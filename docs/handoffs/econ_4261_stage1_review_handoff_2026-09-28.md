# ECON 4261 / ICPSR 04283 — Stage 1 Review Handoff

**Date:** 2026-09-28
**Project:** ECON 4261 paper revision / ICPSR Study 04283
**Current phase:** Mandatory human review after the first Stage 1 implementation tranche
**Working branch:** `codex/restructure-project-layout`

---

## 1. Purpose of this handoff

This document summarizes the current state of the ECON 4261 reconstruction project after:

1. repository/documentation preparation;
2. Codex implementation of the first approved Stage 1 tranche;
3. review of the Stage 1 variable crosswalk, unresolved-issues record, and empirical validation output;
4. targeted NotebookLM checks for documentary ambiguities;
5. independent source-level checks of several NotebookLM claims.

The project is still intentionally **before cleaned-variable construction, panel construction, Stage 2 diagnostics, and regressions**.

The immediate next task should be a **small correction / human-review tranche**, not `03_construct_verified_wide.R` yet.

---

## 2. Overall research objective

The project is a substantial reconstruction of the original ECON 4261 empirical paper using:

> **ICPSR Study 4283 — National Center for Early Development and Learning Multistate Study of Pre-Kindergarten, 2001–2003**

The revised workflow is documentation-first:

```text
Raw ICPSR files
→ verified variables
→ clean four-wave child panel
→ identification / data audit
→ define common samples
→ choose inference strategy
→ estimate models
→ revise paper
```

The intended structural child panel has four periods:

```text
PF = Fall Pre-K
PS = Spring Pre-K
KF = Fall Kindergarten
KS = Spring Kindergarten
```

The key reconstruction principle remains:

> Missing outcomes stay missing on otherwise valid child-period rows.

A universal complete-case sample must **not** be imposed during panel construction.

The main child file contains 1,015 children, so the structural long panel target is:

```text
1,015 children × 4 periods = 4,060 child-period rows
```

---

## 3. Repository and data structure

Repository root:

```text
C:\Users\mvbas\OneDrive\Desktop\Econometrics\Project\ICPSR_04283
```

Working branch:

```text
codex/restructure-project-layout
```

Public-use datasets:

```text
DS0001 — Main Child Level Public-Use Version
DS0002 — Kindergarten Classroom Level Public-Use Version
DS0003 — Pre-K Classroom Level Public-Use Version
```

Raw R objects and verified dimensions:

```text
DS0001 → da04283.0001 → 1,015 × 1,210
DS0002 → da04283.0002 →   794 ×   169
DS0003 → da04283.0003 →   245 ×   261
```

The repository contains the principal public-use documentation under:

```text
docs/icpsr/
```

including:

- dataset-specific codebooks;
- Stata dictionaries;
- Stata setup files;
- DS0001 questionnaire;
- user guide;
- combined questionnaire;
- manifest;
- study/supporting documentation.

Raw research-data exports are excluded from Git.

---

## 4. Documentation hierarchy and NotebookLM role

The governing evidence hierarchy is:

```text
release-specific codebook / setup / derivation syntax
→ release questionnaire/documentation
→ general user/study documentation
→ empirical distributions only as validation
```

NotebookLM is **not** the final authority.

Its intended role is:

```text
NotebookLM
→ locate likely definitions / relevant passages
→ inspect original ICPSR documentation
→ verify the claim
→ implement only after human approval
```

This distinction became important during review because NotebookLM made several confident but incomplete dataset-attribution claims.

---

## 5. What Codex implemented in the first Stage 1 tranche

Codex completed only the authorized verification tranche and then stopped.

### Tracked implementation/specification files

```text
.Rprofile
renv.lock
renv/activate.R
renv/settings.json
renv/.gitignore

code/revision/00_source_environment_gate.R
code/revision/01_import_inventory.R
code/revision/02_validate_crosswalk.R

docs/stage1_variable_crosswalk.csv
docs/stage1_unresolved_issues.md
```

### Generated and ignored outputs

