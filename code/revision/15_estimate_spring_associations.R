# Stage 15: descriptive Spring belief-assessment associations, point estimates only.
# Run from the project root (existing dependencies only):
# $env:LC_ALL = 'English_United States.utf8'
# & 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/15_estimate_spring_associations.R
# No upstream executable stage is sourced. Child-level objects remain in memory.
project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
git <- function(args) {
  z <- system2("git", c("-c", shQuote(paste0("safe.directory=", project_start)), args), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("Git failed: ", paste(args, collapse = " "))
  z
}
stopifnot(identical(normalizePath(git(c("rev-parse", "--show-toplevel"))[1], winslash = "/"), project_start),
  basename(project_start) == "ICPSR_04283")
head_before <- git(c("rev-parse", "HEAD")); branch_before <- git(c("branch", "--show-current"))
status_before <- git(c("status", "--short", "--branch")); index_before <- git(c("ls-files", "--stage"))
script_path <- "code/revision/15_estimate_spring_associations.R"
stopifnot(head_before == "530d637da394748ae703a38da12456972cbf6d32",
  branch_before == "codex/restructure-project-layout", !length(git(c("diff", "--cached", "--name-only"))),
  length(status_before) == 2L, status_before[2] == paste0("?? ", script_path))
Sys.setenv(RENV_PATHS_ROOT = file.path(project_start, "renv", "local"),
  RENV_CONFIG_SANDBOX_ENABLED = "FALSE", RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
source(file.path(project_start, "renv", "activate.R"))
suppressPackageStartupMessages(library(here))
stopifnot(identical(normalizePath(here::here(), winslash = "/"), project_start))
options(stringsAsFactors = FALSE, OutDec = ".", digits = 17, warn = 2)
dest <- c("output/tables/stage15_spring_belief_coefficients.csv",
  "output/tables/stage15_spring_full_coefficients.csv", "output/tables/stage15_spring_fit_diagnostics.csv",
  "output/reports/stage15_spring_associations.md", "output/verification/stage15_checks.csv",
  "output/verification/stage15_verification_unresolved.md")
ignored <- function(p) identical(system2("git", c("-c", shQuote(paste0("safe.directory=", project_start)),
  "check-ignore", "-q", "--", shQuote(p))), 0L)
stopifnot(!any(file.exists(here::here(dest))), all(dir.exists(here::here(dirname(dest)))),
  all(vapply(dest, ignored, logical(1))))
inventory_paths <- function() {
  p <- list.files(project_start, recursive = TRUE, all.files = TRUE, include.dirs = FALSE)
  sort(setdiff(p[!grepl("^\\.git/", p)], dest))
}
protected <- inventory_paths(); before <- tools::md5sum(here::here(protected))
start_time <- format(Sys.time(), tz = "UTC", usetz = TRUE)
python <- Sys.getenv("STAGE15_PYTHON", Sys.which("python"))
stopifnot(nzchar(python), file.exists(python))
py <- function(code) {
  z <- system2(python, c("-X", "utf8", "-c", shQuote(code)), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("Python hashlib helper failed")
  z
}
sha_text <- function(s) {
  # Transport only through process memory; no identifier/membership temporary file.
  hex <- paste(sprintf("%02x", as.integer(charToRaw(enc2utf8(s)))), collapse = "")
  unname(py(paste0("import hashlib; print(hashlib.sha256(bytes.fromhex('", hex, "')).hexdigest())")))
}
sha_file <- function(p) {
  z <- system2("certutil", c("-hashfile", shQuote(here::here(p)), "SHA256"), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("SHA-256 failed: ", p)
  h <- gsub(" ", "", trimws(z), fixed = TRUE); h <- h[grepl("^[0-9a-fA-F]{64}$", h)]
  stopifnot(length(h) == 1L); tolower(h)
}
read_csv <- function(p) read.csv(here::here(p), check.names = FALSE, fileEncoding = "UTF-8")
bind <- function(z) { x <- do.call(rbind, z); row.names(x) <- NULL; x }
checks <- list()
check <- function(id, ok, observed = "", expected = "TRUE", cell = "all", model = "", tolerance = NA_real_, detail = "") {
  key <- paste(cell, model, id, sep = ":")
  stopifnot(!key %in% vapply(checks, `[[`, "", "check_id"))
  checks[[length(checks) + 1L]] <<- data.frame(check_id = key, cell, model,
    status = if (isTRUE(ok)) "pass" else "fail", observed = paste(observed, collapse = ";"),
    expected = paste(expected, collapse = ";"), tolerance, detail)
  if (!isTRUE(ok)) stop("Stage15 check failed: ", key, "; ", detail)
}
qr_tol <- 1e-7; numeric_tol <- 1e-10
close_numeric <- function(a, b) length(a) == length(b) && all(is.finite(c(a, b))) &&
  all(abs(a - b) <= numeric_tol * pmax(1, abs(a), abs(b)))
failed <- function(expr) inherits(tryCatch({ force(expr); NULL }, error = function(e) e), "error")
wide_path <- "Data/processed/verified_child_wide.rds"; panel_path <- "Data/processed/outcome_cleaning_panel.rds"
stage14 <- c("code/revision/14_assess_spring_sample_readiness.R", "output/tables/stage14_sample_support.csv",
  "output/tables/stage14_sample_descriptives.csv", "output/reports/stage14_spring_sample_readiness.md",
  "output/verification/stage14_checks.csv", "output/verification/stage14_verification_unresolved.md")
stage14_sha <- c("0556e1bc30966abac05c8ea13eac72034beb32b5e86615b7c7ce51b951e1b0a9",
  "4537475cff9bbb2012b92f27fbb9dfc06afa58895894dc9101cea53fd6e4139e",
  "fd379f68760e08cf13a3aeacb9a86b09b073d370506e99a6d66703b956325ba6",
  "a75643c53302801f6e7c7fc71ae7efe6173c338aa5aecf97e7cb4d0cf732f6a2",
  "8aa6d9332d498279534bd713b01943a20093f62975845f2a90ffba5287c02ecc",
  "aff892543af2f8033ed6b644311d79312d11f8084018cfb0b9adc9efb00800d1")
created <- list()
failure <- tryCatch({
for (j in seq_along(stage14)) check(paste0("stage14_pin_", j), sha_file(stage14[j]) == stage14_sha[j], detail = stage14[j])
receipt_lines <- readLines(here::here(stage14[6]), warn = FALSE)
receipt_lines <- receipt_lines[seq_len(match("## New artifact fingerprints", receipt_lines) - 1L)]
receipt_lines <- receipt_lines[grepl("^\\| [^|]+ \\| [0-9a-f]{64} \\|$", receipt_lines)]
receipts <- lapply(receipt_lines, function(s) trimws(strsplit(s, "|", fixed = TRUE)[[1]][2:3]))
check("sixteen_input_receipts", length(receipts) == 16L && !anyDuplicated(vapply(receipts, `[`, "", 1L)))
for (j in seq_along(receipts)) check(paste0("accepted_input_sha_", j),
  sha_file(receipts[[j]][1]) == receipts[[j]][2], detail = receipts[[j]][1])
wide_sha <- sha_file(wide_path); panel_sha <- sha_file(panel_path)
check("wide_hash", wide_sha == "a4b4a9d662093345ea65badd51e47ac08d73e3e8eebd4dec211bbe3523be2952", wide_sha)
check("panel_hash", panel_sha == "647d516b29abf647f6545caae662354752650d0596093ddc16277b2618486cf7", panel_sha)
check("hash_known_answer", sha_text("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
for (stage in 11:14) {
  x <- read_csv(paste0("output/verification/stage", stage, "_checks.csv"))
  check(paste0("recorded_stage", stage), all(x$status == "pass") && !anyDuplicated(x$check_id) &&
    nrow(x) == c(`11` = 173L, `12` = 508L, `13` = 111L, `14` = 1537L)[as.character(stage)], nrow(x),
    detail = "Inherited recorded checks inspected; completed stages not executed")
}
wide <- readRDS(here::here(wide_path)); panel <- readRDS(here::here(panel_path))
wide_original <- serialize(wide, NULL); panel_original <- serialize(panel, NULL)
check("dimensions", nrow(wide) == 1015L && nrow(panel) == 4060L)
prov <- read_csv("output/tables/verified_wide_provenance.csv")
panel_prov <- read_csv("output/tables/structural_panel_provenance.csv")
characteristic_inventory <- read_csv("output/tables/stage08_characteristic_inventory.csv")
rules <- read_csv("output/tables/outcome_cleaning_rules.csv")
counts07 <- read_csv("output/tables/outcome_cleaning_counts.csv")
setup <- readLines(here::here("docs/icpsr/DS0001/04283-0001-Setup.do"), warn = FALSE)
dictionary <- readLines(here::here("docs/icpsr/DS0001/04283-0001-Setup.dct"), warn = FALSE)

# Construction: accepted released code-label validation and key alignment.
covars <- c("CHGENP", "CHRACE_AAP", "CHRACE_ASP", "CHRACE_LTP", "CHRACE_NAP", "CHRACE_WHP", "CHMATEDCP", "CHINCOMCP")
expected <- list(CHGENP = c(`1` = "Male", `2` = "Female"))
for (f in covars[2:6]) expected[[f]] <- c(`0` = "No", `1` = "Yes")
expected$CHMATEDCP <- setNames(c("8th Grade or less", "Some high school", "HS diploma or equivalent", "Some college",
  "HS + tech training", "AA, AS, 2yr degree", "Bachelor's", "Master's", "Doctoral", "Other"), 1:10)
expected$CHINCOMCP <- setNames(c("$5,000 or <", "$5,001 - $10,000", "$10,001 - $15,000", "$15,001 - $20,000",
  "$20,001 - $25,000", "$25,001 - $30,000", "$30,001 - $35,000", "$35,001 - $40,000", "$40,001 - $45,000",
  "$45,001 - $50,000", "$50,001 - $55,000", "$55,001 - $60,000", "$60,001 - $65,000", "$65,001 - $70,000",
  "$70,001 - $75,000", "$75,001 - $80,000", "$80,001 - $85,000", "$85,001 or >"), 1:18)
factor_labels <- function(f) {
  codes <- as.integer(names(expected[[f]]))
  paste0("(", sprintf(paste0("%0", if (max(codes) >= 10) 2L else 1L, "d"), codes), ") ", unname(expected[[f]]))
}
decode <- function(v, f) {
  if (!is.factor(v) || !identical(levels(v), factor_labels(f))) stop("Conflicting released code-label pairs: ", f)
  z <- match(as.character(v), factor_labels(f))
  if (!identical(is.na(z), is.na(v))) stop("Unexpected descriptor response: ", f)
  as.integer(names(expected[[f]]))[z]
}
parse_pairs <- function(text) {
  z <- regmatches(text, gregexpr('-?[0-9]+[[:space:]]+"[^"]*"', text))[[1]]
  setNames(sub('^-?[0-9]+[[:space:]]+"(.*)"$', '\\1', z), sub('[[:space:]].*', '', z))
}
codes <- as.data.frame(lapply(covars, function(f) decode(wide[[f]], f))); names(codes) <- covars
for (f in covars) {
  first <- grep(paste0("^label define ", f, "[[:space:]]"), setup)
  check(paste0("setup_unique_", f), length(first) == 1L)
  last <- first - 1L + which(grepl(";", setup[first:length(setup)], fixed = TRUE))[1]
  block <- paste(trimws(setup[first:last]), collapse = " ")
  pr <- prov[prov$raw_variable == f, ]; inv <- characteristic_inventory[characteristic_inventory$characteristic == f, ]
  di <- grep(paste0("[[:space:]]", f, "[[:space:]]"), dictionary)
  check(paste0("descriptor_docs_", f), identical(parse_pairs(block), c(`-99` = "System Missing", expected[[f]])) &&
    nrow(pr) == 1L && isTRUE(pr$included_in_output) && pr$transformation_applied == "none" &&
    length(di) == 1L && grepl(pr$raw_label, dictionary[di], fixed = TRUE) &&
    length(grep(paste0("^replace ", f, " = \\. if \\(", f, " == -99\\)"), setup)) == 1L &&
    nrow(inv) == 1L && identical(inv$released_setup_definition, block), detail = paste(inv$documentary_locators, collapse = ";"))
}
check("education_other_absent", !any(codes$CHMATEDCP == 10L, na.rm = TRUE), sum(codes$CHMATEDCP == 10L, na.rm = TRUE), 0,
  detail = "Unexpected Other requires specification review; never folded into a reference or extra exclusion")
indicator <- function(v, a) ifelse(is.na(v), NA_real_, as.numeric(v %in% a))
descriptor_matrix <- function(codes) {
  z <- cbind(F = indicator(codes$CHGENP, 2L))
  for (f in covars[2:6]) z <- cbind(z, indicator(codes[[f]], 1L))
  colnames(z) <- c("F", "R_AA", "R_AS", "R_LT", "R_NA", "R_WH")
  cbind(z, E_L = indicator(codes$CHMATEDCP, 1:2), E_C = indicator(codes$CHMATEDCP, 4:6),
    E_B = indicator(codes$CHMATEDCP, 7:9), I_2 = indicator(codes$CHINCOMCP, 5:8),
    I_3 = indicator(codes$CHINCOMCP, 9:12), I_4 = indicator(codes$CHINCOMCP, 13:18))
}
X <- descriptor_matrix(codes)
check("descriptor_matrix_coding", ncol(X) == 12L && identical(complete.cases(X), complete.cases(codes)))
# Index joins use keys, independent of source row order; complete wave coverage required.
align_wave <- function(wide_ids, p, wave) {
  if (anyNA(wide_ids) || anyDuplicated(wide_ids) || anyNA(p$STUDY_ID) || anyNA(p$wave) ||
      anyDuplicated(p[c("STUDY_ID", "wave")])) stop("Missing/duplicate child or child-wave key")
  rows <- which(as.character(p$wave) == wave); m <- match(wide_ids, p$STUDY_ID[rows])
  if (length(rows) != length(wide_ids) || anyNA(m) || !setequal(wide_ids, p$STUDY_ID[rows])) stop("Unmatched wave/universe keys")
  rows[m]
}
wave_rows <- lapply(c("PF", "PS", "KF", "KS"), function(w) align_wave(wide$STUDY_ID, panel, w))
names(wave_rows) <- c("PF", "PS", "KF", "KS")
check("fixed_child_universe", is.numeric(wide$STUDY_ID) && all(is.finite(wide$STUDY_ID)) &&
  all(vapply(wave_rows, function(i) identical(panel$STUDY_ID[i], wide$STUDY_ID), logical(1))))
ordering <- order(wide$STUDY_ID, method = "radix")
for (w in names(wave_rows)) for (f in covars) check(paste0("descriptor_overlap_", w, "_", f),
  identical(decode(panel[[f]][wave_rows[[w]]], f), codes[[f]]))
same <- function(a, b) identical(is.na(a), is.na(b)) && isTRUE(all.equal(as.vector(a), as.vector(b), check.attributes = FALSE, tolerance = 0))
validate_lineage <- function(out, src, w, ck) {
  pp <- panel_prov[panel_prov$output_variable == out & panel_prov$wave == w, ]
  pr <- prov[prov$raw_variable == src, ]; di <- grep(paste0("[[:space:]]", src, "[[:space:]]"), dictionary)
  ck(paste0("lineage_", src), nrow(pp) == 1L && pp$source_variable == src && pp$transformation_applied == "none" &&
    nrow(pr) == 1L && isTRUE(pr$included_in_output) && pr$transformation_applied == "none" && length(di) == 1L &&
    (if (src == "WJ10_SSEPS") grepl(gsub("[[:space:]]+", " ", pr$raw_label), gsub("[[:space:]]+", " ", dictionary[di]), fixed = TRUE) else grepl(pr$raw_label, dictionary[di], fixed = TRUE)) &&
    same(panel[[out]][wave_rows[[w]]], wide[[src]]),
    detail = paste0(paste(pp$source_page_or_section, collapse = ";"),
      "; dictionary/provenance label whitespace normalized only (WJ10_SSEPS has STAND  SCORE versus STAND SCORE); source names and values exact"))
}
rule_id <- "stage14_spring_pair_native_fall_stage07_complete8_v1"
signature <- function(cell, mask, ids, wide_hash = wide_sha, panel_hash = panel_sha, rule = rule_id) {
  if (!is.logical(mask) || anyNA(mask) || length(mask) != length(ids) || anyNA(ids) || anyDuplicated(ids) ||
      !is.numeric(ids) || any(!is.finite(ids))) stop("Invalid signature universe/membership")
  # Canonical record: exactly these seven LF-terminated ASCII/UTF-8 lines; no BOM/CR/spaces.
  # Bits have no separators; the ordering is numeric ascending STUDY_ID over the fixed wide universe.
  record <- paste0("format=stage14-membership-sha256-v1\ncell=", cell, "\nrule=", rule,
    "\nwide_sha256=", wide_hash, "\npanel_sha256=", panel_hash, "\nuniverse_n=", length(ids),
    "\nmembership=", paste0(as.integer(mask[order(ids, method = "radix")]), collapse = ""), "\n")
  sha_text(record)
}

# Estimation: explicit matrices, no missing-value omission or inferential calls.
descriptor_terms <- c("F", "R_AA", "R_AS", "R_LT", "R_NA", "R_WH", "E_L", "E_C", "E_B", "I_2", "I_3", "I_4")
terms_for <- function(model) switch(model,
  S0 = c("Intercept", "belief"), S1 = c("Intercept", "belief", descriptor_terms),
  S2 = c("Intercept", "belief", "fall_score", descriptor_terms), stop("Unknown model"))
make_matrix <- function(b, fall, x, model) {
  z <- cbind(Intercept = rep(1, length(b)), belief = b)
  if (model == "S2") z <- cbind(z, fall_score = fall)
  if (model != "S0") z <- cbind(z, x)
  if (!identical(colnames(z), terms_for(model))) stop("Unexpected term order")
  z
}
fit_point <- function(z, y, model) {
  if (!is.matrix(z) || !is.numeric(z) || !is.numeric(y) || nrow(z) != length(y) ||
      !length(y) || any(!is.finite(c(z, y))) || !identical(colnames(z), terms_for(model)) ||
      any(z[, "Intercept"] != 1)) stop("Invalid/nonfinite matrix, response or order")
  a <- z[, colnames(z) != "belief", drop = FALSE]
  qz <- qr(z, tol = qr_tol); qa <- qr(a, tol = qr_tol)
  if (qz$rank != ncol(z) || qz$rank - qa$rank != 1L || nrow(z) <= qz$rank)
    stop("Rank/degree-of-freedom failure; specification review required")
  fit <- stats::lm.fit(z, y, tol = qr_tol)
  if (fit$rank != qz$rank || !identical(names(fit$coefficients), colnames(z)) ||
      any(!is.finite(c(fit$coefficients, fit$fitted.values, fit$residuals)))) stop("Invalid fit")
  # Independent S0 centered cross-products; S1/S2 FWL using QR on other columns.
  rb <- if (model == "S0") z[, "belief"] - mean(z[, "belief"]) else qr.resid(qa, z[, "belief"])
  ry <- if (model == "S0") y - mean(y) else qr.resid(qa, y)
  rbss <- sum(rb * rb)
  if (!is.finite(rbss) || rbss <= 0) stop("Invalid residual-belief sum of squares")
  independent <- sum(rb * ry) / rbss
  reconstructed <- as.vector(z %*% fit$coefficients)
  if (!close_numeric(fit$coefficients["belief"], independent) ||
      !close_numeric(fit$fitted.values, reconstructed) ||
      !close_numeric(fit$residuals, y - reconstructed) ||
      !close_numeric(y, fit$fitted.values + fit$residuals)) stop("Numerical reconstruction/FWL failure")
  normal <- as.vector(crossprod(z, fit$residuals))
  normal_scale <- pmax(1, sqrt(colSums(z * z)) * sqrt(sum(y * y)))
  if (any(abs(normal) > numeric_tol * normal_scale)) stop("Residual normal equation failure")
  rss <- sum(fit$residuals^2); tss <- sum((y - mean(y))^2)
  diagnostics <- c(n_minus_rank = nrow(z) - qz$rank, rank_without_belief = qa$rank,
    belief_rank_increment = qz$rank - qa$rank, residual_belief_ss = rbss,
    independent_belief_estimate = independent,
    belief_abs_difference = abs(unname(fit$coefficients["belief"]) - independent),
    rss = rss, tss = tss, r_squared = 1 - rss/tss, rmse = sqrt(rss/nrow(z)))
  if (rss < 0 || tss <= 0 || any(!is.finite(diagnostics))) stop("Invalid aggregate fit diagnostics")
  # Return only aggregates. Fitted values, residuals and model object are discarded.
  list(coefficients = fit$coefficients, rank = qz$rank, diagnostics = diagnostics,
    normal_ratio = abs(normal)/normal_scale)
}
assert_membership <- function(cell, mask, expected_n, expected_hash, ids) {
  if (sum(mask) != expected_n || signature(cell, mask, ids) != expected_hash)
    stop("Authenticated membership mismatch (even if N agrees)")
  invisible(TRUE)
}

# Verification fixtures: deterministic orthogonal columns identify complete known
# coefficient vectors; Fall-score adjustment is nonzero in S2. No research data.
fixture_sign <- function(k) ifelse(bitwAnd(0:31, bitwShiftL(1L, k)) == 0L, -1, 1)
base_sign <- sapply(0:4, fixture_sign)
combinations <- cbind(1:5, 1:5)
combinations <- rbind(combinations, t(combn(1:5, 2)))
orth <- sapply(seq_len(nrow(combinations)), function(j) {
  ix <- unique(combinations[j, ]); apply(base_sign[, ix, drop = FALSE], 1L, prod)
})
fixture_b <- orth[, 1]; fixture_f <- orth[, 2]
fixture_x <- orth[, 3:14]; colnames(fixture_x) <- descriptor_terms
fixture_s2 <- make_matrix(fixture_b, fixture_f, fixture_x, "S2")
known_s2 <- setNames(c(7, -0.75, 1.25, seq_len(12)/8), terms_for("S2"))
fixture_y <- as.vector(fixture_s2 %*% known_s2 + 0.3 * orth[, 15])
for (model in c("S0", "S1", "S2")) {
  z <- make_matrix(fixture_b, fixture_f, fixture_x, model)
  f <- fit_point(z, fixture_y, model)
  check(paste0("fixture_full_vector_", model), identical(names(f$coefficients), terms_for(model)) &&
    close_numeric(f$coefficients, known_s2[terms_for(model)]), tolerance = numeric_tol,
    detail = "Complete known coefficient vector and exact term order; nonzero Fall coefficient in S2")
  bad <- z; bad[1, 2] <- Inf
  check(paste0("fixture_nonfinite_matrix_", model), failed(fit_point(bad, fixture_y, model)))
  bad <- z; bad[, 2] <- 1
  check(paste0("fixture_rank_deficient_", model), failed(fit_point(bad, fixture_y, model)))
  bad <- z[, rev(seq_len(ncol(z))), drop = FALSE]
  check(paste0("fixture_term_order_", model), failed(fit_point(bad, fixture_y, model)))
}
check("fixture_nonfinite_response", failed(fit_point(fixture_s2, replace(fixture_y, 1L, NA_real_), "S2")))
fp <- data.frame(STUDY_ID = c(1,2,3,1,2,3), wave = rep(c("PF", "PS"), each = 3), value = c(10,20,30,11,21,31))
shuffled <- fp[c(6,2,4,1,5,3), ]
check("fixture_shuffled_spring", identical(shuffled$value[align_wave(1:3, shuffled, "PS")], c(11,21,31)))
check("fixture_duplicate_keys", failed(align_wave(1:3, rbind(fp, fp[1, ]), "PS")))
bad <- fp; bad$STUDY_ID[6] <- 4
check("fixture_unmatched_keys", failed(align_wave(1:3, bad, "PS")))
check("fixture_bad_labels", failed(decode(factor("Other"), "CHGENP")))
fixture_hash <- signature("fixture", c(TRUE, FALSE), 1:2)
check("fixture_equal_n_membership_rejected", failed(assert_membership("fixture", c(FALSE, TRUE), 1L, fixture_hash, 1:2)))
check("fixture_signature_order", signature("fixture", c(FALSE, TRUE), 2:1) == fixture_hash)
check("fixture_signature_binding", length(unique(c(fixture_hash,
  signature("fixture2", c(TRUE,FALSE), 1:2), signature("fixture", c(TRUE,FALSE), 1:2, rule = "v2"),
  signature("fixture", c(TRUE,FALSE), 1:2, wide_hash = paste(rep("0",64),collapse="")),
  signature("fixture", c(TRUE,FALSE), 1:2, panel_hash = paste(rep("0",64),collapse=""))))) == 5L)

# Reconstruct and authenticate all four samples before fitting any research model.
cells <- data.frame(cell = c("PF_PPVT", "KF_PPVT", "PF_Applied_Problems", "KF_Applied_Problems"),
  grade = rep(c("Pre-K", "Kindergarten"), 2), fall = rep(c("PF", "KF"), 2), spring = rep(c("PS", "KS"), 2),
  outcome = rep(c("ppvt_english_standard_score", "applied_problems_english_standard_score"), each = 2),
  priority = rep(c("primary", "secondary"), each = 2),
  fall_src = c("PPVTEPF", "PPVTEKF", "WJ10_SSEPF", "WJ10_SSEKF"),
  spring_src = c("PPVTEPS", "PPVTEKS", "WJ10_SSEPS", "WJ10_SSEKS"),
  n = c(679L, 688L, 665L, 701L),
  signature = c("a72ecd748608e3a28107afa5f3998eaac8055a36b3b0b1d1c48d01b6bdf1fa3d",
    "e1727c34dafce102324337435ff6067b8aa12a1bdcd901557e6b56a93d5555a4",
    "93718361fad42bab0224e99dd97dfcbf438e94dd7f9febce8bdfb69fb79cd755",
    "99a59cd932ae9bffc1c8ff992748809a357abb75a320ccd5ae493850104050fd"))
samples <- list(); selection <- list()
for (ci in seq_len(nrow(cells))) {
  c <- cells[ci, ]; cell <- c$cell
  ck <- function(id, ok, observed = "", expected = "TRUE", model = "", detail = "", tolerance = NA_real_)
    check(id, ok, observed, expected, cell, model, tolerance, detail)
  fi <- wave_rows[[c$fall]]; o <- c$outcome
  bf <- if (c$fall == "PF") "teacher_modernity_pre_k_fall_released" else "teacher_modernity_kindergarten_fall_released"
  bs <- if (c$fall == "PF") "T_IDEAP" else "T_IDEAK"
  validate_lineage(bf, bs, c$fall, ck); b <- panel[[bf]][fi]
  ck("finite_or_missing_belief", is.numeric(b) && all(is.na(b) | is.finite(b)))
  scores <- list()
  for (season in c("fall", "spring")) {
    w <- c[[season]]; rows <- wave_rows[[w]]; src <- c[[paste0(season, "_src")]]
    validate_lineage(o, src, w, ck)
    e <- panel[[paste0(o, "_eligible_current_rules")]][rows]
    y <- panel[[paste0(o, "_clean")]][rows]
    reason <- panel[[paste0(o, "_cleaning_reason")]][rows]; raw <- wide[[src]]
    rr <- rules[rules$outcome == o & rules$wave == w, ]; ac <- counts07[counts07$outcome == o & counts07$wave == w, ]
    ck(paste0("rule_source_", w), nrow(rr) > 0L && all(rr$source_variable == src) && nrow(ac) == 1L)
    ck(paste0("eligible_values_", w), is.numeric(y) && is.logical(e) && length(e) == 1015L && !anyNA(e) &&
      all(!e | is.finite(y)) && same(y[e], raw[e]) && all(is.na(y[!e])))
    ck(paste0("accepted_reasons_", w), !anyNA(reason) &&
      all(reason %in% c("retained_under_current_rules", "source_missing_reason_unavailable", "practice_failure_project_exclusion")) &&
      identical(e, reason == "retained_under_current_rules") &&
      identical(is.na(raw), reason == "source_missing_reason_unavailable") && !any(!is.na(raw) & !is.finite(raw)))
    ck(paste0("stage07_counts_", w), sum(e) == ac$n_eligible_current_rules && sum(is.na(raw)) == ac$n_source_missing &&
      sum(reason == "practice_failure_project_exclusion") == ac$n_practice_failure_project_excluded)
    if (src %in% c("WJ10_SSEPF", "WJ10_SSEPS")) ck(paste0("practice_exclusion_", w),
      any(rr$rule_id == "practice_failure" & rr$rule_value == -7 & rr$action == "clean_NA_eligible_FALSE", na.rm = TRUE) &&
      identical(reason == "practice_failure_project_exclusion", !is.na(raw) & raw == -7) &&
      sum(reason == "practice_failure_project_exclusion") == if (w == "PF") 7L else 1L)
    scores[[season]] <- list(e = e, y = y)
  }
  mask <- scores$fall$e & scores$spring$e & is.finite(b) & complete.cases(codes)
  ck("authenticated_membership", isTRUE(assert_membership(cell, mask, c$n, c$signature, wide$STUDY_ID)), sum(mask), c$n)
  rows <- ordering[mask[ordering]]
  ck("ordered_finite_values", length(rows) == c$n && !anyDuplicated(wide$STUDY_ID[rows]) &&
    !is.unsorted(wide$STUDY_ID[rows], strictly = TRUE) &&
    all(is.finite(c(b[rows], scores$fall$y[rows], scores$spring$y[rows], X[rows, , drop = FALSE]))))
  # Counts after each important restriction; no additional outcome/grade restrictions.
  count <- c(universe = 1015L, eligible_fall = sum(scores$fall$e),
    eligible_pair = sum(scores$fall$e & scores$spring$e),
    pair_finite_belief = sum(scores$fall$e & scores$spring$e & is.finite(b)), complete8 = sum(mask))
  selection[[cell]] <- count
  ck("selection_counts_monotone", all(diff(count) <= 0), count)
  samples[[cell]] <- list(rows = rows, b = b[rows], fall = scores$fall$y[rows], y = scores$spring$y[rows],
    x = X[rows, , drop = FALSE], belief_source = bs, mask = mask)
}

# Fixed export schemas: nothing from an lm object is passed to a table writer.
metadata_names <- c("cell", "grade", "fall_wave", "spring_wave", "outcome", "outcome_priority",
  "fall_outcome_source", "spring_outcome_source", "belief_source", "model", "n", "rank", "n_columns",
  "sample_rule_id", "membership_sha256", "wide_sha256", "panel_sha256", "adjustment_id", "adjustment_label", "weighting")
schemas <- list(
  belief = c(metadata_names, "term", "estimate", "coefficient_unit"),
  full = c(metadata_names, "term_order", "term", "term_label", "reference_category", "estimate", "coefficient_unit"),
  diagnostics = c(metadata_names, "n_minus_rank", "rank_without_belief", "belief_rank_increment", "residual_belief_ss",
    "independent_belief_estimate", "belief_abs_difference", "rss", "tss", "r_squared", "rmse"),
  checks = c("check_id", "cell", "model", "status", "observed", "expected", "tolerance", "detail"))
schema_guard <- function(x, type) {
  if (!identical(names(x), schemas[[type]])) stop("Unexpected export schema: ", type)
  invisible(TRUE)
}
fixture_export <- as.data.frame(setNames(rep(list("fixture"), length(schemas$full)), schemas$full))
fixture_export$std_error <- 0
check("fixture_inferential_column_rejected", failed(schema_guard(fixture_export, "full")))
adjustment_ids <- c(S0 = "intercept_native_fall_belief", S1 = "stage14_explicit_12_descriptors_v1",
  S2 = "same_outcome_fall_score_stage14_explicit_12_descriptors_v1")
adjustment_labels <- c(S0 = "Intercept and native Fall belief", S1 = "S0 plus 12 accepted descriptor indicators",
  S2 = "S1 plus same-outcome measured Fall score")
term_labels <- c(Intercept = "Intercept", belief = "Higher released native Fall belief score",
  fall_score = "Same-outcome measured Fall standard score", F = "Female (CHGENP=2)",
  R_AA = "African American Yes", R_AS = "Asian Yes", R_LT = "Latino Yes", R_NA = "Native American Yes", R_WH = "White Yes",
  E_L = "Below HS (education codes 1-2)", E_C = "College/technical/associate without BA (codes 4-6)",
  E_B = "BA+ (education codes 7-9)", I_2 = "Income $20,001-$40,000 (codes 5-8)",
  I_3 = "Income $40,001-$60,000 (codes 9-12)", I_4 = "Income >$60,000 (codes 13-18)")
references <- setNames(rep("not_applicable", length(term_labels)), names(term_labels))
references["F"] <- "Male (CHGENP=1)"; references[c("R_AA", "R_AS", "R_LT", "R_NA", "R_WH")] <- "No (code 0), separately"
references[c("E_L", "E_C", "E_B")] <- "HS diploma or equivalent (education code 3)"
references[c("I_2", "I_3", "I_4")] <- "Income <=$20,000 (codes 1-4)"
unit_for <- function(terms) ifelse(terms == "Intercept", "assessment standard-score points (intercept)",
  ifelse(terms == "belief", "assessment standard-score points per one-unit higher native released belief score",
    ifelse(terms == "fall_score", "Spring assessment standard-score points per Fall assessment standard-score point",
      "assessment standard-score point contrast relative to reference category")))
belief_rows <- full_rows <- diagnostic_rows <- list()
for (ci in seq_len(nrow(cells))) {
  c <- cells[ci, ]; cell <- c$cell; s <- samples[[cell]]; last_rss <- Inf
  for (model in c("S0", "S1", "S2")) {
    ck <- function(id, ok, observed = "", expected = "TRUE", detail = "", tolerance = NA_real_)
      check(id, ok, observed, expected, cell, model, tolerance, detail)
    independently_selected <- which(s$mask)
    independently_selected <- independently_selected[order(wide$STUDY_ID[independently_selected], method = "radix")]
    ck("common_order", identical(s$rows, independently_selected) &&
      isTRUE(assert_membership(cell, s$mask, c$n, c$signature, wide$STUDY_ID)))
    z <- make_matrix(s$b, s$fall, s$x, model)
    ck("matrix_dimensions", identical(dim(z), c(c$n, length(terms_for(model)))), dim(z), c(c$n, length(terms_for(model))))
    f <- fit_point(z, s$y, model); d <- f$diagnostics
    ck("full_rank", f$rank == ncol(z) && d["belief_rank_increment"] == 1 && d["n_minus_rank"] > 0, f$rank, ncol(z))
    ck("independent_belief", close_numeric(unname(f$coefficients["belief"]), d["independent_belief_estimate"]),
      d["belief_abs_difference"], tolerance = numeric_tol)
    ck("finite_coefficients_diagnostics", all(is.finite(c(f$coefficients, d))))
    ck("reconstruction", TRUE, detail = "fit_point checked fitted values, residuals and y elementwise at fixed scalar tolerance", tolerance = numeric_tol)
    for (j in seq_len(ncol(z))) ck(paste0("normal_equation_", colnames(z)[j]), f$normal_ratio[j] <= numeric_tol,
      f$normal_ratio[j], numeric_tol, tolerance = numeric_tol)
    if (model != "S0") ck("nested_rss", d["rss"] <= last_rss + numeric_tol * max(1, d["tss"], last_rss, d["rss"]),
      d["rss"], last_rss, tolerance = numeric_tol)
    last_rss <- d["rss"]
    m <- data.frame(cell, grade = c$grade, fall_wave = c$fall, spring_wave = c$spring, outcome = c$outcome,
      outcome_priority = c$priority, fall_outcome_source = c$fall_src, spring_outcome_source = c$spring_src,
      belief_source = s$belief_source, model, n = c$n, rank = f$rank, n_columns = ncol(z), sample_rule_id = rule_id,
      membership_sha256 = c$signature, wide_sha256 = wide_sha, panel_sha256 = panel_sha,
      adjustment_id = unname(adjustment_ids[model]), adjustment_label = unname(adjustment_labels[model]),
      weighting = "unweighted_child_level")
    belief_rows[[length(belief_rows) + 1L]] <- cbind(m, data.frame(term = "belief",
      estimate = unname(f$coefficients["belief"]), coefficient_unit = unit_for("belief")))
    terms <- names(f$coefficients)
    full_rows[[length(full_rows) + 1L]] <- cbind(m[rep(1L, length(terms)), ], data.frame(term_order = seq_along(terms), term = terms,
      term_label = unname(term_labels[terms]), reference_category = unname(references[terms]),
      estimate = unname(f$coefficients), coefficient_unit = unit_for(terms)))
    diagnostic_rows[[length(diagnostic_rows) + 1L]] <- cbind(m, as.data.frame(as.list(d)))
  }
}
belief <- bind(belief_rows); full <- bind(full_rows); diagnostics <- bind(diagnostic_rows)
for (type in c("belief", "full", "diagnostics")) schema_guard(get(type), type)
check("result_counts", nrow(belief) == 12L && nrow(full) == 124L && nrow(diagnostics) == 12L, c(nrow(belief), nrow(full), nrow(diagnostics)), c(12,124,12))
check("result_keys", !anyDuplicated(belief[c("cell", "model")]) && !anyDuplicated(full[c("cell", "model", "term")]) &&
  !anyDuplicated(diagnostics[c("cell", "model")]))
full_belief <- full[full$term == "belief", names(belief)]; row.names(full_belief) <- NULL
check("belief_full_agreement", identical(belief, full_belief))
check("result_cell_model_order", identical(belief$cell, rep(cells$cell, each = 3L)) &&
  identical(belief$model, rep(c("S0", "S1", "S2"), 4L)) &&
  identical(diagnostics[c("cell", "model")], belief[c("cell", "model")]))
for (cell in cells$cell) for (model in c("S0", "S1", "S2")) {
  r <- full[full$cell == cell & full$model == model, ]
  check("full_term_order", identical(r$term, terms_for(model)) && identical(r$term_order, seq_len(nrow(r))), cell = cell, model = model)
}

# Presentation: round-trip-safe text, typed numeric readback and strict schemas.
csv_text <- function(x) {
  text <- x
  for (f in names(text)) {
    if (is.numeric(text[[f]])) text[[f]] <- sprintf("%.17g", text[[f]])
    else text[[f]] <- as.character(text[[f]])
    text[[f]][is.na(text[[f]])] <- "NA"
  }
  quote_cell <- function(s) paste0('"', gsub('"', '""', s, fixed = TRUE), '"')
  lines <- c(paste(quote_cell(names(text)), collapse = ","),
    vapply(seq_len(nrow(text)), function(i) paste(quote_cell(unlist(text[i, ], use.names = FALSE)), collapse = ","), ""))
  list(text = text, lines = unname(lines))
}
write_exclusive <- function(lines, p) {
  # wxb is the tested exclusive binary-create mode on this R/Windows runtime.
  stopifnot(p %in% dest, !file.exists(here::here(p)))
  con <- file(here::here(p), open = "wxb")
  tryCatch(writeBin(charToRaw(enc2utf8(paste0(paste(lines, collapse = "\n"), "\n"))), con),
    finally = close(con))
  created[[p]] <<- sha_file(p)
}
readback <- function(p, original, type, record = TRUE) {
  expected <- csv_text(original)$text
  back <- read.csv(here::here(p), colClasses = "character", check.names = FALSE, na.strings = NULL, fileEncoding = "UTF-8")
  stopifnot(identical(back, expected))
  typed <- back
  for (f in names(original)) {
    values <- back[[f]]; values[values == "NA"] <- NA_character_
    if (is.integer(original[[f]])) typed[[f]] <- as.integer(values)
    else if (is.double(original[[f]])) typed[[f]] <- as.numeric(values)
    # Explicit types and exact values; no approximate numeric comparison here.
    stopifnot(identical(typed[[f]], original[[f]]))
  }
  schema_guard(typed, type)
  if (record) check(paste0("exact_readback_", type), identical(typed, original), nrow(back), nrow(original),
    detail = "All fields, column types, exact numeric values, order and schema")
  typed
}
display <- function(v, signed = FALSE) {
  s <- sprintf(if (signed) "%+.6f" else "%.6f", v)
  small <- v != 0 & abs(v) < 0.0000005
  s[small] <- paste0(ifelse(v[small] > 0, "+", "-"), "<0.0000005 (nonzero; below displayed precision)")
  s[v == 0] <- "0.000000"
  s
}
make_report <- function(bt, dt) {
  report <- c("# Stage 15: descriptive Spring belief-assessment associations", "",
    "These are unweighted child-level cross-sectional sample linear projections linking native Fall belief scores and measurements to one Spring assessment per child within each grade-outcome cell. PPVT is primary; Applied Problems is secondary. This is implementation output awaiting code/output review, with no manuscript revision or publication.", "",
    "## Specifications and units", "",
    "S0: Y_i^S = alpha_0 + beta_0 B_i^F + u_i0.",
    "S1: Y_i^S = alpha_1 + beta_1 B_i^F + X_i' gamma_1 + u_i1.",
    "S2: Y_i^S = alpha_2 + beta_2 B_i^F + rho Y_i^F + X_i' gamma_2 + u_i2.", "",
    "Every belief slope is assessment standard-score points per one-unit higher native released belief score. These points are not outcome standard deviations. Native belief units are not authenticated as comparable across grades, so their slope magnitudes must not be compared as equivalent units. Polarity is not interpreted as progressive/traditional teaching.", "",
    "X contains F; five nonexclusive race indicators R_AA/R_AS/R_LT/R_NA/R_WH; three education indicators E_L/E_C/E_B; and three income indicators I_2/I_3/I_4. References are Male (CHGENP=1), No separately for each race field (code 0), HS diploma or equivalent (education code 3), and income <=$20,000 (codes 1-4). Education codes 1-2/4-6/7-9 and income codes 5-8/9-12/13-18 form the accepted contrasts. Education Other (code 10) is unobserved across the release; no extra exclusion or contrast is introduced.", "",
    "## Reconstructed common samples", "",
    "Each sample requires eligible finite same-outcome Fall and Spring scores, finite native Fall belief, and validated observed responses on all eight descriptor fields within the fixed 1,015-child universe. The same ascending-key ordered children enter S0-S2. Stage07 practice-failure exclusions remain seven Fall and one Spring Pre-K Applied Problems observations. No requirements involve another outcome or grade, four-occasion completeness, grouping codes or teacher changes.", "",
    "| Cell | Universe | Eligible Fall | Eligible Fall/Spring pair | Pair with finite Fall belief | Complete eight descriptors |",
    "|---|---:|---:|---:|---:|---:|")
  report <- c(report, vapply(cells$cell, function(cell) paste0("| ", cell, " | ", paste(selection[[cell]], collapse = " | "), " |"), ""))
  for (priority in c("primary", "secondary")) {
    report <- c(report, "", if (priority == "primary") "## PPVT (primary)" else "## Applied Problems (secondary)", "",
      "| Cell | Common N | S0 belief slope | S1 belief slope | S2 belief slope |",
      "|---|---:|---:|---:|---:|")
    for (cell in cells$cell[cells$priority == priority]) {
      r <- bt[bt$cell == cell, ]; slopes <- r$estimate
      report <- c(report, paste0("| ", cell, " | ", r$n[1], " | ", paste(display(slopes), collapse = " | "), " |"))
    }
    for (cell in cells$cell[cells$priority == priority]) {
      slopes <- bt$estimate[bt$cell == cell]
      differences <- c(slopes[2] - slopes[1], slopes[3] - slopes[2], slopes[3] - slopes[1])
      directions <- ifelse(differences == 0, "unchanged", ifelse(differences > 0, "more positive", "more negative"))
      report <- c(report, "", paste0(cell, ": S1 - S0 = ", display(differences[1], TRUE), " (", directions[1],
        "); S2 - S1 = ", display(differences[2], TRUE), " (", directions[2], "); S2 - S0 = ",
        display(differences[3], TRUE), " (", directions[3], "). Differences are calculated from full-precision estimates."))
    }
  }
  report <- c(report, "", "## In-sample fit summaries", "",
    "RSS is the residual sum of squares; TSS is centered on the Spring outcome mean; R-squared = 1 - RSS/TSS; RMSE = sqrt(RSS/N). RMSE is an in-sample residual summary. No uncertainty estimates or hypothesis tests are generated.", "",
    "| Cell | Model | N | Rank / columns | RSS | TSS | R-squared | RMSE |",
    "|---|---|---:|---:|---:|---:|---:|---:|")
  for (i in seq_len(nrow(dt))) {
    r <- dt[i, ]
    report <- c(report, paste0("| ", r$cell, " | ", r$model, " | ", r$n, " | ", r$rank, "/", r$n_columns,
      " | ", paste(display(c(r$rss, r$tss, r$r_squared, r$rmse)), collapse = " | "), " |"))
  }
  c(report, "", "## Interpretation and unresolved limitations", "",
    "S2 adjusts the Spring association for measured Fall performance and the accepted descriptors. It establishes neither causality, teacher value added, absolute skill growth, nor out-of-sample prediction validity. Covariate adjustment does not eliminate unmeasured heterogeneity or establish a temporal causal design. The three specifications were fixed before the coefficients were observed; no model is selected from its sign or size. Null and near-null values are retained.", "",
    "Measurement and direction: T_IDEAP/T_IDEAK are retained in native released units. Exact belief construction, substantive direction and cross-grade equivalence remain unresolved. Available shelved supplemental syntax has not been retrieved; no construction or direction is inferred from field names or coefficient signs.", "",
    "Exposure correspondence and timing: child-attached teacher reports do not establish a known teacher identity/exposure history. Correspondence of Fall belief reports to assessment exposure remains unresolved. Fall assessments are not authenticated pre-instruction baselines. Descriptors are Pre-K reports with unresolved reference timing, including in Kindergarten models.", "",
    "Selection and representation: these are unweighted descriptions of selected released children, not national or automatically design-representative estimates. English assessment availability and complete descriptor responses select the samples; missingness is not assumed ignorable. Stage14 documents differences between included/excluded children. These four paired Spring samples are smaller than the historical Fall samples. Between-stage differences cannot be attributed solely to time or adjustment; no numerical Stage12 comparison or additional Fall model is estimated.", "",
    "Dependence: no final clustering/inference procedure is chosen. Teacher, classroom, site/state dependence and encompassing independent units remain unresolved; recorded identifiers do not alone settle the sampling/dependence design. The absence of uncertainty output supports no claim about statistical significance or precision.", "",
    "Score metrics: assessment standard-score points are not outcome standard deviations or absolute skill growth. PPVT and Applied Problems remain separate, as do grades, languages and metrics. Belief scores are not harmonized. Historical Fall membership is not independently authenticated by old aggregate records; the four newly recomputed canonical signatures authenticate this stage's paired samples.", "",
    "## Computational provenance", "",
    "Both RDS SHA-256 hashes and all four canonical Stage14 membership signatures were freshly authenticated. Coding, aligned values, eligibility, actual samples, matrices, ranks and coefficients were recomputed in this execution. Earlier-stage verification ledgers and receipts are inherited evidence inspected without executing completed stages. Canonical membership hashing uses the accepted seven LF-terminated UTF-8/ASCII lines, sorted numeric STUDY_ID bits, both authenticated input hashes, cell and sample rule.", "",
    "Point estimation uses stats::lm.fit with tol=1e-7. All numerical agreement uses abs(a-b) <= 1e-10 * max(1,abs(a),abs(b)). Residual normal equations use 1e-10 * max(1,||z_j||_2*||y||_2). Nested RSS checks allow 1e-10 * max(1,TSS,RSS_previous,RSS_current). Tolerances were fixed before research coefficients. Complete coefficient vectors and aggregate diagnostics are exported at 17 significant digits with exact typed numeric readback. No identifiers, membership bits, working datasets, fitted values, residuals or model objects are exported.")
}
report <- unname(make_report(belief, diagnostics))
check("all_substantive_checks_before_writes", !any(file.exists(here::here(dest))) && all(vapply(checks, function(r) r$status == "pass", logical(1))))
preserved <- function() identical(before, tools::md5sum(here::here(protected))) && identical(protected, inventory_paths())
git_preserved <- function() identical(head_before, git(c("rev-parse", "HEAD"))) &&
  identical(branch_before, git(c("branch", "--show-current"))) && identical(index_before, git(c("ls-files", "--stage"))) &&
  identical(status_before, git(c("status", "--short", "--branch")))
check("inputs_unchanged_before_write", identical(wide_original, serialize(wide, NULL)) && identical(panel_original, serialize(panel, NULL)))
check("files_preserved_before_write", preserved(), length(protected))
check("git_preserved_before_write", git_preserved())

# Only now are any result destinations opened, always with exclusive creation.
write_exclusive(csv_text(belief)$lines, dest[1]); disk_belief <- readback(dest[1], belief, "belief")
write_exclusive(csv_text(full)$lines, dest[2]); disk_full <- readback(dest[2], full, "full")
write_exclusive(csv_text(diagnostics)$lines, dest[3]); disk_diagnostics <- readback(dest[3], diagnostics, "diagnostics")
disk_full_belief <- disk_full[disk_full$term == "belief", names(disk_belief)]; row.names(disk_full_belief) <- NULL
check("disk_belief_full_agreement", identical(disk_belief, disk_full_belief))
check("report_results_agreement", identical(report, unname(make_report(disk_belief, disk_diagnostics))))
write_exclusive(report, dest[4])
check("report_lines_readback", identical(report, readLines(here::here(dest[4]), encoding = "UTF-8", warn = FALSE)))
check("inputs_unchanged_after_write", identical(wide_original, serialize(wide, NULL)) && identical(panel_original, serialize(panel, NULL)))
check("files_preserved_after_write", preserved(), length(protected))
check("git_preserved_after_write", git_preserved())
check("outputs_ignored", all(vapply(dest, ignored, logical(1))))
check("working_whitespace", !length(git(c("diff", "--check"))))
check("cached_whitespace", !length(git(c("diff", "--cached", "--check"))))
ledger <- bind(checks); schema_guard(ledger, "checks")
write_exclusive(csv_text(ledger)$lines, dest[5])
# Final ledger readback is checked directly, avoiding a self-referential row count.
disk_ledger <- readback(dest[5], ledger, "checks", record = FALSE)
stopifnot(identical(ledger, disk_ledger), all(ledger$status == "pass"), !anyDuplicated(ledger$check_id))
note <- c("# Stage 15 verification and unresolved record", "",
  paste0("Execution-start UTC: ", start_time, ". Runtime: ", R.version.string, "; here ", packageVersion("here"), "; renv ", packageVersion("renv"), "."),
  paste0("Python hashlib executable: `", python, "`; ", py("import sys; print(sys.version.split()[0])"), ". No installation, restore or network acquisition."), "",
  "## Execution and result", "", "Exact fresh-session PowerShell command:", "```powershell",
  "$env:LC_ALL = 'English_United States.utf8'",
  "& 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/15_estimate_spring_associations.R", "```", "",
  paste0("Successful completion: exit 0; ", nrow(ledger), " unique passing ledger records; 12 belief rows, 124 full coefficient rows, 12 diagnostic rows. All 12 fits passed full rank, positive residual degrees of freedom, belief rank increment one, positive residual-belief SS, centered/FWL agreement, elementwise reconstruction and every residual normal equation. RSS was nonnegative, centered TSS positive, and nested RSS nonincreasing within fixed tolerances."), "",
  "Deterministic fixtures passed complete known S0/S1/S2 coefficient vectors including nonzero Fall-score adjustment, full term ordering, shuffled Spring alignment, duplicate/unmatched key rejection, invalid labels, nonfinite response/matrix rejection, rank-deficient matrix rejection, equal-N/different-membership rejection, signature order invariance and cell/rule/input binding. Export schema rejection explicitly rejects an added inferential column.", "",
  "All substantive checks completed before result destinations were opened. Writers rechecked absence and used the tested exclusive binary mode wxb. CSV numeric values use sprintf(%.17g), with explicit numeric/integer conversion and exact identical-value/type readback, plus complete schema/order/string equality. Belief rows match the full table exactly; diagnostic readback matches computed diagnostics exactly; the report is regenerated from readback objects and matches line by line. No child-level export or inferential output was generated.", "",
  "## Preservation and evidence boundaries", "",
  paste0("HEAD: ", head_before, "; branch: ", branch_before, ". Full execution-start index entries and Git status are recorded below and checked unchanged. ", length(protected), " execution-start files, including the new script, have unchanged MD5 inventory/hashes; both loaded RDS objects serialize identically at the end. The external pre-implementation SHA-256 baseline protects 378 pre-existing files and is audited by the caller against exactly seven additions (one script plus six ignored outputs). External audit success is reported separately after this note exists; it is not asserted by this runtime ledger."), "",
  "Git commands executed: rev-parse --show-toplevel; rev-parse HEAD; branch --show-current; status --short --branch; ls-files --stage; diff --cached --name-only; diff --check; diff --cached --check; check-ignore -q -- <each of six destinations>. Process-scoped safe.directory does not modify configuration. HEAD/branch/index/status were checked before and after writes; both whitespace checks were empty. No stage, commit, push or manuscript operation was performed.", "",
  "Fresh computation covers sample reconstruction, input hashes, all four membership signatures, actual aligned values/codes/matrices/ranks, point estimates and numerical verification. Historical Stage11-14 ledgers and the pinned Stage14 input receipts are inherited evidence inspected without rerunning their stages. They do not constitute a fresh end-to-end raw-data audit.", "",
  "## Accepted input continuity", "", "| Input | SHA-256 |", "|---|---|",
  vapply(receipts, function(r) paste0("| ", r[1], " | ", r[2], " |"), ""), "",
  "## Fresh membership authentication", "", "| Cell | N | Membership SHA-256 |", "|---|---:|---|",
  vapply(seq_len(nrow(cells)), function(i) paste0("| ", cells$cell[i], " | ", cells$n[i], " | ", cells$signature[i], " |"), ""), "",
  "## Artifact fingerprints", "", "| Path | SHA-256 |", "|---|---|",
  vapply(c(script_path, dest[1:5]), function(p) paste0("| ", p, " | ", sha_file(p), " |"), ""), "",
  "This note's own final SHA-256 is computed externally after writing. It cannot contain its own byte hash.", "",
  "## Development record and unresolved issues", "",
  "Before research execution, an isolated temporary-file writer test found that R open mode wbx was not recognized as a binary connection. The corrected wxb mode passed exclusive creation, exact binary write and rejection of an existing file. The first isolated test also emitted locale startup warnings; subsequent commands explicitly set the accepted LC_ALL. Neither test touched repository files or research data. Further development failures, if any, are retained in the external execution receipts and documented here before successful final execution.", "",
  "No new substantive coding or eligibility decision was made. Measurement construction/direction, cross-grade equivalence, exposure correspondence, Fall assessment/report timing, Pre-K descriptor timing, dependence/inference, representation, English-outcome/complete-case selection, score-metric and historical Fall membership limitations remain unresolved, as explained in the report. No computational failure remains if this execution completes successfully. Stage15 awaits code/output review and is not reviewed or published.", "",
  "## Execution-start and final Git status", "```", status_before, "```", "",
  "## Complete execution-start index (unchanged)", "```", index_before, "```", "",
  "## Execution-start protected inventory (MD5 before = after)", "", "| Relative path | MD5 |", "|---|---|",
  paste0("| ", protected, " | ", unname(before), " |"))
note <- unname(note)
write_exclusive(note, dest[6])
stopifnot(identical(note, readLines(here::here(dest[6]), encoding = "UTF-8", warn = FALSE)),
  preserved(), git_preserved(), identical(wide_original, serialize(wide, NULL)), identical(panel_original, serialize(panel, NULL)))
cat("Stage15 PASS:", nrow(ledger), "unique passing checks; 12/124/12 result rows;", length(protected), "protected files unchanged; six outputs read back.\n")
NULL
}, error = function(e) e)
if (inherits(failure, "error")) {
  # Failure evidence is aggregate-only and outside the repository. Withdraw a
  # completed destination only if its current hash still proves execution ownership.
  evidence <- tempfile("stage15_failure_", tmpdir = tempdir(), fileext = ".txt")
  writeLines(c("Stage15 FAILED; no successful-result claim", conditionMessage(failure),
    vapply(checks, function(r) paste(r$check_id, r$status, r$observed, r$expected, sep = " | "), "")), evidence)
  for (p in names(created)) if (file.exists(here::here(p)) && identical(sha_file(p), created[[p]])) unlink(here::here(p))
  stop("Stage15 failed: ", conditionMessage(failure), "; aggregate failure evidence: ", evidence)
}
