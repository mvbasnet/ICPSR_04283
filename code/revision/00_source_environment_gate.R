project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
Sys.setenv(
  RENV_PATHS_ROOT = file.path(project_start, "renv", "local"),
  RENV_CONFIG_SANDBOX_ENABLED = "FALSE",
  RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE"
)
activate_file <- file.path(project_start, "renv", "activate.R")
if (!file.exists(activate_file)) {
  stop("Missing renv/activate.R. Restore the project environment before running the gate.")
}
source(activate_file)
suppressPackageStartupMessages(library(here))

project_root <- normalizePath(here::here(), winslash = "/", mustWork = TRUE)
git_root_raw <- system2("git", c("rev-parse", "--show-toplevel"), stdout = TRUE, stderr = TRUE)
git_status <- attr(git_root_raw, "status")
if (!is.null(git_status) && git_status != 0L) {
  stop("Unable to determine the Git repository root: ", paste(git_root_raw, collapse = " "))
}
git_root <- normalizePath(git_root_raw[[1]], winslash = "/", mustWork = TRUE)
if (!identical(project_root, git_root) || !identical(project_start, git_root) ||
    !identical(basename(git_root), "ICPSR_04283")) {
  stop(
    "Wrong repository root. Expected to run from the ICPSR_04283 Git root; got ",
    project_start
  )
}

verification_dir <- here("output", "verification")
dir.create(verification_dir, recursive = TRUE, showWarnings = FALSE)

required_paths <- c(
  "04283-0001-Data.rda" = "Data/raw/icpsr_04283/04283-0001-Data.rda",
  "04283-0002-Data.rda" = "Data/raw/icpsr_04283/04283-0002-Data.rda",
  "04283-0003-Data.rda" = "Data/raw/icpsr_04283/04283-0003-Data.rda",
  "04283-manifest.txt" = "docs/icpsr/04283-manifest.txt",
  "04283-User_guide.pdf" = "docs/icpsr/04283-User_guide.pdf",
  "04283-0001-Questionnaire.pdf" = "docs/icpsr/DS0001/04283-0001-Questionnaire.pdf",
  "04283-0001-Codebook.pdf" = "docs/icpsr/DS0001/04283-0001-Codebook.pdf",
  "04283-0002-Codebook.pdf" = "docs/icpsr/DS0002/04283-0002-Codebook.pdf",
  "04283-0003-Codebook.pdf" = "docs/icpsr/DS0003/04283-0003-Codebook.pdf",
  "04283-0001-Setup.dct" = "docs/icpsr/DS0001/04283-0001-Setup.dct",
  "04283-0002-Setup.dct" = "docs/icpsr/DS0002/04283-0002-Setup.dct",
  "04283-0003-Setup.dct" = "docs/icpsr/DS0003/04283-0003-Setup.dct",
  "04283-0001-Setup.do" = "docs/icpsr/DS0001/04283-0001-Setup.do",
  "04283-0002-Setup.do" = "docs/icpsr/DS0002/04283-0002-Setup.do",
  "04283-0003-Setup.do" = "docs/icpsr/DS0003/04283-0003-Setup.do"
)

manifest_path <- here(required_paths[["04283-manifest.txt"]])
if (!file.exists(manifest_path)) {
  stop("Required ICPSR manifest is missing: ", required_paths[["04283-manifest.txt"]])
}
manifest_lines <- readLines(manifest_path, warn = FALSE, encoding = "UTF-8")

manifest_entries <- lapply(seq_along(manifest_lines), function(i) {
  line <- trimws(manifest_lines[[i]])
  if (!nzchar(line)) return(NULL)
  fields <- strsplit(line, "[[:space:]]+")[[1]]
  if (length(fields) < 2L || !grepl("[.]", fields[[1]], fixed = FALSE)) return(NULL)
  final_field <- fields[[length(fields)]]
  if (!grepl("^([0-9a-f]{32}|-)$", final_field)) return(NULL)
  data.frame(
    manifest_order = i,
    manifest_filename = fields[[1]],
    expected_md5 = if (identical(final_field, "-")) NA_character_ else final_field,
    stringsAsFactors = FALSE
  )
})
manifest_entries <- do.call(rbind, manifest_entries)
if (is.null(manifest_entries) || nrow(manifest_entries) == 0L) {
  stop("The ICPSR manifest could not be parsed.")
}

search_roots <- c(here("Data", "raw", "icpsr_04283"), here("docs", "icpsr"))
available_files <- unlist(lapply(
  search_roots,
  list.files,
  recursive = TRUE,
  full.names = TRUE,
  all.files = FALSE
), use.names = FALSE)
available_files <- normalizePath(available_files, winslash = "/", mustWork = TRUE)

relative_path <- function(path) {
  if (!nzchar(path)) return(NA_character_)
  substring(path, nchar(project_root) + 2L)
}

