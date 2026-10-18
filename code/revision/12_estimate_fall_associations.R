# Stage 12: frozen, unweighted Fall sample linear associations; point estimates only.
# Fresh PowerShell session from the project root:
# $env:LC_ALL = 'English_United States.utf8'
# & 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/12_estimate_fall_associations.R
# No upstream analysis script is sourced. Only the four declared outputs are written.
project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
git <- function(args) {
  z <- system2("git", c("-c", shQuote(paste0("safe.directory=", project_start)), args),
    stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("git failed: ", paste(args, collapse = " "), "\n", paste(z, collapse = "\n"))
  z
}
root <- normalizePath(git(c("rev-parse", "--show-toplevel"))[1], winslash = "/")
stopifnot(identical(root, project_start), basename(root) == "ICPSR_04283")
head_before <- git(c("rev-parse", "HEAD"))
branch_before <- git(c("branch", "--show-current"))
status_before <- git(c("status", "--short", "--branch"))
index_before <- git(c("ls-files", "--stage"))
stopifnot(head_before == "74a1e17ac7873333a9648f0498739799dc49403d",
  branch_before == "codex/restructure-project-layout", length(git(c("diff", "--cached", "--name-only"))) == 0L)
Sys.setenv(RENV_PATHS_ROOT = file.path(root, "renv", "local"),
  RENV_CONFIG_SANDBOX_ENABLED = "FALSE", RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
source(file.path(root, "renv", "activate.R"))
suppressPackageStartupMessages(library(here))
stopifnot(identical(normalizePath(here::here(), winslash = "/"), root))
options(stringsAsFactors = FALSE, OutDec = ".", digits = 17, warn = 2)
script_path <- "code/revision/12_estimate_fall_associations.R"
dest <- c("output/tables/stage12_fall_belief_coefficients.csv",
  "output/reports/stage12_fall_associations.md", "output/verification/stage12_checks.csv",
  "output/verification/stage12_verification_unresolved.md")
stopifnot(all(dir.exists(here::here(dirname(dest)))))
ignored <- function(p) identical(system2("git", c("-c", shQuote(paste0("safe.directory=", root)),
  "check-ignore", "-q", "--", p)), 0L)
stopifnot(all(vapply(dest, ignored, logical(1))))
# Existing results require explicit removal by the caller, so a failed rerun cannot leave stale results.
stopifnot(!any(file.exists(here::here(dest[1:2]))))
protected_paths <- function() {
  extra <- unlist(lapply(c("Data", "docs", "code", "output"), function(d)
    list.files(here::here(d), recursive = TRUE, all.files = TRUE, full.names = TRUE)), use.names = FALSE)
  extra <- substring(gsub("\\", "/", extra, fixed = TRUE), nchar(root) + 2L)
  p <- sort(unique(c(git("ls-files"), extra)))
  setdiff(p[file.exists(here::here(p)) & !dir.exists(here::here(p))], dest)
}
md5 <- function(p) { z <- tools::md5sum(here::here(p)); names(z) <- p; z }
sha256 <- function(p) {
  z <- system2("certutil", c("-hashfile", shQuote(here::here(p)), "SHA256"), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("SHA-256 failed for ", p)
  h <- gsub(" ", "", trimws(z), fixed = TRUE)
  h <- h[grepl("^[0-9a-fA-F]{64}$", h)]
  stopifnot(length(h) == 1L)
  tolower(h)
}
protected <- protected_paths(); before <- md5(protected)
start_time <- format(Sys.time(), tz = "UTC", usetz = TRUE)
checks <- list(); result_rows <- list(); table_lines <- character(); memo <- character()
qr_tol <- 1e-7; numeric_tol <- 1e-10
check <- function(id, ok, observed = "", expected = "TRUE", tolerance = "", detail = "",
                  cell = "all", model = "", fatal = TRUE) {
  if (id %in% vapply(checks, function(x) x$check_id, character(1))) stop("Duplicate check ID: ", id)
  checks[[length(checks) + 1L]] <<- data.frame(check_id = id, cell = cell, model = model,
    status = if (isTRUE(ok)) "pass" else "fail", observed = as.character(observed),
    expected = as.character(expected), tolerance = as.character(tolerance), detail = detail)
  if (!isTRUE(ok) && fatal) stop(id, ": ", detail)
  invisible(isTRUE(ok))
}
bind <- function(z) { x <- do.call(rbind, z); row.names(x) <- NULL; x }
read_csv <- function(p) read.csv(here::here(p), check.names = FALSE, fileEncoding = "UTF-8")
close_numeric <- function(a, b) all(is.finite(c(a, b))) &&
  all(abs(a - b) <= numeric_tol * pmax(1, abs(a), abs(b)))
write_csv <- function(x, p) {
  # Numeric cells use exactly the requested 17-significant-digit representation.
  text <- x
  for (f in names(text)) if (is.numeric(text[[f]])) text[[f]] <- sprintf("%.17g", text[[f]])
  write.table(text, here::here(p), sep = ",", row.names = FALSE, col.names = TRUE,
    quote = TRUE, qmethod = "double", na = "NA", fileEncoding = "UTF-8", eol = "\n")
  back <- read.csv(here::here(p), colClasses = "character", check.names = FALSE,
    na.strings = NULL, fileEncoding = "UTF-8")
  expected <- text
  expected[] <- lapply(expected, function(a) { a <- as.character(a); a[is.na(a)] <- "NA"; a })
  if (!identical(dim(back), dim(expected))) stop("CSV readback dimensions mismatch: ", p)
  if (!identical(back, expected)) {
    for (f in names(expected)) if (!identical(back[[f]], expected[[f]])) {
      bad <- which(is.na(back[[f]]) != is.na(expected[[f]]) | (!is.na(back[[f]]) & !is.na(expected[[f]]) & back[[f]] != expected[[f]]))
      stop("CSV readback mismatch: ", p, " field=", f, " row=", paste(head(bad, 1), collapse = ","),
        "; observed=", paste(head(back[[f]][bad], 1), collapse = ""),
        "; expected=", paste(head(expected[[f]][bad], 1), collapse = ""))
    }
    stop("CSV readback attributes mismatch: ", p)
  }
}
write_md <- function(x, p) {
  lines <- unname(enc2utf8(x))
  writeLines(lines, here::here(p), useBytes = TRUE)
  stopifnot(identical(readLines(here::here(p), encoding = "UTF-8", warn = FALSE), lines))
}
display <- function(v) {
  s <- sprintf("%.3f", v)
  zero <- s %in% c("-0.000", "0.000")
  s[zero] <- ifelse(v[zero] == 0, "0.000", "0.000 (nonzero; below displayed precision)")
  s
}
# These production guards are also exercised by the synthetic fixtures.
fit_belief <- function(b, y, x = NULL) {
  if (!is.numeric(b) || !is.numeric(y) || !length(b) || length(b) != length(y) ||
      any(!is.finite(c(b, y)))) stop("Nonfinite or invalid response/belief")
  if (length(unique(b)) < 2L) stop("Constant belief")
  if (is.null(x)) x <- matrix(numeric(), nrow = length(b), ncol = 0L)
  if (!is.matrix(x) || nrow(x) != length(b) || any(!is.finite(x))) stop("Invalid descriptors")
  a <- cbind(Intercept = 1, x)
  z <- cbind(Intercept = 1, belief = b, x)
  qa <- qr(a, tol = qr_tol); qz <- qr(z, tol = qr_tol)
  if (qz$rank != ncol(z) || qz$rank - qa$rank != 1L) stop("Rank failure or collinear belief")
  rb <- if (ncol(x)) qr.resid(qa, b) else b - mean(b)
  ry <- if (ncol(x)) qr.resid(qa, y) else y - mean(y)
  denominator <- sum(rb * rb)
  if (!is.finite(denominator) || denominator <= 0) stop("Invalid independent-check denominator")
  beta <- unname(stats::lm.fit(z, y, tol = qr_tol)$coefficients["belief"])
  independent <- sum(rb * ry) / denominator
  if (!close_numeric(beta, independent)) stop("Independent numerical disagreement")
  list(beta = beta, independent = independent, denominator = denominator,
    rank = qz$rank, columns = ncol(z), increment = qz$rank - qa$rank)
}
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
factor_labels <- function(f) {
  codes <- as.integer(names(expected[[f]]))
  paste0("(", sprintf(paste0("%0", if (max(codes) >= 10) 2L else 1L, "d"), codes), ") ", unname(expected[[f]]))
}
decode <- function(v, f) {
  if (!is.factor(v) || !identical(levels(v), factor_labels(f))) stop("Conflicting released labels: ", f)
  z <- match(as.character(v), factor_labels(f))
  if (!identical(is.na(z), is.na(v))) stop("Unexpected category: ", f)
  as.integer(names(expected[[f]]))[z]
}
indicator <- function(v, codes) ifelse(is.na(v), NA_real_, as.numeric(v %in% codes))
descriptors <- function(codes) {
  z <- cbind(F = indicator(codes$CHGENP, 2L))
  for (j in 2:6) z <- cbind(z, indicator(codes[[covars[j]]], 1L))
  colnames(z) <- c("F", "R_AA", "R_AS", "R_LT", "R_NA", "R_WH")
  cbind(z, E_L = indicator(codes$CHMATEDCP, 1:2), E_C = indicator(codes$CHMATEDCP, 4:6),
    E_B = indicator(codes$CHMATEDCP, 7:9), I_2 = indicator(codes$CHINCOMCP, 5:8),
    I_3 = indicator(codes$CHINCOMCP, 9:12), I_4 = indicator(codes$CHINCOMCP, 13:18))
}
common_mask <- function(pool, b, eligible, codes) pool & is.finite(b) & eligible %in% TRUE & complete.cases(codes)
failed <- function(expr) inherits(tryCatch({ force(expr); NULL }, error = function(e) e), "error")
stage11 <- c("code/revision/11_specify_fall_analysis.R", "output/reports/stage11_analysis_specification.md",
  "output/tables/stage11_sample_support.csv", "output/tables/stage11_grouping_assessment.csv",
  "output/verification/stage11_checks.csv", "output/verification/stage11_verification_unresolved.md")
stage11_sha <- c("7fb67caadf0739549027446a9da9be865a4793ecbe96be4941b7c87d75456df6",
  "6e0ea47933952cf4af5d693161f6d368a4f2e3ec97a9a4331b7c5b48d410c43f",
  "cd81d3d113aaefe1de7d0713ce26b1ea5014258f85a50e05b4006bd670172026",
  "6683c72a2f7875f6e68df121eee8373f7ee1db185bb3535f009f0d3f22474c5c",
  "426764307a07669848fe9c0d29996d4d868904a703a7df8ff687201c7d78eb83",
  "8f0c7ecab9e22149debff09f6c8f3e94ada104630ccf5d33181e31dab4754a8a")
required <- c("Data/processed/verified_child_wide.rds", "Data/processed/outcome_cleaning_panel.rds",
  "output/tables/verified_wide_provenance.csv", "output/tables/structural_panel_provenance.csv",
  "output/tables/stage08_characteristic_inventory.csv", "output/tables/stage08_belief_outcome_support.csv",
  "output/tables/outcome_cleaning_rules.csv", "docs/icpsr/DS0001/04283-0001-Setup.do",
  "docs/icpsr/DS0001/04283-0001-Setup.dct")
failure <- tryCatch({
  for (j in seq_along(stage11)) check(paste0("accepted_stage11_sha256_", j),
    identical(sha256(stage11[j]), stage11_sha[j]), observed = sha256(stage11[j]), expected = stage11_sha[j],
    detail = stage11[j])
  historical <- readLines(here::here(stage11[6]), warn = FALSE)
  for (j in seq_along(required)) {
    line <- historical[startsWith(historical, paste0("| ", required[j], " | "))]
    h <- if (length(line) == 1L) trimws(strsplit(line, "|", fixed = TRUE)[[1]][3]) else "absent"
    check(paste0("accepted_input_md5_", j), identical(unname(md5(required[j])), h),
      observed = unname(md5(required[j])), expected = h, detail = required[j])
  }
  old_checks <- read_csv(stage11[5])
  check("inherited_ledger_not_rerun", nrow(old_checks) == 173L && all(old_checks$status == "pass"),
    observed = nrow(old_checks), expected = 173, detail = "Historical evidence inspected only; upstream stages not executed")
  wide <- readRDS(here::here(required[1])); panel <- readRDS(here::here(required[2]))
  wide_original <- serialize(wide, NULL); panel_original <- serialize(panel, NULL)
  prov <- read_csv(required[3]); panel_prov <- read_csv(required[4]); inventory <- read_csv(required[5])
  support08 <- read_csv(required[6]); support11 <- read_csv(stage11[3]); rules <- read_csv(required[7])
  setup <- readLines(here::here(required[8]), warn = FALSE)
  dictionary <- readLines(here::here(required[9]), warn = FALSE)
  check("accepted_dimensions", nrow(wide) == 1015L && nrow(panel) == 4060L)
  check("unique_linkage", !anyNA(wide$STUDY_ID) && !anyDuplicated(wide$STUDY_ID) &&
    !anyNA(panel$STUDY_ID) && !anyNA(panel$wave) && !anyDuplicated(panel[c("STUDY_ID", "wave")]))
  link <- match(panel$STUDY_ID, wide$STUDY_ID)
  check("complete_linkage", !anyNA(link))
  codes <- list()
  for (f in covars) {
    first <- grep(paste0("^label define ", f, "[[:space:]]"), setup)
    check(paste0("setup_block_", f), length(first) == 1L)
    last <- first - 1L + which(grepl(";", setup[first:length(setup)], fixed = TRUE))[1]
    block <- paste(trimws(setup[first:last]), collapse = " ")
    pairs <- regmatches(block, gregexpr('-?[0-9]+[[:space:]]+"[^"]*"', block))[[1]]
    parsed <- setNames(sub('^-?[0-9]+[[:space:]]+"(.*)"$', '\\1', pairs), sub('[[:space:]].*', '', pairs))
    pr <- prov[prov$raw_variable == f, , drop = FALSE]
    inv <- inventory[inventory$characteristic == f, , drop = FALSE]
    d <- grep(paste0("[[:space:]]", f, "[[:space:]]"), dictionary)
    missing_rule <- grep(paste0("^replace ", f, " = \\. if \\(", f, " == -99\\)"), setup)
    check(paste0("mapping_", f), identical(parsed, c(`-99` = "System Missing", expected[[f]])) &&
      nrow(pr) == 1L && isTRUE(pr$included_in_output) && pr$transformation_applied == "none" &&
      nrow(inv) == 1L && identical(inv$released_setup_definition, block) && length(d) == 1L &&
      length(missing_rule) == 1L && grepl(pr$raw_label, dictionary[d], fixed = TRUE), detail = block)
    wc <- decode(wide[[f]], f); pc <- decode(panel[[f]], f)
    check(paste0("source_panel_", f), identical(pc, wc[link]) && identical(is.na(pc), is.na(panel[[f]])))
    codes[[f]] <- pc
  }
  codes <- as.data.frame(codes)
  check("education_other_absent", !any(codes$CHMATEDCP == 10L, na.rm = TRUE))
  x <- descriptors(codes)
  check("descriptor_columns", ncol(x) == 12L, observed = ncol(x), expected = 12)
  check("descriptor_missingness", identical(complete.cases(x), complete.cases(codes)))

  # Focused fixtures: no random seed, external files, or research-data modification.
  fb <- seq_len(40) / 7
  fx <- cbind(a = rep(c(0, 0, 1, 1), 10), b = rep(c(0, 1), 20))
  fy <- 9 + 2.5 * fb - 3 * fx[, 1] + 4 * fx[, 2]
  fa <- fit_belief(fb, fy, fx)
  check("fixture_known_adjusted_slope", close_numeric(fa$beta, 2.5), tolerance = numeric_tol)
  check("fixture_known_unadjusted_slope", close_numeric(fit_belief(fb, 7 - 1.25 * fb)$beta, -1.25), tolerance = numeric_tol)
  check("fixture_nonexclusive", any(rowSums(fx) == 2) && fa$rank == 4L)
  check("fixture_constant_belief_rejected", failed(fit_belief(rep(1, 40), fy, fx)))
  check("fixture_collinear_belief_rejected", failed(fit_belief(fx[, 1], fy, fx)))
  check("fixture_nonfinite_rejected", failed(fit_belief(replace(fb, 2, Inf), fy, fx)))
  check("fixture_missing_descriptor_rejected", failed(fit_belief(fb, fy, replace(fx, 1, NA))))
  fixture_codes <- codes[rep(1, 18), , drop = FALSE]
  fixture_codes[] <- lapply(fixture_codes, function(v) rep(1L, 18))
  fixture_codes$CHMATEDCP <- c(1:9, 1:9); fixture_codes$CHINCOMCP <- 1:18
  dx <- descriptors(fixture_codes)
  check("fixture_education_boundaries", identical(unname(dx[, c("E_L", "E_C", "E_B")]),
    unname(cbind(as.numeric(fixture_codes$CHMATEDCP %in% 1:2),
      as.numeric(fixture_codes$CHMATEDCP %in% 4:6), as.numeric(fixture_codes$CHMATEDCP %in% 7:9)))))
  check("fixture_income_boundaries", identical(unname(dx[, c("I_2", "I_3", "I_4")]),
    unname(cbind(as.numeric(1:18 %in% 5:8), as.numeric(1:18 %in% 9:12), as.numeric(1:18 %in% 13:18)))))
  fixture_codes$CHGENP[2] <- NA_integer_
  check("fixture_missing_covariate_selection", identical(common_mask(rep(TRUE, 18), 1:18,
    rep(TRUE, 18), fixture_codes), seq_len(18) != 2L) && is.na(descriptors(fixture_codes)[2, "F"]))
  check("fixture_conflicting_labels_rejected", failed(decode(factor("unexpected"), "CHGENP")))
  check("fixture_display_precision", identical(display(c(-0, -1e-6, 1e-6, 1.2346)),
    c("0.000", rep("0.000 (nonzero; below displayed precision)", 2), "1.235")))

  cells <- data.frame(cell = c("PF_PPVT", "KF_PPVT", "PF_Applied_Problems", "KF_Applied_Problems"),
    grade = rep(c("Pre-K", "Kindergarten"), 2), wave = rep(c("PF", "KF"), 2),
    outcome = rep(c("ppvt_english_standard_score", "applied_problems_english_standard_score"), each = 2),
    priority = rep(c("primary", "secondary"), each = 2),
    source = c("PPVTEPF", "PPVTEKF", "WJ10_SSEPF", "WJ10_SSEKF"),
    belief_source = rep(c("T_IDEAP", "T_IDEAK"), 2), n = c(730L, 700L, 717L, 713L), ceiling = c(791L, 755L, 776L, 769L))
  # Reconcile all requested aggregate partitions, never child IDs, with Stage 11.
  reconcile <- function(cell, section, field, category, n, denominator) {
    a <- support11[support11$cell == cell & support11$section == section &
      support11$field == field & support11$category == category, , drop = FALSE]
    check(paste(cell, section, field, category, sep = ":"), nrow(a) == 1L &&
      a$n == n && a$denominator == denominator, observed = n,
      expected = if (nrow(a) == 1L) a$n else "missing/duplicate aggregate", cell = cell,
      detail = paste0("Stage11 denominator observed=", denominator,
        "; expected=", paste(a$denominator, collapse = ",")))
  }
  for (j in seq_len(nrow(cells))) tryCatch({
    c <- cells[j, ]; cell <- c$cell; w <- c$wave; o <- c$outcome
    ck <- function(id, ok, ...) check(paste0(cell, "_", id), ok, cell = cell, ...)
    pool <- as.character(panel$wave) == w
    ck("unique_fall_rows", sum(pool) == 1015L && !anyDuplicated(panel$STUDY_ID[pool]))
    belief_field <- if (w == "PF") "teacher_modernity_pre_k_fall_released" else "teacher_modernity_kindergarten_fall_released"
    b <- panel[[belief_field]]; y <- panel[[paste0(o, "_clean")]]
    eligible <- panel[[paste0(o, "_eligible_current_rules")]]
    ck("logical_eligibility", is.logical(eligible))
    ck("eligible_finite", all(!eligible[pool] %in% TRUE | is.finite(y[pool])))
    for (pair in list(c(belief_field, c$belief_source), c(o, c$source))) {
      pp <- panel_prov[panel_prov$output_variable == pair[1] & panel_prov$wave == w, , drop = FALSE]
      ck(paste0("provenance_", pair[2]), nrow(pp) == 1L && pp$source_variable == pair[2] && pp$transformation_applied == "none")
      ck(paste0("source_correspondence_", pair[2]),
        isTRUE(all.equal(as.vector(panel[[pair[1]]][pool]), as.vector(wide[[pair[2]]][link[pool]]),
          check.attributes = FALSE, tolerance = 0)))
    }
    rr <- rules[rules$outcome == o & rules$wave == w, , drop = FALSE]
    ck("stage07_rule_source", nrow(rr) > 0L && all(rr$source_variable == c$source))
    ck("eligible_score_unchanged", identical(as.vector(y[pool & eligible %in% TRUE]),
      as.vector(panel[[o]][pool & eligible %in% TRUE])))
    if (cell == "PF_Applied_Problems") ck("practice_failure_exclusion",
      all(!eligible[pool & !is.na(panel[[o]]) & panel[[o]] == -7] %in% TRUE))
    base <- pool & is.finite(b) & eligible %in% TRUE
    mask <- common_mask(pool, b, eligible, codes)
    accepted <- support08[support08$outcome == o & support08$grade == c$grade & support08$outcome_period == "fall", ]
    ck("stage08_ceiling", nrow(accepted) == 1L && sum(base) == accepted$n_overlap && sum(base) == c$ceiling)
    metrics <- c(fall_rows = sum(pool), finite_belief = sum(pool & is.finite(b)),
      eligible_outcome = sum(pool & eligible %in% TRUE), belief_outcome_ceiling = sum(base),
      unresolved_eligibility = sum(pool & is.na(eligible)))
    for (metric in names(metrics)) reconcile(cell, "support", "sample", metric, metrics[metric], sum(pool))
    reconcile(cell, "support", "sample", "candidate_common_M0_M1", sum(mask), sum(base))
    reconcile(cell, "support", "sample", "excluded_covariates", sum(base & !complete.cases(codes)), sum(base))
    ck("expected_n", sum(mask) == c$n, observed = sum(mask), expected = c$n)
    current <- base
    for (f in covars) {
      missing <- is.na(codes[[f]])
      reconcile(cell, "sequential_loss", f, "newly_excluded", sum(current & missing), sum(current))
      reconcile(cell, "overlapping_loss", f, "missing_in_ceiling", sum(base & missing), sum(base))
      current <- current & !missing
      reconcile(cell, "sequential_retained", f, "remaining", sum(current), sum(base))
    }
    ck("partition_complete", identical(current, mask))
    patterns <- apply(is.na(codes[base, , drop = FALSE]), 1, function(z) paste(covars[z], collapse = "+"))
    patterns[patterns == ""] <- "none"
    old_patterns <- support11$category[support11$cell == cell & support11$section == "missingness_partition"]
    ck("partition_categories", setequal(unique(patterns), old_patterns))
    for (p in unique(patterns)) reconcile(cell, "missingness_partition", "covariates", p, sum(patterns == p), sum(base))
    for (f in covars) for (level in c(levels(panel[[f]]), "<missing>")) {
      hit <- if (level == "<missing>") is.na(panel[[f]]) else !is.na(panel[[f]]) & as.character(panel[[f]]) == level
      reconcile(cell, "composition_retained", f, level, sum(mask & hit), sum(mask))
    }
    rows <- which(mask); rows <- rows[order(panel$STUDY_ID[rows])]
    # Independently reconstruct M1 indices and compare the exact ordered IDs in memory.
    m1_rows <- which(pool & is.finite(b) & eligible %in% TRUE & complete.cases(x))
    m1_rows <- m1_rows[order(panel$STUDY_ID[m1_rows])]
    ids0 <- panel$STUDY_ID[rows]; ids1 <- panel$STUDY_ID[m1_rows]
    ck("identical_model_ids", identical(ids0, ids1) && !anyDuplicated(ids0))
    for (model in c("M0", "M1")) {
      fitted <- fit_belief(b[rows], y[rows], if (model == "M1") x[m1_rows, , drop = FALSE] else NULL)
      columns <- if (model == "M0") 2L else 14L
      ck(paste0(model, "_rank"), fitted$rank == columns && fitted$columns == columns,
        observed = fitted$rank, expected = columns, tolerance = qr_tol, model = model)
      ck(paste0(model, "_belief_increment"), fitted$increment == 1L, observed = fitted$increment, expected = 1, model = model)
      ck(paste0(model, "_positive_denominator"), is.finite(fitted$denominator) && fitted$denominator > 0,
        observed = fitted$denominator, expected = "finite > 0", model = model)
      ck(paste0(model, "_independent_coefficient"), close_numeric(fitted$beta, fitted$independent),
        observed = sprintf("%.17g", fitted$beta), expected = sprintf("%.17g", fitted$independent),
        tolerance = numeric_tol, model = model,
        detail = if (model == "M0") "Centered cross-product / centered belief sum of squares" else "QR FWL residual cross-product / residual belief sum of squares")
      result_rows[[length(result_rows) + 1L]] <- data.frame(cell = cell, grade = c$grade, wave = w,
        outcome = o, outcome_priority = c$priority, outcome_source = c$source, belief_source = c$belief_source,
        model = model, term = "belief", estimate = fitted$beta, n = length(ids0), rank = fitted$rank,
        n_columns = fitted$columns, sample_rule_id = "stage12_fall_native_stage07_complete8_v1",
        adjustment_id = if (model == "M0") "intercept_native_belief" else "stage11_explicit_12_descriptors_v1",
        weighting = "unweighted_child_level", coefficient_unit = paste0("outcome standard-score points per one-unit higher released ", c$belief_source, " score"))
    }
  }, error = function(e) check(paste0(cells$cell[j], "_cell_failure"), FALSE,
    detail = conditionMessage(e), cell = cells$cell[j], fatal = FALSE))
  check("all_cells_pass", !any(vapply(checks, function(a) a$status == "fail", logical(1))))
  results <- bind(result_rows)
  schema <- c("cell", "grade", "wave", "outcome", "outcome_priority", "outcome_source", "belief_source",
    "model", "term", "estimate", "n", "rank", "n_columns", "sample_rule_id", "adjustment_id", "weighting", "coefficient_unit")
  check("result_schema_and_keys", identical(names(results), schema) && nrow(results) == 8L &&
    !anyDuplicated(results[c("cell", "model")]) && all(is.finite(results$estimate)) &&
    identical(results$model, rep(c("M0", "M1"), 4)))
  make_table <- function(r) {
    c("| Outcome | Grade | N | M0 belief coefficient | M1 belief coefficient |",
      "|---|---|---:|---:|---:|", vapply(seq_len(nrow(cells)), function(j) {
        a <- r[r$cell == cells$cell[j], ]
        paste0("| ", if (cells$priority[j] == "primary") "PPVT (primary)" else "Applied Problems (secondary)",
          " | ", cells$grade[j], " | ", a$n[1], " | ", display(a$estimate[a$model == "M0"]),
          " | ", display(a$estimate[a$model == "M1"]), " |")
      }, character(1)))
  }
  table_lines <- make_table(results)
  interpretation <- vapply(seq_len(nrow(cells)), function(j) {
    a <- results[results$cell == cells$cell[j], ]
    direction <- ifelse(a$estimate > 0, "positive", ifelse(a$estimate < 0, "negative", "zero"))
    paste0(cells$grade[j], " ", if (cells$priority[j] == "primary") "PPVT" else "Applied Problems",
      ": the unadjusted coefficient is ", direction[1], " (", display(a$estimate[1]),
      "); the coefficient after adjustment is ", direction[2], " (", display(a$estimate[2]),
      ") standard-score points per one-unit higher released belief score.")
  }, character(1))
  memo <- c("# Stage 12: descriptive Fall belief-assessment associations", "",
    "Unweighted child-level point estimates in four separate grade-outcome samples. PPVT-III English receptive-vocabulary standard scores are primary; English WJ-III Applied Problems standard scores are secondary.", "",
    table_lines, "", "Coefficients display three decimal places; nonzero values rounding to zero are labeled below displayed precision. Machine-readable estimates retain 17 significant digits.", "",
    "## Models, indicators and units", "",
    "Let i index children; g in {P,K} index Pre-K and Kindergarten; o in {V,A} index PPVT and Applied Problems; and m in {0,1} index models. Each (g,o,m) is fitted separately.", "",
    "$$", "M0:\\quad Y_{igo}=\\alpha^{(0)}_{go}+\\beta^{(0)}_{go}B_{ig}+u^{(0)}_{igo}.", "$$", "",
    "$$", "M1:\\quad Y_{igo}=\\alpha^{(1)}_{go}+\\beta^{(1)}_{go}B_{ig}+\\mathbf X_i'\\boldsymbol\\gamma_{go}+u^{(1)}_{igo}.", "$$", "",
    "$$", "\\begin{aligned}",
    "Y_{igo}={}&\\alpha^{(1)}_{go}+\\beta^{(1)}_{go}B_{ig}+\\gamma_{go,F}F_i\\\\",
    "&+\\gamma_{go,AA}R_{i,AA}+\\gamma_{go,AS}R_{i,AS}+\\gamma_{go,LT}R_{i,LT}+\\gamma_{go,NA}R_{i,NA}+\\gamma_{go,WH}R_{i,WH}\\\\",
    "&+\\gamma_{go,E_L}E_{i,L}+\\gamma_{go,E_C}E_{i,C}+\\gamma_{go,E_B}E_{i,B}\\\\",
    "&+\\gamma_{go,I_2}I_{i,2}+\\gamma_{go,I_3}I_{i,3}+\\gamma_{go,I_4}I_{i,4}+u^{(1)}_{igo}.",
    "\\end{aligned}", "$$", "",
    "Y is the accepted Stage 07 cleaned English standard score: ppvt_english_standard_score_clean or applied_problems_english_standard_score_clean. PF sources are PPVTEPF / WJ10_SSEPF; KF sources are PPVTEKF / WJ10_SSEKF. B is unchanged T_IDEAP at PF or T_IDEAK at KF.", "",
    "F is CHGENP=2 (Female), with code 1 (Male) as reference. R_AA, R_AS, R_LT, R_NA and R_WH equal code 1 (Yes) for CHRACE_AAP, CHRACE_ASP, CHRACE_LTP, CHRACE_NAP and CHRACE_WHP respectively; code 0 (No) is the reference for each. These five indicators are nonexclusive and enter separately.", "",
    "E_L is CHMATEDCP codes 1-2 (Below HS); E_C is codes 4-6 (college/technical/associate without BA); E_B is codes 7-9 (BA+). Code 3 (HS) is the reference. Code 10 (Other) has no observed responses, verified before fitting. Missing education is not reinterpreted as household composition.", "",
    "I_2 is CHINCOMCP codes 5-8 ($20,001-40,000); I_3 is codes 9-12 ($40,001-60,000); I_4 is codes 13-18 (>$60,000). Codes 1-4 (at most $20,000) are the reference. All indicators equal zero for other observed categories; missing responses remain missing. The 12 descriptors are F, five R terms, three E terms and three I terms. M1 has 14 columns including intercept and belief; M0 has two.", "",
    "All descriptors are Pre-K reports and earlier characteristics for Kindergarten. They are not universally established as pre-exposure or current Kindergarten covariates; exact assessment ordering and income reference year remain unresolved. Age and home language are unadjusted; race is not a language measure.", "",
    "Define $\\mathbf z^{(0)}_{ig}=(1,B_{ig})'$ and $\\mathbf z^{(1)}_{ig}=(1,B_{ig},\\mathbf X_i')'$. Separately for every model:", "",
    "$$", "\\widehat{\\boldsymbol\\theta}^{(m)}_{go}=\\arg\\min_{\\boldsymbol\\theta}\\sum_{i\\in S_{go}}(Y_{igo}-\\mathbf z^{(m)\\prime}_{ig}\\boldsymbol\\theta)^2.", "$$", "",
    "Theta contains alpha, beta and, for M1, the 12 gamma coefficients. The u terms describe residual departures from the fitted sample relationship; this notation imposes no population exogeneity, independent-sampling or causal assumptions. Only beta is reported. M0 beta is an unadjusted sample linear association. M1 beta is a sample linear association after adjustment for the specified descriptors. This is a fitted linear description; a true conditional expectation function is not established.", "",
    "The coefficient unit is outcome standard-score points per one-unit higher released belief score: a native T_IDEAP unit in Pre-K or T_IDEAK unit in Kindergarten. Released belief construction, substantive direction and cross-grade psychometric equivalence remain unresolved. Numerical cross-grade magnitudes cannot be treated as effects on a common belief scale.", "",
    "## Samples and descriptive reading", "",
    "S_go contains one unique relevant Fall row per child, finite native belief, Stage 07 eligibility TRUE, and valid observed responses on all eight source covariates. Eligible scores are asserted finite. Stage 07 cleaning and practice-failure exclusions are preserved. Each cell uses exactly the same ordered child IDs for M0 and M1. No Spring observation, other outcome, other grade, grouping completeness or no-change report is required.", "",
    "Support ceilings are 791/755 for Pre-K/Kindergarten PPVT and 776/769 for Applied Problems. Covariate losses are 61/55 and 59/56 respectively, yielding the displayed samples. Support, sequential and overlapping losses, missingness partitions, and retained categorical counts reconcile with Stage 11. Stage 11 saved aggregate diagnostics but no child-level membership list or fingerprint: unchanged inputs, reconstructed rules and matching aggregates support continuity but cannot independently certify historical child-by-child membership.", "",
    interpretation, "",
    "Adjustment changes the fitted sample association on a fixed sample within each cell; it does not establish that confounding has been eliminated. All four prespecified cells are retained regardless of numerical direction or magnitude.", "",
    "## Unresolved limits", "",
    "These are associations among the included released children. Teachers attached to more included children contribute more observations; the target is neither an equal-teacher nor a population estimate. Complete-case selection, English-score availability and attrition limit the represented sample, which is not a verified monolingual population.", "",
    "Report-to-child and report-to-instruction-period correspondence, released site identity scope, teacher containment, original PSU/site dependence and state/design information remain unresolved. Child observations need not be independent. No uncertainty procedure is established. Point estimates cannot establish statistical uncertainty, population relationships or causal effects.", "",
    "Outcome metric comparability, Spanish assessment gaps and Stage 07 measurement warnings persist. No belief harmonization, language pooling, absolute-growth interpretation, weighting, fixed effects, sensitivity analysis, trimming, imputation or additional controls are used. The writing-sample contribution is transparent selection and prespecified adjustment of numerical sample associations; its substantive value requires review of all results.")
  check("source_objects_unchanged", identical(serialize(wide, NULL), wide_original) && identical(serialize(panel, NULL), panel_original))
  # Positive checks of the boundary plus exclusion of numerical inference/reporting patterns.
  prohibited <- "(?i)(p[- ]?value\\s*[=:<>]|[tzF][- ]statistic\\s*[=:]|standard error\\s*[=:]|confidence interval\\s*[=:]|\\bsignificantly\\b|greater progressiveness|greater traditionalism|\\bR[- ]?squared\\b|\\bcorr(elation)?\\s*[=:])"
  check("narrative_boundary", !any(grepl(prohibited, memo, perl = TRUE)) &&
    any(grepl("sample linear association after adjustment for the specified descriptors", memo, fixed = TRUE)) &&
    !any(grepl("\\*\\*\\*", table_lines)))
  script <- readLines(here::here(script_path), warn = FALSE)
  check("estimation_api_boundary", !any(grepl("\\b(summary|vcov|confint|cor|cor.test|anova|broom::|lmtest::)\\s*\\(",
    script[!grepl("estimation_api_boundary|script\\[", script)], perl = TRUE)))
  check("protected_inventory", identical(protected_paths(), protected))
  check("protected_hashes", identical(md5(protected), before), observed = length(protected), expected = length(protected))
  check("git_head_index", identical(git(c("rev-parse", "HEAD")), head_before) && identical(git(c("ls-files", "--stage")), index_before))
  check("git_whitespace", length(git(c("diff", "--check"))) == 0L)
  # Release only after all eight models pass; readback failure withdraws both results.
  # The fixed output paths are the only on-disk writers in this script.
  write_csv(results, dest[1])
  reread <- read_csv(dest[1])
  check("csv_numeric_roundtrip", identical(reread$estimate, results$estimate),
    detail = "17 significant digits; exact binary-double readback")
  check("csv_fixed_schema", identical(names(reread), schema) && nrow(reread) == 8L && !anyDuplicated(reread[c("cell", "model")]))
  check("csv_display_agreement", identical(make_table(reread), table_lines))
  write_md(memo, dest[2])
  check("memo_readback_table", all(table_lines %in% readLines(here::here(dest[2]), warn = FALSE)))
  NULL
}, error = function(e) conditionMessage(e))

# Always recheck preservation, including failed-run paths. Independent cell failures are retained above.
check("final_protected_inventory", identical(protected_paths(), protected), fatal = FALSE)
check("final_protected_hashes", identical(md5(protected), before), observed = length(protected), expected = length(protected), fatal = FALSE)
check("final_head_index", identical(git(c("rev-parse", "HEAD")), head_before) && identical(git(c("ls-files", "--stage")), index_before), fatal = FALSE)
check("final_git_whitespace", length(git(c("diff", "--check"))) == 0L, fatal = FALSE)
ledger <- bind(checks)
success <- is.null(failure) && all(ledger$status == "pass")
if (!success) {
  # These paths were required absent at entry; only task-created result files can be removed.
  for (p in dest[1:2]) if (file.exists(here::here(p))) unlink(here::here(p))
}
write_csv(ledger, dest[3])
status_after <- git(c("status", "--short", "--branch"))
hash_rows <- function(p) paste0("| ", p, " | ", unname(md5(p)), " |")
sha_paths <- c(script_path, if (success) dest[1:2], dest[3])
note <- c("# Stage 12 verification and unresolved record", "",
  paste0("Execution-start UTC: ", start_time, ". Completed UTC: ", format(Sys.time(), tz = "UTC", usetz = TRUE), "."),
  paste0("Exit status: ", if (success) "0 (all checks passed)" else "1 (results withheld)", "."),
  paste0("R: ", R.version.string, "; platform: ", R.version$platform, "; locale: ", Sys.getlocale(), "."),
  paste0("Executable: ", normalizePath(file.path(R.home("bin"), "Rscript.exe"), winslash = "/"), "."),
  paste0("here version: ", as.character(packageVersion("here")), "; renv version: ", as.character(packageVersion("renv")), "."),
  "Project renv/activate.R loaded explicitly; no upstream stage script executed. No package installation or network access.", "",
  "Exact fresh-session PowerShell command from the verified root:", "```powershell",
  "$env:LC_ALL = 'English_United States.utf8'",
  "& 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/12_estimate_fall_associations.R", "```", "",
  paste0("HEAD: ", head_before, "; branch: ", branch_before, ". HEAD and index preserved; nothing staged, committed or pushed."),
  "Git commands executed by this script (each with process-scoped -c safe.directory=<verified root>, no config modification): rev-parse --show-toplevel; rev-parse HEAD; branch --show-current; status --short --branch; ls-files --stage; diff --cached --name-only; ls-files; check-ignore -q -- <each declared destination>; diff --check. Successful Git commands return zero; whitespace commands return empty output.", "",
  "Starting status:", "```text", status_before, "```", "Final status:", "```text", status_after, "```", "",
  paste0("Executed Stage 12 checks: ", nrow(ledger), "; pass: ", sum(ledger$status == "pass"), "; fail: ", sum(ledger$status == "fail"), ". Unique check IDs and fixed ledger schema are enforced. Every CSV is reread field by field and Markdown line by line."),
  "Executed numerical checks: M0 centered cross-product ratio; M1 QR FWL residualization; positive finite denominators; |a-b| <= 1e-10 max(1,|a|,|b|). QR tolerance is 1e-7; expected ranks/columns are 2/2 and 14/14, with belief adding one rank. No default regression summaries or inference functions are called.",
  "Executed fixtures use the production fitting/mapping/selection guards: known unadjusted and adjusted slopes, overlapping nonexclusive indicators, education/income boundaries, missing covariates, nonfinite inputs, constant belief, collinear belief, conflicting labels, and display precision. Each rejected fixture is an expected failure, not a failed research-data model.",
  "Executed reconstruction checks reconcile support ceilings, sample losses (sequential and overlapping), exact missingness categories/counts, and every retained released categorical count with accepted Stage 11 aggregates. Source-to-panel values, labels, missingness, uniqueness, Stage 07 eligibility and unchanged eligible outcomes are checked. Both models use identical ordered child-ID vectors held only in memory.",
  "Historical evidence: the 173 passing Stage 11 checks were inspected, not rerun. Its six SHA-256 fingerprints match the accepted handoff; nine upstream MD5 fingerprints match its historical note. No earlier output was updated.", "",
  "Implementation troubleshooting: the initial execution passed data/model checks but stopped at checks-ledger readback. Embedded quotes in setup-documentation text required CSV qmethod=double. A diagnostic rerun confirmed a parsing-length discrepancy. The next execution passed all CSV checks but stopped at final-note readback because in-memory fingerprint lines carried vector names, which text files cannot retain; the Markdown writer now compares unnamed lines. These writer corrections did not change data, models or tolerances. Only task-created coefficient/memo files from incomplete executions were removed before rerunning the exact fresh-session command.", "",
  "Formatting correction (2026-10-18): memo-generation strings now use four display-math blocks with standalone $$ delimiters and two inline expressions with $ delimiters. The aligned environment, every mathematical expression and all estimation/interpretation code are preserved. The two authorized task-generated result files were removed for regeneration; no earlier-stage file was removed or changed. Focused structural comparison and local Quarto preview are performed separately from the unchanged 508-check execution ledger.", "",
  "Pre-formatting SHA-256 fingerprints: script 62ab0d444ede6d312aef7b0d446ca6d18893d43966bfd9457ba8c3bbbde6d831; coefficient CSV 445576ab6f472ca66f5f2af975372b48978b4493f281ed7bad8383c3ed1e9b96; results memo 49a23d60222275d2ba0cb392c5f53759360b121189ef933791cd11019d81e046; checks ledger 9263a8655b80b26a27b241580989cf3e4d6b46c0137ec36a0adce2ae57734af6; verification note b8c5243ae2577348467f0e963f4de475dfac8638ee6f942798048b743e703818. A complete pre-change file inventory and SHA-256 manifest are retained outside the repository for focused preservation verification.", "",
  "Preservation: tracked files and all existing files under Data/docs/code/output are hashed before/after, excluding only the four declared Stage 12 destinations. The manifest below includes the new script and all six accepted Stage 11 files. Inventory equality is checked; source R objects serialize identically. Only four aggregate artifacts are written; no analysis dataset, child identifiers, membership lists, fitted objects or plots are saved.", "",
  "## Unresolved issues and review limits", "",
  "Stage 11 saved aggregate diagnostics but no child-level membership list or fingerprint. Unchanged accepted inputs, faithful reconstruction and matching aggregates support continuity; historical child-by-child membership cannot be independently certified. Stage 12 exact within-cell M0/M1 membership equality is checked in memory.",
  "Released belief construction, substantive direction, cross-grade equivalence, report correspondence, site identity scope, teacher containment, PSU/site dependence, state/design information, complete-case and English-score selection, covariate timing/income reference year, and Stage 07 outcome-measurement limitations remain unresolved. No uncertainty method, population generalization or causal identification is established. No new substantive ambiguity is resolved by assumption.",
  if (success) "No execution warnings or unresolved implementation failures. Results are available for independent review; this is local execution evidence, not an independent raw-data replication." else paste0("Execution failure: ", failure, ". See failed checks; coefficient CSV and results memo withheld. Frozen coding and tolerances were not changed."), "",
  "## SHA-256: accepted Stage 11 inputs", "", "| Path | SHA-256 |", "|---|---|",
  paste0("| ", stage11, " | ", stage11_sha, " |"), "",
  "## SHA-256: new script and completed artifacts", "", "| Path | SHA-256 |", "|---|---|",
  vapply(sha_paths, function(p) paste0("| ", p, " | ", sha256(p), " |"), character(1)), "",
  "This verification note cannot contain its own final byte hash. Its final SHA-256 is calculated externally and supplied with the delivery.", "",
  "## Protected MD5 fingerprints (execution start = finish)", "", "| Relative protected path | Before and after MD5 |", "|---|---|", hash_rows(protected), "",
  "## Session", "", "```text", capture.output(sessionInfo()), "```")
write_md(note, dest[4])
if (!success) stop("Stage12 failed: ", failure, "; see ", dest[3], call. = FALSE)
cat("Stage12 passed:", nrow(ledger), "checks; eight belief coefficients; four aggregate artifacts.\n")
