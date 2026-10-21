# Stage 13: bounded documentary recovery; no estimation or score reconstruction.
# Fresh-session usage from the project root (Python with pypdf is required):
# Rscript --vanilla code/revision/13_recover_measurement_dependence_evidence.R --python PYTHON
# Optional --baseline JSON verifies the externally frozen pre-implementation inventory.
# Network observations below are dated receipts, never replayed by this script.
project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
git <- function(args) {
  z <- system2("git", c("-c", shQuote(paste0("safe.directory=", project_start)), args), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("Git command failed: ", paste(args, collapse = " "))
  z
}
stopifnot(identical(normalizePath(git(c("rev-parse", "--show-toplevel"))[1], winslash = "/"), project_start),
  basename(project_start) == "ICPSR_04283")
head_before <- git(c("rev-parse", "HEAD")); branch_before <- git(c("branch", "--show-current"))
status_before <- git(c("status", "--short", "--branch")); index_before <- git(c("ls-files", "--stage"))
stopifnot(head_before == "a17d50c36066aa301cd1243cdb464b8bf26643bd",
  branch_before == "codex/restructure-project-layout", length(git(c("diff", "--cached", "--name-only"))) == 0L)
Sys.setenv(RENV_PATHS_ROOT = file.path(project_start, "renv", "local"),
  RENV_CONFIG_SANDBOX_ENABLED = "FALSE", RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
source(file.path(project_start, "renv", "activate.R"))
suppressPackageStartupMessages(library(here))
stopifnot(identical(normalizePath(here::here(), winslash = "/"), project_start))
options(stringsAsFactors = FALSE, warn = 2)
args <- commandArgs(TRUE)
arg <- function(key, default = "") {
  i <- which(args == key)
  if (!length(i)) return(default)
  if (length(i) != 1L || i == length(args)) stop("Invalid argument: ", key)
  args[i + 1L]
}
python <- arg("--python", Sys.getenv("STAGE13_PYTHON", Sys.which("python")))
stopifnot(nzchar(python), file.exists(python))
py <- function(code, argv = character()) {
  z <- system2(python, c("-X", "utf8", "-c", shQuote(code), shQuote(argv)), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("Python helper failed:\n", paste(z, collapse = "\n"))
  z
}
dest <- c("output/tables/stage13_evidence_ledger.csv", "output/tables/stage13_dependence_assessment.csv",
  "output/reports/stage13_evidence_recovery.md", "output/verification/stage13_checks.csv",
  "output/verification/stage13_verification_unresolved.md")
script_path <- "code/revision/13_recover_measurement_dependence_evidence.R"
report_source <- "docs/icpsr/NCEDL_PreK-in-Eleven-States_Working-Paper_2005.pdf"
report_url <- paste0("https://fpg.unc.edu/sites/fpg.unc.edu/files/resources/reports-and-policy-briefs/",
  basename(report_source))
stopifnot(!any(file.exists(here::here(dest))), all(dir.exists(here::here(dirname(dest)))))
inventory <- function() {
  p <- list.files(project_start, recursive = TRUE, all.files = TRUE, include.dirs = FALSE)
  sort(setdiff(p[!grepl("^\\.git/", p)], dest))
}
protected <- inventory(); protected_md5 <- tools::md5sum(here::here(protected))
sha <- function(p) unname(py("import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())", here::here(p)))
read_csv <- function(p) read.csv(here::here(p), check.names = FALSE, fileEncoding = "UTF-8")
checks <- list()
check <- function(id, ok, observed = "", expected = "TRUE", detail = "") {
  stopifnot(!id %in% vapply(checks, `[[`, "", "check_id"))
  checks[[length(checks) + 1L]] <<- data.frame(check_id = id, status = if (isTRUE(ok)) "pass" else "fail",
    observed = as.character(observed), expected = as.character(expected), detail = detail)
  if (!isTRUE(ok)) stop("Computational verification failed: ", id, "; ", detail)
}
baseline_file <- arg("--baseline")
baseline_receipt <- "No external pre-implementation baseline supplied; runtime preservation only."
if (nzchar(baseline_file)) {
  baseline_result <- py(paste0("import json,sys,pathlib,hashlib; ",
    "b=json.load(open(sys.argv[1],encoding='utf-8-sig')); r=pathlib.Path.cwd(); ",
    "assert r.resolve()==pathlib.Path(b['root']).resolve(); ",
    "assert all((r/f['path']).is_file() and hashlib.sha256((r/f['path']).read_bytes()).hexdigest()==f['sha256'] for f in b['files']); ",
    "assert len({f['path'] for f in b['files']})==len(b['files']); ",
    "print(len(b['files'])); print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())"), baseline_file)
  check("external_baseline_hashes_entry", length(baseline_result) == 2L, baseline_result[1])
  baseline_receipt <- paste("Supplied pre-implementation inventory:", baseline_result[1], "SHA-256 matches; inventory SHA-256", baseline_result[2],
    ". The 127 non-renv files were frozen before acquisition; 238 renv files were added to that inventory before implementation, after read-only acquisition. Git internals excluded; HEAD/index separately checked.")
}
# INPUT_PINS: generated from the frozen inventory; constants, not hashes inferred at runtime.
input_pins <- c(
  "code/revision/06_investigate_belief_scores.R" = "e6e791719d11b47d317213e98c0e30183fed64eebf6a07092cde3fbb12472c74",
  "code/revision/09_investigate_belief_timing_correspondence.R" = "974f2008ee52d3386a3b487f8ad858ce4c2ef93ee071e4478e22a5bee59f93ac",
  "code/revision/10_research_design_feasibility.py" = "5e3c0e7294ac53cf05a5a9d81b074638aa67d4be7d5f6a5839c00a1b86e83f17",
  "code/revision/11_specify_fall_analysis.R" = "7fb67caadf0739549027446a9da9be865a4793ecbe96be4941b7c87d75456df6",
  "code/revision/12_estimate_fall_associations.R" = "e163001bd9aef7b34a44281fb83368823f4f3aaa53f9f73f1cefdd96675f3f22",
  "output/reports/stage09_feasibility.md" = "164a62365cea84bf8280748d565d204e5d345703426b9284c61dca3d60b5c870",
  "output/reports/stage10_research_design_feasibility.md" = "f36d3ecdc03f5f409ae38d63b51d17f12bd7ba4fbe99f1e3a781b164e340a92a",
  "output/reports/stage11_analysis_specification.md" = "6e0ea47933952cf4af5d693161f6d368a4f2e3ec97a9a4331b7c5b48d410c43f",
  "output/reports/stage12_fall_associations.md" = "ec5f39e80d51eeb053db5a1c8de2f38b44626a4757888cfcee9bbb408f3266b0",
  "output/tables/stage09_source_evidence.csv" = "179a601c33d71c939557ba8381e3fb0dc8072cf3b2592dd027dd21e053e18b6d",
  "output/tables/stage10_claim_verification.csv" = "8ae848118cecf8adf567013f908713d68d515c1d1925fa58f84e5313dd01a3d7",
  "output/tables/stage11_grouping_assessment.csv" = "6683c72a2f7875f6e68df121eee8373f7ee1db185bb3535f009f0d3f22474c5c",
  "output/tables/stage11_sample_support.csv" = "cd81d3d113aaefe1de7d0713ce26b1ea5014258f85a50e05b4006bd670172026",
  "output/tables/stage12_fall_belief_coefficients.csv" = "445576ab6f472ca66f5f2af975372b48978b4493f281ed7bad8383c3ed1e9b96",
  "output/verification/belief_score_review.md" = "15ad7b9aaec7699daf1cbd2e5d9bc62eb16baf15b20b3c0700e3893f3fe5d2b5",
  "output/verification/stage10_verification_unresolved.md" = "c1fcef948dad8a651512067089aca8468760fab27c5a86e5f024d2315968cb28",
  "output/verification/stage11_checks.csv" = "426764307a07669848fe9c0d29996d4d868904a703a7df8ff687201c7d78eb83",
  "output/verification/stage11_verification_unresolved.md" = "8f0c7ecab9e22149debff09f6c8f3e94ada104630ccf5d33181e31dab4754a8a",
  "output/verification/stage12_checks.csv" = "9263a8655b80b26a27b241580989cf3e4d6b46c0137ec36a0adce2ae57734af6",
  "output/verification/stage12_verification_unresolved.md" = "207979424556138174d62519905214dafe03866fd70645ec46b67c97f89e0ec9"
)
check("input_pins_present", length(input_pins) >= 20L, length(input_pins), ">=20")
for (p in names(input_pins)) check(paste0("accepted_sha_", match(p, names(input_pins))), identical(sha(p), input_pins[[p]]), detail = p)
for (s in c(11L, 12L)) {
  old <- read_csv(paste0("output/verification/stage", s, "_checks.csv"))
  check(paste0("historical_checks_", s), nrow(old) == c(`11` = 173L, `12` = 508L)[as.character(s)] &&
    !anyDuplicated(old$check_id) && all(old$status == "pass"), nrow(old), detail = "Inspected recorded ledger; upstream stage not rerun")
}
stage11_note <- readLines(here::here("output/verification/stage11_verification_unresolved.md"), warn = FALSE)
upstream <- c("Data/processed/verified_child_wide.rds", "Data/processed/outcome_cleaning_panel.rds",
  "output/tables/verified_wide_provenance.csv", "output/tables/structural_panel_provenance.csv",
  "output/tables/stage08_characteristic_inventory.csv", "output/tables/stage08_belief_outcome_support.csv",
  "output/tables/outcome_cleaning_rules.csv", "docs/icpsr/DS0001/04283-0001-Setup.do", "docs/icpsr/DS0001/04283-0001-Setup.dct")
for (j in seq_along(upstream)) {
  line <- stage11_note[startsWith(stage11_note, paste0("| ", upstream[j], " | "))]
  expected <- if (length(line) == 1L) trimws(strsplit(line, "|", fixed = TRUE)[[1]][3]) else "absent"
  check(paste0("historical_upstream_md5_", j), identical(unname(tools::md5sum(here::here(upstream[j]))), expected), detail = upstream[j])
}
manifest_path <- "docs/icpsr/04283-manifest.txt"
manifest <- readLines(here::here(manifest_path), warn = FALSE)
pdf_pages <- function(p, pages) {
  py(paste0("from pypdf import PdfReader; import sys; r=PdfReader(sys.argv[1]); ",
    "print('PAGES='+str(len(r.pages))); ",
    "[(print('PHYSICAL_PAGE='+str(i)), print(r.pages[i-1].extract_text().encode('ascii','replace').decode())) for i in map(int,sys.argv[2].split(','))]"),
    c(here::here(p), paste(pages, collapse = ",")))
}
guide <- "docs/icpsr/04283-User_guide.pdf"; child_book <- "docs/icpsr/DS0001/04283-0001-Codebook.pdf"
form <- "docs/icpsr/DS0001/04283-0001-Questionnaire.pdf"
# Revisit the named physical locators; do not repeat numerical scoring investigations.
sources <- list(
  guide = list(path = guide, pages = c(11:17, 40, 44), token = "non-traditional beliefs"),
  beliefs = list(path = child_book, pages = c(538:540, 788:790), token = "SCHAEFER TRAD CHILD-REARING VIEWS"),
  context = list(path = child_book, pages = c(315,317,319,964,1116,1118,1119,1122), token = "SITE_TRKF"),
  forms = list(path = form, pages = c(22,33), token = "Ideas About Children"),
  k_keys = list(path = "docs/icpsr/DS0002/04283-0002-Codebook.pdf", pages = 6, token = "CASEID"),
  p_keys = list(path = "docs/icpsr/DS0003/04283-0003-Codebook.pdf", pages = c(6,159), token = "LEAD_1"),
  fpg = list(path = report_source, pages = 1:35, token = "Pre-Kindergarten in Eleven States"))
texts <- list()
for (k in names(sources)) {
  s <- sources[[k]]; z <- pdf_pages(s$path, s$pages); texts[[k]] <- paste(z, collapse = "\n")
  check(paste0("pdf_locator_", k), all(paste0("PHYSICAL_PAGE=", s$pages) %in% z) && grepl(s$token, texts[[k]], fixed = TRUE), detail = s$path)
  if (k != "fpg") {
    line <- manifest[grepl(basename(s$path), manifest, fixed = TRUE)]
    actual <- unname(tools::md5sum(here::here(s$path)))
    check(paste0("manifest_pdf_md5_", k), any(grepl(actual, line, fixed = TRUE)), actual, detail = "Mismatch would be authentication/version failure")
  }
}
check("fpg_identity", grepl("PAGES=35", texts$fpg, fixed = TRUE) && grepl("May 24, 2005", texts$fpg, fixed = TRUE) &&
  identical(sha(report_source), "7fd7633733afb72a947d2b745a812d6334d933f7ab57f590c47df2ac21bf579f"))
check("fpg_named_metadata_absence", !grepl("T_IDEA|SITE_PF|SITE_TRKF|CASEID|LEAD_1|Modernity", texts$fpg, ignore.case = TRUE),
  detail = "Bounded text search, not proof that no other authoritative source exists")
check("guide_discrepancy_retained", grepl("higher scores have more progressive beliefs", texts$guide, fixed = TRUE) &&
  grepl("non-traditional beliefs", texts$guide, fixed = TRUE))
# Generic conditional diagnostic helpers. No research records are loaded on this evidence endpoint.
group_summary <- function(g) {
  sizes <- table(g, useNA = "no")
  c(n = length(g), covered = sum(!is.na(g)), missing = sum(is.na(g)), groups = length(sizes),
    singletons = sum(sizes == 1L), largest_share = if (sum(sizes)) max(sizes)/sum(sizes) else NA_real_)
}
map_summary <- function(child_keys, map_keys, group) {
  if (length(map_keys) != length(group) || anyNA(map_keys) || anyDuplicated(map_keys)) stop("Ambiguous or missing mapping keys")
  i <- match(child_keys, map_keys)
  c(rows = length(i), unmatched = sum(is.na(i)), mapped_missing_group = sum(!is.na(i) & is.na(group[i])))
}
cross_summary <- function(a, b) {
  stopifnot(length(a) == length(b))
  ok <- !is.na(a) & !is.na(b); pairs <- unique(data.frame(a = a[ok], b = b[ok]))
  c(complete = sum(ok), missing_either = sum(!ok), a_multiple = sum(table(pairs$a) > 1L), b_multiple = sum(table(pairs$b) > 1L))
}
diagnostic_gate <- function(authenticated, operation) {
  if (!isTRUE(authenticated)) return("skipped_no_authenticated_scope_or_map")
  operation()
}
rejects <- function(expr) inherits(tryCatch({force(expr); NULL}, error = function(e) e), "error")
check("fixture_duplicate_mapping", rejects(map_summary(1:2, c(1,1), c("a","b"))))
check("fixture_unmatched_mapping", map_summary(1:3, 1:2, c("a","b"))[["unmatched"]] == 1L)
check("fixture_missing_mapping_key", rejects(map_summary(1:2, c(1,NA), c("a","b"))))
check("fixture_missing_mapped_group", map_summary(1:2, 1:2, c("a",NA))[["mapped_missing_group"]] == 1L)
check("fixture_missing_group", group_summary(c("a","a",NA))[["missing"]] == 1L)
all_missing <- group_summary(c(NA,NA))
check("fixture_all_missing_group", all_missing[["groups"]] == 0L && all_missing[["covered"]] == 0L && is.na(all_missing[["largest_share"]]))
cross <- cross_summary(c("a","a","b","b",NA), c("x","y","x","y","z"))
check("fixture_crossing", all(unname(cross) == c(4,1,2,2)))
check("fixture_absent_documentation_skip", identical(diagnostic_gate(FALSE, function() stop("Must not run")), "skipped_no_authenticated_scope_or_map"))
check("fixture_authenticated_gate", diagnostic_gate(TRUE, function() group_summary(c("a",NA)))[["covered"]] == 1L)
ledger <- list()
evidence <- function(id, category, fields, source, locator, finding, evidence_class = "documented_fact",
                     question = "", decision = "", direction = "not_applicable", construction = "not_applicable",
                     reproduction = "not_applicable", outcome = "local_source_inspected", disposition = "retained",
                     version = "ICPSR 04283 v4 local documentation", expected_md5 = "", actual_filename = "") {
  local <- nzchar(source) && file.exists(here::here(source))
  ledger[[length(ledger)+1L]] <<- data.frame(evidence_id = id, category = category, fields = fields,
    observation_date = "2026-10-18", source_identity = source, source_version = version, locator = locator,
    source_md5 = if (local) unname(tools::md5sum(here::here(source))) else "",
    source_sha256 = if (local) sha(source) else "", expected_md5 = expected_md5, actual_filename = actual_filename,
    access_outcome = outcome, finding = finding, evidence_class = evidence_class, direction_status = direction,
    construction_status = construction, numerical_reproduction_status = reproduction, unresolved_question = question,
    decision_affected = decision, disposition = disposition)
}
listing <- "https://www.icpsr.umich.edu/web/ICPSR/studies/4283/versions/V4"
docroute <- paste0(listing, "/datadocumentation?tenant=icpsr&archive=icpsr")
evidence("A00", "acquisition", "all six supplemental files", listing, "Browser: Data & Documentation; Download > Documentation Only",
  "Version V4, date 2017-07-17 visible. DS1 menu offered formats/data bundles and PDFs; study-wide Documentation Only redirected to ICPSR sign-in. No file-level download URL observed.",
  "acquisition_receipt", outcome = "listing_accessible_bundle_authentication_required", disposition = "stop_at_authentication_gate", version = "ICPSR04283.v4")
syntax_names <- paste0("04283-000", rep(1:3, each = 2), "-Supplemental_syntax.", rep(c("do","sas"), 3))
syntax_md5 <- c("1a4dce00159ddbe4352fb5ead4a58bdc", "c37da28115d9e8685b34acd74b1d4894",
  "ce83177cf5b02808aabb8a1b5a4452cd", "c10ec16fbd9b469d4c11e5054fc0f526",
  "e212d06c4175a4bc6905170e44c1eb8b", "641d999ea22c278fdb0d72bf78ebc4b7")
for (j in seq_along(syntax_names)) {
  line <- which(grepl(syntax_names[j], manifest, fixed = TRUE))
  check(paste0("manifest_syntax_", j), length(line) == 1L && grepl(syntax_md5[j], manifest[line], fixed = TRUE))
  target <- paste0("docs/icpsr/DS000", rep(1:3, each = 2)[j], "/", syntax_names[j])
  check(paste0("syntax_absence_", j), !file.exists(here::here(target)), detail = "No retrieved bytes; no static inspection or execution possible")
  evidence(paste0("A",j), "syntax_acquisition", syntax_names[j], docroute, paste0("Shared official documentation-only route; manifest line ", line),
    "One shared bundle request covered this file; stopped at sign-in. Not six independent HTTP requests. No bytes, filename or computed checksum received; contents unknown.",
    "acquisition_receipt", "Can v4 derivation syntax establish released scoring or identifier mapping?", "Directional interpretation/construction and dependence readiness",
    outcome = "not_acquired_authentication_required_shared_attempt", disposition = "stop_no_retry_no_bypass", expected_md5 = syntax_md5[j], version = "ICPSR04283.v4")
}
queries <- c('site.icpsr.umich.edu 4283 "Supplemental_syntax"',
  'site.fpg.unc.edu "Pre-Kindergarten in Eleven States" technical report',
  'site.icpsr.umich.edu "T_IDEAK" "SITE_TRKF"',
  'site.fpg.unc.edu NCEDL Modernity scoring kindergarten teacher beliefs classroom identifiers')
search_findings <- c("No usable official supplemental syntax link surfaced.",
  "Original-team preliminary report lead selected; identity checked against the actual PDF, not repeated bibliography URLs.",
  "No release-specific scoring or linkage resolution surfaced.",
  "Results included general/other-study Modernity material with differing directions; none authenticated these released variables. No third-party result adopted or additional document inspected.")
for (j in seq_along(queries)) evidence(paste0("S",j), "targeted_search", "measurement/dependence gaps", "Web search service", queries[j],
  search_findings[j], "search_receipt", question = "Release-specific scoring or identifier/linkage metadata?", decision = "Whether further documentary inspection is warranted",
  outcome = "search_completed", disposition = if (j == 2L) "inspect_FPG_report" else "no_resolving_authoritative_lead", version = "Search performed 2026-10-18; search ranking not evidence")
evidence("D1", "additional_document", "sampling and release metadata", report_source, "35 physical pages text searched; identity p.1; methods pp.4-5; limitations pp.31-32",
  "Early et al., May 24 2005, Preliminary Descriptive Report; not a release technical derivation manual. Describes selected-site classroom recruitment but supplies no named released scoring key or child-classroom map.",
  "documented_context", "Does selected-classroom sampling authenticate the attached released belief respondent or site-code scope?", "No new structural diagnostic warranted",
  outcome = "acquired_and_text_inspected", disposition = "stop_context_only", version = "NCEDL working paper 2005-05-24", actual_filename = basename(report_source))
evidence("D1_HTTP", "document_acquisition", "FPG report", report_url, "Python urllib normal GET; one necessary sandbox retry",
  "Initial sandbox request failed DNS (Errno 11001), no bytes written. Same URL approved outside sandbox returned HTTP 200, 379436 PDF bytes; exclusive creation in existing docs/icpsr directory. No research data requested.",
  "acquisition_receipt", outcome = "success_after_one_DNS_retry", disposition = "preserve_source", version = "Retrieved 2026-10-18", actual_filename = basename(report_source))
evidence("M_GUIDE", "measurement_context", "T_IDEAP;T_IDEAK", guide, "physical p.40; classroom summary p.44",
  "Guide describes 16 items, a mean with non-traditional items reversed, yet says higher scores are progressive. These statements conflict in direction; the Pre-K classroom summary also uses a different numerical scale from an unscaled item mean.",
  "documented_discrepancy", "Which key, aggregation, missing-item denominator, prorating, rounding and final transformation produced each released variable?",
  "Substantive interpretation of existing slopes", direction = "unresolved", construction = "incomplete", reproduction = "not_attempted_items_unavailable")
for (v in c("T_IDEAP","T_IDEAK")) evidence(paste0("M_",v), "measurement_endpoint", v, child_book,
  if (v == "T_IDEAP") "physical pp.538-540; guide p.40; form p.22; Stage06/09/10 accepted evidence" else "physical pp.788-790; guide p.40; form p.33; Stage06/09/10 accepted evidence",
  paste("Released label names traditional child-rearing views but does not establish higher-score direction. Forms document 16 agreement items with 1-5 anchors. No newly authenticated release-specific direction or complete construction rules.",
    "Stage06 found suitable same-object item/completion inputs unavailable; no new item inventory or score reconstruction performed."),
  "bounded_unresolved_endpoint", "Obtain explicit release-specific direction and a complete derivation key with dependencies; numerical validation requires separately authorized item-level inputs.",
  "Retain native numerical-score association wording", direction = "unresolved", construction = "incomplete", reproduction = "not_attempted_items_unavailable", disposition = "stop_unresolved")
# Reuse selected documentary rows, validating their local bytes and locators.
old9 <- read_csv("output/tables/stage09_source_evidence.csv")
keys <- c("ROLE_CONTEXT","SITE_MEANINGS","CLASSROOM_CASE_KEYS","PREK_CASE_KEY","LEAD_SCOPE")
for (key in keys) {
  r <- old9[old9$evidence_id == key, , drop = FALSE]
  check(paste0("inherited_source_",key), nrow(r) == 1L && identical(unname(tools::md5sum(here::here(r$source_path))), r$source_md5))
  evidence(paste0("B_",key), "inherited_documentation", key, r$source_path, r$source_locator, r$finding,
    "accepted_documented_context", "Global uniqueness, attachment and child correspondence beyond labels?", "Grouping authentication", disposition = "reuse_no_new_map")
}
dictionary <- readLines(here::here("docs/icpsr/DS0001/04283-0001-Setup.dct"), warn = FALSE)
candidate_fields <- c("SITE_PF","SITE_TRKF","SITE_PS","SITE_TRPS","SITE_TRKS","SITE_ECK","SNAPCLASSK","NUMCLSRMK")
for (v in candidate_fields) {
  loc <- grep(paste0("[[:space:]]", v, "[[:space:]]"), dictionary)
  check(paste0("dictionary_", v), length(loc) == 1L)
  evidence(paste0("I_",v), "dependence_candidate", v, "docs/icpsr/DS0001/04283-0001-Setup.dct", paste("line", loc),
    trimws(dictionary[loc]), "released_label_only",
    if (v %in% c("SNAPCLASSK","NUMCLSRMK")) "Counts describe multiplicity, not classroom identities or a join key." else "Uniqueness domain, child-to-setting correspondence, belief respondent containment and cross-period code comparability unresolved.",
    "No automatic equality, prefix decoding, Spring filling or grouping assignment", disposition = "skip_new_diagnostics_no_authenticated_scope")
}
grouping <- read_csv("output/tables/stage11_grouping_assessment.csv")
support <- read_csv("output/tables/stage11_sample_support.csv")
coef <- read_csv("output/tables/stage12_fall_belief_coefficients.csv")
cells <- c("PF_PPVT","KF_PPVT","PF_Applied_Problems","KF_Applied_Problems")
ns <- c(730L,700L,717L,713L); names(ns) <- cells
for (cell in cells) {
  r <- coef[coef$cell == cell, ]
  check(paste0("accepted_cell_n_",cell), nrow(r) == 2L && all(r$n == ns[[cell]]) && setequal(r$model,c("M0","M1")))
}
metric <- function(cell, field, category) {
  r <- grouping[grouping$cell == cell & grouping$section == "coverage_structure" & grouping$field == field & grouping$category == category, , drop = FALSE]
  stopifnot(nrow(r) == 1L, r$denominator == ns[[cell]])
  as.numeric(r$value)
}
dep <- list()
for (cell in cells) for (field in c("SITE_PF", if (startsWith(cell,"KF")) "SITE_TRKF")) {
  n <- ns[[cell]]; covered <- metric(cell,field,"n_covered"); missing <- metric(cell,field,"n_missing")
  ng <- metric(cell,field,"n_groups"); singles <- metric(cell,field,"n_singleton_groups")
  check(paste0("coverage_", cell,"_",field), covered + missing == n && ng <= covered && singles <= ng)
  dep[[length(dep)+1L]] <- data.frame(cell = cell, candidate = field, n = n, n_covered = covered, n_missing = missing,
    n_recorded_groups = ng, n_singleton_groups = singles, period = if (field == "SITE_PF") "Pre-K Fall (origin for Kindergarten cell)" else "Kindergarten Fall teacher rating",
    documented_meaning = if (field == "SITE_PF") "Preschool Fall site ID" else "Site where teacher rated child",
    uniqueness_domain = "unresolved", child_correspondence = "child-attached field; encompassing setting and belief respondent containment unauthenticated",
    evidence_status = "literal_partition_only", new_diagnostic_status = diagnostic_gate(FALSE, function() stop("No authenticated map supplied")),
    readiness = "not_ready", source = "output/tables/stage11_grouping_assessment.csv", locator = "coverage_structure rows",
    limitation = "Coverage does not establish independent/encompassing units or a stochastic target; accepted sample unchanged")
}
for (cell in cells) {
  # Each candidate has a cell-specific skipped-check record; NA means not recomputed, never zero missingness.
  for (field in c("SITE_PS","SITE_TRPS","SITE_TRKS","SITE_ECK","DS0002_CASEID","DS0003_CASEID","DS0003_LEAD_1","SNAPCLASSK","NUMCLSRMK")) {
    dep[[length(dep)+1L]] <- data.frame(cell = cell, candidate = field, n = ns[[cell]], n_covered = NA_real_, n_missing = NA_real_,
      n_recorded_groups = NA_real_, n_singleton_groups = NA_real_, period = "candidate-specific; see evidence ledger",
      documented_meaning = if (field %in% c("SNAPCLASSK","NUMCLSRMK")) "Number of observed classrooms; counts cannot identify classrooms" else if (grepl("CASEID",field)) "File-specific case identifier" else if (grepl("LEAD",field)) "Teacher ID label only" else "Spring/rating/ECERS site label; see ledger",
      uniqueness_domain = "unresolved", child_correspondence = "no authenticated additional map or cross-period code domain",
      evidence_status = "label_or_count_only", new_diagnostic_status = "skipped_no_new_informative_documentation",
      readiness = "not_ready", source = "stage13_evidence_ledger.csv", locator = "I_* and B_* records",
      limitation = "Coverage/containment/joins not newly computed; no child masks reconstructed; no Spring substitution")
  }
}
for (cell in cells[startsWith(cells,"KF")]) {
  for (field in c("current_per_origin","origin_per_current")) {
    r <- grouping[grouping$cell == cell & grouping$section == "observed_nesting_crossing" & grouping$field == field, , drop = FALSE]
    check(paste0("inherited_crossing_", cell,"_",field), nrow(r) == 1L && r$n <= r$denominator)
    evidence(paste0("X_",cell,"_",field), "inherited_aggregate", cell, "output/tables/stage11_grouping_assessment.csv",
      paste("section=observed_nesting_crossing; field=",field), paste(r$n,"of",r$denominator,"recorded codes have multiple counterpart codes; literal crossing only."),
      "accepted_aggregate", "Are relevant dependencies encompassed by any authenticated grouping?", "No uncertainty method selected")
  }
}
evidence("U_ASSUMPTIONS", "assumptions", "all cells", "output/reports/stage12_fall_associations.md", "Unresolved limits",
  "Independence across groups, encompassing dependence, stochastic target, sufficient independent information, and selection/generalizability require explicit analytical assumptions. Documentation and code counts cannot establish them.",
  "analytical_assumptions_not_established", "What stochastic target, dependence assumptions and selected-sample interpretation would a later uncertainty proposal defend?", "Separate review before any inference", disposition = "point_only_reporting")
ledger <- do.call(rbind, ledger); dep <- do.call(rbind, dep); rownames(ledger) <- rownames(dep) <- NULL
check("search_budget", sum(ledger$category == "targeted_search") == 4L && sum(ledger$category == "additional_document") == 1L,
  "4 targeted searches; 1 additional document", "<=4 searches; <=3 documents")
check("ledger_unique_keys", !anyDuplicated(ledger$evidence_id) && !anyNA(ledger))
check("dependence_unique_keys", !anyDuplicated(dep[c("cell","candidate")]) && nrow(dep) == 42L)
check("aggregate_only_schema", !any(c("STUDY_ID","CASEID","LEAD_1","origin_code","current_code") %in% c(names(ledger), names(dep))),
  detail = "Fixed allowlisted documentary/count schemas; no identifier values or code-by-code tables exported")
check("no_new_research_diagnostic", all(grepl("^skipped",dep$new_diagnostic_status)), detail = "New evidence supplies context but no authenticated scope/map")
measurement <- ledger[ledger$category == "measurement_endpoint", ]
check("three_measurement_conclusions", nrow(measurement) == 2L && all(measurement$direction_status == "unresolved") &&
  all(measurement$construction_status == "incomplete") && all(measurement$numerical_reproduction_status == "not_attempted_items_unavailable"))
cell_lines <- vapply(cells, function(cell) {
  d <- dep[dep$cell == cell & dep$candidate %in% c("SITE_PF","SITE_TRKF"), ]
  paste0("| ", cell," | ",ns[[cell]]," | ", paste(paste0(d$candidate,": ",d$n_covered,"/",d$n," covered; ",d$n_missing," missing; ",d$n_recorded_groups," codes"),collapse="; ")," | Not ready |")
}, "")
measurement_lines <- vapply(seq_len(nrow(measurement)), function(i) paste0("| ",measurement$fields[i]," | ",measurement$direction_status[i]," | ",measurement$construction_status[i]," | ",measurement$numerical_reproduction_status[i]," |"), "")
memo <- c("# Stage 13: bounded recovery of measurement and dependence evidence", "",
  "Endpoint: neither released belief measurement nor encompassing dependence units were authenticated. Preserve the accepted native numerical Fall benchmark and point-only reporting. This is an unresolved research endpoint, not a computational failure.", "",
  "## Measurement: three separate conclusions", "",
  "| Released composite | Substantive direction documented | Complete construction rules documented | Released numerical scores independently reproduced |",
  "|---|---|---|---|", measurement_lines, "",
  "For each composite, the direction remains unresolved and construction is incomplete. The questionnaire supplies 16 items and agreement anchors; these do not authenticate the released key. The older guide describes reversing non-traditional items but also says higher scores are progressive. Released labels name traditional child-rearing views without specifying higher-score direction. Retain this discrepancy; do not infer a reflection, division, common scale or polarity from numerical patterns.", "",
  "Missing construction facts include exact item membership/key, aggregation, missing-item rules and minimum completion, denominator, prorating, rounding and final transformations. Stage06 established the absence of positively identified suitable same-object item/completion inputs. No scores were reconstructed or independently reproduced. Even a documentary resolution of direction or construction would not by itself reproduce the released numbers.", "",
  "## Dependence readiness by analysis cell", "",
  "| Cell | Accepted N | Reused Stage11 literal coverage | Readiness |", "|---|---:|---|---|", cell_lines, "",
  "SITE_PF retains only its released Preschool Fall site-ID meaning; SITE_TRKF identifies the reported Kindergarten Fall teacher-rating site. Global uniqueness, encompassing setting scope, attachment to the belief respondent, teacher containment and original PSU relationships remain unauthenticated. Kindergarten current-site gaps remain 17 children in each outcome. Complete Pre-K coverage does not establish independence.", "",
  "Stage11 crossing aggregates are carried into the evidence ledger without code values. Origin settings split across current codes, and current codes can span origins. Neither partition is established as encompassing dependence. Ancillary Spring attendance/rating fields, ECERS sites, classroom counts, CASEID and LEAD_1 receive explicit skipped-check records in every cell. Equal codes across different fields do not establish equal settings; counts do not identify classrooms.", "",
  "## Acquisition, bounded search and stopping endpoints", "",
  paste0("Official listing: ", listing, ". Browser route: Data & Documentation, Download > Documentation Only. The listing loaded as V4 (2017-07-17); the documentation request redirected to sign-in. All six exact syntax targets share that single failed acquisition route. No retry, login, access bypass, guessed endpoint, research-data download or static syntax inspection occurred. File contents remain unknown, not confirmed absent from ICPSR."), "",
  "Budget used: four targeted searches out of four; one additional authoritative document out of three. Each exact query, access outcome, named question and disposition is in the evidence ledger. No additional resolving authoritative lead remained among those results; two document slots remain unused. Search results from other studies/general Modernity applications were not adopted as released evidence.", "",
  paste0("One source acquired: [Early et al. (2005), Pre-Kindergarten in Eleven States](",report_url,
    "). Verified 35-page Preliminary Descriptive Report dated May 24, 2005. It describes classroom recruitment within selected sites but supplies no released scoring key or child-classroom map. It is not the assumed release technical manual. Full PDF text was searched and relevant methods/limitations inspected. This supports context without upgrading released identifier scope."), "",
  "Measurement stopped at unavailable derivation syntax and no release-specific resolving follow-up evidence. Dependence stopped at unauthenticated scope/correspondence. The new report does not establish a new informative empirical relationship, so no research data were loaded, no accepted masks reconstructed, and no additional structural diagnostics run. Existing Stage06 and Stage09-12 findings were reused; no upstream stage was rerun.", "",
  "## Remaining provider questions and substantive next step", "",
  "Unsent measurement question, separately for T_IDEAP and T_IDEAK: Which release-v4 derivation and dependencies establish direction, items, reversals, aggregation, completion rule, denominator and final transformation? Checked: guide pp.40/44, released codebooks, Fall forms, setup/dictionaries, manifest, accepted Stage06/09/10 reviews, the bounded searches and FPG report. Mean/reversal/progressive wording is inconsistent; answers could permit a directional reading or require continued numerical-only wording. Numerical validation would still require available item inputs and separate authorization.", "",
  "Unsent dependence question: What are the uniqueness domain and belief-respondent correspondence of SITE_PF and SITE_TRKF, and is there an explicit child-to-classroom/teacher map for CASEID/LEAD_1? Checked: guide sampling/role descriptions, release entries/setup declarations, Stage09-11 diagnostics and the FPG methods. A valid map could permit a later reviewed structural audit; absent evidence preserves point-only reporting. The missing Kindergarten codes cannot be repaired by authentication alone.", "",
  "Recommended next substantive step: review whether the transparent numerical benchmark and its measurement/selection/dependence limitations are adequate for the writing sample, then draft the supported data, methods, results and limitations narrative. Do not add regressions to substitute for missing evidence. A later uncertainty proposal needs an explicit stochastic target, dependence/coverage assumptions and separate review; finite-sample coefficients alone are fixed descriptive quantities. Population, causal and cross-grade equivalence claims remain unsupported.", "",
  "## Scope and verification", "",
  "Only one new script, five aggregate outputs and the acquired documentation PDF are added. No harmonization, changed sample/cleaning, inference, model, Spring assignment, source-syntax execution or historical provenance update. Review stops before staging/commit/push. Detailed input pins, focused synthetic fixtures, source-locator checks, CSV readback and preservation results are in the verification artifacts.")
# Assemble and verify in scratch before exclusive publication. Existing destinations are never replaced.
scratch <- tempfile("stage13_"); dir.create(scratch)
csv_temp <- function(x, name) {
  p <- file.path(scratch,name)
  write.table(x,p,sep=",",row.names=FALSE,quote=TRUE,qmethod="double",na="NA",fileEncoding="UTF-8",eol="\n")
  back <- read.csv(p, colClasses="character", na.strings=NULL,check.names=FALSE,fileEncoding="UTF-8")
  expected <- x; expected[] <- lapply(expected,function(v) {v <- as.character(v); v[is.na(v)] <- "NA"; v})
  check(paste0("csv_roundtrip_",name), identical(back, expected))
  p
}
temp_files <- c(csv_temp(ledger,"evidence.csv"),csv_temp(dep,"dependence.csv"),file.path(scratch,"report.md"))
writeLines(enc2utf8(unname(memo)), temp_files[3], useBytes=TRUE)
check("report_roundtrip", identical(readLines(temp_files[3],warn=FALSE,encoding="UTF-8"),unname(memo)))
check("report_table_agreement", all(cell_lines %in% memo) && all(measurement_lines %in% memo))
check("runtime_inventory_before_publication", identical(inventory(), protected))
check("runtime_protected_hashes", identical(tools::md5sum(here::here(protected)), protected_md5), length(protected), detail="All project files including renv; Git internals separately checked")
check("head_branch_index_unchanged", identical(git(c("rev-parse","HEAD")),head_before) &&
  identical(git(c("branch","--show-current")),branch_before) && identical(git(c("ls-files","--stage")),index_before))
check("whitespace", length(git(c("diff","--check"))) == 0L && length(git(c("diff","--cached","--check"))) == 0L)
check_df <- do.call(rbind,checks); rownames(check_df) <- NULL
# Final two files' readback is asserted directly, avoiding self-referential ledger counts.
checks_temp <- file.path(scratch,"checks.csv")
write.table(check_df,checks_temp,sep=",",row.names=FALSE,quote=TRUE,qmethod="double",fileEncoding="UTF-8",eol="\n")
stopifnot(identical(read.csv(checks_temp,check.names=FALSE,colClasses="character",na.strings=NULL),check_df),all(check_df$status=="pass"))
note <- c("# Stage 13 verification and unresolved questions", "",
  paste("Fresh-session R:",R.version.string), paste("Execution UTC:",format(Sys.time(),tz="UTC",usetz=TRUE)),
  paste("HEAD:",head_before),paste("Branch:",branch_before), "",
  "Portable command: `Rscript --vanilla code/revision/13_recover_measurement_dependence_evidence.R --python PYTHON_WITH_PYPDF`.",
  "Optional `--baseline PATH` checks an existing external JSON inventory without rewriting it. Acquisition receipts are fixed 2026-10-18 observations; running this script does not reattempt network access. All five output destinations must be absent. Existing outputs trigger a preflight stop and are never deleted or replaced.", "",
  paste("Result:", nrow(check_df),"unique checks passed; zero failed. This verifies computation and evidence handling, not resolution of the research questions."), "",
  baseline_receipt, "",
  paste("Runtime preservation:",length(protected),"pre-existing execution-start files (including the Stage13 script and acquired PDF) have identical MD5 and inventory. HEAD, branch and full index entries unchanged. External baseline verifies pre-implementation SHA-256 when supplied; post-publication SHA-256 checks are performed independently by the caller."), "",
  "Fixtures: ambiguous/duplicate and missing mapping keys rejected; unmatched mapping and mapped missing groups counted; missing/all-missing grouping and crossing tested; absent-documentation gate skips without executing diagnostic. These are synthetic fixtures only, not new research-data diagnostics. No child data/masks/models were loaded or reconstructed. No syntax was acquired or executed.", "",
  "Development limitations: system pdftotext (MiKTeX) failed because it required unavailable setup/registry access; its attempted reads produced no source text. Bundled pypdf was used successfully instead. An initial console extraction hit Windows character encoding; rerunning Python with -X utf8 succeeded. The first package-presence probe emitted startup locale warnings; the authorized fresh run uses LC_ALL=English_United States.utf8. No dependency installation or MiKTeX setup was performed.", "",
  "Research endpoints: T_IDEAP direction unresolved/construction incomplete/numerical reproduction not attempted; T_IDEAK direction unresolved/construction incomplete/numerical reproduction not attempted. All four dependence cells not ready. Sign-in gate blocked all six supplemental files on one shared route. Four searches and one of three additional documents used. No new contradictory release-specific derivations were obtained. Unsent targeted provider questions and implications are in the report.", "",
  "Historical membership caveat persists: Stage11 saved aggregate diagnostics, not a child membership fingerprint. This stage reuses those aggregates; it cannot newly certify historical child-by-child membership. No source or accepted output provenance is rewritten.", "",
  "## Accepted evidence SHA-256 pins", "", "| Path | SHA-256 |", "|---|---|",
  vapply(names(input_pins),function(p) paste0("| ",p," | ",input_pins[[p]]," |"), ""), "",
  "## New source SHA-256", "",paste(report_source,sha(report_source)),"",
  "## Execution-start Git status", "", "```text",status_before,"```", "",
  "No staging, commit or push was performed. Output hashes and final Git status are checked by the caller after publication; this file makes no claim that later review/publication happened.")
note_temp <- file.path(scratch,"verification.md"); writeLines(enc2utf8(unname(note)),note_temp,useBytes=TRUE)
stopifnot(identical(readLines(note_temp,encoding="UTF-8",warn=FALSE),unname(note)))
temp_files <- c(temp_files,checks_temp,note_temp)
py(paste0("import pathlib,sys; s=sys.argv[1:6]; d=sys.argv[6:11]; ",
  "assert len(s)==len(d)==5 and all(not pathlib.Path(p).exists() for p in d); ",
  "[(pathlib.Path(b).open('xb').write(pathlib.Path(a).read_bytes())) for a,b in zip(s,d)]; ",
  "assert all(pathlib.Path(a).read_bytes()==pathlib.Path(b).read_bytes() for a,b in zip(s,d)); print('Five outputs exclusively created and verified')"),
  c(temp_files,here::here(dest)))
stopifnot(identical(inventory(),protected),identical(tools::md5sum(here::here(protected)),protected_md5),
  identical(git(c("rev-parse","HEAD")),head_before),identical(git(c("ls-files","--stage")),index_before))
cat(nrow(check_df),"checks passed; five outputs created; all protected files and HEAD/index preserved.\n")
