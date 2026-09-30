project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
git_root_raw <- system2(
  "git", c("rev-parse", "--show-toplevel"),
  stdout = TRUE, stderr = TRUE
)
git_status <- attr(git_root_raw, "status")
if (!is.null(git_status) && git_status != 0L) {
  stop("Unable to determine the Git repository root: ", paste(git_root_raw, collapse = " "))
}
git_root <- normalizePath(git_root_raw[[1]], winslash = "/", mustWork = TRUE)
if (!identical(project_start, git_root) || !identical(basename(git_root), "ICPSR_04283")) {
  stop("Run this script from the ICPSR_04283 Git root; got ", project_start, ".")
}

Sys.setenv(
  RENV_PATHS_ROOT = file.path(project_start, "renv", "local"),
  RENV_CONFIG_SANDBOX_ENABLED = "FALSE",
  RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE"
)
activate_file <- file.path(project_start, "renv", "activate.R")
if (!file.exists(activate_file)) stop("Missing renv/activate.R.")
source(activate_file)
suppressPackageStartupMessages(library(here))

project_root <- normalizePath(here::here(), winslash = "/", mustWork = TRUE)
if (!identical(project_start, project_root) || !identical(project_root, git_root)) {
  stop("Run this script from the project Git root.")
}

verified_allowlist <- c(
  "STUDY_ID",
  "T_IDEAP",
  "T_IDEAK",
  "PPVTEPF",
  "PPVTEPS",
  "PPVTEKF",
  "PPVTEKS",
  "WJ10_SSEPF",
  "WJ10_SSEPS",
  "WJ10_SSEKF",
  "WJ10_SSEKS",
  "WJ21AEPF",
  "WJ21AEPS",
  "WJ21AEKF",
  "WJ21AEKS",
  "ASMSTATPF",
  "ASMSTATPS",
  "ASMSTATKF",
  "ASMSTATKS",
  "CLS_SIZEPF",
  "CLS_SIZEPS",
  "CLS_SIZEKF",
  "CLS_SIZEKS",
  "CHGENP",
  "CHRACE_AAP",
  "CHRACE_ASP",
  "CHRACE_LTP",
  "CHRACE_NAP",
  "CHRACE_WHP",
  "CHINCOMCP",
  "CHMATEDCP",
  "T_CHNGCP",
  "T_CHNG",
  "TCHCHNGK",
  "CLASSCHNGK",
  "SNAPCLASSK",
  "NUMCLSRMK",
  "SITE_PF",
  "SITE_PS",
  "SITE_TRPS",
  "SITE_ECK",
  "SITE_TRKF",
  "SITE_TRKS",
  "SITE_WT",
  "TVIPSPF",
  "TVIPRSPF",
  "WM25SSPF",
  "WM25WPF",
  "TVIPSPS",
  "TVIPRSPS",
  "WM25SSPS",
  "WM25WPS",
  "TVIPSKF",
  "WM25SSKF",
  "WM25WKF",
  "WM22SSKF",
  "WM22WKF",
  "TVIPSKS",
  "WM22SSKS",
  "WM22WKS",
  "WM25SSKS",
  "WM25WKS"
)

source_relative <- "Data/raw/icpsr_04283/04283-0001-Data.rda"
manifest_relative <- "docs/icpsr/04283-manifest.txt"
crosswalk_relative <- "docs/stage1_variable_crosswalk.csv"
source_path <- here(source_relative)
manifest_path <- here(manifest_relative)
crosswalk_path <- here(crosswalk_relative)
verified_data_path <- here("Data", "processed", "verified_child_wide.rds")
provenance_path <- here("output", "tables", "verified_wide_provenance.csv")
checks_path <- here("output", "verification", "verified_wide_checks.csv")
expected_md5 <- "e1dd29c3fe46e0ac1ebb90f51ef041d3"

checks <- data.frame(
  check_id = character(),
  severity = character(),
  expected = character(),
  observed = character(),
  status = character(),
  detail = character(),
  stringsAsFactors = FALSE
)

format_observed <- function(x) {
  if (length(x) == 0L) return("<none>")
  if (length(x) > 1L) return(paste(x, collapse = " | "))
  if (is.na(x)) return("<missing>")
  as.character(x)
}