```text
output/verification/source_file_checks.csv
output/verification/environment_summary.txt

output/tables/source_object_inventory.csv
output/tables/source_variable_inventory.csv
output/tables/crosswalk_validation.csv
```

### Codex commit

```text
c8d59cb Implement Stage 1 source and crosswalk audit
```

Push succeeded to:

```text
origin/codex/restructure-project-layout
```

Final reported status was clean and synchronized with the remote.

---

## 6. What Codex explicitly did NOT do

Codex respected the hard stop.

It did **not**:

- recode raw variables;
- rescale teacher beliefs;
- implement `T_IDEAP / 16`;
- convert Applied Problems `-7`;
- carry fall teacher beliefs into spring;
- create a cleaned wide dataset;
- create the four-period long panel;
- link DS0001 to DS0002/DS0003;
- impose complete-case restrictions;
- finalize controls;
- finalize samples;
- run Stage 2 diagnostics;
- run regressions;
- choose preferred specifications;
- choose clustering/inference rules.

No new file was created under:

```text
Data/processed/
```

---

## 7. Stage 1 crosswalk status

The current crosswalk contains:

```text
66 rows
25 columns
```

Dataset distribution:

```text
DS0001: 62 rows
DS0002:  1 row
DS0003:  3 rows
```

Documentation status:

```text
verified:   33
partial:    30
conflict:    2
unresolved:  1
```

Transformation status:

```text
none:                    47
proposed_not_approved:   10
blocked:                  9
approved:                 0
```

Human review status:

```text
pending: 66
```

Empirical validation:

```text
pass:           33
review_needed:  33
```

All 66 raw variables exist in the dataset listed in the crosswalk.

The tracked crosswalk intentionally separates:

```text
documentary specification
```

from:

```text
empirical properties of the released R files
```

Empirical patterns are not documentary authorization.

---

## 8. Main empirical findings already established

### Teacher-belief variables

```text
T_IDEAP
T_IDEAK
```

Observed released values in DS0001:

```text
T_IDEAP: 17–64
T_IDEAK: 1.13–4.06
```

Both are tied to the 16-item Modernity Scale, but the released scales differ.

### PPVT

English PPVT standard-score variables:

```text
PPVTEPF
PPVTEPS
PPVTEKF
PPVTEKS
```

Observed nonmissing counts:

```text
PF: 805
PS: 855
KF: 811
KS: 838
```

### Applied Problems

English WJ-III Applied Problems standard-score variables:

```text
WJ10_SSEPF
WJ10_SSEPS
WJ10_SSEKF
WJ10_SSEKS
```

Eight surviving `-7` values remain in the released R file:

```text
7 in Fall Pre-K
1 in Spring Pre-K
```

These must remain untouched in raw columns until an approved cleaned-score rule is implemented.

### Sound Awareness

```text
WJ21AEPF
WJ21AEPS
WJ21AEKF
WJ21AEKS
```

Documented as English Sound Awareness / Rhyming raw scores.

Documented maximum:

```text
17
```

---

## 9. Original unresolved-issues list

`docs/stage1_unresolved_issues.md` currently contains nine formal issues:

```text
Q01  Released construction of T_IDEAP and T_IDEAK
Q02  Meaning of ASMSTATPS code 8 = DR
Q03  Theoretical valid-score bounds for PPVT and Applied Problems
Q04  Missing-reason provenance collapsed in the .rda
Q05  Linkage of child and classroom-level datasets
Q06  Scope and usability of LEAD_1
Q07  Interpretation of SITE_* fields for nesting
Q08  Relationship between T_CHNGCP and T_CHNG
Q09  English/Spanish assessment mapping and comparability
```

The review has now made substantive progress on Q01, Q08, and Q09.

---

# 10. Human review completed so far

## Q01 — `T_IDEAP` / `T_IDEAK`

### What NotebookLM found

NotebookLM located documentation showing that:

- both measures concern teacher child-rearing beliefs / the Modernity Scale;
- the scale uses 16 Likert items;
- higher scores are described in the user guide as more progressive;
- the general guide says the final score is an item mean;
- the released Pre-K and Kindergarten variables nevertheless appear on different scales;
- no uploaded source explicitly authorizes dividing `T_IDEAP` by 16.

