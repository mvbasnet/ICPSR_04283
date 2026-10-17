# Bounded, aggregate-only scoring diagnostics. No upstream script is sourced.
# From the Git root, in a fresh process:
# $env:LC_ALL = 'English_United States.utf8'
# & 'C:\Program Files\R\R-4.6.1\bin\Rscript.exe' --vanilla code/revision/06_investigate_belief_scores.R
project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
gr <- system2("git", c("rev-parse", "--show-toplevel"), stdout = TRUE, stderr = TRUE)
if (!is.null(attr(gr, "status"))) stop("Cannot determine Git root.")
if (!identical(project_start, normalizePath(gr[1], winslash = "/")) ||
    basename(project_start) != "ICPSR_04283") stop("Run from the ICPSR_04283 Git root.")
Sys.setenv(RENV_PATHS_ROOT = file.path(project_start, "renv", "local"),
           RENV_CONFIG_SANDBOX_ENABLED = "FALSE", RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
source(file.path(project_start, "renv", "activate.R"))
suppressPackageStartupMessages(library(here))
stopifnot(identical(normalizePath(here::here(), winslash = "/"), project_start))
options(stringsAsFactors = FALSE)
script_path <- "code/revision/06_investigate_belief_scores.R"
table_ids <- c("evidence", "support", "values", "compatibility", "reconstruction", "conclusions")
paths <- c(setNames(paste0("output/tables/belief_score_", table_ids, ".csv"), table_ids),
           checks = "output/verification/belief_score_checks.csv",
           review = "output/verification/belief_score_review.md")
is_ignored <- function(p) identical(system2("git", c("check-ignore", "-q", "--", p)), 0L)
if (!all(vapply(paths, is_ignored, logical(1)))) stop("All eight destinations must be ignored.")
if (!all(dir.exists(here::here(c("output/tables", "output/verification"))))) stop("Missing output directories.")
# Only this new script and its eight destinations are excluded from preservation.
protected <- sort(unique(c("AGENTS.md", ".gitignore", "renv.lock", "renv/activate.R", "renv/settings.json",
  unlist(lapply(c("Data", "docs", "code", "output"), list.files, recursive = TRUE,
                full.names = TRUE, all.files = TRUE, no.. = TRUE)))))
protected <- setdiff(protected[!dir.exists(protected)], c(script_path, unname(paths)))
before <- tools::md5sum(here::here(protected)); names(before) <- protected
schemas <- list(
 evidence = "evidence_id,hypothesis_id,dataset_id,object_name,variable,grade,occasion,resource_path,locator,availability,item_status,claim,limitation,issue_id",
 support = "dataset_id,variable,grade,occasion,unit,stratum,scale_id,summary_source,n_records,n_source_missing,n_nonfinite,n_finite,n_distinct_finite,pct_source_nonmissing,mean,sd,min,p05,p25,median,p75,p95,max,summary_status",
 values = "dataset_id,variable,grade,occasion,unit,stratum,candidate_id,precision_id,value_id,value,frequency,n_finite,pct_finite,cent_residual,gap_previous,numerical_category,primary_category,changed_from_primary,arithmetic_m_set,rounding_m_set,boundary_m_set,incompatible_m_set,n_compatible_m,n_boundary_m,nearest_grid_value,nearest_m,signed_residual,min_abs_residual",
 compatibility = "dataset_id,variable,stratum,candidate_id,precision_id,denominator_id,m,numerical_category,n_records,n_source_missing,n_nonfinite,n_finite,n_distinct_finite,n_observations,pct_observations,n_distinct_values,pct_distinct_values,n_changed_observations,n_changed_distinct_values,max_min_abs_residual",
 reconstruction = "dataset_id,variable,stratum,rule_id,item_set_id,key_id,completion_stratum,m_observed,precision_id,numerical_category,n_records,n_eligible,n_ineligible,n_released_missing,n_released_nonfinite,n_released_finite,n_eligible_released_missing,n_eligible_released_nonfinite,n_evaluated,n_observations,pct_evaluated,n_distinct_evaluated_pairs,n_distinct_pairs,pct_distinct_pairs,n_changed_observations,n_changed_distinct_pairs,max_abs_residual",
 conclusions = "conclusion_id,hypothesis_id,claim_id,dataset_id,variable,stratum,candidate_id,denominator_id,precision_id,rounding_scenario,assumptions,diagnostic_ref,n_evaluated,n_distinct_evaluated,n_pass,n_boundary,n_contradicted,n_distinct_pass,n_distinct_boundary,n_distinct_contradicted,evidence_category,conclusion_code,conclusion,limitations",
 checks = "check_id,severity,expected,observed,status,detail")
schemas <- lapply(schemas, function(s) strsplit(s, ",", fixed = TRUE)[[1]])
integer_col <- function(n) grepl("^n_", n) || n %in% c("frequency", "m", "m_observed", "nearest_m")
double_cols <- c("value", "cent_residual", "gap_previous", "nearest_grid_value", "signed_residual",
                 "min_abs_residual", "max_min_abs_residual", "max_abs_residual",
                 "mean", "sd", "min", "p05", "p25", "median", "p75", "p95", "max")
col_type <- function(n, table) {
  if (table == "checks") "character" else if (integer_col(n)) "integer" else
    if (grepl("^pct_", n) || n %in% double_cols) "double" else
      if (n == "changed_from_primary") "logical" else "character"
}
empty <- function(id) as.data.frame(setNames(lapply(schemas[[id]], function(n)
  switch(col_type(n, id), character = character(), integer = integer(), double = double(), logical = logical())), schemas[[id]]))
checks <- empty("checks")
add_check <- function(id, ok, expected = "TRUE", observed = ok, detail = "not_applicable", severity = "hard") {
  show <- function(x) paste(ifelse(is.na(x), "NA", as.character(x)), collapse = " | ")
  checks <<- rbind(checks, data.frame(check_id = id, severity = severity, expected = show(expected),
    observed = show(observed), status = if (severity == "hard") if (isTRUE(ok)) "pass" else "fail" else
      if (severity == "review") "review" else "recorded", detail = detail))
}
gate <- function() if (any(checks$status == "fail")) stop("Failed checks: ", paste(checks$check_id[checks$status == "fail"], collapse = ", "))
read_csv <- function(p) read.csv(here::here(p), colClasses = "character", check.names = FALSE,
                                na.strings = character(), fileEncoding = "UTF-8")
bind <- function(z, id) if (length(z)) { x <- do.call(rbind, z); rownames(x) <- NULL; x } else empty(id)
pct <- function(n, d) if (d == 0L) NA_real_ else 100 * n / d
id_value <- function(x) ifelse(x == 0, "0", sprintf("%.17g", x))
near <- function(a, b) all((is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) &
  abs(a - b) <= 1e-12 * pmax(1, abs(a), abs(b))))
