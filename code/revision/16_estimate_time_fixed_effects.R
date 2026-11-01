# Stage 16: frozen pooled OLS / explicit occasion effects; no child fixed effects.
# Existing environment only. Run from the repository root with Rscript --vanilla.
# Never source or rerun Stages 00-15. All child-level construction stays in memory.
project_start <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
git <- function(args) {
  # Same command-local ownership exception used by accepted Stages14/15.
  # It accommodates the R/Windows identity and writes no configuration file.
  z <- system2("git", c("-c",shQuote(paste0("safe.directory=",project_start)),args), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("Git failed: ", paste(args, collapse = " "))
  z
}
stopifnot(identical(normalizePath(git(c("rev-parse", "--show-toplevel"))[1], winslash = "/"), project_start),
  basename(project_start) == "ICPSR_04283")
head_before <- git(c("rev-parse", "HEAD")); branch_before <- git(c("branch", "--show-current"))
index_before <- git(c("ls-files", "--stage")); status_before <- git(c("status", "--short", "--branch"))
script_path <- "code/revision/16_estimate_time_fixed_effects.R"
stopifnot(head_before == "f6112e9c1d94446459c74de7ad96d36101733518",
  identical(git(c("rev-list", "--parents", "-n", "1", "HEAD")),
    paste(head_before, "530d637da394748ae703a38da12456972cbf6d32")),
  branch_before == "codex/restructure-project-layout", !length(git(c("diff", "--cached", "--name-only"))))
Sys.setenv(RENV_PATHS_ROOT = file.path(project_start, "renv", "local"),
  RENV_CONFIG_SANDBOX_ENABLED = "FALSE", RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
source(file.path(project_start, "renv", "activate.R"))
suppressPackageStartupMessages(library(here))
stopifnot(identical(normalizePath(here::here(), winslash = "/"), project_start))
options(stringsAsFactors = FALSE, OutDec = ".", digits = 17, warn = 2)
dest <- c(paste0("output/tables/stage16_", c("model_registry", "sample_flow", "belief_coefficients",
  "full_coefficients", "fit_diagnostics"), ".csv"), "output/reports/stage16_time_fixed_effects.md",
  "output/verification/stage16_checks.csv", "output/verification/stage16_verification_unresolved.md")
ignored <- function(p) identical(system2("git", c("-c",shQuote(paste0("safe.directory=",project_start)),
  "check-ignore", "-q", "--", shQuote(p))), 0L)
stopifnot(!any(file.exists(here::here(dest))), all(dir.exists(here::here(dirname(dest)))),
  all(vapply(dest, ignored, logical(1))), !length(git(c("ls-files", "--", dest))))
inventory_paths <- function() {
  p <- list.files(project_start, recursive = TRUE, all.files = TRUE, include.dirs = FALSE)
  sort(setdiff(p[!grepl("^\\.git/", p)], dest))
}
protected <- inventory_paths(); before <- tools::md5sum(here::here(protected))
start_time <- format(Sys.time(), tz = "UTC", usetz = TRUE)
python <- Sys.getenv("STAGE16_PYTHON", Sys.which("python"))
stopifnot(nzchar(python), file.exists(python))
py <- function(code) {
  z <- system2(python, c("-X", "utf8", "-c", shQuote(code)), stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(z, "status"))) stop("Python helper failed")
  z
}
sha_text <- function(s) {
  # Stream exact UTF-8 bytes through a binary pipe. Only a digest is written to
  # the temporary file; neither IDs nor bits enter files or process arguments.
  p <- tempfile("stage16_digest_",tmpdir=dirname(tempdir()))
  code <- "import sys,hashlib,pathlib;pathlib.Path(sys.argv[1]).write_text(hashlib.sha256(sys.stdin.buffer.read()).hexdigest(),encoding='ascii')"
  con <- pipe(paste(shortPathName(python),"-X utf8 -c",shQuote(code),shQuote(p)),open="wb")
  writeBin(charToRaw(enc2utf8(s)),con); status <- close(con)
  if(status!=0L || !file.exists(p)) stop("SHA-256 memory-pipe helper failed")
  h <- readLines(p,warn=FALSE); unlink(p)
  stopifnot(length(h)==1L,grepl("^[0-9a-f]{64}$",h)); unname(h)
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
check <- function(id, ok, observed = "", expected = "TRUE", outcome = "all", model = "", detail = "") {
  key <- paste(outcome, model, id, sep = ":")
  stopifnot(!key %in% vapply(checks, `[[`, "", "check_id"))
  checks[[length(checks) + 1L]] <<- data.frame(check_id = key, outcome, model,
    status = if (isTRUE(ok)) "pass" else "fail", observed = paste(observed, collapse = ";"),
    expected = paste(expected, collapse = ";"), detail)
  if (!isTRUE(ok)) stop("Stage16 check failed: ", key, "; ", detail)
}
qr_tol <- 1e-7; numeric_tol <- 1e-10
close_numeric <- function(a, b) length(a) == length(b) && all(is.finite(c(a, b))) &&
  all(abs(a - b) <= numeric_tol * pmax(1, abs(a), abs(b)))
same <- function(a, b) identical(is.na(a), is.na(b)) &&
  isTRUE(all.equal(as.vector(a), as.vector(b), check.attributes = FALSE, tolerance = 0))
failed <- function(expr) inherits(tryCatch({ force(expr); NULL }, error = function(e) e), "error")
preserved <- function() identical(before, tools::md5sum(here::here(protected))) && identical(protected, inventory_paths())
git_preserved <- function() identical(head_before, git(c("rev-parse", "HEAD"))) &&
  identical(branch_before, git(c("branch", "--show-current"))) && identical(index_before, git(c("ls-files", "--stage"))) &&
  identical(status_before, git(c("status", "--short", "--branch")))

# Validation and accepted input receipts. Historical ledgers are inspected only.
failure <- tryCatch({
check("stage15_script_pin", sha_file("code/revision/15_estimate_spring_associations.R") ==
  "ee674b6922ae2532500a97fcd03c2c8634aab4f5f126cef2191a935722eeeb78")
old <- read_csv("output/verification/stage15_checks.csv")
check("inherited_stage15_ledger", nrow(old) == 401L && !anyDuplicated(old$check_id) && all(old$status == "pass"),
  nrow(old), 401, detail = "Recorded evidence inspected; no accepted stage rerun")
receipt_lines <- readLines(here::here("output/verification/stage14_verification_unresolved.md"), warn = FALSE)
receipt_lines <- receipt_lines[seq_len(match("## New artifact fingerprints", receipt_lines) - 1L)]
receipt_lines <- receipt_lines[grepl("^\\| [^|]+ \\| [0-9a-f]{64} \\|$", receipt_lines)]
receipts <- lapply(receipt_lines, function(s) trimws(strsplit(s, "|", fixed = TRUE)[[1]][2:3]))
check("sixteen_receipts", length(receipts) == 16L)
for (j in seq_along(receipts)) check(paste0("input_pin_", j), sha_file(receipts[[j]][1]) == receipts[[j]][2], detail = receipts[[j]][1])
wide_path <- "Data/processed/verified_child_wide.rds"
panel_path <- "Data/processed/outcome_cleaning_panel.rds"
struct_path <- "Data/processed/structural_child_wave_panel.rds"
raw_path <- "Data/raw/icpsr_04283/04283-0001-Data.rda"
wide_sha <- sha_file(wide_path); panel_sha <- sha_file(panel_path)
check("analysis_input_pins", wide_sha == "a4b4a9d662093345ea65badd51e47ac08d73e3e8eebd4dec211bbe3523be2952" &&
  panel_sha == "647d516b29abf647f6545caae662354752650d0596093ddc16277b2618486cf7")
check("raw_accepted_md5", unname(tools::md5sum(here::here(raw_path))) == "e1dd29c3fe46e0ac1ebb90f51ef041d3")
check("hash_known_answer", sha_text("abc") == "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
wide <- readRDS(here::here(wide_path)); panel <- readRDS(here::here(panel_path)); structural <- readRDS(here::here(struct_path))
raw_env <- new.env(parent = emptyenv()); raw_names <- load(here::here(raw_path), envir = raw_env)
stopifnot(identical(raw_names, "da04283.0001")); released <- raw_env[[raw_names]]
original_objects <- lapply(list(wide, panel, structural, released), serialize, connection = NULL)
objects_preserved <- function() identical(original_objects, lapply(list(wide, panel, structural, released), serialize, connection = NULL))
check("dimensions", identical(dim(wide), c(1015L,62L)) && identical(dim(panel), c(4060L,65L)) &&
  identical(dim(structural), c(4060L,37L)) && identical(dim(released), c(1015L,1210L)))
prov <- read_csv("output/tables/verified_wide_provenance.csv")
panel_prov <- read_csv("output/tables/structural_panel_provenance.csv")
characteristic_inventory <- read_csv("output/tables/stage08_characteristic_inventory.csv")
rules <- read_csv("output/tables/outcome_cleaning_rules.csv"); counts07 <- read_csv("output/tables/outcome_cleaning_counts.csv")
setup <- readLines(here::here("docs/icpsr/DS0001/04283-0001-Setup.do"), warn = FALSE)
dictionary <- readLines(here::here("docs/icpsr/DS0001/04283-0001-Setup.dct"), warn = FALSE)

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

# Reauthenticate released-to-wide-to-structural-to-clean-panel lineage by keys.
waves <- c("PF", "PS", "KF", "KS")
raw_ix <- match(wide$STUDY_ID, released$STUDY_ID)
check("released_keys", !anyNA(raw_ix) && !anyDuplicated(released$STUDY_ID) &&
  setequal(wide$STUDY_ID, released$STUDY_ID))
struct_rows <- setNames(lapply(waves, function(w) align_wave(wide$STUDY_ID, structural, w)), waves)
shuf <- panel[rev(seq_len(nrow(panel))), ]
for (w in waves) check(paste0("shuffled_key_alignment_", w),
  identical(panel[wave_rows[[w]], ], shuf[align_wave(wide$STUDY_ID, shuf, w), ]))
for (f in c(covars, "T_IDEAP", "T_IDEAK")) check(paste0("released_wide_", f),
  same(wide[[f]], released[[f]][raw_ix]) && identical(attributes(wide[[f]]),attributes(released[[f]])))
class_obs <- c(1007L,994L,877L,817L); class_miss <- c(8L,21L,138L,198L)
class_min <- c(9,6,8,6); class_max <- c(32,56,35,38)
class_audit <- list()
for (wi in seq_along(waves)) {
  w <- waves[wi]; src <- paste0("CLS_SIZE", w); v <- wide[[src]]
  validate_lineage("class_size", src, w, check)
  pp <- panel_prov[panel_prov$output_variable == "class_size" & panel_prov$wave == w, ]
  check(paste0("class_release_structural_", w), same(v, released[[src]][raw_ix]) &&
    identical(attributes(v),attributes(released[[src]])) &&
    same(v, structural$class_size[struct_rows[[w]]]) && same(v, panel$class_size[wave_rows[[w]]]),
    detail = paste(pp$source_page_or_section, collapse = ";"))
  check(paste0("class_documented_counts_range_", w), is.numeric(v) && all(is.na(v) | is.finite(v)) &&
    sum(is.finite(v)) == class_obs[wi] && sum(is.na(v)) == class_miss[wi] &&
    min(v, na.rm = TRUE) == class_min[wi] && max(v, na.rm = TRUE) == class_max[wi],
    c(sum(is.finite(v)),sum(is.na(v)),range(v,na.rm=TRUE)),
    c(class_obs[wi],class_miss[wi],class_min[wi],class_max[wi]),
    detail = "Codebook PDF pp.495-496/546-547/761-762/826-827 checked locally; valid PS 56 retained")
  check(paste0("class_missing_setup_", w), any(grepl(paste0("^replace ", src, " = \\. if"), setup)),
    detail = paste(grep(paste0("^replace ", src, " = \\. if"), setup, value = TRUE), collapse = ";"))
  class_audit[[w]] <- data.frame(wave=w,source=src,observed=sum(is.finite(v)),missing=sum(is.na(v)),
    minimum=min(v,na.rm=TRUE),maximum=max(v,na.rm=TRUE))
}

# C: 30 explicit indicators. H: reviewed 12-column grouping plus White inclusion.
C <- cbind(F = indicator(codes$CHGENP, 2L))
for (f in covars[2:5]) C <- cbind(C, indicator(codes[[f]], 1L))
colnames(C) <- c("F","R_AA","R_AS","R_LT","R_NA")
for (i in 2:18) C <- cbind(C, setNames(data.frame(indicator(codes$CHINCOMCP,i)), paste0("I_",sprintf("%02d",i))))
for (i in 2:9) C <- cbind(C, setNames(data.frame(indicator(codes$CHMATEDCP,i)), paste0("E_",sprintf("%02d",i))))
C <- as.matrix(C); H <- X
check("control_columns_and_membership", ncol(C)==30L && ncol(H)==12L &&
  identical(complete.cases(C), complete.cases(H)) && identical(complete.cases(C),complete.cases(codes)))
check("original_C_ignores_White_missingness", identical(complete.cases(C),complete.cases(codes[covars[c(1:5,7:8)]])))
for (f in colnames(C)) check(paste0("C_indicator_", f), all(is.na(C[,f]) | C[,f] %in% c(0,1)))
check("fixture_bad_factor_labels", failed(decode(factor("Other"),"CHGENP")))
check("fixture_duplicate_keys", failed(align_wave(wide$STUDY_ID,rbind(panel,panel[1,]),"PF")))
bad_keys <- panel; bad_keys$STUDY_ID[wave_rows$PF[1]] <- -1
check("fixture_unmatched_keys", failed(align_wave(wide$STUDY_ID,bad_keys,"PF")))

# Canonical universe: numeric ascending STUDY_ID, then PF/PS/KF/KS within child.
# Hash input is LF-terminated UTF-8; universe identifiers and bits never exported.
ids <- rep(wide$STUDY_ID[ordering], each=4L); wave <- rep(waves,nrow(wide))
ix_wide <- rep(ordering,each=4L)
ix_panel <- match(paste(ids,wave),paste(panel$STUDY_ID,as.character(panel$wave)))
universe_sha <- sha_text(paste0("stage16-child-wave-universe-v1\n",paste(paste(ids,wave,sep="|"),collapse="\n"),"\n"))
rule_id <- "stage16_A_eligible_finite_own_grade_report_complete_C_B_grade_pair_AC_finite_class_v1"
signature <- function(mask, outcome, sample, rule=rule_id, wh=wide_sha, ph=panel_sha, uh=universe_sha) {
  if (!is.logical(mask) || length(mask)!=4060L || anyNA(mask)) stop("Invalid membership")
  sha_text(paste0("format=stage16-membership-sha256-v1\noutcome=",outcome,"\nsample=",sample,
    "\nrule=",rule,"\nwide_sha256=",wh,"\npanel_sha256=",ph,"\nuniverse_sha256=",uh,
    "\nuniverse_n=4060\nmembership=",paste0(as.integer(mask),collapse=""),"\n"))
}
bp <- wide$T_IDEAP[ix_wide]; bk <- wide$T_IDEAK[ix_wide]; is_p <- wave %in% c("PF","PS")
assigned_native <- ifelse(is_p,bp,bk)
A_score <- ifelse(is_p,bp/16,bk)
BP <- ifelse(is_p,bp,0); BK <- ifelse(is_p,0,bk)
class_size <- panel$class_size[ix_panel]
check("grade_assignment_missingness", same(A_score[is_p],bp[is_p]/16) && same(A_score[!is_p],bk[!is_p]) &&
  identical(is.na(assigned_native),ifelse(is_p,is.na(bp),is.na(bk))) &&
  all(BP[!is_p]==0) && all(BK[is_p]==0) && identical(is.na(BP[is_p]),is.na(bp[is_p])) &&
  identical(is.na(BK[!is_p]),is.na(bk[!is_p])))
for (w in c("PF","KF")) {
  bf <- if(w=="PF") "teacher_modernity_pre_k_fall_released" else "teacher_modernity_kindergarten_fall_released"
  validate_lineage(bf,if(w=="PF") "T_IDEAP" else "T_IDEAK",w,check)
}
check("native_spring_beliefs_preserved_missing", all(is.na(panel$teacher_modernity_pre_k_fall_released[as.character(panel$wave)!="PF"])) &&
  all(is.na(panel$teacher_modernity_kindergarten_fall_released[as.character(panel$wave)!="KF"])))
samples <- list(); responses <- list(); flow <- list()
outcomes <- c("PPVT","Applied_Problems")
outcome_fields <- c(PPVT="ppvt_english_standard_score", Applied_Problems="applied_problems_english_standard_score")
expected_counts <- list(PPVT=list(A=c(2920,880,730,770,700,720),B=c(2734,773,679,679,688,688),AC=c(2874,875,730,759,700,685)),
  Applied_Problems=list(A=c(2930,883,717,766,713,734),B=c(2732,787,665,665,701,701),AC=c(2884,878,717,755,713,699)))
grade_counts <- list(PPVT=c(1500,821,1420,732,1358,679,1376,688,594),
  Applied_Problems=c(1483,818,1447,746,1330,665,1402,701,579))
pair_from_keys <- function(mask) {
  keep <- paste(ids[mask],ifelse(is_p[mask],"P","K"))
  n <- table(keep); paired <- names(n)[n==2L]
  mask & paste(ids,ifelse(is_p,"P","K")) %in% paired
}
summarize_mask <- function(mask, o, label) {
  h <- tabulate(as.integer(table(ids[mask])), nbins=4L)
  data.frame(outcome=o, sample=label, n=sum(mask), G=length(unique(ids[mask])),
    PF=sum(mask & wave=="PF"), PS=sum(mask & wave=="PS"), KF=sum(mask & wave=="KF"), KS=sum(mask & wave=="KS"),
    children_1=h[1],children_2=h[2],children_3=h[3],children_4=h[4],
    rule=rule_id, membership_sha256=signature(mask,o,label), universe_sha256=universe_sha,
    wide_sha256=wide_sha, panel_sha256=panel_sha)
}
for (o in outcomes) {
  field <- outcome_fields[[o]]; src <- if(o=="PPVT") paste0("PPVTE",waves) else paste0("WJ10_SSE",waves)
  for (j in seq_along(waves)) {
    w <- waves[j]; validate_lineage(field,src[j],w,check)
    rows <- wave_rows[[w]]; e <- panel[[paste0(field,"_eligible_current_rules")]][rows]
    y <- panel[[paste0(field,"_clean")]][rows]; reason <- panel[[paste0(field,"_cleaning_reason")]][rows]
    raw <- wide[[src[j]]]; ac <- counts07[counts07$outcome==field & counts07$wave==w,]
    rr <- rules[rules$outcome==field & rules$wave==w,]
    check(paste0("outcome_cleaning_",w), is.logical(e) && !anyNA(e) && is.numeric(y) &&
      all(!e | is.finite(y)) && same(y[e],raw[e]) && all(is.na(y[!e])) &&
      identical(e,reason=="retained_under_current_rules") && identical(is.na(raw),reason=="source_missing_reason_unavailable") &&
      all(reason %in% c("retained_under_current_rules","source_missing_reason_unavailable","practice_failure_project_exclusion")) &&
      nrow(ac)==1L && sum(e)==ac$n_eligible_current_rules && sum(is.na(raw))==ac$n_source_missing &&
      sum(reason=="practice_failure_project_exclusion")==ac$n_practice_failure_project_excluded &&
      nrow(rr)>0L && all(rr$source_variable==src[j]) && same(raw,released[[src[j]]][raw_ix]) &&
      identical(attributes(raw),attributes(released[[src[j]]])), outcome=o)
    if(o=="Applied_Problems" && w %in% c("PF","PS")) check(paste0("practice_failure_",w),
      sum(reason=="practice_failure_project_exclusion")== (if(w=="PF")7L else 1L) &&
      identical(reason=="practice_failure_project_exclusion",!is.na(raw)&raw== -7) &&
      any(rr$rule_id=="practice_failure" & rr$rule_value== -7 & rr$action=="clean_NA_eligible_FALSE",na.rm=TRUE),outcome=o)
  }
  y <- panel[[paste0(field,"_clean")]][ix_panel]; e <- panel[[paste0(field,"_eligible_current_rules")]][ix_panel]
  eligible <- e & is.finite(y); belief_available <- eligible & is.finite(assigned_native)
  A <- belief_available & complete.cases(C)[ix_wide]
  B <- pair_from_keys(A); AC <- A & is.finite(class_size)
  # Independent wide reconstruction, sorted by keys, authenticates exact membership.
  e_w <- sapply(waves,function(w) panel[[paste0(field,"_eligible_current_rules")]][wave_rows[[w]]])
  y_w <- sapply(waves,function(w) panel[[paste0(field,"_clean")]][wave_rows[[w]]])
  b_w <- cbind(wide$T_IDEAP,wide$T_IDEAP,wide$T_IDEAK,wide$T_IDEAK)
  aw <- e_w & is.finite(y_w) & is.finite(b_w) & complete.cases(codes[covars[c(1:5,7:8)]])
  bw <- aw; bw[,1:2] <- aw[,1]&aw[,2]; bw[,3:4] <- aw[,3]&aw[,4]
  cw <- aw & is.finite(as.matrix(wide[paste0("CLS_SIZE",waves)]))
  canon <- function(z) as.vector(t(z[ordering,,drop=FALSE]))
  check("exact_independent_membership", identical(A,canon(aw)) && identical(B,canon(bw)) && identical(AC,canon(cw)),outcome=o)
  check("subsets_and_H_complete_case", all(!B|A) && all(!AC|A) && identical(A,belief_available & complete.cases(H)[ix_wide]),outcome=o)
  masks <- list(universe=rep(TRUE,4060), eligible_outcome=eligible, finite_grade_report=belief_available,
    A=A,B=B,AC=AC,A_PreK=A&is_p,A_K=A&!is_p,B_PreK=B&is_p,B_K=B&!is_p)
  samples[[o]] <- masks; responses[[o]] <- y
  for (label in names(masks)) {
    z <- summarize_mask(masks[[label]],o,label); flow[[paste(o,label)]] <- z
    check(paste0("history_reconciliation_",label), sum(z[1,paste0("children_",1:4)]*1:4)==z$n &&
      sum(z[1,paste0("children_",1:4)])==z$G && sum(z[1,waves])==z$n,outcome=o)
    if(label %in% c("A","B","AC")) check(paste0("expected_sample_",label),
      identical(as.numeric(z[1,c("n","G",waves)]),expected_counts[[o]][[label]]),
      as.numeric(z[1,c("n","G",waves)]),expected_counts[[o]][[label]],outcome=o)
  }
  actual <- unlist(lapply(masks[c("A_PreK","A_K","B_PreK","B_K")],function(m)c(sum(m),length(unique(ids[m])))),use.names=FALSE)
  actual <- c(actual,length(intersect(unique(ids[B&is_p]),unique(ids[B&!is_p]))))
  check("expected_grade_counts", identical(as.numeric(actual),grade_counts[[o]]),actual,grade_counts[[o]],outcome=o)
  # Authenticate B against accepted Stage15/14 child-level masks, using their exact signature format.
  pins <- c(PPVT_P="a72ecd748608e3a28107afa5f3998eaac8055a36b3b0b1d1c48d01b6bdf1fa3d",
    PPVT_K="e1727c34dafce102324337435ff6067b8aa12a1bdcd901557e6b56a93d5555a4",
    Applied_Problems_P="93718361fad42bab0224e99dd97dfcbf438e94dd7f9febce8bdfb69fb79cd755",
    Applied_Problems_K="99a59cd932ae9bffc1c8ff992748809a357abb75a320ccd5ae493850104050fd")
  for(g in c("P","K")) {
    m <- if(g=="P") bw[,1] else bw[,3]
    cell <- paste0(if(g=="P")"PF" else "KF","_",o)
    old_record <- paste0("format=stage14-membership-sha256-v1\ncell=",cell,
      "\nrule=stage14_spring_pair_native_fall_stage07_complete8_v1\nwide_sha256=",wide_sha,
      "\npanel_sha256=",panel_sha,"\nuniverse_n=1015\nmembership=",paste0(as.integer(m[ordering]),collapse=""),"\n")
    check(paste0("accepted_pair_signature_",g),sha_text(old_record)==pins[[paste(o,g,sep="_")]],outcome=o)
  }
}
sample_flow <- bind(flow)
check("signature_binding", length(unique(c(signature(samples$PPVT$A,"PPVT","A"),
  signature(samples$PPVT$A,"PPVT","A",rule="changed"),
  signature(samples$PPVT$A,"PPVT","A",wh=paste(rep("0",64),collapse="")),
  signature(samples$PPVT$A,"PPVT","A",ph=paste(rep("0",64),collapse="")),
  signature(samples$PPVT$A,"PPVT","A",uh=paste(rep("0",64),collapse="")))))==5L)
different_mask <- samples$PPVT$A; ii <- which(different_mask)[1]; jj <- which(!different_mask)[1]
different_mask[c(ii,jj)] <- !different_mask[c(ii,jj)]
check("equal_N_different_membership", sum(different_mask)==sum(samples$PPVT$A) &&
  signature(different_mask,"PPVT","A")!=signature(samples$PPVT$A,"PPVT","A"))

# Frozen registry and explicit matrices. Column order is declared, never inferred
# from a formula/factor contrast engine: intercept, beliefs, controls, class, waves.
models <- data.frame(model=sprintf("M%02d",1:16),
  belief=c("common","common","native","native","PreK","PreK","K","K","common","native","PreK","K","common","common","common","native"),
  controls=c("none","C","none","C","none","C","none","C","C","C","C","C","C","C_class","H","H"),
  sample=c("A","A","A","A","A_PreK","A_PreK","A_K","A_K","B","B","B_PreK","B_K","AC","AC","A","A"),
  expected_k=as.integer(c(5,35,6,36,3,33,3,33,35,36,33,33,35,36,17,18)))
belief_terms <- function(m) switch(m$belief,common="belief_common",native=c("belief_PreK","belief_K"),PreK="belief_PreK",K="belief_K")
terms_for <- function(m) c("Intercept",belief_terms(m),
  if(m$controls %in% c("C","C_class"))colnames(C) else if(m$controls=="H")colnames(H),
  if(m$controls=="C_class")"class_size",
  if(m$belief=="PreK")"wave_PS" else if(m$belief=="K")"wave_KS" else paste0("wave_",waves[-1]))
make_matrix <- function(m, mask) {
  z <- cbind(Intercept=rep(1,4060))
  b <- switch(m$belief, common=cbind(belief_common=A_score),native=cbind(belief_PreK=BP,belief_K=BK),
    PreK=cbind(belief_PreK=BP),K=cbind(belief_K=BK))
  z <- cbind(z,b)
  if(m$controls %in% c("C","C_class"))z <- cbind(z,C[ix_wide,,drop=FALSE])
  if(m$controls=="H")z <- cbind(z,H[ix_wide,,drop=FALSE])
  if(m$controls=="C_class")z <- cbind(z,class_size=class_size)
  ww <- if(m$belief=="PreK")"PS" else if(m$belief=="K")"KS" else waves[-1]
  for(w in ww) z <- cbind(z,setNames(data.frame(as.numeric(wave==w)),paste0("wave_",w)))
  z <- as.matrix(z[mask,,drop=FALSE]); storage.mode(z) <- "double"
  if(!identical(colnames(z),terms_for(m)) || ncol(z)!=m$expected_k)stop("Declared columns mismatch")
  z
}
validate_matrix <- function(z,y,cluster,bt,expected_k) {
  if(!is.matrix(z) || !is.numeric(z) || any(!is.finite(c(z,y))) ||
    nrow(z)!=length(y) || length(cluster)!=length(y) || anyNA(cluster) ||
    anyDuplicated(colnames(z)) || !all(bt %in% colnames(z)) ||
    ncol(z)!=expected_k || any(z[,"Intercept"]!=1)) stop("Invalid explicit design")
  q <- qr(z,tol=qr_tol); qa <- qr(z[,!colnames(z)%in%bt,drop=FALSE],tol=qr_tol)
  if(q$rank!=expected_k || q$rank-qa$rank!=length(bt) || nrow(z)<=q$rank || length(unique(cluster))<=1L)
    stop("Rank or degrees of freedom failure")
  list(q=q,rank_without=qa$rank)
}

# Stable cluster sandwich. X[,p] = Q R; coefficient influences are
# R^{-1} sum_{j in cluster} Q_j' u_j. tcrossprod of these influences yields
# the uncorrected sandwich without forming or inverting crossprod(X).
# Both beta and V are explicitly unpivoted into the declared column order.
qr_cluster <- function(z,y,cluster) {
  q <- qr(z,tol=qr_tol); k <- ncol(z); N <- nrow(z); G <- length(unique(cluster))
  if(q$rank!=k || N<=k || G<=1L || any(!is.finite(c(z,y))))stop("Invalid full-rank fit")
  Q <- qr.Q(q,complete=FALSE); R <- qr.R(q); p <- q$pivot
  beta_p <- as.vector(backsolve(R,crossprod(Q,y)))
  beta <- setNames(numeric(k),colnames(z)); beta[p] <- beta_p
  fitted <- as.vector(z%*%beta); residual <- y-fitted
  qs <- rowsum(Q*residual,group=cluster,reorder=FALSE)
  influence_p <- backsolve(R,t(qs))
  correction <- G/(G-1)*(N-1)/(N-k)
  vp <- tcrossprod(influence_p)*correction
  V <- matrix(0,k,k,dimnames=list(colnames(z),colnames(z))); V[p,p] <- vp
  if(any(!is.finite(c(beta,V))) || !close_numeric(V,t(V)) || any(diag(V)<0))
    stop("Invalid covariance: finite/symmetry/nonnegative-variance policy")
  # Variances are sums of squared influences with a positive multiplier. Thus
  # any negative diagonal is an error, with no abs() or truncation permitted.
  list(beta=beta,V=V,residual=residual,fitted=fitted,k=k,N=N,G=G,correction=correction,df=G-1L,pivot=p)
}

# Independent deterministic fixture: block-diagonal u_g u_g' route uses direct
# small-matrix algebra only here; research fits never invert X'X.
fz <- cbind(Intercept=1,a=rep(c(-2,-1,1,3),6),b=rep(1:6,each=4),c=sin(1:24))
fy <- 4+fz[,"a"]*.7-fz[,"b"]*.2+fz[,"c"]*1.3+cos((1:24)*1.4)
fg <- rep(1:6,each=4); ff <- qr_cluster(fz,fy,fg)
fb <- as.vector(solve(crossprod(fz),crossprod(fz,fy))); fu <- fy-as.vector(fz%*%fb)
omega <- matrix(0,24,24)
for(g in unique(fg)) {i <- which(fg==g); omega[i,i] <- tcrossprod(fu[i])}
bread <- solve(crossprod(fz))
fixture_correction <- 6/5*23/20
fv <- bread%*%crossprod(fz,omega%*%fz)%*%bread*fixture_correction
check("fixture_independent_beta",close_numeric(ff$beta,fb))
check("fixture_block_covariance",close_numeric(ff$V,fv),max(abs(ff$V-fv)),numeric_tol)
check("fixture_finite_sample_factor",identical(ff$correction,fixture_correction) && ff$df==5L && ff$k==4L && ff$G==6L)
perm <- c(seq(2,24,2),seq(1,24,2)); fp <- qr_cluster(fz[perm,],fy[perm],paste0("child_",100-fg[perm]))
check("fixture_order_relabel_invariance",close_numeric(ff$beta,fp$beta) && close_numeric(ff$V,fp$V))
cp <- c(3L,1L,4L,2L); fp <- qr_cluster(fz[,cp],fy,fg)
check("fixture_declared_column_permutation",close_numeric(ff$beta,fp$beta[colnames(fz)]) &&
  close_numeric(ff$V,fp$V[colnames(fz),colnames(fz)]))
check("fixture_rank_rejection",failed(qr_cluster(cbind(Intercept=1,a=1,b=1:24),fy,fg)))
check("fixture_nonfinite_rejection",failed(qr_cluster(fz,replace(fy,1,Inf),fg)))

# Validate every actual research matrix before fitting any research model.
designs <- list(); registry <- list()
for(o in outcomes)for(mi in seq_len(nrow(models))) {
  m <- models[mi,]; mask <- samples[[o]][[m$sample]]; z <- make_matrix(m,mask)
  v <- validate_matrix(z,responses[[o]][mask],ids[mask],belief_terms(m),m$expected_k)
  check("actual_design",identical(colnames(z),terms_for(m)) && ncol(z)==m$expected_k && v$q$rank==m$expected_k,
    c(nrow(z),ncol(z),v$q$rank),c(sum(mask),m$expected_k,m$expected_k),outcome=o,model=m$model)
  check("belief_rank_increment", v$q$rank-v$rank_without==length(belief_terms(m)),
    v$q$rank-v$rank_without,length(belief_terms(m)),outcome=o,model=m$model)
  sf <- sample_flow[sample_flow$outcome==o & sample_flow$sample==m$sample,]
  registry[[paste(o,m$model)]] <- data.frame(outcome=o,priority=if(o=="PPVT")"primary" else "secondary",m,
    formula=paste("Y ~",paste(terms_for(m),collapse=" + ")),term_order=paste(terms_for(m),collapse=";"),
    belief_terms=paste(belief_terms(m),collapse=";"),wave_reference=if(m$belief=="K")"KF" else "PF",
    n=sum(mask),G=length(unique(ids[mask])),k=ncol(z),rank=v$q$rank,rank_without_belief=v$rank_without,
    residual_df=nrow(z)-ncol(z),reference_df=length(unique(ids[mask]))-1L,
    correction=length(unique(ids[mask]))/(length(unique(ids[mask]))-1)*(nrow(z)-1)/(nrow(z)-ncol(z)),
    sample_rule=rule_id,membership_sha256=sf$membership_sha256,universe_sha256=universe_sha,
    wide_sha256=wide_sha,panel_sha256=panel_sha,
    assignment="Native Fall report assigned within grade to Fall/Spring only in analysis view; own-grade missing retained",
    units=if(m$belief=="common")"score points per original-scale unit: PreK/16, K native; common scale unverified" else "score points per native grade-specific released belief unit",
    C_reference="Male=1; four separate race No=0; income=1 (<=5000); education=1 (8th grade or less)",
    H_reference="Male=1; five separate race No=0 including White; education=3; income=1:4; combined coding/inclusion sensitivity",
    weighting="unweighted",uncertainty="child-cluster HC1 G/(G-1)*(N-1)/(N-k); conditional t(G-1); higher-level dependence unresolved",
    feasibility="full rank; frozen model retained")
  designs[[paste(o,m$model)]] <- list(z=z,mask=mask)
}
model_registry <- bind(registry)
# Exact same-sample comparisons: adjustment, coding, class adjustment, native/common.
equal_pairs <- rbind(c(1,2),c(3,4),c(5,6),c(7,8),c(13,14),c(2,15),c(4,16),c(2,4),c(9,10))
for(o in outcomes) for(pi in seq_len(nrow(equal_pairs))) {
  mm <- sprintf("M%02d",equal_pairs[pi,]); da <- designs[[paste(o,mm[1])]]; db <- designs[[paste(o,mm[2])]]
  check(paste0("exact_comparison_rows_",paste(mm,collapse="_")),identical(da$mask,db$mask) &&
    identical(responses[[o]][da$mask],responses[[o]][db$mask]) && identical(ids[da$mask],ids[db$mask]),outcome=o)
}
for(o in outcomes)for(mm in list(c(2,9),c(4,10),c(6,11),c(8,12),c(2,13))) {
  ma <- models[mm[1],]; mb <- models[mm[2],]
  check(paste0("held_model_sample_sensitivity_",ma$model,"_",mb$model),
    identical(terms_for(ma),terms_for(mb)) && all(!samples[[o]][[mb$sample]]|samples[[o]][[ma$sample]]),outcome=o)
}

# Estimation and independent FWL coefficient checks on all 40 belief slopes.
full_rows <- list(); diagnostic_rows <- list(); fits <- list()
for(o in outcomes)for(mi in seq_len(nrow(models))) {
  m <- models[mi,]; d <- designs[[paste(o,m$model)]]; z <- d$z; y <- responses[[o]][d$mask]
  f <- qr_cluster(z,y,ids[d$mask]); bt <- belief_terms(m)
  check("fit_finite_covariance",all(is.finite(c(f$beta,f$V))) && close_numeric(f$V,t(f$V)) && all(diag(f$V)>=0),outcome=o,model=m$model)
  check("fitted_reconstruction",close_numeric(f$fitted,as.vector(z%*%f$beta)) &&
    close_numeric(y,f$fitted+f$residual),outcome=o,model=m$model)
  normal <- as.vector(crossprod(z,f$residual)); scale <- pmax(1,sqrt(colSums(z*z))*sqrt(sum(y*y)))
  check("scaled_normal_equations",all(abs(normal)<=numeric_tol*scale),max(abs(normal)/scale),numeric_tol,outcome=o,model=m$model)
  fwl_diff <- c(); rbss <- c()
  for(b in bt) {
    qother <- qr(z[,colnames(z)!=b,drop=FALSE],tol=qr_tol)
    rb <- qr.resid(qother,z[,b]); ry <- qr.resid(qother,y); ss <- sum(rb*rb)
    independent <- sum(rb*ry)/ss
    check(paste0("FWL_",b),ss>0 && close_numeric(f$beta[b],independent),
      abs(f$beta[b]-independent),numeric_tol,outcome=o,model=m$model)
    fwl_diff <- c(fwl_diff,abs(f$beta[b]-independent)); rbss <- c(rbss,ss)
  }
  se <- sqrt(diag(f$V)); statistic <- f$beta/se; p <- 2*pt(-abs(statistic),df=f$df)
  crit <- qt(.975,df=f$df); lower <- f$beta-crit*se; upper <- f$beta+crit*se
  check("conditional_inference",all(is.finite(c(se,statistic,p,lower,upper))) && all(se>0) &&
    all(p>=0 & p<=1),outcome=o,model=m$model)
  r <- model_registry[model_registry$outcome==o & model_registry$model==m$model,]
  rows <- data.frame(outcome=o,priority=r$priority,model=m$model,sample=m$sample,n=f$N,G=f$G,k=f$k,
    residual_df=f$N-f$k,reference_df=f$df,correction=f$correction,membership_sha256=r$membership_sha256,
    wide_sha256=wide_sha,panel_sha256=panel_sha,term_order=seq_len(ncol(z)),term=colnames(z),
    estimate=unname(f$beta),std_error=unname(se),statistic=unname(statistic),p_conditional=unname(p),
    lower_95=unname(lower),upper_95=unname(upper),
    units=ifelse(colnames(z)=="belief_common","score points per original-scale unit (PreK/16; K native)",
      ifelse(colnames(z)%in%c("belief_PreK","belief_K"),"score points per native released grade belief unit","score points per declared indicator/unit")),
    weighting="unweighted",uncertainty="child-cluster working conditional t(G-1)")
  full_rows[[paste(o,m$model)]] <- rows
  rss <- sum(f$residual^2); tss <- sum((y-mean(y))^2)
  check("fit_aggregate_valid",rss>=0 && tss>0 && is.finite(rss+tss),outcome=o,model=m$model)
  diagnostic_rows[[paste(o,m$model)]] <- data.frame(outcome=o,model=m$model,sample=m$sample,n=f$N,G=f$G,k=f$k,
    rank=qr(z,tol=qr_tol)$rank,belief_rank_increment=length(bt),residual_df=f$N-f$k,reference_df=f$df,correction=f$correction,
    rss=rss,tss=tss,r_squared=1-rss/tss,rmse=sqrt(rss/f$N),max_FWL_difference=max(fwl_diff),
    min_residual_belief_ss=min(rbss),max_scaled_normal_error=max(abs(normal)/scale),
    covariance_asymmetry=max(abs(f$V-t(f$V))),minimum_variance=min(diag(f$V)),
    pivot_order=paste(f$pivot,collapse=";"),membership_sha256=r$membership_sha256)
  # Retain aggregates only; no saved model, fitted-value or residual output.
  fits[[paste(o,m$model)]] <- list(rss=rss,tss=tss)
}
full <- bind(full_rows); diagnostics <- bind(diagnostic_rows)
belief <- full[grepl("^belief_",full$term),]; row.names(belief) <- NULL
check("model_result_counts",nrow(model_registry)==32L && nrow(diagnostics)==32L && nrow(full)==794L && nrow(belief)==40L,
  c(nrow(model_registry),nrow(belief),nrow(full),nrow(diagnostics)),c(32,40,794,32))
check("unique_result_keys",!anyDuplicated(full[c("outcome","model","term")]) && !anyDuplicated(diagnostics[c("outcome","model")]))
# Genuinely nested, identical-row comparisons only. C vs H and sample changes are excluded.
nested_pairs <- rbind(c(1,2),c(3,4),c(5,6),c(7,8),c(13,14),c(1,3),c(2,4),c(9,10),c(15,16))
for(o in outcomes)for(j in seq_len(nrow(nested_pairs))) {
  mm <- sprintf("M%02d",nested_pairs[j,]); da <- designs[[paste(o,mm[1])]]; db <- designs[[paste(o,mm[2])]]
  check(paste0("nested_column_space_",paste(mm,collapse="_")),identical(da$mask,db$mask) &&
    close_numeric(qr.resid(qr(db$z,tol=qr_tol),da$z),matrix(0,nrow(da$z),ncol(da$z))),outcome=o)
  fa <- fits[[paste(o,mm[1])]]; fb <- fits[[paste(o,mm[2])]]
  check(paste0("nested_RSS_",paste(mm,collapse="_")),fb$rss<=fa$rss+numeric_tol*max(1,fa$tss,fa$rss,fb$rss),
    c(fa$rss,fb$rss),"nonincreasing at scaled 1e-10",outcome=o)
}

# Aggregate presentation, explicit round-trip-safe serialization, and publication.
csv_text <- function(x) {
  text <- x
  for(f in names(text)) {
    text[[f]] <- if(is.numeric(x[[f]]))sprintf("%.17g",x[[f]]) else as.character(x[[f]])
    text[[f]][is.na(x[[f]])] <- "NA"
  }
  quote_cell <- function(s) paste0('"',gsub('"','""',s,fixed=TRUE),'"')
  lines <- c(paste(quote_cell(names(text)),collapse=","),vapply(seq_len(nrow(text)),
    function(i)paste(quote_cell(unlist(text[i,],use.names=FALSE)),collapse=","),""))
  list(text=text,lines=unname(lines))
}
readback <- function(p,original,record=TRUE) {
  back <- read.csv(p,colClasses="character",check.names=FALSE,na.strings=NULL,fileEncoding="UTF-8")
  stopifnot(identical(back,csv_text(original)$text))
  typed <- back
  for(f in names(original)) {
    values <- back[[f]]; values[values=="NA"] <- NA_character_
    typed[[f]] <- if(is.integer(original[[f]]))as.integer(values) else if(is.double(original[[f]]))as.numeric(values) else
      if(is.logical(original[[f]]))as.logical(values) else values
    stopifnot(identical(typed[[f]],original[[f]]))
  }
  stopifnot(identical(typed,original))
  if(record)check(paste0("exact_readback_",basename(p)),TRUE,nrow(typed),nrow(original))
  typed
}
write_exclusive <- function(lines,p) {
  stopifnot(p%in%dest,!file.exists(here::here(p)))
  con <- file(here::here(p),open="wxb")
  tryCatch(writeBin(charToRaw(enc2utf8(paste0(paste(lines,collapse="\n"),"\n"))),con),finally=close(con))
}
# Exercise the writer/readback infrastructure outside the repository before any
# final destination opens. No automatic deletion or overwrite of final outputs.
tmp <- tempfile("stage16_roundtrip_",fileext=".csv")
con <- file(tmp,open="wxb"); writeBin(charToRaw(paste0(paste(csv_text(full)$lines,collapse="\n"),"\n")),con); close(con)
check("temporary_exact_typed_roundtrip",identical(readback(tmp,full,record=FALSE),full))
check("exclusive_existing_file_rejection",failed({con <- file(tmp,open="wxb"); close(con)}))
unlink(tmp)
fmt <- function(x) sprintf("%+.6f",x)
fmtp <- function(x) sprintf("%.6g",x)
table_rows <- function(x,fields) vapply(seq_len(nrow(x)),function(i)
  paste0("| ",paste(unlist(x[i,fields],use.names=FALSE),collapse=" | ")," |"),"")
comparison_pairs <- rbind(c("M01","M02"),c("M03","M04"),c("M05","M06"),c("M07","M08"),
  c("M02","M09"),c("M04","M10"),c("M06","M11"),c("M08","M12"),
  c("M02","M13"),c("M13","M14"),c("M02","M15"),c("M04","M16"))
comparison_labels <- c(rep("control adjustment; identical rows",4),rep("grade-pair sample restriction; fixed model",4),
  "class-size availability selection; fixed model","class-size adjustment; identical rows",rep("combined C/H coding and White-inclusion sensitivity; identical rows",2))
make_report <- function(bt,rg,sf,dt) {
  report <- c("# Stage 16: pooled teacher-belief associations with time fixed effects","",
    "PPVT is primary; English Applied Problems is secondary. This batch reconstructs the intended original time-effects model with corrected, authenticated inputs. It is not an exact replication of legacy code or historical results. All 32 prespecified models are reported; M14 was preselected before estimation as closest to the adjusted original intent. M04 is the native grade-specific alternative. No manuscript was changed.","",
    "## Equations and interpretation","",
    "Common slope: Y_it = alpha + beta A_it + C_i' gamma + delta_PS 1[PS] + delta_KF 1[KF] + delta_KS 1[KS] + u_it. A_it is native Pre-K T_IDEAP/16 at PF/PS and native Kindergarten T_IDEAK at KF/KS. This original-scale reconstruction assumes a common substantive unit that is not authenticated. It constrains the native Pre-K slope to beta/16 and the native Kindergarten slope to beta.","",
    "Native grade slopes: replace beta A_it by beta_P BP_it + beta_K BK_it. Each belief is native in its own grade and structurally zero outside it; missing own-grade reports remain missing. Separate grade models use the native report and a Spring indicator with the corresponding Fall reference. Every model includes an intercept and explicit 0/1 wave indicators (PF reference for four-wave models; KF for Kindergarten-only models), never ordered-factor polynomial contrasts. Wave effects absorb common occasion differences. These are unweighted pooled OLS associations, retain between-child variation, and contain no child fixed effects.","",
    "Fall reports are assigned to Fall and Spring within grade only in the new in-memory analysis view. This does not establish continuous teacher exposure or create Spring reports. Native sources and missingness are preserved. A higher released score has unresolved substantive direction; progressive/traditional or observed-behavior interpretations are unsupported.","",
    "C has 30 columns: Female (Male code 1 reference), four separate nonexclusive race Yes indicators (each No code 0 reference), 17 income indicators (codes 2-18 versus code 1, <=$5,000), and eight maternal-education indicators (codes 2-9 versus code 1, eighth grade or less). The four race references do not define an exclusive White group. H has 12 columns: Female; all five separate race indicators including White; education codes 1-2, 4-6, 7-9 versus code 3; income codes 5-8, 9-12, 13-18 versus codes 1-4. H changes both grouping and White inclusion; differences cannot be attributed to grouping alone. Both control codings have identical complete-case membership here. All descriptors are Pre-K reports, including Kindergarten models; pre-exposure timing is unverified. Unobserved education code 10 is guarded against rather than recoded.","",
    "## Samples and fresh class-size lineage","",
    "A requires the eligible finite same-outcome English standard score, finite own-grade belief report, and complete valid C controls, allowing unbalanced histories. B retains both independently qualifying Fall/Spring rows within either grade from A. AC restricts A to finite corresponding-occasion class size. No cross-outcome condition, both-grade-report condition, four-wave requirement, carrying of class sizes, or classroom merge is introduced. Seven Fall and one Spring Pre-K Applied Problems practice-failure values remain numerically excluded under Stage07 rules.","",
    "| Outcome | Sample | Child-waves | Children / clusters | PF | PS | KF | KS |","|---|---|---:|---:|---:|---:|---:|---:|",
    table_rows(sf[sf$sample%in%c("A","B","AC","A_PreK","A_K","B_PreK","B_K"),],c("outcome","sample","n","G",waves)),"",
    "Full sequential restriction counts and one-to-four-observation histories are in stage16_sample_flow.csv. A/B/AC were independently rebuilt from wide inputs and compared for exact membership, not just N. B membership additionally matches the accepted Stage14/15 child-level signatures. All samples use a fixed ordered 4,060-child-wave universe; exported signatures bind membership, rules, universe hash, and both analysis input hashes, without identifiers or bits.","",
    "| Wave | Actual released field | Observed | Missing | Minimum | Maximum |","|---|---|---:|---:|---:|---:|",
    table_rows(bind(class_audit),c("wave","source","observed","missing","minimum","maximum")),"",
    "Fresh key-aligned equality holds from released DS0001 through verified wide, structural panel, and cleaned panel, including exact missingness and metadata. Provenance/dictionary labels and wave assignments agree. Local codebook PDF pp.495-496, 546-547, 761-762, 826-827 and release setup syntax identify occasion-specific class enrollment; PS 56 is a documented valid value and is retained.","",
    "## Conditional uncertainty","",
    "The working stochastic target is an unweighted linear projection for a hypothetical population resembling the selected child-wave records. Children with more eligible occasions contribute more rows. The covariance is the child-cluster sandwich multiplied by G/(G-1)*(N-1)/(N-k), where k includes every fitted column. Two-sided p-values and 95% intervals use t(G-1). G, k, residual/reference degrees of freedom and correction are exported for every model.","",
    "This working method permits within-child dependence but leaves cross-child teacher/classroom/site/sampling-unit dependence unresolved. Independent child clusters and the reference approximation are unverified working assumptions. These are conditional, unadjusted p-values and intervals, not design-validated uncertainty; no conservativeness or causal claim follows. No significance stars are used. PPVT is primary, and the other models/outcome provide sensitivity evidence rather than independent replications. Nonsignificance does not prove absence of an association.","",
    "## Preselected original-intent result and native alternative","",
    "| Outcome | Model | Term | N | G | Estimate | Conditional SE | Conditional 95% interval | Conditional p |","|---|---|---|---:|---:|---:|---:|---|---:|")
  result_rows <- function(z) vapply(seq_len(nrow(z)),function(i) {
    a <- z[i,];paste0("| ",a$outcome," | ",a$model," | ",a$term," | ",a$n," | ",a$G," | ",fmt(a$estimate)," | ",
      fmtp(a$std_error)," | [",fmt(a$lower_95),", ",fmt(a$upper_95),"] | ",fmtp(a$p_conditional)," |")},"")
  report <- c(report,result_rows(bt[bt$model%in%c("M14","M04"),]))
  for(o in outcomes) {
    a <- bt[bt$outcome==o & bt$model=="M14",]; original <- if(o=="PPVT") -0.93 else -1.04
    report <- c(report,"",paste0(o," M14: ",fmt(a$estimate)," standard-score points per original-scale belief unit; conditional SE ",
      fmtp(a$std_error),", 95% interval [",fmt(a$lower_95),", ",fmt(a$upper_95),"], p=",fmtp(a$p_conditional),
      ". The corrected intended specification ",if(a$estimate<0)"retains the negative sign" else "contradicts the negative sign",
      " of the original numerical pattern (reported ",original,"). ",
      if(a$lower_95<=0 && a$upper_95>=0)"Its conditional interval includes zero; it is not statistically distinguishable from zero at the conditional 5% reference." else
      "Its conditional interval excludes zero under the working child-cluster assumptions.",
      " Historical coefficients, signs and p-values are not computational pass/fail targets. Belief direction remains unresolved."))
  }
  report <- c(report,"","## All registered belief estimates","",
    "Common-slope terms use the assumption-dependent Pre-K/16 versus K-native scale; native Pre-K and native K terms have different, non-equivalent units. Their numerical magnitudes are not directly comparable as common substantive effects.","",
    "| Outcome | Model | Term | N | G | Estimate | Conditional SE | Conditional 95% interval | Conditional p |","|---|---|---|---:|---:|---:|---:|---|---:|",result_rows(bt),"",
    "## Prespecified comparisons","","Differences below are later minus earlier coefficients, not tests of coefficient differences. Sample-change comparisons hold the model fixed; adjustment/coding comparisons hold exact rows fixed.","",
    "| Outcome | Earlier -> later | Term | Earlier | Later | Difference | Interpretation |","|---|---|---|---:|---:|---:|---|")
  for(o in outcomes)for(j in seq_len(nrow(comparison_pairs))) {
    mm <- comparison_pairs[j,]; a <- bt[bt$outcome==o & bt$model==mm[1],]; b <- bt[bt$outcome==o & bt$model==mm[2],]
    for(term in a$term) {
      av <- a$estimate[a$term==term]; bv <- b$estimate[b$term==term]
      report <- c(report,paste0("| ",o," | ",paste(mm,collapse=" -> ")," | ",term," | ",fmt(av)," | ",fmt(bv)," | ",fmt(bv-av)," | ",comparison_labels[j]," |"))
    }
  }
  for(o in outcomes) {
    sel <- function(mm)bt$estimate[bt$outcome==o & bt$model==mm & bt$term=="belief_common"]
    a <- sel("M01"); b <- sel("M02"); c <- sel("M13"); d <- sel("M14")
    report <- c(report,"",paste0(o,": the common slope changes from ",fmt(a)," (M01) to ",fmt(b),
      " with C (M02), then ",fmt(c)," on class-size-observed rows without class adjustment (M13), and ",fmt(d),
      " after adding class size on those same rows (M14). The availability-selection change is ",fmt(c-b),
      "; the class-adjustment change is ",fmt(d-c),". H gives ",fmt(sel("M15")),
      " (M15), a combined coding/inclusion difference of ",fmt(sel("M15")-b)," from M02."))
  }
  c(report,"","## Computation and remaining limits","",
    "All actual matrices have the exact frozen columns and full expected ranks at QR tolerance 1e-7. Estimation uses X[,pivot]=QR and triangular solves; cluster covariance uses QR-derived cluster influences and their outer products, explicitly mapped back to declared column order. No research cross-product inverse is formed. Fixed scaled agreement tolerance is 1e-10. Independent FWL checks cover every belief slope; the small covariance fixture uses block-diagonal residual outer products, the finite factor, row/relabel invariance and column permutation. Fitted reconstruction, scaled normal equations and genuinely nested same-sample RSS checks pass. Numerical outputs use 17 significant digits and exact typed readback; report tables are regenerated from readback tables.","",
    "No computational issue remains on successful completion. Construction/direction and cross-grade scale equivalence of beliefs, teacher identity/exposure correspondence, assessment/report and descriptor timing, unobserved heterogeneity, cross-child dependence, selection and unweighted representation remain substantive limitations. Standard-score points are not absolute skill growth. Original-paper tables (local ECON_4261_Paper.pdf pp.13-14) are historical reference only; the manuscript and legacy code are preserved. No new model family, supplemental retrieval or manuscript rewrite is part of this batch.")
}
report <- unname(make_report(belief,model_registry,sample_flow,diagnostics))
check("all_substantive_checks_before_writes",!any(file.exists(here::here(dest))) && all(vapply(checks,function(x)x$status=="pass",logical(1))))
check("objects_preserved_before_write",objects_preserved())
check("files_preserved_before_write",preserved(),length(protected))
check("git_preserved_before_write",git_preserved())

# Only now open final result destinations, always exclusively.
tables <- list(model_registry,sample_flow,belief,full,diagnostics); disk <- list()
for(j in seq_along(tables)) {
  write_exclusive(csv_text(tables[[j]])$lines,dest[j]); disk[[j]] <- readback(here::here(dest[j]),tables[[j]])
}
disk_b <- disk[[4]][grepl("^belief_",disk[[4]]$term),]; row.names(disk_b) <- NULL
check("disk_belief_full_agreement",identical(disk[[3]],disk_b))
for(o in outcomes)for(mm in models$model) {
  a <- disk[[4]][disk[[4]]$outcome==o & disk[[4]]$model==mm,]
  check("exported_inference_method",close_numeric(a$p_conditional,2*pt(-abs(a$estimate/a$std_error),a$reference_df)) &&
    close_numeric(a$lower_95,a$estimate-qt(.975,a$reference_df)*a$std_error) &&
    close_numeric(a$upper_95,a$estimate+qt(.975,a$reference_df)*a$std_error) &&
    close_numeric(a$correction,a$G/(a$G-1)*(a$n-1)/(a$n-a$k)),outcome=o,model=mm)
}
check("report_regenerated_from_readback",identical(report,unname(make_report(disk[[3]],disk[[1]],disk[[2]],disk[[5]]))))
write_exclusive(report,dest[6])
check("report_exact_lines",identical(report,readLines(here::here(dest[6]),encoding="UTF-8",warn=FALSE)))
check("objects_preserved_after_write",objects_preserved())
check("files_preserved_after_write",preserved(),length(protected))
check("git_preserved_after_write",git_preserved())
check("eight_outputs_ignored_untracked",all(vapply(dest,ignored,logical(1))) && !length(git(c("ls-files","--",dest))))
check("tracked_whitespace",!length(git(c("diff","--check"))) && !length(git(c("diff","--cached","--check"))))
ledger <- bind(checks)
write_exclusive(csv_text(ledger)$lines,dest[7]); invisible(readback(here::here(dest[7]),ledger,record=FALSE))
stopifnot(all(ledger$status=="pass"),!anyDuplicated(ledger$check_id))
input_paths <- unique(c(wide_path,panel_path,struct_path,raw_path,
  vapply(receipts,`[`,"",1L),"docs/icpsr/DS0001/04283-0001-Codebook.pdf",
  "code/revision/15_estimate_spring_associations.R","output/verification/stage15_checks.csv","../ECON_4261_Paper.pdf"))
note <- c("# Stage 16 verification and unresolved record","",
  paste0("Execution start: ",start_time,". ",R.version.string,"; here ",packageVersion("here"),"; renv ",packageVersion("renv"),
    "; Python ",py("import sys; print(sys.version.split()[0])")," (hashlib only). No installation, lockfile change, upstream stage execution, network retrieval, staging, commit or push."),"",
  "## Exact execution command and outcome","","```powershell","$env:LC_ALL = 'English_United States.utf8'",
  "& 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla 'C:/Users/mvbas/OneDrive/Desktop/Econometrics/Project/ICPSR_04283/code/revision/16_estimate_time_fixed_effects.R'","```","",
  paste0("Exit 0 on successful completion of this script (caller independently records actual process exit). Exactly 32 models, 40 belief rows, 794 full-coefficient rows, 32 diagnostic rows; ",nrow(ledger)," unique passing checks; zero failures. All eight destinations were absent at preflight and before substantive publication; writers exclusively create and never overwrite. A rerun against existing outputs intentionally fails."),"",
  "## Fresh checks and numerical method","",
  "Released DS0001 MD5 matches the accepted Stage03 pin. Analysis input SHA-256 matches accepted pins; 16 Stage14 receipts authenticate support inputs. Four class-size fields match keyed released, wide, structural and clean-panel values and missingness exactly; dictionary labels/provenance and wave assignments agree. Local codebook entries pp.495-496, 546-547, 761-762, 826-827 were freshly read before implementation; counts/ranges match, including valid PS maximum 56. No classroom merge, class-size carry or new exclusion is used.","",
  "A/B/AC and grade samples are recomputed twice via independent keyed panel and wide constructions and compared as exact logical membership. All expected overall, grade and paired-grade counts match; C/H complete cases agree; B and AC are subsets of A. Four accepted Stage14/15 pair signatures match exact membership. Shuffled panel keys, duplicate/unmatched-key rejection, validated setup/factor labels, education Other guard, own-grade missingness and outside-grade structural zeros pass. The eight Applied Problems practice failures remain excluded; no outcome/language/metric is mixed.","",
  "Every actual matrix is validated before research estimation for exact dimensions/declared order/rank, positive residual and cluster degrees of freedom, and belief rank increments (one or two as registered). QR tolerance is 1e-7; scaled agreement tolerance is fixed at 1e-10. X[,p]=QR; beta[p]=backsolve(R,Q'y). Cluster influences in pivot order are backsolve(R,t(rowsum(Q*u,child))); covariance is their tcrossprod times G/(G-1)*(N-1)/(N-k), mapped by V[p,p] into original declared term order. Research fitting never forms or inverts crossprod(X). Symmetry and finite entries are checked. Since diagonal entries are positive-factor sums of squared influences, any negative diagonal is an error: no abs, truncation or hidden symmetrization is used.","",
  paste0("Independent small deterministic block-diagonal u_g u_g' covariance agrees, including finite factor; maximum absolute fixture covariance difference ",sprintf("%.17g",max(abs(ff$V-fv))),
    ". Row ordering, cluster relabeling and declared-column permutation invariance pass. Rank/nonfinite rejection fixtures pass. Every belief slope (40 total) passes independent FWL residualization against all other columns, including both native slopes. Maximum research FWL absolute difference: ",sprintf("%.17g",max(diagnostics$max_FWL_difference)),
    "; maximum scaled normal-equation error: ",sprintf("%.17g",max(diagnostics$max_scaled_normal_error)),"."),"",
  "All fitted-value/residual reconstructions pass. Nested column-space and RSS checks apply only to genuinely nested identical-row comparisons; sample changes and C/H coding changes receive no nested-RSS claim. Conditional SEs, t(G-1) p-values/95% intervals and corrections are finite and independently recalculated from exported coefficients. Belief rows exactly equal their full-coefficient counterparts.","",
  "CSV numeric serialization is explicit sprintf(%.17g), with exact text, numeric/integer/logical types and value readback. Temporary full-result roundtrip and exclusive-existing-file rejection pass before publication. All five result CSVs are read back, the report is regenerated from those tables and checked line-for-line, and the check ledger is exactly read back. No identifiers, membership bits, child-level data, residuals, fitted values or saved model objects are exported.","",
  "## Membership signature specification","",
  paste0("Universe hash: ",universe_sha,". Canonical order is numeric ascending STUDY_ID over all 1,015 released children, then PF,PS,KF,KS per child (4,060 rows). Universe hash input is LF-terminated UTF-8 text: first line stage16-child-wave-universe-v1, then each numeric ID|wave. IDs are hashed in process memory, never exported."),"",
  paste0("Membership record consists of these LF-terminated UTF-8 lines in order: format=stage16-membership-sha256-v1; outcome=<outcome>; sample=<sample>; rule=",rule_id,
    "; wide_sha256=<hash>; panel_sha256=<hash>; universe_sha256=<hash>; universe_n=4060; membership=<4060 concatenated 0/1 digits in canonical order>. No BOM, CR or extra spaces. Semicolons here describe line breaks, not literal record separators. Hashes bind exact membership and inputs; equal-N/different-membership and changed rule/input/universe bindings are rejected."),"",
  "| Outcome | Sample | Membership SHA-256 |","|---|---|---|",table_rows(sample_flow,c("outcome","sample","membership_sha256")),"",
  "## Input fingerprints","","| Input | SHA-256 |","|---|---|",
  vapply(input_paths,function(p)paste0("| ",p," | ",sha_file(p)," |"),""),"",
  "## Preservation audit","",
  paste0(length(protected)," execution-start files, including the new script and every existing repository input/output/legacy/renv file, have unchanged inventory and MD5 fingerprints. All four loaded data objects serialize identically at completion. The caller also captured an independent pre-implementation SHA-256 inventory of 385 pre-existing files; its final comparison is recorded externally after all nine new files exist and is not claimed by the runtime ledger."),"",
  paste0("HEAD ",head_before,"; expected sole parent 530d637da394748ae703a38da12456972cbf6d32; branch ",branch_before,
    ". HEAD, branch, full index and Git status are checked unchanged within execution. The new script is untracked and all eight outputs are ignored and untracked. No Git configuration change is made."),"",
  "Git checks: rev-parse --show-toplevel; rev-parse HEAD; rev-list --parents -n 1 HEAD; branch --show-current; ls-files --stage; status --short --branch; diff --cached --name-only; ls-files -- <outputs>; check-ignore -q -- <each output>; diff --check; diff --cached --check. No stage, commit, push, reset, rebase, merge, amend or manuscript operation.","",
  "## Development evidence and unresolved issues","",
  "Pre-implementation read-only inspection first used nonexistent structural_panel.rds and exited 1; the actual structural_child_wave_panel.rds was found from Stage04 and read. A PDF extraction utility wrote UTF-8 text successfully but its console-print step used a default Windows text decoding and exited 1; explicit UTF-8 readback and complete relevant codebook pages succeeded. A patch context lookup found no matching text and changed no file. These were development/inspection failures, not successful research runs. Any later research-run correction is documented below before final publication.","",
  "Run01 exited 1 at the initial Git ownership check, before loading data or fitting. Diagnostic system2 calls showed the R subprocess identity differed from the sandbox repository owner. The accepted Stage14/15 command-local safe.directory exception was reused for read-only Git calls; no configuration file, repository state or ownership was changed. Later attempts and corrections are recorded by the caller.",
  "Run02 exited 1 before research fitting at released_wide_T_IDEAP: R numeric subsetting dropped its empty value.labels attribute. Investigation verified exact keyed values/missingness and identical original released/wide attributes. Validation now checks keyed values with zero tolerance and compares source attributes before subsetting separately; panel numeric columns intentionally have no such attribute. No data, coding, tolerance or sample changed, and no final output existed.",
  "Run03 exited 1 before fitting when the canonical-universe hex payload exceeded the Windows CreateProcess argument limit. SHA-256 now streams identical UTF-8 bytes through a binary pipe to the existing Python hashlib helper and writes only the digest to a temporary file. The signature definition is unchanged. The retained run03 log redacts the oversized payload from the process error. One isolated pipe test failed Windows executable quoting; using its short path passed the abc known-answer test. No final output existed in these attempts.",
  "Historical Stage15's 401 passing checks were inspected, not newly executed. No accepted stage was rerun. Fresh Stage16 evidence is distinguished from those continuity receipts. The old handoff's proposed manuscript rewrite/publication steps are superseded by the current explicit Stage16 authorization.","",
  "Computational issues: none on successful completion. Acknowledged substantive limits: belief construction/direction, scale equivalence, teacher/exposure correspondence, timing, cross-child dependence and unverified independent-cluster assumptions, selection, weights/representation, score metrics and historical replication remain unresolved. Conditional uncertainty is not design-validated or known conservative. M14 is retained irrespective of findings; M04 and every registered sensitivity are reported.","",
  "## New artifact fingerprints","","| Path | SHA-256 |","|---|---|",
  vapply(c(script_path,dest[1:7]),function(p)paste0("| ",p," | ",sha_file(p)," |"),""),"",
  "The caller supplies the verification note's own SHA-256 after its final write; a file cannot contain its own final byte hash.","",
  "## Execution-start and final Git status","```",status_before,"```","",
  "## Full unchanged execution-start index","```",index_before,"```","",
  "## Protected file fingerprints (MD5 before = after)","","| Relative path | MD5 |","|---|---|",
  paste0("| ",protected," | ",unname(before)," |"))
note <- unname(note)
write_exclusive(note,dest[8])
stopifnot(identical(note,readLines(here::here(dest[8]),encoding="UTF-8",warn=FALSE)),
  preserved(),git_preserved(),objects_preserved())
cat("Stage16 PASS:",nrow(ledger),"unique passing checks; 32 models / 40 belief / 794 full coefficients; eight outputs;",
  length(protected),"protected execution-start files unchanged.\n")
NULL
},error=function(e)e)
if(inherits(failure,"error")) {
  # Preserve completed work. Never remove or replace an existing destination.
  evidence <- tempfile("stage16_failure_",tmpdir=dirname(tempdir()),fileext=".txt")
  writeLines(c("Stage16 FAILED; no successful-result claim",conditionMessage(failure),
    vapply(checks,function(r)paste(r$check_id,r$status,r$observed,r$expected,sep=" | "),"")),evidence)
  stop("Stage16 failed: ",conditionMessage(failure),"; aggregate evidence: ",evidence)
}

