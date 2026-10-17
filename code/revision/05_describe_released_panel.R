# Released-panel descriptions only. Run from the project root in a fresh session:
# Rscript --vanilla code/revision/05_describe_released_panel.R
# Windows: set LC_ALL=English_United States.utf8 before starting Rscript.
# No construction script is sourced; inputs and upstream reports are read-only.
project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
git_root_raw <- system2("git", c("rev-parse", "--show-toplevel"), stdout = TRUE, stderr = TRUE)
if (!is.null(attr(git_root_raw, "status"))) stop("Unable to determine Git root.")
git_root <- normalizePath(git_root_raw[[1]], winslash = "/", mustWork = TRUE)
if (!identical(project_start, git_root) || basename(git_root) != "ICPSR_04283") {
  stop("Run from the ICPSR_04283 Git root.")
}
Sys.setenv(RENV_PATHS_ROOT = file.path(project_start, "renv", "local"),
           RENV_CONFIG_SANDBOX_ENABLED = "FALSE", RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
source(file.path(project_start, "renv", "activate.R"))
suppressPackageStartupMessages(library(here))
stopifnot(identical(normalizePath(here::here(), winslash = "/"), project_start))

table_names <- c("field_support", "numeric_summary", "category_frequencies", "assessment_patterns",
                 "assessment_pair_support", "belief_outcome_support", "context_crosstabs",
                 "identifier_support", "assessment_status_score_availability")
table_paths <- paste0("output/tables/descriptive_", table_names, ".csv")
checks_relative <- "output/verification/descriptive_checks.csv"
review_relative <- "output/verification/descriptive_review.md"
destinations <- c(table_paths, checks_relative, review_relative)
ignored <- vapply(destinations, function(p) {
  identical(system2("git", c("check-ignore", "-q", "--", p)), 0L)
}, logical(1))
if (!all(ignored)) stop("All descriptive destinations must be ignored before any write.")
if (!all(dir.exists(here::here(c("output/tables", "output/verification"))))) {
  stop("Expected existing output directories are missing.")
}
checks <- data.frame(check_id = character(), severity = character(), expected = character(),
                     observed = character(), status = character(), detail = character())
fmt <- function(x) paste(ifelse(is.na(x), "NA", as.character(x)), collapse = " | ")
hard <- function(id, condition, expected = "TRUE", observed = condition, detail = "") {
  checks <<- rbind(checks, data.frame(check_id = id, severity = "hard", expected = fmt(expected),
                                    observed = fmt(observed), status = if (isTRUE(condition)) "pass" else "fail",
                                    detail = detail))
}
record <- function(id, observed, detail = "") {
  checks <<- rbind(checks, data.frame(check_id = id, severity = "info", expected = "record only",
                                    observed = fmt(observed), status = "recorded", detail = detail))
}
gate <- function() {
  bad <- checks$check_id[checks$status == "fail"]
  if (length(bad)) stop("Failed checks: ", paste(bad, collapse = ", "))
}
write_csv <- function(x, p) write.csv(x, here::here(p), row.names = FALSE, na = "NA", fileEncoding = "UTF-8")
read_text_csv <- function(p) read.csv(here::here(p), colClasses = "character", check.names = FALSE,
                                      na.strings = character(), fileEncoding = "UTF-8")
bind <- function(x) { z <- do.call(rbind, x); row.names(z) <- NULL; z }
pct <- function(n, d) { z <- 100 * n / d; z[is.na(d) | d == 0] <- NA_real_; z }
same <- function(a, b) isTRUE(all.equal(a, b, tolerance = 1e-12, check.attributes = FALSE))
warnings_seen <- character()

# Independent field/wave contract, in panel order. Empty sources are approved gaps.
waves <- c("PF", "PS", "KF", "KS")
wave_labels <- c("Fall Pre-K", "Spring Pre-K", "Fall Kindergarten", "Spring Kindergarten")
grades <- c("Pre-K", "Pre-K", "Kindergarten", "Kindergarten")
seasons <- c("Fall", "Spring", "Fall", "Spring")
baseline <- c("CHGENP", "CHRACE_AAP", "CHRACE_ASP", "CHRACE_LTP", "CHRACE_NAP", "CHRACE_WHP", "CHINCOMCP", "CHMATEDCP")
beliefs <- c("teacher_modernity_pre_k_fall_released", "teacher_modernity_kindergarten_fall_released")
assessments <- c("ppvt_english_standard_score", "applied_problems_english_standard_score",
                "sound_awareness_rhyming_raw_score", "tvip_spanish_standard_score", "tvip_spanish_raw_score",
                "woodcock_munoz_applied_problems_standard_score", "woodcock_munoz_applied_problems_w_score",
                "woodcock_munoz_letter_word_standard_score", "woodcock_munoz_letter_word_w_score")
changes <- c("pre_k_fall_to_spring_change_child_record_released",
             "pre_k_fall_to_spring_change_teacher_questionnaire_released",
             "kindergarten_year_teacher_change_released", "kindergarten_year_classroom_change_released")
counts <- c("kindergarten_year_snapshot_classroom_count_released", "kindergarten_year_observed_classroom_count_released")
sites <- c("pre_k_site_id", "teacher_rating_site_id", "site_ecers_kindergarten_year")
weight <- "site_weight_pre_k_released"
generated <- c("wave", "wave_label", "wave_index", "grade", "season")
schema <- c("STUDY_ID", generated, baseline, beliefs, assessments[1:3], "assessment_status_released", "class_size",
            assessments[4:9], sites, weight, changes, counts)
mapping <- function(field, role, output_role, mapping_class, sources) {
  stopifnot(length(sources) == 4L)
  data.frame(field = field, role = role, output_role = output_role, wave = waves,
             source_variable = sources, mapping_class = mapping_class)
}
contract <- bind(c(list(mapping("STUDY_ID", "identifier_site", "child_identifier", "identifier_repeat", rep("STUDY_ID", 4))),
  lapply(generated, function(f) mapping(f, "structural_metadata", "structural_wave_metadata", "generated_structure", rep("", 4))),
  lapply(baseline, function(f) mapping(f, "baseline_characteristic", "baseline_child_characteristic", "baseline_repeat", rep(f, 4))),
  list(
    mapping(beliefs[1], "belief", "source_specific_teacher_belief", "source_specific_native_wave", c("T_IDEAP", "", "", "")),
    mapping(beliefs[2], "belief", "source_specific_teacher_belief", "source_specific_native_wave", c("", "", "T_IDEAK", "")),
    mapping(assessments[1], "assessment", "english_assessment", "wave_reshape", c("PPVTEPF", "PPVTEPS", "PPVTEKF", "PPVTEKS")),
    mapping(assessments[2], "assessment", "english_assessment", "wave_reshape", c("WJ10_SSEPF", "WJ10_SSEPS", "WJ10_SSEKF", "WJ10_SSEKS")),
    mapping(assessments[3], "assessment", "english_assessment", "wave_reshape", c("WJ21AEPF", "WJ21AEPS", "WJ21AEKF", "WJ21AEKS")),
    mapping("assessment_status_released", "status", "released_assessment_status", "wave_reshape", paste0("ASMSTAT", waves)),
    mapping("class_size", "classroom_context", "classroom_variable", "wave_reshape", paste0("CLS_SIZE", waves)),
    mapping(assessments[4], "assessment", "spanish_assessment", "wave_reshape", c("TVIPSPF", "TVIPSPS", "TVIPSKF", "TVIPSKS")),
    mapping(assessments[5], "assessment", "spanish_assessment", "wave_reshape", c("TVIPRSPF", "TVIPRSPS", "", "")),
    mapping(assessments[6], "assessment", "spanish_assessment", "wave_reshape", c("WM25SSPF", "WM25SSPS", "WM25SSKF", "WM25SSKS")),
    mapping(assessments[7], "assessment", "spanish_assessment", "wave_reshape", c("WM25WPF", "WM25WPS", "WM25WKF", "WM25WKS")),
    mapping(assessments[8], "assessment", "spanish_assessment", "wave_reshape", c("", "", "WM22SSKF", "WM22SSKS")),
    mapping(assessments[9], "assessment", "spanish_assessment", "wave_reshape", c("", "", "WM22WKF", "WM22WKS")),
    mapping(sites[1], "identifier_site", "documented_site", "wave_reshape", c("SITE_PF", "SITE_PS", "", "")),
    mapping(sites[2], "identifier_site", "documented_teacher_rating_site", "wave_reshape", c("", "SITE_TRPS", "SITE_TRKF", "SITE_TRKS")),
    mapping(sites[3], "identifier_site", "documented_site_year_context", "grade_context_repeat", c("", "", "SITE_ECK", "SITE_ECK")),
    mapping(weight, "weight", "released_sampling_weight", "grade_context_repeat", c("SITE_WT", "SITE_WT", "", "")),
    mapping(changes[1], "change_context", "released_grade_transition", "grade_context_repeat", c("T_CHNGCP", "T_CHNGCP", "", "")),
    mapping(changes[2], "change_context", "released_grade_transition", "grade_context_repeat", c("T_CHNG", "T_CHNG", "", "")),
    mapping(changes[3], "change_context", "released_grade_year_change", "grade_context_repeat", c("", "", "TCHCHNGK", "TCHCHNGK")),
    mapping(changes[4], "change_context", "released_grade_year_change", "grade_context_repeat", c("", "", "CLASSCHNGK", "CLASSCHNGK")),
    mapping(counts[1], "change_context", "released_grade_year_count", "grade_context_repeat", c("", "", "SNAPCLASSK", "SNAPCLASSK")),
    mapping(counts[2], "change_context", "released_grade_year_count", "grade_context_repeat", c("", "", "NUMCLSRMK", "NUMCLSRMK")))))
contract <- contract[order(match(contract$field, schema), match(contract$wave, waves)), ]
row.names(contract) <- NULL
contract$field_order <- match(contract$field, schema)
contract$wave_index <- match(contract$wave, waves)
contract$availability_status <- ifelse(nzchar(contract$source_variable), "source_mapped",
  ifelse(contract$field %in% generated, "generated_structural", "no_approved_source_mapping"))
contract$mapping_class[contract$availability_status == "no_approved_source_mapping"] <- "no_approved_source_mapping"
status_levels <- c("(1) Absent", "(2) Full Assessment (English)", "(3) Full Assessment (Spanish)",
  "(4) Non-English, Spanish-Speaking Child Failed Pre-LAS", "(5) Partial Assessment (English)",
  "(6) Partial Assessment (Spanish)", "(7) Child Refused Assessment", "(8) DR")
score_levels <- c("source_nonmissing", "source_missing", "no_approved_source_mapping")
occasion <- function(f, w) {
  if (f %in% c("STUDY_ID", baseline)) return("ALL_CHILDREN")
  if (f == weight) return("PRE_K_SAMPLING")
  if (f %in% changes[1:2]) return("PRE_K_FALL_TO_SPRING")
  if (f %in% c(changes[3:4], sites[3])) return("K_YEAR")
  if (f == counts[1]) return("K_SNAPSHOT_OBSERVATIONS")
  if (f == counts[2]) return("K_ACROSS_INSTRUMENTS")
  w
}
unit <- function(f) {
  if (f %in% c("STUDY_ID", baseline)) "child" else if (f %in% beliefs) "child_record_with_attached_belief" else
    if (f == "class_size") "child_record_with_attached_class_size" else "child_record_at_documented_occasion"
}
language <- function(f) if (f %in% assessments[1:3]) "English" else if (f %in% assessments[4:9]) "Spanish" else "Not applicable"
metric <- function(f) {
  if (f %in% assessments[c(1, 2, 4, 6, 8)]) "standard score" else
    if (f %in% assessments[c(3, 5)]) "raw score" else if (f %in% assessments[c(7, 9)]) "W score" else
      if (f %in% beliefs) "released belief measure" else if (f == weight) "released sampling weight" else "count"
}
decision <- function(f, w) contract[contract$field == f & contract$wave == w, , drop = FALSE]
mapped <- function(f, w) decision(f, w)$availability_status == "source_mapped"
value <- function(f, w) panel[[f]][panel$wave == w]
source_name <- function(f, w) decision(f, w)$source_variable
issue <- function(f, w) decision(f, w)$issue_ids

# Helpers explicitly distinguish absent mappings from missing source observations.
numeric_summary <- function(x, has_mapping) {
  n <- length(x); nn <- if (has_mapping) sum(!is.na(x)) else 0L
  nf <- if (has_mapping) sum(!is.na(x) & !is.finite(x)) else 0L
  state <- if (!has_mapping) "mapping_gap" else if (!nn) "all_source_missing" else
    if (nf) "nonfinite_present" else if (nn == 1L) "singleton" else "ok"
  stats <- setNames(rep(NA_real_, 9), c("mean", "sd", "min", "p05", "p25", "median", "p75", "p95", "max"))
  if (state %in% c("singleton", "ok")) {
    y <- x[!is.na(x)]
    stats[] <- c(mean(y), if (nn > 1L) sd(y) else NA_real_, min(y),
                 quantile(y, c(.05, .25, .5, .75, .95), type = 7, names = FALSE), max(y))
  }
  cbind(data.frame(n_nonmissing = nn, n_source_missing = if (has_mapping) n - nn else 0L,
                   n_mapping_gap = if (has_mapping) 0L else n, n_nonfinite = nf,
                   n_minus7 = if (has_mapping) sum(x == -7, na.rm = TRUE) else 0L),
        as.data.frame(as.list(stats)), summary_status = state)
}
category_grid <- function(x, forced_levels = NULL) {
  labels <- if (!is.null(forced_levels)) forced_levels else if (is.factor(x)) levels(x) else as.character(sort(unique(x[!is.na(x)])))
  data.frame(category_order = seq_len(length(labels) + 1L),
             category_kind = c(rep("released_value", length(labels)), "source_missing"),
             category_label = c(labels, ""))
}
category_index <- function(x, grid) {
  z <- match(as.character(x), grid$category_label[grid$category_kind == "released_value"])
  z[is.na(x)] <- nrow(grid)
  stopifnot(!anyNA(z))
  z
}
score_category <- function(x, has_mapping) {
  if (!has_mapping) rep(3L, length(x)) else ifelse(is.na(x), 2L, 1L)
}
literal_code_maps <- list(
  T_CHNGCP = c("(0) No change in teacher, Classroom" = 0L, "(1) Change in Teacher" = 1L, "(2) Change in Classroom" = 2L),
  T_CHNG = c("(0) No change in teacher, classroom" = 0L, "(1) Change in teacher" = 1L, "(2) Change in classroom" = 2L))

tryCatch(withCallingHandlers({
  hard("project_root", identical(project_start, git_root))
  hard("destinations_ignored", all(ignored))
  required <- c("Data/processed/structural_child_wave_panel.rds", "Data/processed/verified_child_wide.rds",
    "output/tables/structural_panel_provenance.csv", "output/tables/verified_wide_provenance.csv",
    "output/verification/structural_panel_checks.csv", "output/verification/verified_wide_checks.csv",
    "docs/stage1_variable_crosswalk.csv", "docs/stage1_unresolved_issues.md",
    "docs/icpsr/DS0001/04283-0001-Setup.do", "docs/icpsr/DS0001/04283-0001-Setup.dct")
  hard("required_inputs", all(file.exists(here::here(required))), "all required inputs present", file.exists(here::here(required)))
  gate()
  # Hash all pre-existing upstream artifacts/reports and documentary inputs, not just the two RDS files.
  input_paths <- sort(unique(c(required, "AGENTS.md", ".gitignore", "renv.lock",
    list.files("Data/processed", full.names = TRUE, all.files = TRUE, no.. = TRUE),
    list.files("docs", full.names = TRUE, recursive = TRUE),
    setdiff(list.files("code/revision", full.names = TRUE), "code/revision/05_describe_released_panel.R"),
    list.files("output/tables", full.names = TRUE), list.files("output/verification", full.names = TRUE))))
  input_paths <- input_paths[!grepl("/descriptive_", input_paths) & !dir.exists(input_paths)]
  input_hash_before <- tools::md5sum(here::here(input_paths))
  names(input_hash_before) <- input_paths
  previous_tables <- lapply(table_paths, function(p) if (file.exists(here::here(p))) read_text_csv(p) else NULL)
  previous_hashes <- vapply(table_paths, function(p) if (file.exists(here::here(p))) unname(tools::md5sum(here::here(p))) else "", character(1))
  wide <- readRDS(here::here(required[2])); panel <- readRDS(here::here(required[1]))
  cw <- read_text_csv("docs/stage1_variable_crosswalk.csv")
  cw1 <- cw[cw$dataset_id == "DS0001", ]; row.names(cw1) <- NULL
  provenance <- read_text_csv("output/tables/structural_panel_provenance.csv")
  wide_provenance <- read_text_csv("output/tables/verified_wide_provenance.csv")
  for (stage in c("verified_wide", "structural_panel")) {
    up <- read_text_csv(paste0("output/verification/", stage, "_checks.csv"))
    hard(paste0(stage, "_check_schema"), identical(names(up), names(checks)) && !anyDuplicated(up$check_id))
    gate()
    h <- up$severity == "hard"
    expected_n <- if (stage == "verified_wide") 35L else 485L
    hard(paste0(stage, "_historical_checks"), sum(h) == expected_n && all(up$status[h] == "pass"),
         paste(expected_n, "historical passing hard checks"), c(sum(h), sum(up$status[h] != "pass")),
         "Existing report inspected; upstream pipeline was not rerun.")
  }
  hard("crosswalk_schema", all(c("dataset_id", "raw_variable", "source_document", "source_page_or_section",
    "conflict_or_question_id", "raw_label", "assessment_language", "score_type") %in% names(cw)) &&
    nrow(cw) == 66L && nrow(cw1) == 62L && !anyDuplicated(cw[c("dataset_id", "raw_variable")]))
  hard("wide_provenance_schema", all(c(names(cw), "included_in_output", "transformation_applied", "output_variable",
    "verified_wide_classification") %in% names(wide_provenance)))
  gate()
  hard("wide_provenance_lineage", identical(wide_provenance[names(cw)], cw) &&
    all(wide_provenance$transformation_applied == "none") &&
    all(wide_provenance$included_in_output == ifelse(cw$dataset_id == "DS0001", "TRUE", "FALSE")) &&
    all(wide_provenance$output_variable == ifelse(cw$dataset_id == "DS0001", cw$raw_variable, "")) &&
    all(wide_provenance$verified_wide_classification == ifelse(cw$dataset_id == "DS0001", "INCLUDE_RAW", "NOT_NEEDED_FOR_VERIFIED_WIDE")))
  hard("input_schemas", is.data.frame(wide) && is.data.frame(panel) && identical(dim(wide), c(1015L, 62L)) &&
    identical(dim(panel), c(4060L, 37L)) && identical(names(panel), schema) && identical(names(wide), cw1$raw_variable))
  hard("contract_148", nrow(contract) == 148L && !anyDuplicated(contract[c("field", "wave")]) &&
    identical(contract$field, rep(schema, each = 4)) && identical(contract$wave, rep(waves, 37)) &&
    sum(contract$availability_status == "source_mapped") == 97L &&
    sum(contract$availability_status == "generated_structural") == 20L &&
    sum(contract$availability_status == "no_approved_source_mapping") == 31L &&
    setequal(contract$source_variable[nzchar(contract$source_variable)], names(wide)))
  hard("panel_provenance_schema", nrow(provenance) == 148L && all(c("decision_id", "output_variable", "output_role", "wave",
    "source_variable", "mapping_class", "availability_status", "source_attributes", "source_class", "source_typeof",
    "conflict_or_question_id", "source_document", "source_page_or_section", "transformation_applied", "substantive_assumption",
    "source_nonmissing_n", "source_na_n", "output_nonmissing_n", "output_source_na_n", "output_introduced_na_n") %in% names(provenance)))
  gate()
  hard("panel_provenance_decisions", identical(provenance$decision_id, sprintf("decision_%03d", 1:148)) &&
    identical(provenance$output_variable, contract$field) && identical(provenance$output_role, contract$output_role) &&
    identical(provenance$wave, contract$wave) && identical(provenance$source_variable, contract$source_variable) &&
    identical(provenance$mapping_class, contract$mapping_class) && identical(provenance$availability_status, contract$availability_status) &&
    all(provenance$substantive_assumption == "none") && all(provenance$transformation_applied ==
      ifelse(contract$availability_status == "source_mapped", "none", ifelse(contract$field %in% generated, "derive_structure", "introduce_mapping_gap_na"))))
  hard("child_identity", !anyNA(wide$STUDY_ID) && !anyDuplicated(wide$STUDY_ID) && !anyNA(panel$STUDY_ID) &&
    setequal(panel$STUDY_ID, wide$STUDY_ID) && !anyDuplicated(panel[c("STUDY_ID", "wave")]) &&
    all(table(panel$STUDY_ID) == 4L) && identical(panel$STUDY_ID, rep(wide$STUDY_ID, each = 4)))
  wi <- rep(1:4, nrow(wide)); n <- nrow(wide)
  hard("wave_metadata_order", identical(panel$wave_index, wi) &&
    identical(panel$wave, ordered(waves[wi], levels = waves)) &&
    identical(panel$wave_label, ordered(wave_labels[wi], levels = wave_labels)) &&
    identical(panel$grade, factor(grades[wi], levels = c("Pre-K", "Kindergarten"))) &&
    identical(panel$season, factor(seasons[wi], levels = c("Fall", "Spring"))))
  hard("common_status_levels", identical(levels(panel$assessment_status_released), status_levels))
  gate()
  ci <- match(contract$source_variable, cw1$raw_variable)
  contract$issue_ids <- ifelse(is.na(ci), "", cw1$conflict_or_question_id[ci])
  contract$source_document <- ifelse(is.na(ci), "", cw1$source_document[ci])
  contract$source_page_or_section <- ifelse(is.na(ci), "", cw1$source_page_or_section[ci])
  # Verify original factor metadata directly against the release setup, preserving display labels.
  setup_text <- paste(readLines(here::here(required[9]), encoding = "UTF-8", warn = FALSE), collapse = "\n")
  setup_levels <- function(src) {
    block <- regmatches(setup_text, regexpr(paste0("label define ", src, "[[:space:]][^;]*;"), setup_text))
    if (!length(block)) stop("Missing setup label block: ", src)
    tokens <- regmatches(block, gregexpr('-?[0-9]+[[:space:]]+"[^"]*"', block))[[1]]
    codes <- as.integer(sub('[[:space:]].*$', "", tokens))
    labels <- sub('^[^"]*"([^"]*)"$', "\\1", tokens)
    keep <- codes >= 0L
    width <- if (src %in% c("CHINCOMCP", "CHMATEDCP")) 2L else 1L
    paste0("(", sprintf(paste0("%0", width, "d"), codes[keep]), ") ", labels[keep])
  }
  factor_sources <- c(paste0("ASMSTAT", waves), baseline, "T_CHNGCP", "T_CHNG", "TCHCHNGK", "CLASSCHNGK")
  for (src in factor_sources) {
    hard(paste0("released_levels_", src), identical(levels(wide[[src]]), setup_levels(src)),
         "exact released display levels and documented code/label order", levels(wide[[src]]))
  }
  for (src in names(wide)) {
    hard(paste0("wide_class_", src), identical(class(wide[[src]]), if (src %in% factor_sources) "factor" else "numeric") &&
      identical(typeof(wide[[src]]), if (src %in% factor_sources) "integer" else "double"))
  }
  hard("literal_change_code_maps", all(vapply(names(literal_code_maps), function(s) {
    identical(names(literal_code_maps[[s]]), levels(wide[[s]])) && identical(unname(literal_code_maps[[s]]), 0:2)
  }, logical(1))))
  gate()
  for (i in seq_len(nrow(contract))) {
    r <- contract[i, ]; x <- value(r$field, r$wave); p <- provenance[i, ]
    backed <- r$availability_status == "source_mapped"
    if (backed) {
      src <- wide[[r$source_variable]]
      equal <- if (is.factor(src)) identical(as.character(x), as.character(src)) else identical(as.numeric(x), as.numeric(src))
      field_sources <- unique(contract$source_variable[contract$field == r$field & nzchar(contract$source_variable)])
      metadata_policy <- if (r$field == "assessment_status_released") {
        identical(class(x), "factor") && identical(levels(x), status_levels)
      } else if (length(field_sources) > 1L) {
        identical(class(x), "numeric") && is.null(attributes(panel[[r$field]]))
      } else {
        identical(class(x), class(src)) && identical(typeof(x), typeof(src)) &&
          identical(attributes(panel[[r$field]]), attributes(src))
      }
      hard(paste0("source_slice_", i), equal && identical(is.na(x), is.na(src)) && metadata_policy,
           "exact source values, NA mask and approved class/attribute policy", equal && metadata_policy)
      hard(paste0("source_metadata_", i), identical(p$source_attributes, paste(capture.output(dput(attributes(src), control = "all")), collapse = "\n")) &&
        p$source_class == paste(class(src), collapse = " | ") && p$source_typeof == typeof(src) &&
        p$conflict_or_question_id == r$issue_ids && p$source_document == r$source_document && p$source_page_or_section == r$source_page_or_section)
    } else if (r$availability_status == "no_approved_source_mapping") {
      hard(paste0("mapping_gap_", i), all(is.na(x)))
    }
    hard(paste0("provenance_counts_", i), as.integer(p$output_nonmissing_n) == sum(!is.na(x)) &&
      as.integer(p$output_source_na_n) == (if (backed) sum(is.na(x)) else 0L) &&
      as.integer(p$output_introduced_na_n) == (if (r$availability_status == "no_approved_source_mapping") n else 0L) &&
      (!backed || (as.integer(p$source_nonmissing_n) == sum(!is.na(x)) && as.integer(p$source_na_n) == sum(is.na(x)))))
  }
  gate()
  # A: field inventory, partitioning every structural cell before inspecting values.
  A <- bind(lapply(seq_len(nrow(contract)), function(i) {
    r <- contract[i, ]; x <- value(r$field, r$wave)
    s <- r$availability_status == "source_mapped"; g <- r$availability_status == "generated_structural"
    nn <- sum(!is.na(x)); nm <- sum(is.na(x))
    data.frame(field_order = r$field_order, field = r$field, role = r$role, output_role = r$output_role,
      wave = r$wave, wave_index = r$wave_index, source_variable = r$source_variable, mapping_class = r$mapping_class,
      availability_status = r$availability_status, summary_unit = unit(r$field), summary_period = occasion(r$field, r$wave),
      n_structural_rows = n, n_source_nonmissing = if (s) nn else 0L, n_source_missing = if (s) nm else 0L,
      n_mapping_gap = if (!s && !g) n else 0L, n_generated_nonmissing = if (g) nn else 0L,
      n_generated_missing = if (g) nm else 0L, pct_source_nonmissing = if (s) pct(nn, n) else NA_real_,
      pct_source_missing = if (s) pct(nm, n) else NA_real_, pct_mapping_gap = if (!s && !g) 100 else 0,
      issue_ids = r$issue_ids, source_document = r$source_document, source_page_or_section = r$source_page_or_section)
  }))
  # Select one row per documented occasion for repeated sources. This never selects children.
  occasions <- function(fields, include_gaps = FALSE) {
    z <- contract[contract$field %in% fields & (include_gaps | contract$availability_status == "source_mapped"), ]
    z$period <- mapply(occasion, z$field, z$wave, USE.NAMES = FALSE)
    z[!duplicated(z[c("field", "period")]), ]
  }
  b_occ <- rbind(occasions(c(assessments, "class_size"), include_gaps = TRUE), occasions(c(beliefs, weight, counts)))
  b_occ <- b_occ[order(b_occ$field_order, b_occ$wave_index), ]
  B <- bind(lapply(seq_len(nrow(b_occ)), function(i) {
    r <- b_occ[i, ]; f <- r$field; w <- r$wave
    cbind(data.frame(field = f, period = r$period, source_variable = r$source_variable,
      summary_unit = unit(f), language = language(f), metric = metric(f), availability_status = r$availability_status,
      n_children = n), numeric_summary(value(f, w), mapped(f, w)), issue_ids = r$issue_ids)
  }))
  c_occ <- occasions(c(baseline, "assessment_status_released", changes, counts))
  C <- bind(lapply(seq_len(nrow(c_occ)), function(i) {
    r <- c_occ[i, ]; x <- value(r$field, r$wave)
    grid <- category_grid(x); nn <- sum(!is.na(x)); freq <- tabulate(category_index(x, grid), nbins = nrow(grid))
    cbind(data.frame(field = r$field, period = r$period, source_variable = r$source_variable, summary_unit = unit(r$field)),
      grid, data.frame(n_children = freq, denominator_all_children = n, denominator_nonmissing = nn,
        pct_all_children = pct(freq, n), pct_nonmissing = ifelse(grid$category_kind == "released_value", pct(freq, nn), NA_real_),
        issue_ids = r$issue_ids))
  }))
  support <- function(f) {
    sapply(waves, function(w) if (mapped(f, w)) !is.na(value(f, w)) else rep(FALSE, n))
  }
  pattern_strings <- function(observed, flags) {
    x <- ifelse(observed, "1", "0"); x[, !flags] <- "M"
    apply(x, 1, paste0, collapse = "")
  }
  pattern_grid <- function(flags) {
    g <- expand.grid(lapply(flags, function(m) if (m) c("0", "1") else "M"), stringsAsFactors = FALSE)
    sort(apply(g, 1, paste0, collapse = ""), method = "radix")
  }
  D <- bind(lapply(assessments, function(f) {
    flags <- vapply(waves, function(w) mapped(f, w), logical(1)); obs <- support(f)
    mask <- paste0(as.integer(flags), collapse = ""); grid <- pattern_grid(flags)
    a <- data.frame(summary_type = "observed_wave_count", support_category = as.character(0:4),
      n_observed_waves = 0:4, category_possible = 0:4 <= sum(flags), n_children = tabulate(rowSums(obs) + 1L, nbins = 5))
    b <- data.frame(summary_type = "availability_pattern", support_category = grid,
      n_observed_waves = nchar(gsub("[^1]", "", grid)), category_possible = TRUE,
      n_children = tabulate(match(pattern_strings(obs, flags), grid), nbins = length(grid)))
    z <- rbind(a, b)
    cbind(data.frame(field = f, language = language(f), metric = metric(f), mapped_wave_mask = mask, n_mapped_waves = sum(flags)),
      z, denominator_children = n, pct_children = pct(z$n_children, n))
  }))
  pairs <- t(combn(waves, 2))
  E <- bind(lapply(assessments, function(f) bind(lapply(seq_len(nrow(pairs)), function(i) {
    a <- pairs[i, 1]; b <- pairs[i, 2]; ma <- mapped(f, a); mb <- mapped(f, b)
    oa <- !is.na(value(f, a)); ob <- !is.na(value(f, b)); complete <- ma && mb
    data.frame(field = f, language = language(f), metric = metric(f), wave_a = a, wave_b = b,
      mapping_a = ma, mapping_b = mb, mapping_complete = complete, n_children = n,
      n_a = if (ma) sum(oa) else NA_integer_, n_b = if (mb) sum(ob) else NA_integer_,
      n_both = if (complete) sum(oa & ob) else NA_integer_, n_a_only = if (complete) sum(oa & !ob) else NA_integer_,
      n_b_only = if (complete) sum(!oa & ob) else NA_integer_, n_neither = if (complete) sum(!oa & !ob) else NA_integer_,
      pct_both_all_children = if (complete) pct(sum(oa & ob), n) else NA_real_)
  }))))
  F <- bind(lapply(1:2, function(g) bind(lapply(assessments, function(f) {
    fall <- waves[2L * g - 1L]; spring <- waves[2L * g]; belief <- beliefs[g]
    mf <- mapped(f, fall); ms <- mapped(f, spring)
    ob <- !is.na(value(belief, fall)); of <- !is.na(value(f, fall)); os <- !is.na(value(f, spring))
    nb <- sum(ob); nbf <- if (mf) sum(ob & of) else NA_integer_
    nbs <- if (ms) sum(ob & os) else NA_integer_; nbb <- if (mf && ms) sum(ob & of & os) else NA_integer_
    data.frame(grade = c("Pre-K", "Kindergarten")[g], belief_field = belief, belief_source_variable = source_name(belief, fall),
      belief_wave = fall, outcome_field = f, language = language(f), metric = metric(f), fall_wave = fall, spring_wave = spring,
      outcome_fall_mapped = mf, outcome_spring_mapped = ms, n_children = n, n_belief = nb,
      n_fall = if (mf) sum(of) else NA_integer_, n_spring = if (ms) sum(os) else NA_integer_,
      n_fall_spring = if (mf && ms) sum(of & os) else NA_integer_, n_belief_fall = nbf, n_belief_spring = nbs, n_belief_both = nbb,
      pct_belief_all_children = pct(nb, n), pct_belief_fall_all_children = pct(nbf, n),
      pct_belief_spring_all_children = pct(nbs, n), pct_belief_both_all_children = pct(nbb, n))
  }))))
  context_pairs <- data.frame(pair_id = 1:4,
    period = c("PRE_K_FALL_TO_SPRING", "K_YEAR", "K_YEAR", "K_YEAR"),
    field_a = c(changes[1], changes[3], counts[1], changes[4]),
    field_b = c(changes[2], changes[4], counts[2], counts[2]), wave = c("PF", "KF", "KF", "KF"))
  meaning <- function(f, w) cw1$raw_label[match(source_name(f, w), cw1$raw_variable)]
  comparison <- function(id, la, lb, ka, kb) {
    if (!id %in% c(1L, 3L)) return(rep("not_applicable", length(la)))
    missing <- ka == "source_missing" | kb == "source_missing"
    if (id == 1L) {
      a <- unname(literal_code_maps$T_CHNGCP[la]); b <- unname(literal_code_maps$T_CHNG[lb])
    } else { a <- as.numeric(la); b <- as.numeric(lb) }
    ifelse(missing, "source_missing", ifelse(a == b, "literal_equal", "literal_unequal"))
  }
  G <- bind(lapply(1:4, function(i) {
    r <- context_pairs[i, ]; a <- value(r$field_a, r$wave); b <- value(r$field_b, r$wave)
    ga <- category_grid(a); gb <- category_grid(b); ai <- category_index(a, ga); bi <- category_index(b, gb)
    # Row-major grid: source A category first, source B category second.
    ia <- rep(seq_len(nrow(ga)), each = nrow(gb)); ib <- rep(seq_len(nrow(gb)), times = nrow(ga))
    freq <- as.integer(table(factor(ai, levels = seq_len(nrow(ga))), factor(bi, levels = seq_len(nrow(gb))))[cbind(ia, ib)])
    complete <- sum(!is.na(a) & !is.na(b))
    aa <- ga[ia, ]; bb <- gb[ib, ]; names(aa) <- paste0(names(aa), "_a"); names(bb) <- paste0(names(bb), "_b")
    cbind(data.frame(pair_id = i, period = r$period, field_a = r$field_a, field_b = r$field_b,
      meaning_a = meaning(r$field_a, r$wave), meaning_b = meaning(r$field_b, r$wave)), aa, bb,
      data.frame(n_children = freq, denominator_all_children = n, denominator_pair_nonmissing = complete,
        pct_all_children = pct(freq, n), pct_pair_nonmissing = ifelse(aa$category_kind_a == "released_value" &
          bb$category_kind_b == "released_value", pct(freq, complete), NA_real_),
        comparison_basis = c("literal_released_codes", "not_applicable", "literal_released_counts", "not_applicable")[i],
        comparison_result = comparison(i, aa$category_label_a, bb$category_label_b, aa$category_kind_a, bb$category_kind_b)))
  }))
  h_occ <- occasions(c("STUDY_ID", sites))
  H <- bind(lapply(seq_len(nrow(h_occ)), function(i) {
    r <- h_occ[i, ]; x <- value(r$field, r$wave); nonmissing <- !is.na(x)
    # Child IDs are already verified unique within each occasion. Count children, not structural rows.
    per_code <- vapply(split(wide$STUDY_ID[nonmissing], x[nonmissing]), function(ids) length(unique(ids)), integer(1))
    child <- r$field == "STUDY_ID"
    data.frame(field = r$field, period = r$period, source_variable = r$source_variable,
      documented_role = meaning(r$field, r$wave), n_children = n, n_nonmissing = sum(nonmissing), n_source_missing = sum(!nonmissing),
      n_distinct_released_codes = length(per_code), min_children_per_code = if (length(per_code)) min(per_code) else NA_real_,
      median_children_per_code = if (length(per_code)) median(per_code) else NA_real_,
      max_children_per_code = if (length(per_code)) max(per_code) else NA_real_,
      linkage_supported = if (child) "child_panel_only" else "not_established",
      interpretation_limit = if (child) "Within-DS0001 child-wave correspondence only; no cross-dataset linkage." else
        "Documented site meaning only; longitudinal grouping-unit stability and cross-dataset linkage not established; no teacher/classroom/school/state identity inferred.",
      source_document = r$source_document, source_page_or_section = r$source_page_or_section)
  }))
  I <- bind(lapply(assessments, function(f) bind(lapply(waves, function(w) {
    x <- value(f, w); status <- value("assessment_status_released", w); m <- mapped(f, w)
    sg <- category_grid(status, status_levels); si <- category_index(status, sg); sc <- score_category(x, m)
    is <- rep(1:9, each = 3); ic <- rep(1:3, times = 9)
    freq <- as.integer(table(factor(si, levels = 1:9), factor(sc, levels = 1:3))[cbind(is, ic)])
    den <- tabulate(si, nbins = 9)[is]; den_mapped <- if (m) den else rep(0L, length(den))
    data.frame(field = f, wave = w, language = language(f), metric = metric(f), source_variable = source_name(f, w),
      availability_status = decision(f, w)$availability_status, status_category_order = is,
      status_category_kind = sg$category_kind[is], status_category_label = sg$category_label[is],
      score_availability_order = ic, score_availability = score_levels[ic], score_availability_possible = if (m) ic < 3L else ic == 3L,
      n_children = freq, denominator_wave_children = n, denominator_status_children = den,
      denominator_status_source_mapped = den_mapped, pct_wave_children = pct(freq, n), pct_within_status = pct(freq, den),
      pct_within_status_source_mapped = ifelse(m & ic < 3L, pct(freq, den_mapped), NA_real_))
  }))))
  tables <- list(A, B, C, D, E, F, G, H, I); names(tables) <- table_names
  # Exact public schemas and keys are declared independently of table construction.
  schemas <- lapply(c(
    "field_order field role output_role wave wave_index source_variable mapping_class availability_status summary_unit summary_period n_structural_rows n_source_nonmissing n_source_missing n_mapping_gap n_generated_nonmissing n_generated_missing pct_source_nonmissing pct_source_missing pct_mapping_gap issue_ids source_document source_page_or_section",
    "field period source_variable summary_unit language metric availability_status n_children n_nonmissing n_source_missing n_mapping_gap n_nonfinite n_minus7 mean sd min p05 p25 median p75 p95 max summary_status issue_ids",
    "field period source_variable summary_unit category_order category_kind category_label n_children denominator_all_children denominator_nonmissing pct_all_children pct_nonmissing issue_ids",
    "field language metric mapped_wave_mask n_mapped_waves summary_type support_category n_observed_waves category_possible n_children denominator_children pct_children",
    "field language metric wave_a wave_b mapping_a mapping_b mapping_complete n_children n_a n_b n_both n_a_only n_b_only n_neither pct_both_all_children",
    "grade belief_field belief_source_variable belief_wave outcome_field language metric fall_wave spring_wave outcome_fall_mapped outcome_spring_mapped n_children n_belief n_fall n_spring n_fall_spring n_belief_fall n_belief_spring n_belief_both pct_belief_all_children pct_belief_fall_all_children pct_belief_spring_all_children pct_belief_both_all_children",
    "pair_id period field_a field_b meaning_a meaning_b category_order_a category_kind_a category_label_a category_order_b category_kind_b category_label_b n_children denominator_all_children denominator_pair_nonmissing pct_all_children pct_pair_nonmissing comparison_basis comparison_result",
    "field period source_variable documented_role n_children n_nonmissing n_source_missing n_distinct_released_codes min_children_per_code median_children_per_code max_children_per_code linkage_supported interpretation_limit source_document source_page_or_section",
    "field wave language metric source_variable availability_status status_category_order status_category_kind status_category_label score_availability_order score_availability score_availability_possible n_children denominator_wave_children denominator_status_children denominator_status_source_mapped pct_wave_children pct_within_status pct_within_status_source_mapped"
  ), function(s) strsplit(s, " ", fixed = TRUE)[[1]])
  keys <- lapply(c("field wave", "field period", "field period category_kind category_label",
    "field summary_type support_category", "field wave_a wave_b", "grade outcome_field",
    "pair_id category_kind_a category_label_a category_kind_b category_label_b", "field period",
    "field wave status_category_kind status_category_label score_availability"), function(s) strsplit(s, " ", fixed = TRUE)[[1]])
  expected_rows <- c(148L, 45L, NA_integer_, 153L, 54L, 18L, NA_integer_, 7L, 972L)
  # D: six four-wave series (21 rows each) and three two-wave series (9 rows each).
  hard("declared_role_partition", identical(as.integer(table(factor(contract$role, levels = c("structural_metadata",
    "baseline_characteristic", "assessment", "belief", "status", "classroom_context", "identifier_site", "weight", "change_context")))) / 4,
    c(5, 8, 9, 2, 1, 1, 4, 1, 6)))
  for (i in seq_along(tables)) {
    z <- tables[[i]]; id <- table_names[i]
    hard(paste0(id, "_schema"), identical(names(z), schemas[[i]]), schemas[[i]], names(z))
    hard(paste0(id, "_keys"), !anyDuplicated(z[keys[[i]]]) && !anyNA(z[keys[[i]]]))
    if (!is.na(expected_rows[i])) hard(paste0(id, "_rows"), nrow(z) == expected_rows[i], expected_rows[i], nrow(z))
    for (p in names(z)[startsWith(names(z), "pct_")]) {
      v <- z[[p]]
      hard(paste0(id, "_range_", p), all(is.na(v) | (is.finite(v) & v >= 0 & v <= 100)))
    }
    count_columns <- names(z)[grepl("^n_|^denominator_", names(z))]
    hard(paste0(id, "_nonnegative_integer_counts"), all(vapply(z[count_columns], function(v) all(is.na(v) | (is.finite(v) & v >= 0 & v == floor(v))), logical(1))))
  }
  gate()
  hard("A_partition", all(A$n_structural_rows == n) && all(rowSums(A[c("n_source_nonmissing", "n_source_missing", "n_mapping_gap",
    "n_generated_nonmissing", "n_generated_missing")]) == A$n_structural_rows) && sum(A$n_mapping_gap) == 31465L)
  hard("A_percentages", same(A$pct_source_nonmissing, pct(A$n_source_nonmissing, A$n_source_nonmissing + A$n_source_missing)) &&
    same(A$pct_source_missing, pct(A$n_source_missing, A$n_source_nonmissing + A$n_source_missing)) &&
    same(A$pct_mapping_gap, pct(A$n_mapping_gap, A$n_structural_rows)))
  hard("A_order", identical(A$field, rep(schema, each = 4)) && identical(A$wave, rep(waves, length(schema))))
  hard("availability_enum", !anyNA(A$availability_status) && setequal(unique(A$availability_status),
    c("source_mapped", "generated_structural", "no_approved_source_mapping")) &&
    all((A$availability_status == "source_mapped") == nzchar(A$source_variable)) &&
    all((A$availability_status == "generated_structural") == A$field %in% generated))
  hard("B_partition", all(B$n_nonmissing + B$n_source_missing + B$n_mapping_gap == n) &&
    all(B$n_children == n) && all(B$n_nonfinite <= B$n_nonmissing) && all(B$n_minus7 <= B$n_nonmissing))
  stat_columns <- c("mean", "sd", "min", "p05", "p25", "median", "p75", "p95", "max")
  for (i in seq_len(nrow(B))) {
    r <- B[i, ]; w <- b_occ$wave[i]; src <- source_name(r$field, w); m <- mapped(r$field, w)
    x <- if (m) wide[[src]] else rep(NA_real_, n)
    # Verify against source vectors, including quantiles/SD, status precedence, and NA statistics.
    hard(paste0("B_source_statistics_", i), same(r[names(numeric_summary(x, m))], numeric_summary(x, m)) &&
      identical(r$period, occasion(r$field, w)) && r$source_variable == src)
  }
  hard("B_order_and_occasions", identical(B$field, b_occ$field) && identical(B$period, b_occ$period) &&
    sum(B$field %in% beliefs) == 2L && sum(B$field == weight) == 1L && sum(B$field %in% counts) == 2L &&
    !any(B$field %in% c("STUDY_ID", sites)))
  hard("summary_status_enum", !anyNA(B$summary_status) && all(B$summary_status %in% c("mapping_gap", "all_source_missing", "nonfinite_present", "singleton", "ok")))
  for (i in seq_len(nrow(c_occ))) {
    r <- c_occ[i, ]; z <- C[C$field == r$field & C$period == r$period, ]; row.names(z) <- NULL; x <- wide[[r$source_variable]]
    grid <- category_grid(x, if (r$field == "assessment_status_released") status_levels else NULL)
    expected <- vapply(seq_len(nrow(grid)), function(j) if (grid$category_kind[j] == "source_missing") sum(is.na(x)) else sum(as.character(x) == grid$category_label[j], na.rm = TRUE), integer(1))
    nn <- sum(!is.na(x))
    hard(paste0("C_source_frequencies_", i), identical(z[c("category_order", "category_kind", "category_label")], grid) &&
      same(z$n_children, expected) && sum(z$n_children) == n && all(z$denominator_all_children == n) && all(z$denominator_nonmissing == nn) &&
      same(z$pct_all_children, pct(expected, n)) && same(z$pct_nonmissing, ifelse(grid$category_kind == "released_value", pct(expected, nn), NA_real_)))
  }
  hard("C_order", identical(paste(C$field, C$period), rep(paste(c_occ$field, c_occ$period),
    vapply(seq_len(nrow(c_occ)), function(i) nrow(category_grid(value(c_occ$field[i], c_occ$wave[i]))), integer(1)))))
  for (f in assessments) {
    flags <- vapply(waves, function(w) mapped(f, w), logical(1))
    source_obs <- sapply(waves, function(w) if (mapped(f, w)) !is.na(wide[[source_name(f, w)]]) else rep(FALSE, n))
    z <- D[D$field == f, ]; a <- z[z$summary_type == "observed_wave_count", ]; b <- z[z$summary_type == "availability_pattern", ]
    hard(paste0("D_patterns_", f), identical(a$support_category, as.character(0:4)) &&
      identical(b$support_category, pattern_grid(flags)) && all(z$mapped_wave_mask == paste0(as.integer(flags), collapse = "")) &&
      all(z$n_mapped_waves == sum(flags)) && identical(a$category_possible, 0:4 <= sum(flags)) && all(b$category_possible) &&
      sum(a$n_children) == n && sum(b$n_children) == n &&
      same(a$n_children, tabulate(rowSums(source_obs) + 1L, nbins = 5)) &&
      same(b$n_children, tabulate(match(pattern_strings(source_obs, flags), b$support_category), nbins = nrow(b))) &&
      all(z$n_children[!z$category_possible] == 0L) && all(z$denominator_children == n) && same(z$pct_children, pct(z$n_children, n)))
    # Pattern counts must imply the observed-count distribution and every wave marginal.
    pattern_counts <- vapply(0:4, function(k) sum(b$n_children[b$n_observed_waves == k]), numeric(1))
    hard(paste0("D_count_and_wave_margins_", f), same(pattern_counts, a$n_children) &&
      all(vapply(1:4, function(j) sum(b$n_children[substr(b$support_category, j, j) == "1"]) == sum(source_obs[, j]), logical(1))))
  }
  d_rows <- vapply(assessments, function(f) 5L + 2L^sum(vapply(waves, function(w) mapped(f, w), logical(1))), numeric(1))
  hard("D_order", identical(D$field, rep(assessments, d_rows)))
  for (i in seq_len(nrow(E))) {
    r <- E[i, ]; a <- !is.na(value(r$field, r$wave_a)); b <- !is.na(value(r$field, r$wave_b))
    ma <- mapped(r$field, r$wave_a); mb <- mapped(r$field, r$wave_b); both <- ma && mb
    expected <- c(if (ma) sum(a) else NA_integer_, if (mb) sum(b) else NA_integer_,
      if (both) c(sum(a & b), sum(a & !b), sum(!a & b), sum(!a & !b)) else rep(NA_integer_, 4))
    hard(paste0("E_intersections_", i), identical(c(r$mapping_a, r$mapping_b, r$mapping_complete), c(ma, mb, both)) &&
      same(unlist(r[c("n_a", "n_b", "n_both", "n_a_only", "n_b_only", "n_neither")], use.names = FALSE), expected) &&
      (!both || (r$n_both + r$n_a_only + r$n_b_only + r$n_neither == n && r$n_a == r$n_both + r$n_a_only && r$n_b == r$n_both + r$n_b_only)) &&
      same(r$pct_both_all_children, pct(r$n_both, n)))
  }
  hard("E_order", identical(E$field, rep(assessments, each = 6)) &&
    identical(E$wave_a, rep(pairs[, 1], 9)) && identical(E$wave_b, rep(pairs[, 2], 9)))
  for (i in seq_len(nrow(F))) {
    r <- F[i, ]; f <- r$outcome_field; mf <- mapped(f, r$fall_wave); ms <- mapped(f, r$spring_wave)
    b <- !is.na(wide[[r$belief_source_variable]])
    a <- if (mf) !is.na(wide[[source_name(f, r$fall_wave)]]) else rep(FALSE, n)
    s <- if (ms) !is.na(wide[[source_name(f, r$spring_wave)]]) else rep(FALSE, n)
    expected <- c(sum(b), if (mf) sum(a) else NA_integer_, if (ms) sum(s) else NA_integer_,
      if (mf && ms) sum(a & s) else NA_integer_, if (mf) sum(b & a) else NA_integer_,
      if (ms) sum(b & s) else NA_integer_, if (mf && ms) sum(b & a & s) else NA_integer_)
    hard(paste0("F_intersections_", i), same(unlist(r[c("n_belief", "n_fall", "n_spring", "n_fall_spring", "n_belief_fall", "n_belief_spring", "n_belief_both")], use.names = FALSE), expected) &&
      identical(c(r$outcome_fall_mapped, r$outcome_spring_mapped), c(mf, ms)) &&
      same(unlist(r[c("pct_belief_all_children", "pct_belief_fall_all_children", "pct_belief_spring_all_children", "pct_belief_both_all_children")], use.names = FALSE), pct(expected[c(1, 5:7)], n)))
  }
  hard("F_order", identical(F$grade, rep(c("Pre-K", "Kindergarten"), each = 9)) && identical(F$outcome_field, rep(assessments, 2)))
  for (i in 1:4) {
    z <- G[G$pair_id == i, ]; r <- context_pairs[i, ]
    a <- wide[[source_name(r$field_a, r$wave)]]; b <- wide[[source_name(r$field_b, r$wave)]]
    ga <- category_grid(a); gb <- category_grid(b)
    ca <- C[C$field == r$field_a & C$period == occasion(r$field_a, r$wave), ]
    cb <- C[C$field == r$field_b & C$period == occasion(r$field_b, r$wave), ]
    complete <- sum(!is.na(a) & !is.na(b))
    hard(paste0("G_margins_", i), sum(z$n_children) == n && all(z$denominator_all_children == n) &&
      all(z$denominator_pair_nonmissing == complete) && nrow(z) == nrow(ga) * nrow(gb) &&
      same(as.numeric(tapply(z$n_children, z$category_order_a, sum)), ca$n_children) &&
      same(as.numeric(tapply(z$n_children, z$category_order_b, sum)), cb$n_children) &&
      same(z$pct_all_children, pct(z$n_children, n)) && same(z$pct_pair_nonmissing,
        ifelse(z$category_kind_a == "released_value" & z$category_kind_b == "released_value", pct(z$n_children, complete), NA_real_)))
    # Recount every cell directly from the wide sources, including unused/missing cells.
    hard(paste0("G_cells_and_literal_labels_", i), all(vapply(seq_len(nrow(z)), function(j) {
      aa <- if (z$category_kind_a[j] == "source_missing") is.na(a) else !is.na(a) & as.character(a) == z$category_label_a[j]
      bb <- if (z$category_kind_b[j] == "source_missing") is.na(b) else !is.na(b) & as.character(b) == z$category_label_b[j]
      z$n_children[j] == sum(aa & bb)
    }, logical(1))) && identical(z$comparison_result, comparison(i, z$category_label_a, z$category_label_b, z$category_kind_a, z$category_kind_b)) &&
      identical(z$category_order_a, rep(seq_len(nrow(ga)), each = nrow(gb))) && identical(z$category_order_b, rep(seq_len(nrow(gb)), nrow(ga))) &&
      all(z$meaning_a == meaning(r$field_a, r$wave)) && all(z$meaning_b == meaning(r$field_b, r$wave)))
  }
  hard("G_order", !is.unsorted(G$pair_id))
  for (i in seq_len(nrow(H))) {
    r <- H[i, ]; x <- wide[[r$source_variable]]; sizes <- as.integer(table(x, useNA = "no"))
    stats <- if (length(sizes)) c(min(sizes), median(sizes), max(sizes)) else rep(NA_real_, 3)
    hard(paste0("H_counts_", i), r$n_nonmissing == sum(!is.na(x)) && r$n_source_missing == sum(is.na(x)) &&
      r$n_nonmissing + r$n_source_missing == n && r$n_distinct_released_codes == length(unique(x[!is.na(x)])) &&
      same(unlist(r[c("min_children_per_code", "median_children_per_code", "max_children_per_code")], use.names = FALSE), stats))
  }
  hard("H_linkage_enum", is.character(H$linkage_supported) && !anyNA(H$linkage_supported) &&
    all(H$linkage_supported == ifelse(H$field == "STUDY_ID", "child_panel_only", "not_established")))
  hard("H_order", identical(H$field, h_occ$field) && identical(H$period, h_occ$period))
  for (f in assessments) for (w in waves) {
    z <- I[I$field == f & I$wave == w, ]; m <- mapped(f, w)
    a <- A[A$field == f & A$wave == w, ]; cstat <- C[C$field == "assessment_status_released" & C$period == w, ]
    hard(paste0("I_grid_", f, "_", w), nrow(z) == 27L && sum(z$n_children) == n &&
      identical(z$status_category_order, rep(1:9, each = 3)) && identical(z$score_availability_order, rep(1:3, 9)) &&
      identical(z$status_category_kind, rep(c(rep("released_value", 8), "source_missing"), each = 3)) &&
      identical(z$status_category_label, rep(c(status_levels, ""), each = 3)) && identical(z$score_availability, rep(score_levels, 9)) &&
      !anyNA(z$score_availability_possible) && identical(z$score_availability_possible, if (m) z$score_availability_order < 3L else z$score_availability_order == 3L) &&
      all(z$n_children[!z$score_availability_possible] == 0L) && all(z$denominator_wave_children == n) &&
      same(z$denominator_status_children, rep(cstat$n_children, each = 3)) &&
      same(z$denominator_status_source_mapped, if (m) rep(cstat$n_children, each = 3) else rep(0L, 27)))
    hard(paste0("I_margins_", f, "_", w), same(as.numeric(tapply(z$n_children, z$status_category_order, sum)), cstat$n_children) &&
      same(as.numeric(tapply(z$n_children, z$score_availability_order, sum)), unlist(a[c("n_source_nonmissing", "n_source_missing", "n_mapping_gap")], use.names = FALSE)))
    hard(paste0("I_percentages_", f, "_", w), same(z$pct_wave_children, pct(z$n_children, n)) &&
      same(z$pct_within_status, pct(z$n_children, z$denominator_status_children)) &&
      same(z$pct_within_status_source_mapped, ifelse(m & z$score_availability_order < 3, pct(z$n_children, z$denominator_status_source_mapped), NA_real_)) &&
      all(vapply(1:9, function(k) {
        zz <- z[z$status_category_order == k, ]
        if (zz$denominator_status_children[1] == 0L) all(is.na(zz$pct_within_status)) else
          same(sum(zz$pct_within_status), 100) && (!m || same(sum(zz$pct_within_status_source_mapped[1:2]), 100))
      }, logical(1))))
    # Check conditional cells directly, not only margins (which could hide a redistribution).
    s <- as.character(wide[[paste0("ASMSTAT", w)]])
    x <- if (m) wide[[source_name(f, w)]] else rep(NA_real_, n)
    hard(paste0("I_source_cells_", f, "_", w), all(vapply(seq_len(nrow(z)), function(j) {
      in_status <- if (z$status_category_kind[j] == "source_missing") is.na(s) else !is.na(s) & s == z$status_category_label[j]
      in_score <- if (!m) rep(z$score_availability_order[j] == 3L, n) else
        if (z$score_availability_order[j] == 1L) !is.na(x) else if (z$score_availability_order[j] == 2L) is.na(x) else rep(FALSE, n)
      z$n_children[j] == sum(in_status & in_score)
    }, logical(1))))
  }
  hard("I_order", identical(I$field, rep(assessments, each = 108)) && identical(I$wave, rep(rep(waves, each = 27), 9)))
  hard("all_mapping_flags_logical", all(vapply(E[c("mapping_a", "mapping_b", "mapping_complete")], function(x) is.logical(x) && !anyNA(x), logical(1))) &&
    all(vapply(F[c("outcome_fall_mapped", "outcome_spring_mapped")], function(x) is.logical(x) && !anyNA(x), logical(1))))
  english_ap <- B[B$field == assessments[2], ]
  hard("eight_minus7_preserved", sum(english_ap$n_minus7) == 8L &&
    all(vapply(waves, function(w) identical(which(value(assessments[2], w) == -7), which(wide[[paste0("WJ10_SSE", w)]] == -7)), logical(1))),
    "8 retained English Applied Problems -7 cells; no child IDs published", sum(english_ap$n_minus7))
  hard("two_PS_DR_preserved", sum(value("assessment_status_released", "PS") == "(8) DR", na.rm = TRUE) == 2L &&
    identical(which(value("assessment_status_released", "PS") == "(8) DR"), which(wide$ASMSTATPS == "(8) DR")), "2 PS DR cells", 2L)
  # Required in-memory edge cases. None changes the released panel or creates a dataset.
  hard("edge_all_source_missing", numeric_summary(c(NA_real_, NaN), TRUE)$summary_status == "all_source_missing" &&
    numeric_summary(c(NA_real_, NaN), TRUE)$n_source_missing == 2L && all(is.na(numeric_summary(c(NA_real_, NaN), TRUE)[stat_columns])))
  hard("edge_mapping_first", numeric_summary(rep(NA_real_, 3), FALSE)$summary_status == "mapping_gap" &&
    numeric_summary(rep(NA_real_, 3), FALSE)$n_source_missing == 0L && numeric_summary(rep(NA_real_, 3), FALSE)$n_mapping_gap == 3L &&
    all(score_category(c(NA_real_, 7), FALSE) == 3L))
  singleton <- numeric_summary(c(NA_real_, 4), TRUE)
  hard("edge_finite_singleton", singleton$summary_status == "singleton" && is.na(singleton$sd) &&
    all(unlist(singleton[setdiff(stat_columns, "sd")]) == 4))
  infinite <- numeric_summary(c(Inf, NA_real_, NaN), TRUE)
  hard("edge_infinite_singleton_precedence", infinite$summary_status == "nonfinite_present" && infinite$n_nonfinite == 1L &&
    infinite$n_source_missing == 2L && all(is.na(infinite[stat_columns])))
  hard("edge_mixed_nonfinite", numeric_summary(c(-Inf, 2, NaN), TRUE)$summary_status == "nonfinite_present" &&
    numeric_summary(c(-Inf, 2, NaN), TRUE)$n_nonfinite == 1L && all(is.na(numeric_summary(c(-Inf, 2, NaN), TRUE)[stat_columns])))
  unused <- factor(c("a", NA, "a"), levels = c("a", "b")); ug <- category_grid(unused)
  hard("edge_unused_levels", identical(ug$category_label, c("a", "b", "")) &&
    identical(tabulate(category_index(unused, ug), nbins = 3), c(2L, 0L, 1L)))
  eg <- category_grid(factor(c(status_levels[2], NA), levels = status_levels), status_levels)
  ec <- tabulate(category_index(factor(c(status_levels[2], NA), levels = status_levels), eg), nbins = 9)
  hard("edge_empty_status_and_zero_denominators", length(ec) == 9L && ec[1] == 0L && ec[2] == 1L && ec[9] == 1L &&
    all(is.na(pct(c(0, 1, NA_real_), 0))) && is.na(pct(0, 0)) && same(pct(0, 2), 0))
  special <- numeric_summary(c(-7, 3, NA_real_), TRUE)
  hard("edge_retained_special_code", special$summary_status == "ok" && special$n_nonmissing == 2L && special$n_minus7 == 1L &&
    special$mean == -2 && special$min == -7 && same(special$sd, sd(c(-7, 3))) &&
    same(unlist(special[c("p05", "p25", "median", "p75", "p95")], use.names = FALSE), quantile(c(-7, 3), c(.05, .25, .5, .75, .95), type = 7, names = FALSE)) &&
    score_category(-7, TRUE) == 1L)
  hard("edge_two_wave_grid", identical(pattern_grid(c(TRUE, TRUE, FALSE, FALSE)), c("00MM", "01MM", "10MM", "11MM")) &&
    identical(pattern_grid(c(FALSE, FALSE, TRUE, TRUE)), c("MM00", "MM01", "MM10", "MM11")))
  repeated <- data.frame(child = rep(1:3, each = 2), wave = rep(c("KF", "KS"), 3), x = rep(c(2, 3, NA_real_), each = 2))
  hard("edge_repeated_context", sum(!is.na(repeated$x)) == 4L && sum(!is.na(repeated$x[repeated$wave == "KF"])) == 2L &&
    length(unique(mapply(occasion, counts[1], c("KF", "KS")))) == 1L && sum(B$field == counts[1]) == 1L &&
    all(B$n_children[B$field %in% c(weight, counts)] == n))
  hard("edge_literal_codes_preserve_labels", identical(comparison(1L, c(names(literal_code_maps$T_CHNGCP), ""),
    c(names(literal_code_maps$T_CHNG), ""), c(rep("released_value", 3), "source_missing"),
    c(rep("released_value", 3), "source_missing")), c(rep("literal_equal", 3), "source_missing")))
  hard("edge_no_identifier_codes", length(unique(c(NA_real_, NaN)[!is.na(c(NA_real_, NaN))])) == 0L)
  hard("no_child_level_output", identical(destinations, c(table_paths, checks_relative, review_relative)) &&
    all(vapply(tables, function(z) !any(c("STUDY_ID", "child_id", "teacher_id", "classroom_id") %in% names(z)), logical(1))))
  gate()

  # Serialize as UTF-8 with numeric NA literal and intentionally blank category/source strings.
  # Read everything back as literal cells first; compare numbers with serialization tolerance.
  csv_matches <- function(saved, expected) {
    identical(names(saved), names(expected)) && nrow(saved) == nrow(expected) && all(vapply(names(expected), function(f) {
      x <- expected[[f]]; s <- saved[[f]]
      if (is.numeric(x)) {
        if (!identical(s == "NA", is.na(x))) return(FALSE)
        parsed <- suppressWarnings(as.numeric(s))
        same(parsed, x)
      } else {
        identical(s, ifelse(is.na(x), "NA", as.character(x)))
      }
    }, logical(1)))
  }
  for (i in seq_along(tables)) {
    if (!is.null(previous_tables[[i]])) {
      hard(paste0("previous_run_contents_", table_names[i]), csv_matches(previous_tables[[i]], tables[[i]]),
           "same ordered schemas, keys, counts, labels, flags, NA cells and numeric values", "literal and numeric comparison")
    }
  }
  gate()
  for (i in seq_along(tables)) {
    write_csv(tables[[i]], table_paths[i])
    saved <- read_text_csv(table_paths[i])
    hard(paste0("saved_csv_", table_names[i]), csv_matches(saved, tables[[i]]) &&
      !anyDuplicated(saved[keys[[i]]]), "ordered full CSV round trip; tolerance 1e-12; literal NA and blank strings", nrow(saved))
  }
  table_hashes <- tools::md5sum(here::here(table_paths)); names(table_hashes) <- table_paths
  if (all(nzchar(previous_hashes))) {
    hard("second_run_identical_table_bytes", identical(unname(table_hashes), unname(previous_hashes)),
      "all nine table MD5 hashes unchanged", unname(table_hashes))
  } else record("second_run_required", "No complete prior table set; repeat the exact command in a fresh R session.")
  input_hash_after <- tools::md5sum(here::here(input_paths)); names(input_hash_after) <- input_paths
  hard("input_preservation", identical(input_hash_before, input_hash_after), "all input artifact/report/document hashes unchanged",
    paste(length(input_paths), "files checked; changed:", sum(input_hash_before != input_hash_after)))
  hard("final_outputs_ignored", all(vapply(destinations, function(p) identical(system2("git", c("check-ignore", "-q", "--", p)), 0L), logical(1))))
  record("execution_warnings", if (length(warnings_seen)) unique(warnings_seen) else "none during script execution",
         "Startup warnings emitted before this script are visible in the calling shell; set a supported locale before launching R.")
  hard("unique_check_ids", !anyDuplicated(c(checks$check_id, "unique_check_ids", "zero_failed_hard_checks")))
  hard("zero_failed_hard_checks", !any(checks$status == "fail"), "zero failures", sum(checks$status == "fail"))
  gate()
  write_csv(checks, checks_relative)
  if (!csv_matches(read_text_csv(checks_relative), checks)) stop("Verification CSV round trip failed.")

  git_head <- system2("git", c("rev-parse", "HEAD"), stdout = TRUE)
  git_state <- system2("git", c("status", "--short", "--branch"), stdout = TRUE)
  script_relative <- "code/revision/05_describe_released_panel.R"
  # A self-contained aggregate review; no individual identifiers or source records are printed.
  lines <- c("# Released-panel descriptive diagnostics and preliminary statistics", "",
    "## Execution and preservation", "",
    paste0("Repository HEAD: `", git_head, "`. Script MD5: `", unname(tools::md5sum(here::here(script_relative))), "`."),
    paste0("R executable: `", normalizePath(file.path(R.home("bin"), "Rscript.exe"), winslash = "/", mustWork = FALSE), "`."),
    "Command from the project root (PowerShell, process-local supported Windows locale):", "", "```powershell",
    "$env:LC_ALL = 'English_United States.utf8'",
    "& 'C:\\Program Files\\R\\R-4.6.1\\bin\\Rscript.exe' --vanilla code/revision/05_describe_released_panel.R", "```", "",
    if (all(nzchar(previous_hashes))) "Second fresh-process execution: all nine previous CSV contents and byte hashes match this run." else
      "First execution: repeat the command above in a second fresh session to establish table reproducibility.",
    paste0("Checks: ", nrow(checks), " rows, ", sum(checks$severity == "hard"), " hard, ", sum(checks$status == "fail"), " failed. Verification CSV itself read back successfully."),
    paste0("Preservation: ", length(input_paths), " inputs, upstream scripts, artifacts, reports and documentation files have identical before/after MD5 hashes."),
    "The Stage 03 and Stage 04 reports contain 35 and 485 passing historical hard checks. They were read, not regenerated. All new outputs remain ignored.",
    "No construction scripts were sourced. No data were cleaned, exposed, harmonized, selected, merged, weighted or modeled. No child-level analytic dataset was written.", "",
    "Environment:", "", "```text", capture.output(sessionInfo()), paste0("Locale: ", Sys.getlocale()),
    paste0("Warnings during script: ", if (length(warnings_seen)) paste(unique(warnings_seen), collapse = " | ") else "none"), "```", "",
    "## Output inventory", "", "| Table | Rows | Columns | MD5 |", "|---|---:|---:|---|",
    vapply(seq_along(tables), function(i) paste0("| `", table_paths[i], "` | ", nrow(tables[[i]]), " | ", ncol(tables[[i]]), " | `", table_hashes[i], "` |"), character(1)), "",
    "## Definitions and verification", "",
    "All-child denominators are 1,015 distinct DS0001 children. The 4,060 structural rows are a four-occasion representation, not four independent baseline/context observations per child.",
    "Field order follows the 37-column panel. Waves and pairs follow PF, PS, KF, KS. Factor grids preserve exact released level order and unused levels; observed numeric counts are ordered numerically; source missingness is last with a blank label.",
    "The independent contract has 148 field-wave decisions: 97 source mappings, 20 generated structural fields and 31 mapping gaps (31,465 intentional NA cells). Mapping gaps do not establish noncollection elsewhere in the release.",
    "Source-backed nonmissing values define observed support, including special codes. Status categories are not validity rules or score-specific completion/missing-reason definitions. DR is uninterpreted.",
    "Numeric summaries include every released nonmissing finite value, including all eight English Applied Problems -7 cells. No exclusion-based alternative is computed. Sample SD and type-7 quantiles are used.",
    "Summary precedence is mapping_gap, all_source_missing, nonfinite_present, singleton, ok. NaN is source missing; nonfinite counts exclude NA/NaN. Inf/-Inf suppress all distribution statistics. Singleton SD is NA. Undefined numeric cells serialize as literal NA.",
    "Beliefs describe child records with attached native-Fall values; class sizes describe child-attached values. Neither supplies unique teacher/classroom counts. All four change indicators, both classroom-count scopes and the released site weight are described once per documented occasion. Weights are not applied.",
    "Pair intersections with an absent mapping are undefined, with mapped marginals retained. Belief overlap is same-grade measurement overlap only; Fall beliefs are not assigned to Spring.",
    "All schemas, unique keys, row orders, categorical totals, source statistics, pattern/count distributions, wave/pair/belief intersections, context margins/cells, identifier counts and all 972 status-score cells are checked. Table I reconciles with Tables A/C, preserves zero/impossible cells and checks every denominator/percentage.",
    "Every CSV is read back to check exact schema/order/labels/flags/counts, literal NA and blank cells, and numeric values at tolerance 1e-12. Edge cases cover missing groups, gaps, finite/infinite singletons, mixed nonfinite values, unused factor/status levels, zero denominators, retained special codes, repeated context and mapping-limited patterns.",
    "Factor labels are verified directly against release Setup.do definitions and original wide-source levels. Pair 1 uses explicit label-to-code maps for T_CHNGCP and T_CHNG; literal equality is not substantive equivalence. Pair 3 compares literal counts across distinct scopes. Other comparisons have no equality interpretation.", "",
    "## Main descriptive findings", "",
    paste0("Native-Fall belief support: Pre-K ", B$n_nonmissing[B$field == beliefs[1]], "/1,015; Kindergarten ", B$n_nonmissing[B$field == beliefs[2]], "/1,015."),
    "The following assessment support counts are descriptive support, including retained special values; they do not define an analytic sample.", "",
    "| Assessment series | PF | PS | KF | KS | All mapped occasions observed | Zero observed |", "|---|---:|---:|---:|---:|---:|---:|",
    vapply(assessments, function(f) {
      bb <- B[B$field == f, ]; dd <- D[D$field == f & D$summary_type == "observed_wave_count", ]
      cells <- ifelse(bb$availability_status == "source_mapped", as.character(bb$n_nonmissing), "M")
      paste0("| ", f, " | ", paste(cells, collapse = " | "), " | ", dd$n_children[dd$n_observed_waves == sum(vapply(waves, function(w) mapped(f, w), logical(1)))],
        " | ", dd$n_children[dd$n_observed_waves == 0], " |")
    }, character(1)), "",
    "M means no approved mapping. For two-wave series, all mapped occasions observed means two occasions, not a four-wave observed panel.", "",
    "| Belief grade | Outcome | Belief + Fall | Belief + Spring | Belief + both outcomes |", "|---|---|---:|---:|---:|",
    vapply(seq_len(nrow(F)), function(i) paste0("| ", F$grade[i], " | ", F$outcome_field[i], " | ",
      fmt(F$n_belief_fall[i]), " | ", fmt(F$n_belief_spring[i]), " | ", fmt(F$n_belief_both[i]), " |"), character(1)), "",
    paste0("Eight released English Applied Problems -7 entries remain source nonmissing and enter distribution statistics: ",
      paste(paste0(english_ap$period, "=", english_ap$n_minus7), collapse = ", "), ". Two PS status observations retain (8) DR."),
    paste0("PF assessment status code 4 has ", C$n_children[C$field == "assessment_status_released" & C$period == "PF" & C$category_label == status_levels[4]],
      " children; the later-wave zero counts do not imply code 4 is absent at all waves."),
    paste0("Pre-K change flags: ", unique(G$denominator_pair_nonmissing[G$pair_id == 1]), " paired nonmissing child records; ",
      sum(G$n_children[G$pair_id == 1 & G$comparison_result == "literal_equal"]), " literal code equal, ",
      sum(G$n_children[G$pair_id == 1 & G$comparison_result == "literal_unequal"]), " literal code unequal. Distinct source meanings are preserved; no indicator is preferred."),
    paste0("Kindergarten classroom counts: ", unique(G$denominator_pair_nonmissing[G$pair_id == 3]), " paired nonmissing records; ",
      sum(G$n_children[G$pair_id == 3 & G$comparison_result == "literal_unequal"]),
      " have different released counts across distinct measurement scopes. Snapshot observations and ASMNT/TQ/TQSC/ECER/SNAP coverage are not reconciled or labeled errors."), "",
    "| Identifier/site occasion | Nonmissing | Distinct released codes | Min / median / max children per code |", "|---|---:|---:|---|",
    vapply(seq_len(nrow(H)), function(i) paste0("| ", H$field[i], " / ", H$period[i], " | ", H$n_nonmissing[i], " | ", H$n_distinct_released_codes[i],
      " | ", paste(c(H$min_children_per_code[i], H$median_children_per_code[i], H$max_children_per_code[i]), collapse = " / "), " |"), character(1)), "",
    "All site linkage claims remain not_established. STUDY_ID supports only the existing within-DS0001 child panel correspondence. Site codes are not teacher/classroom/school/state identities or established stable longitudinal grouping units.",
    "Existing Stage 1 identifier-audit results (not recomputed here): DS0002 CASEID is complete/unique across 794 rows; DS0003 CASEID is complete/unique across 245 rows; DS0003 LEAD_1 has 244 nonmissing observations and three distinct codes. These do not establish DS0001 linkage or a usable teacher identifier. No additional datasets were processed.", "",
    "## Substantive decision register", "",
    "Existing issue identifiers and meanings are preserved; no Q-numbers are reassigned.", "",
    "| Issue | Evidence or decision still needed | Deferred work |", "|---|---|---|",
    "| Q01: released belief construction and /16 | Release-specific scoring/derivation evidence; document conflict with older mean-score guidance | Rescaling, direction, harmonization and cross-grade variation |",
    "| Spring exposure and continuity | Approved exposure rule supported by timing and identity/change evidence | Spring assignment and longitudinal exposure definitions |",
    "| Q02: DR | Release-specific expansion beyond the label | Status interpretation/reclassification |",
    "| Q03: theoretical PPVT/Applied Problems bounds | Release-supported bounds; empirical extrema are insufficient | Valid-score rules and cleaning |",
    "| Special-code cleaning | Source-specific rules and authorization for a cleaned copy | Eligibility and later descriptions |",
    "| Q04: collapsed missing reasons | Release format retaining codes or documented recovery syntax | Missing-reason analyses |",
    "| Q05: DS0001-DS0002/DS0003 linkage | Explicit documented key/relationship | Cross-dataset merges |",
    "| Q06: LEAD_1 scope/usability | Uniqueness and population/period scope | Teacher identity, counts and nesting |",
    "| Q07: site interpretation | Hierarchical scope and cross-wave stability | Grouping-unit interpretation and inference feasibility |",
    "| Q08: distinct Pre-K change constructions | Derivation/reconciliation evidence | Preferred or combined change flag |",
    "| Distinct Kindergarten classroom-count scopes | Documentation connecting Snapshot and across-instrument coverage | Comparison beyond literal released counts |",
    "| Q09: English/Spanish assessment mapping and comparability | Exact separate Kindergarten Spanish-battery English-PPVT field and any conversion/equating rule | Language coverage and any combined outcomes |",
    "| Additional mappings | Documented eligible sources and approved upstream changes | Expanded panel coverage |",
    "| Weighting/target population | Sampling-design evidence and approved target | Weighted descriptions and estimation |",
    "| Analytic restrictions | Approved cleaning, exposure, controls and eligibility | Attrition and final analytic-sample descriptions |",
    "| Estimation/inference | Approved models and established dependence structure | Common samples, standard errors and regressions |", "",
    "Q09 documentary locator: docs/icpsr/04283-User_guide.pdf, PDF page 49, printed page 13, Spanish-Language Assessment Battery. The guide describes separate English PPVT variables for Kindergarten Spanish-battery children. This establishes the mapping question, not the released field. PPVTEKF/PPVTEKS are not assumed to contain those separately described scores. Q09 also preserves English/Spanish comparability and its PF code-4 assessment-status correction.",
    "The status/availability table describes released overlap; it cannot resolve Q02-Q04 or Q09. Missingness, low support, special values, code differences and distinct count scopes are findings, not automatic recoding or pipeline failures. No material source-label discrepancy requiring a contract change was found.", "",
    "## Input preservation ledger", "", "Paths are project-relative. Each entry has the same before/after hash.", "", "| Input | MD5 before | MD5 after |", "|---|---|---|",
    vapply(seq_along(input_paths), function(i) paste0("| `", input_paths[i], "` | `", input_hash_before[i], "` | `", input_hash_after[i], "` |"), character(1)), "",
    "## Git state at review generation", "", "```text", git_state, "```", "",
    "Review stopping point: no staging, committing or pushing is performed by this script.")
  writeLines(enc2utf8(lines), here::here(review_relative), useBytes = TRUE)
  if (!identical(readLines(here::here(review_relative), encoding = "UTF-8", warn = FALSE), unname(enc2utf8(lines)))) stop("Review read-back failed.")
  # Include review generation in the input-preservation boundary as well.
  final_input_hash <- tools::md5sum(here::here(input_paths)); names(final_input_hash) <- input_paths
  if (!identical(input_hash_before, final_input_hash)) stop("An upstream input changed during report generation.")
  message("Descriptive tables: ", paste(paste0(table_names, "=", vapply(tables, nrow, integer(1)), "x", vapply(tables, ncol, integer(1))), collapse = "; "))
  message("Checks: ", nrow(checks), " total; ", sum(checks$severity == "hard"), " hard; 0 failed. All CSVs and review read back; inputs preserved.")
  message(if (all(nzchar(previous_hashes))) "Second-run table contents and bytes identical." else "Run again in a fresh R session for reproducibility verification.")
}, warning = function(w) {
  warnings_seen <<- c(warnings_seen, conditionMessage(w))
  invokeRestart("muffleWarning")
}), error = function(e) {
  hard("execution_error", FALSE, "successful verified descriptive run", conditionMessage(e),
       "Do not treat any existing descriptive outputs as a successful current run until all checks pass.")
  write_csv(checks, checks_relative)
  stop(conditionMessage(e), ". See ", checks_relative, call. = FALSE)
})
