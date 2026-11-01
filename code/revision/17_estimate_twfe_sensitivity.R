# Stage 17: the four registered matched time-FE / child-and-time-FE sensitivities.
# Run from the project root: Rscript --vanilla code/revision/17_estimate_twfe_sensitivity.R
# Never source an earlier analysis stage. No individual records/effects are exported.
project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
git <- function(args) {
  z <- system2("git", c("-c", shQuote(paste0("safe.directory=", project_start)), args),
    stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("Read-only Git command failed: ", paste(args, collapse = " "))
  z
}
stopifnot(identical(normalizePath(git(c("rev-parse", "--show-toplevel"))[1], winslash = "/"), project_start),
  basename(project_start) == "ICPSR_04283")
head_before <- git(c("rev-parse", "HEAD"))
branch_before <- git(c("branch", "--show-current"))
status_before <- git(c("status", "--short", "--branch"))
index_before <- git(c("ls-files", "--stage"))
stopifnot(head_before == "2cb42978efcbca38e5cfaf31e1fdd5c577ecd937",
  branch_before == "codex/restructure-project-layout")
Sys.setenv(RENV_PATHS_ROOT = file.path(project_start, "renv", "local"),
  RENV_CONFIG_SANDBOX_ENABLED = "FALSE", RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
source(file.path(project_start, "renv", "activate.R"))
suppressPackageStartupMessages(library(here))
stopifnot(identical(normalizePath(here::here(), winslash = "/"), project_start))
options(stringsAsFactors = FALSE, OutDec = ".", digits = 17, warn = 2)
script_path <- "code/revision/17_estimate_twfe_sensitivity.R"
dest <- c(paste0("output/tables/stage17_", c("model_registry", "sample_diagnostics",
  "variation_diagnostics", "coefficient_comparison", "fit_comparisons"), ".csv"),
  "output/reports/stage17_twfe_sensitivity.md", "output/verification/stage17_checks.csv",
  "output/verification/stage17_verification_unresolved.md")
ignored <- function(p) identical(system2("git", c("-c", shQuote(paste0("safe.directory=", project_start)),
  "check-ignore", "-q", "--", shQuote(p))), 0L)
if (any(file.exists(here::here(c(script_path, dest[-1])))) && any(file.exists(here::here(dest))))
  stop("Existing Stage 17 destination: establish provenance; never overwrite")
stopifnot(!any(file.exists(here::here(dest))), all(dir.exists(here::here(dirname(dest)))),
  all(vapply(dest, ignored, logical(1))), !length(git(c("ls-files", "--", dest))))
python <- Sys.getenv("STAGE17_PYTHON", Sys.which("python"))
stopifnot(nzchar(python), file.exists(python))
py <- function(code, args = character()) {
  z <- system2(python, c("-X", "utf8", "-c", shQuote(code), shQuote(args)), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("Python hashlib helper failed")
  z
}
sha_file <- function(p) py("import sys,hashlib,pathlib;print(hashlib.sha256(pathlib.Path(sys.argv[1]).read_bytes()).hexdigest())",
  here::here(p))
sha_text <- function(s) {
  # Only a digest is saved temporarily. Membership text travels in a binary pipe.
  p <- tempfile("stage17_digest_", tmpdir = dirname(tempdir()))
  code <- "import sys,hashlib,pathlib;pathlib.Path(sys.argv[1]).write_text(hashlib.sha256(sys.stdin.buffer.read()).hexdigest(),encoding='ascii')"
  con <- pipe(paste(shortPathName(python), "-X utf8 -c", shQuote(code), shQuote(p)), open = "wb")
  writeBin(charToRaw(enc2utf8(s)), con)
  exit_status <- close(con)
  stopifnot(exit_status == 0L, file.exists(p))
  h <- readLines(p, warn = FALSE); unlink(p)
  stopifnot(length(h) == 1L, grepl("^[0-9a-f]{64}$", h))
  unname(h)
}
inventory <- function() {
  # All files, including ignored data, outputs, renv, hidden files and this script.
  # Git metadata is audited separately; output destinations must initially be absent.
  z <- py(paste0("import sys,pathlib,hashlib; r=pathlib.Path(sys.argv[1]); ",
    "files=sorted((p for p in r.rglob('*') if p.is_file() and '.git' not in p.relative_to(r).parts),key=lambda p:p.as_posix()); ",
    "[print(hashlib.sha256(p.read_bytes()).hexdigest()+'|'+p.relative_to(r).as_posix()) for p in files]"), project_start)
  z[!sub("^[^|]+[|]", "", z) %in% dest]
}
before <- inventory()
index_path <- git(c("rev-parse", "--git-path", "index"))[1]
index_sha <- sha_file(index_path)
preserved <- function() identical(before, inventory())
git_preserved <- function() identical(head_before, git(c("rev-parse", "HEAD"))) &&
  identical(branch_before, git(c("branch", "--show-current"))) &&
  identical(index_before, git(c("ls-files", "--stage"))) && identical(index_sha, sha_file(index_path)) &&
  identical(status_before, git(c("status", "--short", "--branch")))
start_time <- format(Sys.time(), tz = "UTC", usetz = TRUE)
qr_tol <- 1e-7; numeric_tol <- 1e-10; weak_tol <- 1e-4
checks <- list()
bind <- function(x) { z <- do.call(rbind, x); row.names(z) <- NULL; z }
check <- function(id, ok, observed = "", expected = "TRUE", outcome = "all", model = "", detail = "") {
  key <- paste(outcome, model, id, sep = ":")
  stopifnot(!key %in% vapply(checks, `[[`, "", "check_id"))
  checks[[length(checks) + 1L]] <<- data.frame(check_id = key, outcome, model,
    status = if (isTRUE(ok)) "pass" else "fail", observed = paste(observed, collapse = ";"),
    expected = paste(expected, collapse = ";"), detail)
  if (!isTRUE(ok)) stop("Stage17 check failed: ", key, "; ", detail)
}
near <- function(a, b) length(a) == length(b) && all(is.finite(c(a, b))) &&
  all(abs(a - b) <= numeric_tol * pmax(1, abs(a), abs(b)))
same <- function(a, b) identical(is.na(a), is.na(b)) &&
  isTRUE(all.equal(as.vector(a), as.vector(b), check.attributes = FALSE, tolerance = 0))
fails <- function(expr) inherits(tryCatch({ force(expr); NULL }, error = function(e) e), "error")
read_csv <- function(p) read.csv(here::here(p), check.names = FALSE, fileEncoding = "UTF-8")

# QR projections and pivot-aware triangular solves; no cross-product inverse.
decomp <- function(x) qr(x, LAPACK = TRUE)
project <- function(q, v) { Q <- qr.Q(q); v - Q %*% crossprod(Q, v) }
demean <- function(v, group) {
  v <- as.matrix(v)
  sums <- rowsum(v, group, reorder = FALSE)
  counts <- as.vector(table(factor(group, levels = unique(group))))
  v - (sums / counts)[match(group, rownames(sums)), , drop = FALSE]
}
sequential <- function(v, W, group) {
  vd <- demean(v, group); wd <- demean(W, group)
  project(decomp(wd), vd)
}
rank_info <- function(x) {
  norms <- sqrt(colSums(x * x))
  if (any(!is.finite(x)) || any(norms == 0)) stop("Nonfinite/zero design column")
  z <- sweep(x, 2L, norms, "/")
  s <- svd(z, nu = 0L, nv = 0L)$d
  ratio <- min(s) / max(s)
  machine_tol <- max(dim(z)) * .Machine$double.eps
  list(rank = qr(z, tol = qr_tol)$rank, machine_rank = sum(s > max(s) * machine_tol),
    ratio = ratio, condition = max(s) / min(s), minimum = min(s), maximum = max(s),
    machine_tol = machine_tol)
}
rank_gate <- function(x, expected) {
  z <- rank_info(x)
  if (z$rank != expected || z$machine_rank != expected || z$ratio <= qr_tol)
    stop("Rank/conditioning gate failed; no tolerance or specification substitution")
  z
}
graph_components <- function(group, w) {
  # Four occasion vertices joined whenever a child appears in both occasions.
  present <- sort(unique(w)); adjacency <- diag(TRUE, length(present))
  for (i in unique(group)) {
    j <- match(unique(w[group == i]), present); adjacency[j, j] <- TRUE
  }
  unseen <- seq_along(present); components <- 0L
  while (length(unseen)) {
    visited <- unseen[1]
    repeat {
      more <- which(colSums(adjacency[visited, , drop = FALSE]) > 0)
      if (setequal(more, visited)) break
      visited <- more
    }
    unseen <- setdiff(unseen, visited); components <- components + 1L
  }
  components
}
qr_cluster <- function(x, y, group, full_k = ncol(x)) {
  if (any(!is.finite(c(x, y))) || nrow(x) != length(y) || length(group) != length(y)) stop("Invalid fit inputs")
  q <- decomp(x); Q <- qr.Q(q); R <- qr.R(q); p <- q$pivot
  n <- length(y); G <- length(unique(group)); k <- ncol(x)
  if (n <= full_k || G <= 1L) stop("Nonpositive inference degrees of freedom")
  beta <- setNames(numeric(k), colnames(x)); beta[p] <- backsolve(R, crossprod(Q, y))
  fitted <- as.vector(x %*% beta); residual <- y - fitted
  influences <- backsolve(R, t(rowsum(Q * residual, group, reorder = FALSE)))
  V0 <- matrix(0, k, k, dimnames = list(colnames(x), colnames(x)))
  V0[p, p] <- tcrossprod(influences)
  correction <- G / (G - 1) * (n - 1) / (n - full_k)
  V <- V0 * correction
  if (any(!is.finite(c(beta, V))) || !near(V, t(V)) || any(diag(V) < 0)) stop("Invalid covariance")
  list(beta = beta, fitted = fitted, residual = residual, V0 = V0, V = V,
    n = n, G = G, k = full_k, residual_df = n - full_k, reference_df = G - 1L,
    correction = correction, q = q, pivot = p)
}
scaled_orthogonality <- function(x, residual, y) {
  max(abs(crossprod(x, residual)) / pmax(1, sqrt(colSums(x * x)) * sqrt(sum(y * y))))
}
compare <- function(id, a, b, outcome = "all", model = "") {
  check(id, near(a, b), max(abs(a - b)), "elementwise scaled tolerance 1e-10", outcome, model)
}

# Explicit exclusive UTF-8/LF output, numeric 17-significant-digit serialization.
csv_text <- function(x) {
  text <- x
  for (f in names(x)) {
    text[[f]] <- if (is.numeric(x[[f]])) sprintf("%.17g", x[[f]]) else as.character(x[[f]])
    text[[f]][is.na(x[[f]])] <- "NA"
  }
  quote_cell <- function(s) paste0('"', gsub('"', '""', s, fixed = TRUE), '"')
  lines <- c(paste(quote_cell(names(text)), collapse = ","), vapply(seq_len(nrow(text)),
    function(i) paste(quote_cell(unlist(text[i, ], use.names = FALSE)), collapse = ","), ""))
  list(text = text, lines = unname(lines))
}
readback <- function(p, original, record = TRUE) {
  back <- read.csv(p, colClasses = "character", check.names = FALSE, na.strings = NULL, fileEncoding = "UTF-8")
  stopifnot(identical(back, csv_text(original)$text))
  for (f in names(original)) {
    v <- back[[f]]; v[v == "NA"] <- NA_character_
    back[[f]] <- if (is.integer(original[[f]])) as.integer(v) else if (is.double(original[[f]])) as.numeric(v) else
      if (is.logical(original[[f]])) as.logical(v) else v
  }
  stopifnot(identical(back, original))
  if (record) check(paste0("typed_readback_", basename(p)), TRUE, nrow(back), nrow(original))
  back
}
write_exclusive <- function(lines, p) {
  stopifnot(p %in% dest, !file.exists(here::here(p)), length(lines) > 0L, tail(lines, 1L) != "",
    !any(grepl("\r", lines, fixed = TRUE)))
  con <- file(here::here(p), open = "wxb")
  tryCatch(writeBin(charToRaw(enc2utf8(paste0(paste(lines, collapse = "\n"), "\n"))), con), finally = close(con))
}

failure <- tryCatch({
cat("Stage17: authenticating accepted inputs and historical outputs\n")
check("hash_known_answer", sha_text("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
check("accepted_stage16_script", sha_file("code/revision/16_estimate_time_fixed_effects.R") ==
  "65f8964d8134a29f1147e48d38569ee65d9cec4a483e8f77e00a2a5505b05f09")
note16_path <- "output/verification/stage16_verification_unresolved.md"
check("accepted_stage16_note", sha_file(note16_path) == "8cf486d0902981c9612fa999e194d6cd65cc4ad22e581825e8bcb70bc99804c7")
note16 <- readLines(here::here(note16_path), encoding = "UTF-8", warn = FALSE)
receipt_section <- function(start, end) {
  z <- note16[seq.int(match(start, note16) + 1L, match(end, note16) - 1L)]
  z <- z[grepl("^\\| [^|]+ \\| [0-9a-f]{64} \\|$", z)]
  lapply(z, function(s) trimws(strsplit(s, "|", fixed = TRUE)[[1]][2:3]))
}
receipts <- receipt_section("## Input fingerprints", "## Preservation audit")
artifacts <- receipt_section("## New artifact fingerprints", "## Execution-start and final Git status")
check("receipt_counts", length(receipts) == 22L && length(artifacts) == 8L, c(length(receipts), length(artifacts)), c(22, 8))
all_receipts <- c(receipts, artifacts)
for (i in seq_along(all_receipts)) check(paste0("accepted_pin_", i),
  identical(sha_file(all_receipts[[i]][1]), all_receipts[[i]][2]), detail = all_receipts[[i]][1])
old_checks <- read_csv("output/verification/stage16_checks.csv")
check("historical_ledger", nrow(old_checks) == 588L && !anyDuplicated(old_checks$check_id) && all(old_checks$status == "pass"),
  nrow(old_checks), 588, detail = "Historical evidence inspected, never rerun")
wide_path <- "Data/processed/verified_child_wide.rds"
panel_path <- "Data/processed/outcome_cleaning_panel.rds"
struct_path <- "Data/processed/structural_child_wave_panel.rds"
raw_path <- "Data/raw/icpsr_04283/04283-0001-Data.rda"
wide_sha <- sha_file(wide_path); panel_sha <- sha_file(panel_path)
wide <- readRDS(here::here(wide_path)); panel <- readRDS(here::here(panel_path))
structural <- readRDS(here::here(struct_path))
raw_env <- new.env(parent = emptyenv()); raw_names <- load(here::here(raw_path), envir = raw_env)
stopifnot(identical(raw_names, "da04283.0001")); released <- raw_env[[raw_names]]
original_objects <- lapply(list(wide, panel, structural, released), serialize, connection = NULL)
objects_preserved <- function() identical(original_objects,
  lapply(list(wide, panel, structural, released), serialize, connection = NULL))
check("dimensions", identical(dim(wide), c(1015L, 62L)) && identical(dim(panel), c(4060L, 65L)) &&
  identical(dim(structural), c(4060L, 37L)) && identical(dim(released), c(1015L, 1210L)))
waves <- c("PF", "PS", "KF", "KS")
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
  if (!is.factor(v) || !identical(levels(v), factor_labels(f))) stop("Unexpected released code-label pairs: ", f)
  z <- match(as.character(v), factor_labels(f))
  stopifnot(identical(is.na(z), is.na(v)))
  as.integer(names(expected[[f]]))[z]
}
indicator <- function(v, a) ifelse(is.na(v), NA_real_, as.numeric(v %in% a))
codes <- as.data.frame(lapply(covars, function(f) decode(wide[[f]], f))); names(codes) <- covars
setup <- readLines(here::here("docs/icpsr/DS0001/04283-0001-Setup.do"), warn = FALSE)
dictionary <- readLines(here::here("docs/icpsr/DS0001/04283-0001-Setup.dct"), warn = FALSE)
inventory08 <- read_csv("output/tables/stage08_characteristic_inventory.csv")
for (f in covars) {
  first <- grep(paste0("^label define ", f, "[[:space:]]"), setup)
  stopifnot(length(first) == 1L)
  last <- first - 1L + which(grepl(";", setup[first:length(setup)], fixed = TRUE))[1]
  block <- paste(trimws(setup[first:last]), collapse = " ")
  entries <- regmatches(block, gregexpr('-?[0-9]+[[:space:]]+"[^"]*"', block))[[1]]
  pairs <- setNames(sub('^-?[0-9]+[[:space:]]+"(.*)"$', '\\1', entries), sub('[[:space:]].*', '', entries))
  check(paste0("documented_C_", f), identical(pairs, c(`-99` = "System Missing", expected[[f]])) &&
    identical(inventory08$released_setup_definition[inventory08$characteristic == f], block) &&
    length(grep(paste0("[[:space:]]", f, "[[:space:]]"), dictionary)) == 1L)
}
check("education_other_absent", !any(codes$CHMATEDCP == 10L, na.rm = TRUE))
C <- cbind(F = indicator(codes$CHGENP, 2L))
for (f in covars[2:5]) C <- cbind(C, indicator(codes[[f]], 1L))
colnames(C) <- c("F", "R_AA", "R_AS", "R_LT", "R_NA")
for (i in 2:18) C <- cbind(C, setNames(data.frame(indicator(codes$CHINCOMCP, i)), paste0("I_", sprintf("%02d", i))))
for (i in 2:9) C <- cbind(C, setNames(data.frame(indicator(codes$CHMATEDCP, i)), paste0("E_", sprintf("%02d", i))))
C <- as.matrix(C)
check("C_coding_eligibility", ncol(C) == 30L && identical(complete.cases(C), complete.cases(codes)) &&
  identical(complete.cases(C), complete.cases(codes[covars[c(1:5, 7:8)]])))
align_wave <- function(p, w) {
  if (anyNA(p$STUDY_ID) || anyNA(p$wave) || anyDuplicated(p[c("STUDY_ID", "wave")])) stop("Invalid child-wave keys")
  ix <- which(as.character(p$wave) == w); m <- match(wide$STUDY_ID, p$STUDY_ID[ix])
  if (length(ix) != nrow(wide) || anyNA(m)) stop("Unmatched universe")
  ix[m]
}
check("wide_keys", is.numeric(wide$STUDY_ID) && !anyNA(wide$STUDY_ID) && !anyDuplicated(wide$STUDY_ID))
raw_ix <- match(wide$STUDY_ID, released$STUDY_ID)
check("released_keys", !anyNA(raw_ix) && !anyDuplicated(released$STUDY_ID))
for (f in c(covars, "T_IDEAP", "T_IDEAK")) check(paste0("released_source_", f),
  same(wide[[f]], released[[f]][raw_ix]) && identical(attributes(wide[[f]]), attributes(released[[f]])))
wave_rows <- setNames(lapply(waves, function(w) align_wave(panel, w)), waves)
struct_rows <- setNames(lapply(waves, function(w) align_wave(structural, w)), waves)
for (w in waves) {
  for (f in covars) check(paste0("panel_C_", w, "_", f), identical(decode(panel[[f]][wave_rows[[w]]], f), codes[[f]]))
  src <- paste0("CLS_SIZE", w)
  check(paste0("class_source_", w), same(wide[[src]], released[[src]][raw_ix]) &&
    identical(attributes(wide[[src]]), attributes(released[[src]])) &&
    same(wide[[src]], panel$class_size[wave_rows[[w]]]) && same(wide[[src]], structural$class_size[struct_rows[[w]]]))
}
check("source_belief_wave_missingness", all(is.na(panel$teacher_modernity_pre_k_fall_released[as.character(panel$wave) != "PF"])) &&
  all(is.na(panel$teacher_modernity_kindergarten_fall_released[as.character(panel$wave) != "KF"])) &&
  same(wide$T_IDEAP, panel$teacher_modernity_pre_k_fall_released[wave_rows$PF]) &&
  same(wide$T_IDEAK, panel$teacher_modernity_kindergarten_fall_released[wave_rows$KF]))
ordering <- order(wide$STUDY_ID, method = "radix")
ids <- rep(wide$STUDY_ID[ordering], each = 4L); wave <- rep(waves, nrow(wide)); ix_wide <- rep(ordering, each = 4L)
ix_panel <- match(paste(ids, wave), paste(panel$STUDY_ID, as.character(panel$wave)))
stopifnot(!anyNA(ix_panel))
universe_sha <- sha_text(paste0("stage16-child-wave-universe-v1\n", paste(paste(ids, wave, sep = "|"), collapse = "\n"), "\n"))
check("canonical_universe", universe_sha == "0dbc983be1f611fae806fdae711e36b6f4f0bf71bd4533daf32084cf1ab1de8b")
rule16 <- "stage16_A_eligible_finite_own_grade_report_complete_C_B_grade_pair_AC_finite_class_v1"
rule17 <- "stage17_AC_child_count_ge2_v1"
signature <- function(mask, outcome, sample, stage17 = FALSE) {
  stopifnot(is.logical(mask), length(mask) == 4060L, !anyNA(mask))
  sha_text(paste0("format=", if (stage17) "stage17" else "stage16", "-membership-sha256-v1\noutcome=", outcome,
    "\nsample=", sample, "\nrule=", if (stage17) rule17 else rule16,
    "\nwide_sha256=", wide_sha, "\npanel_sha256=", panel_sha, "\nuniverse_sha256=", universe_sha,
    "\nuniverse_n=4060\nmembership=", paste0(as.integer(mask), collapse = ""), "\n"))
}
is_p <- wave %in% c("PF", "PS")
bp <- wide$T_IDEAP[ix_wide]; bk <- wide$T_IDEAK[ix_wide]
belief <- ifelse(is_p, bp / 16, bk); class_size <- panel$class_size[ix_panel]
check("assigned_own_grade", same(belief[is_p], bp[is_p] / 16) && same(belief[!is_p], bk[!is_p]) &&
  identical(is.na(belief), ifelse(is_p, is.na(bp), is.na(bk))))
historical_flow <- read_csv("output/tables/stage16_sample_flow.csv")
rules <- read_csv("output/tables/outcome_cleaning_rules.csv")
counts07 <- read_csv("output/tables/outcome_cleaning_counts.csv")
outcomes <- c("PPVT", "Applied_Problems")
fields <- c(PPVT = "ppvt_english_standard_score", Applied_Problems = "applied_problems_english_standard_score")
expected_ac2 <- list(PPVT = c(2769, 770, 680, 729, 697, 663, 0, 107, 97, 566),
  Applied_Problems = c(2791, 785, 667, 737, 710, 677, 0, 115, 119, 551))
expected_hash <- c(PPVT = "9f6f0ff4ab222b5f9751ce95b5a773de35ab5ff4b53479bde4a1ec2bc27dabf7",
  Applied_Problems = "a463a983a7c6b7c36cba648d17a4a331b500493a96d1f469aabeb0231fa29a83")
sample_rows <- list(); variation_rows <- list(); samples <- list(); designs <- list(); registry_rows <- list()
add_sample <- function(o, sample, metric, value, hash = "", detail = "") {
  sample_rows[[length(sample_rows) + 1L]] <<- data.frame(outcome = o, sample, metric, value = as.numeric(value), membership_sha256 = hash, detail)
}
add_variation <- function(o, metric, value, detail = "") {
  variation_rows[[length(variation_rows) + 1L]] <<- data.frame(outcome = o, metric, value = as.numeric(value), detail)
}
summary_mask <- function(m) c(sum(m), length(unique(ids[m])), vapply(waves, function(w) sum(m & wave == w), 0L),
  tabulate(as.integer(table(ids[m])), nbins = 4L))
cat("Stage17: reconstructing frozen samples and feasibility diagnostics before fits\n")
for (o in outcomes) {
  field <- fields[[o]]
  for (w in waves) {
    src <- paste0(if (o == "PPVT") "PPVTE" else "WJ10_SSE", w)
    j <- wave_rows[[w]]; raw <- wide[[src]]
    e <- panel[[paste0(field, "_eligible_current_rules")]][j]
    y <- panel[[paste0(field, "_clean")]][j]; reason <- panel[[paste0(field, "_cleaning_reason")]][j]
    ac <- counts07[counts07$outcome == field & counts07$wave == w, ]
    check(paste0("accepted_cleaning_", w), is.logical(e) && !anyNA(e) && all(!e | is.finite(y)) &&
      same(y[e], raw[e]) && all(is.na(y[!e])) && identical(e, reason == "retained_under_current_rules") &&
      identical(is.na(raw), reason == "source_missing_reason_unavailable") &&
      same(raw, released[[src]][raw_ix]) && identical(attributes(raw), attributes(released[[src]])) &&
      nrow(ac) == 1L && sum(e) == ac$n_eligible_current_rules && sum(is.na(raw)) == ac$n_source_missing &&
      sum(reason == "practice_failure_project_exclusion") == ac$n_practice_failure_project_excluded, outcome = o)
    if (o == "Applied_Problems" && w %in% c("PF", "PS")) {
      rr <- rules[rules$outcome == field & rules$wave == w, ]
      check(paste0("practice_failure_", w), sum(reason == "practice_failure_project_exclusion") == if (w == "PF") 7L else 1L,
        outcome = o)
      check(paste0("practice_rule_", w), identical(reason == "practice_failure_project_exclusion", !is.na(raw) & raw == -7) &&
        any(rr$rule_id == "practice_failure" & rr$rule_value == -7 & rr$action == "clean_NA_eligible_FALSE", na.rm = TRUE), outcome = o)
    }
  }
  y <- panel[[paste0(field, "_clean")]][ix_panel]
  e <- panel[[paste0(field, "_eligible_current_rules")]][ix_panel] & is.finite(y)
  finite_report <- e & is.finite(belief)
  A <- finite_report & complete.cases(C)[ix_wide]
  pairs <- table(paste(ids[A], ifelse(is_p[A], "P", "K")))
  B <- A & paste(ids, ifelse(is_p, "P", "K")) %in% names(pairs)[pairs == 2L]
  AC <- A & is.finite(class_size)
  masks <- list(universe = rep(TRUE, 4060), eligible_outcome = e, finite_grade_report = finite_report,
    A = A, B = B, AC = AC, A_PreK = A & is_p, A_K = A & !is_p, B_PreK = B & is_p, B_K = B & !is_p)
  for (s in names(masks)) {
    h <- historical_flow[historical_flow$outcome == o & historical_flow$sample == s, ]
    check(paste0("accepted_membership_", s), nrow(h) == 1L && signature(masks[[s]], o, s) == h$membership_sha256 &&
      identical(as.numeric(summary_mask(masks[[s]])), as.numeric(h[1, c("n", "G", waves, paste0("children_", 1:4))])), outcome = o)
  }
  # Independent wide-oriented reconstruction uses original scores and documented -7 rule.
  yw <- as.matrix(wide[paste0(if (o == "PPVT") "PPVTE" else "WJ10_SSE", waves)])
  ew <- is.finite(yw)
  if (o == "Applied_Problems") ew[, 1:2] <- ew[, 1:2] & yw[, 1:2] != -7
  bw <- cbind(wide$T_IDEAP, wide$T_IDEAP, wide$T_IDEAK, wide$T_IDEAK)
  cw <- as.matrix(wide[paste0("CLS_SIZE", waves)])
  ac_wide <- ew & is.finite(bw) & complete.cases(C) & is.finite(cw)
  check("independent_AC", identical(AC, as.vector(t(ac_wide[ordering, , drop = FALSE]))), outcome = o)
  child_n <- table(ids[AC]); AC2 <- AC & ids %in% as.numeric(names(child_n)[child_n >= 2L])
  ac2_hash <- signature(AC2, o, "AC2", TRUE)
  check("AC2_hash", ac2_hash == expected_hash[[o]], ac2_hash, expected_hash[[o]], o)
  check("AC2_counts", identical(as.numeric(summary_mask(AC2)), expected_ac2[[o]]), summary_mask(AC2), expected_ac2[[o]], o)
  for (s in c("AC", "AC2")) {
    m <- if (s == "AC") AC else AC2; vals <- summary_mask(m)
    names(vals) <- c("rows", "children", waves, paste0("children_", 1:4))
    h <- signature(m, o, s, s == "AC2")
    for (j in names(vals)) add_sample(o, s, j, vals[j], h)
    ui <- unique(ix_wide[m]); has_p <- is.finite(wide$T_IDEAP[ui]); has_k <- is.finite(wide$T_IDEAK[ui])
    both <- intersect(unique(ids[m & is_p]), unique(ids[m & !is_p]))
    metrics <- c(both_grades = length(both), one_grade = length(ui) - length(both),
      both_reports = sum(has_p & has_k), preK_report_only = sum(has_p & !has_k), K_report_only = sum(!has_p & has_k))
    for (j in names(metrics)) add_sample(o, s, j, metrics[j], h)
    patterns <- vapply(split(wave[m], ids[m]), function(v) paste(waves[waves %in% v], collapse = "+"), "")
    for (bits in 1:15) {
      label <- paste(waves[as.logical(intToBits(bits)[1:4])], collapse = "+")
      add_sample(o, s, paste0("pattern_", label), sum(patterns == label), h)
    }
  }
  add_sample(o, "AC_to_AC2", "singleton_rows_and_children_excluded", sum(AC) - sum(AC2), ac2_hash)
  check("singleton_only_exclusion", all(!AC2 | AC) && all(child_n[as.character(ids[AC & !AC2])] == 1L), outcome = o)
  m <- AC2; g <- ids[m]; w <- wave[m]; yy <- y[m]
  unique_ids <- sort(unique(g)); D <- outer(g, unique_ids, "==") * 1
  colnames(D) <- paste0("child_", seq_along(unique_ids))
  W <- outer(w, waves[-1], "==") * 1; colnames(W) <- paste0("wave_", waves[-1])
  slopes <- cbind(belief_common = belief[m], class_size = class_size[m])
  Z <- cbind(D, W); full <- cbind(Z, slopes)
  tfe <- cbind(Intercept = 1, belief_common = slopes[, 1], C[ix_wide[m], , drop = FALSE], class_size = slopes[, 2], W)
  G <- length(unique_ids); n <- length(g)
  check("graph_connected", graph_components(g, w) == 1L && length(unique(w)) == 4L && min(table(g)) >= 2L, outcome = o)
  rZ <- rank_gate(Z, G + 3L); rT <- rank_gate(tfe, 36L); rF <- rank_gate(full, G + 5L)
  rs <- sequential(slopes, W, g); rS <- rank_gate(rs, 2L)
  conditional_b <- project(decomp(rs[, "class_size", drop = FALSE]), rs[, "belief_common"])
  conditional_ss <- sum(conditional_b^2)
  check("focal_rank_increment", rS$rank - rank_info(rs[, "class_size", drop = FALSE])$rank == 1L && conditional_ss > 0, outcome = o)
  check("constant_C_absorption", all(demean(C[ix_wide[m], , drop = FALSE], g) == 0), outcome = o)
  qZ <- decomp(Z); qFull <- decomp(full)
  compare("sequential_explicit_projection", rs, project(qZ, slopes), o)
  compare("sequential_idempotence", sequential(rs, W, g), rs, o)
  check("projected_nuisance_orthogonality", scaled_orthogonality(Z, rs[, 1], slopes[, 1]) <= numeric_tol &&
    scaled_orthogonality(Z, rs[, 2], slopes[, 2]) <= numeric_tol, outcome = o)
  # Independent alternating projections: convergence tolerance is fixed before research fitting.
  alt <- slopes
  for (iteration in seq_len(10000L)) {
    next_alt <- demean(demean(alt, g), w)
    if (max(abs(next_alt - alt)) <= 1e-13 * max(1, abs(slopes))) { alt <- next_alt; break }
    alt <- next_alt
  }
  check("alternating_converged", iteration < 10000L, iteration, "<10000", o)
  compare("alternating_sequential", alt, rs, o)
  shortcut <- demean(slopes, g) - (slopes - demean(slopes, w)) +
    matrix(colMeans(slopes), n, 2L, byrow = TRUE)
  add_variation(o, "incorrect_single_mean_subtraction_max_difference", max(abs(shortcut - rs)), "Diagnostic only; never used for estimation")
  compare("nested_TFE_column_space", project(qFull, tfe), matrix(0, n, ncol(tfe)), o)
  cross_ids <- intersect(unique(g[w %in% c("PF", "PS")]), unique(g[w %in% c("KF", "KS")]))
  ui <- match(cross_ids, wide$STUDY_ID); delta <- wide$T_IDEAK[ui] - wide$T_IDEAP[ui] / 16
  dvals <- c(children = length(delta), mean = mean(delta), sd = sd(delta), min = min(delta),
    q25 = unname(quantile(delta, .25)), median = median(delta), q75 = unname(quantile(delta, .75)), max = max(delta),
    negative = sum(delta < 0), zero = sum(delta == 0), positive = sum(delta > 0))
  for (j in names(dvals)) add_variation(o, paste0("cross_grade_change_", j), dvals[j])
  check("cross_grade_counts", length(delta) == if (o == "PPVT") 671L else 679L, outcome = o)
  check("cross_grade_change_signs", identical(as.numeric(dvals[c("negative", "zero", "positive")]),
    if (o == "PPVT") c(301, 6, 364) else c(306, 6, 367)), outcome = o)
  a_centered <- sum((slopes[, 1] - mean(slopes[, 1]))^2)
  ss_by_child <- rowsum(conditional_b^2, g, reorder = FALSE)[, 1]
  ss <- c(belief_centered_SS = a_centered, belief_after_child_SS = sum(demean(slopes[, 1], g)^2),
    belief_after_child_wave_SS = sum(rs[, 1]^2), belief_after_child_wave_class_SS = conditional_ss,
    class_after_child_wave_SS = sum(rs[, 2]^2), conditional_belief_SS_fraction_of_centered = conditional_ss / a_centered,
    conditional_belief_SS_fraction_of_child_wave = conditional_ss / sum(rs[, 1]^2),
    residual_belief_SS_cross_grade_children = sum(conditional_b[g %in% cross_ids]^2),
    residual_belief_SS_one_grade_children = sum(conditional_b[!g %in% cross_ids]^2),
    residual_belief_contributing_children = sum(ss_by_child > numeric_tol * max(1, conditional_ss) / G),
    weak_variation_flag = as.numeric(conditional_ss / a_centered < weak_tol))
  for (j in names(ss)) add_variation(o, j, ss[j])
  # These are rounded historical planning values, not substitutes for computed diagnostics.
  expected_ss <- if (o == "PPVT") c(969.217079, 419.799906, 417.989797, 416.780991, 24592.235973) else
    c(978.567891, 418.423244, 416.859475, 415.686505, 24665.867975)
  check("historical_rounded_SS_reproduction", all(abs(ss[1:5] - expected_ss) <= 0.00000051), ss[1:5], expected_ss, o,
    detail = "Comparison to six-decimal historical diagnostics; numerical implementation agreement remains 1e-10 scaled")
  # Singleton rows project to zero; use AC only for regressor feasibility, never fit another outcome model.
  Wac <- outer(wave[AC], waves[-1], "==") * 1
  rac <- sequential(cbind(belief[AC], class_size[AC]), Wac, ids[AC])
  compare("singleton_removal_projected_SS", colSums(rac^2), colSums(rs^2), o)
  ranks <- list(nuisance = rZ, matched_TFE = rT, explicit_TWFE = rF, residualized_slopes = rS)
  for (label in names(ranks)) for (j in names(ranks[[label]])) add_variation(o, paste(label, j, sep = "_"), ranks[[label]][[j]])
  add_variation(o, "child_indicator_rank", G); add_variation(o, "wave_rank_increment", 3)
  add_variation(o, "graph_components", graph_components(g, w)); add_variation(o, "focal_rank_increment_conditional_class", 1)
  add_variation(o, "sequential_explicit_max_difference", max(abs(rs - project(qZ, slopes))))
  add_variation(o, "alternating_sequential_max_difference", max(abs(alt - rs)))
  samples[[o]] <- list(mask = m, y = yy, belief = belief[m], class_size = class_size[m], group = g, hash = ac2_hash)
  designs[[o]] <- list(tfe = tfe, Z = Z, full = full, W = W, slopes = slopes, rs = rs, qZ = qZ, qFull = qFull)
  prefix <- if (o == "PPVT") "S17_PPVT_" else "S17_AP_"
  for (kind in c("TFE", "TWFE")) {
    k <- if (kind == "TFE") 36L else G + 5L
    registry_rows[[length(registry_rows) + 1L]] <- data.frame(outcome = o, model = paste0(prefix, kind),
      sample = "AC2", formula = if (kind == "TFE") "Y ~ intercept + belief + 30 C indicators + class size + PS/KF/KS" else
        "Y ~ all child indicators + PS/KF/KS + belief + class size; no intercept; C absorbed",
      n = n, G = G, k = k, rank = k, residual_df = n - k, reference_df = G - 1L,
      correction = G / (G - 1) * (n - 1) / (n - k), membership_sha256 = ac2_hash,
      universe_sha256 = universe_sha, wide_sha256 = wide_sha, panel_sha256 = panel_sha,
      term_order = if (kind == "TFE") paste(colnames(tfe), collapse = ";") else
        "all child indicators in ascending numeric STUDY_ID;wave_PS;wave_KF;wave_KS;belief_common;class_size",
      normalization = if (kind == "TFE") "intercept; PF reference" else "all child indicators; no extra intercept; PF wave effect zero",
      C_reference = "Male; four separate race No; income code 1; education code 1; C main effects absorbed in TWFE",
      sample_rule = rule17, units = "English standard-score points; higher released belief score; PreK/16 and K native",
      weighting = "unweighted", uncertainty = "child CR1 full rank G/(G-1)*(N-1)/(N-k); conditional t(G-1); cross-child dependence unresolved",
      feasibility = "feasible; all declared prefit gates passed")
  }
}
registry <- bind(registry_rows); sample_diagnostics <- bind(sample_rows); variation_diagnostics <- bind(variation_rows)
check("four_frozen_registry_rows", nrow(registry) == 4L && !anyDuplicated(registry$model) &&
  identical(as.numeric(registry$k), c(36, 775, 36, 790)) && identical(as.numeric(registry$residual_df), c(2733, 1994, 2755, 2001)))

# Synthetic unbalanced fixture: all verification precedes research estimation.
cat("Stage17: synthetic unbalanced fixture, sandwich and permutation gates\n")
fg <- rep(1:6, each = 3L)
fw <- c("PF", "PS", "KF", "PS", "KF", "KS", "PF", "KF", "KS", "PF", "PS", "KS", "PF", "PS", "KF", "PS", "KF", "KS")
fD <- outer(fg, 1:6, "==") * 1; colnames(fD) <- paste0("child_", 1:6)
fW <- outer(fw, waves[-1], "==") * 1; colnames(fW) <- paste0("wave_", waves[-1])
fi <- seq_along(fg); fS <- cbind(belief_common = sin(fi * .7) + fg / 5, class_size = cos(fi * 1.3) + match(fw, waves))
fZ <- cbind(fD, fW); fX <- cbind(fZ, fS)
fy <- 3 + fg * .4 + match(fw, waves) * .7 + fS[, 1] * .8 - fS[, 2] * .3 + sin(fi * 1.9)
check("fixture_ranks", rank_gate(fZ, 9L)$rank == 9L && rank_gate(fX, 11L)$rank == 11L && graph_components(fg, fw) == 1L)
ff <- qr_cluster(fX, fy, fg); fr <- sequential(cbind(y = fy, fS), fW, fg)
fa <- qr_cluster(fr[, -1, drop = FALSE], fr[, 1], fg, full_k = 11L)
ft <- c("belief_common", "class_size")
compare("fixture_coefficients", ff$beta[ft], fa$beta)
compare("fixture_residuals", ff$residual, fa$residual)
compare("fixture_CR0", ff$V0[ft, ft], fa$V0)
compare("fixture_CR1", ff$V[ft, ft], fa$V)
check("fixture_full_rank_correction", ff$n == 18L && ff$G == 6L && ff$k == 11L && ff$residual_df == 7L &&
  near(ff$correction, 2.9142857142857141), ff$correction, 2.9142857142857141)
Omega <- outer(fg, fg, "==") * outer(ff$residual, ff$residual)
independent_bread <- qr.solve(fX, diag(nrow(fX)), tol = qr_tol)
independent_V0 <- independent_bread %*% Omega %*% t(independent_bread)
compare("fixture_independent_block_sandwich_CR0", ff$V0, independent_V0)
compare("fixture_independent_block_sandwich_CR1", ff$V, independent_V0 * ff$correction)
rp <- rev(seq_along(fg)); cp <- c(11, 4, 2, 10, 7, 1, 9, 3, 6, 5, 8)
fp <- qr_cluster(fX[rp, cp], fy[rp], fg[rp])
compare("fixture_row_column_permutation_beta", fp$beta[names(ff$beta)], ff$beta)
compare("fixture_row_column_permutation_V0", fp$V0[names(ff$beta), names(ff$beta)], ff$V0)
compare("fixture_row_column_permutation_CR1", fp$V[names(ff$beta), names(ff$beta)], ff$V)
fl <- qr_cluster(fX, fy, paste0("cluster", 7 - fg))
compare("fixture_cluster_relabel", fl$V, ff$V)
check("fixture_nontrivial_pivot", !identical(ff$pivot, seq_len(ncol(fX))), paste(ff$pivot, collapse = ";"))
check("fixture_rank_rejection", fails(rank_gate(cbind(fX, duplicate = fX[, 1]), 12L)))
check("fixture_nonfinite_rejection", fails(rank_gate(matrix(c(1, NA_real_, 3, 4), 2L), 2L)))
check("fixture_disconnected_handling", graph_components(rep(1:4, each = 2), rep(c("PF", "PS", "KF", "KS"), each = 2)) == 4L,
  detail = "Disconnected designs are diagnosed and rejected by the research graph gate; no component is silently removed")
fixture_full_fitted <- fy - as.vector(project(decomp(fZ), fy - as.vector(fS %*% fa$beta)))
compare("fixture_full_fitted_recovery", fixture_full_fitted, ff$fitted)
check("fixture_shortcut_detected", max(abs(sequential(fS, fW, fg) -
  (demean(fS, fg) - (fS - demean(fS, fw)) + matrix(colMeans(fS), 18, 2, byrow = TRUE)))) > 1e-4)

# Exactly four registered research fits; explicit TWFE QR verifies the same model.
cat("Stage17: estimating the four registered models\n")
historical_full <- read_csv("output/tables/stage16_full_coefficients.csv")
historical_fit <- read_csv("output/tables/stage16_fit_diagnostics.csv")
coefficient_rows <- list(); fit_rows <- list(); numerical_rows <- list()
coefficient_table <- function(f, o, model, hash, terms, source, sample, term_order) {
  beta <- unname(f$beta[terms]); se <- sqrt(diag(f$V)[terms]); statistic <- beta / se
  p <- 2 * pt(-abs(statistic), f$reference_df); critical <- qt(.975, f$reference_df)
  check("conditional_uncertainty_valid", all(is.finite(c(beta, se, p))) && all(se > 0) && all(p >= 0 & p <= 1), outcome = o, model = model)
  data.frame(outcome = o, model, source, sample, term_order, term = terms,
    estimate = beta, std_error = unname(se), statistic = unname(statistic), p_conditional = unname(p),
    lower_95 = unname(beta - critical * se), upper_95 = unname(beta + critical * se),
    n = f$n, G = f$G, k = f$k, residual_df = f$residual_df, reference_df = f$reference_df,
    correction = f$correction, membership_sha256 = hash,
    units = ifelse(terms == "belief_common", "English standard-score points per higher released belief score (PreK/16; K native)",
      "English standard-score points per declared indicator/unit"), uncertainty = "conditional child-cluster CR1; t(G-1)")
}
for (o in outcomes) {
  s <- samples[[o]]; d <- designs[[o]]; yy <- s$y; g <- s$group
  rr <- registry[registry$outcome == o, ]; idT <- rr$model[1]; idF <- rr$model[2]
  # Two independently assembled ordered analysis views, exact (not tolerance) equality.
  viewT <- list(rows = which(s$mask), y = yy, belief = d$tfe[, "belief_common"], class_size = d$tfe[, "class_size"], cluster = g)
  viewF <- list(rows = which(s$mask), y = s$y, belief = d$full[, "belief_common"], class_size = d$full[, "class_size"], cluster = ids[s$mask])
  check("exact_matched_ordered_views", identical(viewT, viewF), outcome = o)
  tfit <- qr_cluster(d$tfe, yy, g)
  residualized <- sequential(cbind(y = yy, d$slopes), d$W, g)
  afit <- qr_cluster(residualized[, -1, drop = FALSE], residualized[, 1], g, full_k = rr$k[2])
  explicit <- qr_cluster(d$full, yy, g)
  slope_names <- colnames(d$slopes)
  compare("explicit_FWL_slopes", explicit$beta[slope_names], afit$beta, o, idF)
  compare("explicit_FWL_residuals", explicit$residual, afit$residual, o, idF)
  compare("explicit_FWL_CR0", explicit$V0[slope_names, slope_names], afit$V0, o, idF)
  compare("explicit_FWL_CR1", explicit$V[slope_names, slope_names], afit$V, o, idF)
  # Absorbed fitted values predict M_Z Y. Restore P_Z(Y-X beta) before full-fit comparisons.
  raw_slope_fit <- as.vector(d$slopes %*% afit$beta)
  remainder <- yy - raw_slope_fit
  fe_contribution <- remainder - as.vector(project(d$qZ, remainder))
  full_fitted <- fe_contribution + raw_slope_fit
  compare("original_scale_full_fitted", full_fitted, explicit$fitted, o, idF)
  compare("residualized_fitted", afit$fitted, as.vector(project(d$qZ, explicit$fitted)), o, idF)
  compare("original_Y_reconstruction", yy, full_fitted + afit$residual, o, idF)
  compare("residualized_Y_reconstruction", residualized[, 1], afit$fitted + afit$residual, o, idF)
  compare("full_residual_for_absorbed_covariance", yy - full_fitted, afit$residual, o, idF)
  for (kind in c("TFE", "TWFE")) {
    f <- if (kind == "TFE") tfit else afit
    x <- if (kind == "TFE") d$tfe else d$full
    model <- if (kind == "TFE") idT else idF
    residual <- if (kind == "TFE") tfit$residual else yy - full_fitted
    normal <- scaled_orthogonality(x, residual, yy)
    check("full_normal_orthogonality", normal <= numeric_tol, normal, numeric_tol, o, model)
    check("finite_symmetric_covariance", all(is.finite(f$V)) && near(f$V, t(f$V)) && all(diag(f$V) >= 0), outcome = o, model = model)
    reg <- rr[rr$model == model, ]
    check("counts_rank_df_correction", f$n == reg$n && f$G == reg$G && f$k == reg$k &&
      f$residual_df == reg$residual_df && f$reference_df == reg$reference_df && near(f$correction, reg$correction), outcome = o, model = model)
    check("expected_rounded_multiplier", abs(f$correction -
      (if (o == "PPVT") if (kind == "TFE") 1.0141234833 else 1.3899696489 else
        if (kind == "TFE") 1.0139958887 else 1.3960812961)) <= 0.000000000051, outcome = o, model = model)
    if (kind == "TFE") {
      compare("TFE_Y_reconstruction", yy, tfit$fitted + residual, o, model)
      # Independent two-slope FWL check in the matched time-FE design.
      keep <- !colnames(d$tfe) %in% slope_names
      rz <- decomp(d$tfe[, keep, drop = FALSE])
      tx <- project(rz, d$tfe[, slope_names]); ty <- project(rz, yy)
      tb <- qr.solve(tx, ty, tol = qr_tol)
      compare("TFE_independent_FWL_slopes", tfit$beta[slope_names], tb, o, model)
    }
    # Explicit covariance uses original-model residuals. The FWL residual agrees above;
    # independently rebuild absorbed influences with recovered full residuals as required.
    if (kind == "TWFE") {
      aq <- decomp(d$rs); aQ <- qr.Q(aq); aR <- qr.R(aq)
      ai <- backsolve(aR, t(rowsum(aQ * residual, g, reorder = FALSE)))
      v0 <- matrix(0, 2L, 2L); v0[aq$pivot, aq$pivot] <- tcrossprod(ai)
      compare("recovered_full_residual_CR0", v0, afit$V0, o, model)
      check("residualized_regressor_orthogonality", scaled_orthogonality(d$rs, residual, residualized[, 1]) <= numeric_tol, outcome = o, model = model)
    }
    terms <- if (kind == "TFE") colnames(d$tfe) else slope_names
    coefficient_rows[[length(coefficient_rows) + 1L]] <- coefficient_table(f, o, model, s$hash, terms,
      "new Stage17", "AC2", if (kind == "TFE") seq_along(terms) else (ncol(d$Z) + seq_along(terms)))
    rss <- sum(residual^2); tss <- sum((yy - mean(yy))^2)
    Zfit <- if (kind == "TFE") d$tfe[, !colnames(d$tfe) %in% slope_names, drop = FALSE] else d$Z
    nuisance_y <- project(decomp(Zfit), yy); denominator <- sum(nuisance_y^2)
    fit_rows[[length(fit_rows) + 1L]] <- data.frame(outcome = o, model, source = "new Stage17", sample = "AC2",
      n = f$n, G = f$G, k = f$k, residual_df = f$residual_df, reference_df = f$reference_df,
      correction = f$correction, rss, tss, R2_total = 1 - rss / tss,
      nuisance_adjusted_denominator = denominator, R2_nuisance_adjusted = 1 - rss / denominator,
      nuisance_Z = if (kind == "TFE") "intercept + 30 C indicators + PS/KF/KS" else "all child indicators + PS/KF/KS",
      belief_estimate = unname(f$beta["belief_common"]), class_size_estimate = unname(f$beta["class_size"]),
      compared_to = if (kind == "TFE") "M14" else idT,
      comparison_step = if (kind == "TFE") "1: full-AC M14 -> AC2 matched time-FE: sample restriction" else
        "2: AC2 matched time-FE -> AC2 matched TWFE: specification change on identical rows",
      belief_numerical_difference = NA_real_, class_size_numerical_difference = NA_real_,
      membership_sha256 = s$hash)
    numerical_rows[[length(numerical_rows) + 1L]] <- data.frame(outcome = o, model,
      max_scaled_normal_error = normal, covariance_asymmetry = max(abs(f$V - t(f$V))), minimum_variance = min(diag(f$V)),
      max_explicit_FWL_slope_difference = if (kind == "TWFE") max(abs(explicit$beta[slope_names] - afit$beta)) else max(abs(tfit$beta[slope_names] - tb)),
      max_explicit_FWL_residual_difference = if (kind == "TWFE") max(abs(explicit$residual - afit$residual)) else NA_real_,
      max_explicit_FWL_full_fitted_difference = if (kind == "TWFE") max(abs(explicit$fitted - full_fitted)) else NA_real_,
      max_explicit_FWL_CR0_difference = if (kind == "TWFE") max(abs(explicit$V0[slope_names, slope_names] - afit$V0)) else NA_real_,
      max_explicit_FWL_CR1_difference = if (kind == "TWFE") max(abs(explicit$V[slope_names, slope_names] - afit$V)) else NA_real_)
  }
  check("same_sample_nested_RSS", sum(afit$residual^2) <= sum(tfit$residual^2) + numeric_tol *
    max(1, sum((yy - mean(yy))^2), sum(tfit$residual^2), sum(afit$residual^2)), outcome = o)
  h <- historical_full[historical_full$outcome == o & historical_full$model == "M14" & historical_full$term %in% slope_names, ]
  h <- h[match(slope_names, h$term), ]; check("two_copied_historical_terms", nrow(h) == 2L && !anyNA(h$estimate), outcome = o)
  check("historical_belief_reference", abs(h$estimate[1] - if (o == "PPVT") -1.0524330866 else -0.6439797420) <= 0.000000000051, outcome = o)
  hrows <- data.frame(outcome = o, model = "M14", source = "copied accepted Stage16; never refitted", sample = "AC",
    term_order = h$term_order, term = h$term, estimate = h$estimate, std_error = h$std_error, statistic = h$statistic,
    p_conditional = h$p_conditional, lower_95 = h$lower_95, upper_95 = h$upper_95,
    n = h$n, G = h$G, k = h$k, residual_df = h$residual_df, reference_df = h$reference_df,
    correction = h$correction, membership_sha256 = h$membership_sha256, units = h$units,
    uncertainty = "conditional child-cluster CR1; t(G-1)")
  coefficient_rows[[length(coefficient_rows) + 1L]] <- hrows
  hf <- historical_fit[historical_fit$outcome == o & historical_fit$model == "M14", ]
  for (i in seq_along(fit_rows)) if (fit_rows[[i]]$outcome == o) {
    previous <- if (fit_rows[[i]]$model == idT) h$estimate else tfit$beta[slope_names]
    fit_rows[[i]]$belief_numerical_difference <- fit_rows[[i]]$belief_estimate - previous[1]
    fit_rows[[i]]$class_size_numerical_difference <- fit_rows[[i]]$class_size_estimate - previous[2]
  }
  fit_rows[[length(fit_rows) + 1L]] <- data.frame(outcome = o, model = "M14", source = "copied accepted Stage16; never refitted", sample = "AC",
    n = hf$n, G = hf$G, k = hf$k, residual_df = hf$residual_df, reference_df = hf$reference_df, correction = hf$correction,
    rss = hf$rss, tss = hf$tss, R2_total = hf$r_squared,
    nuisance_adjusted_denominator = NA_real_, R2_nuisance_adjusted = NA_real_, nuisance_Z = "historical adjusted fit not computed",
    belief_estimate = h$estimate[1], class_size_estimate = h$estimate[2], compared_to = "",
    comparison_step = "historical main specification; full AC", belief_numerical_difference = NA_real_,
    class_size_numerical_difference = NA_real_, membership_sha256 = hf$membership_sha256)
}
coefficients <- bind(coefficient_rows); fit_comparisons <- bind(fit_rows); numerical <- bind(numerical_rows)
for (i in seq_len(nrow(numerical))) for (j in setdiff(names(numerical), c("outcome", "model"))) {
  if (!is.na(numerical[[j]][i])) add_variation(numerical$outcome[i], paste(numerical$model[i], j, sep = "_"), numerical[[j]][i])
}
variation_diagnostics <- bind(variation_rows)
check("result_counts", nrow(coefficients) == 80L && nrow(fit_comparisons) == 6L && nrow(registry) == 4L,
  c(nrow(coefficients), nrow(fit_comparisons), nrow(registry)), c(80, 6, 4))
check("unique_result_keys", !anyDuplicated(coefficients[c("outcome", "model", "term")]) &&
  !anyDuplicated(fit_comparisons[c("outcome", "model")]) && !anyDuplicated(sample_diagnostics[c("outcome", "sample", "metric")]) &&
  !anyDuplicated(variation_diagnostics[c("outcome", "metric")]))

fmt <- function(x) sprintf("%.6f", x)
make_report <- function(ct, rg, sd, vd, fc) {
  report <- c("# Stage 17: focused child-and-time fixed-effects sensitivity", "",
    "Stage 16 full-AC M14 remains the paper's main specification. Exactly four registered Stage 17 models were estimated. The two explicit TWFE fits verify the same registered absorbed models. No additional specification was searched.", "",
    "## Belief and class-size associations", "",
    "Unweighted English standard-score points. Belief means a higher released belief score: Pre-K T_IDEAP/16 assigned to PF/PS; Kindergarten T_IDEAK assigned to KF/KS. All uncertainty below is conditional child-cluster CR1 with t(G-1); no significance stars.", "",
    "| Outcome | Model / sample | Term | Estimate | Conditional SE | 95% interval | Two-sided conditional p |",
    "|---|---|---|---:|---:|---|---:|")
  for (o in outcomes) for (m in c("M14", rg$model[rg$outcome == o])) {
    rows <- ct[ct$outcome == o & ct$model == m & ct$term %in% c("belief_common", "class_size"), ]
    for (i in seq_len(nrow(rows))) {
      a <- rows[i, ]
      report <- c(report, paste0("| ", o, " | ", m, " / ", a$sample, " | ", a$term, " | ", fmt(a$estimate), " | ",
        fmt(a$std_error), " | [", fmt(a$lower_95), ", ", fmt(a$upper_95), "] | ", sprintf("%.6g", a$p_conditional), " |"))
    }
  }
  report <- c(report, "", "## Two separate numerical comparisons", "",
    "Differences are later minus earlier coefficients. No test, standard error, interval, or significance comparison is attached to these differences.", "",
    "| Outcome | Comparison | Belief difference | Class-size difference |",
    "|---|---|---:|---:|")
  for (i in which(fc$source == "new Stage17")) report <- c(report, paste0("| ", fc$outcome[i], " | ", fc$comparison_step[i],
    " | ", fmt(fc$belief_numerical_difference[i]), " | ", fmt(fc$class_size_numerical_difference[i]), " |"))
  report <- c(report, "", "## Samples, inference and fit", "",
    "AC2 retains every accepted AC child with at least two AC observations, including incomplete histories; neither both reports nor four occasions are required. PPVT excludes 105 singleton rows/children and Applied Problems excludes 93. Source missingness and attributes are preserved. Eight Pre-K Applied Problems practice failures remain excluded. C coding and C-complete eligibility match Stage 16; class size is observed at the corresponding occasion.", "",
    "| Outcome | Model | N | G | Full rank k | Residual df | Reference df | CR1 factor | RSS | Total centered R2 | Nuisance-adjusted R2 |",
    "|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
  for (i in seq_len(nrow(fc))) {
    a <- fc[i, ]
    report <- c(report, paste0("| ", a$outcome, " | ", a$model, " | ", a$n, " | ", a$G, " | ", a$k, " | ",
      a$residual_df, " | ", a$reference_df, " | ", sprintf("%.10f", a$correction), " | ", fmt(a$rss), " | ", fmt(a$R2_total),
      " | ", if (is.na(a$R2_nuisance_adjusted)) "NA" else fmt(a$R2_nuisance_adjusted), " |"))
  }
  report <- c(report, "",
    "TSS = sum((Y-mean(Y))^2); R2_total = 1-RSS/TSS, on each model's own sample. For the new matched models, R2_nuisance_adjusted = 1-RSS/sum((M_Z Y)^2): Z is intercept + 30 C indicators + PS/KF/KS for time-FE, and all child indicators + PS/KF/KS for TWFE. These different denominators do not measure directly comparable fit improvements. Historical adjusted R2 is unavailable and is explicitly NA. Same-sample time-FE column space is contained in TWFE and TWFE RSS is no larger within the declared scaled tolerance.", "",
    "CR1 = [G/(G-1)]*[(N-1)/(N-k)] times CR0. Full rank counts absorbed child and wave effects, including child effects nested in child clusters; the absorbed calculation does not use k=2. Conditional p-values are two-sided and intervals use t(G-1).", "",
    "## Feasibility and numerical verification", "",
    "All numbers in the diagnostic CSVs are freshly computed unless explicitly described as historical. All 20 accepted Stage 16 signatures and both registered AC2 signatures match. Numeric-ID then PF/PS/KF/KS order is fixed. Both child-occasion graphs are connected; nuisance ranks are 773/788, full TWFE ranks 775/790, residualized slope rank two, and belief adds one rank conditional on class size. All 30 C columns are exactly constant within child and absorbed.", "",
    "Ranks use unit-normalized columns with QR tolerance 1e-7 and singular-value ratios, plus machine threshold max(N,p)*epsilon. Agreement tolerance is abs(a-b) <= 1e-10*max(1,abs(a),abs(b)); orthogonality uses column/response norms and RSS uses max(1,TSS,RSS1,RSS2). Remaining belief-SS fractions exceed the declared 1e-4 weak-variation threshold. The synthetic unbalanced fixture, independent block sandwich, row/column permutations, cluster relabeling, nontrivial pivoting, rank rejection and disconnected-graph diagnostics pass before research fitting.", "",
    "The projection first demeans by child, then projects on child-demeaned PS/KF/KS using QR. Explicit-indicator QR and independent alternating projections agree. Full fitted values restore P_Z(Y-X beta) to the raw slope fit; absorbed fitted values predict M_Z Y. Both reconstructions and CR0/CR1 slope covariances agree. No single subtraction of child and wave means is used.", "",
    "| Outcome | Model | Maximum slope difference | Maximum full fitted difference | Maximum CR0 difference | Maximum CR1 difference |",
    "|---|---|---:|---:|---:|---:|")
  for (o in outcomes) {
    model <- rg$model[rg$outcome == o & grepl("TWFE$", rg$model)]
    value <- function(metric) vd$value[vd$outcome == o & vd$metric == paste(model, metric, sep = "_")]
    report <- c(report, paste0("| ", o, " | ", model, " | ", sprintf("%.6g", value("max_explicit_FWL_slope_difference")),
      " | ", sprintf("%.6g", value("max_explicit_FWL_full_fitted_difference")), " | ", sprintf("%.6g", value("max_explicit_FWL_CR0_difference")),
      " | ", sprintf("%.6g", value("max_explicit_FWL_CR1_difference")), " |"))
  }
  c(report, "", "## Interpretation and remaining limits", "",
    "Child effects absorb additive time-invariant child components. They do not remove child-specific changes associated with the Kindergarten transition, including changes in curriculum, peers, schools, or other changing confounders, and do not establish causality. Cross-grade belief scale equivalence and released score direction remain unverified. Fall reports assigned within grade do not establish teacher/exposure correspondence or assessment/report timing. Descriptor timing, selected C/class-size/AC2 samples, attrition, missingness, and unweighted representation remain limitations. Standard-score changes are not absolute learning growth.", "",
    "Child clustering permits within-child dependence under working assumptions. Cross-child teacher/classroom/site dependence and independent-cluster assumptions remain unresolved; the uncertainty is neither design-validated nor established conservative. A change in significance labels would not be a formal test of coefficient differences. M14 remains the main specification regardless of these sensitivity estimates. No manuscript change is part of this batch.")
}

check("all_destinations_absent_before_publication", !any(file.exists(here::here(dest))))
check("objects_preserved_before_publication", objects_preserved())
check("files_preserved_before_publication", preserved(), length(before))
check("git_preserved_before_publication", git_preserved())
tables <- list(registry, sample_diagnostics, variation_diagnostics, coefficients, fit_comparisons)
report <- unname(make_report(coefficients, registry, sample_diagnostics, variation_diagnostics, fit_comparisons))
# Test typed serialization in an external temporary file before production writes.
for (i in seq_along(tables)) {
  p <- tempfile("stage17_roundtrip_", tmpdir = dirname(tempdir()), fileext = ".csv")
  con <- file(p, "wb"); writeBin(charToRaw(paste0(paste(csv_text(tables[[i]])$lines, collapse = "\n"), "\n")), con); close(con)
  invisible(readback(p, tables[[i]], record = FALSE)); unlink(p)
}
check("prepublication_typed_roundtrips", TRUE)
disk <- list()
for (i in seq_along(tables)) {
  write_exclusive(csv_text(tables[[i]])$lines, dest[i])
  disk[[i]] <- readback(here::here(dest[i]), tables[[i]])
}
for (model in registry$model) {
  a <- disk[[4]][disk[[4]]$model == model, ]
  check("exported_inference", near(a$p_conditional, 2 * pt(-abs(a$estimate / a$std_error), a$reference_df)) &&
    near(a$lower_95, a$estimate - qt(.975, a$reference_df) * a$std_error) &&
    near(a$upper_95, a$estimate + qt(.975, a$reference_df) * a$std_error) &&
    near(a$correction, a$G / (a$G - 1) * (a$n - 1) / (a$n - a$k)), model = model)
}
check("report_regenerated_from_verified_readback", identical(report,
  unname(make_report(disk[[4]], disk[[1]], disk[[2]], disk[[3]], disk[[5]]))))
write_exclusive(report, dest[6])
check("report_exact_readback", identical(report, readLines(here::here(dest[6]), encoding = "UTF-8", warn = FALSE)))
check("exclusive_existing_destination_rejected", fails(write_exclusive("never overwrite", dest[1])))
check("objects_preserved_after_publication", objects_preserved())
check("files_preserved_after_publication", preserved(), length(before))
check("git_preserved_after_publication", git_preserved())
check("eight_outputs_ignored_untracked", all(vapply(dest, ignored, logical(1))) && !length(git(c("ls-files", "--", dest))))
check("tracked_whitespace", !length(git(c("diff", "--check"))) && !length(git(c("diff", "--cached", "--check"))))
ledger <- bind(checks)
stopifnot(all(ledger$status == "pass"), !anyDuplicated(ledger$check_id))
write_exclusive(csv_text(ledger)$lines, dest[7]); invisible(readback(here::here(dest[7]), ledger, record = FALSE))
note <- c("# Stage 17 verification and unresolved record", "",
  paste0("Execution start: ", start_time, ". ", R.version.string, "; here ", packageVersion("here"), "; renv ", packageVersion("renv"),
    ". Existing Python hashlib only; no installation or lockfile changes. Earlier analysis scripts were never sourced or run."), "",
  "## Execution and review scope", "", "```powershell", "$env:LC_ALL = 'English_United States.utf8'",
  "& 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla 'code/revision/17_estimate_twfe_sensitivity.R'", "```", "",
  paste0("Successful completion emits Stage17 PASS and exits 0; the caller independently records actual exit status. Exactly four registered models, 80 coefficient rows (including four copied historical terms), six fit rows, ",
    nrow(sample_diagnostics), " sample diagnostics, ", nrow(variation_diagnostics), " variation diagnostics, and ", nrow(ledger),
    " unique passing checks. No substantive failure remains. No staging, commit, push, registry expansion, manuscript edit, data acquisition, or dependency installation."), "",
  "## Accepted inputs and provenance", "",
  "The repository root, expected branch and HEAD are verified before construction. The accepted Stage 16 script and verification note are pinned; 22 accepted input receipts and eight recorded artifact pins match. The note's own accepted hash was independently captured at preflight. The historical Stage 16 ledger has 588 unique passing checks; these are inspected historical evidence, not rerun checks. All four source objects retain identical serialized values, attributes and source missingness. Setup.do/Setup.dct and the accepted characteristic inventory authenticate descriptor labels, missing codes and references. Keyed released/wide/structural/clean-panel values agree. Outcome cleaning and the eight Pre-K Applied Problems -7 exclusions are independently checked.", "",
  "| Accepted path | SHA-256 |", "|---|---|",
  paste0("| ", c("code/revision/16_estimate_time_fixed_effects.R", note16_path), " | ",
    c(sha_file("code/revision/16_estimate_time_fixed_effects.R"), sha_file(note16_path)), " |"),
  vapply(all_receipts, function(z) paste0("| ", z[1], " | ", z[2], " |"), ""), "",
  "## Canonical membership", "",
  paste0("Universe SHA-256: ", universe_sha, ". Numeric ascending STUDY_ID, then PF/PS/KF/KS. Universe bytes are UTF-8 LF-terminated: first line stage16-child-wave-universe-v1, then ID|wave for 4,060 rows. No identifiers or membership bits are exported."), "",
  paste0("Membership bytes are these LF-terminated lines in exact order: format=stage17-membership-sha256-v1; outcome=<PPVT or Applied_Problems>; sample=AC2; rule=", rule17,
    "; wide_sha256=<hash>; panel_sha256=<hash>; universe_sha256=<hash>; universe_n=4060; membership=<4060 concatenated 0/1 digits>. Semicolons here denote line breaks. No BOM, CR, extra spaces or extra blank line. AC2 is accepted AC intersected with child AC count >=2. The 20 historical signatures use the unchanged Stage 16 format/rule and all match."), "",
  paste0("| ", outcomes, " | ", expected_hash[outcomes], " |"), "",
  "## Numerical definitions and gates", "",
  "Sequential FWL first residualizes against child indicators by exact child means, then projects on child-demeaned PS/KF/KS via QR. No cross-product inversion or one-pass child/time demeaning is used. Slope fitting and cluster influences use pivoted LAPACK QR and triangular solves, with coefficients/covariances mapped back to declared order. Absorbed covariance uses full-model residuals. Full fitted values recover P_Z(Y-X beta) plus X beta, separately from residualized fitted values. Explicit-indicator QR independently verifies coefficients, residuals, fitted reconstructions, CR0 and CR1 slope blocks.", "",
  "Normalized rank QR tolerance is 1e-7; machine rank threshold max(N,p)*epsilon; required singular-value ratio >1e-7 and equal ranks. All gates pass. Weak variation threshold is final conditional belief SS / centered belief SS <1e-4: neither outcome flags. Near equality is abs(a-b)<=1e-10*max(1,abs(a),abs(b)). Orthogonality scales by column and response norms; nested RSS uses max(1,TSS,RSS1,RSS2). Six-decimal historical feasibility SS is compared only at its recorded rounding precision, without changing numerical agreement tolerances.", "",
  "The synthetic fixture is unbalanced N=18/G=6, nuisance rank 9, full rank 11, residual df 7, CR1=2.9142857142857141. An independent QR bread and full block-diagonal residual outer-product sandwich agree. Row/column permutations, cluster relabeling, nontrivial pivoting, exact rank rejection, nonfinite rejection and disconnected-graph diagnostics pass before research fitting. No disconnected component is dropped.", "",
  "CR1 is G/(G-1)*(N-1)/(N-k), full k including absorbed child and wave effects even when nested in child clusters. Reference df G-1; two-sided conditional p-values/95% t intervals. No invalid variance is truncated, no tolerance relaxed, and no coefficient-difference test is performed. Total centered R2 and the two explicitly different nuisance-adjusted denominators are defined in the report and exported fit table.", "",
  "## Export verification", "",
  "Five result CSVs and the ledger have exact typed readback. Numeric serialization uses sprintf(%.17g); missing fields are quoted NA (read as missing using the declared original types), empty character fields are quoted empty strings. No actual character value is the reserved NA sentinel. The report is regenerated from verified disk tables and checked line-for-line. All nine artifacts use UTF-8-compatible text, LF endings, one final newline, and no blank EOF line. Writers exclusively create absent paths and reject existing destinations. All checks complete before publication except readback/preservation checks. No child-level records, membership masks, effects, residuals, fitted values or model objects are written.", "",
  "## Preservation audit", "",
  paste0(length(before), " execution-start files, including this new script, retain identical SHA-256 inventories. The caller separately captured all 394 pre-edit project files before creating this script and verifies exactly nine additions afterward. Ignored inputs/outputs, raw data, legacy code, manuscript, environment, lockfile and all accepted work remain unchanged. Git index byte hash: ", index_sha, "."), "",
  paste0("HEAD ", head_before, "; branch ", branch_before, ". HEAD, branch, full index entries, index byte hash and execution-start Git status remain unchanged. All eight outputs are ignored and untracked; the script remains untracked. The safe.directory exception is command-local for read-only Git and changes no persistent configuration."), "",
  "Read-only Git commands: rev-parse --show-toplevel; rev-parse HEAD; branch --show-current; status --short --branch; ls-files --stage; rev-parse --git-path index; ls-files -- <outputs>; check-ignore -q -- <each output>; diff --check; diff --cached --check.", "",
  "## Failures, resolutions and unresolved evidence", "",
  "An initial read-only PowerShell inspection returned exit 1 because optional parent AGENTS.md paths were absent; the 30 recorded SHA-256 comparisons in that same inspection all passed. The only applicable AGENTS.md is the repository file. No files were changed by that inspection. Later meaningful development attempts, if any, are supplied through STAGE17_DEVELOPMENT_NOTES below.",
  Sys.getenv("STAGE17_DEVELOPMENT_NOTES", "No failed Stage 17 execution attempts preceded this successful run."), "",
  "Both outcomes are feasible, so no unavailable-slope substitution or infeasibility report is needed. Computational issues remaining: none. Substantive uncertainties remain: released belief score direction and construction; cross-grade equivalence; assigned Fall reports and exposure/assessment timing; descriptor timing; child-specific Kindergarten-transition changes; changing confounders; selected samples/missingness/attrition; unweighted representation; cross-child teacher/classroom/site dependence. Child effects absorb additive time-invariant components only. Conditional uncertainty is not design-valid or known conservative, and standard-score changes are not absolute learning growth. M14 remains main irrespective of signs or uncertainty.", "",
  "## Artifact fingerprints", "", "| Path | Bytes | SHA-256 |", "|---|---:|---|",
  vapply(c(script_path, dest[1:7]), function(p) paste0("| ", p, " | ", file.info(here::here(p))$size, " | ", sha_file(p), " |"), ""), "",
  "The caller supplies this verification note's own final byte hash and size after exclusive creation; a file cannot contain its own final SHA-256.", "",
  "## Final Git status", "", "```", git(c("status", "--short", "--branch")), "```", "",
  "## Protected SHA-256 inventory (execution start = finish)", "", "| Path | SHA-256 |", "|---|---|",
  vapply(before, function(z) paste0("| ", sub("^[^|]+[|]", "", z), " | ", sub("[|].*$", "", z), " |"), ""))
note <- unname(note)
write_exclusive(note, dest[8])
stopifnot(identical(note, readLines(here::here(dest[8]), encoding = "UTF-8", warn = FALSE)), preserved(), git_preserved(), objects_preserved())
cat("Stage17 PASS:", nrow(ledger), "unique passing checks; four models; 80 coefficient rows; eight outputs;",
  length(before), "protected execution-start files unchanged.\n")
NULL
}, error = function(e) e)
if (inherits(failure, "error")) {
  # Keep partial artifacts. Failure evidence contains aggregate checks only, outside the project.
  p <- tempfile("stage17_failure_", tmpdir = dirname(tempdir()), fileext = ".txt")
  writeLines(c("Stage17 FAILED; no successful-result claim", conditionMessage(failure),
    vapply(checks, function(z) paste(z$check_id, z$status, z$observed, z$expected, sep = " | "), "")), p)
  stop("Stage17 failed: ", conditionMessage(failure), "; aggregate evidence: ", p)
}
