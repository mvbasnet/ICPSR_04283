project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
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
git_root <- normalizePath(
  system2("git", c("rev-parse", "--show-toplevel"), stdout = TRUE)[[1]],
  winslash = "/",
  mustWork = TRUE
)
if (!identical(project_start, project_root) || !identical(project_root, git_root)) {
  stop("Run this script from the project Git root.")
}

crosswalk_path <- here("docs", "stage1_variable_crosswalk.csv")
if (!file.exists(crosswalk_path)) stop("Missing documentary crosswalk: docs/stage1_variable_crosswalk.csv")
crosswalk <- read.csv(
  crosswalk_path,
  stringsAsFactors = FALSE,
  check.names = FALSE,
  na.strings = character(),
  encoding = "UTF-8"
)

required_columns <- c(
  "dataset_id", "raw_variable", "proposed_construct", "wave", "grade",
  "collection_period", "respondent_source", "raw_label", "score_type",
  "documented_valid_min", "documented_valid_max", "value_labels",
  "documented_special_codes", "assessment_language", "raw_or_derived",
  "documented_scoring_derivation", "permitted_transformation",
  "transformation_status", "source_tier", "source_document",
  "source_page_or_section", "documentation_status", "conflict_or_question_id",
  "review_status", "review_notes"
)
missing_columns <- setdiff(required_columns, names(crosswalk))
if (length(missing_columns) > 0L) stop("Crosswalk is missing columns: ", paste(missing_columns, collapse = ", "))

empirical_names <- c(
  "observed_r_class", "observed_nonmissing_n", "observed_min", "observed_max",
  "observed_levels", "special_code_observed", "rda_missing_code_retention",
  "variable_exists", "documented_range_match", "documented_code_match",
  "validation_status", "validation_note"
)
forbidden <- intersect(empirical_names, names(crosswalk))
if (length(forbidden) > 0L) {
  stop("Empirical fields must not appear in the tracked documentary crosswalk: ", paste(forbidden, collapse = ", "))
}
if (anyDuplicated(crosswalk[c("dataset_id", "raw_variable")])) {
  stop("Crosswalk contains duplicate dataset_id/raw_variable rows.")
}

allowed_documentation <- c("verified", "partial", "conflict", "unresolved")
allowed_transformation <- c("none", "proposed_not_approved", "approved", "blocked")
allowed_review <- c("pending", "reviewed", "approved", "rejected", "not_applicable")
if (any(!crosswalk$documentation_status %in% allowed_documentation)) stop("Invalid documentation_status value.")
if (any(!crosswalk$transformation_status %in% allowed_transformation)) stop("Invalid transformation_status value.")
if (any(!crosswalk$review_status %in% allowed_review)) stop("Invalid review_status value.")
if (any(crosswalk$transformation_status == "approved")) {
  stop("This tranche does not authorize any new transformation_status = approved rows.")
}
verified <- crosswalk$documentation_status == "verified"
if (any(verified & (!nzchar(crosswalk$source_document) | !nzchar(crosswalk$source_page_or_section)))) {
  stop("Every verified row must include a documentary source and usable locator.")
}

source_specs <- list(
  DS0001 = list(file = "Data/raw/icpsr_04283/04283-0001-Data.rda", object = "da04283.0001"),
  DS0002 = list(file = "Data/raw/icpsr_04283/04283-0002-Data.rda", object = "da04283.0002"),
  DS0003 = list(file = "Data/raw/icpsr_04283/04283-0003-Data.rda", object = "da04283.0003")
)
unknown_datasets <- setdiff(unique(crosswalk$dataset_id), names(source_specs))
if (length(unknown_datasets) > 0L) stop("Unknown dataset_id: ", paste(unknown_datasets, collapse = ", "))

raw_data <- list()
for (dataset_id in names(source_specs)) {
  isolated <- new.env(parent = baseenv())
  loaded <- load(here(source_specs[[dataset_id]]$file), envir = isolated)
  if (!identical(loaded, source_specs[[dataset_id]]$object)) {
    stop(dataset_id, " loaded unexpected object(s): ", paste(loaded, collapse = ", "))
  }
  raw_data[[dataset_id]] <- isolated[[loaded]]
}

extract_special_codes <- function(text) {
  if (!nzchar(text)) return(numeric())
  hits <- regmatches(text, gregexpr("-[0-9]+(?:[.][0-9]+)?", text, perl = TRUE))[[1]]
  if (identical(hits, character(0)) || identical(hits, "")) numeric() else unique(as.numeric(hits))
}

