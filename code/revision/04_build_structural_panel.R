# Stage 04: mechanical child x wave representation of the approved Stage 03 input.
# No cleaning, sample selection, substantive diagnostics, or estimation occurs here.
# Windows verification chain: set a supported process-local UTF-8 locale before
# Rscript (e.g. PowerShell: $env:LC_ALL = 'English_United States.utf8'). An invalid
# C.UTF-8 fallback can alter Stage 03's CSV documentation text; lineage checks reject it.
project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
git_root_raw <- system2("git", c("rev-parse", "--show-toplevel"), stdout = TRUE, stderr = TRUE)
git_status <- attr(git_root_raw, "status")
if (!is.null(git_status) && git_status != 0L) stop("Unable to determine the Git root.")
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
  stop("Working directory, here root, and Git root must agree.")
}

input_path <- here::here("Data", "processed", "verified_child_wide.rds")
upstream_provenance_path <- here::here("output", "tables", "verified_wide_provenance.csv")
upstream_checks_path <- here::here("output", "verification", "verified_wide_checks.csv")
crosswalk_path <- here::here("docs", "stage1_variable_crosswalk.csv")
output_relative <- c(
  "Data/processed/structural_child_wave_panel.rds",
  "output/tables/structural_panel_provenance.csv",
  "output/verification/structural_panel_checks.csv"
)
output_path <- here::here(output_relative[[1]])
provenance_path <- here::here(output_relative[[2]])
checks_path <- here::here(output_relative[[3]])

# Check ignore rules before writing even a failed-build report.
ignored <- vapply(output_relative, function(path) {
  identical(system2("git", c("check-ignore", "-q", "--", path)), 0L)
}, logical(1))
if (!all(ignored)) stop("Output ignore rules are insufficient: ", paste(output_relative[!ignored], collapse = ", "))