source_checks <- lapply(seq_len(nrow(manifest_entries)), function(i) {
  filename <- manifest_entries$manifest_filename[[i]]
  required_rel <- unname(required_paths[filename])
  is_required <- length(required_rel) == 1L && !is.na(required_rel)
  if (is_required) {
    candidate <- here(required_rel)
    matches <- if (file.exists(candidate)) normalizePath(candidate, winslash = "/") else character()
  } else {
    matches <- available_files[basename(available_files) == filename]
  }
  exists <- length(matches) == 1L
  resolved <- if (exists) matches[[1]] else ""
  expected <- manifest_entries$expected_md5[[i]]
  actual <- if (exists && !is.na(expected)) unname(tools::md5sum(resolved)) else NA_character_
  md5_status <- if (!exists) {
    "absent"
  } else if (is.na(expected)) {
    "not_available"
  } else if (identical(tolower(actual), tolower(expected))) {
    "match"
  } else {
    "mismatch"
  }
  gate_status <- if (length(matches) > 1L) {
    "fail_multiple_matches"
  } else if (is_required && !exists) {
    "fail_missing_required"
  } else if (identical(md5_status, "mismatch")) {
    "fail_hash_mismatch"
  } else if (!exists) {
    "recorded_absent_nonrequired"
  } else {
    "pass"
  }
  data.frame(
    manifest_order = manifest_entries$manifest_order[[i]],
    manifest_filename = filename,
    resolved_path = if (exists) relative_path(resolved) else NA_character_,
    required_for_tranche = is_required,
    exists = exists,
    expected_md5 = expected,
    actual_md5 = actual,
    md5_status = md5_status,
    gate_status = gate_status,
    note = if (length(matches) > 1L) paste("Multiple files:", paste(relative_path(matches), collapse = " | ")) else "",
    stringsAsFactors = FALSE
  )
})
source_checks <- do.call(rbind, source_checks)

required_not_in_manifest <- setdiff(names(required_paths), source_checks$manifest_filename)
if (length(required_not_in_manifest) > 0L) {
  extra_checks <- lapply(required_not_in_manifest, function(filename) {
    rel <- unname(required_paths[[filename]])
    exists <- file.exists(here(rel))
    data.frame(
      manifest_order = NA_integer_, manifest_filename = filename,
      resolved_path = if (exists) rel else NA_character_, required_for_tranche = TRUE,
      exists = exists, expected_md5 = NA_character_, actual_md5 = NA_character_,
      md5_status = if (exists) "not_available" else "absent",
      gate_status = if (exists) "pass" else "fail_missing_required",
      note = "Required file was not parsed from manifest.", stringsAsFactors = FALSE
    )
  })
  source_checks <- rbind(source_checks, do.call(rbind, extra_checks))
}

write.csv(
  source_checks,
  file.path(verification_dir, "source_file_checks.csv"),
  row.names = FALSE,
  na = "",
  fileEncoding = "UTF-8"
)

quarto_candidates <- unique(c(
  unname(Sys.which("quarto")),
  "C:/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.exe"
))
quarto_candidates <- quarto_candidates[nzchar(quarto_candidates) & file.exists(quarto_candidates)]
quarto_path <- if (length(quarto_candidates) > 0L) normalizePath(quarto_candidates[[1]], winslash = "/") else NA_character_
quarto_version <- if (!is.na(quarto_path)) {
  paste(system2(quarto_path, "--version", stdout = TRUE, stderr = TRUE), collapse = " ")
} else {
  NA_character_
}

package_names <- c("renv", "here")
package_versions <- vapply(package_names, function(pkg) {
  if (requireNamespace(pkg, quietly = TRUE)) as.character(packageVersion(pkg)) else "NOT INSTALLED"
}, character(1))

summary_lines <- c(
  paste0("project_root: ", project_root),
  paste0("git_root: ", git_root),
  paste0("R_version: ", R.version.string),
  paste0("R_platform: ", R.version$platform),
  paste0("locale: ", Sys.getlocale()),
  paste0("library_paths: ", paste(.libPaths(), collapse = " | ")),
  paste0("package_renv: ", package_versions[["renv"]]),
  paste0("package_here: ", package_versions[["here"]]),
  paste0("quarto_path: ", if (is.na(quarto_path)) "NOT FOUND" else quarto_path),
  paste0("quarto_version: ", if (is.na(quarto_version)) "NOT FOUND" else quarto_version),
  paste0("manifest_entries: ", nrow(source_checks)),
  paste0("present_manifest_files: ", sum(source_checks$exists)),
  paste0("absent_nonrequired_manifest_files: ", sum(source_checks$gate_status == "recorded_absent_nonrequired")),
  paste0("hard_failures: ", sum(grepl("^fail_", source_checks$gate_status))),
  "locale_note: C.UTF-8 startup fallback warnings are recorded warnings unless an actual reproducibility check fails."
)
writeLines(
  enc2utf8(summary_lines),
  file.path(verification_dir, "environment_summary.txt"),
  useBytes = TRUE
)

hard_failures <- source_checks[grepl("^fail_", source_checks$gate_status), , drop = FALSE]
if (nrow(hard_failures) > 0L) {
  stop(
    "Source/environment gate failed: ",
    paste(paste0(hard_failures$manifest_filename, " [", hard_failures$gate_status, "]"), collapse = "; ")
  )
}
if (any(package_versions == "NOT INSTALLED")) {
  stop("Required project packages are not installed: ", paste(names(package_versions)[package_versions == "NOT INSTALLED"], collapse = ", "))
}

message("Source/environment gate passed. See output/verification for generated checks.")