add_check <- function(check_id, severity, expected, observed, status, detail = "") {
  checks <<- rbind(
    checks,
    data.frame(
      check_id = check_id,
      severity = severity,
      expected = format_observed(expected),
      observed = format_observed(observed),
      status = status,
      detail = detail,
      stringsAsFactors = FALSE
    )
  )
}

add_hard_check <- function(check_id, condition, expected, observed, detail = "") {
  add_check(
    check_id = check_id,
    severity = "hard",
    expected = expected,
    observed = observed,
    status = if (isTRUE(condition)) "pass" else "fail",
    detail = detail
  )
}

write_checks <- function() {
  dir.create(dirname(checks_path), recursive = TRUE, showWarnings = FALSE)
  write.csv(
    checks,
    checks_path,
    row.names = FALSE,
    na = "",
    fileEncoding = "UTF-8"
  )
}

stop_on_hard_failure <- function(context) {
  failed <- checks$severity == "hard" & checks$status == "fail"
  if (any(failed)) {
    write_checks()
    stop(
      context, ": ",
      paste(checks$check_id[failed], collapse = ", "),
      ". See output/verification/verified_wide_checks.csv."
    )
  }
}

add_hard_check(
  "project_root",
  identical(project_start, project_root) && identical(project_root, git_root),
  "working directory = here root = Git root",
  paste(project_start, project_root, git_root, sep = " | "),
  "The construction must run from the verified project root."
)

required_paths <- c(source_path, manifest_path, crosswalk_path)
required_exists <- file.exists(required_paths)
add_hard_check(
  "required_inputs_present",
  all(required_exists),
  paste(c(source_relative, manifest_relative, crosswalk_relative), collapse = " | "),
  paste(
    paste0(c(source_relative, manifest_relative, crosswalk_relative), "=", required_exists),
    collapse = " | "
  ),
  "DS0001 and both tracked metadata inputs are required."
)
add_hard_check(
  "explicit_allowlist_size",
  length(verified_allowlist) == 62L,
  "62 names",
  paste0(length(verified_allowlist), " names")
)
add_hard_check(
  "explicit_allowlist_unique",
  !anyDuplicated(verified_allowlist),
  "62 unique names",
  paste0(length(unique(verified_allowlist)), " unique names")
)
stop_on_hard_failure("Pre-import validation failed")

manifest_lines <- readLines(manifest_path, warn = FALSE, encoding = "UTF-8")
manifest_matches <- grep(
  "^[[:space:]]*04283-0001-Data[.]rda[[:space:]]+",
  manifest_lines,
  value = TRUE
)
manifest_md5 <- if (length(manifest_matches) == 1L) {
  fields <- strsplit(trimws(manifest_matches), "[[:space:]]+")[[1]]
  tolower(fields[[length(fields)]])
} else {
  NA_character_
}
add_hard_check(
  "manifest_ds0001_rda_entry",
  length(manifest_matches) == 1L,
  "exactly one 04283-0001-Data.rda entry",
  paste0(length(manifest_matches), " entries")
)
add_hard_check(
  "manifest_ds0001_rda_md5",
  identical(manifest_md5, expected_md5),
  expected_md5,
  manifest_md5,
  "The release manifest must contain the approved DS0001 RDA checksum."
)

source_md5_before <- tolower(unname(tools::md5sum(source_path)))
add_hard_check(
  "source_ds0001_rda_md5",
  identical(source_md5_before, expected_md5),
  expected_md5,
  source_md5_before
)
add_hard_check(
  "source_manifest_md5_agreement",
  identical(source_md5_before, manifest_md5),
  manifest_md5,
  source_md5_before
)
stop_on_hard_failure("Source checksum validation failed")

source_environment <- new.env(parent = baseenv())
loaded_names <- load(source_path, envir = source_environment)
add_hard_check(
  "isolated_load_object",
  identical(loaded_names, "da04283.0001"),
  "da04283.0001 only",
  loaded_names,
  "DS0001 is loaded into an isolated environment."
)
stop_on_hard_failure("Isolated load validation failed")

