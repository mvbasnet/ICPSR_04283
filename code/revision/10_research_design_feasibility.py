"""Bounded documentary synthesis; never loads research data or runs Stages 00-09.

Run from the repository root: python code/revision/10_research_design_feasibility.py
Requires pypdf. Optional --baseline PATH verifies an earlier SHA-256 file inventory.
Network outcomes below are recorded observations, not a claim of permanent availability.
Existing memo/ledger bytes must match assembly and are left untouched; absent
outputs are generated only after both destinations pass preflight. The verification
note is regenerated. No Git mutation or network request.
"""
import argparse
import csv
from datetime import datetime, timezone
import hashlib
import io
import json
from pathlib import Path
import re
import subprocess
import sys

from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[2]
DEST = ["output/reports/stage10_research_design_feasibility.md",
        "output/tables/stage10_claim_verification.csv",
        "output/verification/stage10_verification_unresolved.md"]
URL = "https://www.icpsr.umich.edu/web/ICPSR/studies/4283/versions/V4"
SOURCES = {
    "G": "docs/icpsr/04283-User_guide.pdf",
    "C": "docs/icpsr/DS0001/04283-0001-Codebook.pdf",
    "K": "docs/icpsr/DS0002/04283-0002-Codebook.pdf",
    "P": "docs/icpsr/DS0003/04283-0003-Codebook.pdf",
    "Q": "docs/icpsr/DS0001/04283-0001-Questionnaire.pdf",
    "M": "docs/icpsr/04283-manifest.txt",
    "D": "docs/icpsr/DS0001/04283-0001-Setup.dct",
    "S": "docs/icpsr/DS0001/04283-0001-Setup.do",
}


def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args], text=True).rstrip("\r\n")


def digest(path, algorithm="sha256"):
    return hashlib.new(algorithm, (ROOT / path).read_bytes()).hexdigest()


def norm(s):
    return " ".join(s.split())


def read_csv(path):
    with (ROOT / path).open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def protected_paths():
    paths = set(git("ls-files", "-z").split("\0")) - {""}
    for directory in ["code", "docs", "output", "Data"]:
        paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / directory).rglob("*") if p.is_file())
    return sorted(paths - {DEST[2], Path(__file__).relative_to(ROOT).as_posix()})


def preflight_outputs(contents):
    """Check both memo/ledger destinations without writing any files."""
    assert set(contents) == set(DEST[:2])
    plan = {}
    for path in DEST[:2]:
        target = ROOT / path
        exists = target.exists()
        if exists:
            assert target.is_file() and target.read_bytes() == contents[path], f"Accepted artifact differs from assembly: {path}"
        plan[path] = {"content": contents[path], "existed": exists}
    return plan


def publish_outputs(plan):
    """Recheck both destinations, then create only the identified absent files."""
    checked = preflight_outputs({p: item["content"] for p, item in plan.items()})
    assert checked == plan, "Output destination state changed after preflight"
    for path, item in plan.items():
        if not item["existed"]:
            target = ROOT / path
            target.parent.mkdir(parents=True, exist_ok=True)
            with target.open("xb") as f:
                f.write(item["content"])
    rows = []
    for path, item in plan.items():
        assert (ROOT / path).read_bytes() == item["content"], f"Published bytes differ: {path}"
        rows.append([path, "existing artifact preserved untouched" if item["existed"] else "missing artifact newly generated", digest(path)])
    return rows


def verify_preservation(snapshot, allowed_additions=()):
    assert set(allowed_additions) <= set(DEST[:2]), "Only identified Stage10 outputs may be added"
    assert all((ROOT / p).is_file() and digest(p) == h for p, h in snapshot.items()), "Current-run protected bytes changed"
    current = set(protected_paths())
    assert set(snapshot) <= current and current - set(snapshot) <= set(allowed_additions), "Unauthorized protected file-set change"


def script_observation(path=None):
    """Read actual index membership and worktree status; never mutate Git."""
    path = Path(path or __file__).resolve().relative_to(ROOT).as_posix()
    entry = git("ls-files", "--stage", "--", path)
    status = git("status", "--short", "--untracked-files=all", "--", path)
    tracking = "tracked" if entry else "untracked"
    return {"path": path, "tracking": tracking,
            "status": status or ("clean" if entry else "not listed (possibly ignored)"),
            "index_entry": entry or "none", "sha256": digest(path)}


def render_current_run(started, head, branch, script, baseline_description, argv):
    """Keep observations for this execution separate from dated history."""
    return f"""## Current-run metadata

Execution start (UTC): `{started}`. Repository root verified: `{ROOT.as_posix()}`.
HEAD: `{head}`. Branch/status: `{branch or 'detached HEAD'}`.
Assembly script: `{script['path']}`; tracking: **{script['tracking']}**; observed short status: `{script['status']}`.
Index entry: `{script['index_entry']}`.
Current assembly script SHA-256: `{script['sha256']}`.

Baseline mode: {baseline_description}

Exact current invocation (executable and argv, JSON):

```json
{json.dumps(argv, ensure_ascii=False)}
```

These metadata and preservation checks describe this execution only. A supplied inventory's creation date or historical origin is not authenticated by its hashes. Without a supplied inventory, this execution cannot verify original pre-implementation preservation and does not reconstruct an original baseline.
"""


def table(headers, rows):
    def cell(x):
        return str(x).replace("|", " / ").replace("\n", " ")
    return "\n".join(["| " + " | ".join(map(cell, headers)) + " |",
                      "|" + "---|" * len(headers)] +
                     ["| " + " | ".join(map(cell, r)) + " |" for r in rows])