documented_label_codes <- function(text) {
  if (!nzchar(text)) return(character())
  entries <- strsplit(text, "[[:space:]]+[|][[:space:]]+")[[1]]
  normalize_codes(trimws(sub("=.*$", "", entries)))
}

observed_factor_codes <- function(levels_text) {
  if (length(levels_text) == 0L) return(character())
  normalize_codes(sub("^[(]([^)]*)[)].*$", "\\1", levels_text))
}

normalize_codes <- function(codes) {
  numeric_codes <- suppressWarnings(as.numeric(codes))
  ifelse(is.na(numeric_codes), codes, format(numeric_codes, trim = TRUE, scientific = FALSE))
}

format_number <- function(x) {
  if (length(x) == 0L || is.na(x)) return(NA_character_)
  format(x, trim = TRUE, scientific = FALSE, digits = 15)
}

validation_rows <- lapply(seq_len(nrow(crosswalk)), function(i) {
  spec <- crosswalk[i, , drop = FALSE]
  dataset <- raw_data[[spec$dataset_id]]
  exists <- spec$raw_variable %in% names(dataset)
  if (!exists) {
    empirical <- data.frame(
      observed_r_class = NA_character_, observed_nonmissing_n = NA_integer_,
      observed_min = NA_character_, observed_max = NA_character_, observed_levels = NA_character_,
      special_code_observed = NA_character_, rda_missing_code_retention = NA_character_,
      variable_exists = FALSE, documented_range_match = "not_assessed_variable_missing",
      documented_code_match = "not_assessed_variable_missing", validation_status = "fail",
      validation_note = "Variable is absent from the stated released dataset.", stringsAsFactors = FALSE
    )
    return(cbind(spec, empirical))
  }

  value <- dataset[[spec$raw_variable]]
  nonmissing <- !is.na(value)
  special_codes <- extract_special_codes(spec$documented_special_codes)
  numeric_values <- if (is.numeric(value) && !is.factor(value)) value[nonmissing] else numeric()
  retained_special <- if (length(numeric_values) > 0L && length(special_codes) > 0L) {
    intersect(unique(numeric_values), special_codes)
  } else {
    numeric()
  }
  valid_numeric <- if (length(numeric_values) > 0L) numeric_values[!numeric_values %in% special_codes] else numeric()
  doc_min <- suppressWarnings(as.numeric(spec$documented_valid_min))
  doc_max <- suppressWarnings(as.numeric(spec$documented_valid_max))
  range_match <- if (!nzchar(spec$documented_valid_min) && !nzchar(spec$documented_valid_max)) {
    "not_assessed_documented_bound_missing"
  } else if (length(valid_numeric) == 0L) {
    "not_assessed_non_numeric_or_empty"
  } else if ((!is.na(doc_min) && min(valid_numeric) < doc_min) || (!is.na(doc_max) && max(valid_numeric) > doc_max)) {
    "mismatch"
  } else {
    "match"
  }

  doc_codes <- documented_label_codes(spec$value_labels)
  factor_codes <- if (is.factor(value)) observed_factor_codes(levels(value)) else character()
  code_match <- if (length(doc_codes) == 0L) {
    "not_assessed_no_documented_labels"
  } else if (!is.factor(value)) {
    "not_assessed_released_value_not_factor"
  } else if (setequal(doc_codes, factor_codes)) {
    "match"
  } else {
    "mismatch"
  }

  retention <- if (length(special_codes) == 0L) {
    "not_applicable"
  } else if (length(retained_special) > 0L) {
    "some_documented_codes_retained"
  } else {
    "documented_codes_not_observed_in_nonmissing_values"
  }
  status <- if (identical(range_match, "mismatch") && spec$documentation_status == "verified") {
    "fail"
  } else if (identical(code_match, "mismatch") && spec$documentation_status == "verified") {
    "fail"
  } else if (spec$documentation_status %in% c("partial", "conflict", "unresolved") ||
             identical(range_match, "mismatch") || length(retained_special) > 0L) {
    "review_needed"
  } else {
    "pass"
  }
  notes <- character()
  if (identical(range_match, "mismatch")) notes <- c(notes, "Released values fall outside documented bounds after excluding documented special codes.")
  if (identical(code_match, "mismatch")) notes <- c(notes, "Released factor levels do not match documentary value-label codes.")
  if (length(retained_special) > 0L) notes <- c(notes, paste0("Retained documented special code(s): ", paste(retained_special, collapse = " | "), "."))
  if (spec$documentation_status %in% c("partial", "conflict", "unresolved")) notes <- c(notes, paste0("Documentation status is ", spec$documentation_status, "."))

  empirical <- data.frame(
    observed_r_class = paste(class(value), collapse = " | "),
    observed_nonmissing_n = sum(nonmissing),
    observed_min = if (length(numeric_values) > 0L) format_number(min(numeric_values)) else NA_character_,
    observed_max = if (length(numeric_values) > 0L) format_number(max(numeric_values)) else NA_character_,
    observed_levels = if (is.factor(value)) paste(levels(value), collapse = " | ") else "",
    special_code_observed = if (length(retained_special) > 0L) paste(retained_special, collapse = " | ") else "",
    rda_missing_code_retention = retention,
    variable_exists = TRUE,
    documented_range_match = range_match,
    documented_code_match = code_match,
    validation_status = status,
    validation_note = paste(notes, collapse = " "),
    stringsAsFactors = FALSE
  )
  cbind(spec, empirical)
})