source_data <- source_environment[["da04283.0001"]]
add_hard_check(
  "source_is_data_frame",
  is.data.frame(source_data),
  "data.frame",
  paste(class(source_data), collapse = " | ")
)
stop_on_hard_failure("Source object validation failed")

source_dimensions <- dim(source_data)
add_hard_check(
  "source_dimensions",
  identical(as.integer(source_dimensions), c(1015L, 1210L)),
  "1015 x 1210",
  paste(source_dimensions, collapse = " x ")
)
add_hard_check(
  "source_column_names_unique",
  !anyDuplicated(names(source_data)),
  "1210 unique source column names",
  paste0(length(unique(names(source_data))), " unique of ", ncol(source_data))
)

source_md5_after <- tolower(unname(tools::md5sum(source_path)))
add_hard_check(
  "source_file_unchanged_during_load",
  identical(source_md5_before, source_md5_after),
  source_md5_before,
  source_md5_after
)
stop_on_hard_failure("Source structure validation failed")

crosswalk <- read.csv(
  crosswalk_path,
  stringsAsFactors = FALSE,
  check.names = FALSE,
  na.strings = character(),
  encoding = "UTF-8"
)
required_crosswalk_columns <- c(
  "dataset_id", "raw_variable", "raw_label", "wave", "assessment_language",
  "transformation_status", "documentation_status", "review_status",
  "conflict_or_question_id", "permitted_transformation", "source_document",
  "source_page_or_section"
)
missing_crosswalk_columns <- setdiff(required_crosswalk_columns, names(crosswalk))
add_hard_check(
  "crosswalk_required_columns",
  length(missing_crosswalk_columns) == 0L,
  paste(required_crosswalk_columns, collapse = " | "),
  if (length(missing_crosswalk_columns) == 0L) "all present" else paste(missing_crosswalk_columns, collapse = " | ")
)
stop_on_hard_failure("Crosswalk schema validation failed")

crosswalk_key <- paste(crosswalk$dataset_id, crosswalk$raw_variable, sep = "::")
dataset_counts <- table(factor(crosswalk$dataset_id, levels = c("DS0001", "DS0002", "DS0003")))
add_hard_check(
  "crosswalk_row_count",
  nrow(crosswalk) == 66L,
  "66 rows",
  paste0(nrow(crosswalk), " rows")
)
add_hard_check(
  "crosswalk_unique_dataset_variable_rows",
  !anyDuplicated(crosswalk_key),
  "66 unique dataset-variable rows",
  paste0(length(unique(crosswalk_key)), " unique rows")
)
add_hard_check(
  "crosswalk_dataset_distribution",
  identical(as.integer(dataset_counts), c(62L, 1L, 3L)),
  "DS0001=62 | DS0002=1 | DS0003=3",
  paste(paste0(names(dataset_counts), "=", as.integer(dataset_counts)), collapse = " | ")
)

ds0001_crosswalk_variables <- crosswalk$raw_variable[crosswalk$dataset_id == "DS0001"]
add_hard_check(
  "crosswalk_ds0001_order_matches_allowlist",
  identical(ds0001_crosswalk_variables, verified_allowlist),
  paste(verified_allowlist, collapse = " | "),
  paste(ds0001_crosswalk_variables, collapse = " | "),
  "The allowlist is defined independently and must match the ordered DS0001 crosswalk rows."
)

missing_source_variables <- setdiff(verified_allowlist, names(source_data))
add_hard_check(
  "allowlisted_variables_present",
  length(missing_source_variables) == 0L,
  "all 62 allowlisted variables present",
  if (length(missing_source_variables) == 0L) "all present" else paste(missing_source_variables, collapse = " | ")
)
stop_on_hard_failure("Crosswalk and allowlist validation failed")