### Source-level correction discovered during review

NotebookLM initially claimed:

> `T_IDEAK` is a DS0002 variable, not a DS0001 variable.

This is false as stated.

`T_IDEAK` appears in **both**:

```text
DS0001 codebook — page 788, location 3469–3471
DS0002 codebook — page 57, location 254–256
```

The Stage 1 child-level crosswalk correctly uses the DS0001 version.

Therefore, a key lesson for later work is:

> A variable can appear in multiple released datasets. Do not infer dataset exclusivity from one codebook hit.

### Human-review decision for Q01

Record the substantive decision as:

> **Human reviewed — documentary conflict confirmed; harmonization remains blocked.**

Specifically:

- the user guide describes a 16-item mean score;
- released DS0001 `T_IDEAP` is sum-like;
- released DS0001 `T_IDEAK` is mean-like;
- no reviewed release-specific source explicitly authorizes `T_IDEAP / 16`;
- `T_IDEAP / 16` is therefore **not authorized**;
- no generic harmonized teacher-belief column should yet be constructed;
- cross-grade teacher-belief change remains blocked until release-specific derivation evidence is found.

The substantive mystery remains unresolved, but the implementation rule is resolved:

```text
do not harmonize by assumption
```

### Timing distinction also remains mandatory

`T_IDEAP` is a Fall Pre-K measure.

`T_IDEAK` is a Fall Kindergarten measure.

Therefore:

```text
PF → observed T_IDEAP
KF → observed T_IDEAK
```

Putting either value on a spring row would be a carry-forward / grade-assignment assumption, not a contemporaneous spring measurement.

---

## Q08 — `T_CHNGCP` vs `T_CHNG`

### What NotebookLM initially claimed

NotebookLM framed the variables as:

```text
T_CHNGCP → DS0001 child-level
T_CHNG   → DS0003 classroom-level
```

and concluded they were distinct measures from different datasets.

### Source-level correction discovered during review

That framing is incomplete.

`T_CHNG` appears in **both DS0001 and DS0003**.

The relevant DS0001 comparison is:

```text
T_CHNGCP:
0 No change       972
1 Teacher change   38
2 Classroom change  5

T_CHNG:
0 No change       977
1 Teacher change   38
2 Classroom change  0
```

This is an important pattern:

- both identify 38 teacher changes;
- `T_CHNGCP` additionally identifies 5 classroom changes;
- `T_CHNG` identifies zero classroom changes in DS0001.

DS0003 also contains `T_CHNG` at the classroom level with its own distribution.

### What the documentation supports

`T_CHNGCP` is explicitly labeled as:

```text
Pre-K Fall-to-Spring change indicator based on child-level data
```

`T_CHNG` is labeled as a Pre-K teacher-questionnaire change indicator.

Both use nominal categories:

```text
0 = no change
1 = teacher change
2 = classroom change
```

However, the available documentation does **not** explain the exact derivation/reconciliation logic behind the difference between them.

### Important caution about code 2

A classroom change (`2`) does **not automatically prove a teacher change**.

Safe interpretation:

```text
0 → documented no teacher/classroom change
1 → documented teacher change
2 → documented classroom change; teacher continuity not established from this variable alone
```

### Human-review decision for Q08

Record:

> **Human reviewed — relationship partially clarified; reconciliation remains unresolved.**

Implementation rule:

- keep both variables distinct;
- do not create a preferred Pre-K change flag;
- do not reconcile them by assumption;
- do not infer teacher change from a classroom-change code unless separately documented.

A reasonable summary classification is:

```text
Documented as related but distinct,
with exact reconciliation logic still undocumented.
```

---

## Q09 — English/Spanish assessment mapping

### What NotebookLM established

The English battery includes:

```text
PPVT:
PPVTEPF
PPVTEPS
PPVTEKF
PPVTEKS
```

English WJ-III variables include the existing Applied Problems and Sound Awareness fields.

The Spanish battery includes:

```text
TVIP
Woodcock-Muñoz counterparts
```

