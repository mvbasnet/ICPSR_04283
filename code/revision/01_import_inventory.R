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

table_dir <- here("output", "tables")
dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)

sources <- data.frame(
  dataset_id = c("DS0001", "DS0002", "DS0003"),
  source_file = c(
    "Data/raw/icpsr_04283/04283-0001-Data.rda",
    "Data/raw/icpsr_04283/04283-0002-Data.rda",
    "Data/raw/icpsr_04283/04283-0003-Data.rda"
  ),
  expected_object = c("da04283.0001", "da04283.0002", "da04283.0003"),
  expected_rows = c(1015L, 794L, 245L),
  expected_columns = c(1210L, 169L, 261L),
  stringsAsFactors = FALSE
)

collapse_attribute_labels <- function(x) {
  labels <- attr(x, "labels", exact = TRUE)
  if (is.null(labels)) return("")
  paste(paste0(names(labels), "=", unname(labels)), collapse = " | ")
}

format_number <- function(x) {
  if (length(x) == 0L || is.na(x)) return(NA_character_)
  format(x, trim = TRUE, scientific = FALSE, digits = 15)
}

object_rows <- vector("list", nrow(sources))
variable_rows <- vector("list", nrow(sources))

for (i in seq_len(nrow(sources))) {
  source_path <- here(sources$source_file[[i]])
  if (!file.exists(source_path)) stop("Missing raw source: ", sources$source_file[[i]])
  hash_before <- unname(tools::md5sum(source_path))
  isolated <- new.env(parent = baseenv())
  loaded_names <- load(source_path, envir = isolated)
  hash_after <- unname(tools::md5sum(source_path))

  if (!identical(loaded_names, sources$expected_object[[i]])) {
    stop(
      sources$dataset_id[[i]], " loaded unexpected object(s): ",
      paste(loaded_names, collapse = ", "), ". Expected exactly ",
      sources$expected_object[[i]], "."
    )
  }
  raw_object <- isolated[[sources$expected_object[[i]]]]
  if (!is.data.frame(raw_object)) {
    stop(sources$dataset_id[[i]], " object is not a data.frame.")
  }
  observed_dim <- dim(raw_object)
  if (!identical(as.integer(observed_dim), c(sources$expected_rows[[i]], sources$expected_columns[[i]]))) {
    stop(
      sources$dataset_id[[i]], " dimensions are ", paste(observed_dim, collapse = " x "),
      "; expected ", sources$expected_rows[[i]], " x ", sources$expected_columns[[i]], "."
    )
  }
  if (!identical(hash_before, hash_after)) {
    stop("Raw source hash changed while loading: ", sources$source_file[[i]])
  }

  object_rows[[i]] <- data.frame(
    dataset_id = sources$dataset_id[[i]],
    source_file = sources$source_file[[i]],
    expected_object = sources$expected_object[[i]],
    loaded_objects = paste(loaded_names, collapse = " | "),
    observed_rows = observed_dim[[1]],
    observed_columns = observed_dim[[2]],
    expected_rows = sources$expected_rows[[i]],
    expected_columns = sources$expected_columns[[i]],
    observed_class = paste(class(raw_object), collapse = " | "),
    hash_before = hash_before,
    hash_after = hash_after,
    hash_unchanged = identical(hash_before, hash_after),
    validation_status = "pass",
    stringsAsFactors = FALSE
  )

  per_variable <- lapply(seq_along(raw_object), function(j) {
    value <- raw_object[[j]]
    nonmissing <- !is.na(value)
    observed_text <- if (is.factor(value)) as.character(value) else as.character(value)
    observed_unique <- unique(observed_text[nonmissing])
    numeric_value <- if (is.numeric(value) && !is.factor(value)) value[nonmissing] else numeric()
    data.frame(
      dataset_id = sources$dataset_id[[i]],
      source_file = sources$source_file[[i]],
      object_name = sources$expected_object[[i]],
      variable_position = j,
      raw_variable = names(raw_object)[[j]],
      observed_r_class = paste(class(value), collapse = " | "),
      observed_storage_mode = storage.mode(value),
      r_label_attribute = if (is.null(attr(value, "label", exact = TRUE))) "" else as.character(attr(value, "label", exact = TRUE)),
      factor_levels = if (is.factor(value)) paste(levels(value), collapse = " | ") else "",
      value_labels_attribute = collapse_attribute_labels(value),
      observed_nonmissing_n = sum(nonmissing),
      observed_missing_n = sum(!nonmissing),
      observed_unique_n = length(observed_unique),
      observed_min = if (length(numeric_value) > 0L) format_number(min(numeric_value)) else NA_character_,
      observed_max = if (length(numeric_value) > 0L) format_number(max(numeric_value)) else NA_character_,
      observed_unique_values = if (length(observed_unique) <= 20L) paste(observed_unique, collapse = " | ") else "",
      raw_file_md5 = hash_before,
      stringsAsFactors = FALSE
    )
  })
  variable_rows[[i]] <- do.call(rbind, per_variable)
  rm(raw_object, isolated)
}

object_inventory <- do.call(rbind, object_rows)
variable_inventory <- do.call(rbind, variable_rows)
if (nrow(variable_inventory) != 1640L) {
  stop("Variable inventory has ", nrow(variable_inventory), " rows; expected 1,640.")
}

write.csv(
  object_inventory,
  file.path(table_dir, "source_object_inventory.csv"),
  row.names = FALSE,
  na = "",
  fileEncoding = "UTF-8"
)
write.csv(
  variable_inventory,
  file.path(table_dir, "source_variable_inventory.csv"),
  row.names = FALSE,
  na = "",
  fileEncoding = "UTF-8"
)

message("Isolated import passed for three raw objects; inventoried 1,640 variables.")