verified_wide <- source_data[, verified_allowlist, drop = FALSE]
add_hard_check(
  "output_dimensions",
  identical(as.integer(dim(verified_wide)), c(1015L, 62L)),
  "1015 x 62",
  paste(dim(verified_wide), collapse = " x ")
)
add_hard_check(
  "output_column_names_unique",
  !anyDuplicated(names(verified_wide)),
  "62 unique output column names",
  paste0(length(unique(names(verified_wide))), " unique of ", ncol(verified_wide))
)
add_hard_check(
  "output_names_match_allowlist",
  identical(names(verified_wide), verified_allowlist),
  paste(verified_allowlist, collapse = " | "),
  paste(names(verified_wide), collapse = " | ")
)
add_hard_check(
  "output_has_no_extra_variables",
  length(setdiff(names(verified_wide), verified_allowlist)) == 0L,
  "no variables outside the allowlist",
  format_observed(setdiff(names(verified_wide), verified_allowlist))
)
add_hard_check(
  "study_id_complete",
  !anyNA(verified_wide$STUDY_ID),
  "0 missing values",
  paste0(sum(is.na(verified_wide$STUDY_ID)), " missing values")
)
add_hard_check(
  "study_id_unique",
  !anyDuplicated(verified_wide$STUDY_ID),
  "1015 unique values",
  paste0(length(unique(verified_wide$STUDY_ID)), " unique values")
)
add_hard_check(
  "study_id_source_sequence",
  identical(verified_wide$STUDY_ID, source_data$STUDY_ID),
  "identical to the source STUDY_ID sequence",
  if (identical(verified_wide$STUDY_ID, source_data$STUDY_ID)) "identical" else "different"
)

column_identity <- vapply(
  verified_allowlist,
  function(variable) identical(verified_wide[[variable]], source_data[[variable]]),
  logical(1)
)
add_hard_check(
  "all_output_columns_identical_to_source",
  all(column_identity),
  "62 identical columns",
  paste0(sum(column_identity), " identical columns"),
  if (all(column_identity)) "Values, missingness, classes, levels, and attributes are preserved." else {
    paste("Non-identical columns:", paste(names(column_identity)[!column_identity], collapse = " | "))
  }
)
stop_on_hard_failure("Verified-wide construction validation failed")

is_ds0001 <- crosswalk$dataset_id == "DS0001"
provenance_additions <- data.frame(
  output_variable = ifelse(is_ds0001, crosswalk$raw_variable, ""),
  verified_wide_classification = ifelse(
    is_ds0001,
    "INCLUDE_RAW",
    "NOT_NEEDED_FOR_VERIFIED_WIDE"
  ),
  included_in_output = is_ds0001,
  transformation_applied = "none",
  blocked_or_unapproved_action = ifelse(
    crosswalk$transformation_status %in% c("blocked", "proposed_not_approved"),
    crosswalk$permitted_transformation,
    ""
  ),
  stringsAsFactors = FALSE
)
provenance <- cbind(crosswalk, provenance_additions)
provenance_first <- c(
  "dataset_id", "raw_variable", "output_variable", "wave", "assessment_language",
  "verified_wide_classification", "included_in_output", "transformation_status",
  "transformation_applied", "documentation_status", "review_status",
  "conflict_or_question_id", "blocked_or_unapproved_action", "source_document",
  "source_page_or_section"
)
provenance <- provenance[c(provenance_first, setdiff(names(provenance), provenance_first))]