The user guide states that, beginning in Kindergarten, Spanish-battery children were also given an English PPVT and that those PPVT scores were stored separately from English-battery PPVT scores.

### Source-level issue that remains unresolved

The available DS0001 codebook clearly contains the normal Kindergarten English PPVT variables:

```text
PPVTEKF
PPVTEKS
```

but the separate Kindergarten English PPVT field described for Spanish-battery children has **not been identified** in the currently reviewed public-release documentation.

The available codebook search found the ordinary English PPVT variables but no separately labeled Spanish-battery English PPVT field.

### Correction to NotebookLM's assessment-status summary

NotebookLM incorrectly said code `4` had zero observations across all waves.

In fact:

```text
ASMSTATPF (Fall Pre-K):
4 = Non-English, Spanish-Speaking Child Failed Pre-LAS
n = 6
```

Code 4 is zero in the later waves checked.

### Wording correction

Do **not** state:

> The documentation explicitly prohibits combining the batteries.

Safer and better-supported wording:

> The documentation distinguishes the English and Spanish batteries and provides no documented conversion, equating, or harmonization rule authorizing their combination.

### Human-review decision for Q09

Record:

> **Human reviewed — conservative implementation rule confirmed; exact Kindergarten Spanish-battery English-PPVT mapping remains unresolved.**

Implementation rule:

- keep English and Spanish outcomes separate;
- do not pool PPVT with TVIP;
- do not pool WJ-III with Woodcock-Muñoz;
- do not impute one from the other;
- do not infer that `PPVTEKF`/`PPVTEKS` contain the separate Spanish-battery English PPVT scores;
- preserve the mapping question as unresolved.

The unresolved mapping does **not** need to block ordinary English-outcome reconstruction.

---

# 11. Important correction needed: `LEAD_1`

A factual inconsistency was discovered in the prior prose summary.

Earlier prose stated that `LEAD_1` had:

> only three nonmissing values

But the generated `crosswalk_validation.csv` reports:

```text
dataset: DS0003
nonmissing N: 244
total rows: 245
observed min: 50
observed max: 58
```

Therefore the phrase “three nonmissing values” is incorrect.

A prior exploratory summary elsewhere referred instead to a **three-value empirical distribution**, but the current generated validation table does not report the number of distinct values.

Therefore, before relying on any distinct-count claim, Codex should explicitly compute:

```text
n_distinct(LEAD_1)
frequency table for LEAD_1
```

The documentary conclusion remains unchanged:

```text
LEAD_1 is labeled “Teacher ID”
but documentation does not establish scope or uniqueness.
```

So it must **not** yet be used as a unique teacher key.

---

# 12. Identifier checks still needed

Before Stage 1 moves forward, run an explicit small identifier audit for:

```text
STUDY_ID in DS0001
CASEID in DS0002
CASEID in DS0003
LEAD_1 in DS0003
```

Report:

```text
dataset
variable
N rows
N nonmissing
N distinct
duplicate count
min
max
frequency summary where useful
```

This is still a Stage 1 verification task, not Stage 2 analysis.

Important distinction:

- empirical uniqueness can be checked;
- documentary meaning / cross-file linkage cannot be inferred from uniqueness.

In particular:

```text
CASEID
```

must not be used to merge DS0001 with DS0002 or DS0003 unless a documented linkage rule is found.

---

# 13. Other unresolved issues and safe current treatment

## Q02 — `ASMSTATPS = 8 "DR"`

Still unresolved.

Safe rule:

```text
retain DR literally as its own category
```

Do not infer that it means absent, refusal, language status, etc.

---

## Q03 — theoretical PPVT / Applied Problems bounds

Still unresolved.

Safe rule:

```text
do not impose undocumented theoretical valid-score bounds
```

Empirical min/max values are not documentary authorization.

---

## Q04 — collapsed missing-reason codes

The released R objects have already collapsed many original special values such as:

```text
-99
-6
-5
```

to `NA`.

Safe rule:

```text
do not reconstruct missing-reason categories from NA
```

Only surviving explicit special values may be flagged directly.

---