checks <- data.frame(
  check_id = character(), severity = character(), expected = character(),
  observed = character(), status = character(), detail = character(), stringsAsFactors = FALSE
)
format_observed <- function(x) {
  if (!length(x)) return("<none>")
  paste(ifelse(is.na(x), "<missing>", as.character(x)), collapse = " | ")
}
add_check <- function(id, severity, expected, observed, status, detail = "") {
  checks <<- rbind(checks, data.frame(
    check_id = id, severity = severity, expected = format_observed(expected),
    observed = format_observed(observed), status = status, detail = detail, stringsAsFactors = FALSE
  ))
}
hard <- function(id, condition, expected, observed, detail = "") {
  add_check(id, "hard", expected, observed, if (isTRUE(condition)) "pass" else "fail", detail)
}
record <- function(id, observed, detail = "", severity = "info") {
  add_check(id, severity, "record only; no substantive transformation", observed, "recorded", detail)
}
write_checks <- function() {
  dir.create(dirname(checks_path), recursive = TRUE, showWarnings = FALSE)
  write.csv(checks, checks_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
}
gate <- function(context) {
  failed <- checks$severity == "hard" & checks$status == "fail"
  if (any(failed)) stop(context, ": ", paste(checks$check_id[failed], collapse = ", "))
}
attribute_text <- function(x) paste(capture.output(dput(attributes(x), control = "all")), collapse = "\n")
class_text <- function(x) paste(class(x), collapse = " | ")
read_csv <- function(path, col_classes = NA) read.csv(
  path, stringsAsFactors = FALSE, check.names = FALSE, na.strings = character(),
  colClasses = col_classes, encoding = "UTF-8"
)

tryCatch({
  hard("project_root", identical(project_start, project_root) && identical(project_root, git_root),
       "working directory = here root = Git root", c(project_start, project_root, git_root))
  hard("outputs_ignored", all(ignored), "all three outputs ignored", ignored)
  required_paths <- c(input_path, upstream_provenance_path, upstream_checks_path, crosswalk_path)
  hard("required_inputs_present", all(file.exists(required_paths)), "all four upstream inputs present", file.exists(required_paths))
  gate("Required input validation failed")

  # Independent, ordered Stage 03 contract; never derived from the input names.
  verified_allowlist <- c(
    "STUDY_ID", "T_IDEAP", "T_IDEAK", "PPVTEPF", "PPVTEPS", "PPVTEKF", "PPVTEKS",
    "WJ10_SSEPF", "WJ10_SSEPS", "WJ10_SSEKF", "WJ10_SSEKS",
    "WJ21AEPF", "WJ21AEPS", "WJ21AEKF", "WJ21AEKS",
    "ASMSTATPF", "ASMSTATPS", "ASMSTATKF", "ASMSTATKS",
    "CLS_SIZEPF", "CLS_SIZEPS", "CLS_SIZEKF", "CLS_SIZEKS",
    "CHGENP", "CHRACE_AAP", "CHRACE_ASP", "CHRACE_LTP", "CHRACE_NAP", "CHRACE_WHP", "CHINCOMCP", "CHMATEDCP",
    "T_CHNGCP", "T_CHNG", "TCHCHNGK", "CLASSCHNGK", "SNAPCLASSK", "NUMCLSRMK",
    "SITE_PF", "SITE_PS", "SITE_TRPS", "SITE_ECK", "SITE_TRKF", "SITE_TRKS", "SITE_WT",
    "TVIPSPF", "TVIPRSPF", "WM25SSPF", "WM25WPF", "TVIPSPS", "TVIPRSPS", "WM25SSPS", "WM25WPS",
    "TVIPSKF", "WM25SSKF", "WM25WKF", "WM22SSKF", "WM22WKF",
    "TVIPSKS", "WM22SSKS", "WM22WKS", "WM25SSKS", "WM25WKS"
  )
  output_schema <- c(
    "STUDY_ID", "wave", "wave_label", "wave_index", "grade", "season",
    "CHGENP", "CHRACE_AAP", "CHRACE_ASP", "CHRACE_LTP", "CHRACE_NAP", "CHRACE_WHP", "CHINCOMCP", "CHMATEDCP",
    "teacher_modernity_pre_k_fall_released", "teacher_modernity_kindergarten_fall_released",
    "ppvt_english_standard_score", "applied_problems_english_standard_score", "sound_awareness_rhyming_raw_score",
    "assessment_status_released", "class_size", "tvip_spanish_standard_score", "tvip_spanish_raw_score",
    "woodcock_munoz_applied_problems_standard_score", "woodcock_munoz_applied_problems_w_score",
    "woodcock_munoz_letter_word_standard_score", "woodcock_munoz_letter_word_w_score",
    "pre_k_site_id", "teacher_rating_site_id", "site_ecers_kindergarten_year", "site_weight_pre_k_released",
    "pre_k_fall_to_spring_change_child_record_released",
    "pre_k_fall_to_spring_change_teacher_questionnaire_released",
    "kindergarten_year_teacher_change_released", "kindergarten_year_classroom_change_released",
    "kindergarten_year_snapshot_classroom_count_released", "kindergarten_year_observed_classroom_count_released"
  )
  wave_table <- data.frame(
    wave = c("PF", "PS", "KF", "KS"),
    wave_label = c("Fall Pre-K", "Spring Pre-K", "Fall Kindergarten", "Spring Kindergarten"),
    wave_index = 1:4, grade = c("Pre-K", "Pre-K", "Kindergarten", "Kindergarten"),
    season = c("Fall", "Spring", "Fall", "Spring"), stringsAsFactors = FALSE
  )
  status_levels <- c(
    "(1) Absent", "(2) Full Assessment (English)", "(3) Full Assessment (Spanish)",
    "(4) Non-English, Spanish-Speaking Child Failed Pre-LAS", "(5) Partial Assessment (English)",
    "(6) Partial Assessment (Spanish)", "(7) Child Refused Assessment", "(8) DR"
  )
  context_note <- paste(
    "Repeated on both rows of the applicable grade as a structural representation convenience;",
    "not measured contemporaneously at both waves; no event date inferred."
  )
  gap_note <- paste(
    "No approved Stage 03 source mapping exists for this output-variable x wave;",
    "this does not establish noncollection or absence elsewhere in the release."
  )
  site_note <- paste(
    "Site fields retain only documented site meanings; no teacher, classroom, school, state, nesting, or clustering identifier inferred.",
    "A shared long site field is wave-relative storage; equal codes across waves do not establish a longitudinally stable site."
  )
  weight_note <- "Released Pre-K site sampling weight, not an identifier; no analytic weighting applied."

  # Every row declares PF, PS, KF, KS explicitly. Empty strings are mapping gaps.
  # construct is the reviewed crosswalk terminology, including naming-only exceptions.
  mapping <- function(output, role, mapping_class, sources, construct = output, note = "") {
    stopifnot(length(sources) == 4L, length(construct) %in% c(1L, 4L))
    data.frame(output_variable = output, output_role = role, wave = wave_table$wave,
               source_variable = sources, mapping_class = mapping_class,
               expected_construct = rep(construct, length.out = 4L), note = note, stringsAsFactors = FALSE)
  }
  registry <- do.call(rbind, list(
    mapping("STUDY_ID", "child_identifier", "identifier_repeat", rep("STUDY_ID", 4), "child_identifier"),
    mapping("CHGENP", "baseline_child_characteristic", "baseline_repeat", rep("CHGENP", 4), "child_sex"),
    mapping("CHRACE_AAP", "baseline_child_characteristic", "baseline_repeat", rep("CHRACE_AAP", 4), "child_race_african_american_indicator"),
    mapping("CHRACE_ASP", "baseline_child_characteristic", "baseline_repeat", rep("CHRACE_ASP", 4), "child_race_asian_indicator"),
    mapping("CHRACE_LTP", "baseline_child_characteristic", "baseline_repeat", rep("CHRACE_LTP", 4), "child_race_latino_indicator"),
    mapping("CHRACE_NAP", "baseline_child_characteristic", "baseline_repeat", rep("CHRACE_NAP", 4), "child_race_native_american_indicator"),
    mapping("CHRACE_WHP", "baseline_child_characteristic", "baseline_repeat", rep("CHRACE_WHP", 4), "child_race_white_indicator"),
    mapping("CHINCOMCP", "baseline_child_characteristic", "baseline_repeat", rep("CHINCOMCP", 4), "family_income_category"),
    mapping("CHMATEDCP", "baseline_child_characteristic", "baseline_repeat", rep("CHMATEDCP", 4), "maternal_education_category"),
    mapping("teacher_modernity_pre_k_fall_released", "source_specific_teacher_belief", "source_specific_native_wave",
            c("T_IDEAP", "", "", ""), "teacher_modernity_fall_pre_k", "Released Fall Pre-K scale only; no rescaling or spring carry-forward."),
    mapping("teacher_modernity_kindergarten_fall_released", "source_specific_teacher_belief", "source_specific_native_wave",
            c("", "", "T_IDEAK", ""), "teacher_modernity_fall_k", "Released Fall Kindergarten scale only; no harmonization or spring carry-forward."),
    mapping("ppvt_english_standard_score", "english_assessment", "wave_reshape", c("PPVTEPF", "PPVTEPS", "PPVTEKF", "PPVTEKS")),
    mapping("applied_problems_english_standard_score", "english_assessment", "wave_reshape", c("WJ10_SSEPF", "WJ10_SSEPS", "WJ10_SSEKF", "WJ10_SSEKS")),
    mapping("sound_awareness_rhyming_raw_score", "english_assessment", "wave_reshape", c("WJ21AEPF", "WJ21AEPS", "WJ21AEKF", "WJ21AEKS")),
    mapping("assessment_status_released", "released_assessment_status", "wave_reshape", c("ASMSTATPF", "ASMSTATPS", "ASMSTATKF", "ASMSTATKS"),
            "assessment_status", "Common eight-level factor uses exact released labels; DR remains uninterpreted."),
    mapping("class_size", "classroom_variable", "wave_reshape", c("CLS_SIZEPF", "CLS_SIZEPS", "CLS_SIZEKF", "CLS_SIZEKS")),
    mapping("tvip_spanish_standard_score", "spanish_assessment", "wave_reshape", c("TVIPSPF", "TVIPSPS", "TVIPSKF", "TVIPSKS")),
    mapping("tvip_spanish_raw_score", "spanish_assessment", "wave_reshape", c("TVIPRSPF", "TVIPRSPS", "", "")),
    mapping("woodcock_munoz_applied_problems_standard_score", "spanish_assessment", "wave_reshape", c("WM25SSPF", "WM25SSPS", "WM25SSKF", "WM25SSKS")),
    mapping("woodcock_munoz_applied_problems_w_score", "spanish_assessment", "wave_reshape", c("WM25WPF", "WM25WPS", "WM25WKF", "WM25WKS")),
    mapping("woodcock_munoz_letter_word_standard_score", "spanish_assessment", "wave_reshape", c("", "", "WM22SSKF", "WM22SSKS")),
    mapping("woodcock_munoz_letter_word_w_score", "spanish_assessment", "wave_reshape", c("", "", "WM22WKF", "WM22WKS")),
    mapping("pre_k_site_id", "documented_site", "wave_reshape", c("SITE_PF", "SITE_PS", "", ""),
            c("pre_k_fall_site_id", "pre_k_spring_site_id", "", ""), site_note),
    mapping("teacher_rating_site_id", "documented_teacher_rating_site", "wave_reshape", c("", "SITE_TRPS", "SITE_TRKF", "SITE_TRKS"),
            c("", "pre_k_spring_teacher_rating_site_id", "kindergarten_fall_teacher_rating_site_id", "kindergarten_spring_teacher_rating_site_id"), site_note),
    mapping("site_ecers_kindergarten_year", "documented_site_year_context", "grade_context_repeat", c("", "", "SITE_ECK", "SITE_ECK"),
            "kindergarten_ecers_site_id", paste(context_note, site_note)),
    mapping("site_weight_pre_k_released", "released_sampling_weight", "grade_context_repeat", c("SITE_WT", "SITE_WT", "", ""),
            "site_sampling_weight", paste(context_note, weight_note)),
    mapping("pre_k_fall_to_spring_change_child_record_released", "released_grade_transition", "grade_context_repeat", c("T_CHNGCP", "T_CHNGCP", "", ""),
            "pre_k_child_level_teacher_or_classroom_change", context_note),
    mapping("pre_k_fall_to_spring_change_teacher_questionnaire_released", "released_grade_transition", "grade_context_repeat", c("T_CHNG", "T_CHNG", "", ""),
            "pre_k_questionnaire_teacher_or_classroom_change", context_note),
    mapping("kindergarten_year_teacher_change_released", "released_grade_year_change", "grade_context_repeat", c("", "", "TCHCHNGK", "TCHCHNGK"),
            "kindergarten_teacher_change", context_note),
    mapping("kindergarten_year_classroom_change_released", "released_grade_year_change", "grade_context_repeat", c("", "", "CLASSCHNGK", "CLASSCHNGK"),
            "kindergarten_classroom_change", context_note),
    mapping("kindergarten_year_snapshot_classroom_count_released", "released_grade_year_count", "grade_context_repeat", c("", "", "SNAPCLASSK", "SNAPCLASSK"),
            "kindergarten_snapshot_classroom_count", context_note),
    mapping("kindergarten_year_observed_classroom_count_released", "released_grade_year_count", "grade_context_repeat", c("", "", "NUMCLSRMK", "NUMCLSRMK"),
            "kindergarten_observed_classroom_count", context_note)
  ))
  generated_names <- c("wave", "wave_label", "wave_index", "grade", "season")
  generated <- do.call(rbind, lapply(generated_names, function(variable) {
    mapping(variable, "structural_wave_metadata", "generated_structure", rep("", 4), "",
            "Approved four-wave structure; wave_index is order only, not elapsed or equally spaced time.")
  }))
  registry <- rbind(registry, generated)
  registry <- registry[order(match(registry$output_variable, output_schema), match(registry$wave, wave_table$wave)), ]
  row.names(registry) <- NULL
  is_generated <- registry$mapping_class == "generated_structure"
  is_mapped <- nzchar(registry$source_variable)
  is_gap <- !is_mapped & !is_generated
  registry$mapping_class[is_gap] <- "no_approved_source_mapping"
  registry$availability_status <- ifelse(is_mapped, "source_mapped", ifelse(is_generated, "generated_structural", "no_approved_source_mapping"))
  registry$transformation_applied <- ifelse(is_mapped, "none", ifelse(is_generated, "derive_structure", "introduce_mapping_gap_na"))
  prohibited_actions <- c(
    "teacher_belief_rescaling", "teacher_belief_harmonization", "teacher_belief_grade_assignment", "spring_carry_forward",
    "score_cleaning", "special_code_recoding", "imputation", "missing_reason_reconstruction", "cross_language_pooling",
    "cross_language_equating", "score_conversion", "change_indicator_reconciliation", "identifier_inference", "dataset_linkage",
    "income_midpoints", "education_years", "race_consolidation", "event_date_inference", "analytic_weighting",
    "sample_selection", "regression", "inference_selection", "median_split_did", "sgfe_groups"
  )

  upstream_checks <- read_csv(upstream_checks_path)
  hard("upstream_check_schema", identical(names(upstream_checks), names(checks)), names(checks), names(upstream_checks))
  gate("Stage 03 check schema failed")
  expected_upstream_hard <- c(
    "project_root", "required_inputs_present", "explicit_allowlist_size", "explicit_allowlist_unique",
    "manifest_ds0001_rda_entry", "manifest_ds0001_rda_md5", "source_ds0001_rda_md5", "source_manifest_md5_agreement",
    "isolated_load_object", "source_is_data_frame", "source_dimensions", "source_column_names_unique", "source_file_unchanged_during_load",
    "crosswalk_required_columns", "crosswalk_row_count", "crosswalk_unique_dataset_variable_rows", "crosswalk_dataset_distribution",
    "crosswalk_ds0001_order_matches_allowlist", "allowlisted_variables_present", "output_dimensions", "output_column_names_unique",
    "output_names_match_allowlist", "output_has_no_extra_variables", "study_id_complete", "study_id_unique", "study_id_source_sequence",
    "all_output_columns_identical_to_source", "provenance_row_count", "provenance_unique_decisions", "provenance_preserves_crosswalk_fields",
    "provenance_ds0001_classification", "provenance_non_ds0001_classification", "provenance_no_transformations_applied",
    "rds_round_trip_identity", "verification_check_ids_unique"
  )
  upstream_hard <- upstream_checks$severity == "hard"
  hard("upstream_check_ids", !anyDuplicated(upstream_checks$check_id) &&
         setequal(upstream_checks$check_id[upstream_hard], expected_upstream_hard),
       "all 35 Stage 03 hard checks; unique IDs", upstream_checks$check_id[upstream_hard])
  hard("upstream_hard_checks_pass", all(upstream_checks$status[upstream_hard] == "pass"),
       "all Stage 03 hard checks pass", table(upstream_checks$status[upstream_hard]))
  gate("Stage 03 hard gate failed")

  crosswalk <- read_csv(crosswalk_path)
  required_crosswalk <- c(
    "dataset_id", "raw_variable", "proposed_construct", "wave", "assessment_language", "score_type",
    "transformation_status", "documentation_status", "review_status", "conflict_or_question_id",
    "permitted_transformation", "source_document", "source_page_or_section", "review_notes"
  )
  hard("crosswalk_schema", all(required_crosswalk %in% names(crosswalk)), required_crosswalk, names(crosswalk))
  gate("Crosswalk schema failed")
  cw <- crosswalk[crosswalk$dataset_id == "DS0001", , drop = FALSE]
  row.names(cw) <- NULL
  hard("crosswalk_contract", nrow(crosswalk) == 66L && !anyDuplicated(crosswalk[c("dataset_id", "raw_variable")]) &&
         identical(cw$raw_variable, verified_allowlist), "66 unique rows; exact ordered 62 DS0001 variables", cw$raw_variable)
  upstream_provenance <- read_csv(upstream_provenance_path)
  required_upstream <- c(names(crosswalk), "output_variable", "verified_wide_classification", "included_in_output", "transformation_applied")
  hard("upstream_provenance_schema", all(required_upstream %in% names(upstream_provenance)), required_upstream, names(upstream_provenance))
  gate("Upstream provenance schema failed")
  up_included <- upstream_provenance$dataset_id == "DS0001"
  hard("upstream_provenance_contract", nrow(upstream_provenance) == 66L &&
         identical(upstream_provenance[names(crosswalk)], crosswalk) &&
         all(upstream_provenance$transformation_applied == "none") &&
         identical(upstream_provenance$included_in_output, up_included) &&
         all(upstream_provenance$verified_wide_classification == ifelse(up_included, "INCLUDE_RAW", "NOT_NEEDED_FOR_VERIFIED_WIDE")) &&
         all(upstream_provenance$output_variable == ifelse(up_included, upstream_provenance$raw_variable, "")),
       "Stage 03 lineage, crosswalk, and include/exclude decisions unchanged", paste(nrow(upstream_provenance), "rows"))
  gate("Upstream lineage validation failed")

  wide <- readRDS(input_path)
  hard("input_data_frame", is.data.frame(wide), "data.frame", class(wide))
  gate("Input type validation failed")
  hard("input_dimensions", identical(dim(wide), c(1015L, 62L)), "1015 x 62", dim(wide))
  hard("input_names", identical(names(wide), verified_allowlist) && !anyDuplicated(names(wide)), verified_allowlist, names(wide))
  gate("Input contract failed")
  factor_sources <- c(
    "ASMSTATPF", "ASMSTATPS", "ASMSTATKF", "ASMSTATKS", "CHGENP", "CHRACE_AAP", "CHRACE_ASP", "CHRACE_LTP",
    "CHRACE_NAP", "CHRACE_WHP", "CHINCOMCP", "CHMATEDCP", "T_CHNGCP", "T_CHNG", "TCHCHNGK", "CLASSCHNGK"
  )
  for (v in verified_allowlist) {
    expected_class <- if (v %in% factor_sources) "factor" else "numeric"
    hard(paste0("input_class_", v), identical(class(wide[[v]]), expected_class) &&
           identical(typeof(wide[[v]]), if (v %in% factor_sources) "integer" else "double") &&
           is.null(names(wide[[v]])) && is.null(dim(wide[[v]])),
         paste(expected_class, "released vector"), c(typeof(wide[[v]]), class(wide[[v]])))
  }
  hard("input_id", !anyNA(wide$STUDY_ID) && !anyDuplicated(wide$STUDY_ID), "1015 complete unique child IDs", length(unique(wide$STUDY_ID)))
  hard("registry_source_coverage", length(verified_allowlist) == 62L && !anyDuplicated(verified_allowlist) &&
         setequal(registry$source_variable[is_mapped], verified_allowlist), "exactly 62 authorized sources", unique(registry$source_variable[is_mapped]))
  expected_keys <- as.vector(t(outer(output_schema, wave_table$wave, paste, sep = "::")))
  registry_keys <- paste(registry$output_variable, registry$wave, sep = "::")
  hard("registry_output_coverage", length(output_schema) == 37L && !anyDuplicated(output_schema) &&
         identical(registry_keys, expected_keys) && !anyDuplicated(registry_keys), "148 ordered output x wave decisions", length(registry_keys))
  gate("Input classes and registry validation failed")

  source_index <- match(registry$source_variable, cw$raw_variable)
  hard("registry_reviewed_constructs", identical(registry$expected_construct[is_mapped], cw$proposed_construct[source_index[is_mapped]]),
       "all sources match explicit reviewed constructs", cw$proposed_construct[source_index[is_mapped]])
  native <- is_mapped & registry$mapping_class %in% c("wave_reshape", "source_specific_native_wave")
  hard("registry_documented_native_waves", identical(registry$wave[native], cw$wave[source_index[native]]),
       "source-specific documented waves", cw$wave[source_index[native]])
  for (v in c("ASMSTATPF", "ASMSTATPS", "ASMSTATKF", "ASMSTATKS")) {
    expected_levels <- if (v == "ASMSTATPS") status_levels else status_levels[1:7]
    hard(paste0("source_status_levels_", v), identical(levels(wide[[v]]), expected_levels), expected_levels, levels(wide[[v]]))
  }
  gate("Documentary mapping and status-level validation failed")

  n_child <- nrow(wide)
  child_index <- rep(seq_len(n_child), each = 4L)
  wave_index <- rep(1:4, times = n_child)
  panel <- data.frame(
    STUDY_ID = wide$STUDY_ID[child_index],
    wave = ordered(wave_table$wave[wave_index], levels = wave_table$wave),
    wave_label = ordered(wave_table$wave_label[wave_index], levels = wave_table$wave_label),
    wave_index = wave_index,
    grade = factor(wave_table$grade[wave_index], levels = c("Pre-K", "Kindergarten")),
    season = factor(wave_table$season[wave_index], levels = c("Fall", "Spring"))
  )
  for (output in setdiff(output_schema, generated_names)) {
    decisions <- registry[registry$output_variable == output, , drop = FALSE]
    sources <- unique(decisions$source_variable[nzchar(decisions$source_variable)])
    single_source <- length(sources) == 1L
    if (output == "assessment_status_released") {
      value <- factor(rep(NA_character_, length(child_index)), levels = status_levels)
    } else if (single_source) {
      # Preserve one source's complete metadata; no union of attributes.
      value <- wide[[sources]][rep(NA_integer_, length(child_index))]
      attributes(value) <- attributes(wide[[sources]])
    } else {
      value <- rep(NA_real_, length(child_index))
    }
    for (j in seq_len(4L)) {
      source <- decisions$source_variable[[j]]
      if (!nzchar(source)) next
      rows <- wave_index == j
      value[rows] <- if (output == "assessment_status_released") {
        as.character(wide[[source]])
      } else if (single_source) wide[[source]] else as.numeric(wide[[source]])
    }
    panel[[output]] <- value
  }
  panel <- panel[output_schema]

  # Provenance is generated from the construction registry, one decision per cell type.
  provenance_rows <- lapply(seq_len(nrow(registry)), function(i) {
    r <- registry[i, , drop = FALSE]
    rows <- as.character(panel$wave) == r$wave
    value <- panel[[r$output_variable]][rows]
    mapped <- is_mapped[[i]]
    src <- if (mapped) wide[[r$source_variable]] else NULL
    cwi <- source_index[[i]]
    cw_field <- function(field) if (mapped) cw[[field]][[cwi]] else ""
    multi <- length(unique(registry$source_variable[registry$output_variable == r$output_variable & is_mapped])) > 1L
    copy_mode <- if (is_generated[[i]]) "generate_wave_metadata" else if (is_gap[[i]]) "introduce_mapping_gap_na" else if (
      r$output_variable == "assessment_status_released") "exact_released_labels_common_factor" else if (multi) "numeric_values_source_metadata_separate" else "single_source_values_and_metadata"
    note <- r$note
    if (multi && r$output_variable != "assessment_status_released") {
      note <- paste(note, "Base numeric output; each source's attributes are retained separately in provenance, without attribute union.")
    }
    if (is_gap[[i]]) note <- paste(note, gap_note)
    if (mapped) note <- paste(note, cw_field("review_notes"))
    data.frame(
      decision_id = sprintf("decision_%03d", i), output_variable = r$output_variable, output_role = r$output_role,
      wave = r$wave, source_variable = r$source_variable,
      source_scope = if (mapped) paste0("DS0001 child record; documented scope: ", cw_field("wave")) else "",
      mapping_class = r$mapping_class, availability_status = r$availability_status,
      introduced_na_reason = if (is_gap[[i]]) gap_note else "", copy_mode = copy_mode,
      source_typeof = if (mapped) typeof(src) else "", source_class = if (mapped) class_text(src) else "",
      source_attributes = if (mapped) attribute_text(src) else "",
      output_typeof = typeof(panel[[r$output_variable]]), output_class = class_text(panel[[r$output_variable]]),
      crosswalk_proposed_construct = cw_field("proposed_construct"),
      crosswalk_transformation_status = cw_field("transformation_status"),
      crosswalk_documentation_status = cw_field("documentation_status"), crosswalk_review_status = cw_field("review_status"),
      conflict_or_question_id = cw_field("conflict_or_question_id"),
      transformation_applied = r$transformation_applied, substantive_assumption = "none",
      source_document = cw_field("source_document"), source_page_or_section = cw_field("source_page_or_section"),
      source_nonmissing_n = if (mapped) sum(!is.na(src)) else NA_integer_,
      source_na_n = if (mapped) sum(is.na(src)) else NA_integer_, output_nonmissing_n = sum(!is.na(value)),
      output_source_na_n = if (mapped) sum(is.na(value)) else 0L,
      output_introduced_na_n = if (is_gap[[i]]) length(value) else 0L, note = trimws(note), stringsAsFactors = FALSE
    )
  })
  provenance <- do.call(rbind, provenance_rows)

  hard("output_schema", identical(names(panel), output_schema), output_schema, names(panel))
  hard("output_dimensions", identical(dim(panel), c(4060L, 37L)), "4060 x 37", dim(panel))
  hard("output_children", setequal(panel$STUDY_ID, wide$STUDY_ID) && length(unique(panel$STUDY_ID)) == 1015L,
       "all 1015 children", length(unique(panel$STUDY_ID)))
  hard("four_rows_per_child", all(table(panel$STUDY_ID) == 4L), "4 rows per child", range(table(panel$STUDY_ID)))
  hard("unique_child_wave", !anyDuplicated(panel[c("STUDY_ID", "wave")]), "4060 unique child x wave keys", nrow(unique(panel[c("STUDY_ID", "wave")])))
  hard("child_sequence", identical(panel$STUDY_ID, wide$STUDY_ID[child_index]), "input child order, four consecutive rows each", "direct vector comparison")
  hard("wave_sequence", identical(as.character(panel$wave), wave_table$wave[wave_index]) &&
         identical(panel$wave_index, wave_index) && identical(typeof(panel$wave_index), "integer"),
       "PF PS KF KS with integer 1 2 3 4 within every child", "direct vector comparison")
  hard("wave_factor_policy", is.ordered(panel$wave) && identical(levels(panel$wave), wave_table$wave) &&
         is.ordered(panel$wave_label) && identical(levels(panel$wave_label), wave_table$wave_label),
       "ordered wave and wave_label with exact approved levels", c(levels(panel$wave), levels(panel$wave_label)))
  hard("wave_metadata", identical(as.character(panel$wave_label), wave_table$wave_label[wave_index]) &&
         identical(panel$grade, factor(wave_table$grade[wave_index], levels = c("Pre-K", "Kindergarten"))) &&
         identical(panel$season, factor(wave_table$season[wave_index], levels = c("Fall", "Spring"))),
       "approved labels, grade, season", "direct vector and factor comparison")
  hard("status_common_factor", identical(class(panel$assessment_status_released), "factor") &&
         identical(levels(panel$assessment_status_released), status_levels), "exact common eight-level factor", levels(panel$assessment_status_released))

  for (i in seq_len(nrow(registry))) {
    r <- registry[i, , drop = FALSE]
    value <- panel[[r$output_variable]][panel$wave == r$wave]
    id <- paste(r$output_variable, r$wave, sep = "_")
    context <- if (r$mapping_class == "grade_context_repeat") context_note else ""
    if (is_mapped[[i]]) {
      src <- wide[[r$source_variable]]
      multi <- length(unique(registry$source_variable[registry$output_variable == r$output_variable & is_mapped])) > 1L
      same_value <- if (is.factor(src)) identical(as.character(value), as.character(src)) else identical(as.numeric(value), as.numeric(src))
      same_type <- if (r$output_variable == "assessment_status_released") {
        identical(class(value), "factor") && identical(levels(value), status_levels)
      } else if (multi) identical(class(value), "numeric") && is.null(attributes(value)) else {
        identical(class(value), class(src)) && identical(typeof(value), typeof(src)) &&
          identical(levels(value), levels(src)) && identical(attributes(panel[[r$output_variable]]), attributes(src))
      }
      hard(paste0("mapping_", id), same_value && identical(is.na(value), is.na(src)) && same_type,
           "exact source values, NA mask, and approved class/metadata policy", r$source_variable, context)
      hard(paste0("source_metadata_", id), identical(provenance$source_attributes[[i]], attribute_text(src)) &&
             identical(provenance$source_class[[i]], class_text(src)) && identical(provenance$source_typeof[[i]], typeof(src)) &&
             identical(eval(parse(text = provenance$source_attributes[[i]]), envir = baseenv()), attributes(src)),
           "reversible original source attributes, class, typeof", r$source_variable, context)
    } else if (is_gap[[i]]) {
      hard(paste0("mapping_gap_", id), all(is.na(value)), "1015 mapping-gap NA cells", sum(is.na(value)), r$note)
    }
    p <- provenance[i, ]
    hard(paste0("counts_", id), p$output_nonmissing_n + p$output_source_na_n + p$output_introduced_na_n == n_child &&
           (!is_mapped[[i]] || (p$source_na_n == p$output_source_na_n && p$source_nonmissing_n == p$output_nonmissing_n)),
         "1015 cells; mapped source/output missing counts agree", c(p$output_nonmissing_n, p$output_source_na_n, p$output_introduced_na_n), context)
    record(paste0("missingness_", id), paste0("source_na=", if (is_mapped[[i]]) p$source_na_n else "not_applicable",
           "; output_source_na=", p$output_source_na_n, "; introduced_na=", p$output_introduced_na_n,
           "; output_nonmissing=", p$output_nonmissing_n), if (is_gap[[i]]) gap_note else context)
  }

  applied_sources <- c("WJ10_SSEPF", "WJ10_SSEPS", "WJ10_SSEKF", "WJ10_SSEKS", "WM25SSPF", "WM25WPF", "WM25SSPS", "WM25WPS", "WM25SSKF", "WM25WKF", "WM25SSKS", "WM25WKS")
  source_minus7_locations <- character()
  output_minus7_locations <- character()
  for (src in applied_sources) {
    r <- registry[registry$source_variable == src, ]
    source_ids <- wide$STUDY_ID[which(wide[[src]] == -7)]
    value <- panel[[r$output_variable]][panel$wave == r$wave]
    output_ids <- wide$STUDY_ID[which(value == -7)]
    source_minus7_locations <- c(source_minus7_locations, paste(src, r$wave, source_ids, sep = "::")[seq_along(source_ids)])
    output_minus7_locations <- c(output_minus7_locations, paste(src, r$wave, output_ids, sep = "::")[seq_along(output_ids)])
  }
  hard("applied_problems_minus7_locations", length(source_minus7_locations) == 8L && identical(output_minus7_locations, source_minus7_locations),
       "8 unchanged -7 values at exact child-wave locations", output_minus7_locations)
  record("released_minus7_locations", output_minus7_locations, "Released values retained; no score cleaning.", "review")
  hard("ps_dr_retained", sum(wide$ASMSTATPS == "(8) DR", na.rm = TRUE) == 2L &&
         identical(which(panel$assessment_status_released[panel$wave == "PS"] == "(8) DR"), which(wide$ASMSTATPS == "(8) DR")),
       "two PS DR observations at original child locations", sum(panel$assessment_status_released[panel$wave == "PS"] == "(8) DR", na.rm = TRUE))
  for (w in wave_table$wave) {
    record(paste0("status_distribution_", w), paste(names(table(panel$assessment_status_released[panel$wave == w], useNA = "always")),
           as.integer(table(panel$assessment_status_released[panel$wave == w], useNA = "always")), sep = "="), "DR is retained without interpretation.", "review")
  }
  teacher_fields <- c("teacher_modernity_pre_k_fall_released", "teacher_modernity_kindergarten_fall_released")
  teacher_decisions <- provenance$output_variable %in% teacher_fields
  hard("teacher_native_only", all(provenance$availability_status[teacher_decisions & !is_mapped] == "no_approved_source_mapping") &&
         all(vapply(panel[teacher_fields], function(x) all(is.na(x[panel$season == "Spring"])), logical(1))) &&
         identical(names(panel)[grepl("teacher_modernity|teacher_belief|teacher_idea", names(panel))], teacher_fields),
       "two distinct native-fall fields; all spring cells NA; no generic belief output", provenance$availability_status[teacher_decisions])
  record("teacher_availability", paste(provenance$output_variable[teacher_decisions], provenance$wave[teacher_decisions], provenance$availability_status[teacher_decisions], sep = "::"),
         "Direct native-wave equality is checked; no numerical-coincidence rescaling test.", "review")
  assessment_decisions <- is_mapped & registry$output_role %in% c("english_assessment", "spanish_assessment")
  hard("language_and_metric_lineage", all(cw$assessment_language[source_index[assessment_decisions]] ==
         ifelse(registry$output_role[assessment_decisions] == "english_assessment", "English", "Spanish")) &&
         all(vapply(split(cw$score_type[source_index[assessment_decisions]], registry$output_variable[assessment_decisions]),
                    function(x) length(unique(x)) == 1L, logical(1))),
       "distinct language fields and one documented metric per long field", "crosswalk language and score_type comparison")

  context_rows <- provenance$mapping_class == "grade_context_repeat"
  hard("context_representation_note", sum(context_rows) == 16L && all(grepl(context_note, provenance$note[context_rows], fixed = TRUE)),
       "16 context decisions with exact non-contemporaneous statement", sum(context_rows), context_note)
  for (v in unique(provenance$output_variable[context_rows])) {
    record(paste0("context_repetition_", v), "2 applicable rows per child; 2030 mapped cells; 2030 other-grade mapping-gap NA cells", context_note, "review")
  }
  distinct_change_sources <- c("T_CHNGCP", "T_CHNG", "TCHCHNGK", "CLASSCHNGK")
  change_outputs <- vapply(distinct_change_sources, function(v) unique(registry$output_variable[registry$source_variable == v]), character(1))
  hard("change_fields_distinct", length(unique(change_outputs)) == 4L, "four separate unreconciled change fields", change_outputs, context_note)
  released_code <- function(x) sub("^[(]([^)]*)[)].*$", "\\1", as.character(x))
  a <- released_code(wide$T_CHNGCP)
  b <- released_code(wide$T_CHNG)
  record("change_indicator_descriptive_disagreement", sum(a != b, na.rm = TRUE),
         paste("Descriptive only: released category-code disagreement among", sum(!is.na(a) & !is.na(b)), "paired nonmissing child records; neither indicator preferred or reconciled."), "review")

  site_rows <- provenance$output_role %in% c("documented_site", "documented_teacher_rating_site", "documented_site_year_context")
  hard("site_meaning_notes", all(grepl(site_note, provenance$note[site_rows], fixed = TRUE)) &&
         all(grepl(weight_note, provenance$note[provenance$output_role == "released_sampling_weight"], fixed = TRUE)),
       "site meanings and weight limitations retained", "explicit provenance notes")
  for (i in which(site_rows & is_mapped)) {
    p <- provenance[i, ]
    value <- panel[[p$output_variable]][panel$wave == p$wave]
    record(paste0("site_distinct_", p$output_variable, "_", p$wave), length(unique(value[!is.na(value)])),
           paste("Distinct nonmissing site codes within this mapped wave only.", site_note), "review")
  }
  hard("no_unsupported_identifiers", identical(names(panel)[grepl("(^STUDY_ID$|_id$|identifier)", names(panel))],
         c("STUDY_ID", "pre_k_site_id", "teacher_rating_site_id")) && identical(names(panel), output_schema),
       "child and documented site fields only; exact schema excludes inferred identifiers", names(panel)[grepl("(^STUDY_ID$|_id$|identifier)", names(panel))])

  for (v in unique(registry$output_variable)) {
    sources <- unique(registry$source_variable[registry$output_variable == v & is_mapped])
    if (length(sources) > 1L) record(paste0("source_metadata_differences_", v), paste0(
      "sources=", paste(sources, collapse = ","), "; distinct_classes=", length(unique(vapply(wide[sources], class_text, character(1)))),
      "; distinct_attribute_representations=", length(unique(vapply(wide[sources], attribute_text, character(1))))),
      "Original metadata is serialized separately per source in provenance; numeric attributes are not merged.", "review")
  }
  for (i in seq_len(nrow(crosswalk))) {
    r <- crosswalk[i, ]
    if (r$documentation_status %in% c("partial", "conflict", "unresolved") ||
        r$transformation_status %in% c("blocked", "proposed_not_approved") ||
        nzchar(r$conflict_or_question_id) || r$review_status == "pending") {
      record(paste0("crosswalk_review_", r$dataset_id, "_", r$raw_variable), c(
        paste0("documentation=", r$documentation_status), paste0("transformation=", r$transformation_status),
        paste0("review=", r$review_status), r$conflict_or_question_id),
        paste(r$permitted_transformation, r$review_notes, "No blocked or proposed substantive action is applied; unchanged source carriage is permitted."), "review")
    }
  }
  hard("provenance_coverage", nrow(provenance) == 148L && !anyDuplicated(provenance$decision_id) &&
         !anyDuplicated(provenance[c("output_variable", "wave")]) &&
         identical(paste(provenance$output_variable, provenance$wave, sep = "::"), expected_keys) &&
         setequal(provenance$source_variable[is_mapped], verified_allowlist), "148 unique decisions covering all 62 sources", nrow(provenance))
  hard("provenance_controlled_values", all(provenance$mapping_class %in% c(
    "generated_structure", "identifier_repeat", "baseline_repeat", "wave_reshape", "source_specific_native_wave", "grade_context_repeat", "no_approved_source_mapping")) &&
      all(provenance$availability_status %in% c("source_mapped", "generated_structural", "no_approved_source_mapping", "documented_not_available_at_wave")) &&
      all(provenance$substantive_assumption == "none"), "approved controlled values; substantive_assumption always none", unique(provenance$mapping_class))
  hard("mapping_gap_provenance", all(provenance$availability_status[is_gap] == "no_approved_source_mapping") &&
         all(provenance$introduced_na_reason[is_gap] == gap_note) &&
         all(provenance$output_introduced_na_n[is_gap] == 1015L),
       "mapping gaps relative only to approved Stage 03 input", sum(is_gap))
  documented_absent <- provenance$availability_status == "documented_not_available_at_wave"
  hard("documented_nonavailability_citations", all(nzchar(provenance$source_document[documented_absent]) &
         nzchar(provenance$source_page_or_section[documented_absent])), "explicit citation required for documented nonavailability", sum(documented_absent))
  hard("source_citations_retained", all(nzchar(provenance$source_document[is_mapped])) &&
         all(nzchar(provenance$source_page_or_section[is_mapped])), "source-backed decisions retain documentary locators", sum(is_mapped))
  hard("applied_actions_only_mechanical", identical(provenance$transformation_applied, registry$transformation_applied) &&
         all(provenance$transformation_applied[is_mapped] == "none") &&
         all(provenance$transformation_applied[is_generated] == "derive_structure") &&
         all(provenance$transformation_applied[is_gap] == "introduce_mapping_gap_na") &&
         !any(provenance$transformation_applied %in% prohibited_actions),
       "unchanged source carriage, generated structure, mapping-gap NA only", unique(provenance$transformation_applied),
       paste("All mapped values and missing masks independently compared above. Prohibited actions:", paste(prohibited_actions, collapse = ", ")))
  record("locale_and_startup", c(Sys.getlocale(), if (is.null(warnings())) "no stored warnings" else names(warnings())),
         "Locale/startup fallback warnings are informational unless an actual reproducibility check fails.")
  gate("Pre-save validation failed")

  dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
  dir.create(dirname(provenance_path), recursive = TRUE, showWarnings = FALSE)
  saveRDS(panel, output_path)
  hard("rds_round_trip_identity", identical(readRDS(output_path), panel), "full saved/in-memory identity", "readRDS comparison")
  gate("RDS verification failed")
  write.csv(provenance, provenance_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  provenance_readback <- read_csv(provenance_path, col_classes = "character")
  # Compare literal CSV cells, including intentionally blank source counts for unmapped decisions.
  hard("provenance_csv_round_trip", identical(names(provenance_readback), names(provenance)) &&
         nrow(provenance_readback) == nrow(provenance) && all(vapply(names(provenance), function(v) {
           expected <- as.character(provenance[[v]])
           expected[is.na(expected)] <- ""
           identical(as.character(provenance_readback[[v]]), expected)
         }, logical(1))), "all provenance CSV cells preserved including source metadata", nrow(provenance_readback))
  hard("verification_check_ids_unique", !anyDuplicated(c(checks$check_id, "verification_check_ids_unique", "zero_failed_hard_checks")),
       "unique check IDs including final checks", nrow(checks) + 2L)
  hard("zero_failed_hard_checks", !any(checks$severity == "hard" & checks$status == "fail"), "zero failed hard checks",
       sum(checks$severity == "hard" & checks$status == "fail"))
  gate("Final artifact validation failed")
  write_checks()
  checks_readback <- read_csv(checks_path)
  if (!identical(checks_readback, checks)) stop("Saved verification report does not match the completed check registry.")
  message("Structural panel construction completed: ", nrow(wide), " x ", ncol(wide), " -> ", nrow(panel), " x ", ncol(panel), ".")
  message("Checks: ", nrow(checks), " total; ", sum(checks$severity == "hard"), " hard; ",
          sum(checks$severity != "hard"), " nonfatal; ", sum(checks$severity == "hard" & checks$status == "fail"), " failed hard.")
  message("Provenance: ", nrow(provenance), " unique decisions; ", length(unique(provenance$source_variable[is_mapped])),
          " inputs; ", sum(is_gap), " mapping-gap decisions; ", sum(provenance$output_introduced_na_n), " introduced NA cells.")
}, error = function(e) {
  add_check("build_error", "hard", "successful verified build", conditionMessage(e), "fail",
            "Build failed. Existing RDS/provenance files, if any, must not be treated as outputs of a successful new build.")
  write_checks()
  stop(conditionMessage(e), ". See output/verification/structural_panel_checks.csv. No successful build reported.", call. = FALSE)
})