provenance_key <- paste(provenance$dataset_id, provenance$raw_variable, sep = "::")
ds0001_provenance_valid <- with(
  provenance[is_ds0001, , drop = FALSE],
  verified_wide_classification == "INCLUDE_RAW" &
    included_in_output &
    output_variable == raw_variable &
    transformation_applied == "none"
)
non_ds0001_provenance_valid <- with(
  provenance[!is_ds0001, , drop = FALSE],
  verified_wide_classification == "NOT_NEEDED_FOR_VERIFIED_WIDE" &
    !included_in_output &
    output_variable == "" &
    transformation_applied == "none"
)
add_hard_check(
  "provenance_row_count",
  nrow(provenance) == 66L,
  "66 rows",
  paste0(nrow(provenance), " rows")
)
add_hard_check(
  "provenance_unique_decisions",
  !anyDuplicated(provenance_key),
  "66 unique dataset-variable decisions",
  paste0(length(unique(provenance_key)), " unique decisions")
)
add_hard_check(
  "provenance_preserves_crosswalk_fields",
  identical(provenance[names(crosswalk)], crosswalk),
  "all original crosswalk fields unchanged",
  if (identical(provenance[names(crosswalk)], crosswalk)) "unchanged" else "different"
)
add_hard_check(
  "provenance_ds0001_classification",
  length(ds0001_provenance_valid) == 62L && all(ds0001_provenance_valid),
  "62 INCLUDE_RAW, included, same-name, untransformed rows",
  paste0(sum(ds0001_provenance_valid), " valid of ", length(ds0001_provenance_valid))
)
add_hard_check(
  "provenance_non_ds0001_classification",
  length(non_ds0001_provenance_valid) == 4L && all(non_ds0001_provenance_valid),
  "4 NOT_NEEDED_FOR_VERIFIED_WIDE, excluded, blank-output, untransformed rows",
  paste0(sum(non_ds0001_provenance_valid), " valid of ", length(non_ds0001_provenance_valid))
)
add_hard_check(
  "provenance_no_transformations_applied",
  all(provenance$transformation_applied == "none"),
  "66 transformation_applied = none rows",
  paste0(sum(provenance$transformation_applied == "none"), " none rows")
)
stop_on_hard_failure("Provenance validation failed")

dir.create(dirname(verified_data_path), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(provenance_path), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(checks_path), recursive = TRUE, showWarnings = FALSE)

saveRDS(verified_wide, verified_data_path)
verified_wide_readback <- readRDS(verified_data_path)
add_hard_check(
  "rds_round_trip_identity",
  identical(verified_wide_readback, verified_wide),
  "readRDS output identical to in-memory object",
  if (identical(verified_wide_readback, verified_wide)) "identical" else "different"
)
stop_on_hard_failure("Saved RDS validation failed")

write.csv(
  provenance,
  provenance_path,
  row.names = FALSE,
  na = "",
  fileEncoding = "UTF-8"
)

review_documentation <- crosswalk$documentation_status %in% c("partial", "conflict", "unresolved")
for (i in which(review_documentation)) {
  add_check(
    paste0("review_documentation_", tolower(crosswalk$dataset_id[[i]]), "_", tolower(crosswalk$raw_variable[[i]])),
    "review",
    "documentation status recorded",
    crosswalk$documentation_status[[i]],
    "review",
    paste0(
      crosswalk$dataset_id[[i]], "::", crosswalk$raw_variable[[i]],
      " remains raw and unchanged; documentary limitations remain unresolved for affected uses."
    )
  )
}

review_transformation <- crosswalk$transformation_status %in% c("blocked", "proposed_not_approved")
for (i in which(review_transformation)) {
  add_check(
    paste0("review_transformation_", tolower(crosswalk$dataset_id[[i]]), "_", tolower(crosswalk$raw_variable[[i]])),
    "review",
    "blocked or unapproved action recorded without applying it",
    crosswalk$transformation_status[[i]],
    "review",
    crosswalk$permitted_transformation[[i]]
  )
}

question_rows <- nzchar(crosswalk$conflict_or_question_id) &
  grepl("Q0[1-9]", crosswalk$conflict_or_question_id)
for (i in which(question_rows)) {
  add_check(
    paste0("review_question_", tolower(crosswalk$dataset_id[[i]]), "_", tolower(crosswalk$raw_variable[[i]])),
    "review",
    "Q01-Q09 reference retained",
    crosswalk$conflict_or_question_id[[i]],
    "review",
    paste0(crosswalk$dataset_id[[i]], "::", crosswalk$raw_variable[[i]])
  )
}

for (variable in verified_allowlist) {
  missing_n <- sum(is.na(verified_wide[[variable]]))
  add_check(
    paste0("missingness_", tolower(variable)),
    "info",
    "missingness recorded without filtering",
    paste0(missing_n, " of ", nrow(verified_wide)),
    "recorded",
    "All 1,015 source rows are retained."
  )
}

matches_released_code <- function(x, code) {
  text <- trimws(as.character(x))
  code_text <- as.character(code)
  !is.na(text) & (
    text == code_text |
      grepl(paste0("^[(]", code_text, "[)](?:[[:space:]]|$)"), text, perl = TRUE) |
      grepl(paste0("^", code_text, "(?:[[:space:]]*=[[:space:]]*|[[:space:]]+)"), text, perl = TRUE)
  )
}

