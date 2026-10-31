# Stage 14: Spring sample readiness and descriptives. No outcome regressions.
# Fresh session from project root:
# $env:LC_ALL = 'English_United States.utf8'
# & 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/14_assess_spring_sample_readiness.R
# Requires existing Python (standard-library hashlib only); installs nothing.
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
stopifnot(head_before == "dcbef14f9bcc02ce49b0df6582ec7a9a18e68e8a",
  branch_before == "codex/restructure-project-layout", !length(git(c("diff", "--cached", "--name-only"))))
Sys.setenv(RENV_PATHS_ROOT = file.path(project_start, "renv", "local"),
  RENV_CONFIG_SANDBOX_ENABLED = "FALSE", RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
source(file.path(project_start, "renv", "activate.R"))
suppressPackageStartupMessages(library(here))
stopifnot(identical(normalizePath(here::here(), winslash = "/"), project_start))
options(stringsAsFactors = FALSE, OutDec = ".", digits = 17, warn = 2)
script_path <- "code/revision/14_assess_spring_sample_readiness.R"
dest <- c("output/tables/stage14_sample_support.csv", "output/tables/stage14_sample_descriptives.csv",
  "output/reports/stage14_spring_sample_readiness.md", "output/verification/stage14_checks.csv",
  "output/verification/stage14_verification_unresolved.md")
stopifnot(!any(file.exists(here::here(dest))), all(dir.exists(here::here(dirname(dest)))))
ignored <- function(p) identical(system2("git", c("-c", shQuote(paste0("safe.directory=", project_start)),
  "check-ignore", "-q", "--", shQuote(p))), 0L)
stopifnot(all(vapply(dest, ignored, logical(1))))
inventory_paths <- function() {
  p <- list.files(project_start, recursive = TRUE, all.files = TRUE, include.dirs = FALSE)
  sort(setdiff(p[!grepl("^\\.git/", p)], dest))
}
protected <- inventory_paths(); before <- tools::md5sum(here::here(protected))
start_time <- format(Sys.time(), tz = "UTC", usetz = TRUE)
python <- Sys.getenv("STAGE14_PYTHON", Sys.which("python"))
stopifnot(nzchar(python), file.exists(python))
py <- function(code) {
  z <- system2(python, c("-X", "utf8", "-c", shQuote(code)), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("Python hashlib helper failed: ", paste(z, collapse = "\n"))
  z
}
# Text is ASCII, a subset of UTF-8. Hex argument transports bytes in memory only.
# Neither identifiers nor membership vectors are written to disk, even temporarily.
sha_text <- function(s) {
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
pct <- function(n, d) if (d == 0) NA_real_ else 100 * n/d
checks <- list(); support <- list(); descriptives <- list(); decisions <- list()
check <- function(id, ok, observed = "", expected = "TRUE", cell = "all", model = "", tolerance = NA_real_, detail = "") {
  key <- paste(cell, model, id, sep = ":")
  stopifnot(!key %in% vapply(checks, `[[`, "", "check_id"))
  checks[[length(checks) + 1L]] <<- data.frame(check_id = key, cell = cell, model = model,
    status = if (isTRUE(ok)) "pass" else "fail", observed = paste(observed, collapse = ";"),
    expected = paste(expected, collapse = ";"), tolerance = tolerance, detail = detail)
  if (!isTRUE(ok)) stop("Stage14 unexpected failure requiring resolution: ", key, "; ", detail)
}
srow <- function(cell, section, field, category = "", n = NA_real_, denominator = NA_real_,
  value = NA_real_, text = "", model = "", group = "", statistic = "", status = "supported", detail = "",
  starting_n = NA_real_, newly_excluded_n = NA_real_, remaining_n = NA_real_, pct_previous = NA_real_, pct_universe = NA_real_) {
  support[[length(support) + 1L]] <<- data.frame(cell, section, group, model, field, category, statistic,
    n = as.double(n), denominator = as.double(denominator), value = as.double(value), text, status, detail,
    starting_n = as.double(starting_n), newly_excluded_n = as.double(newly_excluded_n), remaining_n = as.double(remaining_n),
    pct_previous = as.double(pct_previous), pct_universe = as.double(pct_universe))
}
drow <- function(cell, section, group, field, category = "", statistic = "", n = NA_real_, denominator = NA_real_,
  value = NA_real_, group_n, observed_n, status = "supported", detail = "") {
  descriptives[[length(descriptives) + 1L]] <<- data.frame(cell, section, group, field, category, statistic,
    n = as.double(n), denominator = as.double(denominator), value = as.double(value), group_n = as.double(group_n),
    observed_n = as.double(observed_n), status, detail)
}
wide_path <- "Data/processed/verified_child_wide.rds"; panel_path <- "Data/processed/outcome_cleaning_panel.rds"
required <- c(wide_path, panel_path, "output/tables/verified_wide_provenance.csv",
  "output/tables/structural_panel_provenance.csv", "output/tables/stage08_characteristic_inventory.csv",
  "output/tables/stage08_belief_outcome_support.csv", "output/tables/outcome_cleaning_rules.csv",
  "docs/icpsr/DS0001/04283-0001-Setup.do", "docs/icpsr/DS0001/04283-0001-Setup.dct")
historical <- readLines(here::here("output/verification/stage11_verification_unresolved.md"), warn = FALSE)
for (j in seq_along(required)) {
  line <- historical[startsWith(historical, paste0("| ", required[j], " | "))]
  h <- if (length(line) == 1L) trimws(strsplit(line, "|", fixed = TRUE)[[1]][3]) else "absent"
  check(paste0("accepted_input_md5_", j), identical(unname(tools::md5sum(here::here(required[j]))), h),
    observed = unname(tools::md5sum(here::here(required[j]))), expected = h, detail = required[j])
}
pins <- c("output/tables/stage11_sample_support.csv" = "cd81d3d113aaefe1de7d0713ce26b1ea5014258f85a50e05b4006bd670172026",
  "output/tables/stage12_fall_belief_coefficients.csv" = "445576ab6f472ca66f5f2af975372b48978b4493f281ed7bad8383c3ed1e9b96",
  "output/reports/stage11_analysis_specification.md" = "6e0ea47933952cf4af5d693161f6d368a4f2e3ec97a9a4331b7c5b48d410c43f",
  "output/reports/stage12_fall_associations.md" = "ec5f39e80d51eeb053db5a1c8de2f38b44626a4757888cfcee9bbb408f3266b0")
for (j in seq_along(pins)) check(paste0("accepted_history_sha_", j), identical(sha_file(names(pins)[j]), unname(pins[j])), detail = names(pins)[j])
wide_sha <- sha_file(wide_path); panel_sha <- sha_file(panel_path)
check("accepted_wide_sha", wide_sha == "a4b4a9d662093345ea65badd51e47ac08d73e3e8eebd4dec211bbe3523be2952", wide_sha)
check("accepted_panel_sha", panel_sha == "647d516b29abf647f6545caae662354752650d0596093ddc16277b2618486cf7", panel_sha)
check("hash_known_answer", sha_text("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
for (stage in 7:13) {
  path <- if (stage == 7) "output/verification/outcome_cleaning_checks.csv" else if (stage == 8)
    "output/verification/stage08_checks.csv" else if (stage == 9) "output/verification/stage09_checks.csv" else if (stage == 10)
    "output/tables/stage10_claim_verification.csv" else paste0("output/verification/stage", stage, "_checks.csv")
  x <- read_csv(path)
  # Stage10 is documentary evidence, with its own status vocabulary, not a computation ledger.
  if (stage != 10) check(paste0("recorded_checks_stage", stage), nrow(x) > 0L && all(x$status == "pass"), nrow(x), detail = "Recorded evidence only; no upstream execution")
}
wide <- readRDS(here::here(wide_path)); panel <- readRDS(here::here(panel_path))
wide_original <- serialize(wide, NULL); panel_original <- serialize(panel, NULL)
check("dimensions", nrow(wide) == 1015L && nrow(panel) == 4060L)
prov <- read_csv(required[3]); panel_prov <- read_csv(required[4]); characteristic_inventory <- read_csv(required[5])
support08 <- read_csv(required[6]); rules <- read_csv(required[7])
counts07 <- read_csv("output/tables/outcome_cleaning_counts.csv")
pairs07 <- read_csv("output/tables/outcome_cleaning_pair_support.csv")
pairs08 <- read_csv("output/tables/stage08_pair_characteristics.csv")
support11 <- read_csv("output/tables/stage11_sample_support.csv")
# Read only sample metadata; historical coefficient values are never used or recomputed.
metadata12 <- read_csv("output/tables/stage12_fall_belief_coefficients.csv")[c("cell", "model", "n", "sample_rule_id")]
setup <- readLines(here::here(required[8]), warn = FALSE); dictionary <- readLines(here::here(required[9]), warn = FALSE)

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
  for (j in seq_along(expected[[f]])) srow("all", "descriptor_mapping", f, names(expected[[f]])[j],
    n = sum(codes[[f]] == as.integer(names(expected[[f]]))[j], na.rm = TRUE), denominator = 1015,
    text = expected[[f]][j], detail = paste0("Setup.do lines ", first, "-", last, "; ", inv$documentary_locators))
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
compact_map <- lapply(expected, unname)
compact_map$CHMATEDCP <- c(rep("Below HS", 2), "HS", rep("College/technical/associate without BA", 3), rep("BA+", 3), "Other")
compact_map$CHINCOMCP <- rep(c("<=20000", "20001-40000", "40001-60000", ">60000"), c(4,4,4,6))
compact <- lapply(covars, function(f) factor(compact_map[[f]][match(codes[[f]], as.integer(names(expected[[f]])))],
  levels = unique(compact_map[[f]]))); names(compact) <- covars
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
    grepl(gsub("[[:space:]]+", " ", pr$raw_label), gsub("[[:space:]]+", " ", dictionary[di]), fixed = TRUE) &&
    same(panel[[out]][wave_rows[[w]]], wide[[src]]),
    detail = paste0(paste(pp$source_page_or_section, collapse = ";"),
      "; dictionary/provenance label whitespace normalized only (WJ10_SSEPS has STAND  SCORE versus STAND SCORE); source names and values exact"))
}
score_state <- function(e, reason, raw) {
  if (!is.logical(e) || length(e) != length(raw) || length(reason) != length(e) || anyNA(reason)) stop("Invalid score state fields")
  state <- ifelse(is.na(e), "unknown_eligibility", ifelse(e, "eligible", reason))
  nf <- !is.na(raw) & !is.finite(raw)
  state[nf] <- paste0(state[nf], ":observed_nonfinite")
  state
}
summary_numeric <- function(v) {
  z <- v[is.finite(v)]
  c(n_usable = length(z), n_distinct = length(unique(z)), mean = if (length(z)) mean(z) else NA_real_,
    sd = if (length(z) > 1L) sd(z) else NA_real_, min = if (length(z)) min(z) else NA_real_, max = if (length(z)) max(z) else NA_real_)
}
qr_tol <- 1e-7
matrix_audit <- function(z) {
  if (!is.matrix(z) || any(!is.finite(z)) || !"belief" %in% colnames(z)) stop("Invalid predictor matrix")
  a <- z[, colnames(z) != "belief", drop = FALSE]
  r <- if (nrow(z)) qr(z, tol = qr_tol)$rank else 0L
  ra <- if (nrow(a)) qr(a, tol = qr_tol)$rank else 0L
  # Only belief is residualized. Spring outcome is never an argument to this helper.
  residual_ss <- if (!nrow(z)) NA_real_ else sum(qr.resid(qr(a, tol = qr_tol), z[, "belief"])^2)
  list(n = nrow(z), columns = ncol(z), rank = r, rank_without_belief = ra, belief_increment = r - ra,
    residual_belief_ss = residual_ss, n_minus_rank = nrow(z) - r,
    status = if (!nrow(z)) "undefined_empty_sample" else if (r < ncol(z) || r - ra != 1L || nrow(z) <= ncol(z))
      "requires_specification_review" else "computationally_ready")
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
failure_patterns <- function(states) apply(states, 1L, function(s) {
  bad <- s != "eligible"; if (any(bad)) paste(paste0(names(s)[bad], "=", s[bad]), collapse = ";") else "none"
})
failed <- function(expr) inherits(tryCatch({ force(expr); NULL }, error = function(e) e), "error")
# Focused synthetic fixtures exercise the production guards, without research values.
fp <- data.frame(STUDY_ID = c(1,2,3,1,2,3), wave = rep(c("PF", "PS"), each = 3), value = c(10,20,30,11,21,31))
shuffled <- fp[c(6,2,4,1,5,3), ]
check("fixture_shuffled_spring", identical(shuffled$value[align_wave(1:3, shuffled, "PS")], c(11,21,31)))
check("fixture_duplicate_keys", failed(align_wave(1:3, rbind(fp, fp[1, ]), "PS")))
bad <- fp; bad$STUDY_ID[6] <- 4
check("fixture_unmatched_keys", failed(align_wave(1:3, bad, "PS")))
check("fixture_unknown_eligibility", identical(score_state(c(TRUE,FALSE,NA), c("retained_under_current_rules", "source_missing_reason_unavailable", "unresolved_score_value"), c(2,NA,Inf)),
  c("eligible", "source_missing_reason_unavailable", "unknown_eligibility:observed_nonfinite")))
st <- cbind(a = c("eligible", "source_missing", "source_missing"), b = c("eligible", "eligible", "source_missing"))
check("fixture_overlapping_exclusions", sum(rowSums(st != "eligible") > 0) == 2L && sum(st != "eligible") == 3L && sum(table(failure_patterns(st))) == 3L)
check("fixture_empty_singleton", is.na(summary_numeric(numeric())["mean"]) && is.na(summary_numeric(2)["sd"]) && is.na(pct(0,0)))
check("fixture_collinear_belief", matrix_audit(cbind(Intercept = 1, belief = c(0,1,0,1), x = c(0,1,0,1)))$belief_increment == 0L)
check("fixture_collinear_fall_score", matrix_audit(cbind(Intercept = 1, belief = 1:4, fall_score = 2*(1:4)))$rank == 2L)
check("fixture_absent_category", matrix_audit(cbind(Intercept = 1, belief = 1:4, absent = rep(0,4)))$status == "requires_specification_review")
check("fixture_empty_matrix", matrix_audit(matrix(numeric(), 0, 2, dimnames = list(NULL,c("Intercept","belief"))))$status == "undefined_empty_sample")
check("fixture_equal_n_different_membership", signature("fixture", c(TRUE,FALSE), 1:2) != signature("fixture", c(FALSE,TRUE), 1:2))
check("fixture_signature_order", signature("fixture", c(TRUE,FALSE), 1:2) == signature("fixture", c(FALSE,TRUE), 2:1))
check("fixture_signature_binding", length(unique(c(signature("fixture", c(TRUE,FALSE), 1:2),
  signature("fixture2", c(TRUE,FALSE), 1:2), signature("fixture", c(TRUE,FALSE), 1:2, rule = "v2"),
  signature("fixture", c(TRUE,FALSE), 1:2, wide_hash = paste(rep("0",64),collapse="")),
  signature("fixture", c(TRUE,FALSE), 1:2, panel_hash = paste(rep("0",64),collapse=""))))) == 5L)
check("fixture_bad_descriptor_label", failed(decode(factor("Other"), "CHGENP")))

cells <- data.frame(cell = c("PF_PPVT", "KF_PPVT", "PF_Applied_Problems", "KF_Applied_Problems"),
  grade = rep(c("Pre-K", "Kindergarten"), 2), fall = rep(c("PF", "KF"), 2), spring = rep(c("PS", "KS"), 2),
  outcome = rep(c("ppvt_english_standard_score", "applied_problems_english_standard_score"), each = 2),
  fall_src = c("PPVTEPF", "PPVTEKF", "WJ10_SSEPF", "WJ10_SSEKF"), spring_src = c("PPVTEPS", "PPVTEKS", "WJ10_SSEPS", "WJ10_SSEKS"),
  eligible_fall = c(805,811,790,831), eligible_spring = c(855,838,850,859), eligible_pair = c(750,796,734,815),
  pair_belief = c(737,742,721,756), historical_n = c(730,700,717,713))
for (ci in seq_len(nrow(cells))) {
  c <- cells[ci, ]; cell <- c$cell
  ck <- function(id, ok, observed = "", expected = "TRUE", model = "", detail = "", tolerance = NA_real_)
    check(id, ok, observed, expected, cell, model, tolerance, detail)
  fi <- wave_rows[[c$fall]]; si <- wave_rows[[c$spring]]; o <- c$outcome
  bf <- if (c$fall == "PF") "teacher_modernity_pre_k_fall_released" else "teacher_modernity_kindergarten_fall_released"
  bs <- if (c$fall == "PF") "T_IDEAP" else "T_IDEAK"
  validate_lineage(bf, bs, c$fall, ck)
  b <- panel[[bf]][fi]
  ck("belief_finite_or_missing", all(is.na(b) | is.finite(b)), detail = "Observed nonfinite belief is an unexpected failure, never an added exclusion")
  scores <- list()
  for (season in c("fall", "spring")) {
    w <- c[[season]]; rows <- wave_rows[[w]]; src <- c[[paste0(season, "_src")]]
    validate_lineage(o, src, w, ck)
    e <- panel[[paste0(o, "_eligible_current_rules")]][rows]
    y <- panel[[paste0(o, "_clean")]][rows]; reason <- panel[[paste0(o, "_cleaning_reason")]][rows]; raw <- wide[[src]]
    rr <- rules[rules$outcome == o & rules$wave == w, ]; ac <- counts07[counts07$outcome == o & counts07$wave == w, ]
    ck(paste0("rule_source_", w), nrow(rr) > 0L && all(rr$source_variable == src) && nrow(ac) == 1L)
    ck(paste0("eligible_values_", w), is.logical(e) && all(!e %in% TRUE | is.finite(y)) && same(y[e %in% TRUE], raw[e %in% TRUE]))
    state <- score_state(e, reason, raw)
    ck(paste0("accepted_reasons_", w), all(reason %in% c("retained_under_current_rules", "source_missing_reason_unavailable", "practice_failure_project_exclusion")) &&
      identical(e %in% TRUE, reason == "retained_under_current_rules") &&
      identical(is.na(raw), reason == "source_missing_reason_unavailable") &&
      all(is.na(y[!e %in% TRUE])), detail = "Unexpected reason or unknown eligibility pauses this cell; no heuristic exclusion")
    ck(paste0("no_unknown_nonfinite_", w), !anyNA(e) && !any(!is.na(raw) & !is.finite(raw)), detail = "Unknown and nonfinite states remain separately reportable, never silently recoded")
    ck(paste0("stage07_counts_", w), sum(e %in% TRUE) == ac$n_eligible_current_rules && sum(is.na(raw)) == ac$n_source_missing &&
      sum(reason == "practice_failure_project_exclusion") == ac$n_practice_failure_project_excluded &&
      sum(e %in% TRUE) == c[[paste0("eligible_", season)]])
    if (src %in% c("WJ10_SSEPF", "WJ10_SSEPS")) ck(paste0("practice_exclusion_", w),
      any(rr$rule_id == "practice_failure" & rr$rule_value == -7 & rr$action == "clean_NA_eligible_FALSE", na.rm = TRUE) &&
      identical(reason == "practice_failure_project_exclusion", !is.na(raw) & raw == -7))
    states <- c("eligible", "source_missing_reason_unavailable", "practice_failure_project_exclusion", "documented_source_special",
      "documented_invalid_above_max", "unknown_eligibility", "unknown_eligibility:observed_nonfinite")
    for (s in states) srow(cell, "score_state", season, s, sum(state == s), 1015,
      detail = "Mutually exclusive eligibility/reason states; zero states retained")
    srow(cell, "score_state_overlap", season, "observed_nonfinite", sum(!is.na(raw) & !is.finite(raw)), 1015,
      detail = "Overlapping diagnostic; not an additional sample exclusion")
    scores[[season]] <- list(e = e, y = y, reason = reason, raw = raw, state = state)
  }
  ef <- scores$fall$e %in% TRUE; es <- scores$spring$e %in% TRUE; pair <- ef & es
  ac <- pairs07[pairs07$outcome == o & pairs07$grade == c$grade, ]
  ck("stage07_pair", nrow(ac) == 1L && sum(pair) == ac$n_eligible_both && sum(pair) == c$eligible_pair)
  for (period in c("fall", "spring", "both")) {
    use <- switch(period, fall = ef, spring = es, both = pair)
    ac <- support08[support08$outcome == o & support08$grade == c$grade & support08$outcome_period == period, ]
    ck(paste0("stage08_overlap_", period), nrow(ac) == 1L && sum(use & is.finite(b)) == ac$n_overlap)
  }
  ck("accepted_pair_belief", sum(pair & is.finite(b)) == c$pair_belief)
  complete <- complete.cases(codes)
  fall_mask <- ef & is.finite(b) & complete
  mask <- pair & is.finite(b) & complete
  ck("spring_bridge_identity", identical(mask, fall_mask & es))
  base_fall <- ef & is.finite(b)
  reconcile11 <- function(section, field, category, n, denominator) {
    r <- support11[support11$cell == cell & support11$section == section & support11$field == field & support11$category == category, ]
    ck(paste("stage11",section,field,category,sep="_"), nrow(r) == 1L && r$n == n && r$denominator == denominator, n, if (nrow(r)==1L) r$n else "missing")
  }
  reconcile11("support", "sample", "candidate_common_M0_M1", sum(fall_mask), sum(base_fall))
  ck("historical_metadata_n", sum(fall_mask) == c$historical_n && all(metadata12$n[metadata12$cell == cell] == sum(fall_mask)) &&
    sum(metadata12$cell == cell) == 2L)
  current <- base_fall
  for (f in covars) {
    reconcile11("sequential_loss", f, "newly_excluded", sum(current & is.na(codes[[f]])), sum(current))
    reconcile11("overlapping_loss", f, "missing_in_ceiling", sum(base_fall & is.na(codes[[f]])), sum(base_fall))
    current <- current & !is.na(codes[[f]])
    reconcile11("sequential_retained", f, "remaining", sum(current), sum(base_fall))
  }
  pat11 <- apply(is.na(codes[base_fall, , drop = FALSE]), 1, function(v) if (any(v)) paste(covars[v], collapse = "+") else "none")
  ck("stage11_pattern_categories", setequal(unique(pat11), support11$category[support11$cell == cell & support11$section == "missingness_partition"]))
  for (p in unique(pat11)) reconcile11("missingness_partition", "covariates", p, sum(pat11 == p), sum(base_fall))
  for (f in covars) for (lev in c(levels(wide[[f]]), "<missing>")) {
    hit <- if (lev == "<missing>") is.na(wide[[f]]) else !is.na(wide[[f]]) & as.character(wide[[f]]) == lev
    for (part in c("retained", "excluded_covariates", "excluded_from_release")) {
      use <- switch(part, retained = fall_mask, excluded_covariates = base_fall & !complete, excluded_from_release = !fall_mask)
      reconcile11(paste0("composition_", part), f, lev, sum(use & hit), sum(use))
    }
    for (part in c("complete_pair", "incomplete_pair")) {
      use <- if (part == "complete_pair") pair else !pair
      r <- pairs08[pairs08$outcome == o & pairs08$grade == c$grade & pairs08$characteristic == f & pairs08$group == part &
        if (lev == "<missing>") pairs08$category_kind == "source_missing" else pairs08$category_label == lev, ]
      ck(paste("stage08_composition", f, lev, part, sep="_"), nrow(r) == 1L && r$n_children == sum(use & hit) &&
        r$denominator_group == sum(use) && r$denominator_characteristic_nonmissing == sum(use & !is.na(wide[[f]])))
    }
  }
  states <- cbind(fall_score = scores$fall$state, spring_score = scores$spring$state,
    fall_belief = ifelse(is.na(b), "source_missing", ifelse(is.finite(b), "eligible", "observed_nonfinite")))
  for (f in covars) states <- cbind(states, ifelse(is.na(codes[[f]]), "source_missing", "eligible"))
  colnames(states) <- c("fall_score", "spring_score", "fall_belief", covars)
  current <- rep(TRUE, 1015); losses <- numeric(ncol(states))
  srow(cell, "sequential_flow", "universe", n = 1015, denominator = 1015, starting_n = 1015,
    newly_excluded_n = 0, remaining_n = 1015, pct_previous = 100, pct_universe = 100)
  for (j in seq_len(ncol(states))) {
    prev <- sum(current); ok <- states[,j] == "eligible"; lost <- sum(current & !ok); current <- current & ok; losses[j] <- lost
    srow(cell, "sequential_flow", colnames(states)[j], n = sum(current), denominator = prev,
      starting_n = prev, newly_excluded_n = lost, remaining_n = sum(current), pct_previous = pct(sum(current),prev), pct_universe = pct(sum(current),1015))
    srow(cell, "marginal_failures", colnames(states)[j], "all_failures", sum(!ok), 1015, value = pct(sum(!ok),1015), detail = "Overlapping; never sum marginal failures")
    for (st in sort(setdiff(unique(states[,j]), "eligible"))) srow(cell, "marginal_failure_reasons", colnames(states)[j], st,
      sum(states[,j] == st), 1015, value = pct(sum(states[,j] == st),1015))
  }
  patterns <- failure_patterns(states)
  ck("pattern_partition", sum(table(patterns)) == 1015L && sum(patterns == "none") == sum(mask) &&
    identical(current, mask) && sum(losses) + sum(mask) == 1015L)
  for (p in sort(unique(patterns))) srow(cell, "failure_patterns", "all_requirements", p, sum(patterns == p), 1015,
    value = pct(sum(patterns == p),1015), detail = "Mutually exclusive joint failure states, not individual memberships")
  for (gr in c("reconstructed_fall_common", "spring_retained", "spring_excluded")) {
    use <- switch(gr, reconstructed_fall_common = fall_mask, spring_retained = mask, spring_excluded = fall_mask & !es)
    srow(cell, "fall_bridge", "sample", gr, sum(use), sum(fall_mask), value = pct(sum(use),sum(fall_mask)))
  }
  sig <- signature(cell, mask, wide$STUDY_ID)
  for (f in c("sample_rule_id", "wide_sha256", "panel_sha256", "membership_sha256")) srow(cell, "membership_signature", f,
    n = sum(mask), denominator = 1015, text = switch(f, sample_rule_id = rule_id, wide_sha256 = wide_sha, panel_sha256 = panel_sha, membership_sha256 = sig))
  rows <- ordering[mask[ordering]]; audits <- list()
  for (model in c("S0", "S1", "S2")) {
    # Independently reselect and order the same children for each candidate; no automatic NA omission.
    model_rows <- which(ef & es & is.finite(b) & complete.cases(codes)); model_rows <- model_rows[order(wide$STUDY_ID[model_rows], method="radix")]
    ck("identical_ordered_membership", identical(wide$STUDY_ID[rows], wide$STUDY_ID[model_rows]), model = model)
    z <- cbind(Intercept = rep(1, length(rows)), belief = b[rows])
    if (model == "S2") z <- cbind(z, fall_score = scores$fall$y[rows])
    if (model != "S0") z <- cbind(z, X[rows, , drop = FALSE])
    a <- matrix_audit(z); audits[[model]] <- a
    ck("declared_columns", a$columns == c(S0=2L,S1=14L,S2=15L)[model], a$columns, c(S0=2L,S1=14L,S2=15L)[model], model = model)
    for (metric in setdiff(names(a), "status")) srow(cell, "matrix_diagnostics", metric, model = model,
      n = length(rows), denominator = 1015, value = a[[metric]], status = a$status, detail = "Predictor-only QR; tolerance=1e-7; no term removed")
    srow(cell, "matrix_diagnostics", "column_names", text = paste(colnames(z), collapse = ";"), model = model, status = a$status)
    for (f in colnames(z)) for (stat in names(summary_numeric(z[,f]))) srow(cell, "predictor_support", f,
      statistic = stat, value = summary_numeric(z[,f])[[stat]], model = model, n = length(rows), denominator = length(rows))
  }
  groups <- list(universe = rep(TRUE,1015), included = mask, excluded = !mask,
    spring_retained = mask, spring_excluded = fall_mask & !es)
  for (gr in names(groups)) {
    use <- groups[[gr]]; gn <- sum(use)
    for (f in c("fall_score", "spring_score", "fall_belief")) {
      if (f == "fall_belief") {
        v <- b; eligible <- is.finite(b); missing <- is.na(b); ineligible <- rep(FALSE,1015); unknown <- rep(FALSE,1015); raw <- b
      } else {
        sc <- scores[[if (f == "fall_score") "fall" else "spring"]]
        v <- sc$y; eligible <- sc$e %in% TRUE; missing <- sc$reason == "source_missing_reason_unavailable"
        unknown <- is.na(sc$e); ineligible <- !eligible & !missing & !unknown; raw <- sc$raw
      }
      valid <- use & eligible & is.finite(v); vsummary <- summary_numeric(v[valid]); usable <- sum(valid)
      count_metrics <- c(group_n = gn, n_usable = usable, source_missing_n = sum(use & missing), documented_exclusion_n = sum(use & ineligible),
        unknown_eligibility_n = sum(use & unknown), observed_nonfinite_n = sum(use & !is.na(raw) & !is.finite(raw)))
      ck(paste("continuous_partition",gr,f,sep="_"), usable + sum(use & missing) + sum(use & ineligible) + sum(use & unknown) == gn)
      for (metric in names(count_metrics)) drow(cell, "continuous", gr, f, statistic = metric, n = count_metrics[[metric]],
        denominator = gn, group_n = gn, observed_n = usable, detail = "Observed nonfinite is an overlapping diagnostic; only eligible finite scores summarized")
      for (stat in setdiff(names(vsummary), "n_usable")) drow(cell, "continuous", gr, f, statistic = stat,
        value = vsummary[[stat]], denominator = usable, group_n = gn, observed_n = usable,
        status = if (!usable) "undefined_empty" else if (usable == 1L && stat == "sd") "undefined_singleton" else "supported")
    }
    for (f in covars) {
      obs <- sum(use & !is.na(compact[[f]])); ct <- numeric()
      for (lev in c(levels(compact[[f]]), "<missing>")) {
        hit <- if (lev == "<missing>") is.na(compact[[f]]) else !is.na(compact[[f]]) & compact[[f]] == lev
        n <- sum(use & hit); den <- if (lev == "<missing>") gn else obs; ct <- c(ct,n)
        drow(cell, "descriptors", gr, f, lev, "count_percent", n, den, pct(n,den), gn, obs,
          status = if (!den) "undefined_denominator" else if (!n) "absent_category" else if (n < 5L) "sparse_count_below_5_display_flag" else "supported",
          detail = "Observed-category denominator excludes missing; missing denominator is full group. Race indicators nonexclusive; Pre-K reports also used for Kindergarten. Sparse <5 is a display flag, never a sample rule.")
      }
      ck(paste("descriptor_partition",gr,f,sep="_"), sum(ct) == gn && sum(ct[-length(ct)]) == obs)
    }
  }
  spring_summary <- summary_numeric(scores$spring$y[mask]); fall_summary <- summary_numeric(scores$fall$y[mask])
  absent <- unlist(lapply(covars, function(f) {
    lev <- levels(compact[[f]]); lev <- setdiff(lev, if (f == "CHMATEDCP") "Other" else character())
    missing_levels <- lev[vapply(lev,function(l) !any(compact[[f]][mask] == l),logical(1))]
    if (length(missing_levels)) paste0(f, "=", missing_levels) else character()
  }), use.names = FALSE)
  # Other is retained descriptively but deliberately outside the accepted predictor coding.
  status <- if (!sum(mask)) "undefined_empty_sample" else if (any(vapply(audits,function(a) a$status != "computationally_ready",logical(1))) ||
    fall_summary[["n_distinct"]] < 2L || length(absent)) "requires_specification_review" else if (spring_summary[["n_distinct"]] < 2L)
      "requires_outcome_variation_review" else "computationally_ready"
  srow(cell, "readiness", "cell", n = sum(mask), denominator = 1015, text = status, status = status,
    detail = paste0("Absent modeled categories: ", if (length(absent)) paste(absent,collapse=";") else "none", "; zero-frequency descriptive Other is not a modeled term"))
  srow(cell, "readiness", "spring_distinct_values", value = spring_summary[["n_distinct"]], n = sum(mask), status = status)
  decisions[[cell]] <- list(n = sum(mask), lost = 1015 - sum(mask), fall_n = sum(fall_mask), bridge_lost = sum(fall_mask & !es),
    losses = losses, audits = audits, signature = sig, status = status)
}

# All computations above finish before any destination is opened. Existing outputs are never replaced.
check("source_objects_unchanged", identical(wide_original, serialize(wide,NULL)) && identical(panel_original, serialize(panel,NULL)))
check("protected_before_publication", identical(before, tools::md5sum(here::here(protected))) && identical(protected, inventory_paths()), length(protected))
check("git_before_publication", identical(head_before,git(c("rev-parse","HEAD"))) && identical(index_before,git(c("ls-files","--stage"))) &&
  identical(branch_before,git(c("branch","--show-current"))) && identical(status_before,git(c("status","--short","--branch"))))
check("whitespace_worktree", !length(git(c("diff","--check"))))
check("whitespace_index", !length(git(c("diff","--cached","--check"))))
so <- bind(support); de <- bind(descriptives)
check("aggregate_schema", !any(c("STUDY_ID","child_id","membership_vector") %in% c(names(so),names(de))))
write_csv <- function(x,p) {
  stopifnot(!file.exists(here::here(p)))
  encode <- function(z) if (is.character(z)) ifelse(is.na(z),"NA",paste0('"',gsub('"','""',z,fixed=TRUE),'"')) else
    ifelse(is.na(z),"NA",sprintf("%.17g",z))
  columns <- lapply(x,encode)
  lines <- c(paste(encode(names(x)),collapse=","), vapply(seq_len(nrow(x)),function(i) paste(vapply(columns,`[`,"",i),collapse=","),""))
  con <- file(here::here(p),"wb"); writeBin(charToRaw(paste0(paste(lines,collapse="\n"),"\n")),con); close(con)
  y <- read.csv(here::here(p), colClasses="character", na.strings=character(), check.names=FALSE)
  stopifnot(identical(names(x),names(y)), nrow(x)==nrow(y))
  for (f in names(x)) if (is.character(x[[f]])) stopifnot(identical(ifelse(is.na(x[[f]]),"NA",x[[f]]), y[[f]])) else {
    b <- suppressWarnings(as.double(y[[f]])); a <- as.double(x[[f]])
    stopifnot(identical(is.na(a),is.na(b)), identical(a[!is.na(a)],b[!is.na(b)]))
  }
}
write_md <- function(x,p) {
  stopifnot(!file.exists(here::here(p))); x <- unname(x)
  con <- file(here::here(p),"wb"); writeBin(charToRaw(paste0(paste(x,collapse="\n"),"\n")),con); close(con)
  stopifnot(identical(x,readLines(here::here(p),warn=FALSE)))
}
fmt <- function(x) ifelse(is.na(x),"undefined",sprintf("%.2f",x))
report <- c("# Stage 14: Spring sample readiness and descriptive statistics", "",
  "Four outcome-specific common samples are audited. No outcome regression, coefficient, uncertainty estimate or significance test is computed. S0-S2 below are candidate predictor matrices only. Readiness is computational and remains subject to review and later estimation authorization.", "",
  "## Sample definitions and decisions", "",
  "Each mask requires eligible same-outcome Fall and Spring scores, finite native Fall belief, and observed valid responses on all eight accepted descriptors. Nothing from another grade/outcome, grouping identifiers or teacher-change fields enters the masks. Fall predictors are joined by STUDY_ID to Spring rows; no Spring belief field is created. Every structural denominator is 1,015.", "",
  "| Cell | Common N | Excluded / 1,015 | Reconstructed Fall N | Spring loss within Fall | % Fall retained | Decision |",
  "|---|---:|---:|---:|---:|---:|---|")
for (cell in names(decisions)) {
  d <- decisions[[cell]]
  report <- c(report,paste0("| ",cell," | ",d$n," | ",d$lost," | ",d$fall_n," | ",d$bridge_lost," | ",fmt(pct(d$n,d$fall_n))," | ",d$status," |"))
}
report <- c(report,"", "## Sequential selection", "",
  "Each remaining count follows the preceding row. Marginal failures overlap and must not be added. The support CSV supplies previous-step and universe percentages plus mutually exclusive joint failure patterns and explicit reason states.", "",
  "| Cell | Restriction | Starting N | Newly excluded | Remaining N | % previous | % universe |",
  "|---|---|---:|---:|---:|---:|---:|")
flow <- so[so$section=="sequential_flow",]
report <- c(report, vapply(seq_len(nrow(flow)),function(i) {r<-flow[i,];paste0("| ",r$cell," | ",r$field," | ",r$starting_n," | ",r$newly_excluded_n," | ",r$remaining_n," | ",fmt(r$pct_previous)," | ",fmt(r$pct_universe)," |")},""),
  "", "## Candidate predictor support", "",
  "S0: intercept + native Fall belief. S1 adds the 12 accepted descriptors. S2 adds the same-outcome Fall score to S1. QR tolerance is 1e-7. Belief estimability requires full-matrix rank to exceed rank without belief by exactly one. Shared sample/order is checked separately for each candidate.", "",
  "| Cell | Candidate | N | Columns | Rank | Rank without belief | N - rank | Belief adds rank | Status |",
  "|---|---|---:|---:|---:|---:|---:|---:|---|")
for (cell in names(decisions)) for (model in c("S0","S1","S2")) {
  a <- decisions[[cell]]$audits[[model]]
  report <- c(report,paste0("| ",cell," | ",model," | ",a$n," | ",a$columns," | ",a$rank," | ",a$rank_without_belief," | ",a$n_minus_rank," | ",a$belief_increment," | ",a$status," |"))
}
report <- c(report, "", "Rank deficiency, empty samples, saturation, constant Fall scores and absent modeled categories are research review endpoints; no controls or children are automatically removed. Zero-frequency education Other is retained in descriptions and omitted from the accepted 12 descriptors. Counts below five are display flags only. Spring outcome variation is recorded separately from predictor rank.", "",
  "## Continuous composition", "",
  "Means use available eligible finite values within each comparison group, without imposing extra comparison-group complete cases. SD is the sample SD and is undefined for fewer than two usable values. Source-missing, documented exclusions, unknown eligibility and observed nonfinite counts are separate in the CSV; nonfinite is an overlapping diagnostic. Ineligible codes are never summarized as outcomes.", "",
  "Universe / included / excluded use the 1,015-child universe. Spring retained / Spring excluded are confined to the reconstructed Fall common sample; Spring retained equals included by construction.", "",
  "| Cell | Group | Field | Group N | Usable N | Mean | SD | Min | Max |",
  "|---|---|---|---:|---:|---:|---:|---:|---:|")
for (cell in names(decisions)) for (gr in c("universe","included","excluded","spring_retained","spring_excluded")) for (f in c("fall_score","spring_score","fall_belief")) {
  r <- de[de$cell==cell & de$section=="continuous" & de$group==gr & de$field==f,]
  get <- function(stat) r$value[r$statistic==stat]
  report <- c(report,paste0("| ",cell," | ",gr," | ",f," | ",r$group_n[1]," | ",r$observed_n[1]," | ",fmt(get("mean"))," | ",fmt(get("sd"))," | ",fmt(get("min"))," | ",fmt(get("max"))," |"))
}
report <- c(report,"", "## Descriptor selection comparisons", "",
  "Entries are count / variable-observed denominator (percent). Missing percentages instead use the full group denominator. All compact categories, including zero categories and missing rows, appear in the CSV. Race indicators are separate nonexclusive responses and their Yes percentages need not sum to 100%.", "",
  "| Cell | Descriptor/category | Included | All excluded | Spring excluded within Fall |",
  "|---|---|---:|---:|---:|")
for (cell in names(decisions)) for (f in covars) for (lev in levels(compact[[f]])) {
  if (f=="CHGENP" && lev=="Male" || f %in% covars[2:6] && lev=="No") next
  vals <- vapply(c("included","excluded","spring_excluded"),function(gr) {
    r<-de[de$cell==cell & de$section=="descriptors" & de$group==gr & de$field==f & de$category==lev,]
    paste0(r$n," / ",r$denominator," (",fmt(r$value),"%)")},"")
  report <- c(report,paste0("| ",cell," | ",f," / ",lev," | ",paste(vals,collapse=" | ")," |"))
}
report <- c(report,"", "## Coding, provenance and interpretation", "",
  "Descriptor coding preserves Stage11: Female (CHGENP=2), Male reference; five separate race Yes indicators (1), No references; education 1-2 Below HS, 3 HS reference, 4-6 college/technical/associate without BA, 7-9 BA+, 10 Other descriptive only because unobserved; income 1-4 <=20000 reference, 5-8 20001-40000, 9-12 40001-60000, 13-18 >60000. Factor responses are decoded through verified code-label pairs, never storage integers. Exact mapping locators are in support section descriptor_mapping.", "",
  "Sources checked: accepted Stage07 rules/counts/pair support and review; Stage08 characteristic inventory/pair composition/belief support and report; Stage09-13 scripts, reports and verification context; wide and structural provenance; DS0001 Setup.do/Setup.dct for exact field and code-label agreement. Practice-failure exclusions remain at both Pre-K Applied Problems occasions (7 Fall, 1 Spring). No new status exclusion, missing category, imputation, trimming, harmonization, weighting or pooling is introduced.", "",
  "These descriptors originate in Pre-K reports and are earlier-grade characteristics for Kindergarten. Exact report/assessment order, income reference year and the disposition of the questionnaire's no-mother option remain unresolved; missing education is not a household-composition indicator. Selection contrasts are descriptive, with no tests or random-missingness assumption. English-score selection does not identify a monolingual or representative population.", "",
  "## Membership contract", "",
  paste0("Sample rule: `",rule_id,"`. Canonical serialization is seven lines in this exact order: `format=stage14-membership-sha256-v1`, `cell=<cell>`, `rule=<rule>`, `wide_sha256=<lowercase SHA-256>`, `panel_sha256=<lowercase SHA-256>`, `universe_n=1015`, `membership=<1015 consecutive 0/1 ASCII digits>`. Each line, including the last, ends in one LF byte (0A); UTF-8, no BOM, no CR, no spaces or separators in the bit string. Bits correspond to the fixed verified-wide universe ordered by numeric ascending STUDY_ID. The IDs and bits remain only in memory."), "",
  "Only signatures and aggregate metadata are exported. Both input SHA-256 hashes bind the underlying values and universe; the signature binds the cell/rule/membership to those inputs. Later estimation must verify both current input hashes against these saved hashes AND recompute the canonical membership signature. Membership agreement alone cannot verify unchanged analysis values. Stage11/12 saved no historical membership fingerprint: reconstructed Fall counts/composition agree, but cannot independently authenticate historical child-by-child membership.", "",
  "| Cell | Common N | Membership SHA-256 |", "|---|---:|---|")
for (cell in names(decisions)) report <- c(report,paste0("| ",cell," | ",decisions[[cell]]$n," | ",decisions[[cell]]$signature," |"))
report <- c(report,"",paste0("Verified-wide SHA-256: `",wide_sha,"`. Outcome-cleaning-panel SHA-256: `",panel_sha,"`."), "",
  "## Review boundary and unresolved issues", "",
  "No new cleaning or specification decision is implemented. Unexpected coding, lineage, input or preservation failures stop publication and require resolution; they cannot become additional exclusions. Computational readiness does not resolve belief polarity/construction, individual timing, belief-to-teacher correspondence, cross-grade equivalence, dependence or population representation. No inference procedure is chosen. Fall scores are assessment-occasion measures; adjustment does not establish pre-instruction measurement or learning gains. No causal or growth interpretation is authorized.", "",
  "Stop for code/output review. These audit masks are candidates, not final authorized estimation samples. No estimation, manuscript rewriting, staging, commit or push occurs.")
write_csv(so,dest[1]); write_csv(de,dest[2]); write_md(report,dest[3])
check("aggregate_readback", TRUE, paste(nrow(so),nrow(de),length(report),sep="/"), detail="All CSV fields round-trip at 17-digit precision; exact Markdown lines read back")
# Independent checks on disk, including report/table agreement and denominator semantics.
disk_s <- read_csv(dest[1]); disk_d <- read_csv(dest[2]); disk_report <- readLines(here::here(dest[3]),warn=FALSE)
for (cell in names(decisions)) {
  d <- decisions[[cell]]; flow <- disk_s[disk_s$cell==cell & disk_s$section=="sequential_flow",]
  check("disk_flow", tail(flow$remaining_n,1)==d$n && sum(flow$newly_excluded_n)+d$n==1015 &&
    all(flow$starting_n[-1]==head(flow$remaining_n,-1)), cell=cell)
  check("disk_pattern_partition", sum(disk_s$n[disk_s$cell==cell & disk_s$section=="failure_patterns"])==1015, cell=cell)
  check("report_decision_agreement", any(grepl(paste0("| ",cell," | ",d$n," | ",d$lost," | ",d$fall_n," | ",d$bridge_lost," |"),disk_report,fixed=TRUE)), cell=cell)
}
for (i in which(disk_d$section=="descriptors")) {
  r<-disk_d[i,]; expected_den<-if(r$category=="<missing>") r$group_n else r$observed_n
  stopifnot(r$denominator==expected_den, isTRUE(all.equal(r$value,pct(r$n,expected_den),tolerance=1e-14)))
}
check("disk_descriptor_denominators", TRUE)
check("protected_after_publication", identical(before,tools::md5sum(here::here(protected))) && identical(protected,inventory_paths()),length(protected))
check("git_after_publication", identical(head_before,git(c("rev-parse","HEAD"))) && identical(index_before,git(c("ls-files","--stage"))) &&
  identical(status_before,git(c("status","--short","--branch"))))
check("five_outputs_ignored", all(vapply(dest,ignored,logical(1))))
write_csv(bind(checks),dest[4])
note <- c("# Stage 14 verification and unresolved record", "",
  paste0("Execution-start UTC: ",start_time,". Runtime: ",R.version.string,"; here ",packageVersion("here"),"; renv ",packageVersion("renv"),"."),
  paste0("Python hashlib executable: `",python,"`; ",py("import sys; print(sys.version.split()[0])"),". No package installation, network acquisition, upstream execution or PDF extraction."), "",
  "Exact fresh-session PowerShell command:", "```powershell", "$env:LC_ALL = 'English_United States.utf8'",
  "& 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/14_assess_spring_sample_readiness.R", "```", "",
  "Result: exit 0 on successful completion. All five destinations must be absent; writers recheck absence. Rerunning against existing artifacts deliberately fails preflight and preserves them. No rerun should delete or overwrite accepted outputs.", "",
  paste0("Checks: ",length(checks)," unique checks passed; zero failures. All CSV fields and Markdown lines read back exactly; numbers serialized at 17 significant digits. Disk checks reconcile sequential losses, joint failure-pattern partitions, descriptor denominators and report decisions. Fixtures test shuffled Spring rows, duplicate/unmatched keys, unknown/nonfinite eligibility, overlapping exclusions, empty/singleton summaries, collinear belief/Fall scores, absent categories, empty matrices, conflicting labels, equal-N/different membership, ordering invariance and all four signature bindings."), "",
  paste0("HEAD: ",head_before,"; branch: ",branch_before,". Full index entries and status unchanged across execution. Each Git call uses process-scoped `git -c safe.directory=<verified root>`; no configuration file is modified. Commands: `rev-parse --show-toplevel`, `rev-parse HEAD`, `branch --show-current`, `status --short --branch`, `ls-files --stage`, `diff --cached --name-only`, `diff --check`, `diff --cached --check`, and `check-ignore -q -- <each destination>`; all succeeded; whitespace checks empty."), "",
  paste0("Preservation: ",length(protected)," execution-start files (including this script, all raw/processed files, prior outputs, documentation, tracked files and renv files; excluding only five authorized destinations) have unchanged MD5 hashes and inventory. Both in-memory RDS objects serialize identically. An independent pre-implementation SHA-256 inventory outside the repository is checked by the caller after execution to verify the six additions and all 372 pre-existing files. That external check is not claimed by this runtime ledger."), "",
  "## Accepted input continuity and current SHA-256", "", "The nine upstream MD5 fingerprints match the historical Stage11 record. The four explicitly pinned Stage11/12 aggregate/report SHA-256 hashes match the accepted handoff. Recorded upstream checks were inspected only. SHA-256 hashes below pin all Stage14 data/support inputs; current supplementary support hashes are continuity receipts, not an independent reconstruction of their historical provenance.", "",
  "| Input | SHA-256 |", "|---|---|")
inputs <- unique(c(required,names(pins),"output/tables/outcome_cleaning_counts.csv","output/tables/outcome_cleaning_pair_support.csv","output/tables/stage08_pair_characteristics.csv"))
note <- c(note,vapply(inputs,function(p) paste0("| ",p," | ",sha_file(p)," |"),""),"",
  "## New artifact fingerprints", "", "| Path | SHA-256 |", "|---|---|",
  vapply(c(script_path,dest[1:4]),function(p) paste0("| ",p," | ",sha_file(p)," |"),""), "",
  "This note cannot contain its own final byte hash; it is supplied by the external delivery check. The report documents the seven-line UTF-8/LF canonical signature record binding both input SHA-256 hashes, cell, versioned sample rule and ascending-STUDY_ID 0/1 vector. Later estimation must authenticate both input fingerprints and the signature; membership equality alone is insufficient.", "",
  "## Limitations and review endpoint", "",
  "No new cleaning conflict, nonfinite observation, unknown eligibility or unexpected education Other was found. Existing measurement, timing, teacher correspondence, dependence, equivalence and representativeness questions remain unresolved as described in the report and Stage13. The historical Fall membership caveat persists. No final inference method or estimation sample is approved. Each cell's independent decision and model support are in the report and support CSV; rank deficiency/empty sample would be reported rather than repaired by term deletion. No coefficients or uncertainty quantities were computed.", "",
  "Development receipts: a read-only preliminary Get-Content used the nonexistent name 11_assess_fall_model_readiness.R; the actual 11_specify_fall_analysis.R was then read successfully. The first fresh-session run stopped before publication at WJ10_SSEPS dictionary-label comparison: Setup.dct has STAND  SCORE (two spaces), whereas accepted provenance has STAND SCORE. Exact source mapping and numerical values agreed. Collapsing label whitespace only resolves this formatting mismatch; codes, mappings, eligibility and values remain exact. The second run was interrupted before publication after review caught paste0 recycling an empty category vector into a spurious absent-category label. An explicit zero-length branch corrects that reporting bug. No output was created by either run and no upstream file was changed. A process-information query via Get-CimInstance was unavailable; the owned R session was interrupted via its session handle.", "",
  "## Final Git status", "```",git(c("status","--short","--branch")),"```", "",
  "## Protected fingerprints (MD5 before = after)", "", "| Relative path | MD5 |", "|---|---|",
  paste0("| ",protected," | ",unname(before)," |"))
write_md(note,dest[5])
stopifnot(identical(before,tools::md5sum(here::here(protected))), identical(protected,inventory_paths()),
  identical(head_before,git(c("rev-parse","HEAD"))), identical(index_before,git(c("ls-files","--stage"))),
  identical(status_before,git(c("status","--short","--branch"))))
cat("Stage14 PASS:",length(checks),"checks;",length(protected),"protected files unchanged; five aggregate outputs read back.\n")
for (cell in names(decisions)) { d<-decisions[[cell]]; cat(cell,"N=",d$n,"universe loss=",d$lost,"Fall-to-Spring loss=",d$bridge_lost,d$status,"\n") }