cats <- c("arithmetic", "rounding_only", "boundary", "incompatible")
precisions <- c("primary", "single_precision")
strata <- c("all", "both", "p_only", "k_only", "neither")
den_ids <- c(sprintf("M%02d", 1:16), "FAMILY")
eps <- function(a, b, q) (if (q == "primary") 1e-10 else max(1e-10, 2^-23)) * pmax(1, abs(a), abs(b))
cent <- function(x) {
  lo <- floor(x * 100) / 100; hi <- ceiling(x * 100) / 100
  if (abs(x - lo) <= abs(x - hi)) lo else hi
}
# Shared by grid diagnostics and singleton reconstruction. Never changes x.
classify <- function(x, grid, q) {
  if (!is.finite(x) || !length(grid) || any(!is.finite(grid))) stop("Finite nonempty grid and finite observation required.")
  if (any(abs(x - grid) <= eps(x, grid, q))) return("arithmetic")
  c0 <- cent(x)
  if (abs(x - c0) > eps(x, c0, q)) return("incompatible")
  d <- abs(grid - c0); e <- eps(grid, c0, q)
  if (any(d < .005 - e)) "rounding_only" else
    if (any(abs(d - .005) <= e)) "boundary" else "incompatible"
}
grid_for <- function(candidate, m) {
  stopifnot(candidate %in% c("P_PRORATED16", "K_AVAILABLE"), m %in% 1:16)
  (if (candidate == "P_PRORATED16") 16 else 1) * (m:(5 * m)) / m
}
nearest <- function(x, g, ms) {
  o <- order(abs(x - g), g, ms); j <- o[1]
  list(value = g[j], m = as.integer(ms[j]), signed = x - g[j], residual = abs(x - g[j]))
}
analyze_values <- function(v, candidate, q) {
  grids <- lapply(1:16, function(m) grid_for(candidate, m))
  all_g <- unlist(grids); all_m <- rep(1:16, lengths(grids))
  classification <- matrix(character(), nrow = length(v), ncol = 17L)
  residual <- matrix(NA_real_, nrow = length(v), ncol = 17L)
  nn <- vector("list", length(v))
  for (i in seq_along(v)) {
    for (m in 1:16) {
      classification[i, m] <- classify(v[i], grids[[m]], q)
      residual[i, m] <- min(abs(v[i] - grids[[m]]))
    }
    classification[i, 17] <- cats[min(match(classification[i, 1:16], cats))]
    nn[[i]] <- nearest(v[i], all_g, all_m)
    residual[i, 17] <- nn[[i]]$residual
  }
  list(category = classification, residual = residual, nearest = nn, grids = grids)
}
stats_names <- c("mean", "sd", "min", "p05", "p25", "median", "p75", "p95", "max")
summarize <- function(x) {
  n <- length(x); nm <- sum(is.na(x)); nf <- sum(!is.na(x) & !is.finite(x)); y <- x[is.finite(x)]
  state <- if (!n) "empty" else if (nm == n) "all_source_missing" else if (nf) "nonfinite_present" else
    if (length(y) == 1L) "singleton" else "ok"
  ss <- setNames(rep(NA_real_, 9), stats_names)
  if (state %in% c("singleton", "ok")) ss[] <- c(mean(y), if (length(y) > 1L) sd(y) else NA_real_,
    min(y), quantile(y, c(.05, .25, .5, .75, .95), type = 7, names = FALSE), max(y))
  cbind(data.frame(n_records = n, n_source_missing = nm, n_nonfinite = nf, n_finite = length(y),
    n_distinct_finite = length(unique(y)), pct_source_nonmissing = pct(n - nm, n)),
    as.data.frame(as.list(ss)), summary_status = state)
}
# This branch requires a positively documented same-object item/key registry.
# No fitted key, completion threshold or item subset is accepted here.
reconstruct <- function(items, key, allowed_codes, rule) {
  stopifnot(is.matrix(items), is.numeric(items), ncol(items) > 0L, length(key) == ncol(items),
            all(key %in% c("identity", "reverse_1_5")), identical(allowed_codes, 1:5),
            rule %in% c("sum_complete", "mean_complete", "mean_available", "sum_prorated"))
  bad <- rowSums(!is.na(items) & (!is.finite(items) | !(items %in% allowed_codes))) > 0L
  scored <- items
  for (j in which(key == "reverse_1_5")) scored[, j] <- 6 - scored[, j]
  m <- rowSums(!is.na(items)); eligible <- !bad & if (grepl("complete$", rule)) m == ncol(items) else m > 0L
  g <- rep(NA_real_, nrow(items)); sums <- rowSums(scored, na.rm = TRUE)
  g[eligible] <- switch(rule, sum_complete = sums[eligible], mean_complete = sums[eligible] / m[eligible],
    mean_available = sums[eligible] / m[eligible], sum_prorated = ncol(items) * sums[eligible] / m[eligible])
  list(value = g, eligible = eligible, m = m, bad = bad)
}
reconstruction_rows <- function(x, items, key, allowed_codes, ds, variable, item_set_id, key_id) {
  out <- list()
  for (rule in c("sum_complete", "mean_complete", "mean_available", "sum_prorated")) {
    rr <- reconstruct(items, key, allowed_codes, rule)
    completion <- ifelse(rr$bad, "uninterpretable", sprintf("m%02d", rr$m))
    for (st in c("all", sprintf("m%02d", 0:ncol(items)), "uninterpretable")) {
      ix <- if (st == "all") rep(TRUE, length(x)) else completion == st
      xx <- x[ix]; gg <- rr$value[ix]; el <- rr$eligible[ix]; ev <- el & is.finite(xx)
      prim <- vapply(which(ev), function(j) classify(xx[j], gg[j], "primary"), character(1))
      pair <- paste(id_value(xx[ev]), id_value(gg[ev]), sep = "::"); distinct <- !duplicated(pair)
      for (q in precisions) {
        cc <- vapply(which(ev), function(j) classify(xx[j], gg[j], q), character(1))
        for (cat in cats) {
          hit <- cc == cat; changed <- hit & cc != prim
          out[[length(out) + 1L]] <- data.frame(dataset_id = ds, variable = variable, stratum = "all",
            rule_id = rule, item_set_id = item_set_id, key_id = key_id, completion_stratum = st,
            m_observed = if (st %in% c("all", "uninterpretable")) NA_integer_ else as.integer(sub("m", "", st)),
            precision_id = q, numerical_category = cat, n_records = length(xx), n_eligible = sum(el),
            n_ineligible = sum(!el), n_released_missing = sum(is.na(xx)),
            n_released_nonfinite = sum(!is.na(xx) & !is.finite(xx)), n_released_finite = sum(is.finite(xx)),
            n_eligible_released_missing = sum(el & is.na(xx)),
            n_eligible_released_nonfinite = sum(el & !is.na(xx) & !is.finite(xx)), n_evaluated = sum(ev),
            n_observations = sum(hit), pct_evaluated = pct(sum(hit), sum(ev)),
            n_distinct_evaluated_pairs = sum(distinct), n_distinct_pairs = sum(hit & distinct),
            pct_distinct_pairs = pct(sum(hit & distinct), sum(distinct)), n_changed_observations = sum(changed),
            n_changed_distinct_pairs = sum(changed & distinct),
            max_abs_residual = if (any(hit)) max(abs(xx[ev][hit] - gg[ev][hit])) else NA_real_)
        }
      }
    }
  }
  bind(out, "reconstruction")
}
# Serialize doubles ourselves: write.csv's usual 15-digit formatting is insufficient.
serialize <- function(x, table) {
  z <- x
  for (n in names(z)) {
    type <- col_type(n, table)
    if (type == "double") z[[n]] <- as.character(ifelse(is.na(x[[n]]), "NA", sprintf("%.17g", x[[n]]))) else
      z[[n]] <- as.character(ifelse(is.na(x[[n]]), "NA", as.character(x[[n]])))
  }
  z
}
write_csv <- function(x, p, table) write.csv(serialize(x, table), here::here(p), row.names = FALSE,
                                            na = "NA", fileEncoding = "UTF-8")
