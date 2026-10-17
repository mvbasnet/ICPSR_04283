# Stage 07: bounded, documented outcome cleaning; no upstream script is sourced.
# From the repository root in a fresh session:
# $env:LC_ALL = 'English_United States.utf8'
# & 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/07_clean_outcomes_describe.R
# The default entry point runs two fresh workers, verifies them, then publishes ten
# ignored artifacts. Existing upstream files and released panel columns are read-only.
# Project decision: defer general comparability assessment and score differences in Stage 07.
project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
root_raw <- system2("git", c("rev-parse", "--show-toplevel"), stdout = TRUE)
if (!is.null(attr(root_raw, "status"))) stop("Cannot determine Git root.")
git_root <- normalizePath(root_raw[1], winslash = "/", mustWork = TRUE)
if (!identical(project_start, git_root) || basename(git_root) != "ICPSR_04283") {
  stop("Run from the ICPSR_04283 Git root.")
}
Sys.setenv(RENV_PATHS_ROOT = file.path(project_start, "renv", "local"),
           RENV_CONFIG_SANDBOX_ENABLED = "FALSE", RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
source(file.path(project_start, "renv", "activate.R"))
suppressPackageStartupMessages(library(here))
stopifnot(identical(normalizePath(here::here(), winslash = "/"), git_root))
options(stringsAsFactors = FALSE, OutDec = ".", digits = 17)

script_path <- "code/revision/07_clean_outcomes_describe.R"
destinations <- c("Data/processed/outcome_cleaning_panel.rds",
  paste0("output/tables/outcome_cleaning_", c("evidence", "rules", "counts", "numeric_summary",
    "status_frequencies", "pair_support"), ".csv"),
  "output/figures/outcome_cleaning_distributions.pdf",
  "output/verification/outcome_cleaning_checks.csv",
  "output/verification/outcome_cleaning_review.md")
stopifnot(all(dir.exists(dirname(here::here(destinations)))))
ignored <- vapply(destinations, function(p) identical(system2("git", c("check-ignore", "-q", "--", p)), 0L), logical(1))
if (!all(ignored)) stop("All ten destinations must be ignored before publication.")

bind <- function(x) { z <- do.call(rbind, x); row.names(z) <- NULL; z }
same <- function(x, y) isTRUE(all.equal(x, y, tolerance = 1e-12, check.attributes = FALSE))
pct <- function(n, d) { ans <- 100 * n / d; ans[is.na(d) | d == 0] <- NA_real_; ans }
write_csv <- function(x, path) {
  # write.table's numeric conversion is not a 17-significant-digit contract.
  # Format doubles explicitly and leave them unquoted; quote/escape all strings.
  encode <- function(z) {
    if (is.character(z)) return(ifelse(is.na(z), "NA", paste0('"', gsub('"', '""', z, fixed = TRUE), '"')))
    if (is.logical(z)) return(ifelse(is.na(z), "NA", ifelse(z, "TRUE", "FALSE")))
    if (is.integer(z)) return(ifelse(is.na(z), "NA", as.character(z)))
    if (is.double(z)) return(ifelse(is.na(z), "NA", sprintf("%.17g", z)))
    stop("Unsupported CSV column type.")
  }
  cells <- lapply(x, encode)
  lines <- c(paste(encode(names(x)), collapse = ","),
    vapply(seq_len(nrow(x)), function(i) paste(vapply(cells, `[`, character(1), i), collapse = ","), character(1)))
  con <- file(path, "wb"); on.exit(close(con)); writeBin(charToRaw(paste0(paste(lines, collapse = "\n"), "\n")), con)
}
read_csv <- function(path) read.csv(path, colClasses = "character", check.names = FALSE,
  na.strings = character(), fileEncoding = "UTF-8")
csv_numbers <- function(x) {
  z <- as.character(unlist(x, use.names = FALSE))
  z[z == "NA"] <- NA_character_
  as.double(z)
}
check_csv <- function(x, path) {
  y <- read_csv(path)
  stopifnot(identical(names(x), names(y)), nrow(x) == nrow(y))
  for (f in names(x)) {
    a <- x[[f]]; b <- y[[f]]
    if (is.character(a)) stopifnot(identical(ifelse(is.na(a), "NA", a), b)) else {
      stopifnot(identical(is.na(a), b == "NA"))
      ok <- !is.na(a)
      if (is.logical(a)) stopifnot(identical(as.character(a[ok]), b[ok])) else
        stopifnot(identical(as.double(a[ok]), as.double(b[ok])))
    }
  }
  TRUE
}
protected_paths <- function() {
  tracked <- system2("git", c("ls-files"), stdout = TRUE)
  paths <- sort(unique(c(tracked, unlist(lapply(c("Data", "docs", "code", "output", "paper"),
    function(p) list.files(here::here(p), recursive = TRUE, all.files = TRUE, full.names = TRUE)), use.names = FALSE))))
  paths <- gsub("\\\\", "/", paths)
  absolute <- startsWith(paths, paste0(project_start, "/"))
  paths[absolute] <- substring(paths[absolute], nchar(project_start) + 2L)
  paths <- sort(unique(paths))
  paths <- paths[file.exists(paths) & !dir.exists(paths)]
  setdiff(paths, c(destinations, script_path))
}
hashes <- function(paths) { z <- tools::md5sum(here::here(paths)); names(z) <- paths; z }

waves <- c("PF", "PS", "KF", "KS")
wave_labels <- c("Fall Pre-K", "Spring Pre-K", "Fall Kindergarten", "Spring Kindergarten")
outcomes <- c("ppvt_english_standard_score", "applied_problems_english_standard_score",
  "sound_awareness_rhyming_raw_score", "tvip_spanish_standard_score", "tvip_spanish_raw_score",
  "woodcock_munoz_applied_problems_standard_score", "woodcock_munoz_applied_problems_w_score",
  "woodcock_munoz_letter_word_standard_score", "woodcock_munoz_letter_word_w_score")
source_map <- list(c("PPVTEPF", "PPVTEPS", "PPVTEKF", "PPVTEKS"),
  c("WJ10_SSEPF", "WJ10_SSEPS", "WJ10_SSEKF", "WJ10_SSEKS"),
  c("WJ21AEPF", "WJ21AEPS", "WJ21AEKF", "WJ21AEKS"),
  c("TVIPSPF", "TVIPSPS", "TVIPSKF", "TVIPSKS"), c("TVIPRSPF", "TVIPRSPS", "", ""),
  c("WM25SSPF", "WM25SSPS", "WM25SSKF", "WM25SSKS"),
  c("WM25WPF", "WM25WPS", "WM25WKF", "WM25WKS"), c("", "", "WM22SSKF", "WM22SSKS"),
  c("", "", "WM22WKF", "WM22WKS"))
contract <- bind(lapply(seq_along(outcomes), function(i) data.frame(outcome = outcomes[i], wave = waves,
  source_variable = source_map[[i]], language = if (i <= 3) "English" else "Spanish",
  score_type = if (i %in% c(3, 5)) "raw score" else if (i %in% c(7, 9)) "W score" else "standard score")))
minus5 <- c("PPVTEPF", "PPVTEPS", "WJ10_SSEPF", "WJ10_SSEPS", "WJ10_SSEKF", "WJ21AEPF", "WJ21AEPS")
minus6 <- c("WJ10_SSEPS", "TVIPSKF")
practice_sources <- c("WJ10_SSEPF", "WJ10_SSEPS")
rhyming_sources <- source_map[[3]]
rhyming_labels <- setNames(c(rep("WJIII TEST 21A (RHYMING): RAW SCORE", 2),
  rep("WJIII TEST 21A (RHYMING) (RAW SCORE)", 2)), rhyming_sources)
missing_codes <- function(src) if (!nzchar(src)) numeric() else c(-99, if (src %in% minus5) -5, if (src %in% minus6) -6)
reasons <- c("no_approved_mapping", "source_missing_reason_unavailable", "practice_failure_project_exclusion",
  "documented_source_special", "documented_invalid_above_max", "unresolved_score_value", "retained_under_current_rules")
status_levels <- c("(1) Absent", "(2) Full Assessment (English)", "(3) Full Assessment (Spanish)",
  "(4) Non-English, Spanish-Speaking Child Failed Pre-LAS", "(5) Partial Assessment (English)",
  "(6) Partial Assessment (Spanish)", "(7) Child Refused Assessment", "(8) DR")
status_documentation <- function(status) ifelse(is.na(status), "source_missing",
  ifelse(as.character(status) == "(8) DR", "undefined_DR", "documented_label_only"))

# Status has deliberately no argument here: it cannot change score treatment.
# Labels come from the exact source vector, never from a neighboring wave.
clean_score <- function(x, src, labels = NULL) {
  y <- as.double(x); reason <- rep("retained_under_current_rules", length(x))
  if (!nzchar(src)) reason[] <- "no_approved_mapping" else {
    reason[is.na(x)] <- "source_missing_reason_unavailable"
    available <- function() reason == "retained_under_current_rules"
    reason[available() & x %in% missing_codes(src)] <- "documented_source_special"
    if (src %in% practice_sources) reason[available() & x %in% -7] <- "practice_failure_project_exclusion"
    if (src %in% rhyming_sources) reason[available() & is.finite(x) & x > 17] <- "documented_invalid_above_max"
    unknown <- (!is.na(x) & !is.finite(x)) | (!is.na(x) & x %in% unname(labels))
    reason[available() & unknown] <- "unresolved_score_value"
  }
  eligible <- reason == "retained_under_current_rules"
  eligible[reason == "unresolved_score_value"] <- NA
  y[reason %in% reasons[1:5]] <- NA_real_
  list(clean = y, reason = reason, eligible = eligible)
}
changed <- function(x, y) (!is.na(x) & is.na(y)) | (is.na(x) & !is.na(y)) |
  (!is.na(x) & !is.na(y) & x != y)
numeric_summary <- function(x, mapped = TRUE) {
  n <- sum(!is.na(x)); nf <- sum(!is.na(x) & !is.finite(x))
  state <- if (!mapped) "mapping_gap" else if (!n) "empty_group" else if (nf) "nonfinite_present" else
    if (n == 1L) "singleton" else "ok"
  stats <- setNames(rep(NA_real_, 9), c("mean", "sd", "min", "p05", "p25", "median", "p75", "p95", "max"))
  if (state %in% c("ok", "singleton")) {
    z <- x[!is.na(x)]
    stats[] <- c(mean(z), if (length(z) > 1L) sd(z) else NA_real_, min(z),
      quantile(z, c(.05, .25, .5, .75, .95), type = 7, names = FALSE), max(z))
  }
  cbind(as.data.frame(as.list(stats)), summary_status = state)
}

schemas <- list(
  evidence = "evidence_id claim_id resource_path resource_md5 source_tier variable pdf_page printed_page line_start line_end exact_passage interpretation evidence_status availability limitation issue_ids notebooklm_locator notebooklm_claim_status",
  rules = "rule_id outcome wave source_variable language score_type rule_kind operator rule_value action decision_basis implementation_status evidence_status evidence_ids issue_ids n_matched n_changed limitation",
  counts = "outcome wave source_variable mapped n_structural n_source_observed n_source_missing n_mapping_gap n_practice_failure_project_excluded n_documented_source_special n_documented_invalid n_unresolved_score_value n_eligible_current_rules n_clean_nonmissing n_nonfinite n_values_changed n_status_DR n_status_DR_with_source_score",
  numeric_summary = "outcome wave language score_type view denominator_structural n_summarized n_practice_failure_in_view n_source_special_in_view n_unresolved_score_in_view n_nonfinite mean sd min p05 p25 median p75 p95 max summary_status",
  status_frequencies = "outcome wave status_order status_kind status_label cleaning_reason n denominator_structural denominator_status pct_structural pct_within_status",
  pair_support = "outcome grade fall_wave spring_wave fall_mapped spring_mapped n_children n_source_fall n_source_spring n_source_both n_source_fall_only n_source_spring_only n_source_neither n_eligible_fall n_eligible_spring n_eligible_both n_eligible_fall_only n_eligible_spring_only n_eligible_neither n_pairs_lost n_pairs_with_unresolved_scores comparability_status comparability_evidence_ids difference_status",
  checks = "check_id severity expected observed status detail")
schemas <- lapply(schemas, strsplit, split = " ", fixed = TRUE)
schemas <- lapply(schemas, `[[`, 1)
keys <- list(evidence = "evidence_id", rules = c("rule_id", "outcome", "wave"), counts = c("outcome", "wave"),
  numeric_summary = c("outcome", "wave", "view"), status_frequencies = c("outcome", "wave", "status_order", "cleaning_reason"),
  pair_support = c("outcome", "grade"), checks = "check_id")

run_stage <- function(outdir) {
  checks <- data.frame(check_id = character(), severity = character(), expected = character(),
    observed = character(), status = character(), detail = character())
  hard <- function(id, condition, expected = "TRUE", observed = condition, detail = "") {
    txt <- function(z) paste(ifelse(is.na(z), "NA", as.character(z)), collapse = " | ")
    checks <<- rbind(checks, data.frame(check_id = id, severity = "hard", expected = txt(expected),
      observed = txt(observed), status = if (isTRUE(condition)) "pass" else "fail", detail = detail))
    if (!isTRUE(condition)) stop("Stage 07 check failed: ", id, "; observed: ", txt(observed))
  }
  paths_before <- protected_paths(); before <- hashes(paths_before)
  required <- c("Data/processed/structural_child_wave_panel.rds", "Data/processed/verified_child_wide.rds",
    "Data/raw/icpsr_04283/04283-0001-Data.rda", "output/tables/structural_panel_provenance.csv",
    paste0("output/tables/descriptive_", c("numeric_summary", "assessment_pair_support", "assessment_status_score_availability"), ".csv"),
    "docs/stage1_variable_crosswalk.csv", "docs/stage1_unresolved_issues.md")
  hard("required_inputs", all(file.exists(here::here(required))))
  doc_paths <- c(C = "docs/icpsr/DS0001/04283-0001-Codebook.pdf", G = "docs/icpsr/04283-User_guide.pdf",
    S = "docs/icpsr/DS0001/04283-0001-Setup.do", D = "docs/icpsr/DS0001/04283-0001-Setup.dct")
  doc_md5 <- c(C = "e446e37ce5abc44ec01f542b066ab23a", G = "4e55f1c71026776af7c4a859bba57027",
    S = "ee8f0a97a9dbb176eeea77bd9c40afc4", D = "77b8aed6a5eee90227b2b6c6bfe3ba1b")
  hard("approved_document_hashes", identical(unname(hashes(doc_paths)), unname(doc_md5)),
    unname(doc_md5), unname(hashes(doc_paths)), "Changed approved evidence stops publication.")
  # Pin the inspected inputs as well as checking semantic lineage. This stage is
  # deliberately bounded to these inputs; a changed release requires review.
  hard("inspected_input_hashes", identical(unname(hashes(required[1:3])),
    c("2bb62db072c370bdeae6dbebe3e1e5f2", "d1b9b2563414fc0c3e6ceccb757bea1c", "e1dd29c3fe46e0ac1ebb90f51ef041d3")))
  panel <- readRDS(here::here(required[1])); wide <- readRDS(here::here(required[2]))
  src_env <- new.env(parent = emptyenv()); load(here::here(required[3]), envir = src_env)
  source_data <- src_env[["da04283.0001"]]
  hard("input_dimensions", identical(dim(panel), c(4060L, 37L)) && identical(dim(wide), c(1015L, 62L)))
  hard("source_identifiers", identical(wide$STUDY_ID, source_data$STUDY_ID))
  hard("panel_keys", !anyDuplicated(panel[c("STUDY_ID", "wave")]) &&
    all(vapply(waves, function(w) identical(panel$STUDY_ID[panel$wave == w], wide$STUDY_ID), logical(1))))
  hard("status_labels", identical(levels(panel$assessment_status_released), status_levels))
  hard("practice_source_labels", all(vapply(practice_sources, function(src)
    identical(attr(source_data[[src]], "value.labels", exact = TRUE), c("Child Failed Practice Items" = -7)), logical(1))))
  hard("Kindergarten_no_documented_practice_label", all(vapply(source_map[[2]][3:4], function(src)
    !(-7 %in% unname(attr(source_data[[src]], "value.labels", exact = TRUE))), logical(1))))
  for (stage in c("verified_wide", "structural_panel", "descriptive")) {
    up <- read_csv(here::here(paste0("output/verification/", stage, "_checks.csv")))
    hard(paste0("upstream_checks_", stage), identical(names(up), schemas$checks) &&
      !anyDuplicated(up$check_id) && any(up$severity == "hard") && all(up$status[up$severity == "hard"] == "pass"))
  }
  provenance <- read_csv(here::here(required[4]))
  crosswalk <- read_csv(here::here(required[8]))
  resource_paths <- c(doc_paths, X = required[8], P = required[4], I = required[9], J = script_path)
  resource_md5 <- setNames(unname(hashes(resource_paths)), names(resource_paths))
  resource_tiers <- c(C = "release_specific", G = "study_guide", S = "release_specific", D = "release_specific",
    X = "approved_project_crosswalk", P = "upstream_stage04_provenance", I = "project_issue_register", J = "project_decision")
  hard("approved_mapping_resource_hashes", identical(unname(resource_md5[c("X", "P", "I")]),
    c("f35b8024afb5e4da0b052138fdad0360", "7e1935dc869dd854b9407266233b121f", "10ba0b7c09ee23f0644902fb1d373f7f")))
  resource_lines <- lapply(resource_paths, function(p) readLines(here::here(p), warn = FALSE))
  setup <- readLines(here::here(doc_paths["S"]), warn = FALSE)
  dictionary <- readLines(here::here(doc_paths["D"]), warn = FALSE)
  # Evidence ledger: exact localized source text and interpretation are separate.
  evidence_rows <- list()
  evidence <- function(id, claim, alias, variable = "not_applicable", pdf = NA_integer_, printed = NA_integer_,
      start = NA_integer_, end = start, passage, interpretation, state = "supported",
      limitation = "not_applicable", issues = "not_applicable", nl = "not_applicable", nl_state = "not_applicable") {
    evidence_rows[[length(evidence_rows) + 1L]] <<- data.frame(evidence_id = id, claim_id = claim,
      resource_path = unname(resource_paths[alias]), resource_md5 = unname(resource_md5[alias]),
      source_tier = unname(resource_tiers[alias]),
      variable = variable, pdf_page = as.integer(pdf), printed_page = as.integer(printed),
      line_start = as.integer(start), line_end = as.integer(end), exact_passage = passage,
      interpretation = interpretation, evidence_status = state, availability = "local_verified_hash",
      limitation = limitation, issue_ids = issues, notebooklm_locator = nl, notebooklm_claim_status = nl_state)
  }
  evidence("G_MAX", "rhyming_maximum", "G", paste(rhyming_sources, collapse = ";"), 48L, 12L,
    passage = "The maximum possible on this scale is 17.",
    interpretation = "Score maximum applies to the four mapped WJIII Test 21A raw scores; exclude above 17, never cap.",
    limitation = "Does not establish item count, lower bound, or integer-only rule.",
    issues = "S07_BOUNDS", nl = "Guide PDF p.21 / printed p.11; claimed Pre-K maxima 14/13", nl_state = "incorrect_for_local_document")
  evidence("C_PF_PRACTICE", "practice_code_meaning", "C", "WJ10_SSEPF", 41L, 37L,
    passage = "Child Failed Practice Items", interpretation = "Value -7 has this label, 7 records. Location 196-198.",
    limitation = "Meaning supports a project choice, not a release-mandated exclusion.",
    nl = "WJ10_SSEPF location 193-195", nl_state = "incorrect_for_local_document")
  evidence("C_PS_PRACTICE", "practice_code_meaning", "C", "WJ10_SSEPS", 67L, 63L,
    passage = "Child Failed Practice Items", interpretation = "Value -7 has this label, 1 record. Location 265-267.",
    limitation = "Release valid-case classification does not establish numerical achievement-score meaning.")
  for (w in 1:2) {
    src <- practice_sources[w]; pg <- c(43L, 69L)[w]
    evidence(paste0("C_", waves[w], "_MISSING"), "practice_release_missing_declaration", "C", src, pg, pg - 4L,
      passage = c("-99 , -5", "-99 , -6 , -5")[w], interpretation = paste0("Missing declaration; declared valid cases ", c(797, 851)[w], ". Does not remove -7."))
    ln <- c(149L, 196L)[w]; le <- c(150L, 198L)[w]
    evidence(paste0("S_", waves[w], "_PRACTICE"), "practice_code_label", "S", src, start = ln, end = le,
      passage = paste(trimws(setup[ln:le]), collapse = "\n"), interpretation = "Source-specific -7 label; project analytical exclusion is recorded separately.")
  }
  evidence("C_DR", "undefined_status_DR", "C", "ASMSTATPS", 80L, 76L,
    passage = "DR", interpretation = "Code 8, 2 children (0.2%); location 298-300. Meaning is not expanded.",
    state = "unresolved", limitation = "Status alone has no score-cleaning or eligibility consequence.", issues = "S07_DR",
    nl = "Codebook PDF p.80; claimed location 226-228", nl_state = "incorrect_for_local_document")
  evidence("S_DR", "undefined_status_DR", "S", "ASMSTATPS", start = 210L, end = 216L,
    passage = paste(trimws(setup[210:216]), collapse = "\n"), interpretation = "Released status labels include DR without expansion.",
    state = "unresolved", limitation = "No documented score-validity implication.", issues = "S07_DR", nl_state = "verified", nl = "Codebook PDF p.80 (status label)")
  for (j in 1:2) {
    v <- c("WM25SSPF", "WM25SSPS")[j]; pg <- c(49L, 75L)[j]
    evidence(paste0("C_", v, "_LABEL"), "WM_released_metric", "C", v, pg, pg - 4L,
      passage = "STANDARD SCORE", interpretation = paste0("Release label; location ", c("217-219", "286-288")[j], "; retain separately."),
      nl = c("Codebook PDF p.45", "Codebook PDF p.94")[j], nl_state = "incorrect_for_local_document")
    pg <- c(50L, 77L)[j]
    evidence(paste0("C_", v, "_STATS"), "WM_release_summary", "C", v, pg, pg - 4L,
      passage = c("Mean: 79.81", "Mean: 78.79")[j],
      interpretation = c("113 valid cases; SD 14.59; released standard score.", "94 valid cases; SD 15.25; released standard score.")[j],
      limitation = "Matching marginal Ns cannot establish matching populations or scoring history.",
      issues = "S07_WM_GUIDE", nl = "Claimed N=110/92 and Fall SD=15.24", nl_state = "incorrect_for_local_document")
  }
  evidence("G_WM_TABLE", "WM_guide_discrepancy", "G", "wm25sspf;wm25ssps", 54L, 18L,
    passage = "Woodcock Muñoz", interpretation = "CHILD OUTCOMES (Pre-K), Spanish Assessment: PF N=113 mean=5.77 SD=3.35; PS N=94 mean=7.66 SD=3.39. Row names wm25sspf, wm25ssps; metric not stated as raw scores.",
    state = "unresolved", limitation = "No conversion, population identity, or requirement to reproduce guide statistics is inferred.",
    issues = "S07_WM_GUIDE", nl = "Guide PDF p.30 / printed p.20; N=110/92; SD=3.65/3.49; raw-score interpretation", nl_state = "incorrect_for_local_document")
  evidence("G_RHYME_PK", "rhyming_mapping", "G", "WJ21AEPF;WJ21AEPS", 54L, 18L,
    passage = "WJ rhyming raw", interpretation = "Pre-K summary names the mapped raw-score fields; observed maxima 15/15 in release.")
  evidence("G_RHYME_K", "rhyming_mapping", "G", "WJ21AEKF;WJ21AEKS", 56L, 20L,
    passage = "WJ rhyming raw", interpretation = "Kindergarten summary names the mapped raw-score fields; observed maxima 17/17 in release.")
  for (j in 1:4) {
    pg <- c(43L, 69L, 596L, 625L)[j]
    evidence(paste0("C_RHYME_", waves[j]), "rhyming_release_label", "C", rhyming_sources[j], pg, pg - 4L,
      passage = unname(rhyming_labels[rhyming_sources[j]]), interpretation = "Entry continues on next PDF/printed page; supports application of G_MAX to this raw score.")
  }
  evidence("S_ADJACENT_W", "adjacent_W_score_correction", "S", "WJ10_WEPF", start = 2605L,
    passage = trimws(setup[2605]), interpretation = "Adjacent English W-score replacement also retains -7; no English W-score outcome is added.",
    nl = "Claimed W-score/standard-score missing-code contrast", nl_state = "incorrect_for_local_document")
  evidence("C_ADJACENT_W", "adjacent_W_missing_declaration", "C", "WJ10_WEPF", 41L, 37L,
    passage = "-99 , -5", interpretation = "Adjacent W-score missing declaration. The preceding -99,-8,-7,-5 declaration belongs to OWLSEPF, location 190-192.",
    nl = "Claimed W-score/standard-score contrast", nl_state = "incorrect_for_local_document")
  evidence("G_BOUNDS_OPEN", "unsupported_bounds_and_norming", "G", pdf = 48L, printed = 12L,
    passage = "The maximum possible on this scale is 17.", interpretation = "Only a rhyming maximum is used; other score bounds and detailed norming remain unresolved.",
    state = "unresolved", limitation = "No lower-bound, integer-only, trimming, or scale-conversion rule is authorized.", issues = "S07_BOUNDS")
  evidence("G_Q09", "specific_language_mapping_question", "G", variable = "PPVTEKF;PPVTEKS;English/Spanish batteries", pdf = 49L, printed = 13L,
    passage = "Spanish-Language Assessment Battery", interpretation = "Q09 concerns the separately described Kindergarten English PPVT for Spanish-battery children and cross-language combination; its released-field mapping remains unresolved.",
    state = "unresolved", limitation = "This passage does not establish field-occasion mappings, intentional mapping gaps, or a general comparability deferral for every outcome.", issues = "Q09")
  issue_start <- which(startsWith(resource_lines$I, "## Q09 -"))
  issue_end <- which(startsWith(resource_lines$I, "## Review boundary")) - 1L
  hard("Q09_localized_scope", length(issue_start) == 1L && length(issue_end) == 1L && issue_end > issue_start)
  evidence("I_Q09", "specific_language_mapping_question", "I", variable = "PPVTEKF;PPVTEKS;English/Spanish batteries",
    start = issue_start, end = issue_end, passage = paste(resource_lines$I[issue_start:issue_end], collapse = "\n"),
    interpretation = "Reviewed project register specifies the unresolved Kindergarten Spanish-battery English-PPVT mapping and English/Spanish combination question.",
    state = "unresolved", limitation = "Q09 is retained as specific language-mapping context, not generic mapping or within-outcome longitudinal provenance.", issues = "Q09")
  project_passage <- "# Project decision: defer general comparability assessment and score differences in Stage 07."
  project_line <- which(resource_lines$J == project_passage)
  hard("project_comparability_decision_locator", length(project_line) == 1L)
  evidence("PROJECT_COMPARABILITY_DEFERRAL", "stage07_project_scope_decision", "J", start = project_line,
    passage = project_passage, interpretation = "The project confines Stage 07 to cleaning and descriptive support; general comparability assessment and score differences are deferred for all outcomes.",
    limitation = "A project scope decision does not establish psychometric comparability or noncomparability.", issues = "S07_COMPARABILITY_DEFERRED")
  # Localize complete CSV records, including any quoted multiline fields.
  mapping_record <- function(alias, id, variable, prefix, interpretation) {
    lines <- resource_lines[[alias]]; first <- which(startsWith(lines, prefix))
    hard(paste0("mapping_evidence_locator_", id), length(first) == 1L)
    starts <- grep(if (alias == "P") '^"decision_[0-9]+",' else '^"DS[0-9]{4}",', lines)
    last <- min(c(starts[starts > first], length(lines) + 1L)) - 1L
    evidence(id, "approved_field_occasion_mapping", alias, variable, start = first, end = last,
      passage = paste(lines[first:last], collapse = "\n"), interpretation = interpretation,
      limitation = "Mapping provenance only; does not authorize additional cleaning, prove noncollection, or resolve comparability.")
  }
  mapping_refs <- character(nrow(contract)); provenance_refs <- character(nrow(contract))
  for (i in seq_len(nrow(contract))) {
    r <- contract[i, ]; src <- r$source_variable
    p <- provenance[provenance$output_variable == r$outcome & provenance$wave == r$wave, ]
    hard(paste0("mapping_evidence_record_", i), nrow(p) == 1L && p$source_variable == src)
    provenance_refs[i] <- paste0("P_MAP_", p$decision_id)
    mapping_record("P", provenance_refs[i], if (nzchar(src)) src else r$outcome,
      paste0('"', p$decision_id, '",'), paste0("Stage 04 records ", r$outcome, " at ", r$wave, ": ",
        if (nzchar(src)) paste0("mapped source ", src, ".") else "intentional no_approved_source_mapping; no source is inferred."))
    approved <- crosswalk[crosswalk$dataset_id == "DS0001" & crosswalk$proposed_construct == r$outcome, ]
    hard(paste0("crosswalk_mapping_scope_", i), nrow(approved) > 0L &&
      if (nzchar(src)) sum(approved$raw_variable == src & approved$wave == r$wave) == 1L else !any(approved$wave == r$wave))
    coverage <- if (nzchar(src)) src else approved$raw_variable
    mapping_refs[i] <- paste(c(provenance_refs[i], paste0("X_MAP_", coverage)), collapse = ";")
  }
  for (src in contract$source_variable[nzchar(contract$source_variable)]) {
    mapping_record("X", paste0("X_MAP_", src), src, paste0('"DS0001","', src, '",'),
      "Approved crosswalk source, construct, and occasion; cited only for mapping coverage, including the limited approved coverage underlying Stage 04 gaps.")
  }

  # One localized setup passage for every mapped source, plus its dictionary label.
  for (src in contract$source_variable[nzchar(contract$source_variable)]) {
    ii <- grep(paste0("^replace ", src, " = \\. if"), setup)
    hard(paste0("setup_single_replacement_", src), length(ii) == 1L)
    codes <- as.double(regmatches(setup[ii], gregexpr("-[0-9]+", setup[ii]))[[1]])
    hard(paste0("registry_matches_release_", src), setequal(codes, missing_codes(src)),
      missing_codes(src), codes, "Only exact source-specific documented missing codes.")
    evidence(paste0("S_MISS_", src), "source_missing_registry", "S", src, start = ii,
      passage = trimws(setup[ii]), interpretation = "Exact release replacement; no borrowing across sources or waves.")
    jj <- grep(paste0("[[:space:]]", src, "[[:space:]]"), dictionary)
    hard(paste0("dictionary_source_", src), length(jj) == 1L)
    if (src %in% rhyming_sources) hard(paste0("rhyming_source_label_", src),
      grepl(rhyming_labels[src], dictionary[jj], fixed = TRUE))
    evidence(paste0("D_LABEL_", src), "release_source_label", "D", src, start = jj,
      passage = trimws(dictionary[jj]), interpretation = "Retain this release-labeled metric separately.")
  }
  E <- bind(evidence_rows)

  cleaned <- panel
  cleaned$assessment_status_documentation_state <- status_documentation(panel$assessment_status_released)
  for (f in outcomes) {
    cleaned[[paste0(f, "_clean")]] <- rep(NA_real_, nrow(panel))
    cleaned[[paste0(f, "_cleaning_reason")]] <- rep(NA_character_, nrow(panel))
    cleaned[[paste0(f, "_eligible_current_rules")]] <- rep(NA, nrow(panel))
  }
  rule_rows <- count_rows <- numeric_rows <- status_rows <- list()
  results <- vector("list", nrow(contract))
  for (i in seq_len(nrow(contract))) {
    r <- contract[i, ]; f <- r$outcome; w <- r$wave; src <- r$source_variable; mapped <- nzchar(src)
    idx <- which(panel$wave == w); x <- panel[[f]][idx]; status <- panel$assessment_status_released[idx]
    p <- provenance[provenance$output_variable == f & provenance$wave == w, ]
    hard(paste0("approved_mapping_", i), nrow(p) == 1L && p$source_variable == src &&
      p$availability_status == if (mapped) "source_mapped" else "no_approved_source_mapping")
    if (mapped) {
      hard(paste0("source_to_wide_", src), identical(wide[[src]], source_data[[src]]))
      hard(paste0("wide_to_panel_", src), identical(as.double(x), as.double(wide[[src]])))
    } else hard(paste0("gap_values_", i), all(is.na(x)))
    labels <- if (mapped) attr(source_data[[src]], "value.labels", exact = TRUE) else NULL
    z <- clean_score(x, src, labels); results[[i]] <- z
    cleaned[[paste0(f, "_clean")]][idx] <- z$clean
    cleaned[[paste0(f, "_cleaning_reason")]][idx] <- z$reason
    cleaned[[paste0(f, "_eligible_current_rules")]][idx] <- z$eligible
    changed_mask <- changed(x, z$clean); ct <- tabulate(match(z$reason, reasons), nbins = 7L)
    dr <- !is.na(status) & status == "(8) DR"
    count_rows[[i]] <- data.frame(outcome = f, wave = w, source_variable = src, mapped = mapped,
      n_structural = length(x), n_source_observed = if (mapped) sum(!is.na(x)) else 0L,
      n_source_missing = if (mapped) sum(is.na(x)) else 0L, n_mapping_gap = ct[1],
      n_practice_failure_project_excluded = ct[3], n_documented_source_special = ct[4], n_documented_invalid = ct[5],
      n_unresolved_score_value = ct[6], n_eligible_current_rules = ct[7], n_clean_nonmissing = sum(!is.na(z$clean)),
      n_nonfinite = sum(!is.na(x) & !is.finite(x)), n_values_changed = sum(changed_mask),
      n_status_DR = sum(dr), n_status_DR_with_source_score = if (mapped) sum(dr & !is.na(x)) else 0L)
    add_rule <- function(id, kind, op, val, action, basis, ev, matches, reason = NULL,
        state = "supported", impl = "active", issues = "not_applicable", limitation = "not_applicable") {
      rule_rows[[length(rule_rows) + 1L]] <<- data.frame(rule_id = id, outcome = f, wave = w,
        source_variable = src, language = r$language, score_type = r$score_type, rule_kind = kind,
        operator = op, rule_value = as.double(val), action = action, decision_basis = basis,
        implementation_status = impl, evidence_status = state, evidence_ids = ev, issue_ids = issues,
        n_matched = as.integer(sum(matches)), n_changed = as.integer(sum(matches & changed_mask)), limitation = limitation)
    }
    add_rule("mapping", "mapping_availability", "mapping_absent", NA, "clean_NA_eligible_FALSE",
      "structural_handling", mapping_refs[i], z$reason == reasons[1])
    add_rule("source_missing", "source_missing", "is_na", NA, "clean_NA_eligible_FALSE",
      "source_missing_handling", if (mapped) paste0("S_MISS_", src) else mapping_refs[i], z$reason == reasons[2],
      limitation = "Collapsed source NA reasons cannot be reconstructed from aggregate codebook frequencies.")
    if (mapped) for (code in missing_codes(src)) add_rule(paste0("missing_", abs(code)), "documented_missing_code", "==", code,
      "clean_NA_eligible_FALSE", "release_missing_code", paste0("S_MISS_", src), !is.na(x) & x == code)
    if (src %in% practice_sources) add_rule("practice_failure", "practice_failure_project_exclusion", "==", -7,
      "clean_NA_eligible_FALSE", "project_analytical_choice", paste0("C_", w, "_PRACTICE;S_MISS_", src), z$reason == reasons[3],
      limitation = "Project analytical exclusion based on documented practice failure; not release-mandated. Potential selection against lower-achieving children.")
    if (src %in% rhyming_sources) add_rule("rhyming_maximum", "documented_score_maximum", ">", 17,
      "flag_and_clean_NA_eligible_FALSE_never_cap", "study_documented_maximum", paste0("G_MAX;D_LABEL_", src), z$reason == reasons[5],
      limitation = "No lower-bound or integer-only rule; finite above-maximum values only.")
    add_rule("unresolved_score", "unresolved_score_evidence", "nonmissing_nonfinite_or_unregistered_label", NA,
      "preserve_value_eligibility_NA", "deferred_interpretation", if (mapped) paste0("D_LABEL_", src) else mapping_refs[i], z$reason == reasons[6],
      state = "unresolved", issues = "S07_SCORE_INTERPRETATION", limitation = "No heuristic based on signs, fractions, or status.")
    add_rule("retention", "retention", "no_prior_rule_matched", NA, "preserve_value_eligible_TRUE",
      "limited_descriptive_rules", if (mapped) paste0("D_LABEL_", src) else mapping_refs[i], z$reason == reasons[7],
      limitation = "Not full psychometric validation or final analytic-sample membership.")
    add_rule("status_context_only", "status_documentation", "status_DR", NA, "preserve_status_no_score_effect",
      "deferred_interpretation", "C_DR;S_DR", dr, state = "unresolved", impl = "context_only", issues = "S07_DR")
    # Context-only status rules must have no numerical change attribution.
    rule_rows[[length(rule_rows)]]$n_changed <- 0L
    if (grepl("^woodcock_munoz", f)) add_rule("WM_interpretation_deferred", "metric_history", "not_applicable", NA,
      "retain_release_metric_no_conversion", "deferred_interpretation", "G_WM_TABLE", rep(FALSE, length(x)),
      state = "unresolved", impl = "deferred", issues = "S07_WM_GUIDE")
    for (view in c("released_numeric_diagnostic", "current_rule_eligible")) {
      take <- if (view == "released_numeric_diagnostic") !is.na(x) else !is.na(z$eligible) & z$eligible
      y <- if (view == "released_numeric_diagnostic") x[take] else z$clean[take]
      numeric_rows[[length(numeric_rows) + 1L]] <- cbind(data.frame(outcome = f, wave = w,
        language = r$language, score_type = r$score_type, view = view, denominator_structural = length(x),
        n_summarized = sum(take), n_practice_failure_in_view = sum(take & z$reason == reasons[3]),
        n_source_special_in_view = sum(take & z$reason == reasons[4]), n_unresolved_score_in_view = sum(take & z$reason == reasons[6]),
        n_nonfinite = sum(!is.na(y) & !is.finite(y))), numeric_summary(y, mapped))
    }
    si <- match(as.character(status), status_levels); si[is.na(status)] <- 9L
    for (s in 1:9) for (reason in reasons) {
      n <- sum(si == s & z$reason == reason); den <- sum(si == s)
      status_rows[[length(status_rows) + 1L]] <- data.frame(outcome = f, wave = w, status_order = s,
        status_kind = if (s == 9L) "source_missing" else "released_value",
        status_label = if (s == 9L) "" else status_levels[s], cleaning_reason = reason, n = n,
        denominator_structural = length(x), denominator_status = den, pct_structural = pct(n, length(x)), pct_within_status = pct(n, den))
    }
  }
  R <- bind(rule_rows); C <- bind(count_rows); N <- bind(numeric_rows); S <- bind(status_rows)
  pairs <- list()
  for (f in outcomes) for (g in 1:2) {
    ww <- waves[(2L * g - 1L):(2L * g)]
    ci <- match(paste(f, ww), paste(contract$outcome, contract$wave)); zz <- results[ci]
    mm <- nzchar(contract$source_variable[ci]); complete <- all(mm)
    xx <- lapply(ww, function(w) panel[[f]][panel$wave == w])
    observed <- lapply(xx, function(x) !is.na(x)); eligible <- lapply(zz, function(z) !is.na(z$eligible) & z$eligible)
    # Marginals survive a missing opposite mapping; joint counts stay undefined.
    joint <- function(a, b) if (complete) as.integer(c(sum(a & b), sum(a & !b), sum(!a & b), sum(!a & !b))) else rep(NA_integer_, 4)
    so <- joint(observed[[1]], observed[[2]]); el <- joint(eligible[[1]], eligible[[2]])
    unresolved <- vapply(zz, function(z) any(z$reason == reasons[6]), logical(1))
    pairs[[length(pairs) + 1L]] <- data.frame(outcome = f, grade = c("Pre-K", "Kindergarten")[g],
      fall_wave = ww[1], spring_wave = ww[2], fall_mapped = mm[1], spring_mapped = mm[2], n_children = nrow(wide),
      n_source_fall = if (mm[1]) sum(observed[[1]]) else NA_integer_,
      n_source_spring = if (mm[2]) sum(observed[[2]]) else NA_integer_,
      n_source_both = so[1], n_source_fall_only = so[2], n_source_spring_only = so[3], n_source_neither = so[4],
      n_eligible_fall = if (mm[1]) sum(eligible[[1]]) else NA_integer_,
      n_eligible_spring = if (mm[2]) sum(eligible[[2]]) else NA_integer_,
      n_eligible_both = el[1], n_eligible_fall_only = el[2], n_eligible_spring_only = el[3], n_eligible_neither = el[4],
      n_pairs_lost = if (complete) sum(observed[[1]] & observed[[2]] & !(eligible[[1]] & eligible[[2]])) else NA_integer_,
      n_pairs_with_unresolved_scores = if (complete) sum(zz[[1]]$reason == reasons[6] | zz[[2]]$reason == reasons[6]) else NA_integer_,
      comparability_status = if (complete) "not_established_this_stage" else "mapping_gap",
      comparability_evidence_ids = paste(c("PROJECT_COMPARABILITY_DEFERRAL", if (!complete) provenance_refs[ci]), collapse = ";"),
      difference_status = "not_computed_this_stage")
  }
  P <- bind(pairs)

  # Contracts and independent reconciliation against Stage 05 and source vectors.
  hard("output_dimensions", identical(dim(cleaned), c(4060L, 65L)), "4060 | 65", dim(cleaned))
  hard("original_37_columns_exact", identical(cleaned[seq_len(37)], panel),
    detail = "Values, classes, attributes, row names, order, keys, and all original columns identical.")
  hard("append_order", identical(names(cleaned)[-(1:37)], c("assessment_status_documentation_state",
    unlist(lapply(outcomes, function(f) paste0(f, c("_clean", "_cleaning_reason", "_eligible_current_rules"))), use.names = FALSE))))
  hard("clean_column_types_and_no_attributes", all(vapply(outcomes, function(f) {
    y <- cleaned[[paste0(f, "_clean")]]
    typeof(y) == "double" && is.null(attributes(y)) &&
      typeof(cleaned[[paste0(f, "_cleaning_reason")]]) == "character" &&
      typeof(cleaned[[paste0(f, "_eligible_current_rules")]]) == "logical"
  }, logical(1))))
  totals <- c(sum(C$n_structural), sum(C$n_mapping_gap), sum(C$n_source_missing), sum(C$n_source_observed),
    sum(C$n_practice_failure_project_excluded), sum(C$n_documented_source_special), sum(C$n_documented_invalid),
    sum(C$n_unresolved_score_value), sum(C$n_eligible_current_rules), sum(C$n_values_changed))
  hard("inspected_counts", identical(totals, c(36540L, 6090L, 19180L, 11270L, 8L, 0L, 0L, 0L, 11262L, 8L)),
    c(36540L, 6090L, 19180L, 11270L, 8L, 0L, 0L, 0L, 11262L, 8L), totals)
  hard("reason_partitions", all(rowSums(C[c("n_mapping_gap", "n_source_missing", "n_practice_failure_project_excluded",
    "n_documented_source_special", "n_documented_invalid", "n_unresolved_score_value", "n_eligible_current_rules")]) == C$n_structural))
  hard("observed_and_clean_reconciliation", all(C$n_source_observed + C$n_source_missing + C$n_mapping_gap == 1015L) &&
    all(C$n_clean_nonmissing == C$n_eligible_current_rules + C$n_unresolved_score_value) &&
    all(C$n_nonfinite <= C$n_unresolved_score_value))
  ap <- C[C$outcome == outcomes[2], ]
  hard("Applied_Problems_eligible", identical(ap$n_eligible_current_rules, c(790L, 850L, 831L, 859L)),
    c(790L, 850L, 831L, 859L), ap$n_eligible_current_rules)
  ap_pair <- P[P$outcome == outcomes[2] & P$grade == "Pre-K", ]
  hard("Applied_Problems_pairs", ap_pair$n_source_both == 740L && ap_pair$n_eligible_both == 734L && ap_pair$n_pairs_lost == 6L,
    c(740L, 734L, 6L), unlist(ap_pair[c("n_source_both", "n_eligible_both", "n_pairs_lost")]))
  ap_idx <- which(contract$outcome == outcomes[2])
  changed_ids <- numeric()
  for (j in seq_along(ap_idx)) {
    i <- ap_idx[j]; idx <- which(panel$wave == waves[j]); x <- panel[[outcomes[2]]][idx]; z <- results[[i]]
    expected <- if (j <= 2) !is.na(x) & x == -7 else rep(FALSE, length(x))
    hard(paste0("exact_changes_AP_", waves[j]), identical(changed(x, z$clean), expected) &&
      all(z$reason[expected] == reasons[3]) && all(is.na(z$clean[expected])) && all(!z$eligible[expected]),
      c(7L, 1L, 0L, 0L)[j], sum(changed(x, z$clean)))
    hard(paste0("practice_status_", waves[j]), all(panel$assessment_status_released[idx][expected] == status_levels[2]))
    changed_ids <- c(changed_ids, panel$STUDY_ID[idx][expected])
  }
  hard("eight_distinct_practice_children", length(unique(changed_ids)) == 8L)
  wm <- C[C$outcome == outcomes[6] & C$wave %in% c("PF", "PS"), ]
  hard("WM_source_denominators", identical(wm$n_source_observed, c(113L, 94L)) &&
    sum(!is.na(source_data$WM25SSPF)) == 113L && sum(!is.na(source_data$WM25SSPS)) == 94L,
    c(113L, 94L), wm$n_source_observed)
  wm_stats <- N[N$outcome == outcomes[6] & N$wave %in% c("PF", "PS") & N$view == "released_numeric_diagnostic", ]
  hard("WM_released_statistics", same(wm_stats$mean, c(79.805309734513, 78.787234042553)) &&
    same(wm_stats$sd, c(14.589537840937, 15.246979140550)),
    "Release statistics only; guide equality is not asserted", c(wm_stats$mean, wm_stats$sd))
  dr_idx <- which(panel$wave == "PS" & !is.na(panel$assessment_status_released) & panel$assessment_status_released == "(8) DR")
  hard("DR_two_children_no_mapped_scores", length(dr_idx) == 2L && length(unique(panel$STUDY_ID[dr_idx])) == 2L &&
    all(is.na(as.matrix(panel[dr_idx, outcomes[1:7]]))) && all(cleaned$assessment_status_documentation_state[dr_idx] == "undefined_DR"))
  hard("status_documentation_states", identical(cleaned$assessment_status_documentation_state,
    status_documentation(panel$assessment_status_released)))

  old_numeric <- read_csv(here::here(required[5])); old_pair <- read_csv(here::here(required[6])); old_status <- read_csv(here::here(required[7]))
  for (i in seq_len(nrow(contract))) {
    r <- contract[i, ]; x <- panel[[r$outcome]][panel$wave == r$wave]; z <- results[[i]]; cc <- C[i, ]
    nn <- N[N$outcome == r$outcome & N$wave == r$wave, ]
    ss <- S[S$outcome == r$outcome & S$wave == r$wave, ]
    rr <- R[R$outcome == r$outcome & R$wave == r$wave, ]
    hard(paste0("rule_source_key_", i), all(rr$source_variable == r$source_variable) && all(rr$n_changed <= rr$n_matched))
    actionable <- rr$rule_kind %in% c("documented_missing_code", "practice_failure_project_exclusion", "documented_score_maximum")
    hard(paste0("rule_change_reconciliation_", i), sum(rr$n_changed[actionable]) == cc$n_values_changed &&
      sum(rr$n_matched[actionable]) == cc$n_practice_failure_project_excluded + cc$n_documented_source_special + cc$n_documented_invalid)
    noncontext <- !rr$rule_kind %in% c("status_documentation", "metric_history")
    hard(paste0("rule_match_partition_", i), sum(rr$n_matched[noncontext]) == 1015L)
    hard(paste0("eligibility_reason_contract_", i), identical(is.na(z$eligible), z$reason == reasons[6]) &&
      identical(!is.na(z$eligible) & z$eligible, z$reason == reasons[7]) &&
      all(is.na(z$clean[z$reason %in% reasons[1:5]])) &&
      identical(z$clean[z$reason %in% reasons[6:7]], as.double(x[z$reason %in% reasons[6:7]])))
    old <- old_numeric[old_numeric$field == r$outcome & old_numeric$period == r$wave, ]
    stat_cols <- names(numeric_summary(numeric()))[1:9]
    hard(paste0("Stage05_numeric_", i), nrow(old) == 1L && as.integer(old$n_nonmissing) == cc$n_source_observed &&
      same(csv_numbers(old[stat_cols]), as.double(unlist(nn[1, stat_cols]))))
    for (j in 1:2) {
      take <- if (j == 1) !is.na(x) else !is.na(z$eligible) & z$eligible
      yy <- if (j == 1) x[take] else z$clean[take]
      hard(paste0("summary_values_", i, "_", j), nn$n_summarized[j] == sum(take) && nn$denominator_structural[j] == 1015L &&
        identical(as.list(nn[j, c(stat_cols, "summary_status")]),
          as.list(numeric_summary(yy, nzchar(r$source_variable)))) &&
        (j == 1 || nn$n_unresolved_score_in_view[j] == 0L))
    }
    hard(paste0("status_full_grid_", i), nrow(ss) == 63L && identical(ss$status_order, rep(1:9, each = 7)) &&
      identical(ss$cleaning_reason, rep(reasons, 9)) && sum(ss$n) == 1015L && all(ss$denominator_structural == 1015L) &&
      same(ss$pct_structural, pct(ss$n, ss$denominator_structural)) && same(ss$pct_within_status, pct(ss$n, ss$denominator_status)))
    for (s in 1:9) {
      st <- panel$assessment_status_released[panel$wave == r$wave]
      in_status <- if (s == 9) is.na(st) else !is.na(st) & st == status_levels[s]
      sub <- ss[ss$status_order == s, ]
      oo <- old_status[old_status$field == r$outcome & old_status$wave == r$wave & as.integer(old_status$status_category_order) == s, ]
      hard(paste0("status_margins_", i, "_", s), sum(sub$n) == sum(in_status) &&
        sum(as.integer(oo$n_children)) == sum(in_status) && all(sub$denominator_status == sum(in_status)) &&
        (if (sum(in_status) == 0L) all(is.na(sub$pct_within_status)) else same(sum(sub$pct_within_status), 100)))
      for (k in seq_along(reasons)) hard(paste0("status_cell_", i, "_", s, "_", k),
        sub$n[k] == sum(in_status & z$reason == reasons[k]))
    }
    for (k in seq_along(reasons)) hard(paste0("status_reason_margin_", i, "_", k),
      sum(ss$n[ss$cleaning_reason == reasons[k]]) == sum(z$reason == reasons[k]))
  }
  for (i in seq_len(nrow(P))) {
    p <- P[i, ]; oo <- old_pair[old_pair$field == p$outcome & old_pair$wave_a == p$fall_wave & old_pair$wave_b == p$spring_wave, ]
    hard(paste0("Stage05_pair_", i), nrow(oo) == 1L && same(as.double(unlist(p[c("n_source_fall", "n_source_spring", "n_source_both", "n_source_fall_only", "n_source_spring_only", "n_source_neither")])),
      csv_numbers(oo[c("n_a", "n_b", "n_both", "n_a_only", "n_b_only", "n_neither")])))
    if (p$fall_mapped && p$spring_mapped) {
      hard(paste0("pair_partitions_", i), sum(unlist(p[c("n_source_both", "n_source_fall_only", "n_source_spring_only", "n_source_neither")])) == 1015L &&
        sum(unlist(p[c("n_eligible_both", "n_eligible_fall_only", "n_eligible_spring_only", "n_eligible_neither")])) == 1015L &&
        p$n_source_fall == p$n_source_both + p$n_source_fall_only && p$n_source_spring == p$n_source_both + p$n_source_spring_only &&
        p$n_eligible_fall == p$n_eligible_both + p$n_eligible_fall_only && p$n_eligible_spring == p$n_eligible_both + p$n_eligible_spring_only &&
        p$n_pairs_lost == p$n_source_both - p$n_eligible_both)
    } else hard(paste0("pair_mapping_gap_", i), all(is.na(unlist(p[c("n_source_both", "n_source_fall_only", "n_source_spring_only", "n_source_neither",
      "n_eligible_both", "n_eligible_fall_only", "n_eligible_spring_only", "n_eligible_neither", "n_pairs_lost", "n_pairs_with_unresolved_scores")]))))
  }

  # Focused synthetic boundaries. These checks do not infer new cleaning rules.
  edge <- clean_score(c(NA_real_, NaN, -99, -5, -6, -7, -1, 0.5, 16, 17, 18, Inf, -Inf), "WJ21AEPF")
  hard("edge_rhyming_boundaries", identical(edge$reason,
    c(reasons[2], reasons[2], reasons[4], reasons[4], reasons[7], reasons[7], reasons[7], reasons[7], reasons[7], reasons[7], reasons[5], reasons[6], reasons[6])) &&
    identical(edge$clean[5:10], c(-6, -7, -1, 0.5, 16, 17)) && is.na(edge$clean[11]) &&
    identical(edge$clean[12:13], c(Inf, -Inf)) && all(is.na(edge$eligible[12:13])),
    detail = "18 excluded, original input unchanged; 16 and 17 retained; no invented lower-bound or integer rules.")
  boundary_input <- c(17, 18); boundary_copy <- boundary_input
  hard("edge_original_boundary_preserved", identical(boundary_input, boundary_copy) &&
    identical(clean_score(boundary_input, "WJ21AEPS")$clean, c(17, NA_real_)))
  for (src in contract$source_variable[nzchar(contract$source_variable)]) {
    zz <- clean_score(c(missing_codes(src), -2.5), src)
    hard(paste0("edge_exact_registry_", src), all(zz$reason[seq_along(missing_codes(src))] == reasons[4]) && tail(zz$reason, 1) == reasons[7])
  }
  hard("edge_Kindergarten_minus7_no_borrowing", all(vapply(c("WJ10_SSEKF", "WJ10_SSEKS"), function(src) {
    zz <- clean_score(-7, src); identical(zz$clean, -7) && identical(zz$reason, reasons[7]) && isTRUE(zz$eligible)
  }, logical(1))))
  unknown <- clean_score(c(-42, 4), "PPVTEPF", c("Unregistered special" = -42))
  hard("edge_unregistered_labeled_special", identical(unknown$clean, c(-42, 4)) &&
    identical(unknown$reason, c(reasons[6], reasons[7])) && identical(unknown$eligible, c(NA, TRUE)))
  under_status <- function(x, src, status) list(score = clean_score(x, src), documentation = status_documentation(status))
  a <- under_status(80, "WJ10_SSEPS", "(8) DR"); b <- under_status(80, "WJ10_SSEPS", status_levels[2])
  hard("edge_finite_DR_same_score_and_eligibility", identical(a$score, b$score) && isTRUE(a$score$eligible) &&
    a$documentation == "undefined_DR" && b$documentation == "documented_label_only")
  hard("edge_all_statuses_no_score_effect", all(vapply(c(status_levels, NA_character_), function(s)
    identical(under_status(4.5, "PPVTEPF", s)$score, clean_score(4.5, "PPVTEPF")), logical(1))))
  hard("edge_empty_and_singleton", numeric_summary(numeric())$summary_status == "empty_group" &&
    all(is.na(numeric_summary(numeric())[1:9])) && numeric_summary(4)$summary_status == "singleton" &&
    is.na(numeric_summary(4)$sd) && numeric_summary(4)$mean == 4)
  hard("edge_nonfinite_and_missing", numeric_summary(c(Inf, 3))$summary_status == "nonfinite_present" &&
    all(is.na(numeric_summary(c(Inf, 3))[1:9])) && numeric_summary(c(NA_real_, NaN))$summary_status == "empty_group")
  hard("edge_zero_denominators", all(is.na(pct(c(0, 1), c(0, 0)))) && pct(0, 3) == 0)
  hard("edge_mapping_precedence", identical(clean_score(c(18, Inf, -7), "")$reason, rep(reasons[1], 3)) &&
    all(is.na(clean_score(c(18, Inf, -7), "")$clean)))
  hard("row_counts", nrow(C) == 36L && nrow(N) == 72L && nrow(P) == 18L && nrow(S) == 2268L)
  hard("evidence_enums", all(E$evidence_status %in% c("supported", "contradicted", "unresolved")) &&
    all(E$notebooklm_claim_status %in% c("verified", "incorrect_for_local_document", "unresolved", "not_applicable")))
  refs <- unique(unlist(strsplit(R$evidence_ids, ";", fixed = TRUE)))
  hard("rule_evidence_references", all(refs %in% E$evidence_id))
  pair_refs <- unique(unlist(strsplit(P$comparability_evidence_ids, ";", fixed = TRUE)))
  hard("pair_evidence_references", all(pair_refs %in% E$evidence_id))
  hard("mapping_evidence_scope", identical(R$evidence_ids[R$rule_id == "mapping"], mapping_refs) &&
    all(R$issue_ids[R$rule_id == "mapping"] == "not_applicable"))
  gap_rules <- R[R$source_variable == "" & R$rule_id %in% c("mapping", "source_missing", "unresolved_score", "retention"), ]
  gap_contract <- match(paste(gap_rules$outcome, gap_rules$wave), paste(contract$outcome, contract$wave))
  hard("mapping_gap_reference_scope", identical(gap_rules$evidence_ids, mapping_refs[gap_contract]))
  hard("Q09_not_generic_provenance", !any(c("G_Q09", "I_Q09") %in% c(refs, pair_refs)) &&
    !any(grepl("(^|;)Q09(;|$)", R$issue_ids)) &&
    setequal(E$evidence_id[E$issue_ids == "Q09"], c("G_Q09", "I_Q09")))
  hard("comparability_project_decision", all(vapply(seq_len(nrow(P)), function(i) {
    p <- P[i, ]; ci <- match(paste(p$outcome, c(p$fall_wave, p$spring_wave)), paste(contract$outcome, contract$wave))
    identical(p$comparability_evidence_ids, paste(c("PROJECT_COMPARABILITY_DEFERRAL",
      if (!(p$fall_mapped && p$spring_mapped)) provenance_refs[ci]), collapse = ";"))
  }, logical(1))) && E$source_tier[E$evidence_id == "PROJECT_COMPARABILITY_DEFERRAL"] == "project_decision")
  hard("reference_resource_hashes", all(vapply(seq_len(nrow(E)), function(i)
    unname(tools::md5sum(here::here(E$resource_path[i]))) == E$resource_md5[i], logical(1))))
  hard("no_NotebookLM_primary_evidence", !any(grepl("NotebookLM", E$resource_path)))
  tables <- list(evidence = E, rules = R, counts = C, numeric_summary = N, status_frequencies = S, pair_support = P)
  for (nm in names(tables)) {
    hard(paste0("schema_key_", nm), identical(names(tables[[nm]]), schemas[[nm]]) && !anyDuplicated(tables[[nm]][keys[[nm]]]))
  }
  # Nine pages, four occasion panels per outcome, using separate ECDFs.
  pdf_path <- file.path(outdir, basename(destinations[8]))
  draw_pdf <- function() {
    grDevices::pdf(pdf_path, width = 11, height = 8.5, onefile = TRUE, paper = "special", compress = FALSE,
      title = "Stage 07: released and current-rule-eligible outcome distributions", useDingbats = FALSE, useKerning = FALSE)
    on.exit(grDevices::dev.off())
    for (j in seq_along(outcomes)) {
      par(mfrow = c(2, 2), mar = c(4.2, 4.2, 3.5, 1.2), oma = c(3.7, 0.3, 4, 0.3), mgp = c(2.5, .7, 0), cex = .9)
      for (k in 1:4) {
        i <- (j - 1L) * 4L + k; r <- contract[i, ]; x <- panel[[r$outcome]][panel$wave == r$wave]; z <- results[[i]]
        take <- !is.na(z$eligible) & z$eligible; a <- x[!is.na(x) & is.finite(x)]; b <- z$clean[take]
        all_values <- c(a, b); range_x <- if (length(all_values)) range(all_values) else c(0, 1)
        if (diff(range_x) == 0) range_x <- range_x + c(-.5, .5)
        plot(NA_real_, NA_real_, xlim = range_x, ylim = c(0, 1), xlab = r$score_type,
          ylab = "Cumulative proportion", main = paste0(wave_labels[k], " (", waves[k], ")"), yaxs = "i")
        grid(col = "#E7E9ED")
        if (!nzchar(r$source_variable)) text(mean(range_x), .5, "No approved mapping", cex = 1.15) else {
          if (length(a)) lines(ecdf(a), do.points = FALSE, verticals = TRUE, col = "#56677B", lwd = 2.5)
          if (length(b)) lines(ecdf(b), do.points = FALSE, verticals = TRUE, col = "#007E87", lwd = 1.5, lty = 2)
          if (!length(a) && !length(b)) text(mean(range_x), .5, "Empty groups: no numerical values")
          if (!length(b) && length(a)) text(mean(range_x), .5, "Eligible group empty")
        }
        mtext(paste0(if (nzchar(r$source_variable)) r$source_variable else "Mapping gap", "; structural N=1015"), side = 3, line = .4, cex = .8)
        legend("bottomright", legend = c(paste0("Released diagnostic n=", length(a)), paste0("Current-rule eligible n=", length(b))),
          col = c("#56677B", "#007E87"), lty = c(1, 2), lwd = c(2.5, 1.5), bty = "n", cex = .78)
        mtext(paste0("Practice codes=", sum(z$reason == reasons[3]), "; other special=", sum(z$reason == reasons[4]),
          "; above max=", sum(z$reason == reasons[5]), "; unresolved=", sum(z$reason == reasons[6])), side = 1, line = 3.1, cex = .68)
      }
      title <- gsub("_", " ", outcomes[j], fixed = TRUE)
      mtext(paste(strwrap(title, width = 78), collapse = "\n"), outer = TRUE, side = 3, line = 1.1, cex = 1.05, font = 2)
      mtext(paste0("Page ", j, " of 9 | Unweighted | Released diagnostic can include practice-failure codes"), outer = TRUE, side = 1, line = 1.5, cex = .85)
      mtext("Eligibility covers this stage's limited descriptive rules; no score differences or learning gains.", outer = TRUE, side = 1, line = .2, cex = .8)
    }
  }
  draw_pdf()
  pdf_text <- readLines(pdf_path, warn = FALSE, encoding = "bytes")
  page_count <- sum(grepl("/Type /Page[[:space:]]", pdf_text, useBytes = TRUE))
  hard("PDF_nine_pages", page_count == 9L, 9L, page_count)
  hard("PDF_content_structure", sum(grepl("structural N=1015", pdf_text, fixed = TRUE, useBytes = TRUE)) == 36L &&
    sum(grepl("No approved mapping", pdf_text, fixed = TRUE, useBytes = TRUE)) == 6L)
  for (nm in names(tables)) {
    path <- file.path(outdir, paste0("outcome_cleaning_", nm, ".csv"))
    write_csv(tables[[nm]], path)
    hard(paste0("CSV_readback_", nm), check_csv(tables[[nm]], path))
  }
  saveRDS(cleaned, file.path(outdir, basename(destinations[1])), version = 3)
  hard("RDS_readback_exact", identical(readRDS(file.path(outdir, basename(destinations[1]))), cleaned))
  hard("protected_files_unchanged", identical(protected_paths(), paths_before) && identical(hashes(paths_before), before),
    detail = paste(length(paths_before), "protected source, code, documentation, data, and existing artifact files hashed before/after."))
  hard("destinations_ignored", all(ignored))
  hard("checks_schema_unique", identical(names(checks), schemas$checks) && !anyDuplicated(checks$check_id))
  write_csv(checks, file.path(outdir, basename(destinations[9])))
  stopifnot(check_csv(checks, file.path(outdir, basename(destinations[9]))))

  practice_table <- vapply(1:2, function(i) {
    r <- ap[i, ]
    sprintf("| %s | %d | %d | %d | %.8f%% | %.8f%% |", r$wave, r$n_structural, r$n_source_observed,
      r$n_practice_failure_project_excluded, pct(r$n_practice_failure_project_excluded, r$n_structural),
      pct(r$n_practice_failure_project_excluded, r$n_source_observed))
  }, character(1))
  review <- c("# Stage 07: documented outcome cleaning review", "",
    "This is partial, unweighted descriptive cleaning. Eligible under current rules means suitable for this stage's limited descriptive summaries; it is not full psychometric validation or membership in an eventual analytic sample.", "",
    "## Inputs, scope, and decisions", "",
    paste0("Git branch: `", system2("git", c("branch", "--show-current"), stdout = TRUE), "`. HEAD: `",
      system2("git", c("rev-parse", "HEAD"), stdout = TRUE), "`. No staging, commit, or push is performed."),
    "Only code/revision/07_clean_outcomes_describe.R is an implementation change. No upstream pipeline is sourced. Data/processed outputs are research data and remain ignored. No child-level CSV is exported.",
    "The 4,060 x 65 output preserves all original 37 columns exactly, including values, classes, attributes, row order, identifiers, and wave keys. It adds the status-documentation state and three fields per outcome in the reviewed order. Each occasion retains all 1,015 children.",
    "The exact reviewed source registry is checked against each source's setup replacement and dictionary entry. -99 applies to every mapped source; -5 and -6 only to the reviewed lists. Source NA reasons remain unavailable. Cleaned copies have no inherited special-code attributes; originals are preserved.",
    "WJ10_SSEPF/PS == -7 is a project analytical exclusion based on documented practice failure, not a release-mandated correction. Its reason is practice_failure_project_exclusion. The release's replacement rules retain -7; the codebook valid-case totals include it. No zero, floor, or alternate score is substituted. The Kindergarten sources receive no borrowed -7 meaning or rule.",
    "The documented rhyming maximum is 17 (guide physical PDF p.48, printed p.12), applied only to the four reviewed WJIII Test 21A raw scores. Finite values above 17 are flagged and excluded, never capped. No lower bound or integer-only rule is imposed. Current maxima are 15/15/17/17.", "",
    "## Cleaning counts and denominators", "",
    "36,540 = 6,090 mapping gaps + 19,180 source missing + 8 project practice-failure exclusions + 0 other source specials + 0 above-maximum invalid values + 0 unresolved observed scores + 11,262 eligible values.",
    "Exactly eight numerical cells change: seven PF and one PS Applied Problems -7 values, belonging to eight distinct children. All eight have Full Assessment (English) status. Recoding reduces numerical-score availability; no children or structural rows are removed.", "",
    "| Wave | All children | Source observed | Practice excluded | % all children | % source observed |",
    "|---|---:|---:|---:|---:|---:|", practice_table, "",
    "Applied Problems availability changes PF 797 -> 790 and PS 851 -> 850. KF/KS remain 831/859. Pre-K Fall-Spring pairs change 740 -> 734 (six lost pairs). Paired support is availability only; no differences or learning gains are computed.",
    "Practice-failure exclusion changes the score-observed population and may disproportionately omit lower-achieving children. Neither random selection nor the size of that selection effect is established. Retained scores cannot be assumed to represent all children. The original values and identifiable reasons support later study of this missing-score mechanism.", "",
    "## Status and unresolved score evidence", "",
    "DR is preserved without expansion: two distinct PS children, with zero observed values across their seven mapped PS outcomes. Repeated outcome-level DR counts must not be summed as child counts. DR meaning remains undefined (codebook PDF p.80 / printed p.76, location 298-300; setup lines 210-216). DR alone, partial/absent/refused status, and status missingness change neither a numerical score nor its eligibility.",
    "Nonmissing nonfinite or unregistered labeled special values are unresolved score evidence: preserve their released values and assign eligibility NA. No current observed values fall into this category. Unresolved values are excluded from eligible summaries. Source missingness and mapping gaps instead receive FALSE, and remain separately identifiable.", "",
    "## Woodcock-Munoz and documentary discrepancies", "",
    "Release labels explicitly say STANDARD SCORE for WM25SSPF/PS; the W-score fields remain separate. Independent source denominators are PF 113 and PS 94. Actual release mean/SD: PF 79.805309734513 / 14.589537840937; PS 78.787234042553 / 15.246979140550. Codebook rounded summaries agree (PF 79.81 / 14.59; PS 78.79 / 15.25).",
    "The guide's Summary of analysis variables - CHILD OUTCOMES (Pre-K), Spanish Assessment, Woodcock Munoz row names wm25sspf/wm25ssps (PDF p.54 / printed p.18): PF N=113 mean=5.77 SD=3.35; PS N=94 mean=7.66 SD=3.39. It does not call the row raw scores. The metric/population/version/scoring-history discrepancy remains unexplained. Equal marginal Ns do not establish identical populations. No conversion is inferred and guide equality is never an acceptance criterion.",
    "The evidence ledger corrects the NotebookLM locators and claims: guide PDF p.21 is printed p.17 (references), and PDF p.30 is printed p.26 (observational reliability); rhyming maximum is at PDF p.48/printed p.12 and the Pre-K table at PDF p.54/printed p.18. WM25SSPF heading is at C PDF p.49/printed p.45 with statistics p.50/46; WM25SSPS heading p.75/71 and statistics p.77/73, not PDF p.94. WJ10_SSEPF location is 196-198, not adjacent W-score 193-195. Pre-K rhyming maxima are 15/15, not 14/13. N=110/92 and guide SD=3.65/3.49 are incorrect for these local rows; the origin of those numbers is unresolved.",
    "The claimed adjacent English W-score missing-value contrast is also incorrect: WJ10_WEPF has -99/-5 missing declaration and its replacement retains -7. The preceding -99/-8/-7/-5 declaration belongs to OWLSEPF. No English W-score fields are added.", "",
    "## F01 provenance correction", "",
    "Confirmed against the pre-correction script and generated tables: G_Q09 was attached to all 36 mapping-rule rows, 18 additional mapping-gap fallback rows, and all 18 pair-support rows; six mapping-gap rules also inherited Q09 issue IDs. The guide passage and reviewed Q09 register concern the separately described Kindergarten English PPVT for Spanish-battery children and cross-language combination. They do not establish every field-occasion mapping, intentional gap, or general longitudinal comparability deferral.",
    "Actual mapping references now identify the exact Stage 04 provenance record and the approved crosswalk source/occasion record. Intentional gaps reference their explicit Stage 04 gap record and the crosswalk's limited approved coverage for that construct; they do not imply noncollection. G_Q09 and I_Q09 remain confined to the specific unresolved language question in the evidence ledger. Generic mapping rules and gap fallbacks carry no Q09 issue ID.",
    "General comparability deferral is explicitly recorded as PROJECT_COMPARABILITY_DEFERRAL, a project scope decision localized to this script, with issue ID S07_COMPARABILITY_DEFERRED. Every pair cites that decision; gap pairs additionally cite the relevant Stage 04 records. This records a deferred assessment, without asserting psychometric comparability or noncomparability. Reference checks cover rule and pair resolution, mapping/gap scope, Q09 scope, project-decision provenance, and resource hashes. Cleaning rules, source mappings, eligibility definitions, and all numerical calculations are unchanged.", "",
    "## Artifacts and validation", "",
    paste0("- ", destinations), "",
    "Counts have 36 rows, summaries 72 rows (released_numeric_diagnostic and current_rule_eligible), status frequencies 2,268 rows (36 x 9 statuses x 7 reasons, including zeros), pair support 18 rows. Mapping gaps retain mapped marginals and undefined joint counts. Statistics use sample SD and R type-7 quantiles. CSVs serialize undefined numbers as NA, doubles with 17 significant digits, absent mappings as empty source names, and character inapplicability as not_applicable.",
    "Every CSV is read back for exact schema/order/keys/labels/flags/counts and lossless numeric values. Checks reconcile all reason partitions, matched rules, changes, status cells and margins, pair partitions/losses, Stage 05 numeric summaries and support definitions, source-wide-panel lineage, and the 65-column contract. Focused checks cover empty groups, singleton SD, zero denominators, missing/nonfinite values, 16/17/18 boundaries, negative/fractional scores, exact source codes, DR score invariance, Kindergarten -7 scope, and unregistered labeled specials.",
    "The default entry point launches two independent Rscript --vanilla workers into temporary directories. It requires byte-identical seven CSVs and identical deserialized RDS objects before publication. PDF checks cover nine pages, four occasion panels per page, six labeled mapping-gap panels, counts and special-code annotations; PDF metadata bytes are not compared.",
    paste0("Worker checks: ", nrow(checks), " hard checks, all pass. Protected file count: ", length(paths_before), "."),
    "All protected inputs and existing artifacts are MD5-checked before and after; protected filenames are also checked. All ten destinations pass git check-ignore. No upstream records, data, code, or reports are rewritten.", "",
    "## Commands", "", "```powershell",
    "git rev-parse --show-toplevel", "git status --short --branch", "git branch --show-current", "git rev-parse HEAD",
    "$env:LC_ALL = 'English_United States.utf8'",
    "$env:GIT_CONFIG_COUNT = '1'", "$env:GIT_CONFIG_KEY_0 = 'safe.directory'",
    "$env:GIT_CONFIG_VALUE_0 = (Get-Location).Path.Replace('\\','/')",
    "& 'C:\\Program Files\\R\\R-4.6.1\\bin\\Rscript.exe' --vanilla code/revision/07_clean_outcomes_describe.R",
    "git diff --check", "git status --short --branch", "```", "",
    "The process exits nonzero and does not publish draft products if a required input, evidence hash, lineage, schema, count, or active rule check fails. Final review records reproducibility, ignored-status and whitespace checks only after they pass.", "",
    "The process-local safe.directory setting scopes Git trust to this verified checkout; no global Git configuration is changed. Earlier execution without it stopped at Git's ownership check, including an outside-sandbox retry. Development checks also caught a row-name-only summary-check mismatch, PDF page-syntax/kerning assumptions, and literal-NA parsing warnings; these were corrected in the checker/serializer without changing approved cleaning rules. The successful final R runs emit no warnings.", "",
    "## Independent implementation-time audit and visual review (2026-10-17)", "",
    "The original implementation-time Python/pypdf audit located all 84 original ledger passages in the hash-verified PDFs, setup, and dictionary. F01 adds localized project crosswalk, Stage 04 provenance, Q09-register and project-decision records, with separate reference validation. The original audit independently reconciled reason totals, the eight changes, Applied Problems counts and paired support, CSV sizes, and passing check statuses. A separate initial filesystem baseline preserved all 86 files in its scope; the R audit additionally covers tracked renv infrastructure and records its own complete protected-file manifest below.",
    "Bundled Poppler pdfinfo confirmed nine letter-landscape pages. pdftoppm -scale-to 1500 -png rendered all nine pages. Every page was visually inspected for clipping, label readability, empty groups, mapping gaps, legends, and annotations; no visual defects were found. Six mapping gaps are explicitly labeled; no mapped group is empty on these inputs. All nine final render PNGs were byte-identical to the inspected renders. This paragraph records the implementation-time visual review; repeat visual inspection after changing the script or approved inputs.",
    "Poppler returned exit 0 with font notices: No display font for 'Symbol' and No display font for 'ArialUnicode'. The rendered labels were readable and complete. R's final generation/verification runs emitted no warnings. Early read-only tool probes also found no PyMuPDF module or bundled pdftotext executable; pypdf extraction and bundled Poppler rendering completed the checks.",
    "Exact independent audit/render commands used in this execution:", "```powershell",
    "$env:PYTHONIOENCODING = 'utf-8'",
    "& 'C:/Users/mvbas/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' 'C:/Users/mvbas/.codex/visualizations/2026/10/17/01a14abf-3ead-7513-b0b7-1ce4f6639a87/stage07_external_audit.py'",
    "& 'C:/Users/mvbas/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/poppler/Library/bin/pdfinfo.exe' output/figures/outcome_cleaning_distributions.pdf",
    "& 'C:/Users/mvbas/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/poppler/Library/bin/pdftoppm.exe' -scale-to 1500 -png output/figures/outcome_cleaning_distributions.pdf 'C:/Users/mvbas/.codex/visualizations/2026/10/17/01a14abf-3ead-7513-b0b7-1ce4f6639a87/stage07_final'",
    "git diff --cached --exit-code", "git ls-files --others --exclude-standard", "```",
    "The independent audit and cached diff returned exit 0. The only unignored added file was the Stage 07 script. All ten exact destinations passed git check-ignore -v; final status is recorded below.", "",
    "## Unresolved endpoint", "",
    "S07_DR: undefined DR meaning and score-validity implications; no status-only consequence implemented.",
    "S07_BOUNDS: unsupported theoretical score bounds, rhyming lower-bound/integer rules, and detailed norming conventions; no heuristic added.",
    "S07_WM_GUIDE: guide metric/population/history discrepancy; released metrics retained separately without conversion.",
    "S07_SCORE_INTERPRETATION: any future unregistered labeled/nonfinite scores require score evidence; currently zero observed.",
    "Collapsed source missing reasons and existing Q09 mapping/comparability questions remain unresolved. No final sample, exposure, substantive regression, weighting, preferred specification, longitudinal growth interpretation, or inference procedure is produced. Stage 06 is not reopened.", "",
    "## Protected-file MD5 audit", "", "| Relative path | MD5 before = after |", "|---|---|",
    paste0("| ", names(before), " | ", unname(before), " |"))
  writeLines(enc2utf8(review), file.path(outdir, basename(destinations[10])), useBytes = TRUE)
  message("PASS: Stage 07 worker: ", nrow(checks), " checks; 4060 x 65; eight numerical changes.")
}

args <- commandArgs(trailingOnly = TRUE)
if (length(args) && args[1] == "--worker") {
  stopifnot(length(args) == 2L, dir.exists(args[2]))
  run_stage(args[2])
} else {
  if (length(args)) stop("Unknown arguments.")
  before_paths <- protected_paths(); before_hash <- hashes(before_paths)
  staging <- tempfile("outcome_cleaning_"); dir.create(staging)
  # tempdir lives outside the repository; cleanup is limited to this known folder.
  on.exit_cleanup <- function() unlink(staging, recursive = TRUE)
  worker_dirs <- file.path(staging, c("run1", "run2")); invisible(lapply(worker_dirs, dir.create))
  rscript <- file.path(R.home("bin"), "Rscript.exe")
  if (!file.exists(rscript)) rscript <- file.path(R.home("bin"), "Rscript")
  for (i in 1:2) {
    log <- file.path(staging, paste0("run", i, ".log"))
    status <- system2(rscript, c("--vanilla", shQuote(here::here(script_path)), "--worker", shQuote(worker_dirs[i])), stdout = log, stderr = log)
    if (status != 0L) stop(paste(readLines(log, warn = FALSE), collapse = "\n"))
    message(paste(readLines(log, warn = FALSE), collapse = "\n"))
  }
  files1 <- file.path(worker_dirs[1], basename(destinations)); files2 <- file.path(worker_dirs[2], basename(destinations))
  csv <- grepl("[.]csv$", destinations)
  stopifnot(all(file.exists(files1)), all(file.exists(files2)),
    identical(unname(tools::md5sum(files1[csv])), unname(tools::md5sum(files2[csv]))),
    identical(readRDS(files1[1]), readRDS(files2[1])))
  # With uncompressed R PDFs, compare page/content text while ignoring metadata.
  pdf_content <- function(p) {
    lines <- readLines(p, warn = FALSE, encoding = "bytes")
    lines[!grepl("^/CreationDate|^/ModDate", lines, useBytes = TRUE)]
  }
  stopifnot(identical(pdf_content(files1[8]), pdf_content(files2[8])))
  ck <- read.csv(files1[9], colClasses = "character", check.names = FALSE, na.strings = character())
  add_final_check <- function(id, expected, observed, detail = "") {
    ck <<- rbind(ck, data.frame(check_id = id, severity = "hard", expected = expected, observed = observed, status = "pass", detail = detail))
  }
  add_final_check("fresh_process_CSV_reproducibility", "7 byte-identical CSVs", "7 byte-identical CSVs")
  add_final_check("fresh_process_RDS_equivalence", "identical objects", "identical objects", "Includes original attributes and appended fields.")
  add_final_check("fresh_process_PDF_content", "equivalent pages/content", "equivalent pages/content", "Creation/modification timestamps excluded; no metadata-byte requirement.")
  stopifnot(identical(protected_paths(), before_paths), identical(hashes(before_paths), before_hash))
  add_final_check("parent_protected_files_unchanged", as.character(length(before_paths)), as.character(length(before_paths)))
  diff_check <- system2("git", c("diff", "--check"), stdout = TRUE, stderr = TRUE)
  stopifnot(is.null(attr(diff_check, "status")))
  # git diff ignores this intentionally untracked script; check its whitespace too.
  script_lines <- readLines(here::here(script_path), warn = FALSE)
  stopifnot(!any(grepl("[ \t]+$", script_lines)), !any(grepl("^(<<<<<<<|=======|>>>>>>>)", script_lines)))
  add_final_check("git_diff_check_and_script_whitespace", "exit 0 and clean untracked script", "exit 0 and clean untracked script")
  stopifnot(all(ignored), identical(names(ck), schemas$checks), !anyDuplicated(ck$check_id), all(ck$status == "pass"))
  write_csv(ck, files1[9]); stopifnot(check_csv(ck, files1[9]))
  review <- readLines(files1[10], warn = FALSE, encoding = "UTF-8")
  review <- c(review, "", "## Completed fresh-process verification", "",
    "PASS: two Rscript --vanilla worker processes; seven byte-identical CSVs, identical deserialized RDS objects, equivalent PDF page/content streams excluding timestamps. All protected hashes preserved. git diff --check exited 0; untracked-script whitespace and conflict-marker checks passed. All ten outputs ignored.",
    paste0("Final verification table: ", nrow(ck), " passing hard checks. CSV checks table also read back successfully."),
    "", "Final Git status:", "```text", system2("git", c("status", "--short", "--branch"), stdout = TRUE), "```")
  writeLines(enc2utf8(review), files1[10], useBytes = TRUE)
  # All substantive/stopping checks precede publication to the approved destinations.
  stopifnot(all(file.copy(files1, here::here(destinations), overwrite = TRUE)))
  stopifnot(identical(unname(tools::md5sum(files1)), unname(tools::md5sum(here::here(destinations)))),
    identical(hashes(before_paths), before_hash), identical(protected_paths(), before_paths))
  on.exit_cleanup()
  message("PASS: ten ignored outputs published; ", nrow(ck), " passing checks; no staging, commit, or push.")
}
