# Stage 08: substantive sample profile and outcome support.
# Run from the Git root in a fresh session (no upstream script is sourced):
# $env:LC_ALL = 'English_United States.utf8'
# & 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/08_describe_sample_support.R
# Default: two fresh workers, aggregate reconciliation, then six ignored outputs.
project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
root_raw <- system2("git", c("rev-parse", "--show-toplevel"), stdout = TRUE)
stopifnot(is.null(attr(root_raw, "status")))
git_root <- normalizePath(root_raw[1], winslash = "/", mustWork = TRUE)
if (!identical(project_start, git_root) || basename(git_root) != "ICPSR_04283")
  stop("Run from the ICPSR_04283 Git root.")
Sys.setenv(RENV_PATHS_ROOT = file.path(project_start, "renv", "local"),
  RENV_CONFIG_SANDBOX_ENABLED = "FALSE", RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
source(file.path(project_start, "renv", "activate.R"))
suppressPackageStartupMessages(library(here))
stopifnot(identical(normalizePath(here::here(), winslash = "/"), git_root))
options(stringsAsFactors = FALSE, OutDec = ".", digits = 17, warn = 2)

script_path <- "code/revision/08_describe_sample_support.R"
destinations <- c(paste0("output/tables/stage08_", c("characteristic_inventory",
  "pair_characteristics", "cleaned_histories", "belief_outcome_support"), ".csv"),
  "output/verification/stage08_checks.csv", "output/reports/stage08_sample_profile.md")
check_ignore <- function() {
  z <- vapply(destinations, function(p)
    identical(system2("git", c("check-ignore", "-q", "--", p)), 0L), logical(1))
  if (!all(z)) stop("Publication stopped: unignored destinations: ", paste(destinations[!z], collapse = ", "))
  z
}
invisible(check_ignore())
stopifnot(all(dir.exists(here::here(dirname(destinations)))))
bind <- function(x) { z <- do.call(rbind, x); row.names(z) <- NULL; z }
pct <- function(n, d) { z <- 100 * n / d; z[is.na(d) | d == 0] <- NA_real_; z }
same <- function(a, b) isTRUE(all.equal(a, b, tolerance = 1e-12, check.attributes = FALSE))
read_csv <- function(p) read.csv(p, check.names = FALSE, fileEncoding = "UTF-8")
write_csv <- function(x, p) {
  encode <- function(z) {
    if (is.character(z)) return(ifelse(is.na(z), "NA", paste0('"', gsub('"', '""', z, fixed = TRUE), '"')))
    if (is.logical(z)) return(ifelse(is.na(z), "NA", ifelse(z, "TRUE", "FALSE")))
    if (is.integer(z)) return(ifelse(is.na(z), "NA", as.character(z)))
    if (is.double(z)) return(ifelse(is.na(z), "NA", sprintf("%.17g", z)))
    stop("Unsupported CSV column type.")
  }
  cells <- lapply(x, encode)
  lines <- c(paste(encode(names(x)), collapse = ","), vapply(seq_len(nrow(x)), function(i)
    paste(vapply(cells, `[`, character(1), i), collapse = ","), character(1)))
  con <- file(p, "wb"); on.exit(close(con))
  writeBin(charToRaw(paste0(paste(lines, collapse = "\n"), "\n")), con)
}
check_csv <- function(x, p) {
  y <- read.csv(p, colClasses = "character", check.names = FALSE, na.strings = character())
  stopifnot(identical(names(x), names(y)), nrow(x) == nrow(y))
  for (f in names(x)) {
    a <- x[[f]]; b <- y[[f]]
    stopifnot(identical(is.na(a), b == "NA"))
    ok <- !is.na(a)
    if (is.character(a) || is.logical(a)) stopifnot(identical(as.character(a[ok]), b[ok])) else
      stopifnot(identical(as.double(a[ok]), as.double(b[ok])))
  }
  TRUE
}
protected_paths <- function() {
  extra <- unlist(lapply(c("Data", "docs", "code", "output", "paper"), function(p)
    file.path(p, list.files(p, recursive = TRUE, all.files = TRUE))), use.names = FALSE)
  paths <- sort(unique(c(system2("git", "ls-files", stdout = TRUE), gsub("\\\\", "/", extra))))
  setdiff(paths[file.exists(paths) & !dir.exists(paths)], destinations)
}
hashes <- function(p) { z <- tools::md5sum(here::here(p)); names(z) <- p; z }

waves <- c("PF", "PS", "KF", "KS")
grades <- c("Pre-K", "Kindergarten")
characteristics <- c("CHGENP", "CHRACE_AAP", "CHRACE_ASP", "CHRACE_LTP", "CHRACE_NAP",
  "CHRACE_WHP", "CHINCOMCP", "CHMATEDCP")
outcomes <- c("ppvt_english_standard_score", "applied_problems_english_standard_score",
  "sound_awareness_rhyming_raw_score", "tvip_spanish_standard_score", "tvip_spanish_raw_score",
  "woodcock_munoz_applied_problems_standard_score", "woodcock_munoz_applied_problems_w_score",
  "woodcock_munoz_letter_word_standard_score", "woodcock_munoz_letter_word_w_score")
short_names <- c("English PPVT standard", "English Applied Problems standard", "English rhyming raw",
  "Spanish TVIP standard", "Spanish TVIP raw", "Spanish WM Applied Problems standard",
  "Spanish WM Applied Problems W", "Spanish WM Letter-Word standard", "Spanish WM Letter-Word W")
belief_fields <- c("teacher_modernity_pre_k_fall_released", "teacher_modernity_kindergarten_fall_released")
pair_group <- function(fall, spring) {
  # Unresolved precedes explicit nonusability at the other occasion.
  ifelse(is.na(fall) | is.na(spring), "unresolved",
    ifelse(fall & spring, "complete_pair", "incomplete_pair"))
}
history_state <- function(eligible, reason) {
  ifelse(reason == "no_approved_mapping", "M", ifelse(is.na(eligible), "?", ifelse(eligible, "U", "N")))
}

# Verified documentary decisions. These describe the released categories, not a
# reconstruction of the original questionnaire responses or collapsed NA reasons.
make_inventory <- function(wide, crosswalk, provenance, setup, dictionary) {
  pages <- c("7", "9", "9", "9-10", "10", "11", "21-22", "8")
  items <- c("5", rep("10", 5), "15", "14")
  meanings <- c("Released child gender", "African American indicator", "Asian indicator", "Latino indicator",
    "Native American indicator", "White indicator", "Annual total family income from all sources",
    "Highest education of child's mother/female guardian living in household")
  bind(lapply(seq_along(characteristics), function(i) {
    f <- characteristics[i]; cw <- crosswalk[crosswalk$raw_variable == f, , drop = FALSE]
    pr <- provenance[provenance$raw_variable == f, , drop = FALSE]
    stopifnot(nrow(cw) == 1L, nrow(pr) == 1L, pr$included_in_output,
      pr$transformation_applied == "none", is.factor(wide[[f]]))
    start <- grep(paste0("^label define ", f, "[[:space:]]"), setup)
    stopifnot(length(start) == 1L)
    finish <- start - 1L + which(grepl(";", setup[start:length(setup)], fixed = TRUE))[1]
    definition <- paste(trimws(setup[start:finish]), collapse = " ")
    replacements <- grep(paste0("^replace ", f, " = \\. if "), setup)
    dct <- grep(paste0("[[:space:]]", f, "[[:space:]]"), dictionary)
    stopifnot(length(replacements) == 1L, length(dct) == 1L,
      grepl(paste0("(", f, " == -99)"), setup[replacements], fixed = TRUE))
    data.frame(row_id = paste0("inventory:", f), characteristic = f, meaning = meanings[i],
      respondent = "Adult taking most care of and knowing child best; may be mother, father, grandmother, foster parent, other",
      measurement_period = "Pre-K family questionnaire; exact administration relative to each Fall assessment not established",
      reference_period = if (i == 7L) "Annual total; exact income reference year not specified" else
        "Child/household characteristic at questionnaire response; exact date not established",
      released_coding = cw$value_labels, released_setup_definition = definition,
      units = if (i == 7L) "Annual family income in dollars, categorical intervals with open endpoints" else
        if (i == 8L) "Education category, not years" else "Released categorical response",
      special_values = "-99 System Missing in release documentation; setup replaces with missing; current R factor uses NA",
      current_representation = paste0("factor; levels: ", paste(levels(wide[[f]]), collapse = " | ")),
      n_children = nrow(wide), n_nonmissing = sum(!is.na(wide[[f]])), n_missing = sum(is.na(wide[[f]])),
      documentary_locators = paste0("docs/icpsr/DS0001/04283-0001-Codebook.pdf physical p.", pages[i],
        "; docs/icpsr/DS0001/04283-0001-Questionnaire.pdf physical p.", if (i == 1L) "85" else "86",
        " item ", items[i], "; Setup.do lines ", start, "-", finish, ",", replacements,
        "; Setup.dct line ", dct, "; docs/stage1_variable_crosswalk.csv raw_variable=", f,
        "; output/tables/verified_wide_provenance.csv raw_variable=", f),
      suitability = "Pre-K questionnaire descriptor for Pre-K; earlier-grade descriptor for Kindergarten; no universal pre-assessment claim",
      limitations = paste("Crosswalk respondent Parent/female guardian is narrower than questionnaire instructions; upstream unchanged.",
        if (i %in% 2:6) "Separate nonexclusive Yes/No indicator; selected indicators do not form an exhaustive classification." else
        if (i == 7L) "Not contemporaneous Kindergarten income; no midpoint conversion or category consolidation." else
        if (i == 8L) paste("Not contemporaneous Kindergarten education; zero-frequency Other retained. Questionnaire item 14 also offers",
          "No mother/female guardian in household, absent from released ten-category coding; its disposition is unresolved",
          "(S08_EDU_DISPOSITION). No inference about NA reasons or household composition is implemented.") else
          "Retain released Male/Female labels; no broader identity interpretation.",
        "Collapsed missing reasons and exact questionnaire/assessment ordering remain unresolved."))
  }))
}

summarize_pairs <- function(wide, eligibility) {
  bind(lapply(outcomes[1:3], function(o) bind(lapply(seq_along(grades), function(g) {
    e <- eligibility[[o]][, (2L * g - 1L):(2L * g), drop = FALSE]
    group <- pair_group(e[, 1], e[, 2])
    bind(lapply(characteristics, function(f) {
      x <- wide[[f]]; labels <- c(levels(x), "")
      kind <- c(rep("released_value", nlevels(x)), "source_missing")
      result <- bind(lapply(c("complete_pair", "incomplete_pair", "unresolved"), function(gr) {
        use <- group == gr; d <- sum(use); nm <- sum(use & !is.na(x))
        n <- c(vapply(levels(x), function(l) sum(use & !is.na(x) & as.character(x) == l), integer(1)), sum(use & is.na(x)))
        data.frame(outcome = o, grade = grades[g], characteristic = f, group = gr,
          category_order = seq_along(labels), category_kind = kind, category_label = labels,
          n_children = n, denominator_group = d, denominator_characteristic_nonmissing = nm,
          pct_category_nonmissing_primary = ifelse(kind == "released_value", pct(n, nm), NA_real_),
          pct_category_full_group_supplementary = ifelse(kind == "released_value", pct(n, d), NA_real_),
          pct_missing_full_group = ifelse(kind == "source_missing", pct(n, d), NA_real_))
      }))
      a <- result[result$group == "complete_pair", ]; b <- result[result$group == "incomplete_pair", ]
      result$pp_complete_minus_incomplete_primary <- rep(a$pct_category_nonmissing_primary - b$pct_category_nonmissing_primary, 3L)
      result$pp_missing_complete_minus_incomplete_full_group <- rep(a$pct_missing_full_group - b$pct_missing_full_group, 3L)
      result$row_id <- paste("pair", o, grades[g], f, result$group, result$category_order, sep = ":")
      result
    }))
  }))))
}

summarize_histories <- function(states, metadata) {
  stopifnot(all(c("outcome", "language", "score_type") %in% names(metadata)))
  bind(lapply(outcomes, function(o) {
    s <- states[[o]]; mapped <- colSums(s == "M") == 0L; nm <- sum(mapped)
    grid <- expand.grid(lapply(mapped, function(m) if (m) c("U", "N", "?") else "M"), stringsAsFactors = FALSE)
    pattern <- apply(s, 1L, paste0, collapse = "")
    keys <- apply(grid, 1L, paste0, collapse = "")
    # Lexical ordering is stable; rows with zero counts retain possible unknown states.
    keys <- sort(keys)
    counts <- as.integer(table(factor(pattern, levels = keys)))
    nu <- vapply(strsplit(keys, ""), function(k) sum(k == "U"), integer(1))
    nq <- vapply(strsplit(keys, ""), function(k) sum(k == "?"), integer(1))
    history <- data.frame(summary_type = "history", support_category = keys,
      n_usable_occasions = nu, n_unresolved_occasions = nq, n_children = counts)
    cc <- expand.grid(n_usable_occasions = 0:nm, n_unresolved_occasions = 0:nm)
    cc <- cc[cc$n_usable_occasions + cc$n_unresolved_occasions <= nm, , drop = FALSE]
    cc <- cc[order(cc$n_usable_occasions, cc$n_unresolved_occasions), , drop = FALSE]
    cc$n_children <- vapply(seq_len(nrow(cc)), function(i) sum(counts[nu == cc$n_usable_occasions[i] &
      nq == cc$n_unresolved_occasions[i]]), integer(1))
    count <- data.frame(summary_type = "usable_occasion_count", support_category = paste0("U", cc$n_usable_occasions,
      "_Q", cc$n_unresolved_occasions), cc)
    z <- rbind(history, count)
    z$outcome <- o; z$language <- metadata$language[match(o, metadata$outcome)]
    z$metric <- metadata$score_type[match(o, metadata$outcome)]
    z$mapped_wave_mask <- paste0(as.integer(mapped), collapse = "")
    z$n_mapped_occasions <- nm
    z$complete_mapped_history <- ifelse(z$n_unresolved_occasions > 0L, NA, z$n_usable_occasions == nm)
    z$denominator_children <- nrow(s); z$pct_children <- pct(z$n_children, nrow(s))
    z$row_id <- paste("history", o, z$summary_type, z$support_category, sep = ":")
    z
  }))
}

summarize_overlap <- function(wide, eligibility, mappings, belief_vectors, metadata) {
  stopifnot(all(c("outcome", "language", "score_type") %in% names(metadata)))
  bind(lapply(outcomes, function(o) bind(lapply(seq_along(grades), function(g) {
    wi <- (2L * g - 1L):(2L * g); e <- eligibility[[o]][, wi, drop = FALSE]
    b <- belief_vectors[[g]]; observed <- !is.na(b)
    bind(lapply(c("fall", "spring", "both"), function(period) {
      cols <- switch(period, fall = 1L, spring = 2L, both = 1:2)
      mapped <- all(mappings[[o]][wi[cols]])
      usable <- rowSums(e[, cols, drop = FALSE] == TRUE, na.rm = TRUE) == length(cols)
      unknown <- rowSums(is.na(e[, cols, drop = FALSE])) > 0L
      n <- if (mapped) sum(observed & usable) else NA_integer_
      data.frame(row_id = paste("overlap", o, grades[g], period, sep = ":"), outcome = o, grade = grades[g],
        language = metadata$language[match(o, metadata$outcome)], metric = metadata$score_type[match(o, metadata$outcome)],
        belief_field = belief_fields[g], belief_source_variable = c("T_IDEAP", "T_IDEAK")[g],
        belief_wave = waves[wi[1]], outcome_period = period, outcome_waves = paste(waves[wi[cols]], collapse = "+"),
        mapped = mapped, denominator_all_children = nrow(wide), denominator_belief_nonmissing = sum(observed),
        n_belief_finite = sum(observed & is.finite(b)), n_belief_nonfinite = sum(observed & !is.finite(b)),
        n_outcome_usable = if (mapped) sum(usable) else NA_integer_,
        n_outcome_unresolved = if (mapped) sum(unknown) else NA_integer_,
        n_belief_with_unresolved_outcome = if (mapped) sum(observed & unknown) else NA_integer_,
        n_overlap = n, pct_all_children = pct(n, nrow(wide)), pct_belief_nonmissing = pct(n, sum(observed)),
        interpretation = if (mapped) "Joint availability only; no Spring exposure assignment or score harmonization" else "No approved mapping; relevant overlap undefined")
    }))
  }))))
}

run_stage <- function(outdir) {
  paths_before <- protected_paths(); before <- hashes(paths_before)
  checks <- data.frame(check_id = character(), severity = character(), expected = character(),
    observed = character(), status = character(), detail = character())
  fmt <- function(x) paste(ifelse(is.na(x), "NA", as.character(x)), collapse = " | ")
  hard <- function(id, condition, expected = TRUE, observed = condition, detail = "") {
    stopifnot(!id %in% checks$check_id)
    checks <<- rbind(checks, data.frame(check_id = id, severity = "hard", expected = fmt(expected),
      observed = fmt(observed), status = if (isTRUE(condition)) "pass" else "fail", detail = detail))
    if (!isTRUE(condition)) stop("Failed check: ", id, "; expected ", fmt(expected), "; observed ", fmt(observed))
  }
  get_table <- function(p) read_csv(here::here(p))
  counts <- get_table("output/tables/outcome_cleaning_counts.csv")
  numeric <- get_table("output/tables/outcome_cleaning_numeric_summary.csv")
  pairs <- get_table("output/tables/outcome_cleaning_pair_support.csv")
  categories <- get_table("output/tables/descriptive_category_frequencies.csv")
  old_overlap <- get_table("output/tables/descriptive_belief_outcome_support.csv")
  old_patterns <- get_table("output/tables/descriptive_assessment_patterns.csv")
  crosswalk <- get_table("docs/stage1_variable_crosswalk.csv")
  provenance <- get_table("output/tables/verified_wide_provenance.csv")
  setup <- readLines(here::here("docs/icpsr/DS0001/04283-0001-Setup.do"), warn = FALSE)
  dictionary <- readLines(here::here("docs/icpsr/DS0001/04283-0001-Setup.dct"), warn = FALSE)
  wide <- readRDS(here::here("Data/processed/verified_child_wide.rds"))
  panel <- readRDS(here::here("Data/processed/outcome_cleaning_panel.rds"))
  structural <- readRDS(here::here("Data/processed/structural_child_wave_panel.rds"))
  hard("wide_dimensions", identical(dim(wide), c(1015L, 62L)), "1015 x 62", dim(wide))
  hard("panel_dimensions", identical(dim(panel), c(4060L, 65L)), "4060 x 65", dim(panel))
  hard("wide_child_keys", !anyNA(wide$STUDY_ID) && !anyDuplicated(wide$STUDY_ID))
  hard("panel_child_wave_keys", !anyNA(panel$STUDY_ID) && !anyDuplicated(panel[c("STUDY_ID", "wave")]) &&
    setequal(panel$STUDY_ID, wide$STUDY_ID) && identical(sort(unique(as.character(panel$wave))), sort(waves)))
  hard("four_occasions_each_child", all(table(panel$STUDY_ID) == 4L))
  hard("stage07_original_columns_preserved", identical(panel[names(structural)], structural))
  for (p in c("verified_wide", "structural_panel", "descriptive", "belief_score", "outcome_cleaning")) {
    upstream_checks <- get_table(paste0("output/verification/", p, "_checks.csv"))
    hard(paste0("upstream_checks_", p), !any(upstream_checks$status == "fail"))
  }
  hard("corrected_stage07_script", unname(tools::md5sum(here::here("code/revision/07_clean_outcomes_describe.R"))) ==
    "7f37f554685a7d5dac828f051994366e")
  hard("stage07_mapping_counts", nrow(counts) == 36L && !anyDuplicated(counts[c("outcome", "wave")]) &&
    setequal(counts$outcome, outcomes) && all(counts$n_structural == nrow(wide)))
  hard("stage07_pair_keys", nrow(pairs) == 18L && !anyDuplicated(pairs[c("outcome", "grade")]))
  hard("stage07_summary_keys", nrow(numeric) == 72L && !anyDuplicated(numeric[c("outcome", "wave", "view")]))
  hard("zero_denominator_fixture", all(is.na(pct(c(0, 1), c(0, 0)))))
  hard("unresolved_precedence_fixture", identical(pair_group(c(NA, FALSE, TRUE, FALSE, TRUE, NA),
    c(FALSE, NA, TRUE, FALSE, FALSE, NA)), c("unresolved", "unresolved", "complete_pair", "incomplete_pair", "incomplete_pair", "unresolved")))
  hard("history_unknown_vs_gap_fixture", identical(history_state(c(NA, FALSE, FALSE, TRUE),
    c("unresolved_score_value", "no_approved_mapping", "source_missing_reason_unavailable", "retained_under_current_rules")),
    c("?", "M", "N", "U")))

  # Explicit child-key joins: no reliance on the stored panel's row order.
  by_wave <- lapply(waves, function(w) {
    z <- panel[panel$wave == w, , drop = FALSE]; ix <- match(wide$STUDY_ID, z$STUDY_ID)
    hard(paste0("one_to_one_join_", w), length(ix) == nrow(wide) && !anyNA(ix) && !anyDuplicated(ix) &&
      identical(z$STUDY_ID[ix], wide$STUDY_ID))
    z[ix, , drop = FALSE]
  })
  names(by_wave) <- waves
  for (f in characteristics) for (w in waves)
    hard(paste("characteristic_repeats", f, w, sep = ":"), identical(wide[[f]], by_wave[[w]][[f]]))
  eligibility <- states <- mappings <- list()
  reason_fields <- c("no_approved_mapping", "source_missing_reason_unavailable", "practice_failure_project_exclusion",
    "documented_source_special", "documented_invalid_above_max", "unresolved_score_value", "retained_under_current_rules")
  reason_counts <- c("n_mapping_gap", "n_source_missing", "n_practice_failure_project_excluded",
    "n_documented_source_special", "n_documented_invalid", "n_unresolved_score_value", "n_eligible_current_rules")
  for (o in outcomes) {
    eligibility[[o]] <- do.call(cbind, lapply(by_wave, function(z) z[[paste0(o, "_eligible_current_rules")]]))
    rs <- do.call(cbind, lapply(by_wave, function(z) z[[paste0(o, "_cleaning_reason")]]))
    states[[o]] <- matrix(history_state(eligibility[[o]], rs), ncol = 4L, dimnames = list(NULL, waves))
    co <- counts[counts$outcome == o, ]; co <- co[match(waves, co$wave), ]
    mappings[[o]] <- co$mapped
    for (wi in seq_along(waves)) {
      w <- waves[wi]; e <- eligibility[[o]][, wi]; r <- rs[, wi]; s <- states[[o]][, wi]
      hard(paste("eligibility_type", o, w, sep = ":"), is.logical(e) && all(r %in% reason_fields))
      hard(paste("eligibility_reason", o, w, sep = ":"), identical(is.na(e), r == "unresolved_score_value") &&
        all(e[!is.na(e)] == (r[!is.na(e)] == "retained_under_current_rules")))
      for (j in seq_along(reason_fields)) hard(paste("reason_count", o, w, reason_fields[j], sep = ":"),
        sum(r == reason_fields[j]) == co[[reason_counts[j]]][wi], co[[reason_counts[j]]][wi], sum(r == reason_fields[j]))
      hard(paste("mapping_state", o, w, sep = ":"), if (co$mapped[wi]) all(s != "M") else all(s == "M"))
      clean <- by_wave[[wi]][[paste0(o, "_clean")]]
      hard(paste("usable_clean_value", o, w, sep = ":"), all(is.finite(clean[e %in% TRUE])) &&
        sum(e %in% TRUE) == co$n_eligible_current_rules[wi])
      for (st in c("U", "N", "M", "?")) hard(paste("state_marginal", o, w, st, sep = ":"),
        sum(s == st) == switch(st, U = co$n_eligible_current_rules[wi],
          N = co$n_source_missing[wi] + co$n_practice_failure_project_excluded[wi] + co$n_documented_source_special[wi] + co$n_documented_invalid[wi],
          M = co$n_mapping_gap[wi], `?` = co$n_unresolved_score_value[wi]))
    }
  }
  inventory <- make_inventory(wide, crosswalk, provenance, setup, dictionary)
  hard("inventory_eight_rows", nrow(inventory) == 8L && identical(inventory$characteristic, characteristics))
  expected_missing <- c(0L, rep(20L, 5), 62L, 19L)
  for (i in seq_along(characteristics)) {
    f <- characteristics[i]; x <- wide[[f]]; inv <- inventory[i, ]
    level_text <- sub("^\\([0-9]+\\) ", "", levels(x))
    # Setup definitions and dictionary, not empirical category guesses.
    tokens <- regmatches(inv$released_setup_definition, gregexpr('[-]?[0-9]+ "[^"]*"', inv$released_setup_definition))[[1]]
    codes <- as.integer(sub(' .*$', '', tokens)); labs <- sub('^[-]?[0-9]+ "(.*)"$', '\\1', tokens)
    hard(paste0("documented_levels:", f), identical(level_text, labs[codes != -99L]) &&
      identical(as.integer(sub("^\\(([0-9]+)\\).*$", "\\1", levels(x))), codes[codes != -99L]))
    hard(paste0("documented_missing:", f), inv$n_missing == expected_missing[i], expected_missing[i], inv$n_missing)
    old <- categories[categories$field == f & categories$period == "ALL_CHILDREN", ]
    direct <- c(as.integer(table(x)), sum(is.na(x)))
    hard(paste0("stage05_characteristic_categories:", f), identical(old$category_label, c(levels(x), "")) &&
      identical(old$category_kind, c(rep("released_value", nlevels(x)), "source_missing")) &&
      same(old$n_children, direct) && all(old$denominator_all_children == nrow(wide)) &&
      all(old$denominator_nonmissing == sum(!is.na(x))))
  }
  hard("zero_frequency_other_retained", nlevels(wide$CHMATEDCP) == 10L &&
    sum(wide$CHMATEDCP == "(10) Other", na.rm = TRUE) == 0L)
  # A nonempty group with no observed characteristic is distinct from an empty
  # group: category percentages are undefined, but missingness is 100 percent.
  fixture <- wide[1:3, characteristics, drop = FALSE]
  for (f in characteristics) fixture[[f]][] <- NA
  fixture_e <- setNames(rep(list(cbind(c(TRUE, FALSE, NA), c(TRUE, FALSE, FALSE),
    c(TRUE, FALSE, NA), c(TRUE, FALSE, FALSE))), 3L), outcomes[1:3])
  fixture_t <- summarize_pairs(fixture, fixture_e)
  hard("nonempty_all_characteristics_missing_fixture", all(fixture_t$denominator_group == 1L) &&
    all(fixture_t$denominator_characteristic_nonmissing == 0L) && all(is.na(fixture_t$pct_category_nonmissing_primary)) &&
    all(fixture_t$pct_missing_full_group[fixture_t$category_kind == "source_missing"] == 100))

  pair_table <- summarize_pairs(wide, eligibility)
  # Direct partitions also check every resolved support cell against Stage 07.
  approved <- rbind(c(750, 265, 55, 105, 105), c(796, 219, 15, 42, 162),
    c(734, 281, 56, 116, 109), c(815, 200, 16, 44, 140),
    c(742, 273, 56, 110, 107), c(814, 201, 16, 44, 141))
  k <- 0L
  for (o in outcomes) for (g in seq_along(grades)) {
    wi <- (2L * g - 1L):(2L * g); e <- eligibility[[o]][, wi, drop = FALSE]
    gr <- pair_group(e[, 1], e[, 2]); resolved <- gr != "unresolved"
    p <- pairs[pairs$outcome == o & pairs$grade == grades[g], ]
    if (all(mappings[[o]][wi])) {
      n <- c(both = sum(gr == "complete_pair"), fall_only = sum(resolved & e[, 1] %in% TRUE & e[, 2] %in% FALSE),
        spring_only = sum(resolved & e[, 1] %in% FALSE & e[, 2] %in% TRUE),
        neither = sum(resolved & e[, 1] %in% FALSE & e[, 2] %in% FALSE))
      hard(paste("resolved_pair_counts", o, grades[g], sep = ":"),
        same(unname(n), unlist(p[paste0("n_eligible_", c("both", "fall_only", "spring_only", "neither"))], use.names = FALSE)))
      hard(paste("unresolved_pair_counts", o, grades[g], sep = ":"), sum(!resolved) == p$n_pairs_with_unresolved_scores)
      hard(paste("partition_all_children", o, grades[g], sep = ":"), sum(n) + sum(!resolved) == nrow(wide) &&
        sum(n[-1]) == sum(gr == "incomplete_pair"))
    }
    if (!o %in% outcomes[1:3]) next
    k <- k + 1L
    hard(paste0("approved_pair_partition:", k), same(c(n[1], sum(n[-1]), n[-1]), approved[k, ]),
      approved[k, ], c(n[1], sum(n[-1]), n[-1]))
    hard(paste0("current_unresolved_zero:", k), sum(!resolved) == 0L, 0L, sum(!resolved))
    z <- pair_table[pair_table$outcome == o & pair_table$grade == grades[g], ]
    for (f in characteristics) {
      q <- z[z$characteristic == f, ]; x <- wide[[f]]
      a <- q[q$group == "complete_pair", ]; b <- q[q$group == "incomplete_pair", ]
      for (gr_name in c("complete_pair", "incomplete_pair", "unresolved")) {
        t <- q[q$group == gr_name, ]; use <- gr == gr_name
        hard(paste("pair_denominators", k, f, gr_name, sep = ":"), sum(t$n_children) == sum(use) &&
          all(t$denominator_group == sum(use)) && all(t$denominator_characteristic_nonmissing == sum(use & !is.na(x))))
        direct <- c(vapply(levels(x), function(l) sum(use & !is.na(x) & as.character(x) == l), integer(1)), sum(use & is.na(x)))
        hard(paste("pair_category_counts", k, f, gr_name, sep = ":"), same(t$n_children, direct))
        primary <- ifelse(t$category_kind == "released_value", pct(direct, sum(use & !is.na(x))), NA_real_)
        supplementary <- ifelse(t$category_kind == "released_value", pct(direct, sum(use)), NA_real_)
        missing <- ifelse(t$category_kind == "source_missing", pct(direct, sum(use)), NA_real_)
        hard(paste("pair_percentages", k, f, gr_name, sep = ":"), same(t$pct_category_nonmissing_primary, primary) &&
          same(t$pct_category_full_group_supplementary, supplementary) && same(t$pct_missing_full_group, missing))
        hard(paste("pair_differences", k, f, gr_name, sep = ":"),
          same(t$pp_complete_minus_incomplete_primary, a$pct_category_nonmissing_primary - b$pct_category_nonmissing_primary) &&
          same(t$pp_missing_complete_minus_incomplete_full_group, a$pct_missing_full_group - b$pct_missing_full_group))
      }
      # Restoring the three group counts reproduces Stage 05, including zero cells.
      totals <- aggregate(n_children ~ category_order, q, sum)$n_children
      old <- categories[categories$field == f & categories$period == "ALL_CHILDREN", ]
      hard(paste("pair_stage05_totals", k, f, sep = ":"), same(totals, old$n_children))
    }
  }
  histories <- summarize_histories(states, numeric)
  hard("history_metadata_columns", all(c("language", "metric") %in% names(histories)) &&
    !anyNA(histories$language) && !anyNA(histories$metric))
  for (o in outcomes) {
    h <- histories[histories$outcome == o, ]; s <- states[[o]]
    pat <- h[h$summary_type == "history", ]; hist <- apply(s, 1L, paste0, collapse = "")
    for (type in unique(h$summary_type)) hard(paste("history_total", o, type, sep = ":"),
      sum(h$n_children[h$summary_type == type]) == nrow(wide), nrow(wide), sum(h$n_children[h$summary_type == type]))
    hard(paste0("history_direct_patterns:", o), same(pat$n_children, vapply(pat$support_category,
      function(k) sum(hist == k), integer(1))))
    u <- rowSums(s == "U"); q <- rowSums(s == "?")
    cc <- h[h$summary_type == "usable_occasion_count", ]
    hard(paste0("usable_count_direct:", o), same(cc$n_children, vapply(seq_len(nrow(cc)), function(i)
      sum(u == cc$n_usable_occasions[i] & q == cc$n_unresolved_occasions[i]), integer(1))))
    hard(paste0("history_complete_mapping:", o), sum(pat$n_children[pat$complete_mapped_history %in% TRUE]) ==
      sum(u == sum(mappings[[o]]) & q == 0L))
    hard(paste0("history_unresolved_preserved:", o), sum(pat$n_children[pat$n_unresolved_occasions > 0]) == sum(q > 0L) &&
      all(is.na(pat$complete_mapped_history[pat$n_unresolved_occasions > 0])))
    for (wi in seq_along(waves)) for (state in c("U", "N", "M", "?")) hard(paste("history_margin", o, waves[wi], state, sep = ":"),
      sum(pat$n_children[substr(pat$support_category, wi, wi) == state]) == sum(s[, wi] == state))
    for (g in seq_along(grades)) if (all(mappings[[o]][(2L * g - 1L):(2L * g)])) {
      first <- 2L * g - 1L; second <- 2L * g
      p <- pairs[pairs$outcome == o & pairs$grade == grades[g], ]
      hard(paste("history_pair_intersection", o, grades[g], sep = ":"),
        sum(pat$n_children[substr(pat$support_category, first, second) == "UU"]) == p$n_eligible_both)
    }
    if (o != outcomes[2]) {
      old <- old_patterns[old_patterns$field == o & old_patterns$summary_type == "availability_pattern", ]
      converted <- chartr("UNM", "10M", pat$support_category)
      hard(paste0("unchanged_stage05_histories:", o), same(old$n_children, vapply(old$support_category, function(k)
        sum(pat$n_children[converted == k]), integer(1))))
    }
  }
  beliefs <- lapply(seq_along(grades), function(g) by_wave[[2L * g - 1L]][[belief_fields[g]]])
  for (g in seq_along(grades)) {
    b <- beliefs[[g]]
    hard(paste0("belief_nonmissing:", grades[g]), sum(!is.na(b)) == c(987L, 840L)[g], c(987L, 840L)[g], sum(!is.na(b)))
    hard(paste0("belief_nonfinite:", grades[g]), sum(!is.na(b) & !is.finite(b)) == 0L, 0L, sum(!is.na(b) & !is.finite(b)))
    hard(paste0("belief_wide_values:", grades[g]), identical(as.double(b), as.double(wide[[c("T_IDEAP", "T_IDEAK")[g]]])),
      detail = "Stage 04 removed source-only empty value.labels attributes; compare released values. Original panel attributes are separately checked against Stage 04.")
  }
  overlap <- summarize_overlap(wide, eligibility, mappings, beliefs, numeric)
  hard("overlap_metadata_columns", all(c("language", "metric") %in% names(overlap)) &&
    !anyNA(overlap$language) && !anyNA(overlap$metric))
  for (i in seq_len(nrow(overlap))) {
    r <- overlap[i, ]; g <- match(r$grade, grades); o <- r$outcome
    wi <- (2L * g - 1L):(2L * g)
    cols <- switch(r$outcome_period, fall = 1L, spring = 2L, both = 1:2)
    use <- rep(TRUE, nrow(wide)); source_use <- use
    for (j in cols) {
      use <- use & eligibility[[o]][, wi[j]] %in% TRUE
      source_use <- source_use & !is.na(by_wave[[wi[j]]][[o]])
    }
    expected <- if (r$mapped) sum(!is.na(beliefs[[g]]) & use) else NA_integer_
    hard(paste0("overlap_direct:", r$row_id), same(r$n_overlap, expected) &&
      same(r$pct_all_children, pct(expected, nrow(wide))) &&
      same(r$pct_belief_nonmissing, pct(expected, sum(!is.na(beliefs[[g]])))))
    old <- old_overlap[old_overlap$outcome_field == o & old_overlap$grade == grades[g], ]
    field <- switch(r$outcome_period, fall = "n_belief_fall", spring = "n_belief_spring", both = "n_belief_both")
    old_direct <- if (r$mapped) sum(!is.na(beliefs[[g]]) & source_use) else NA_integer_
    hard(paste0("stage05_overlap_source:", r$row_id), same(old[[field]], old_direct))
    if (o != outcomes[2] || g == 2L) hard(paste0("unchanged_stage05_overlap:", r$row_id), same(r$n_overlap, old[[field]])) else
      hard(paste0("affected_AP_overlap_recomputed:", r$row_id), same(old[[field]] - r$n_overlap,
        sum(!is.na(beliefs[[g]]) & source_use & !use)))
    if (!r$mapped) hard(paste0("mapping_gap_undefined:", r$row_id), all(is.na(r[c("n_overlap", "n_outcome_usable",
      "n_outcome_unresolved", "n_belief_with_unresolved_outcome", "pct_all_children", "pct_belief_nonmissing")])))
  }
  tables <- list(inventory, pair_table, histories, overlap)
  for (i in seq_along(tables)) {
    t <- tables[[i]]
    hard(paste0("unique_aggregate_keys:", i), !anyNA(t$row_id) && !anyDuplicated(t$row_id))
    hard(paste0("deterministic_table_order:", i), identical(t, switch(i,
      make_inventory(wide, crosswalk, provenance, setup, dictionary), summarize_pairs(wide, eligibility),
      summarize_histories(states, numeric), summarize_overlap(wide, eligibility, mappings, beliefs, numeric))))
    p <- file.path(outdir, basename(destinations[i])); write_csv(t, p)
    hard(paste0("CSV_readback:", i), check_csv(t, p))
  }
  # Report references resolve exact named rows in the reused or new tables.
  report <- unname(render_report(inventory, pair_table, histories, overlap, categories, counts, numeric, pairs,
    old_overlap, before, hard))
  writeLines(enc2utf8(report), file.path(outdir, basename(destinations[6])), useBytes = TRUE)
  hard("report_roundtrip", identical(readLines(file.path(outdir, basename(destinations[6])), warn = FALSE, encoding = "UTF-8"), report))
  hard("protected_file_set_unchanged", identical(protected_paths(), paths_before))
  after <- hashes(paths_before)
  for (p in paths_before) hard(paste0("preserved:", p), identical(unname(before[p]), unname(after[p])), before[p], after[p],
    "MD5 before and after; read-only upstream artifact or source, including this implementation script.")
  hard("all_six_destinations_ignored", all(check_ignore()))
  hard("checks_unique", !anyDuplicated(checks$check_id))
  write_csv(checks, file.path(outdir, basename(destinations[5])))
  stopifnot(check_csv(checks, file.path(outdir, basename(destinations[5]))))
  message("PASS: Stage 08 worker; ", nrow(checks), " checks; table rows ", paste(vapply(tables, nrow, integer(1)), collapse = "/"), ".")
}

render_report <- function(inventory, pair_table, histories, overlap, categories, counts, numeric, pairs,
                          old_overlap, protected_hash, hard) {
  # Every numeric finding below is interpolated from these row selections. Row
  # IDs or upstream composite keys are printed beside the associated finding.
  pick <- function(t, use, id) {
    z <- t[use, , drop = FALSE]
    hard(paste0("report_row:", id), nrow(z) == 1L, 1L, nrow(z)); z
  }
  nfmt <- function(x) ifelse(is.na(x), "NA", formatC(x, format = "f", digits = 2))
  share <- function(n, d) paste0(n, "/", d, " (", nfmt(pct(n, d)), "%)")
  # Integer-valued structural counts come from verified inventory dimensions.
  N <- inventory$n_children[1]
  cat_lines <- vapply(characteristics, function(f) {
    z <- categories[categories$field == f & categories$period == "ALL_CHILDREN", ]
    missing <- pick(z, z$category_kind == "source_missing", paste0("profile_missing:", f))
    valid <- z[z$category_kind == "released_value", ]
    selected <- if (f == "CHGENP") valid[valid$category_label == "(2) Female", ] else if (f %in% characteristics[2:6])
      valid[valid$category_label == "(1) Yes", ] else valid[which.max(valid$n_children), ]
    hard(paste0("report_selected_category:", f), nrow(selected) == 1L)
    paste0("| ", f, " | ", selected$category_label, " | ", share(selected$n_children, selected$denominator_nonmissing),
      " | ", share(missing$n_children, missing$denominator_all_children), " | category_order=", selected$category_order,
      "; missing order=", missing$category_order, " |")
  }, character(1))
  coverage <- vapply(outcomes, function(o) {
    r <- counts[counts$outcome == o, ]; r <- r[match(waves, r$wave), ]
    vals <- ifelse(r$mapped, paste0(r$n_eligible_current_rules, "/", r$n_structural), "unmapped")
    paste0("| ", short_names[match(o, outcomes)], " | ", paste(vals, collapse = " | "), " | `", o, "` |")
  }, character(1))
  # One representative mapped marginal per distinct outcome, selected by the
  # first approved occasion, with the full diagnostics left in Stage 07.
  concentration <- vapply(outcomes, function(o) {
    co <- counts[counts$outcome == o & counts$mapped, ]; w <- waves[min(match(co$wave, waves))]
    r <- pick(numeric, numeric$outcome == o & numeric$wave == w & numeric$view == "current_rule_eligible",
      paste0("concentration:", o))
    paste0("| ", short_names[match(o, outcomes)], " / ", w, " | ", r$n_summarized, " | ", nfmt(r$mean), " / ", nfmt(r$sd),
      " | ", nfmt(r$p25), " / ", nfmt(r$median), " / ", nfmt(r$p75), " | ", nfmt(r$p05), " / ", nfmt(r$p95),
      " | ", nfmt(r$min), " / ", nfmt(r$max), " |")
  }, character(1))
  ap <- counts[counts$outcome == outcomes[2], ]; ap <- ap[match(waves, ap$wave), ]
  ap_pair <- pick(pairs, pairs$outcome == outcomes[2] & pairs$grade == grades[1], "AP_pair")
  ap_num <- numeric[numeric$outcome == outcomes[2] & numeric$wave == "PF", ]
  released <- pick(ap_num, ap_num$view == "released_numeric_diagnostic", "AP_PF_released")
  cleaned <- pick(ap_num, ap_num$view == "current_rule_eligible", "AP_PF_cleaned")
  exclusion <- paste0("Applied Problems Pre-K exclusions are ", ap$n_practice_failure_project_excluded[1], " PF and ",
    ap$n_practice_failure_project_excluded[2], " PS child-occasion scores (", sum(ap$n_practice_failure_project_excluded),
    " total). PF support changes ", ap$n_source_observed[1], " -> ", ap$n_eligible_current_rules[1], "; PS ", ap$n_source_observed[2],
    " -> ", ap$n_eligible_current_rules[2], ". Complete Pre-K pairs change ", ap_pair$n_source_both, " -> ", ap_pair$n_eligible_both,
    " (", ap_pair$n_pairs_lost, " lost pairs); exclusions and pair losses differ because some excluded scores already lacked the other occasion.",
    " The PF mean changes ", nfmt(released$mean), " -> ", nfmt(cleaned$mean), " and sample SD ", nfmt(released$sd), " -> ", nfmt(cleaned$sd),
    ". [Rows: outcome_cleaning_counts outcome=", outcomes[2], " wave=PF/PS; outcome_cleaning_pair_support same outcome grade=Pre-K;",
    " outcome_cleaning_numeric_summary same outcome wave=PF view=released_numeric_diagnostic/current_rule_eligible; each marginal uses its own n_summarized, not N=", N, ".]")
  english <- vapply(outcomes[1:3], function(o) {
    r <- numeric[numeric$outcome == o & numeric$view == "current_rule_eligible", ]; r <- r[match(waves, r$wave), ]
    paste0("- ", short_names[match(o, outcomes)], ": marginal medians PF/PS/KF/KS = ", paste(nfmt(r$median), collapse = "/"),
      "; eligible denominators = ", paste(r$n_summarized, collapse = "/"),
      ". [outcome_cleaning_numeric_summary outcome=", o, ", wave=PF/PS/KF/KS, view=current_rule_eligible.]")
  }, character(1))
  pair_interpretation <- character(); gaps <- character(); missing_lines <- character()
  for (o in outcomes[1:3]) for (g in grades) {
    p <- pick(pairs, pairs$outcome == o & pairs$grade == g, paste0("pair:", o, ":", g))
    incomplete <- p$n_eligible_fall_only + p$n_eligible_spring_only + p$n_eligible_neither
    q <- pair_table[pair_table$outcome == o & pair_table$grade == g, ]
    female_a <- pick(q, q$characteristic == "CHGENP" & q$group == "complete_pair" & q$category_order == 2L,
      paste0("female_complete:", o, ":", g))
    female_b <- pick(q, q$characteristic == "CHGENP" & q$group == "incomplete_pair" & q$category_order == 2L,
      paste0("female_incomplete:", o, ":", g))
    income_a <- pick(q, q$characteristic == "CHINCOMCP" & q$group == "complete_pair" & q$category_kind == "source_missing",
      paste0("income_missing_complete:", o, ":", g))
    income_b <- pick(q, q$characteristic == "CHINCOMCP" & q$group == "incomplete_pair" & q$category_kind == "source_missing",
      paste0("income_missing_incomplete:", o, ":", g))
    pair_interpretation <- c(pair_interpretation, paste0("- ", g, ", ", short_names[match(o, outcomes)], ": complete ",
      share(p$n_eligible_both, N), ", incomplete ", share(incomplete, N), "; the latter comprises Fall-only ", p$n_eligible_fall_only,
      ", Spring-only ", p$n_eligible_spring_only, ", neither ", p$n_eligible_neither, "; unresolved ", p$n_pairs_with_unresolved_scores,
      ". Female representation is ", share(female_a$n_children, female_a$denominator_characteristic_nonmissing), " versus ",
      share(female_b$n_children, female_b$denominator_characteristic_nonmissing), " (complete minus incomplete ",
      nfmt(female_a$pp_complete_minus_incomplete_primary), " percentage points). Income missingness is ",
      share(income_a$n_children, income_a$denominator_group), " versus ", share(income_b$n_children, income_b$denominator_group),
      " (difference ", nfmt(income_a$pp_missing_complete_minus_incomplete_full_group), " points). [Support: outcome_cleaning_pair_support outcome=", o,
      ", grade=", g, "; composition: stage08_pair_characteristics row_id=", female_a$row_id, ", ", female_b$row_id, ", ", income_a$row_id,
      ", ", income_b$row_id, ".]"))
    for (f in characteristics) {
      a <- q[q$characteristic == f & q$group == "complete_pair" & q$category_kind == "released_value", ]
      # Explicit descriptive scan; ties retain released order. No test or model selection.
      a <- a[which.max(round(abs(a$pp_complete_minus_incomplete_primary), 12)), ]
      b <- pick(q, q$characteristic == f & q$group == "incomplete_pair" & q$category_order == a$category_order,
        paste0("gap_incomplete:", o, ":", g, ":", f))
      gaps <- c(gaps, paste0("| ", g, " / ", short_names[match(o, outcomes)], " | ", f, " ", a$category_label, " | ",
        share(a$n_children, a$denominator_characteristic_nonmissing), " | ", share(b$n_children, b$denominator_characteristic_nonmissing),
        " | ", nfmt(a$pp_complete_minus_incomplete_primary), " | ", a$row_id, " ; ", b$row_id, " |"))
    }
    m <- q[q$category_kind == "source_missing" & q$group == "complete_pair", ]
    m <- m[match(characteristics, m$characteristic), ]
    missing_lines <- c(missing_lines, paste0("| ", g, " / ", short_names[match(o, outcomes)], " | ",
      paste(nfmt(m$pp_missing_complete_minus_incomplete_full_group), collapse = " | "), " |"))
  }
  history_lines <- vapply(outcomes, function(o) {
    h <- histories[histories$outcome == o & histories$summary_type == "usable_occasion_count", ]
    complete <- sum(h$n_children[h$complete_mapped_history %in% TRUE])
    none <- sum(h$n_children[h$n_usable_occasions == 0L & h$n_unresolved_occasions == 0L])
    unresolved <- sum(h$n_children[h$n_unresolved_occasions > 0L])
    mapped <- h$n_mapped_occasions[1]
    distribution <- vapply(0:mapped, function(n) paste0(n, ":", sum(h$n_children[h$n_usable_occasions == n &
      h$n_unresolved_occasions == 0L])), character(1))
    paste0("| ", short_names[match(o, outcomes)], " | ", h$mapped_wave_mask[1], " / ", mapped, " | ",
      share(complete, N), " | ", share(none, N), " | ", unresolved, " | ", paste(distribution, collapse = "; "), " | `", o, "` |")
  }, character(1))
  overlap_lines <- character()
  for (o in outcomes) for (g in grades) {
    z <- overlap[overlap$outcome == o & overlap$grade == g, ]; z <- z[match(c("fall", "spring", "both"), z$outcome_period), ]
    cells <- vapply(seq_len(nrow(z)), function(i) if (!z$mapped[i]) "undefined (unmapped)" else
      paste0(z$n_overlap[i], "; ", nfmt(z$pct_all_children[i]), "% / ", nfmt(z$pct_belief_nonmissing[i]), "%"), character(1))
    overlap_lines <- c(overlap_lines, paste0("| ", g, " / ", short_names[match(o, outcomes)], " | ", z$denominator_belief_nonmissing[1],
      " | ", paste(cells, collapse = " | "), " | `", o, "` |"))
  }
  affected <- overlap[overlap$outcome == outcomes[2] & overlap$grade == "Pre-K", ]
  affected <- affected[match(c("fall", "spring", "both"), affected$outcome_period), ]
  old_ap <- pick(old_overlap, old_overlap$outcome_field == outcomes[2] & old_overlap$grade == "Pre-K", "old_AP_overlap")
  example <- function(f, category, gr) pick(pair_table, pair_table$outcome == outcomes[1] & pair_table$grade == grades[1] &
    pair_table$characteristic == f & pair_table$category_order == category & pair_table$group == gr,
    paste0("interpretation:", f, ":", gr))
  latino <- lapply(c("complete_pair", "incomplete_pair"), function(gr) example("CHRACE_LTP", 2L, gr))
  low_income <- lapply(c("complete_pair", "incomplete_pair"), function(gr) example("CHINCOMCP", 1L, gr))
  low_education <- lapply(c("complete_pair", "incomplete_pair"), function(gr) example("CHMATEDCP", 1L, gr))
  rhyming <- pick(numeric, numeric$outcome == outcomes[3] & numeric$wave == "PF" & numeric$view == "current_rule_eligible", "rhyming_concentration")
  composition_finding <- paste0("A prominent observed pattern is the lower Latino-indicator Yes share among children with complete English pairs.",
    " For Pre-K PPVT it is ", share(latino[[1]]$n_children, latino[[1]]$denominator_characteristic_nonmissing), " versus ",
    share(latino[[2]]$n_children, latino[[2]]$denominator_characteristic_nonmissing), " (difference ",
    nfmt(latino[[1]]$pp_complete_minus_incomplete_primary), " points). The lowest income category is also less represented: ",
    share(low_income[[1]]$n_children, low_income[[1]]$denominator_characteristic_nonmissing), " versus ",
    share(low_income[[2]]$n_children, low_income[[2]]$denominator_characteristic_nonmissing),
    "; and mother/female-guardian education of eighth grade or less is ",
    share(low_education[[1]]$n_children, low_education[[1]]$denominator_characteristic_nonmissing), " versus ",
    share(low_education[[2]]$n_children, low_education[[2]]$denominator_characteristic_nonmissing),
    ". Thus complete English pairs describe a different observed socioeconomic and ethnic composition; the selected tables show this is not simply equal composition with fewer children.",
    " Language-specific assessment access is a possible explanation for the ethnic pattern, but the indicators do not establish language or missingness reasons.",
    " [stage08_pair_characteristics row_id=", paste(vapply(c(latino, low_income, low_education), function(r) r$row_id, character(1)), collapse = "; "), ".]")
  reason_total <- vapply(c("n_mapping_gap", "n_source_missing", "n_practice_failure_project_excluded", "n_documented_source_special",
    "n_documented_invalid", "n_unresolved_score_value", "n_eligible_current_rules"), function(f) sum(counts[[f]]), numeric(1))
  report <- c("# Stage 08: substantive sample profile and outcome support", "",
    "## What this evidence supports", "",
    paste0("The released sample contains ", N, " children and ", nrow(counts) / length(outcomes),
      " structural assessment occasions per child. English within-grade pairs provide considerably more joint support than the Spanish series.",
      " Requiring a complete pair changes observed composition and would define an outcome-specific population. These unweighted descriptions",
      " support a design-feasibility decision; they do not define the final analytic sample, establish causal identification, or justify missing-at-random assumptions.",
      " [Inventory n_children; outcome_cleaning_counts keys outcome/wave; six pair discussions and overlap rows below.]"), "",
    "No upstream result was regenerated. Released values, cleaned datasets, and upstream code/output files are read-only. Native Fall beliefs are not harmonized or assigned to Spring. No regressions, significance tests, weighting, gain construction, imputation, clustering decision, or continuity investigation is performed.", "",
    "## Who is represented and when characteristics were measured", "",
    "These are Pre-K questionnaire characteristics. Exact administration relative to every child's Fall assessment is not established. For Kindergarten they describe the earlier grade, so income and education are not contemporaneous Kindergarten controls. Questionnaire physical pages 85-86 permit the adult who knows and cares for the child best, including fathers and other caregivers; the crosswalk's Parent/female guardian description is narrower. The inventory records both without editing upstream provenance.", "",
    "Each row below uses existing descriptive_category_frequencies, period=ALL_CHILDREN, field shown, released category and missing row orders shown. Category percentages use characteristic-nonmissing children; missingness percentages use the whole released sample. For income/education the modal released category is displayed; no categories were combined.", "",
    "| Characteristic | Selected category | Category n / nonmissing | Missing n / all children | Stage 05 row locator |",
    "|---|---|---|---|---|", cat_lines, "",
    "The five race indicators are separate nonexclusive responses. Their Yes counts must not be read as mutually exclusive group sizes or summed into a reconstructed race classification. The income distribution retains its open-ended categories and the education distribution retains zero-frequency Other. Education refers to the mother/female guardian living in the household, regardless of the questionnaire respondent. There is no conversion to income midpoints or years of education.", "",
    "Unresolved characteristic issues: exact questionnaire/assessment ordering; exact annual income reference year; collapsed missing reasons; and S08_EDU_DISPOSITION, the questionnaire's additional No mother/female guardian response absent from the release's ten education categories. Its disposition cannot be recovered from NA alone. The affected interpretation (why education is missing) is paused; published categories and descriptive comparisons remain supported. [stage08_characteristic_inventory row_id=inventory:CHINCOMCP and inventory:CHMATEDCP; codebook physical pp.8,21-22; questionnaire physical p.86 items 14-16; setup definitions/replacements and dictionary entries located in inventory.]", "",
    "The guide's recruitment and maintenance description provides a plausible context for changing assessment availability: consent and eligibility screening, later recruitment/replacement, and different tracking arrangements across grades. These historical study totals have not been forced to equal released score counts. Score histories do not identify individual enrollment, departure, attrition, or reasons for missingness. [docs/icpsr/04283-User_guide.pdf physical pp.14-15, Child Selection / The Sample Maintenance.]", "",
    "## Cleaned coverage, score concentration, and exclusions", "",
    paste0("Coverage below counts usable child-occasion values, each relative to ", N,
      " children. An unmapped entry means no approved source mapping, not a zero score or evidence of noncollection.",
      " [outcome_cleaning_counts outcome shown, wave=PF/PS/KF/KS, fields n_eligible_current_rules/n_structural.]"), "",
    "| Outcome | PF | PS | KF | KS | Exact outcome key |", "|---|---|---|---|---|---|", coverage, "",
    paste0("Across outcome-by-occasion cells: ", paste(reason_total, collapse = " + "), " = ", sum(reason_total),
      ". In order these are mapping gaps, source missingness, practice exclusions, other source-special exclusions, above-maximum exclusions, unresolved eligibility, and usable scores.",
      " They are child-occasion-outcome cells, not distinct children; the same child contributes to multiple outcomes.",
      " [outcome_cleaning_counts sums of n_mapping_gap/n_source_missing/n_practice_failure_project_excluded/n_documented_source_special/n_documented_invalid/n_unresolved_score_value/n_eligible_current_rules.]"), "",
    exclusion, "",
    "Practice failure is a documented project exclusion from numerical-score summaries, not a substituted floor score or a release correction. Its effect on the mean and dispersion shows why keeping those codes as scores was consequential, despite a small availability reduction. Selection on practice performance could alter the represented achievement distribution; its direction/size beyond these observed summaries is not established. Source-missing reasons remain unavailable, and assessment status alone does not exclude a numerical score.", "",
    "The following selected marginals explain concentration without reproducing the full distribution report. The first mapped occasion is shown for each distinct instrument/language/metric. Each row is outcome_cleaning_numeric_summary, outcome key from the coverage table, wave shown, view=current_rule_eligible; n is n_summarized. SD is sample SD and quantiles are R type 7.", "",
    "| Outcome / wave | Eligible n | Mean / SD | p25 / median / p75 | p05 / p95 | Observed min / max |",
    "|---|---:|---|---|---|---|", concentration, "",
    "The interquartile and p05-p95 intervals show where the middle portions of each observed marginal lie; the extrema describe the actual retained tails. The existing ECDFs (output/figures/outcome_cleaning_distributions.pdf, pages in the coverage table's outcome order) rise most quickly where scores concentrate. A curve's height is the fraction of its own included scores at or below a value, and each nonempty curve ends at one. Curves overlap where cleaning changes no scores; the Applied Problems Pre-K page exposes the removed negative-code tail. Panel ranges vary, so apparent curve slopes across panels are not directly comparable densities.", "",
    paste0("Pre-K Fall rhyming is strongly concentrated at its observed minimum: p25 and median are ", nfmt(rhyming$p25),
      " and ", nfmt(rhyming$median), ", the observed minimum is ", nfmt(rhyming$min), " and p75 is ", nfmt(rhyming$p75),
      " among ", rhyming$n_summarized, " usable scores. The ECDF's large first step corroborates this concentration. This is an observed pile-up, not a claim of a documented lower bound or psychometric floor effect.",
      " [outcome_cleaning_numeric_summary outcome=", outcomes[3], ", wave=PF, view=current_rule_eligible; distribution PDF page 3 PF panel.]"), "",
    english, "",
    "Those median differences describe different observed marginals. They are neither within-child changes nor absolute learning gains. Rhyming is a raw-score measure with a documented upper bound, while standard and W scores remain separate metrics. Observed extrema alone do not prove floor/ceiling effects or theoretical bounds. The guide/release Woodcock-Munoz summary discrepancy, unsupported bounds/norming conventions, and score comparability remain unresolved at the Stage 07 endpoint; release-specific metrics are retained without conversion. See outcome_cleaning_review.md, S07_BOUNDS and S07_WM_GUIDE; Stage 06 Q01 remains the belief-scoring endpoint.", "",
    "## Who has a complete within-grade English pair", "",
    "Unresolved eligibility at either occasion takes precedence, even if the other occasion is explicitly nonusable. Complete means both usable; incomplete means both eligibility decisions resolved and at least one nonusable. The bullets reuse Stage 07 support; all selected characteristics use the full pair groups without requiring beliefs, joint covariate completeness, or a four-occasion history. Female and income-missing comparisons are fixed report examples, not tests.", "",
    pair_interpretation, "",
    "The next table scans every characteristic in every comparison. It displays the released category with the largest absolute complete-minus-incomplete difference, breaking ties at 12 decimal places by released order. This is a transparent descriptive scan; small cell counts can create large percentages, and it is not a ranking of causal importance. Full original-category results, including zero-frequency and unresolved rows, are in stage08_pair_characteristics.csv.", "",
    "| Comparison | Characteristic / category | Complete n / nonmissing | Incomplete n / nonmissing | Primary difference (pp) | Exact row IDs |",
    "|---|---|---|---|---:|---|", gaps, "",
    "Missingness is a separate composition dimension. This table gives complete-minus-incomplete missingness percentage points, each using full-group denominators. Exact keys in stage08_pair_characteristics are outcome/grade as above, characteristic as column, category_kind=source_missing, group=complete_pair; the row also stores both groups' common comparison difference.", "",
    paste0("| Comparison | ", paste(characteristics, collapse = " | "), " |"),
    paste0("|---|", paste(rep("---:", length(characteristics)), collapse = "|"), "|"), missing_lines, "",
    "The six comparisons show that assessment completeness is an observed selection dimension rather than just a reduction in row count. Spring-only, Fall-only, and neither have different availability histories, so an incomplete group is heterogeneous. Differences in these Pre-K descriptors may reflect recruitment, language/assessment access, household circumstances, or other processes; these are possible explanations, not identified mechanisms. Null or small differences in a listed descriptor cannot establish random missingness. No composition comparison chooses a preferred specification.", "",
    composition_finding, "",
    "## Outcome-specific longitudinal support", "",
    "History positions are PF/PS/KF/KS: U usable, N mapped but nonusable, M no approved mapping, ? unresolved eligibility. The history table includes zero-frequency possible states and a separate joint histogram of known usable and unresolved occasion counts. Complete mapped history requires U at every mapped occasion; with a mapping gap it can mean two occasions rather than four. Unresolved histories have an undefined complete indicator, and are never silently classified as ordinary nonusability.", "",
    "| Outcome | Mapping mask / mapped occasions | Complete mapped n / all | No usable and no unresolved n / all | Children with unresolved | Resolved usable-count histogram (occasions:children) | Exact outcome key |",
    "|---|---|---|---|---:|---|---|", history_lines, "",
    "Source: stage08_cleaned_histories, outcome shown, summary_type=usable_occasion_count, support_category=U{known usable}_Q{unresolved}; denominator_children is the full released sample in every row. Complete rows require complete_mapped_history=TRUE; no-usable rows are U0_Q0. For an exact four-position history use summary_type=history, support_category equal to its U/N/M/? string. Requiring every mapped score would retain different populations for different outcomes and is not imposed here. Limited Spanish longitudinal support constrains any later design; sparse support and intentional mapping gaps must be addressed on their own terms.", "",
    "## Native Fall beliefs and cleaned outcomes: joint availability", "",
    "Each cell below is overlap count; percent of all released children / percent of children with observed native Fall belief in that grade. Belief denominators are shown separately and all observed beliefs are finite (checked separately from nonmissingness). Fall, Spring, and both refer to outcome availability paired with that grade's native Fall belief, not three exposure definitions. Source: stage08_belief_outcome_support, outcome key shown, grade shown, outcome_period=fall/spring/both, row_id=overlap:{outcome}:{grade}:{period}.", "",
    "| Grade / outcome | Belief nonmissing denominator | Fall outcome | Spring outcome | Both outcomes | Exact outcome key |",
    "|---|---:|---|---|---|---|", overlap_lines, "",
    paste0("The affected Pre-K Applied Problems belief overlaps are recomputed as ", paste(affected$n_overlap, collapse = "/"),
      " for Fall/Spring/both, replacing released-value Stage 05 counts ", paste(c(old_ap$n_belief_fall, old_ap$n_belief_spring, old_ap$n_belief_both), collapse = "/"),
      ". All other overlap counts reconcile to Stage 05. [stage08_belief_outcome_support outcome=", outcomes[2],
      ", grade=Pre-K, outcome_period=fall/spring/both; descriptive_belief_outcome_support outcome_field=", outcomes[2], ", grade=Pre-K.]") , "",
    "English joint availability leaves room to consider a later grade-specific design, subject to exposure and scoring evidence. The Spanish series support substantially fewer children, and metrics/languages cannot be pooled merely to enlarge a sample. A Spring overlap establishes joint availability only: it does not show that the Fall respondent taught that child through Spring or justify carrying beliefs forward. Overlap counts also say nothing about independent teacher/classroom sample sizes; child-attached beliefs and context measurements are child-weighted records, not counts of independent teachers.", "",
    "## Evidence needed for the next design decision", "",
    "- Establish the Fall belief respondent and precise measurement/reference timing for each released source; retain the unresolved Stage 06 scoring/direction endpoint unless new release-specific evidence resolves it.",
    "- Establish whether and how the Fall teacher corresponds to the child's Spring teacher before assigning a Spring exposure.",
    "- Obtain definitions, derivation, reference interval, and scope for the distinct change fields; apparent code agreement alone cannot establish a common construction.",
    "- Establish valid child-teacher-classroom-site grouping and linkage, including longitudinal correspondence, before choosing an inference procedure or independent-unit count.",
    "- Resolve the education-response disposition only if interpreting its missingness mechanism; do not map No mother/female guardian into Other or NA without release-specific evidence.", "",
    "## Execution and verification record", "",
    "Exact generation command from the repository root:", "```powershell",
    "$env:LC_ALL = 'English_United States.utf8'",
    "$env:GIT_CONFIG_COUNT = '1'",
    "$env:GIT_CONFIG_KEY_0 = 'safe.directory'",
    "$env:GIT_CONFIG_VALUE_0 = (Get-Location).Path.Replace('\\','/')",
    "& 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/08_describe_sample_support.R", "```", "",
    "The default entry point runs this script in two fresh Rscript --vanilla worker processes, compares all four substantive CSVs, the worker checks CSV, and the report byte for byte, checks upstream preservation and ignored destinations, then publishes exactly six files. stage08_checks.csv records every hard check and before/after MD5 for protected paths. Generated outputs contain only aggregates. No staging, commit, or push is performed.", "",
    paste0("Protected-file coverage includes ", length(protected_hash) - 1L, " pre-existing upstream/source files plus this implementation script, listed by relative path in the preserved:* check rows. No source or upstream output is written by this script. Publication completes only after all substantive checks pass. The checks table's final parent checks document the actual fresh-process comparison and post-publication audit."))
  # The substantive endpoint is the evidence required next, after the execution record.
  next_at <- match("## Evidence needed for the next design decision", report)
  execution_at <- match("## Execution and verification record", report)
  c(report[seq_len(next_at - 1L)], report[execution_at:length(report)], "", report[next_at:(execution_at - 1L)])
}

main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) && args[1] == "--worker") {
    stopifnot(length(args) == 2L, dir.exists(args[2])); run_stage(args[2]); return(invisible(NULL))
  }
  if (length(args)) stop("Unknown arguments.")
  protected <- protected_paths(); before <- hashes(protected)
  staging <- tempfile("stage08_"); dir.create(staging)
  on.exit(unlink(staging, recursive = TRUE), add = TRUE)
  dirs <- file.path(staging, c("run1", "run2")); invisible(lapply(dirs, dir.create))
  rscript <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
  for (i in 1:2) {
    log <- file.path(staging, paste0("run", i, ".log"))
    status <- system2(rscript, c("--vanilla", shQuote(here::here(script_path)), "--worker", shQuote(dirs[i])), stdout = log, stderr = log)
    message(paste(readLines(log, warn = FALSE), collapse = "\n"))
    if (status != 0L) stop("Stage 08 worker ", i, " failed; no outputs published.")
  }
  a <- file.path(dirs[1], basename(destinations)); b <- file.path(dirs[2], basename(destinations))
  stopifnot(all(file.exists(a)), all(file.exists(b)), identical(unname(tools::md5sum(a)), unname(tools::md5sum(b))),
    identical(protected_paths(), protected), identical(hashes(protected), before))
  ck <- read.csv(a[5], colClasses = "character", na.strings = character())
  add <- function(id, expected, observed, detail = "") {
    ck <<- rbind(ck, data.frame(check_id = id, severity = "hard", expected = expected, observed = observed, status = "pass", detail = detail))
  }
  add("fresh_process_all_six_bytes", "6 byte-identical worker artifacts", "6 byte-identical worker artifacts",
    "Two fresh Rscript --vanilla processes; four substantive tables, worker checks, report; no timestamp exclusions.")
  for (i in c(1:4, 6)) add(paste0("reproducible_md5:", destinations[i]), unname(tools::md5sum(a[i])), unname(tools::md5sum(b[i])))
  add("parent_protected_before_publication", as.character(length(protected)), as.character(length(protected)))
  invisible(check_ignore()); add("parent_ignore_gate", "6 ignored paths", "6 ignored paths")
  diff <- system2("git", c("diff", "--check"), stdout = TRUE, stderr = TRUE)
  stopifnot(is.null(attr(diff, "status")))
  lines <- readLines(here::here(script_path), warn = FALSE)
  stopifnot(!any(grepl("[ \t]+$", lines)), !any(grepl("^(<<<<<<<|=======|>>>>>>>)", lines)))
  add("git_diff_and_untracked_script_whitespace", "clean", "clean")
  # Publish only after every substantive and reproducibility gate. The final check
  # file also records real post-publication results, not an anticipated success.
  stopifnot(all(file.copy(a[c(1:4, 6)], here::here(destinations[c(1:4, 6)]), overwrite = TRUE)))
  stopifnot(identical(unname(tools::md5sum(a[c(1:4, 6)])), unname(tools::md5sum(here::here(destinations[c(1:4, 6)])))),
    identical(protected_paths(), protected), identical(hashes(protected), before), all(check_ignore()))
  add("post_publication_substantive_bytes", "5 exact published copies", "5 exact published copies")
  add("post_publication_upstream_preservation", as.character(length(protected)), as.character(length(protected)))
  stopifnot(!anyDuplicated(ck$check_id), all(ck$status == "pass"))
  write_csv(ck, a[5]); stopifnot(check_csv(ck, a[5]))
  stopifnot(file.copy(a[5], here::here(destinations[5]), overwrite = TRUE),
    identical(unname(tools::md5sum(a)), unname(tools::md5sum(here::here(destinations)))),
    identical(hashes(protected), before), all(check_ignore()))
  message("PASS: six ignored outputs published; ", nrow(ck), " passing checks; upstream preserved; no staging, commit, or push.")
}
main()