validate_readback <- function(x, p, table) {
  y <- read_csv(p); expected <- serialize(x, table)
  add_check(paste0("readback_", table), identical(y, expected), "exact ordered serialized cells", nrow(y))
  for (n in names(x)) if (col_type(n, table) %in% c("integer", "double")) {
    tokens <- y[[n]]; tokens[tokens == "NA"] <- NA_character_
    a <- as.numeric(tokens); b <- as.numeric(x[[n]])
    add_check(paste0("roundtrip_", table, "_", n), identical(a, b), "exact numeric equality", length(a))
  }
}
warnings_seen <- character()
tryCatch(withCallingHandlers({
  add_check("root", identical(project_start, normalizePath(here::here(), winslash = "/")))
  add_check("eight_ignored_destinations", length(paths) == 8L && all(vapply(paths, is_ignored, logical(1))))
  # Check required reviewed artifacts before evaluating scores.
  required <- c("Data/processed/verified_child_wide.rds", "Data/processed/structural_child_wave_panel.rds",
    "output/tables/source_object_inventory.csv", "output/tables/source_variable_inventory.csv",
    "output/tables/verified_wide_provenance.csv", "output/tables/structural_panel_provenance.csv",
    "docs/stage1_variable_crosswalk.csv", "docs/stage1_unresolved_issues.md")
  stage05_paths <- c(paste0("output/tables/descriptive_", c("field_support", "numeric_summary", "category_frequencies",
    "assessment_patterns", "assessment_pair_support", "belief_outcome_support", "context_crosstabs",
    "identifier_support", "assessment_status_score_availability"), ".csv"),
    "output/verification/descriptive_checks.csv", "output/verification/descriptive_review.md")
  add_check("required_inputs", all(file.exists(here::here(c(required, stage05_paths)))))
  add_check("all_eleven_stage05_protected", all(stage05_paths %in% protected))
  gate()
  # The reviewed ledgers are checksum evidence; upstream construction is never rerun.
  for (report in c("verified_wide", "structural_panel", "descriptive")) {
    up <- read_csv(paste0("output/verification/", report, "_checks.csv"))
    nh <- c(verified_wide = 35L, structural_panel = 485L, descriptive = 886L)[[report]]
    add_check(paste0("historical_", report), !anyDuplicated(up$check_id) &&
      sum(up$severity == "hard") == nh && all(up$status[up$severity == "hard"] == "pass"),
      paste(nh, "historical hard/pass records"), sum(up$severity == "hard"))
  }
  # Verify Stage 05 table hashes and script hash recorded in its review.
  old_review <- readLines(here::here("output/verification/descriptive_review.md"), warn = FALSE)
  for (line in old_review) {
    if (grepl("^\\| `[^`]+` \\| `[0-9a-f]{32}` \\| `[0-9a-f]{32}` \\|$", line)) {
      tokens <- strsplit(line, "`", fixed = TRUE)[[1]]; p <- tokens[2]
      add_check(paste0("reviewed_hash_", p), file.exists(p) &&
        identical(unname(tools::md5sum(here::here(p))), tokens[4]) && tokens[4] == tokens[6],
        tokens[4], unname(tools::md5sum(here::here(p))))
    }
  }
  for (p in c(stage05_paths[1:9], "code/revision/05_describe_released_panel.R")) {
    hash <- unname(tools::md5sum(here::here(p)))
    add_check(paste0("stage05_review_hash_", basename(p)), any(grepl(hash, old_review, fixed = TRUE)), hash, hash)
  }
  file_checks <- read_csv("output/verification/source_file_checks.csv")
  present <- file_checks$exists == "TRUE" & grepl("^[0-9a-f]{32}$", file_checks$expected_md5)
  for (i in which(present)) add_check(paste0("release_hash_", i),
    identical(unname(tools::md5sum(here::here(file_checks$resolved_path[i]))), file_checks$expected_md5[i]),
    file_checks$expected_md5[i], unname(tools::md5sum(here::here(file_checks$resolved_path[i]))))
  objects <- read_csv("output/tables/source_object_inventory.csv")
  inventory <- read_csv("output/tables/source_variable_inventory.csv")
  cw <- read_csv("docs/stage1_variable_crosswalk.csv")
  wp <- read_csv("output/tables/verified_wide_provenance.csv")
  pp <- read_csv("output/tables/structural_panel_provenance.csv")
  issue_text <- readLines(here::here("docs/stage1_unresolved_issues.md"), warn = FALSE)
  add_check("crosswalk_and_issues", nrow(cw) == 66L && nrow(wp) == 66L && nrow(pp) == 148L &&
    all(paste0("Q0", 1:9) %in% regmatches(paste(issue_text, collapse = " "),
      gregexpr("Q0[1-9]", paste(issue_text, collapse = " ")))[[1]]))
  sources <- list(); item_candidates <- list()
  for (i in 1:3) {
    ds <- sprintf("DS%04d", i); r <- objects[objects$dataset_id == ds, ]
    add_check(paste0(ds, "_inventory_row"), nrow(r) == 1L); gate()
    p <- r$source_file; env <- new.env(parent = emptyenv()); loaded <- load(here::here(p), envir = env)
    add_check(paste0(ds, "_object_name_hash"), identical(loaded, r$expected_object) &&
      identical(unname(tools::md5sum(here::here(p))), r$hash_before))
    x <- env[[r$expected_object]]; sources[[ds]] <- x
    add_check(paste0(ds, "_dimensions"), is.data.frame(x) &&
      identical(dim(x), c(as.integer(r$expected_rows), as.integer(r$expected_columns))),
      c(r$expected_rows, r$expected_columns), dim(x))
    labels <- attr(x, "variable.labels")
    iv <- inventory[inventory$dataset_id == ds, ]
    add_check(paste0(ds, "_metadata"), is.character(labels) && identical(names(labels), names(x)) &&
      identical(iv$raw_variable, names(x)) && all(iv$raw_file_md5 == r$hash_before) &&
      identical(iv$observed_storage_mode, vapply(x, typeof, character(1), USE.NAMES = FALSE)))
    # Bounded inventory: all names/labels plus only the identified instrument terms.
    terms <- grepl("IDEA|MODERN|SCHAEFER|CHILD.REARING|Since parents|absolute obedience|Children learn best",
                   paste(names(x), labels), ignore.case = TRUE)
    item_candidates[[ds]] <- setdiff(names(x)[terms], c("T_IDEAP", "T_IDEAK"))
    add_check(paste0(ds, "_modernity_inventory"), TRUE, "record only", names(x)[terms],
              "Names and named data-frame variable.labels inspected; no inference of item identity from numerical patterns.", "info")
  }
  wide <- readRDS(here::here(required[1])); panel <- readRDS(here::here(required[2]))
  add_check("wide_panel_dimensions", identical(dim(wide), c(1015L, 62L)) && identical(dim(panel), c(4060L, 37L)))
  add_check("wide_source_all_columns", identical(names(wide), cw$raw_variable[cw$dataset_id == "DS0001"]) &&
    all(vapply(names(wide), function(v) identical(wide[[v]], sources$DS0001[[v]]), logical(1))))
  add_check("child_correspondence", !anyNA(wide$STUDY_ID) && !anyDuplicated(wide$STUDY_ID) &&
    identical(panel$STUDY_ID, rep(wide$STUDY_ID, each = 4)) &&
    identical(as.character(panel$wave), rep(c("PF", "PS", "KF", "KS"), nrow(wide))) &&
    !anyDuplicated(panel[c("STUDY_ID", "wave")]))
  fields <- c(T_IDEAP = "teacher_modernity_pre_k_fall_released", T_IDEAK = "teacher_modernity_kindergarten_fall_released")
  for (v in names(fields)) {
    w <- if (v == "T_IDEAP") "PF" else "KF"; f <- fields[[v]]
    # Stage 04 deliberately stores panel numeric values without source attributes.
    # Full wide/source metadata identity is checked above; panel values stay exact.
    add_check(paste0("native_fall_", v), identical(as.numeric(panel[[f]][panel$wave == w]), as.numeric(wide[[v]])) &&
      all(is.na(panel[[f]][panel$wave != w])))
    r <- pp[pp$output_variable == f & pp$wave == w, ]
    add_check(paste0("native_provenance_", v), nrow(r) == 1L && r$source_variable == v &&
      cw$wave[cw$dataset_id == "DS0001" & cw$raw_variable == v] == w)
  }
  gate()
  # Focused helper tests exercise actual functions used for research outputs.
  cases <- list(list(1.234, 1.230, "incompatible", "incompatible"),
    list(1.23, 1.234, "rounding_only", "rounding_only"), list(1.23, 1.235, "boundary", "boundary"),
    list(1.23, 1.225, "boundary", "boundary"), list(1.234, 1.234, "arithmetic", "arithmetic"),
    list(1.23 + 1e-8, 1.234, "incompatible", "rounding_only"),
    list(1.25 + 1e-8, 1.25, "incompatible", "arithmetic"))
  for (i in seq_along(cases)) for (j in seq_along(precisions)) {
    z <- cases[[i]]; actual <- classify(z[[1]], z[[2]], precisions[j])
    add_check(paste0("singleton_grid_and_reconstruction_", i, "_", j), identical(actual, z[[j + 2]]), z[[j + 2]], actual)
  }
  for (q in precisions) {
    add_check(paste0("grid_precedence_", q), classify(1.23, c(1.225, 1.234), q) == "rounding_only" &&
      classify(1.23, c(1.225, 1.234, 1.23), q) == "arithmetic")
    z <- analyze_values(c(1.13, 1.25), "K_AVAILABLE", q)
    add_check(paste0("denominator_precedence_", q), z$category[1, 16] == "boundary" &&
      z$category[1, 15] == "rounding_only" && z$category[1, 17] == "rounding_only" &&
      identical(which(z$category[2, 1:16] == "arithmetic"), c(4L, 8L, 12L, 16L)) && z$category[2, 17] == "arithmetic")
    for (side in c(-1, 1)) {
      endpoint <- 1.23 + side * .005; e <- eps(endpoint, 1.23, q)
      got <- vapply(endpoint + side * c(-4, -.5, .5, 4) * e,
                    function(g) classify(1.23, g, q), character(1))
      add_check(paste0("endpoint_band_", q, "_", side),
        identical(got, c("rounding_only", "boundary", "boundary", "incompatible")))
    }
  }
  add_check("nearest_tie", nearest(1.5, c(2, 1, 1), c(1, 3, 2))$value == 1 &&
    nearest(1.5, c(2, 1, 1), c(1, 3, 2))$m == 2L && cent(1.125) == 1.12)
  add_check("empty_nonfinite_zero", summarize(numeric())$summary_status == "empty" &&
    summarize(c(NA_real_, NaN))$summary_status == "all_source_missing" &&
    summarize(c(1, Inf, -Inf, NA_real_))$summary_status == "nonfinite_present" &&
    all(is.na(summarize(c(1, Inf))[stats_names])) && is.na(summarize(1)$sd) && is.na(pct(0, 0)) &&
    nrow(analyze_values(numeric(), "K_AVAILABLE", "primary")$category) == 0L && id_value(-0) == "0")
  fake <- matrix(c(1, 3, 1, NA, NA, NA, 1, Inf, 1, 9, 1, 3, 1, 3), ncol = 2, byrow = TRUE)
  rx <- c(2, 1, NA, 2, Inf, 2, 2)
  rr <- reconstruction_rows(rx, fake, c("identity", "identity"), 1:5,
    "synthetic", "synthetic", "synthetic", "synthetic")
  add_check("reconstruction_coverage", all(rr$n_records == rr$n_eligible + rr$n_ineligible) &&
    all(rr$n_records == rr$n_released_missing + rr$n_released_nonfinite + rr$n_released_finite) &&
    all(rr$n_eligible == rr$n_eligible_released_missing + rr$n_eligible_released_nonfinite + rr$n_evaluated))
  for (rule in unique(rr$rule_id)) for (st in unique(rr$completion_stratum)) for (q in precisions) {
    z <- rr[rr$rule_id == rule & rr$completion_stratum == st & rr$precision_id == q, ]
    add_check(paste0("reconstruction_partition_", rule, "_", st, "_", q),
      sum(z$n_observations) == z$n_evaluated[1] && sum(z$n_distinct_pairs) == z$n_distinct_evaluated_pairs[1])
  }
  add_check("reconstruction_duplicate_pairs_and_keys", any(rr$n_evaluated > rr$n_distinct_evaluated_pairs) &&
    identical(reconstruct(matrix(c(1, 5), nrow = 1), c("identity", "reverse_1_5"), 1:5, "sum_complete")$value, 2))
  for (rule in c("sum_complete", "mean_complete", "mean_available", "sum_prorated")) {
    r <- reconstruct(fake, rep("identity", 2), 1:5, rule)
    expected <- switch(rule, sum_complete = c(4, NA, NA, NA, NA, 4, 4),
      mean_complete = c(2, NA, NA, NA, NA, 2, 2), mean_available = c(2, 1, NA, NA, NA, 2, 2),
      sum_prorated = c(4, 2, NA, NA, NA, 4, 4))
    add_check(paste0("reconstruction_expected_values_", rule), identical(r$value, expected) &&
      identical(r$bad, c(FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE)))
  }
  gate()
  # Documentary ledger: findings checked against the bounded references at implementation.
  ev <- list()
  evidence <- function(h, ds, v, p, loc, claim, limitation, availability = "present_readable", item_status = "not_established") {
    ev[[length(ev) + 1L]] <<- data.frame(evidence_id = "pending", hypothesis_id = h, dataset_id = ds,
      object_name = if (ds == "not_applicable") "not_applicable" else paste0("da04283.", sub("DS", "", ds)),
      variable = v, grade = if (v == "T_IDEAP") "Pre-K" else if (v == "T_IDEAK") "Kindergarten" else "not_applicable",
      occasion = if (v == "T_IDEAP") "PF" else if (v == "T_IDEAK") "KF" else "not_applicable",
      resource_path = p, locator = loc, availability = availability, item_status = item_status,
      claim = claim, limitation = limitation, issue_id = "Q01")
  }
  for (v in names(fields)) evidence("H01", "DS0001", v, "docs/icpsr/DS0001/04283-0001-Questionnaire.pdf",
    if (v == "T_IDEAP") "PDF p.22; Fall Pre-K Q31 a-p" else "PDF p.33; Fall Kindergarten Q40 a-p",
    "Printed form has 16 matching item statements and 1-5 response anchors.",
    "Printed forms do not establish released item inclusion, response handling or scoring key.")
  evidence("H01", "DS0001", "T_IDEAP", "docs/icpsr/DS0001/04283-0001-Codebook.pdf", "PDF pp.538-540",
    "Released Pre-K composite includes fractional categories; 987 nonmissing child records; displayed mean 38.78.",
    "Only first 50 response categories are printed; sum-like scale does not establish derivation.", item_status = "composite_only")
  evidence("H01", "DS0001", "T_IDEAK", "docs/icpsr/DS0001/04283-0001-Codebook.pdf", "PDF pp.788-790",
    "Released Kindergarten composite has 840 nonmissing child records and displayed mean 2.47.",
    "Distribution does not identify completion counts or official scoring.", item_status = "composite_only")
  evidence("H04", "not_applicable", "not_applicable", "docs/icpsr/04283-User_guide.pdf", "PDF pp.23,26,40",
    "Fall timing and separate Bandura/CCNES instruments identified. Guide describes a mean, reversing non-traditional items, and higher progressive scores.",
    "Direction/reversal language remains ambiguous; older general guidance is not release-specific derivation or a verified scoring key.")
  for (ds in names(sources)) {
    i <- match(ds, names(sources)); base <- sprintf("04283-%04d", i)
    vars <- intersect(names(fields), names(sources[[ds]]))
    for (v in vars) {
      evidence("H03", ds, v, sprintf("Data/raw/icpsr_04283/%s-Data.rda", base),
        "All variable names and named data-frame variable.labels; inventory positions",
        paste0("Inspected ", ncol(sources[[ds]]), " names/labels; Modernity composites identified; no identifiable Modernity response items or completion fields."),
        "Absence in inspected accessible material does not prove absence elsewhere. Bandura and CCNES cannot substitute.", item_status = "composite_only")
      evidence("H04", ds, v, sprintf("docs/icpsr/%s/%s-Setup.dct", ds, base), paste(v, "dictionary declaration"),
        "Float storage declaration with two displayed decimal places.",
        "Declaration does not establish actual storage/export history or mandatory nearest-cent rounding.", item_status = "composite_only")
      evidence("H04", ds, v, sprintf("docs/icpsr/%s/%s-Setup.do", ds, base), paste(v, "label and replacement lines"),
        "Setup replaces -99 with missing for this composite; no derivation of the composite is supplied.",
        "Already released NA reasons are not reconstructed.", item_status = "composite_only")
    }
    for (ext in c("do", "sas")) {
      p <- sprintf("docs/icpsr/%s/%s-Supplemental_syntax.%s", ds, base, ext)
      manifest <- readLines(here::here("docs/icpsr/04283-manifest.txt"), warn = FALSE)
      add_check(paste0("absent_supplement_", ds, "_", ext), !file.exists(here::here(p)) &&
        any(grepl(basename(p), manifest, fixed = TRUE)))
      evidence("H02", ds, "not_applicable", p, paste("Manifest entry", basename(p)),
        "Manifest-listed supplemental derivation syntax is absent locally.",
        "Contents unavailable; no claim about its scoring formula.", "absent_manifest_listed")
    }
  }
  evidence("H05", "DS0002", "T_IDEAK", "docs/icpsr/DS0002/04283-0002-Codebook.pdf", "PDF pp.57-59",
    "Separate classroom file: 720 nonmissing of 794 records; displayed mean 2.49.",
    "Different record population; aggregate resemblance cannot establish linkage, teacher counts or identical processing.", item_status = "composite_only")
  evidence("H05", "not_applicable", "not_applicable", "docs/icpsr/04283-manifest.txt", "Version History; 2009,2013,2017 entries",
    "History records public-use revisions, numeric/missing recodes, and questionnaire text additions to codebooks.",
    "No identified entry resolves the released Modernity scoring formula or proves dataset-specific processing.")
  evidence("H06", "not_applicable", "not_applicable", "docs/stage1_unresolved_issues.md", "Q01",
    "not_run_items_unavailable: no positively identified suitable same-object Modernity items and documentary key.",
    "Q01 preserved; direction, official scoring, reliability and cross-grade equivalence remain unresolved.", "present_readable")
  tables <- list(evidence = bind(ev, "evidence"))
  z <- tables$evidence
  z <- z[order(z$hypothesis_id, z$resource_path, z$locator, z$dataset_id,
    match(z$variable, c(names(fields), "not_applicable"))), ]; rownames(z) <- NULL
  z$evidence_id <- sprintf("E%03d", seq_len(nrow(z))); tables$evidence <- z
  # Availability describes the referenced resource, separately from missing scoring evidence.
  for (i in seq_len(nrow(z))) {
    p <- here::here(z$resource_path[i]); exists <- file.exists(p)
    agrees <- if (z$availability[i] == "present_readable") {
      exists && !dir.exists(p) && file.access(p, mode = 4L) == 0L
    } else !exists
    add_check(paste0("evidence_resource_availability_", z$evidence_id[i]), agrees,
      z$availability[i], if (exists) "local resource present" else "local resource absent",
      z$resource_path[i])
  }
  # No candidate items were identified. Any future positive inventory requires review/key registration.
  add_check("conditional_item_registry", all(lengths(item_candidates) == 0L),
    "no unreviewed candidate items", lengths(item_candidates))
  tables$reconstruction <- empty("reconstruction")
  add_check("reconstruction_status", TRUE, "record only", "not_run_items_unavailable",
    "Header-only reconstruction output; diagnostic helpers were exercised with synthetic inputs only.", "review")
  stage05 <- read_csv("output/tables/descriptive_numeric_summary.csv")
  support_rows <- value_rows <- compatibility_rows <- list(); group_data <- list()
  availability <- ifelse(!is.na(wide$T_IDEAP), ifelse(!is.na(wide$T_IDEAK), "both", "p_only"),
                         ifelse(!is.na(wide$T_IDEAK), "k_only", "neither"))
  add_check("availability_partition", identical(as.integer(table(factor(availability, levels = strata[-1]))), c(821L, 166L, 19L, 9L)),
    c(821, 166, 19, 9), as.integer(table(factor(availability, levels = strata[-1]))))
  for (ds in names(sources)) for (v in intersect(names(fields), names(sources[[ds]]))) {
    x_all <- sources[[ds]][[v]]; grade <- if (v == "T_IDEAP") "Pre-K" else "Kindergarten"
    wave <- if (v == "T_IDEAP") "PF" else "KF"; candidate <- if (v == "T_IDEAP") "P_PRORATED16" else "K_AVAILABLE"
    unit <- if (ds == "DS0001") "child_attached_record" else "classroom_file_record"
    for (st in if (ds == "DS0001") strata else "all") {
      x <- if (st == "all") x_all else x_all[availability == st]; ss <- summarize(x)
      group <- paste(ds, v, st, sep = "_"); group_data[[group]] <- x
      for (scale in if (ds == "DS0001" && v == "T_IDEAP") c("released", "p_div16_diagnostic") else "released") {
        su <- if (scale == "released") ss else summarize(x / 16)
        reused <- ds == "DS0001" && st == "all" && scale == "released"
        if (reused) {
          old <- stage05[stage05$source_variable == v, ]; stopifnot(nrow(old) == 1L)
          add_check(paste0("stage05_summary_", v), old$n_children == su$n_records &&
            old$n_source_missing == su$n_source_missing && old$n_nonfinite == su$n_nonfinite &&
            old$n_nonmissing == su$n_finite + su$n_nonfinite && old$summary_status == su$summary_status &&
            near(as.numeric(old[1, stats_names]), as.numeric(su[1, stats_names])))
          # Reuse the reviewed serialized statistics, with the contract's comparison tolerance.
          for (n in stats_names) su[[n]] <- as.numeric(old[[n]])
        }
        support_rows[[length(support_rows) + 1L]] <- cbind(data.frame(dataset_id = ds, variable = v,
          grade = grade, occasion = wave, unit = unit, stratum = st, scale_id = scale,
          summary_source = if (reused) "stage05_reused" else "calculated"), su)
      }
      vals <- sort(unique(x[is.finite(x)])); freq <- tabulate(match(x[is.finite(x)], vals), nbins = length(vals))
      primary <- analyze_values(vals, candidate, "primary")
      for (q in precisions) {
        a <- if (q == "primary") primary else analyze_values(vals, candidate, q)
        for (j in seq_along(vals)) {
          cc <- a$category[j, 1:16]; sets <- lapply(cats, function(cat) which(cc == cat))
          set_string <- function(ms) if (length(ms)) paste(ms, collapse = "|") else "none"
          nn <- a$nearest[[j]]
          value_rows[[length(value_rows) + 1L]] <- data.frame(dataset_id = ds, variable = v, grade = grade,
            occasion = wave, unit = unit, stratum = st, candidate_id = candidate, precision_id = q,
            value_id = id_value(vals[j]), value = vals[j], frequency = freq[j], n_finite = sum(freq),
            pct_finite = pct(freq[j], sum(freq)), cent_residual = abs(vals[j] - cent(vals[j])),
            gap_previous = if (j == 1L) NA_real_ else vals[j] - vals[j - 1L], numerical_category = a$category[j, 17],
            primary_category = primary$category[j, 17], changed_from_primary = a$category[j, 17] != primary$category[j, 17],
            arithmetic_m_set = set_string(sets[[1]]), rounding_m_set = set_string(sets[[2]]),
            boundary_m_set = set_string(sets[[3]]), incompatible_m_set = set_string(sets[[4]]),
            n_compatible_m = length(c(sets[[1]], sets[[2]])), n_boundary_m = length(sets[[3]]),
            nearest_grid_value = nn$value, nearest_m = nn$m, signed_residual = nn$signed, min_abs_residual = nn$residual)
          add_check(paste0("denominator_sets_", group, "_", q, "_", j),
            identical(sort(unlist(sets, use.names = FALSE)), 1:16) && !anyDuplicated(unlist(sets)) &&
            a$category[j, 17] == classify(vals[j], unlist(a$grids), q) &&
            (a$category[j, 17] == "arithmetic") == (length(sets[[1]]) > 0L) &&
            (a$category[j, 17] %in% cats[1:2]) == (length(c(sets[[1]], sets[[2]])) > 0L))
        }
        for (d in 1:17) {
          counts <- distinct_counts <- integer(4)
          for (k in seq_along(cats)) {
            hit <- a$category[, d] == cats[k]; changed <- hit & a$category[, d] != primary$category[, d]
            counts[k] <- sum(freq[hit]); distinct_counts[k] <- sum(hit)
            compatibility_rows[[length(compatibility_rows) + 1L]] <- data.frame(dataset_id = ds, variable = v,
              stratum = st, candidate_id = candidate, precision_id = q, denominator_id = den_ids[d],
              m = if (d == 17L) NA_integer_ else as.integer(d), numerical_category = cats[k],
              n_records = ss$n_records, n_source_missing = ss$n_source_missing, n_nonfinite = ss$n_nonfinite,
              n_finite = ss$n_finite, n_distinct_finite = length(vals), n_observations = counts[k],
              pct_observations = pct(counts[k], sum(freq)), n_distinct_values = distinct_counts[k],
              pct_distinct_values = pct(distinct_counts[k], length(vals)), n_changed_observations = sum(freq[changed]),
              n_changed_distinct_values = sum(changed),
              max_min_abs_residual = if (any(hit)) max(a$residual[hit, d]) else NA_real_)
          }
          # Independent record-level evaluations reconcile exact-value frequencies.
          obs <- x[is.finite(x)]; gg <- if (d == 17L) unlist(a$grids) else a$grids[[d]]
          direct <- vapply(obs, classify, character(1), grid = gg, q = q)
          add_check(paste0("category_partition_", group, "_", q, "_", den_ids[d]),
            sum(counts) == ss$n_finite && sum(distinct_counts) == length(vals) &&
            identical(counts, as.integer(table(factor(direct, levels = cats)))) &&
            ss$n_records == ss$n_source_missing + ss$n_nonfinite + ss$n_finite)
          # Compare independent record transitions with exact-value frequency weights.
          direct_primary <- if (q == "primary") direct else vapply(obs, classify, character(1), grid = gg, q = "primary")
          add_check(paste0("precision_transitions_", group, "_", q, "_", den_ids[d]),
            sum(direct != direct_primary) == sum(freq[a$category[, d] != primary$category[, d]]) &&
            sum(direct != direct_primary) == sum(vapply(cats, function(cat)
              sum(freq[a$category[, d] == cat & a$category[, d] != primary$category[, d]]), integer(1))))
        }
      }
    }
  }
  tables$support <- bind(support_rows, "support"); tables$values <- bind(value_rows, "values")
  tables$compatibility <- bind(compatibility_rows, "compatibility")
  # Shared contract ordering, followed by ascending scale identifier for support.
  support_order <- function(z) order(z$dataset_id, match(z$variable, names(fields)), match(z$stratum, strata), z$scale_id)
  value_order <- function(z) order(z$dataset_id, match(z$variable, names(fields)), match(z$stratum, strata),
    z$candidate_id, match(z$precision_id, precisions), z$value)
  compatibility_order <- function(z) order(z$dataset_id, match(z$variable, names(fields)), match(z$stratum, strata),
    z$candidate_id, match(z$precision_id, precisions), match(z$denominator_id, den_ids), match(z$numerical_category, cats))
  tables$support <- tables$support[support_order(tables$support), ]; rownames(tables$support) <- NULL
  add_check("support_order", identical(support_order(tables$support), seq_len(nrow(tables$support))))
  add_check("values_order", identical(value_order(tables$values), seq_len(nrow(tables$values))))
  add_check("compatibility_order", identical(compatibility_order(tables$compatibility), seq_len(nrow(tables$compatibility))))
  for (v in names(fields)) {
    gs <- group_data[paste("DS0001", v, strata, sep = "_")]
    all_vals <- sort(unique(gs[[1]][is.finite(gs[[1]])])); disjoint <- unlist(gs[-1], use.names = FALSE)
    add_check(paste0("stratum_reconciliation_", v), length(gs[[1]]) == length(disjoint) &&
      sum(is.na(gs[[1]])) == sum(is.na(disjoint)) &&
      identical(all_vals, sort(unique(disjoint[is.finite(disjoint)]))))
  }
  # Conclusions reuse M16 and FAMILY counts; rejection is a finding, never a failed check.
  con <- list()
  for (h in c("H01", "H02")) for (ds in names(sources)) for (v in intersect(names(fields), names(sources[[ds]]))) {
    den <- if (h == "H01") "M16" else "FAMILY"
    for (q in precisions) for (scenario in c("arithmetic_only", "unrounded_or_nearest_cent")) {
      z <- tables$compatibility
      z <- z[z$dataset_id == ds & z$variable == v & z$stratum == "all" & z$precision_id == q & z$denominator_id == den, ]
      pass_k <- if (scenario == "arithmetic_only") 1L else 1:2
      boundary_k <- if (scenario == "arithmetic_only") integer() else 3L
      fail_k <- if (scenario == "arithmetic_only") 2:4 else 4L
      counts <- function(column) c(sum(z[[column]][pass_k]), sum(z[[column]][boundary_k]), sum(z[[column]][fail_k]))
      n <- counts("n_observations"); nv <- counts("n_distinct_values")
      code <- if (!z$n_finite[1]) "not_testable" else if (n[3] > 0L) "rejected_under_assumptions" else
        if (n[2] > 0L) "boundary_unresolved" else "survives_necessary_checks"
      category <- if (code == "rejected_under_assumptions") "contradiction_under_assumptions" else
        if (code == "survives_necessary_checks") "compatibility_only" else "unresolved"
      con[[length(con) + 1L]] <- data.frame(conclusion_id = "pending", hypothesis_id = h,
        claim_id = if (h == "H01") "complete16_grid" else "available1to16_family", dataset_id = ds, variable = v,
        stratum = "all", candidate_id = z$candidate_id[1], denominator_id = den, precision_id = q,
        rounding_scenario = scenario,
        assumptions = paste("Integer scored 1-5 items;", if (h == "H01") "all 16 complete;" else "1-16 observed items;",
          if (v == "T_IDEAP") "16 times item mean in released units;" else "item mean in released units;",
          if (scenario == "arithmetic_only") "unrounded arithmetic" else "unrounded arithmetic OR hypothetical nearest-cent export; unknown tie rule"),
        diagnostic_ref = paste("belief_score_compatibility", ds, v, "all", z$candidate_id[1], q, den, sep = ":"),
        n_evaluated = z$n_finite[1], n_distinct_evaluated = z$n_distinct_finite[1], n_pass = n[1], n_boundary = n[2],
        n_contradicted = n[3], n_distinct_pass = nv[1], n_distinct_boundary = nv[2], n_distinct_contradicted = nv[3],
        evidence_category = category, conclusion_code = code,
        conclusion = paste(code, ": observations pass/boundary/contradicted =", paste(n, collapse = "/"),
          "; distinct values =", paste(nv, collapse = "/")),
        limitations = "Conditional numerical check only; no inference of official rule, actual completion, direction, validity, reliability, teacher identity or cross-grade equivalence.")
      add_check(paste0("conclusion_partition_", h, "_", ds, "_", v, "_", q, "_", scenario),
        sum(n) == z$n_finite[1] && sum(nv) == z$n_distinct_finite[1])
    }
  }
  for (h in c("H03", "H04", "H05", "H06")) {
    row <- as.list(setNames(rep("not_applicable", length(schemas$conclusions)), schemas$conclusions))
    for (n in schemas$conclusions[vapply(schemas$conclusions, integer_col, logical(1))]) row[[n]] <- NA_integer_
    row$conclusion_id <- "pending"; row$hypothesis_id <- h; row$claim_id <- "bounded_documentary_synthesis"
    row$diagnostic_ref <- paste(tables$evidence$evidence_id[tables$evidence$hypothesis_id %in% c(h, "H02")], collapse = "|")
    row$evidence_category <- "unresolved"; row$conclusion_code <- "unresolved"
    row$assumptions <- "Accessible release-specific evidence only; separate dataset populations; no new linkage"
    row$conclusion <- switch(h, H03 = "Matching printed forms do not establish released item counts, content or keys.",
      H04 = "Rounding/representation routes are conditional diagnostics; official transformations and direction remain unidentified.",
      H05 = "Version history and separate populations do not identify dataset-specific scoring differences.",
      H06 = "Official scoring and cross-grade comparability remain unidentified; preserve separate released fields and Q01.")
    row$limitations <- "Supplemental syntax absent; suitable same-object items and documentary key unidentified; not_run_items_unavailable."
    con[[length(con) + 1L]] <- as.data.frame(row)
  }
  tables$conclusions <- bind(con, "conclusions")
  z <- tables$conclusions
  z <- z[order(z$hypothesis_id, z$claim_id, z$dataset_id, match(z$variable, c(names(fields), "not_applicable")),
    match(z$stratum, c(strata, "not_applicable")), z$candidate_id, match(z$denominator_id, c(den_ids, "not_applicable")),
    match(z$precision_id, c(precisions, "not_applicable")), match(z$rounding_scenario,
      c("arithmetic_only", "unrounded_or_nearest_cent", "not_applicable"))), ]; rownames(z) <- NULL
  z$conclusion_id <- sprintf("C%03d", seq_len(nrow(z))); tables$conclusions <- z
  tables <- tables[table_ids]
  keys <- list(evidence = "evidence_id", support = c("dataset_id", "variable", "stratum", "scale_id"),
    values = c("dataset_id", "variable", "stratum", "candidate_id", "precision_id", "value_id"),
    compatibility = c("dataset_id", "variable", "stratum", "candidate_id", "precision_id", "denominator_id", "numerical_category"),
    reconstruction = c("dataset_id", "variable", "stratum", "rule_id", "item_set_id", "key_id", "completion_stratum", "precision_id", "numerical_category"),
    conclusions = "conclusion_id")
  for (id in names(tables)) {
    z <- tables[[id]]
    add_check(paste0("schema_", id), setequal(names(z), schemas[[id]]) && ncol(z) == length(schemas[[id]]))
    z <- z[schemas[[id]]]
    # Explicit contract types, including typed zero-row reconstruction.
    for (n in names(z)) z[[n]] <- switch(col_type(n, id), character = as.character(z[[n]]),
      integer = as.integer(z[[n]]), double = as.double(z[[n]]), logical = as.logical(z[[n]]))
    add_check(paste0("keys_and_cells_", id), !anyDuplicated(z[keys[[id]]]) &&
      all(vapply(z, function(col) if (is.character(col)) !anyNA(col) && all(nzchar(col)) else TRUE, logical(1))))
    add_check(paste0("aggregate_only_", id), !any(c("STUDY_ID", "CASEID", "LEAD_1", "child_id", "teacher_id", "item_response") %in% names(z)))
    tables[[id]] <- z
  }
  add_check("allowed_enums", all(tables$values$numerical_category %in% cats) &&
    all(tables$compatibility$numerical_category %in% cats) && all(tables$values$precision_id %in% precisions) &&
    all(tables$support$summary_status %in% c("empty", "all_source_missing", "nonfinite_present", "singleton", "ok")) &&
    all(tables$evidence$availability %in% c("present_readable", "absent_manifest_listed", "not_available")) &&
    all(tables$evidence$item_status %in% c("composite_only", "not_modernity", "item_verified", "not_established", "not_applicable")) &&
    all(tables$conclusions$rounding_scenario %in% c("arithmetic_only", "unrounded_or_nearest_cent", "not_applicable")))
  add_check("exact_value_ids", identical(as.numeric(tables$values$value_id), tables$values$value))
  gate()
  for (id in names(tables)) { write_csv(tables[[id]], paths[[id]], id); validate_readback(tables[[id]], paths[[id]], id) }
  after <- tools::md5sum(here::here(protected)); names(after) <- protected
  for (p in protected) add_check(paste0("preserved_", p), identical(before[[p]], after[[p]]), before[[p]], after[[p]])
  add_check("outputs_still_ignored", all(vapply(paths, is_ignored, logical(1))))
  add_check("execution_warnings", TRUE, "record only", if (length(warnings_seen)) warnings_seen else "none", severity = "info")
  add_check("check_ids_unique", !anyDuplicated(c(checks$check_id, "check_ids_unique")))
  gate()
  # Validate check-report serialization without recursively adding self-check records.
  write_csv(checks, paths[["checks"]], "checks")
  stopifnot(identical(read_csv(paths[["checks"]]), serialize(checks, "checks")))
  hashes <- tools::md5sum(here::here(paths[names(paths) != "review"]))
  names(hashes) <- paths[names(paths) != "review"]
  findings <- tables$conclusions[tables$conclusions$rounding_scenario != "not_applicable", ]
  vv <- tables$values; exceptions <- vv[vv$stratum == "all" & vv$precision_id == "primary" &
    vv$numerical_category %in% c("boundary", "incompatible"), ]
  ambiguity <- vv[vv$stratum == "all", ]
  ambiguous_lines <- unlist(lapply(split(ambiguity, paste(ambiguity$dataset_id, ambiguity$variable, ambiguity$precision_id)), function(z) {
    paste0("- ", z$dataset_id[1], " / ", z$variable[1], " / ", z$precision_id[1],
      ": zero/one/multiple compatible denominators, observations = ",
      paste(vapply(list(z$n_compatible_m == 0, z$n_compatible_m == 1, z$n_compatible_m > 1), function(ix) sum(z$frequency[ix]), integer(1)), collapse = "/"),
      "; distinct values = ", paste(c(sum(z$n_compatible_m == 0), sum(z$n_compatible_m == 1), sum(z$n_compatible_m > 1)), collapse = "/"))
  }))
  review <- c("# Stage 06 bounded teacher-belief scoring investigation", "",
    paste0("HEAD: `", system2("git", c("rev-parse", "HEAD"), stdout = TRUE), "`. Script MD5: `",
      unname(tools::md5sum(here::here(script_path))), "`."),
    paste0("R: ", R.version.string, ". Locale: ", Sys.getlocale(), "."),
    "Executed from the verified project root. No upstream construction script was sourced or rerun. Historical check reports were inspected, not re-executed.",
    "Exact execution command (twice in fresh processes for external reproducibility verification):", "```powershell",
    "$env:LC_ALL = 'English_United States.utf8'",
    r"(& 'C:\Program Files\R\R-4.6.1\bin\Rscript.exe' --vanilla code/revision/06_investigate_belief_scores.R)", "```", "",
    "## Scope and inventories", "",
    "DS0001: 1015 x 1210; DS0002: 794 x 169; DS0003: 245 x 261. Source objects loaded separately in isolated environments; names, dimensions, release checksums, inventories, named data-frame labels, wide-source identity and native-Fall panel correspondence checked.",
    "DS0001 availability strata both/p_only/k_only/neither: 821/166/19/9. Strata use source !is.na, with nonfinite values separately counted. DS0002 and DS0003 are separate classroom-file record populations, never linked, pooled or deduplicated by score.",
    "Documentary inspection was limited to the plan's identified scoring pages, forms, dictionary/setup blocks and manifest/history. Evidence rows retain exact locators. The older guide's mean and reversal/direction language conflicts with or fails to explain released scales. Matching forms do not establish released scoring.",
    "not_run_items_unavailable: no positively identified suitable same-object Modernity items, completion fields and documentary key. Manifest-listed supplemental .do/.sas derivation syntax absent for all three datasets. Bandura self-efficacy and CCNES are separate instruments. Reconstruction CSV has its exact header and no data rows.", "",
    "## Numerical contract", "",
    "Only P_PRORATED16 (16*s/m) and K_AVAILABLE (s/m), m=1,...,16, s=m,...,5m, were tested in released units. M16 supplies H01; FAMILY supplies H02. No fitted divisors, offsets, reflections, subsets or keys. Temporary DS0001 T_IDEAP/16 summaries create no exposure or altered source.",
    "Primary tolerance: 1e-10*max(1,abs(a),abs(b)); single_precision: max(1e-10,2^-23)*max(1,abs(a),abs(b)). Both are applied independently; h=0.005.",
    "Arithmetic can match a non-cent observation and takes precedence. Rounding-only and boundary categories require cent alignment. The nearest decimal uses neighboring floor/ceiling cents, smaller cent on a tie. cent_residual diagnoses alignment without altering stored observations.",
    "Interval membership uses candidate-to-cent distance, not observation-to-grid distance: interior < h-epsilon, boundary abs(distance-h)<=epsilon at either endpoint. Nearest-grid residuals alone cannot establish rounding compatibility. Strongest precedence applies across grid points and denominators. Sets partition 1-16; family counts each value once. Nearest residual ties choose smaller grid value, then smaller denominator.",
    "unrounded_or_nearest_cent accepts either an unrounded arithmetic route or a hypothetical nearest-cent route. It does not assert mandatory rounding or identify processing history. Boundaries remain ambiguous under the unknown tie rule. Compatible denominators are possibilities, never inferred completion counts.",
    "Support denominators are finite observations and exact distinct finite values. Missing=NA/NaN; nonmissing Inf/-Inf are separate. Undefined percentages/statistics are NA. Stage 05 all/released statistics are reused and checked at 1e-12 relative tolerance. Doubles and exact IDs serialize with 17 significant digits and pass exact numeric read-back.", "",
    "## Hypothesis results", "",
    "Counts below are pass / boundary / contradicted. Primary and precision sensitivity remain separate. H01 refers to each grade's part of the complete-16 joint explanation; a rejection in either grade rejects that joint explanation under its assumptions.", "",
    "| Hypothesis | Dataset | Variable | Precision | Scenario | Observations | Distinct values | Conclusion |",
    "|---|---|---|---|---|---|---|---|",
    vapply(seq_len(nrow(findings)), function(i) { r <- findings[i, ]; paste0("| ", paste(c(r$hypothesis_id, r$dataset_id,
      r$variable, r$precision_id, r$rounding_scenario, paste(r$n_pass, r$n_boundary, r$n_contradicted, sep = "/"),
      paste(r$n_distinct_pass, r$n_distinct_boundary, r$n_distinct_contradicted, sep = "/"), r$conclusion_code), collapse = " | "), " |") }, character(1)), "",
    "## Denominator ambiguity and exceptions", "", ambiguous_lines, "",
    "All exact values and denominator sets are in belief_score_values.csv; M16 and every denominator's exceptions/boundaries are fully enumerated through their sets. Family primary boundaries/incompatibilities:",
    if (!nrow(exceptions)) "- None." else vapply(seq_len(nrow(exceptions)), function(i) { r <- exceptions[i, ];
      paste0("- ", r$dataset_id, " / ", r$variable, ": ", r$value_id, "; frequency=", r$frequency,
        "; category=", r$numerical_category, "; boundary denominators=", r$boundary_m_set) }, character(1)),
    "Precision transitions are recorded per exact value and per denominator/category (incoming changed counts). Primary changed counts are zero; categories are never combined across precision scenarios.", "",
    "## Remaining conclusions and decisions", "",
    tables$conclusions$conclusion[tables$conclusions$rounding_scenario == "not_applicable"],
    "Compatibility is necessary-check survival, not official derivation or numerical reconstruction. Contradictions apply to stated rules and assumptions, not automatic score invalidity. No conclusion establishes direction, validity, reliability or cross-grade equivalence. Q01 and Q02-Q09 retain their meanings and bytes.",
    "Later choices require separate review: seek release-specific scoring evidence; consider grade-specific analyses with explicit measurement limitations; or omit analyses requiring comparable cross-grade scores. No harmonization, Spring assignment, subtraction, new linkage, sample selection, weighting, outcome-based choice, regression, event study, inference procedure or paper conclusion was implemented.", "",
    "## Verification and outputs", "",
    paste0(sum(checks$severity == "hard"), " hard/pass checks; ", sum(checks$severity == "review"),
      " review records; ", sum(checks$severity == "info"), " information records. Execution warnings: ",
      if (length(warnings_seen)) paste(warnings_seen, collapse = " | ") else "none", "."),
    "Synthetic tests cover singleton arithmetic/alignment/interval/boundary/noise, grid/denominator precedence, both endpoint tolerance bands, nearest ties, empty/nonfinite/zero support, and conditional reconstruction eligibility/completion/pair accounting. Record-level checks independently reconcile exact-value frequencies to classifications; family unions and strata reconcile.",
    "All eight destinations are ignored. CSV schemas, types, keys, enums, serialization and numeric read-back checked. External two-run hashes and git diff --check results are reported with delivery; this script does not claim to execute itself twice.", "",
    "| Output | Rows | Columns | MD5 |", "|---|---:|---:|---|",
    vapply(names(tables), function(id) paste0("| `", paths[[id]], "` | ", nrow(tables[[id]]), " | ",
      ncol(tables[[id]]), " | `", hashes[[paths[[id]]]], "` |"), character(1)),
    paste0("| `", paths[["checks"]], "` | ", nrow(checks), " | 6 | `", hashes[[paths[["checks"]]]], "` |"), "",
    "## Preservation ledger", "", paste(length(protected), "protected pre-existing files; all before/after hashes identical."),
    "| Path | MD5 before | MD5 after |", "|---|---|---|",
    vapply(protected, function(p) paste0("| `", p, "` | `", before[[p]], "` | `", after[[p]], "` |"), character(1)), "",
    "Stop: implementation and verification only. No staging, commit, push, branch change, fetch or PR.")
  writeLines(enc2utf8(review), here::here(paths[["review"]]), useBytes = TRUE)
  stopifnot(identical(before, setNames(tools::md5sum(here::here(protected)), protected)))
  cat("Stage 06 complete:", sum(checks$severity == "hard"), "hard checks passed;", nrow(checks), "check rows;",
      length(protected), "protected files unchanged.\n")
}, warning = function(w) { warnings_seen <<- c(warnings_seen, conditionMessage(w)); invokeRestart("muffleWarning") }),
error = function(e) {
  add_check("execution_error", FALSE, "successful completion", conditionMessage(e))
  write_csv(checks, paths[["checks"]], "checks")
  stop(conditionMessage(e), call. = FALSE)
})