def main():
    started = datetime.now(timezone.utc).isoformat(timespec="seconds")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path)
    args = parser.parse_args()
    assert Path(git("rev-parse", "--show-toplevel")).resolve() == ROOT
    initial_status = git("status", "--short", "--branch")
    head, branch = git("rev-parse", "HEAD"), git("branch", "--show-current")
    script = script_observation()
    worktree_before = git("diff", "--binary")
    index_before = git("diff", "--cached", "--binary")
    snapshot = {p: digest(p) for p in protected_paths()}
    missing_at_start = {p for p in DEST if not (ROOT / p).exists()}
    if args.baseline:
        supplied_path = args.baseline.resolve()
        supplied_bytes = supplied_path.read_bytes()
        baseline = json.loads(supplied_bytes)
        baseline_description = (f"**supplied inventory** `{supplied_path.as_posix()}`; "
            f"inventory SHA-256 `{hashlib.sha256(supplied_bytes).hexdigest()}`; {len(baseline)} named file hashes. "
            "Checks each supplied path's existence and SHA-256 against that inventory at entry and exit; "
            "it verifies only those named paths, not inventory age or unlisted history. "
            f"A separate {len(snapshot)}-file execution-start snapshot checks current-run preservation and file-set stability.")
        assert baseline and set(baseline) <= set(snapshot), "Supplied inventory must name protected existing files only"
    else:
        baseline = snapshot
        baseline_description = (f"**execution-start snapshot** of {len(snapshot)} protected files, taken at the start of this execution. "
            "Checks those bytes and the protected file set through this execution; no original pre-implementation inventory was supplied or manufactured.")
    assert all((ROOT / p).is_file() and digest(p) == h for p, h in baseline.items()), "Supplied/start baseline differs before assembly"
    run_metadata = render_current_run(started, head, branch, script, baseline_description, [sys.executable, *sys.argv])
    readers, pages = {}, {}
    ledger = []

    def evidence(claim, text, classification, key, page, excerpt, reused, conclusion, question, decision, origin="previously accepted; primary rechecked", status="closed factual check; interpretation bounded"):
        path = SOURCES[key]
        if path.endswith(".pdf"):
            if key not in readers:
                readers[key] = PdfReader(ROOT / path)
            if (key, page) not in pages:
                pages[key, page] = norm(readers[key].pages[page - 1].extract_text())
            source = pages[key, page]
            locator = f"physical PDF p.{page}"
        else:
            source = norm((ROOT / path).read_text(encoding="utf-8-sig"))
            locator = str(page)
        assert norm(excerpt) in source, (claim, locator, excerpt)
        ledger.append(dict(claim_id=claim, claim_text=text, classification=classification,
                           evidence_origin=origin, source_path=path, source_version="ICPSR04283.v4; guide 2009-06-08 / released codebooks and syntax 2017-07-17 as applicable",
                           source_md5=digest(path, "md5"), source_sha256=digest(path), locator=locator,
                           bounded_excerpt=norm(excerpt), reused_evidence_key=reused, conclusion=conclusion,
                           unresolved_question=question, design_decision_affected=decision, stopping_status=status))

    # Curated claims and exact, machine-checked primary passages. No inferred formulas.
    evidence("B01", "Released belief construction and direction are established", "unsupported inference", "G", 40,
             "Scores are derived by taking the mean of all items, with non-traditional beliefs reversed-scored.",
             "belief_score_evidence.csv E003/E004; docs/stage1_unresolved_issues.md Q01",
             "Guide describes a mean and reversal but does not establish release-specific item handling or direction.",
             "What are the exact item key, reversal, completion, prorating and rounding rules for each released grade?", "Substantive direction and any harmonization")
    evidence("B01", "Released belief construction and direction are established", "unsupported inference", "G", 40,
             "In the current dataset, teachers with higher scores have more progressive beliefs.", "Q01; Stage06 conclusions",
             "Record the guide's direction claim explicitly; do not resolve its inconsistency with the stated reversal rule by guessing.",
             "Which direction applies to T_IDEAP and T_IDEAK in v4?", "Progressive/traditional coefficient labels")
    evidence("B02", "Pre-K beliefs are a documented integer sum", "factual contradiction", "C", 538,
             "26.67 - 5 0.5 %", "belief_score_evidence.csv E001",
             "Released categories include fractions; sum-like magnitude is not an integer-sum derivation.", "Release scoring formula remains Q01", "No divide-by-16 or numerical hypothesis search")
    evidence("B03", "Kindergarten belief maximum is 5.00", "factual contradiction", "C", 790,
             "Maximum: 4.06", "belief_score_evidence.csv E002", "Child codebook maximum is 4.06; this is an observed maximum, not a theoretical bound.", "Scoring direction and completeness rules remain unknown", "Grade-specific released units")
    evidence("B03", "Kindergarten belief maximum is 5.00", "factual contradiction", "K", 59,
             "Maximum: 4.06", "Stage06 DS0002 evidence", "Classroom codebook also reports 4.06.", "No evidence of cross-grade equivalence", "No pooling of belief units")
    evidence("B04", "Guide summaries validate a common mean scale", "unsupported inference", "G", 44,
             "Ideas about childrearing 233 38.9 9.88 0.78 t_ideapf", "Q01; Stage06",
             "Pre-K classroom mean 38.9 conflicts with a literal unscaled 1-5 item mean; child-weighted and classroom summaries have different units of observation.",
             "How does the older summary map to the released scoring/version?", "Preserve native scales")
    for page, item in [(22, "31."), (33, "40.")]:
        evidence("B05", "Printed Modernity forms establish the released scoring formula", "unsupported inference", "Q", page,
                 item + " Please circle the answer that indicates how strongly you agree with the following statements.", "belief_score_evidence.csv E003/E004; stage09_source_evidence.csv P_FORM/K_FORM",
                 "Fall Pre-K item 31 and Fall K item 40 contain 16 agreement statements; forms establish questions and anchors, not released aggregation.",
                 "Release-specific scoring and respondent mappings are absent", "Separate report content from score construction")
    evidence("R01", "No-change reports authenticate Fall-to-Spring belief respondents", "unsupported inference", "C", 313,
             "0 No change in teacher, Classroom 972 95.8 %", "stage09_source_evidence.csv P_CHILD_CHANGE; Q08",
             "T_CHNGCP has 972/38/5 among 1015; category labels do not identify the Fall respondent.", "What source reports, missing-report rules and interval endpoints generate each change field?", "No Spring carry-forward or validated no-change subset")
    evidence("R01", "No-change reports authenticate Fall-to-Spring belief respondents", "unsupported inference", "C", 580,
             "0 No change in teacher, classroom 977 96.3 %", "stage09_source_evidence.csv P_TQ_CHANGE; stage09_continuity_diagnostics.csv",
             "T_CHNG has 977/38/0; Stage09 records 1007 agreements and 8 disagreements, despite equal teacher-change marginals.", "Why do the eight child records disagree?", "Keep both Pre-K indicators separate")
    evidence("R02", "The five Pre-K classroom moves establish matched Spring teachers", "unsupported inference", "G", 15,
             "spring assessment and collect teacher questionnaires with those children in their new room.", "stage09_source_evidence.csv P_CLASS_MOVES",
             "Guide describes an attempt to collect in new rooms, not successful collection or respondent correspondence.", "What map identifies the actual Fall belief respondent and Spring teacher?", "No exposure assignment")
    evidence("R03", "Kindergarten no-change reports establish Fall respondent continuity", "unsupported inference", "C", 1115,
             "TCHCHNGK: K: CHANGE IN TEACHERS DURING K YEAR? (1=Y)", "stage09_source_evidence.csv K_CHANGE",
             "Teacher change No/Yes/missing=828/82/105, all-child denominator 1015; observed-report denominator 910.", "Endpoints relative to forms/assessments and reporter identity remain unknown", "Turnover categories only")
    evidence("R03", "Kindergarten no-change reports establish Fall respondent continuity", "unsupported inference", "C", 1116,
             "CLASSCHNGK: K: CHANGE IN CLASSROOM DURING K YEAR? (1=Y)", "stage09_source_evidence.csv K_CHANGE",
             "Classroom change No/Yes/missing=859/51/105, denominator 1015 (910 observed reports).", "Classroom change is not a replacement belief measure", "Separate teacher/classroom/exposure changes")
    for cid, page, variable, excerpt, n in [("P01", 41, "WJ10_SSEPF", "-7 Child Failed Practice Items 7 0.7 %", 7), ("P02", 67, "WJ10_SSEPS", "-7 Child Failed Practice Items 1 0.1 %", 1)]:
        evidence(cid, "There are 16 Spring Pre-K practice failures", "factual contradiction", "C", page, excerpt,
                 f"outcome_cleaning_counts.csv {variable}; outcome_cleaning_rules.csv; Stage07 review",
                 f"{variable}: {n} documented -7 values among 1015 children. Stage07 excludes these only as a project decision for numerical summaries; released setup retains -7.",
                 "No unresolved frequency question in this v4 source", "Retain accepted seven-Fall/one-Spring exclusion; no cleaning rerun", status="closed")
    for var, line, excerpt in [("WJ10_SSEPF", 2606, "replace WJ10_SSEPF = . if (WJ10_SSEPF == -5 | WJ10_SSEPF == -99)"), ("WJ10_SSEPS", 2629, "replace WJ10_SSEPS = . if (WJ10_SSEPS == -5 | WJ10_SSEPS == -6 | WJ10_SSEPS == -99)")]:
        evidence("P03", "Practice-failure exclusion is a project decision rather than an official release missing-code replacement", "supported statement", "S", f"line {line}, {var} replacement", excerpt,
                 "outcome_cleaning_rules.csv; Stage07 review", "Release replacement omits -7; setup label lines 149/196 identify it as Child Failed Practice Items. Existing analytical exclusion remains unchanged.",
                 "No new cleaning decision authorized", "Do not call the exclusion a release correction", status="closed factual check")
    evidence("I01", "Manifest only removes SITE/SPSU from classroom files", "factual contradiction", "M", "2009-06-08 complete version-history entry",
             "differs from the Main Child Level Restricted-Use Version in that SITE and SPSU have been dropped from the public-use version.", "stage09 linkage; Q05/Q07",
             "Full entry explicitly removes SITE/SPSU from DS0001 and both classroom public-use files; STATE was dropped in favor of SPSU.", "No released state/PSU recovery map established", "Population-weighting and sampling-design inference blocked")
    evidence("I01", "Manifest only removes SITE/SPSU from classroom files", "factual contradiction", "M", "2009-06-08 classroom clause",
             "Classroom Level Restricted-Use Version in that SITE and SPSU have been dropped.", "Q05/Q07",
             "Classroom removal is an additional clause, not the whole entry.", "Remaining site fields require their own scope evidence", "Do not overgeneralize removal")
    for page, excerpt in [(315, "SITE_PS: PRESCHOOL: SPRING: SITE ID"), (317, "SITE_PF: PRESCHOOL: FALL: SITE ID"), (319, "SITE_TRPS: PRESCHOOL: SPRING: SITE WHERE TEACHER RATED CHILD"), (1116, "SITE_ECK: K YEAR: SITE OF ECERS"), (1118, "SITE_TRKF: K YEAR: FALL: SITE WHERE TEACHER RATED CHILD"), (1119, "SITE_TRKS: K YEAR: SPRING: SITE WHERE TEACHER RATED CHILD")]:
        evidence("I02", "Manifest removal eliminates every useful grouping field", "unsupported inference", "C", page, excerpt,
                 "stage09_source_evidence.csv SITE_MEANINGS; Q07; identifier_audit.csv",
                 "Named site contexts remain. Their labels do not validate teacher/classroom/state identity, longitudinal stability or cross-file linkage.",
                 "What scope/stability/crosswalk is documented for each site field?", "A later scope audit could permit site descriptions and inform dependence units")
    for key, page, excerpt in [("C", 6, "STUDY_ID: STUDY ID: UNIQUE CHILD IDENTIFIER"), ("K", 6, "CASEID: CASE IDENTIFIER"), ("P", 6, "CASEID: CASE IDENTIFIER"), ("P", 159, "LEAD_1: TEACHER ID")]:
        evidence("I03", "CASEID or LEAD_1 establishes persistent teacher identity and a child merge", "unsupported inference", key, page, excerpt,
                 "stage09_source_evidence.csv CHILD_KEY/CLASSROOM_CASE_KEYS/PREK_CASE_KEY/LEAD_SCOPE; Q05/Q06",
                 "STUDY_ID establishes child identity; CASEID is file record identity; LEAD_1 lacks documented unique scope (244 observed, only 3 distinct values in 245 rows).",
                 "Where is the explicit child-to-classroom/respondent map and uniqueness scope?", "No merge, teacher counts or clustering from these labels")
    evidence("W01", "SITE_WT is a suitable child-analysis population weight", "unsupported inference", "D", "line 545, SITE_WT declaration",
             '"Sampling Weight for Site"', "source_variable_inventory.csv DS0001 SITE_WT",
             "Site-unit weight is not interchangeable with child-unit period weights; DS0003 also has SITE_WT, DS0002 has no weight declaration.",
             "Which released fields implement each documented period and analysis unit?", "No substitution or weight implementation", origin="new primary evidence relative to Stage09; existing local source")
    for page, excerpt in [(301, "CHILD_WTPF: CHILD WEIGHT (FALL)"), (303, "CHILD_WTPS: CHILD WEIGHT (SPRING)")]:
        evidence("W02", "Only site weights are released", "factual contradiction", "C", page, excerpt,
                 "source_variable_inventory.csv DS0001 CHILD_WTPF/CHILD_WTPS; dictionary lines 316-317",
                 "DS0001 releases child Fall and Spring weights in the Pre-K section. Applicability to belief/pair/complete-case subsets is not established.",
                 "What is the v4 Kindergarten or longitudinal weight mapping, if any?", "Distinguish period-specific population target from observed sample", origin="new primary evidence relative to Stage09; existing local source")
    evidence("W03", "Released weights identify a national or arbitrary subset target", "factual contradiction", "G", 16,
             "weights add to 100% within state, not across state.", "guide Generalizability of Weighted Samples",
             "Guide targets eligible classrooms/children in four states and two regions; six states equally weighted, and state must enter weighted analyses.",
             "How can guide-required state/design information be used in this public release? No documented map is supplied.", "Cannot claim a documented population-weighted estimator now", origin="new primary evidence relative to Stage09; existing local source")
    evidence("W04", "Guide attrition adjustments validate weights for every proposed subset", "unsupported inference", "G", 17,
             "In classrooms where children were replaced, the weights for all the children in the classroom are changed to reflect this new dispersion.", "guide Post-stratification Weights",
             "Spring replacement/reweighting is documented. Kindergarten child attrition uses model-based demographic cells; only children were followed, so guide says no classroom nonresponse adjustment.",
             "Which released field carries each adjustment and does it cover joint belief/outcome/covariate missingness?", "No ad hoc subset renormalization or Kindergarten weight borrowing", origin="new primary evidence relative to Stage09; existing local source")
    evidence("W04", "Guide attrition adjustments validate weights for every proposed subset", "unsupported inference", "G", 17,
             "should use the Spring of Pre-K child weights.", "guide period-specific cross-sectional example",
             "Cross-sectional period-specific recommendation does not validate a longitudinal pair, change-score or within-child weight.",
             "Explicit unit/period/target implementation is needed", "Separate documented design from released implementation", origin="new primary evidence relative to Stage09; existing local source")
    evidence("G01", "NotebookLM sampling geography/representativeness is correct", "factual contradiction", "G", 11,
             "California, Illinois, New York, Ohio, Kentucky, and Georgia.", "guide State Selection; manifest",
             "California covers Los Angeles/Central Valley; New York covers NYC/50-mile Albany region. Other four states sampled statewide; national representativeness is explicitly denied.",
             "No uncertainty in stated geography; state codes must not be reconstructed from prefixes", "Correct target population", origin="new primary evidence relative to Stage09; existing local source")
    evidence("G02", "Classroom or child clustering alone necessarily recovers the sampling design", "unsupported inference", "G", 12,
             "Zip code was primary sampling unit.", "guide Sampling",
             "Sampling proceeds through ZIP/PSU, site, classroom, child; shared teachers/sites and within-child dependence may cross later grades. No single inference rule is selected.",
             "Document dependence units, coverage, nesting/crossing, cluster sizes/counts, PSU/state access and finite-sample adequacy", "Uncertainty judgments separate from numerical feasibility", origin="new primary evidence relative to Stage09; existing local source")
    evidence("F01", "Released child beliefs have 987 observed Pre-K records and 840 observed Kindergarten records", "supported statement", "C", 540,
             "Based upon 987 valid cases out of 1,015 total cases.", "belief_score_evidence.csv E001; source inventory",
             "Pre-K belief coverage is 987/1015; this is child-attached coverage, not independent teacher count.", "Joint covariate coverage and teacher identity remain unresolved", "Planning denominator only", status="closed factual check")
    evidence("F01", "Released child beliefs have 987 observed Pre-K records and 840 observed Kindergarten records", "supported statement", "C", 790,
             "Based upon 840 valid cases out of 1,015 total cases.", "belief_score_evidence.csv E002; source inventory",
             "Kindergarten belief coverage is 840/1015; this is child-attached coverage, not independent teacher count.", "Joint covariate coverage and teacher identity remain unresolved", "Planning denominator only", status="closed factual check")
    evidence("F02", "Child weights and their period recommendation are newly relevant evidence beyond Stage09", "new primary evidence relative to the accepted investigation", "G", 17,
             "The weights should be used any time that cross-sectional analysis within a period is performed.", "source_variable_inventory.csv; Stage09 did not resolve weight mapping",
             "Guide's period-specific cross-sectional recommendation is supported; its applicability to each released field/subset remains unverified.", "Released Kindergarten and longitudinal mapping and state requirement unresolved", "Population versus observed-sample description", origin="newly inspected for this synthesis; older local guide")

    evidence("F03", "Sampling eligibility limits the population represented", "supported statement", "G", 14,
             "did not have an Individualized Education Plan", "guide Child Selection",
             "Eligible children were old enough for K in Fall2002, without an IEP, and able to understand simple English/Spanish instructions per teacher; sampling was among consenting families.",
             "Analysis subset generalizability remains unvalidated", "Do not describe all children or a national population", origin="newly inspected for this synthesis; older local guide", status="closed factual check")
    evidence("F04", "Rhyming raw scores have a documented maximum of 17", "supported statement", "G", 48,
             "The maximum possible on this scale is 17.", "Stage07 rhyming rule/evidence",
             "The English Sound Awareness-Rhyming description supplies the bound used in accepted Stage07 rules; it does not justify score conversion or absolute growth language.",
             "Other bounds and comparability remain as accepted", "Retain metric-specific interpretation and current rules", status="closed factual check")
    manifest = (ROOT / SOURCES["M"]).read_text()
    supplemental = []
    for ds in range(1, 4):
        for ext in ["do", "sas"]:
            name = f"04283-{ds:04d}-Supplemental_syntax.{ext}"
            line = next(x for x in manifest.splitlines() if x.strip().startswith(name))
            expected_md5 = line.split()[-1]
            path = f"docs/icpsr/DS{ds:04d}/{name}"
            assert not (ROOT / path).exists(), "Newly available supplemental file requires actual inspection; do not infer contents"
            supplemental.append([f"DS{ds:04d}", name, "blocked", expected_md5, "not retrieved / not inspected / checksum unavailable"])
            ledger.append(dict(claim_id=f"S{ds:02d}_{ext}", claim_text="Supplemental syntax was already inspected and contains only import/missing-code statements",
                classification="unsupported inference", evidence_origin="new retrieval attempt; contents uninspected",
                source_path=SOURCES["M"], source_version="ICPSR04283.v4; supplemental listing 2017-07-17",
                source_md5=digest(SOURCES["M"], "md5"), source_sha256=digest(SOURCES["M"]), locator=f"DS{ds:04d} exact filename row",
                bounded_excerpt=norm(line), reused_evidence_key="belief_score_evidence.csv E005-E010; stage09 MISSING_DERIVATION_SYNTAX",
                conclusion=f"{name}: blocked at official listing; not retrieved or inspected; manifest expected MD5 {expected_md5}, not a retrieved-file checksum.",
                unresolved_question="Scoring, continuity derivation, linkage, dates and weight applicability cannot be checked in this file.",
                design_decision_affected="Cannot close Q01/Q05-Q08 or weight mapping using uninspected syntax", stopping_status="blocked; bounded acquisition closed without expansion"))

    support_path = "output/tables/stage08_belief_outcome_support.csv"
    support = read_csv(support_path)
    support_rows = []
    for outcome in ["ppvt_english_standard_score", "applied_problems_english_standard_score", "sound_awareness_rhyming_raw_score"]:
        for grade in ["Pre-K", "Kindergarten"]:
            rows = [next(r for r in support if r["outcome"] == outcome and r["grade"] == grade and r["outcome_period"] == period) for period in ["fall", "both"]]
            assert all(r["denominator_all_children"] == "1015" and r["mapped"] == "TRUE" for r in rows)
            support_rows.append([outcome, grade, rows[0]["n_overlap"], rows[1]["n_overlap"], rows[0]["denominator_belief_nonmissing"]])
    assert [int(r[2]) for r in support_rows] == [791, 755, 776, 769, 784, 769]
    assert [int(r[3]) for r in support_rows] == [737, 742, 721, 756, 729, 756]
    both_beliefs = [r for r in read_csv("output/tables/belief_score_support.csv") if r["dataset_id"] == "DS0001" and r["stratum"] == "both" and r["scale_id"] == "released"]
    assert len(both_beliefs) == 2 and all(r["n_finite"] == "821" for r in both_beliefs)
    continuity = [r for r in read_csv("output/tables/stage09_continuity_diagnostics.csv") if r["group_kind"] == "all_children" and r["diagnostic"] == "change_crosstab" and r["grade"] == "Pre-K" and r["field_a"] == "T_CHNGCP" and r["field_b"] == "T_CHNG"]
    assert sum(int(r["n_children"]) for r in continuity if r["category_a"] == r["category_b"]) == 1007
    assert sum(int(r["n_children"]) for r in continuity if r["category_a"] != r["category_b"]) == 8
    spanish = [[r["outcome"], r["grade"], r["metric"], r["n_overlap"] if r["mapped"] == "TRUE" else "undefined: mapping gap", r["row_id"]]
               for r in support if r["language"] == "Spanish" and r["outcome_period"] == "both"]
    counts = read_csv("output/tables/outcome_cleaning_counts.csv")
    for var, expected in [("WJ10_SSEPF", 7), ("WJ10_SSEPS", 1)]:
        row = next(r for r in counts if r["source_variable"] == var)
        assert int(row["n_practice_failure_project_excluded"]) == expected and row["n_structural"] == "1015"
    inventory = read_csv("output/tables/source_variable_inventory.csv")
    weight_rows = []
    for ds, var, observed, denominator in [("DS0001", "CHILD_WTPF", 939, 1015), ("DS0001", "CHILD_WTPS", 948, 1015), ("DS0001", "SITE_WT", 1007, 1015), ("DS0003", "SITE_WT", 238, 245)]:
        row = next(r for r in inventory if r["dataset_id"] == ds and r["raw_variable"] == var)
        assert int(row["observed_nonmissing_n"]) == observed
        weight_rows.append([ds, var, observed, row["observed_missing_n"], denominator, row["variable_position"]])
    assert not [r for r in inventory if r["dataset_id"] == "DS0002" and "WEIGHT" in r["raw_variable"]]
    for ds in range(1, 4):
        dct = (ROOT / f"docs/icpsr/DS{ds:04d}/04283-{ds:04d}-Setup.dct").read_text()
        declarations = re.findall(r"_column\(\d+\)\s+\w+\s+(\w+)", dct)
        assert not set(declarations) & {"STATE", "SPSU", "SITE"}
    checks = []
    for name, expected in [("belief_score", 2192), ("outcome_cleaning", 3612), ("stage08", 1944), ("stage09", 1059)]:
        rows = read_csv(f"output/verification/{name}_checks.csv")
        statuses = {s: sum(r["status"] == s for r in rows) for s in {r["status"] for r in rows}}
        assert statuses.get("pass") == expected and set(statuses) <= {"pass", "recorded", "review"}
        checks.append([name, len(rows), "; ".join(f"{s}={statuses[s]}" for s in sorted(statuses)) + "; not rerun"])

    buf = io.StringIO(newline="")
    writer = csv.DictWriter(buf, fieldnames=list(ledger[0]), lineterminator="\n")
    writer.writeheader()
    writer.writerows(ledger)
    ledger_text = buf.getvalue()
    assert len(list(csv.DictReader(io.StringIO(ledger_text)))) == len(ledger)
    assert len({r["claim_id"] for r in ledger}) >= 25

    memo = """# Stage 10: finite research-design feasibility investigation

This bounded review supports planning grade-specific descriptions of released Fall belief scores. It does not establish a population-weighted, causally identified, or fully specified inferential analysis. No final specification or sample is selected. Stages 00-09 and their rules remain intact; no regressions, differences, harmonization, Spring assignment, merges, weights or clustering were implemented.

## Evidence status and consequential reconciliations

The companion ledger gives source checksums, physical PDF pages or exact text locators, bounded verbatim excerpts, reused evidence keys, classifications, unresolved questions and decisions affected. “New primary evidence” means newly inspected relative to the accepted Stage09 investigation, including older documents already in the repository. Accepted counts are reused, not newly estimated. The supplied reviewed plan is the complete claim set available here; the original NotebookLM transcript was not supplied, so no exact wording or omitted claims are attributed to it.

**Beliefs (B01-B05).** G p.40 describes a 16-item mean, reversal of nontraditional items and higher progressive scores, yet G p.44 reports Pre-K classroom mean 38.9. C pp.538-540 lists fractional Pre-K categories and mean 38.78; C pp.788-790 and K pp.57-59 give observed Kindergarten maximum 4.06, not 5.00. These facts do not establish a released formula, direction, completion threshold, prorating or rounding. Q pp.22/33 establishes the 16 agreement questions, not the released derivation. The guide's reversal language and direction claim are not silently reconciled. Release-specific distributions take priority for describing released values; they cannot supply a missing scoring key. Continue saying “higher released score,” separately by grade. Dividing by 16 or standardizing does not establish equivalence.

**Respondents (R01-R03).** T_CHNGCP=0/1/2 has 972/38/5 children; child-attached T_CHNG has 977/38/0 (each denominator 1015). Stage09 records 1007 literal agreements and eight disagreements. Equal teacher-change marginals do not establish agreement by child. G p.15 explains five same-site classroom moves and attempted collection in new rooms, without authenticating actual respondents. Kindergarten teacher change No/Yes/missing=828/82/105 and classroom change=859/51/105; observed-report denominator is 910 for each, all-child denominator 1015. Keep the two Pre-K fields and teacher/classroom changes distinct. No-change does not identify a validated continuity subset. Fall forms do not establish report onset, exposure duration, or ordering relative to individual assessments; Stage09's date limitations stand. No replacement teacher belief measure was identified in inspected released fields; that is not proof that none was collected.

**Practice failures (P01-P02).** C physical p.41, WJ10_SSEPF, explicitly has seven -7 values; p.67, WJ10_SSEPS, has one, each among 1015 children. Existing Stage07 counts agree. Sixteen Spring failures is contradicted for this release. The eight cell exclusions are project decisions for numerical summaries, not an official release correction, full psychometric validation or a new cleaning rule.

**Manifest and identity (I01-I03).** The full 2009-06-08 entry removes SITE/SPSU from DS0001 and both public classroom files; STATE was dropped in favor of SPSU. It also adds SITE_TRPS/TRKF/TRKS/ECK and corrects SITE_PF for children without Fall Pre-K data. SITE_PF/PS identify stated Pre-K sites, SITE_TRPS/TRKF/TRKS identify sites where teachers rated children, and SITE_ECK identifies the ECERS site. Remaining fields refute “all grouping is lost,” but do not validate persistent teacher/classroom/school/state keys or a cross-file map. STUDY_ID is child identity; classroom CASEID is file record identity. LEAD_1's teacher-ID label has no documented uniqueness scope; its 244 observed entries and three distinct codes among 245 classroom records cannot establish teacher counts. Do not infer state from prefixes or match composite values.

**Weights and geography (W01-W04, G01-G02).** G pp.11-17 describes four-stage sampling (ZIP/PSU, site, classroom, child), with state-specific oversampling, gender-based child selection, Spring replacement/reweighting and model-based Kindergarten child attrition adjustment. The eligible child target is children old enough for K in Fall 2002, without an IEP and able to understand simple English or Spanish instructions, sampled from consenting families in eligible state-funded classrooms (G p.14). The geography is California, Illinois, New York, Ohio, Kentucky and Georgia. California covers greater Los Angeles/Central Valley and New York covers NYC/50-mile Albany; only the other four states were sampled statewide. This is not a national sample.

The guide's technical target is eligible Pre-K classrooms and their children in those four states/two regions. It states that the six states are equally weighted, weights normalize to 100% within state, and state must enter weighted analyses (G p.16). This describes the intended design; released numeric weights are not independently certified as normalized percentages here. CHILD_WTPF/CHILD_WTPS are the released child Fall/Spring fields in the Pre-K section (C pp.301-305; dictionary lines 316-317). SITE_WT is a site-unit sampling weight in DS0001 and DS0003, not a substitute child weight; no DS0002 weight declaration was identified. No explicitly labeled Kindergarten child weight was identified in the three dictionaries or source inventory. G p.17's Kindergarten adjustment therefore lacks a verified released-field mapping. Period-specific child weights are recommended for cross-sectional analysis; that does not validate weights for paired, both-belief, complete-case or longitudinal subsets. The guide-required state and original PSU fields are absent from these public declarations. No reconstruction or implementation is justified.

### Weight availability, reused from source inventory

{weights}

These are coverage counts, not counts for belief/outcome/covariate intersections. The locator is dataset_id + raw_variable (variable_position also shown) in output/tables/source_variable_inventory.csv. Differences between guide recruitment totals and released valid counts (e.g., 940 Fall recruited versus 939 observed Fall weights; 960 Spring participants versus 948 weights) must not be silently treated as interchangeable denominators.

## Five design comparisons

Let B_g be the child-attached released Fall belief score for grade g. Y_gF and Y_gS denote separately identified outcome metrics. “Association” is descriptive. Native standard scores can describe relative standing on their reported metric; differences are not absolute skill growth. Rhyming is bounded raw performance (documented maximum 17). W-score growth interpretation needs scale/comparability documentation. English and Spanish instruments remain separate; no conversion or pooling is supported by this review.

### 1. Grade-specific Fall associations

**Point estimation:** Numerically feasible for the association between B_g and usable Fall outcomes, separately by grade/instrument/language/metric, optionally conditional on explicitly defined observed characteristics. It needs child linkage and native scores, without Spring teacher assignment. A unit is a unit of the released grade-specific score; substantive progressive/traditional direction remains unresolved. Fall need not precede instruction for a contemporaneous association, but “entry ability” or pre-exposure claims require additional evidence.

**Uncertainty:** Not finalized. Even one row per child may share teachers/sites and the original sampling design. Validate dependence units, coverage, cluster counts/sizes, nesting/crossing and relevant design fields before selecting an uncertainty procedure. Independent-child errors are not established.

**Causality:** Unsupported: sorting, unmeasured family/teacher inputs and potentially performance-related reporting remain. Observed controls alone do not supply exogenous assignment.

**Requirements and population:** Most plausible first descriptive route. Resolve scoring direction for substantive labels, define covariate timing/measurement and joint support, and establish dependence/design information before inferential claims. An observed-sample released-score description can remain explicitly unweighted and bounded, without claiming the guide's population target. Spring outcomes and no-change restrictions are not eligibility requirements. Pre-K income/education are earlier descriptors for K, not proven contemporaneous K controls.

### 2. Spring associations conditional on Fall performance

**Point estimation:** Numerically feasible as an association of B_g with Spring performance conditional on the same instrument's usable Fall metric and defined characteristics. Pair availability is required. Unknown questionnaire ordering limits temporal interpretation but does not automatically make this descriptive association impossible. Fall may already reflect instruction; baseline measurement error and unobserved sorting remain.

**Uncertainty:** Unresolved for shared teachers/sites and original PSUs; pair selection also changes coverage. A single child record does not eliminate dependence. No final SE or weighting choice is supplied.

**Causality:** Unsupported. Baseline adjustment does not isolate incremental learning or teacher effectiveness. Interpreting B_g as Spring-teacher exposure additionally requires respondent correspondence and exposure-period evidence that no-change flags do not establish.

**Requirements and population:** Plausible second route, explicitly framed as the Fall report's association with later performance. Need scoring interpretation, metric validity, covariate joint support, missingness/selection assessment and dependence information. Exposure interpretation needs a documented respondent/interval map. A no-change subset would be another selected population, not a default rule.

### 3. Within-grade outcome-change associations

**Point estimation:** Conditional feasibility only: pair availability permits numerical subtraction, but intended change interpretation requires documented comparability of Fall/Spring scores for the same instrument/language/metric. No difference was constructed. Standard-score changes concern reported relative performance, raw rhyming changes concern bounded test performance, and W-score growth requires verified scale documentation. Differencing removes an additive constant level component, not ability-related growth or changing confounders; it imposes baseline coefficient one, unlike unrestricted baseline adjustment.

**Uncertainty:** Pair dependence/shared contexts, score error and sampling structure remain unresolved. Differencing does not repair missing cluster/design information.

**Causality:** Unsupported. Time-varying sorting/inputs, measurement error and respondent/exposure uncertainty remain.

**Requirements and population:** Same paired support ceiling as route 2, before controls. Require exact outcome comparability and exposure evidence for any exposure language, plus dependence/design validation. Practice exclusions and selective pair availability matter. Do not prefer change scores because of significance or presume they are superior to baseline adjustment.

### 4. Cross-grade within-child comparisons

**Point estimation:** A substantive common-belief coefficient remains blocked by unvalidated cross-grade units/direction and outcome comparability. Matched Fall-to-Fall comparisons would avoid a new Spring assignment but still need equivalent measures. Four-occasion exposure models additionally need justified Spring assignments. There are 821 children with both Fall beliefs (Stage06 support); this is an availability ceiling, not a joint outcome/covariate sample. Four-wave outcome completeness alone does not establish joint support. No normalized coefficient is manufactured.

**Uncertainty:** Child repetition plus potentially changing/crossed teachers/sites and original PSUs must be documented. Child clustering alone can miss shared contexts; four occasion clusters do not establish a defensible procedure. A multilevel model does not recover undocumented units.

**Causality:** Unsupported. Child effects remove time-constant child heterogeneity under the model, and period effects absorb common shifts, but child-specific maturation, changing inputs, sorting and carryover remain. Maturation does not by itself prove that every descriptive within-child coefficient is mathematically unidentified.

**Requirements and population:** Release scoring and equivalence, matched outcome metric validation, joint availability/variation, dependence structure and (for four occasions) exposure correspondence. Retain as conditional future work; no variation audit, rescaling, sample or fixed-effects specification is selected here.

### 5. Turnover analyses

**Point estimation:** Descriptive outcome distributions or, conditionally on route 3 measurement requirements, score-change differences across each released change category are possible. Retain missing categories and both Pre-K indicators separately. Teacher change, classroom change and change in belief exposure are different quantities. No replacement belief or exposure-duration measure was identified; this prevents a documented belief-exposure-change estimand. Event-study feasibility is unsupported without event dates and suitable repeated pre/post observations; four scheduled assessments do not supply them automatically.

**Uncertainty:** Child counts are not independent turnover events. Need documented event/teacher units, event counts, category-specific outcome/characteristic support and dependence structure. Counts 38/82 alone establish neither severe low power nor adequate inference; no power or SE result is claimed.

**Causality:** Unsupported; turnover can be selective. A no-change comparison, conditioning on initial beliefs or child effects does not establish exogenous turnover.

**Requirements and population:** Reconcile source definitions/endpoints for stronger interpretation, identify event counts and actual replacement beliefs for exposure change, and document temporal support for an event study. Until then, only separate reported-category descriptions are plausible. Stage09 retains category support for each belief-plus-outcome-pair group; no new restriction is chosen.

## Reused planning support, not an estimation sample

{support}

All-child denominator is 1015 in every row. Counts are distinct children with an observed native Fall belief plus the indicated Stage07-usable score(s); the final column gives the grade's observed-belief denominator (987 Pre-K, 840 K). Exact source: output/tables/stage08_belief_outcome_support.csv; row_id = overlap:<outcome>:<grade>:fall or :both. Controls have not been jointly required, and nested future specifications must share an outcome-specific sample. The earlier Stage05 uncleaned Applied Problems counts are not substituted for accepted Stage08 counts.

Spanish paired availability remains separate:

{spanish}

Source is the same Stage08 table, exact row_id shown. Denominator 1015 all children; observed belief denominators 987/840. Mapping gaps are undefined, not zero. No smaller battery is pooled or converted to improve support.

## Bounded supplemental retrieval

Official v4 listing: {url}. All six exact manifest-listed files have the following endpoint:

{supplemental}

On 2026-10-17 (America/Chicago), web access to the version URL returned a cache miss; direct sandbox urllib access failed DNS (Errno 11001); the approved network retry returned HTTP 403 Forbidden. The web-rendered general study page was readable but supplied no supplemental download links. The shared listing failure blocks each of the six files; there is no file-specific HTTP 404 and no basis to classify them as nonexistent. No supplemental bytes, retrieved checksums, language-version comparison or content/dependency inspection is available. Expected MD5s above come only from the local v4 manifest. Nothing was executed. No restricted data, additional source acquisition or inquiry was pursued. Claims that these files contain only import/recode instructions remain unverified; setup contents cannot be transferred to them.

## Supersession and stopping decision

This memo supersedes the supplied claim of sixteen Spring practice failures with seven Fall/one Spring (P01/P02); the proposed K maximum 5.00 with released observed maximum 4.06 (B03); classroom-only manifest quotation with the full all-three-file removal (I01); site-only weighting with released child Fall/Spring fields and unresolved applicability (W01-W04); and incorrect/national geography with the four-state/two-region target (G01). These correct claims presented for verification, not Stage07-09 cleaning or empirical results. Any blanket statement that no grouping information remains is narrowed to the particular removed fields (I02). Stage09's historical “not acquired in that stage” is now supplemented by a blocked retrieval attempt, without rewriting its accepted bytes. No accepted scoring/correspondence blocker is overturned.

Prioritize route 1 and conditionally route 2 for a separately authorized descriptive implementation. Route 3 needs additional measurement justification; route 4 needs equivalence; route 5 supports reported categories but not belief-exposure changes or an event study. All routes still need defensible dependence/design evidence before inferential claims; causal interpretation is unsupported for all five. Exact unresolved evidence questions and alternative choices are recorded in the verification note. The investigation stops here with blocked syntax and explicit documentary endpoints, without requesting broader acquisition or selecting an estimator/sample.

## Source key

G = docs/icpsr/04283-User_guide.pdf (2009-06-08); C = docs/icpsr/DS0001/04283-0001-Codebook.pdf; K/P = DS0002/DS0003 corresponding codebooks (2017-07-17); Q = DS0001 questionnaire (2017-07-17); M = docs/icpsr/04283-manifest.txt; D = DS0001 Setup.dct. All page references are physical PDF pages. Source hashes and bounded passages are in the claim CSV; full manifest entry is reproduced in the verification note.
""".format(weights=table(["Dataset", "Field", "Observed", "Missing", "File denominator", "Inventory position"], weight_rows),
           support=table(["Outcome", "Grade", "Belief + Fall", "Belief + pair", "Observed-belief denominator"], support_rows),
           spanish=table(["Outcome", "Grade", "Metric", "Belief + pair", "Exact row_id"], spanish),
           supplemental=table(["Dataset", "Exact file", "Status", "Manifest expected MD5", "Inspection"], supplemental), url=URL)

    entry = norm(manifest[manifest.index("2009-06-08 Main Child"):manifest.index("2006-03-28 A restricted")])
    source_rows = [[key, path, digest(path, "md5"), digest(path)] for key, path in SOURCES.items()]
    for key, path in SOURCES.items():
        if path.endswith(".pdf") and key != "Q":
            assert digest(path, "md5") in manifest, f"Manifest checksum mismatch: {path}"
    assert digest(SOURCES["Q"], "md5") in manifest
    unresolved = [
        ["U01 / Q01", "T_IDEAP/T_IDEAK: exact v4 items, reversal, aggregation, completion, prorating, rounding, direction and cross-grade equivalence?", "G40/44, C538-540/788-790, K57-59, Q22/33, dictionaries/setup, Stage06; supplemental blocked", "Guide mean/reversal/direction versus sum-like Pre-K fractions; distributions cannot identify formula", "Retain native grade units now; a documented rule plus later release-value validation could permit labels/transformation; otherwise withhold cross-grade coefficient"],
        ["U02 / Q08", "How are T_CHNGCP/T_CHNG generated, including missing reports, reporters and endpoints, and what map authenticates the Fall belief respondent as Spring teacher in each grade?", "C313-314/580/1115-1116, G15, Q forms, all dictionaries/setup, Stage09; supplemental blocked", "Pre-K 972/38/5 versus 977/38/0 and eight disagreements; same marginals do not reconcile individuals", "Keep reports separate; explicit mapping could support a correspondence subset; otherwise no exposure carry-forward"],
        ["U03 / Q05-Q07", "What are CASEID/LEAD_1/SITE_* uniqueness scopes, cross-wave stability, and explicit DS0001-to-classroom/respondent mapping?", "Full M entry, C6/315/317/319/1116/1118-1119, K/P6, P159, dictionaries/setup, forms and Stage09", "Site fields remain but do not establish teachers or state; LEAD_1 has only three observed distinct codes", "Use documented site contexts only; a future map/scope audit could permit grouping/linkage; otherwise no merge or teacher clustering"],
        ["U04 / weights", "Which released field implements Kindergarten attrition weights, what weights apply to each child/period/subset, and where is the guide-required state/PSU information?", "G11-17, C301-305, three dictionaries/setup, source inventory, full M; six supplements blocked", "Guide describes K adjustment; no explicit K weight mapped; STATE/SPSU absent; coverage counts differ from recruitment counts", "Observed-sample description remains possible; documented unit/period/target plus design access would be required for population weighting; do not substitute SITE_WT or infer state"],
        ["U05 / uncertainty", "What documented dependence units, coverage, nesting/crossing, cluster counts/sizes and sampling-design information support uncertainty estimates for the eventual route?", "G11-17, M, identifier audit, Stage09 scope evidence", "Repeated children, shared contexts and original PSUs differ; no validated final hierarchy", "Later bounded structure audit then consistent justified inference; until then no claimed defensible SE choice, no multilevel/design shortcut"],
        ["U06 / Q09 and Stage07", "Which instrument/language/metric pairs are comparable for reported change or absolute growth, including W scores and Spanish mapping gaps?", "Stage07 rules/evidence/review; G48 and accepted Q09; Stage08 pair support", "Standard/raw/W metrics differ; English/Spanish not equated; some pairs unmapped", "Keep native metrics and gaps; verified comparability could permit a separately authorized change analysis; otherwise omit the affected interpretation"],
        ["U07 / timing and turnover", "Are there documented assessment/form calendar mappings, exposure intervals, replacement-belief measures and event dates with repeated pre/post support?", "Stage09 complete bounded date search, field timing and forms; G15; dictionaries/setup; blocked syntax", "Seasonal forms and ages/spacing do not establish individual ordering; no replacement belief identified", "Fall-report descriptions remain possible; documented mapping could strengthen temporal/exposure interpretation; without event support no event study"],
    ]
    output_plan = preflight_outputs({DEST[0]: memo.encode("utf-8"), DEST[1]: ledger_text.encode("utf-8")})
    allowed_additions = {p for p, item in output_plan.items() if not item["existed"]}
    assert allowed_additions <= missing_at_start, "An execution-start output disappeared before preflight"
    note = f"""# Stage 10 verification and unresolved issues

{run_metadata}

## Historical implementation observations (2026-10-17, America/Chicago)

This section preserves the original dated implementation account. It is not a log of commands or retrieval attempts performed by the current execution. The original account records a clean initial checkout, consultation of AGENTS.md and the supplied reviewed-plan attachment, and an untracked assembly script at that time. None of those historical status observations determines the script's current tracking status, HEAD or branch; current observations are reported above. The original account reported 114 protected hashes matching an external pre-implementation inventory. That historical claim is retained as history, not reverified or reconstructed automatically on later runs. Only a supplied, existing inventory can support an additional present-day comparison to its recorded hashes, with its scope identified above.

Historical read/search commands:

```powershell
git rev-parse --show-toplevel
git status --short --branch
rg --files -g AGENTS.md -g '*feasib*' -g '*manifest*' -g '*09*' -g '*08*' -g '*07*' -g '*06*' -g '*05*' -g '*04*' -g '*03*' -g '*02*' -g '*01*' -g '*00*' -g '*.md'
Get-Content AGENTS.md -Raw
rg --files output code/revision docs
rg -n 'SITE_WT|CHILD_WT|STATE|SPSU|SITE_TR|LEAD_1|CASEID' docs/icpsr -g '*Setup.dct'
```

The historical account reports that root/status/read/search commands succeeded. An earlier rg command used a Windows wildcard path (`docs/icpsr/DS000*/04283-*-Setup.dct`) and returned OS error 123; the directory plus -g form shown above succeeded. Read-only Get-Content commands inspected Stage06-09 evidence, counts, reports, checks, manifest and the existing issue register. `rg -n 'WJ10_SSEP[FS]|Child Failed Practice|CHILD_WT|SITE_WT' docs/icpsr/DS0001/04283-0001-Setup.do` checked label/replacement blocks. Scratch inspect_sources.py extracted relevant PDF pages. The original external inventory was reported to contain 114 files before project writes; a current execution-start snapshot must never be substituted for that historical inventory.

Historical retrieval observations: bundled Python `urllib.request.urlopen('{URL}', timeout=30)` failed with DNS Errno 11001 in sandbox (exit 1). The approved network retry returned HTTP 403 Forbidden (exit 1). No listing file was written. Web open of the same URL returned cache miss; the general study page was readable but exposed no supplemental download links in its rendering. All six files were consequently classified as blocked and uninspected at that date, not confirmed nonexistent. No additional acquisition or inquiries followed; unrelated search results were not used as evidence. These downloads are not retried by this script, and these historical failures do not describe current server availability.

Historical assembly/verification command (retained as history; not the current invocation):

```powershell
& 'C:/Users/mvbas/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' code/revision/10_research_design_feasibility.py --baseline 'C:/Users/mvbas/.codex/visualizations/2026/10/18/01a14d12-2fa2-7441-9a10-e2d48463005c/protected_baseline.json'
```

Historical development runs stopped before publication on three checker assertions: field matching included label text (fixed by parsing declared names); Stage06 was incorrectly assumed to contain only pass rows (corrected to preserve 2192 pass, four recorded and one review); and the Pre-K continuity check included the K crosstab (restricted to the exact grade/field pair). The original account reports separate fixes and reruns without changing accepted artifacts. An interim Get-Item returned exit 1 before outputs existed. An apply_patch context mismatch made no changes before being reapplied. These are historical development events, not current-run failures or checks.

## Current-run assembly verification

Portable reproduction from the project root: `python code/revision/10_research_design_feasibility.py` (pypdf required), optionally with `--baseline PATH` naming an existing inventory. The exact invocation for this execution is recorded above. No network request, completed analysis, cleaning or estimation is run. Only Stage10 assembly is checked. Both memo/ledger destinations are preflighted before any write: existing bytes must match assembly and remain untouched; missing destinations are generated from the assembled bytes. A differing existing artifact stops publication before any output is written, including when its companion is missing. Creation uses exclusive mode to avoid overwriting a file that appears after preflight. This execution regenerates the verification note. Current source/accepted-input fingerprints are recorded below; historical acquisition and original preservation are not inferred from them.

### Current-run output publication

{{OUTPUT_PUBLICATION}}

Each resulting output is read back, required to equal its assembled bytes, and hashed. Specifically identified output destinations missing at execution start: {', '.join(sorted(missing_at_start)) or 'none'}. Only the missing memo/ledger destinations listed as newly generated above may be added to the protected file set; the verification note is the separately identified regenerated destination. Existing protected files cannot be removed or changed.

PASS: {len(ledger)} ledger evidence rows round-trip through CSV; existing available-source excerpts are checked at their recorded locators; exact Stage08 table keys/counts and accepted Stage07 failure counts reconcile. All primary PDF MD5s used in the ledger match the local manifest. This reruns assembly assertions, not the underlying analyses or research-design investigation. The six blocked supplemental dispositions are retained historical observations. Five route discussions and the claim ledger remain accepted. Existing recorded check files read during assembly (their analyses were not rerun):

{table(['Accepted check file prefix', 'Rows', 'Status'], checks)}

## Source hashes

{table(['Key', 'Path', 'MD5', 'SHA-256'], source_rows)}

## Complete manifest entry reconciled

Locator: docs/icpsr/04283-manifest.txt, Version History, 2009-06-08 through immediately before 2006-03-28. The entry is retained in full here so the DS0001 clause cannot be lost when quoting the classroom clause:

> {entry}

Interpretation: SITE/SPSU removal covers all three public-use datasets; STATE replacement by SPSU precedes public-use removal. Added/corrected SITE_* fields still need their own identity/scope validation. This supports I01/I02 without inventing a linkage.

## Supplemental-file disposition

{table(['Dataset', 'File', 'Classification', 'Expected manifest MD5', 'Inspection/checksum endpoint'], supplemental)}

These are historical 2026-10-17 dispositions, sharing the blocked official listing provenance `{URL}`; dataset/version are DS0001-3, v4. No supplemental checksum or content inspection was available in the original account. Contents, executable derivations, comments, external dependencies and language-version differences remain uninspected, not negative findings. This execution did not request downloads, execute syntax or save supplemental sources.

## Exact unresolved evidence questions and alternatives

These are recorded questions for a future authorized step, not external inquiries or a request to expand this task. Only affected interpretations remain stopped; the bounded synthesis is complete.

{table(['Issue', 'Exact question', 'Sources checked', 'Conflict or missing evidence', 'Decision/alternatives'], unresolved)}

Q02 (DR), Q03 (bounds), Q04 (collapsed missing reasons), Q09 (language mapping) and Stage07 metric warnings remain as accepted; none is reinterpreted by this memo. No cleaning or sampling decision changes. The existing issue register remains byte-identical; this note records new endpoints separately.

## Accepted historical supersession record (2026-10-17)

The accepted 2026-10-17 record corrects sixteen Spring failures to seven Fall/one Spring (P01/P02); 5.00 to observed 4.06 (B03); partial manifest quotation to all-three-file scope (I01); and the grouping, weight and geography claims (I02, W01-W04, G01). These superseded supplied claims, not Stage00-09 values/rules. Stage09 non-acquisition was supplemented by the blocked retrieval attempt in that dated investigation. This run preserves those conclusions without reopening their interpretation.

## Current-run preservation verification

PASS: all {len(snapshot)} execution-start protected SHA-256 hashes match at exit; every protected file present at entry remains unchanged. This covers Stages00-09 scripts/accepted outputs, raw/processed research files, legacy analysis, mappings, the issue register, and whichever Stage10 memo/ledger artifacts existed at entry. Permitted protected file additions are limited to these specifically identified missing output destinations: {', '.join(sorted(allowed_additions)) or 'none'}. The publication table distinguishes preserved existing artifacts from newly generated ones and records verified resulting hashes. The assembly script and regenerated verification note are excluded from this protected snapshot; the current script fingerprint is separately checked and recorded above. This proves preservation during this execution only. HEAD, branch/detached status, script tracking/status and initial worktree/index diffs are also checked unchanged during execution, allowing already tracked scripts or pre-existing changes without claiming a clean checkout.

Baseline comparison mode: {baseline_description}

PASS: all {len(baseline)} hashes in the selected supplied/start inventory match both entry and exit. This does not by itself authenticate when an externally supplied inventory was created. If no inventory was supplied, the comparison is solely to this execution's start snapshot. No original inventory is synthesized. Historical preservation claims in the dated section remain historical, separate from these current-run results.

{table(['Current execution protected path', 'SHA-256 at execution start = exit'], sorted(snapshot.items()))}

## Final verification commands

The following Git commands are executed in the current run; their actual exit codes are recorded below. A diff exit code 1 indicates an observed pre-existing diff, not an assembly-induced change; worktree/index diff snapshots must match entry exactly. `git check-ignore` confirms each output's existing ignore status. The assembly script's actual tracking and status are observed above; neither tracked nor untracked is assumed. No force-add, staging, commit, push or Git history/index mutation is performed.

{{CURRENT_CHECKS}}

Execution end (UTC): `{{FINISHED_AT}}`.
Accepted memo SHA-256: `{{MEMO_SHA256}}`.
Accepted claim CSV SHA-256: `{{LEDGER_SHA256}}`.

Final `git status --short --branch`:

```text
{{FINAL_STATUS}}
```

No commit or push was requested or performed; HEAD remains `{head}`. Assembly-entry status was:

```text
{initial_status}
```
"""
    assert all(digest(p) == h for p, h in baseline.items()), "Protected bytes changed"
    verify_preservation(snapshot)
    assert git("diff", "--binary") == worktree_before
    assert git("diff", "--cached", "--binary") == index_before
    assert git("rev-parse", "HEAD") == head
    assert git("branch", "--show-current") == branch
    assert script_observation() == script, "Assembly script state/bytes changed during execution"
    if args.baseline:
        assert supplied_path.read_bytes() == supplied_bytes, "Supplied inventory changed during execution"
    command_results = []
    for command in [["diff", "--check"], ["diff", "--exit-code"], ["diff", "--cached", "--exit-code"]]:
        result = subprocess.run(["git", "-C", str(ROOT), *command], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        assert result.returncode in ([0] if command == ["diff", "--check"] else [0, 1]), result.stderr
        command_results.append(["git " + " ".join(command), result.returncode])
    for path in DEST:
        subprocess.run(["git", "-C", str(ROOT), "check-ignore", path], check=True, stdout=subprocess.DEVNULL)
    publication_rows = publish_outputs(output_plan)
    verify_preservation(snapshot, allowed_additions)
    final_status = git("status", "--short", "--branch")
    note = note.replace("{FINAL_STATUS}", final_status)
    note = note.replace("{CURRENT_CHECKS}", table(["Current command", "Observed exit code"], command_results))
    note = note.replace("{OUTPUT_PUBLICATION}", table(["Output destination", "Observed publication result", "Verified resulting SHA-256"], publication_rows))
    note = note.replace("{FINISHED_AT}", datetime.now(timezone.utc).isoformat(timespec="seconds"))
    note = note.replace("{MEMO_SHA256}", digest(DEST[0])).replace("{LEDGER_SHA256}", digest(DEST[1]))
    (ROOT / DEST[2]).write_text(note, encoding="utf-8", newline="\n")
    assert all(digest(p) == h for p, h in baseline.items())
    verify_preservation(snapshot, allowed_additions)
    assert git("diff", "--binary") == worktree_before and git("diff", "--cached", "--binary") == index_before
    assert git("rev-parse", "HEAD") == head and script_observation() == script
    assert all((ROOT / p).read_bytes() == item["content"] for p, item in output_plan.items()), "Final output bytes differ from assembly"
    assert all((ROOT / p).stat().st_size > 1000 for p in DEST)
    print(f"PASS: {len(ledger)} evidence rows; {len(output_plan) - len(allowed_additions)} existing outputs preserved; {len(allowed_additions)} missing outputs generated; {len(snapshot)} execution-start protected files unchanged; {len(baseline)} selected baseline hashes match; Git/index unchanged.")
    print("\n".join(DEST))
    print(final_status)


if __name__ == "__main__":
    main()