applied_problems_variables <- crosswalk$raw_variable[
  crosswalk$dataset_id == "DS0001" &
    grepl("APP PROB", crosswalk$raw_label, fixed = TRUE)
]
applied_problems_minus_seven <- sum(vapply(
  applied_problems_variables,
  function(variable) sum(matches_released_code(verified_wide[[variable]], -7L)),
  integer(1)
))
add_check(
  "review_applied_problems_minus_7",
  "review",
  "8 released -7 Applied Problems values retained unchanged",
  paste0(applied_problems_minus_seven, " retained values"),
  if (applied_problems_minus_seven == 8L) "review" else "review_mismatch",
  paste("Documented Applied Problems variables:", paste(applied_problems_variables, collapse = " | "))
)

asmstatps_dr_n <- sum(matches_released_code(verified_wide$ASMSTATPS, 8L))
add_check(
  "review_asmstatps_code_8_dr",
  "review",
  "released ASMSTATPS code 8 retained without reinterpretation",
  paste0(asmstatps_dr_n, " observations"),
  "review",
  "Code 8 (DR) is recorded but not recoded or expanded."
)

add_check(
  "review_identifier_limitations",
  "review",
  "no documented teacher, classroom, school, or state identifier inferred",
  "STUDY_ID is the sole structural identifier used",
  "review",
  "No teacher/classroom/site linkage or clustering identifier is constructed."
)
add_check(
  "review_site_interpretation_limitations",
  "review",
  "SITE_* fields retain only their documented meanings",
  "retained raw; SITE_WT not used as an identifier",
  "review",
  "Site fields are not relabeled as teacher, classroom, school, or state identifiers."
)

pending_review <- crosswalk$review_status == "pending"
for (i in which(pending_review)) {
  add_check(
    paste0("review_pending_", tolower(crosswalk$dataset_id[[i]]), "_", tolower(crosswalk$raw_variable[[i]])),
    "review",
    "pending review status retained",
    "pending",
    "review",
    paste0(crosswalk$dataset_id[[i]], "::", crosswalk$raw_variable[[i]])
  )
}

add_check(
  "review_assessment_languages_separate",
  "review",
  "English and Spanish assessment batteries remain separate",
  "separate released columns retained",
  "review",
  "No pooling, equating, conversion, or imputation was applied across languages."
)

row_names_identical <- identical(row.names(verified_wide), row.names(source_data))
add_check(
  "row_names_consistency",
  "info",
  "row-name equality is informational only",
  if (row_names_identical) "identical" else "different",
  if (row_names_identical) "pass" else "info",
  "Row names are not treated as an ICPSR identifier."
)

completed_check_ids <- c(checks$check_id, "verification_check_ids_unique")
add_hard_check(
  "verification_check_ids_unique",
  !anyDuplicated(completed_check_ids),
  "unique check_id values",
  paste0(length(unique(completed_check_ids)), " unique of ", length(completed_check_ids))
)
stop_on_hard_failure("Verification report validation failed")
write_checks()

hard_results <- checks[checks$severity == "hard", , drop = FALSE]
nonfatal_results <- checks[checks$severity != "hard", , drop = FALSE]
message("Verified-wide construction completed.")
message("Source dimensions: ", paste(source_dimensions, collapse = " x "))
message("Output dimensions: ", paste(dim(verified_wide), collapse = " x "))
message(
  "Hard checks: ", sum(hard_results$status == "pass"), " passed; ",
  sum(hard_results$status == "fail"), " failed."
)
message(
  "Nonfatal records: ", nrow(nonfatal_results), " total; ",
  sum(nonfatal_results$severity == "review"), " review; ",
  sum(nonfatal_results$severity == "info"), " informational."
)
message(
  "Provenance classifications: ",
  sum(provenance$verified_wide_classification == "INCLUDE_RAW"), " INCLUDE_RAW; ",
  sum(provenance$verified_wide_classification == "NOT_NEEDED_FOR_VERIFIED_WIDE"),
  " NOT_NEEDED_FOR_VERIFIED_WIDE."
)