## Q05 — DS0001 ↔ DS0002/DS0003 linkage

No documented cross-dataset key has been found.

Safe rule:

```text
no merge
```

Numeric resemblance or uniqueness is not enough.

---

## Q06 — `LEAD_1`

See correction above.

Safe rule:

```text
retain as released
do not treat as unique teacher ID
```

---

## Q07 — `SITE_*`

Documentation supports interpreting these as site / teacher-rating-site identifiers.

Safe rule:

```text
site means site
```

Do not relabel them as:

- teacher IDs;
- classroom IDs;
- school IDs;
- state IDs.

Any clustering/nesting interpretation beyond documented site identity remains blocked.

---

# 14. What human review should mean in this project

The substantive decision should be made by the user / research workflow.

Codex should make the **mechanical edit** after the decision is explicit.

Recommended pattern:

```text
Human reviews evidence
→ human states decision
→ Codex updates review_status / review_notes
→ Codex verifies the CSV and diffs
```

Do not ask Codex to independently decide what “human reviewed” should mean.

For reviewed rows, the transformation/documentation status should remain independent.

Example:

```text
review_status = reviewed
documentation_status = conflict
transformation_status = blocked
```

is perfectly valid.

Human review does not mean the ambiguity disappeared.

---

# 15. Human-review decisions ready to be recorded

At minimum, the following decisions are now ready to be entered into the tracked Stage 1 crosswalk / unresolved-issues record.

## Q01 rows

Relevant:

```text
T_IDEAP
T_IDEAK
```

Decision:

```text
Human reviewed.
Documentary scale conflict confirmed.
T_IDEAP / 16 not authorized.
Cross-wave harmonization remains blocked.
Spring carry-forward not authorized.
```

---

## Q08 rows

Relevant:

```text
T_CHNGCP
T_CHNG
```

Decision:

```text
Human reviewed.
Related but distinct indicators.
Exact derivation/reconciliation remains unresolved.
Keep separate.
No preferred/reconciled Pre-K change flag authorized.
```

Also update documentary notes to reflect that:

```text
T_CHNG exists in DS0001 and DS0003.
```

---

## Q09 rows

Relevant English / Spanish assessment and outcome variables.

Decision:

```text
Human reviewed.
Keep English and Spanish batteries separate.
No cross-language pooling/equating/imputation authorized.
Kindergarten Spanish-battery English-PPVT variable mapping remains unresolved.
```

Also correct any inaccurate note suggesting code 4 is absent in all waves.

---

# 16. Dataset-duplication facts that must be preserved

Two important source-structure corrections were discovered during human review:

## `T_IDEAK`

Appears in:

```text
DS0001
DS0002
```

Therefore:

```text
Do not say “T_IDEAK is a DS0002 variable, not DS0001.”
```

For the child panel, DS0001 remains the relevant copy.

---

## `T_CHNG`

Appears in:

```text
DS0001
DS0003
```

Therefore:

```text
Do not frame T_CHNG only as a DS0003 classroom-level variable.
```

The DS0001 comparison with `T_CHNGCP` is directly relevant to the child-level reconstruction.

---

# 17. Why NotebookLM should be paused for now

NotebookLM successfully located useful documentation for Q01, Q08, and Q09.

However, repeated source-level checks found that NotebookLM sometimes:

- treats a variable found in one dataset as exclusive to that dataset;
- misses duplicate appearances in other released datasets;
- overstates a conservative documentation conclusion as an explicit prohibition;
- makes broad frequency claims that need checking against the codebook.

Therefore, current best practice is:

```text
NotebookLM for targeted navigation
→ verify against canonical docs
→ human decision
```

There is no strong need for another NotebookLM query before the next Codex correction tranche.

---

# 18. Immediate next Codex task

Do **not** authorize `03_construct_verified_wide.R` yet.

The next Codex task should be a **small correction / review-recording tranche**.

It should:

1. read `AGENTS.md`;
2. verify repository root / branch / clean state;
3. inspect current Stage 1 crosswalk, unresolved-issues file, and validation output;
4. record the human-review decisions for Q01, Q08, and Q09;
5. preserve all `blocked` and `proposed_not_approved` transformation statuses unless explicitly instructed otherwise;
6. correct source notes to reflect:
   - `T_IDEAK` occurs in DS0001 and DS0002;
   - `T_CHNG` occurs in DS0001 and DS0003;
7. correct the inaccurate `LEAD_1` prose;
8. compute explicit identifier distinct-count diagnostics for:
   - `STUDY_ID` DS0001;
   - `CASEID` DS0002;
   - `CASEID` DS0003;
   - `LEAD_1` DS0003;
9. update the relevant Stage 1 documentation / generated verification output as needed;
10. run the existing validation scripts;
11. run Git diff checks;
12. commit and push only this small correction tranche;
13. STOP again.

It should **not** yet:

- create cleaned variables;
- build the panel;
- merge datasets;
- harmonize teacher beliefs;
- choose an estimation sample;
- run Stage 2 diagnostics;
- run regressions.

---

# 19. Stage architecture after the next correction boundary

The planned architecture remains:

```text
00_source_environment_gate.R
01_import_inventory.R
02_validate_crosswalk.R

→ MANDATORY USER REVIEW / CORRECTION

03_construct_verified_wide.R
04_build_structural_panel.R
05_validate_panel.R
06_audit_coverage.R
07_audit_teacher_beliefs.R
08_audit_identifiers.R
09_audit_attrition.R
10_render_stage_1_2_audit.R
stage_1_2_audit.qmd
```

Only after the correction tranche is reviewed should `03_construct_verified_wide.R` be considered.

Even then, unresolved issues do not all need to be “solved” before Stage 1 proceeds.

The correct rule is:

> An unresolved issue blocks only the affected transformation or interpretation, not unrelated safe construction.

For example:

```text
Q01 unresolved scoring
→ blocks harmonized teacher-belief construction
→ does not block preserving raw T_IDEAP and T_IDEAK

Q09 unresolved Spanish-battery English-PPVT mapping
→ blocks combined language outcomes
→ does not block preserving ordinary English PPVT fields
```

---

# 20. Key project principles to preserve

1. **Documentation first.**
2. **Never overwrite raw released variables.**
3. **Empirical plausibility is not documentary authorization.**
4. **Do not infer missing-value meanings from NA.**
5. **Do not infer cross-dataset linkage from numeric patterns.**
6. **Do not infer identifier scope from a variable label alone.**
7. **Do not silently carry Fall teacher measures into Spring.**
8. **Keep English and Spanish batteries separate absent explicit harmonization evidence.**
9. **Human review can confirm that an issue remains blocked.**
10. **Only the affected rule should stop when documentation is unresolved.**
11. **NotebookLM is a navigator, not the final authority.**
12. **Codex should implement explicit human decisions, not substitute for them.**

---

# 21. Files to review in the next chat

The three key Stage 1 review files remain:

```text
docs/stage1_variable_crosswalk.csv
docs/stage1_unresolved_issues.md
output/tables/crosswalk_validation.csv
```

If validating the implementation logic itself, also inspect:

```text
code/revision/02_validate_crosswalk.R
```

If inventory behavior becomes relevant:

```text
code/revision/01_import_inventory.R
output/tables/source_variable_inventory.csv
```

---

# 22. Concise current status

The project is currently here:

```text
Repository/documentation preparation: COMPLETE
First Stage 1 verification tranche: COMPLETE
Crosswalk generated: COMPLETE
Empirical validation generated: COMPLETE
Mandatory human review: IN PROGRESS / PARTIALLY COMPLETE
Q01 reviewed: YES
Q08 reviewed: YES
Q09 reviewed: YES
LEAD_1 correction: PENDING CODEX FIX
Identifier distinct-count audit: PENDING
Human review statuses written into crosswalk: NOT YET
03_construct_verified_wide.R: NOT YET AUTHORIZED
Panel construction: NOT STARTED
Stage 2 diagnostics: NOT STARTED
Regressions: NOT STARTED
```

The next chat should begin by preparing the **small Codex correction / human-review implementation prompt** described above.
