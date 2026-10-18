# Stage 11: specify Fall associations and assess readiness. No estimation.
# From the project root, in a fresh session:
# $env:LC_ALL = 'English_United States.utf8'
# & 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/11_specify_fall_analysis.R
# Only the five aggregate destinations below are written. No upstream stage is sourced.
project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
git <- function(args) {
  z <- system2("git", c("-c", shQuote(paste0("safe.directory=", project_start)), args), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("git failed: ", paste(args, collapse = " "), "\n", paste(z, collapse = "\n"))
  z
}
root <- normalizePath(git(c("rev-parse", "--show-toplevel"))[1], winslash = "/")
stopifnot(identical(project_start, root), basename(root) == "ICPSR_04283")
head_before <- git(c("rev-parse", "HEAD"))
branch_before <- git(c("branch", "--show-current"))
status_before <- git(c("status", "--short", "--branch"))
index_before <- git(c("ls-files", "--stage"))
stopifnot(head_before == "15ae2ef0d2ffb14f7db34e4e4d19f700edfa38a2",
  branch_before == "codex/restructure-project-layout")
Sys.setenv(RENV_PATHS_ROOT = file.path(root, "renv", "local"),
  RENV_CONFIG_SANDBOX_ENABLED = "FALSE", RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
source(file.path(root, "renv", "activate.R"))
suppressPackageStartupMessages(library(here))
stopifnot(identical(normalizePath(here::here(), winslash = "/"), root))
options(stringsAsFactors = FALSE, OutDec = ".", digits = 17, warn = 2)
script_path <- "code/revision/11_specify_fall_analysis.R"
dest <- c("output/reports/stage11_analysis_specification.md",
  "output/tables/stage11_sample_support.csv", "output/tables/stage11_grouping_assessment.csv",
  "output/verification/stage11_checks.csv", "output/verification/stage11_verification_unresolved.md")
stopifnot(all(dir.exists(here::here(dirname(dest)))))
ignored <- function(p) identical(system2("git", c("-c", shQuote(paste0("safe.directory=", project_start)),
  "check-ignore", "-q", "--", p)), 0L)
stopifnot(all(vapply(dest, ignored, logical(1))))
protected_paths <- function() {
  dirs <- c("Data", "docs", "code", "output")
  extra <- unlist(lapply(dirs, function(d) list.files(d, recursive = TRUE,
    all.files = TRUE, full.names = TRUE)), use.names = FALSE)
  p <- sort(unique(c(git("ls-files"), gsub("\\", "/", extra, fixed = TRUE))))
  setdiff(p[file.exists(p) & !dir.exists(p)], dest)
}
hashes <- function(p) { z <- tools::md5sum(here::here(p)); names(z) <- p; z }
protected <- protected_paths()
before <- hashes(protected)
start_time <- format(Sys.time(), tz = "UTC", usetz = TRUE)
checks <- list(); samples <- list(); grouping <- list(); decisions <- list()
check <- function(id, ok, detail = "", fatal = TRUE, status = NULL) {
  if (is.null(status)) status <- if (isTRUE(ok)) "pass" else "fail"
  checks[[length(checks) + 1L]] <<- data.frame(check_id = id, status = status, detail = detail)
  if (!isTRUE(ok) && fatal) stop(id, ": ", detail)
  invisible(isTRUE(ok))
}
sample_row <- function(cell, section, field, category, n = NA_real_, denominator = NA_real_,
                       value = "", status = "supported", detail = "") {
  samples[[length(samples) + 1L]] <<- data.frame(cell = cell, section = section, field = field,
    category = category, n = as.double(n), denominator = as.double(denominator),
    value = as.character(value), status = status, detail = detail)
}
group_row <- function(cell, section, field, category, n = NA_real_, denominator = NA_real_,
                      value = "", status = "supported", detail = "") {
  grouping[[length(grouping) + 1L]] <<- data.frame(cell = cell, section = section, field = field,
    category = category, n = as.double(n), denominator = as.double(denominator),
    value = as.character(value), status = status, detail = detail)
}
bind <- function(z) { x <- do.call(rbind, z); row.names(x) <- NULL; x }
read_csv <- function(p) read.csv(here::here(p), check.names = FALSE, fileEncoding = "UTF-8")
wide_path <- "Data/processed/verified_child_wide.rds"
panel_path <- "Data/processed/outcome_cleaning_panel.rds"
wide <- readRDS(here::here(wide_path)); panel <- readRDS(here::here(panel_path))
wide_original <- serialize(wide, NULL); panel_original <- serialize(panel, NULL)
prov <- read_csv("output/tables/verified_wide_provenance.csv")
panel_prov <- read_csv("output/tables/structural_panel_provenance.csv")
inventory <- read_csv("output/tables/stage08_characteristic_inventory.csv")
accepted_support <- read_csv("output/tables/stage08_belief_outcome_support.csv")
setup <- readLines(here::here("docs/icpsr/DS0001/04283-0001-Setup.do"), warn = FALSE)
dictionary <- readLines(here::here("docs/icpsr/DS0001/04283-0001-Setup.dct"), warn = FALSE)
manifest <- readLines(here::here("docs/icpsr/04283-manifest.txt"), warn = FALSE)
check("accepted_dimensions", nrow(wide) == 1015L && nrow(panel) == 4060L)

# Label validation uses explicit code/label pairs, never the integer storage of a factor.
covars <- c("CHGENP", "CHRACE_AAP", "CHRACE_ASP", "CHRACE_LTP", "CHRACE_NAP",
  "CHRACE_WHP", "CHMATEDCP", "CHINCOMCP")
expected <- list(CHGENP = c(`1` = "Male", `2` = "Female"))
for (f in covars[2:6]) expected[[f]] <- c(`0` = "No", `1` = "Yes")
expected$CHMATEDCP <- setNames(c("8th Grade or less", "Some high school", "HS diploma or equivalent",
  "Some college", "HS + tech training", "AA, AS, 2yr degree", "Bachelor's", "Master's", "Doctoral", "Other"), 1:10)
expected$CHINCOMCP <- setNames(c("$5,000 or <", "$5,001 - $10,000", "$10,001 - $15,000",
  "$15,001 - $20,000", "$20,001 - $25,000", "$25,001 - $30,000", "$30,001 - $35,000",
  "$35,001 - $40,000", "$40,001 - $45,000", "$45,001 - $50,000", "$50,001 - $55,000",
  "$55,001 - $60,000", "$60,001 - $65,000", "$65,001 - $70,000", "$70,001 - $75,000",
  "$75,001 - $80,000", "$80,001 - $85,000", "$85,001 or >"), 1:18)
mapped_labels <- expected
mapped_labels$CHMATEDCP <- setNames(c(rep("Below HS", 2), "HS", rep("College/technical/associate without BA", 3),
  rep("BA+", 3), "Other"), 1:10)
mapped_labels$CHINCOMCP <- setNames(rep(c("<=20000", "20001-40000", "40001-60000", ">60000"), c(4,4,4,6)), 1:18)
references <- c(CHGENP = "Male", setNames(rep("No", 5), covars[2:6]), CHMATEDCP = "HS", CHINCOMCP = "<=20000")
factor_labels <- function(f) {
  codes <- as.integer(names(expected[[f]]))
  digits <- if (max(codes) >= 10) 2L else 1L
  paste0("(", sprintf(paste0("%0", digits, "d"), codes), ") ", unname(expected[[f]]))
}
validate_factor <- function(x, labels) is.factor(x) && identical(levels(x), labels) &&
  all(is.na(x) | as.character(x) %in% labels)
setup_block <- function(f) {
  first <- grep(paste0("^label define ", f, "[[:space:]]"), setup)
  if (length(first) != 1L) return(list(text = "", lines = "missing/ambiguous"))
  last <- first - 1L + which(grepl(";", setup[first:length(setup)], fixed = TRUE))[1]
  list(text = paste(trimws(setup[first:last]), collapse = " "), lines = paste0(first, "-", last))
}
parse_pairs <- function(text) {
  z <- regmatches(text, gregexpr('-?[0-9]+[[:space:]]+"[^"]*"', text))[[1]]
  codes <- sub('[[:space:]].*', '', z)
  labels <- sub('^-?[0-9]+[[:space:]]+"(.*)"$', '\\1', z)
  setNames(labels, codes)
}
mapped <- list(); mapping_ok <- setNames(rep(FALSE, length(covars)), covars)
for (f in covars) {
  block <- setup_block(f); pairs <- parse_pairs(block$text)
  pairs_expected <- c(`-99` = "System Missing", expected[[f]])
  p <- prov[prov$raw_variable == f, , drop = FALSE]
  inv <- inventory[inventory$characteristic == f, , drop = FALSE]
  d <- grep(paste0("[[:space:]]", f, "[[:space:]]"), dictionary)
  missing_rule <- grep(paste0("^replace ", f, " = \\. if \\(", f, " == -99\\)"), setup)
  ok <- identical(pairs, pairs_expected) && validate_factor(wide[[f]], factor_labels(f)) &&
    validate_factor(panel[[f]], factor_labels(f)) && nrow(p) == 1L &&
    isTRUE(p$included_in_output) && p$transformation_applied == "none" &&
    length(d) == 1L && length(missing_rule) == 1L && nrow(inv) == 1L &&
    identical(inv$released_setup_definition, block$text) && grepl(p$raw_label, dictionary[d], fixed = TRUE)
  mapping_ok[f] <- ok
  check(paste0("mapping_", f), ok, paste0("Setup.do ", block$lines,
    "; codebook/questionnaire locators: ", paste(inv$documentary_locators, collapse = " | ")),
    fatal = FALSE)
  for (j in seq_along(expected[[f]])) {
    sample_row("all", "mapping_validation", f, names(expected[[f]])[j],
      sum(as.character(wide[[f]]) == factor_labels(f)[j], na.rm = TRUE), nrow(wide),
      mapped_labels[[f]][j], if (ok) "supported" else "return_for_review",
      paste0("Released label: ", expected[[f]][j], "; reference: ", references[f],
        "; Setup.do ", block$lines, "; ", paste(inv$documentary_locators, collapse = " | ")))
  }
  # A conflicting field is never recoded. Other independent checks still run.
  if (ok) {
    values <- unname(mapped_labels[[f]][match(as.character(panel[[f]]), factor_labels(f))])
    lev <- unique(unname(mapped_labels[[f]]))
    # Other is a separate term only if observed in the release (accepted design).
    if (f == "CHMATEDCP" && !any(values == "Other", na.rm = TRUE)) lev <- setdiff(lev, "Other")
    mapped[[f]] <- factor(values, levels = c(references[f], setdiff(lev, references[f])))
    check(paste0("missing_preserved_", f), identical(is.na(values), is.na(panel[[f]])))
  }
}

# Linkage validation precedes any grouping attachment. No merge sorting or row multiplication.
key_validation <- function(w, p) {
  if (!all(c("STUDY_ID") %in% names(w)) || !all(c("STUDY_ID", "wave") %in% names(p)))
    return(list(ok = FALSE, reason = "missing key fields", index = NULL))
  if (anyNA(w$STUDY_ID) || anyDuplicated(w$STUDY_ID))
    return(list(ok = FALSE, reason = "wide keys missing or duplicated", index = NULL))
  if (anyNA(p$STUDY_ID) || anyNA(p$wave) || anyDuplicated(p[c("STUDY_ID", "wave")]))
    return(list(ok = FALSE, reason = "panel child-wave keys missing or duplicated", index = NULL))
  m <- match(p$STUDY_ID, w$STUDY_ID)
  if (anyNA(m)) return(list(ok = FALSE, reason = "unmatched panel child keys", index = m))
  list(ok = TRUE, reason = "full panel many-to-one; Fall slices one-to-one; complete key coverage", index = m)
}
link <- key_validation(wide, panel)
check("linkage_keys", link$ok, link$reason, fatal = FALSE)
group_row("all", "linkage", "STUDY_ID", "panel_rows", nrow(panel), nrow(panel),
  link$reason, if (link$ok) "supported" else "unresolved", paste(wide_path, "->", panel_path))
overlap_ok <- link$ok
if (link$ok) {
  # Check every documented mapped field, including grouping aliases, before attachment.
  pp <- panel_prov[panel_prov$source_variable %in% names(wide) &
    panel_prov$output_variable %in% names(panel), , drop = FALSE]
  for (i in seq_len(nrow(pp))) {
    q <- pp[i, ]; rows <- as.character(panel$wave) == q$wave
    a <- panel[[q$output_variable]][rows]; b <- wide[[q$source_variable]][link$index[rows]]
    ok <- identical(is.na(a), is.na(b)) &&
      isTRUE(all.equal(as.vector(a), as.vector(b), check.attributes = FALSE, tolerance = 0))
    check(paste0("overlap_", q$output_variable, "_", q$wave), ok,
      paste0("structural_panel_provenance.csv ", q$decision_id, "; ", q$source_variable), fatal = FALSE)
    overlap_ok <- overlap_ok && ok
  }
  group_row("all", "linkage", "STUDY_ID", "matched_panel_rows", sum(!is.na(link$index)), nrow(panel))
  group_row("all", "linkage", "STUDY_ID", "matched_unique_children", length(unique(panel$STUDY_ID)), nrow(wide))
}
group_fields <- c("SITE_PF", "SITE_TRKF")
group_meanings <- c(SITE_PF = "PRESCHOOL: FALL: SITE ID",
  SITE_TRKF = "K YEAR: FALL: SITE WHERE TEACHER RATED CHILD")
group_docs <- setNames(rep(FALSE, 2), group_fields)
for (f in group_fields) {
  pr <- prov[prov$raw_variable == f, , drop = FALSE]
  d <- grep(paste0("[[:space:]]", f, "[[:space:]]"), dictionary)
  block <- setup_block(f)
  group_docs[f] <- f %in% names(wide) && nrow(pr) == 1L && isTRUE(pr$included_in_output) &&
    pr$transformation_applied == "none" && pr$raw_label == group_meanings[f] && length(d) == 1L &&
    grepl(group_meanings[f], dictionary[d], fixed = TRUE) &&
    identical(parse_pairs(block$text), c(`-99` = "System Missing"))
  group_row("all", "documentation", f, "meaning", value = group_meanings[f],
    status = if (group_docs[f]) "supported_label_only" else "unresolved",
    detail = paste0(wide_path, " field=", f, "; ", paste(pr$source_page_or_section, collapse = " | "),
      "; Setup.dct line ", paste(d, collapse = ","),
      "; Guide physical pp.11-17; manifest 2009-06-08 removal entry. Global scope, teacher containment, stable identities and independent groups remain unresolved."))
}
group_ready <- link$ok && overlap_ok
attached <- list()
if (group_ready) for (f in group_fields) if (f %in% names(wide)) attached[[f]] <- wide[[f]][link$index]
check("attachment_row_preservation", !group_ready || all(lengths(attached) == nrow(panel)),
  "Index attachment only; panel itself remains unchanged")

# Computability examines predictor matrices only. It never uses outcomes as a response.
matrix_audit <- function(belief, x) {
  if (!length(belief) || length(unique(belief)) < 2L)
    return(list(status = "stop_affected_association", rank = NA_integer_, columns = NA_integer_,
      belief_increment = 0L, detail = "Absent usable belief variation"))
  z <- data.frame(B = belief, x, check.names = FALSE)
  result <- tryCatch({
    contrasts_list <- lapply(x, function(a) contrasts(a, contrasts = TRUE))
    full <- model.matrix(~ ., z, contrasts.arg = contrasts_list)
    controls <- full[, colnames(full) != "B", drop = FALSE]
    r <- qr(full)$rank; rc <- qr(controls)$rank
    list(status = if (r < ncol(full)) "return_for_specification_review" else "supported",
      rank = r, columns = ncol(full), belief_increment = r - rc,
      detail = if (r < ncol(full)) "Unidentified specified terms; no term dropped or regrouped" else "Full column rank; belief adds one rank")
  }, error = function(e) list(status = "return_for_specification_review", rank = NA_integer_,
    columns = NA_integer_, belief_increment = NA_integer_, detail = conditionMessage(e)))
  if (!is.na(result$belief_increment) && result$belief_increment == 0L)
    result$status <- "stop_affected_association"
  result
}
group_summary <- function(g, b) {
  valid <- !is.na(g); sizes <- table(g[valid]); values <- split(b[valid], g[valid])
  ub <- vapply(values, function(z) length(unique(z)), integer(1))
  c(n_covered = sum(valid), n_missing = sum(!valid), n_groups = length(sizes),
    n_singleton_groups = sum(sizes == 1), n_children_in_singletons = sum(sizes[sizes == 1]),
    singleton_child_share = if (sum(valid)) sum(sizes[sizes == 1])/sum(valid) else NA_real_,
    largest_group_share = if (sum(valid)) max(sizes)/sum(valid) else NA_real_,
    size_min = if (length(sizes)) min(sizes) else NA_real_,
    size_median = if (length(sizes)) median(as.numeric(sizes)) else NA_real_,
    size_max = if (length(sizes)) max(sizes) else NA_real_,
    groups_with_multiple_belief_values = sum(ub > 1),
    distinct_belief_values_covered = length(unique(b[valid])),
    belief_values_in_multiple_groups = sum(vapply(split(as.character(g[valid]), b[valid]),
      function(z) length(unique(z)) > 1L, logical(1))))
}
cross_codes <- function(origin, current, labels_ok, link_ok) {
  if (!labels_ok || !link_ok) return(list(status = "skipped", reason = "Field meanings or verified linkage unavailable"))
  joint <- !is.na(origin) & !is.na(current)
  if (!any(joint)) return(list(status = "skipped", reason = "No jointly observed code pairs"))
  tab <- as.data.frame(table(origin = as.character(origin[joint]), current = as.character(current[joint])))
  tab <- tab[tab$Freq > 0, , drop = FALSE]
  list(status = "executed_literal_codes_only", tab = tab, joint = sum(joint),
    current_per_origin = table(tab$origin), origin_per_current = table(tab$current))
}
composition <- function(cell, pool, mask, section, b, y, writer = sample_row) {
  for (f in covars) for (level in c(levels(panel[[f]]), "<missing>")) {
    hit <- if (level == "<missing>") is.na(panel[[f]]) else !is.na(panel[[f]]) & as.character(panel[[f]]) == level
    writer(cell, section, f, level, sum(pool & mask & hit), sum(pool & mask),
      detail = "Released categories; denominator includes missing; nonexclusive race indicators separate")
  }
  for (f in c("belief", "eligible_clean_outcome")) {
    v <- if (f == "belief") b else y
    a <- v[pool & mask & is.finite(v)]
    for (stat in c("n_finite", "mean", "min", "max")) {
      val <- if (stat == "n_finite") length(a) else if (!length(a)) NA_real_ else
        switch(stat, mean = mean(a), min = min(a), max = max(a))
      writer(cell, section, f, stat, denominator = sum(pool & mask), value = val,
        detail = "Marginal composition only; no belief-outcome association calculated")
    }
  }
}
outcomes <- c("ppvt_english_standard_score", "applied_problems_english_standard_score")
beliefs <- c(PF = "teacher_modernity_pre_k_fall_released", KF = "teacher_modernity_kindergarten_fall_released")
ceilings <- matrix(c(791,755,776,769), nrow = 2, dimnames = list(c("PF","KF"), outcomes))
for (o in outcomes) for (w in c("PF", "KF")) {
  cell <- paste(w, if (o == outcomes[1]) "PPVT" else "Applied_Problems", sep = "_")
  grade <- if (w == "PF") "Pre-K" else "Kindergarten"
  pool <- as.character(panel$wave) == w
  b <- panel[[beliefs[w]]]; y <- panel[[paste0(o, "_clean")]]
  eligible <- panel[[paste0(o, "_eligible_current_rules")]]
  slice_keys_ok <- !anyNA(panel$STUDY_ID[pool]) && !anyDuplicated(panel$STUDY_ID[pool])
  check(paste0(cell, "_unique_child_keys"), slice_keys_ok, fatal = FALSE)
  group_row(cell, "linkage", "STUDY_ID", "fall_slice", sum(pool), sum(pool),
    value = if (link$ok && slice_keys_ok) "one-to-one; complete child-key coverage" else "unresolved",
    status = if (link$ok && slice_keys_ok) "supported" else "unresolved",
    detail = paste0(panel_path, " wave=", w, " -> ", wide_path,
      "; full-panel cardinality many-to-one; all mapped overlaps checked before attachment"))
  check(paste0(cell, "_outcome_eligibility"), all(!eligible[pool] %in% TRUE | is.finite(y[pool])),
    "Accepted Stage07 eligibility requires finite cleaned score")
  base <- pool & is.finite(b) & eligible %in% TRUE
  accepted <- accepted_support[accepted_support$outcome == o & accepted_support$grade == grade &
    accepted_support$outcome_period == "fall", , drop = FALSE]
  check(paste0(cell, "_accepted_overlap"), nrow(accepted) == 1L && sum(base) == ceilings[w,o] &&
    sum(base) == accepted$n_overlap, paste0("recomputed=", sum(base), "; accepted=", ceilings[w,o]))
  for (item in c("fall_rows", "finite_belief", "eligible_outcome", "belief_outcome_ceiling", "unresolved_eligibility")) {
    n <- switch(item, fall_rows = sum(pool), finite_belief = sum(pool & is.finite(b)),
      eligible_outcome = sum(pool & eligible %in% TRUE), belief_outcome_ceiling = sum(base),
      unresolved_eligibility = sum(pool & is.na(eligible)))
    sample_row(cell, "support", "sample", item, n, sum(pool))
  }
  if (!all(mapping_ok) || !slice_keys_ok) {
    sample_row(cell, "computability", "model", "adjusted", status = "return_for_review",
      detail = "Invalid mapping or child keys; no adjusted candidate mask constructed")
    group_row(cell, "coverage", "grouping", "assessment", status = "skipped", detail = "No validated common sample")
    decisions[[cell]] <- list(n = NA_integer_, ceiling = sum(base), status = "unresolved",
      recommendation = "Return for specification review", grouping = "skipped", rank = NA_integer_, columns = NA_integer_)
    next
  }
  x <- as.data.frame(mapped, check.names = FALSE)
  complete <- complete.cases(x)
  candidate <- base & complete
  current <- base
  for (f in covars) {
    missing <- is.na(x[[f]])
    sample_row(cell, "sequential_loss", f, "newly_excluded", sum(current & missing), sum(current))
    sample_row(cell, "overlapping_loss", f, "missing_in_ceiling", sum(base & missing), sum(base),
      detail = "Overlaps other covariate losses; do not sum marginal counts")
    current <- current & !missing
    sample_row(cell, "sequential_retained", f, "remaining", sum(current), sum(base))
  }
  patterns <- apply(is.na(x[base, , drop = FALSE]), 1, function(z) paste(covars[z], collapse = "+"))
  patterns[patterns == ""] <- "none"
  for (p in unique(patterns)) sample_row(cell, "missingness_partition", "covariates", p,
    sum(patterns == p), sum(base))
  check(paste0(cell, "_sample_partition"), sum(candidate) + sum(base & !complete) == sum(base) &&
    identical(current, candidate) && length(patterns) == sum(base))
  sample_row(cell, "support", "sample", "candidate_common_M0_M1", sum(candidate), sum(base),
    detail = "Outcome-specific audit mask; grouping completeness is not required")
  sample_row(cell, "support", "sample", "excluded_covariates", sum(base & !complete), sum(base))
  # Both proposed models reference exactly this mask; no outcome or grade intersection.
  m0_mask <- candidate; m1_mask <- candidate
  check(paste0(cell, "_common_sample"), identical(m0_mask, m1_mask) &&
    identical(candidate, pool & is.finite(b) & eligible %in% TRUE & complete))
  for (part in c("retained", "excluded_covariates", "excluded_from_release")) {
    mask <- switch(part, retained = candidate, excluded_covariates = base & !complete,
      excluded_from_release = pool & !candidate)
    composition(cell, pool, mask, paste0("composition_", part), b, y)
  }
  audit <- matrix_audit(b[candidate], x[candidate, , drop = FALSE])
  sample_row(cell, "computability", "M0", "rank", value = if (any(candidate))
    qr(cbind(Intercept = 1, B = b[candidate]))$rank else 0,
    status = if (length(unique(b[candidate])) >= 2) "supported" else "stop_affected_association",
    detail = "Predictor matrix only, using the identical M1 mask")
  for (metric in c("rank", "columns", "belief_increment")) sample_row(cell, "computability", "M1",
    metric, value = audit[[metric]], status = audit$status, detail = audit$detail)
  for (metric in c("distinct", "min", "max")) sample_row(cell, "belief_support", beliefs[w], metric,
    value = switch(metric, distinct = length(unique(b[candidate])),
      min = if (any(candidate)) min(b[candidate]) else NA_real_,
      max = if (any(candidate)) max(b[candidate]) else NA_real_))
  primary_group <- if (w == "PF") "SITE_PF" else "SITE_TRKF"
  fields <- if (w == "PF") "SITE_PF" else group_fields
  for (f in fields) {
    group_row(cell, "dependence_documentation", f, "identity_scope_and_teacher_containment",
      status = "unresolved", detail = "Label context supported; global identity scope, teacher containment and independent encompassing groups not established by targeted local sources")
    if (!group_ready || !group_docs[f] || is.null(attached[[f]])) {
      group_row(cell, "coverage", f, "assessment", status = "skipped",
        detail = "Prerequisite grouping field/documentation/linkage unavailable")
      next
    }
    g <- attached[[f]]
    stats <- group_summary(g[candidate], b[candidate])
    for (metric in names(stats)) group_row(cell, "coverage_structure", f, metric,
      value = stats[metric], denominator = sum(candidate), status = "literal_partition_only",
      detail = "Shares use covered children; no teacher identity or independent-site inference")
    sizes <- table(g[candidate & !is.na(g)])
    for (size in sort(unique(as.integer(sizes)))) group_row(cell, "group_size_distribution", f,
      as.character(size), sum(sizes == size), length(sizes), status = "literal_partition_only")
    ub <- vapply(split(b[candidate & !is.na(g)], g[candidate & !is.na(g)]),
      function(z) length(unique(z)), integer(1))
    for (v in sort(unique(ub))) group_row(cell, "group_belief_support_distribution", f,
      as.character(v), sum(ub == v), length(ub), status = "literal_partition_only",
      detail = "Number of distinct native beliefs per recorded code; repeated beliefs do not identify teachers")
    gc <- candidate & !is.na(g)
    group_row(cell, "hypothetical_restriction", f, "retained", sum(gc), sum(candidate))
    group_row(cell, "hypothetical_restriction", f, "lost", sum(candidate & is.na(g)), sum(candidate))
    for (part in c("retained", "lost")) composition(cell, candidate,
      if (part == "retained") gc else candidate & is.na(g), paste0("hypothetical_", f, "_", part), b, y, group_row)
    check(paste0(cell, "_", f, "_coverage_partition"), sum(gc) + sum(candidate & is.na(g)) == sum(candidate))
  }
  if (w == "KF") {
    cross <- cross_codes(if (group_ready) attached$SITE_PF[candidate] else NULL,
      if (group_ready) attached$SITE_TRKF[candidate] else NULL, all(group_docs), group_ready)
    group_row(cell, "conditional_origin_current", "SITE_PF x SITE_TRKF", "status", value = cross$status,
      status = cross$status, detail = if (cross$status == "skipped") cross$reason else
        "Interpretable labels permit code cross-tabulation only; code domains kept distinct; no identity authentication")
    if (cross$status != "skipped") {
      group_row(cell, "conditional_origin_current", "SITE_PF x SITE_TRKF", "joint_coverage", cross$joint, sum(candidate))
      group_row(cell, "conditional_origin_current", "SITE_PF x SITE_TRKF", "joint_missing", sum(candidate) - cross$joint, sum(candidate))
      for (i in seq_len(nrow(cross$tab))) group_row(cell, "origin_current_crosstab", "SITE_PF x SITE_TRKF",
        paste0("origin=", cross$tab$origin[i], ";current=", cross$tab$current[i]), cross$tab$Freq[i], cross$joint,
        status = "literal_partition_only")
      for (direction in c("current_per_origin", "origin_per_current")) {
        counts <- cross[[direction]]
        group_row(cell, "observed_nesting_crossing", direction, "codes_with_multiple_counterparts",
          sum(counts > 1), length(counts), status = "literal_partition_only")
      }
      check(paste0(cell, "_cross_partition"), sum(cross$tab$Freq) == cross$joint)
    }
  }
  coverage <- if (group_ready && group_docs[primary_group] && !is.null(attached[[primary_group]])) {
    if (anyNA(attached[[primary_group]][candidate])) "incomplete; identity scope unresolved" else "complete literal coverage; identity scope unresolved"
  } else "skipped"
  recommendation <- switch(audit$status, supported = "Recommend descriptive fallback",
    return_for_specification_review = "Return for specification review",
    stop_affected_association = "Stop the affected association")
  decisions[[cell]] <- list(n = sum(candidate), ceiling = sum(base), status = audit$status,
    recommendation = recommendation, grouping = coverage, rank = audit$rank, columns = audit$columns,
    primary_group = primary_group,
    covered = if (group_ready && !is.null(attached[[primary_group]])) sum(candidate & !is.na(attached[[primary_group]])) else NA_integer_,
    groups = if (group_ready && !is.null(attached[[primary_group]])) length(unique(attached[[primary_group]][candidate & !is.na(attached[[primary_group]])])) else NA_integer_)
}

# Focused synthetic fixtures exercise the production guards without changing source data.
check("fixture_conflicting_label", !validate_factor(factor("(1) Female", levels = c("(1) Female", "(2) Male")), factor_labels("CHGENP")))
check("fixture_unexpected_code", !validate_factor(factor("(3) Other"), factor_labels("CHGENP")))
check("fixture_conflicting_setup", !identical(parse_pairs('1 "Female" 2 "Male"'), expected$CHGENP))
fixture_w <- data.frame(STUDY_ID = c(1,2)); fixture_p <- data.frame(STUDY_ID = c(1,2), wave = c("PF","PF"))
check("fixture_duplicate_wide", !key_validation(rbind(fixture_w, fixture_w[1, , drop = FALSE]), fixture_p)$ok)
check("fixture_duplicate_panel", !key_validation(fixture_w, rbind(fixture_p, fixture_p[1, , drop = FALSE]))$ok)
unmatched <- fixture_p; unmatched$STUDY_ID[2] <- 3
check("fixture_unmatched", !key_validation(fixture_w, unmatched)$ok)
missing_key <- fixture_w; missing_key$STUDY_ID[1] <- NA
check("fixture_missing_key", !key_validation(missing_key, fixture_p)$ok)
check("fixture_valid_many_to_one", key_validation(fixture_w,
  data.frame(STUDY_ID = c(1,2,1,2), wave = c("PF","PF","KF","KF")))$ok)
gs <- group_summary(c(1,NA,2,2), c(10,11,12,13))
check("fixture_missing_grouping_and_singletons", gs["n_missing"] == 1 && gs["n_singleton_groups"] == 1 &&
  gs["n_children_in_singletons"] == 1 && gs["largest_group_share"] == 2/3)
check("fixture_all_missing_grouping", group_summary(c(NA,NA), c(1,2))["n_covered"] == 0)
fx <- data.frame(C = factor(c("No","Yes","No","Yes"), levels = c("No","Yes")))
check("fixture_absent_belief_variation", matrix_audit(rep(1,4), fx)$status == "stop_affected_association")
check("fixture_unidentified_belief", matrix_audit(c(0,1,0,1), fx)$status == "stop_affected_association")
check("fixture_identifiable_matrix", matrix_audit(c(1,2,4,8), fx)$status == "supported")
check("fixture_conditional_documentation_skip", cross_codes(1:2, 1:2, FALSE, TRUE)$status == "skipped")
check("fixture_conditional_linkage_skip", cross_codes(1:2, 1:2, TRUE, FALSE)$status == "skipped")
check("fixture_conditional_no_pairs_skip", cross_codes(c(NA,NA), 1:2, TRUE, TRUE)$status == "skipped")
check("fixture_conditional_crossing", nrow(cross_codes(c(1,1,2,2), c(3,4,3,4), TRUE, TRUE)$tab) == 4)
check("fixture_mapping_boundaries", identical(unname(mapped_labels$CHMATEDCP),
  c("Below HS","Below HS","HS",rep("College/technical/associate without BA",3),rep("BA+",3),"Other")) &&
  identical(unname(mapped_labels$CHINCOMCP), rep(c("<=20000","20001-40000","40001-60000",">60000"),c(4,4,4,6))))
check("source_values_unchanged", identical(wide_original, serialize(wide, NULL)) &&
  identical(panel_original, serialize(panel, NULL)))
check("protected_hashes", identical(before, hashes(protected)), paste(length(protected), "MD5 hashes unchanged"))
check("protected_inventory", identical(protected, protected_paths()), "Only five declared output paths excluded")
check("head_unchanged", identical(head_before, git(c("rev-parse", "HEAD"))))
check("index_unchanged", identical(index_before, git(c("ls-files", "--stage"))))
check("destinations_ignored", all(vapply(dest, ignored, logical(1))))
check("diff_check", length(git(c("diff", "--check"))) == 0L)

spec <- c("# Stage 11: Fall specification and readiness", "",
  "Controlling specification: accepted revised Stage 11 plan; Stage 10 is context. This stage audits four temporary, outcome-specific common-sample masks and stops before association estimation or final dataset creation.", "",
  "## Frozen descriptive specification", "",
  "Question: Within each grade, how are Fall English assessment scores associated with attached Fall released teacher-belief scores? One observation per child; unweighted child-level linear association, not equal-teacher or causal.", "",
  "M0: Y = alpha + beta B + error. M1: Y = alpha + beta B + X gamma + error. Both use the identical outcome-specific complete-case mask. No other outcome, grade, Spring observation, or no-change report is required. No fixed effects.", "",
  "PPVT-III English standard score is primary; WJ-III English Applied Problems standard score is secondary. Use unchanged Stage07 cleaned scores and eligibility at PF/KF. B is native T_IDEAP at PF or T_IDEAK at KF. A later beta would be standard-score points associated with one unit higher released belief score in that grade. No divide-by-16, psychometric harmonization, directional progressive/traditional claim, language pooling, cross-grade effect comparison, or absolute-growth interpretation.", "",
  "X: released CHGENP (Male reference); five separate nonexclusive race/ethnicity Yes/No terms (No references); education 1-2 Below HS, 3 HS reference, 4-6 College/technical/associate without BA, 7-9 BA+, 10 Other separately if observed; income 1-4 <=20000 reference, 5-8 20001-40000, 9-12 40001-60000, 13-18 >60000. All categorical, no ranks, years, or midpoints. Exact code-label mappings and observed counts are in sample_support section=mapping_validation.", "",
  "Covariates are Pre-K family reports and earlier descriptors for Kindergarten. Questionnaire physical pp.85-86 supports adult caregiver respondent and multiple ethnicity responses. Released coding takes precedence over questionnaire letter order (gender) or the extra no-mother response option absent from released education categories. Missing education does not identify household composition. Exact assessment ordering and income reference year remain unresolved. Age and home language are unadjusted; race is not a language measure.", "",
  "Eligibility: finite grade-native belief, Stage07-eligible outcome, observed validated covariates. No trimming, imputation, missing-category creation, or new assessment-status restriction. Grouping absence never changes this descriptive mask. Included children represent this observed released sample with specified English scores/reports, not a national population or a verified monolingual population.", "",
  "Unweighted observed-sample analysis is proposed. Weighted alternatives require separately verified period-specific child weights, sample applicability, state and design information; no site-weight substitution or transfer of Pre-K weights to Kindergarten. Unweighted does not imply independent children.", "",
  "## Four independent decision records", "",
  "| Cell | Belief/outcome ceiling | Candidate common sample | Computability | Matrix rank/columns | Grouping | Recommendation |",
  "|---|---:|---:|---|---|---|---|")
for (cell in names(decisions)) {
  d <- decisions[[cell]]
  spec <- c(spec, paste0("| ", cell, " | ", d$ceiling, " | ", d$n, " | ", d$status,
    " | ", d$rank, "/", d$columns, " | ", d$grouping, " | ", d$recommendation, " |"))
}
spec <- c(spec, "", "| Cell | Grouping field | Covered / full candidate | Distinct recorded codes |",
  "|---|---|---:|---:|")
for (cell in names(decisions)) {
  d <- decisions[[cell]]
  if (!is.null(d$primary_group)) spec <- c(spec, paste0("| ", cell, " | ", d$primary_group,
    " | ", d$covered, "/", d$n, " | ", d$groups, " |"))
}
spec <- c(spec, "", "Each cell independently requires an authenticated encompassing grouping, teacher containment where relevant, and a credible independent-group assumption before uncertainty review. Literal code coverage/counts above do not satisfy those requirements. Kindergarten origin/current joint coverage and crossing are recorded separately in grouping_assessment.",
  "", "## Evidence classifications, dependence and uncertainty", "",
  "Documented: SITE_PF is the Pre-K Fall site ID; SITE_TRKF is the K Fall site where the teacher rated the child. Local targeted sources: DS0001 codebook physical pp.7-11,21-22,317-319,1118-1119; Setup.do label/missing declarations; Setup.dct field labels; family questionnaire pp.85-86; guide pp.11-17; manifest 2009-06-08 entry; accepted wide/structural provenance and Stage08 inventory. No supplemental acquisition, broad scoring search, Spring-field investigation, prefix decoding, or classroom merge was performed.", "",
  "Guide pp.11-13 documents ZIP PSU/site/classroom/child sampling and one selected Pre-K classroom per participating site; pp.15-17 documents Kindergarten dispersion, maintenance, and weights. This general sampling description does not certify released code scope, same-teacher attachment, global uniqueness, or independence of distinct released codes. The manifest 2009-06-08 entry says SITE and SPSU were dropped from public-use files, STATE was dropped in favor of SPSU, and SITE_PF values were corrected for subjects with no Fall Pre-K data. Retained site labels are not substitute identities or recovered PSUs. Observed site codes are reported strictly as literal partitions, not authenticated site or teacher counts.", "",
  "Empirical: linkage cardinality, match coverage, row preservation, and all overlapping mapped field agreements are audited before grouping attachment. Sample loss/composition and full-rank predictor matrices address computability only. Group-size and belief-support summaries use recorded codes; repeated beliefs do not identify teachers. Kindergarten conditional code cross-tabs use the two documented contexts in distinct domains; observed nesting/crossing authenticates no hierarchy. Missing origin/current codes and any observed crossing limit a current-site-only procedure.", "",
  "Unresolved for each of the four cells: unique site scope and report-to-context correspondence; teacher containment; independent encompassing groups; original ZIP/PSU dependence, state/design information, and effective information/leverage. Even complete literal coverage cannot certify an uncertainty procedure. Missing grouping and hypothetical restriction losses are reported separately from the full descriptive sample.", "",
  "For every computable cell, recommend a separately reviewed descriptive fallback: point summaries only, without standard errors, confidence intervals, p-values, significance claims, or population generalization. No such summaries are estimated in Stage11. Do not default to child clustering, heteroskedasticity-robust errors, random effects, bootstrap, or invented multiway clustering.", "",
  "A later inferential review would need documentary support that one grouping dimension encompasses relevant shared contexts and a credible independent-group assumption. Only then could CR2 with Satterthwaite degrees of freedom and 95% intervals be a conditional candidate, with effective information and leverage reviewed. It is not authorized here and would not recover survey-design inference. No four-cell recommendation grants automatic inferential approval.", "",
  "## Unresolved questions and stopping record", "",
  "U1: exact released belief construction/direction/equivalence remains unresolved; native units and higher released score retained. U2: outcome metric comparability, Spanish gaps and Stage07 measurement warnings persist; no new cleaning. U3: site scope/teacher containment and PSU dependence unresolved after the targeted local sources above; explicit fallback is the accepted stopping endpoint, not an automatic substitute inference procedure. U4: covariate timing, income reference year and missing education disposition unresolved. U5: complete-case and English-score selection change represented composition; audit masks are not final approved estimation samples. All skipped conditional checks, if any, appear explicitly in grouping_assessment; failed mapping/sample checks require review, never automatic recoding.", "",
  "Spring associations remain a later extension requiring same-instrument pairs, selection assessment, Fall-score adjustment and renewed dependence assessment; exposure interpretation additionally needs correspondence and interval evidence. These are not prerequisites for this narrow Fall question.")

# Serialize aggregates with explicit double precision and verify every field after readback.
write_csv <- function(x, p) {
  encode <- function(z) {
    if (is.character(z)) return(ifelse(is.na(z), "NA", paste0('"', gsub('"','""', z, fixed = TRUE), '"')))
    if (is.numeric(z)) return(ifelse(is.na(z), "NA", sprintf("%.17g", z)))
    stop("Unexpected output type")
  }
  cols <- lapply(x, encode)
  lines <- c(paste(encode(names(x)), collapse = ","), vapply(seq_len(nrow(x)), function(i)
    paste(vapply(cols, `[`, character(1), i), collapse = ","), character(1)))
  writeLines(lines, here::here(p), useBytes = TRUE)
  y <- read.csv(here::here(p), colClasses = "character", na.strings = character(), check.names = FALSE)
  stopifnot(identical(names(x), names(y)), nrow(x) == nrow(y))
  for (f in names(x)) if (is.character(x[[f]])) {
    expected_text <- ifelse(is.na(x[[f]]), "NA", x[[f]])
    if (!identical(expected_text, y[[f]])) {
      bad <- which(expected_text != y[[f]])
      stop("CSV character readback failed: ", p, " field=", f, " first row=", bad[1],
        " expected=", expected_text[bad[1]], " actual=", y[[f]][bad[1]])
    }
  } else {
    a <- x[[f]]; b <- suppressWarnings(as.double(y[[f]]))
    stopifnot(identical(is.na(a), is.na(b)), identical(as.double(a[!is.na(a)]), b[!is.na(b)]))
  }
}
write_md <- function(lines, p) {
  writeLines(lines, here::here(p), useBytes = TRUE)
  stopifnot(identical(lines, readLines(here::here(p), warn = FALSE)))
}
sample_output <- bind(samples); grouping_output <- bind(grouping)
check("aggregate_schemas", !any(c("STUDY_ID", "child_id") %in% c(names(sample_output), names(grouping_output))),
  "Only marginal counts, code cross-tabs, and predictor computability summaries are published")
write_md(spec, dest[1]); write_csv(sample_output, dest[2]); write_csv(grouping_output, dest[3])
check("aggregate_readback_spec_sample_grouping", TRUE,
  paste(length(spec), "Markdown lines;", nrow(sample_output), "sample rows;", nrow(grouping_output), "grouping rows; exact field readback"))
check("post_publication_protection", identical(before, hashes(protected)) && identical(protected, protected_paths()))
check("post_publication_git", identical(head_before, git(c("rev-parse", "HEAD"))) &&
  identical(index_before, git(c("ls-files", "--stage"))))
write_csv(bind(checks), dest[4])
r_exe <- normalizePath(file.path(R.home("bin"), "Rscript.exe"), winslash = "/")
note <- c("# Stage 11 verification and unresolved record", "",
  paste0("Execution-start UTC: ", start_time, ". R version: ", R.version.string, "."),
  paste0("Installed executable: `", r_exe, "`."), "",
  "Exact fresh-session PowerShell command:", "```powershell",
  "$env:LC_ALL = 'English_United States.utf8'",
  "& 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/11_specify_fall_analysis.R", "```", "",
  paste0("Execution HEAD: ", head_before, "; branch: ", branch_before, ". Stage11 intentionally leaves changes unstaged and uncommitted."), "",
  paste0("Each script Git invocation uses the process-scoped prefix `git -c safe.directory=", project_start,
    "` (no configuration file is changed). Arguments executed: `rev-parse --show-toplevel`; `rev-parse HEAD`; `branch --show-current`; `status --short --branch`; `ls-files --stage`; `ls-files`; `check-ignore -q -- <each of the five declared destinations>`; `diff --check`. All returned success; diff whitespace output empty. HEAD/index unchanged. Output destinations ignored."), "",
  paste0("Checks ledger: ", length(checks), " records; ", sum(bind(checks)$status == "pass"),
    " pass; ", sum(bind(checks)$status == "fail"), " fail. Readback includes every CSV field at 17-digit numeric precision and exact Markdown lines. The checks ledger itself is read back by the same writer; this note is read back after publication."), "",
  "Focused fixtures: conflicting labels/setup, unexpected code, duplicate wide/panel keys, unmatched/missing keys, valid many-to-one linkage, missing/all-missing grouping, singleton shares, absent belief variation, collinear belief, identifiable matrix, documentation/linkage/no-pair conditional skips, literal crossing, and every education/income mapping boundary. They use the production guards. No outcome regression or inferential statistic is computed.", "",
  "Preservation: source R objects serialize identically before/after audit. Protected files include tracked files and all existing Data/docs/code/output files except exactly the five Stage11 destinations, including this script and every accepted prior-stage output. Before/after MD5 hashes and inventory match. The table below is the execution-start fingerprint manifest; every after hash equals before. No child-level output or final dataset is written; publication paths are fixed to the five listed artifacts.", "",
  "Preparation-only diagnostics: an initial R inspection command ended at `packageVersion(\"digest\")` because digest is not installed; no upstream script ran and no package was installed. The implementation uses base R tools::md5sum. A Python questionnaire extraction initially encountered console cp1252 encoding; rerunning with PYTHONIOENCODING=utf-8 succeeded. A first external hash inventory referenced absent paper/; the corrected inventory uses the four existing directories. Initial script execution and its approved outside-sandbox retry both stopped at Git dubious ownership before reading data. Process-scoped safe.directory on the verified project path resolves that root cause without modifying Git configuration. Two subsequent runs stopped at grouping CSV character readback (generic assertion, then diagnostic row 131 field=value); the root cause was internal NA_character_ versus the serialized NA marker. Normalizing expected missing-text markers fixed readback, after which the full script passed. These probes did not modify project inputs.", "",
  "Substantive unresolved evidence and assumptions are in the specification. No newly discovered conflict was silently recoded. Runtime does not acquire PDFs or rerun their extraction: source-page consultation is the bounded implementation review recorded in the specification, backed by the hashes below and the accepted provenance. The code checks released setup/dictionary/provenance on each execution. Grouping means literal recorded partitions only. No uncertainty method has been justified or selected.", "",
  "## Readiness", "")
for (cell in names(decisions)) {
  d <- decisions[[cell]]
  note <- c(note, paste0("- ", cell, ": ceiling ", d$ceiling, "; candidate ", d$n,
    "; computability ", d$status, "; grouping ", d$grouping, "; ", d$recommendation, "."))
}
note <- c(note, "", "## Conditional skips", "")
skips <- grouping_output[grouping_output$status == "skipped", , drop = FALSE]
note <- c(note, if (!nrow(skips)) "No real-data conditional checks were skipped: both Kindergarten code cross-tabs met label/linkage/joint-coverage prerequisites. The stronger site-identity/dependence claims remain unresolved and were not authenticated. Skip paths were exercised by fixtures." else
  paste(skips$cell, skips$field, skips$detail, sep = ": "), "", "## Git status at publication", "```",
  git(c("status", "--short", "--branch")), "```", "", "## Protected MD5 fingerprints", "",
  "| Relative protected path | Before and after MD5 |", "|---|---|",
  paste0("| ", protected, " | ", unname(before), " |"))
write_md(note, dest[5])
stopifnot(identical(before, hashes(protected)), identical(protected, protected_paths()),
  identical(head_before, git(c("rev-parse", "HEAD"))), identical(index_before, git(c("ls-files", "--stage"))))
cat("Stage11 PASS:", length(checks), "checks;", length(protected), "protected hashes unchanged; five aggregate outputs read back.\n")
for (cell in names(decisions)) cat(cell, "n=", decisions[[cell]]$n, decisions[[cell]]$recommendation, "\n")