validation <- do.call(rbind, validation_rows)
table_dir <- here("output", "tables")
dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(
  validation,
  file.path(table_dir, "crosswalk_validation.csv"),
  row.names = FALSE,
  na = "",
  fileEncoding = "UTF-8"
)

identifier_specs <- data.frame(
  dataset_id = c("DS0001", "DS0002", "DS0003", "DS0003"),
  variable = c("STUDY_ID", "CASEID", "CASEID", "LEAD_1"),
  stringsAsFactors = FALSE
)

identifier_rows <- lapply(seq_len(nrow(identifier_specs)), function(i) {
  dataset_id <- identifier_specs$dataset_id[[i]]
  variable <- identifier_specs$variable[[i]]
  dataset <- raw_data[[dataset_id]]
  if (!variable %in% names(dataset)) stop(dataset_id, " is missing identifier variable ", variable, ".")

  value <- dataset[[variable]]
  nonmissing <- !is.na(value)
  nonmissing_value <- value[nonmissing]
  numeric_value <- if (is.numeric(nonmissing_value) && !is.factor(nonmissing_value)) nonmissing_value else numeric()
  distinct_nonmissing <- length(unique(nonmissing_value))

  data.frame(
    dataset = dataset_id,
    variable = variable,
    n_rows = nrow(dataset),
    n_nonmissing = sum(nonmissing),
    n_distinct_nonmissing = distinct_nonmissing,
    duplicate_count = sum(nonmissing) - distinct_nonmissing,
    duplicate_count_definition = "Nonmissing observations beyond the first occurrence of each distinct value.",
    min = if (length(numeric_value) > 0L) format_number(min(numeric_value)) else NA_character_,
    max = if (length(numeric_value) > 0L) format_number(max(numeric_value)) else NA_character_,
    stringsAsFactors = FALSE
  )
})
identifier_audit <- do.call(rbind, identifier_rows)
if (nrow(identifier_audit) != 4L) stop("Identifier audit must contain exactly four rows.")

write.csv(
  identifier_audit,
  file.path(table_dir, "identifier_audit.csv"),
  row.names = FALSE,
  na = "",
  fileEncoding = "UTF-8"
)

lead_1 <- raw_data$DS0003$LEAD_1
lead_1_text <- as.character(lead_1)
lead_1_frequency <- as.data.frame(
  table(value = lead_1_text, useNA = "always"),
  stringsAsFactors = FALSE,
  responseName = "frequency"
)
lead_1_frequency$value <- ifelse(is.na(lead_1_frequency$value), "<missing>", lead_1_frequency$value)
lead_1_frequency$dataset <- "DS0003"
lead_1_frequency$variable <- "LEAD_1"
lead_1_frequency <- lead_1_frequency[c("dataset", "variable", "value", "frequency")]

write.csv(
  lead_1_frequency,
  file.path(table_dir, "lead_1_frequency.csv"),
  row.names = FALSE,
  na = "",
  fileEncoding = "UTF-8"
)

if (any(!validation$variable_exists)) {
  stop("Crosswalk validation failed because one or more variables are absent from the stated dataset.")
}
if (any(validation$validation_status == "fail")) {
  failed <- validation[validation$validation_status == "fail", c("dataset_id", "raw_variable", "validation_note")]
  stop("Crosswalk validation contains hard failures: ", paste(paste(failed$dataset_id, failed$raw_variable), collapse = ", "))
}

message(
  "Crosswalk validation completed for ", nrow(validation), " rows: ",
  sum(validation$validation_status == "pass"), " pass; ",
  sum(validation$validation_status == "review_needed"), " review_needed."
)
message("Identifier audit completed for four dataset-variable pairs; wrote LEAD_1 frequency table.")
