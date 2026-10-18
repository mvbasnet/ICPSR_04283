# Stage 09: Fall belief timing and Spring teacher correspondence.
# From the Git root, using the existing renv library; requires pdftotext on PATH:
# $env:LC_ALL = 'English_United States.utf8'
# & 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/09_investigate_belief_timing_correspondence.R
# The default entry point compares two fresh workers before publishing five
# aggregate/report artifacts. No upstream script, regression, or Git mutation runs.
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
script_path <- "code/revision/09_investigate_belief_timing_correspondence.R"
destinations <- c("output/tables/stage09_source_evidence.csv",
  "output/tables/stage09_field_timing.csv", "output/tables/stage09_continuity_diagnostics.csv",
  "output/verification/stage09_checks.csv", "output/reports/stage09_feasibility.md")
check_ignore <- function() {
  z <- vapply(destinations, function(p)
    identical(system2("git", c("check-ignore", "-q", "--", p)), 0L), logical(1))
  if (!all(z)) stop("Publication stopped: unignored destinations.")
  z
}
invisible(check_ignore())
stopifnot(all(dir.exists(here::here(dirname(destinations)))))
bind <- function(x) { z <- do.call(rbind, x); row.names(z) <- NULL; z }
pct <- function(n, d) { z <- 100 * n / d; z[is.na(d) | d == 0] <- NA_real_; z }
same <- function(a, b) isTRUE(all.equal(a, b, tolerance = 1e-12, check.attributes = FALSE))
read_csv <- function(p) read.csv(here::here(p), check.names = FALSE, fileEncoding = "UTF-8")
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
  writeBin(charToRaw(enc2utf8(paste0(paste(lines, collapse = "\n"), "\n"))), con)
}
check_csv <- function(x, p) {
  y <- read.csv(p, colClasses = "character", check.names = FALSE, na.strings = character(), fileEncoding = "UTF-8")
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
flat <- function(x) trimws(gsub("[[:space:]]+", " ", paste(x, collapse = " ")))
md5_text <- function(x) {
  p <- tempfile(); on.exit(unlink(p)); con <- file(p, "wb")
  writeBin(charToRaw(enc2utf8(x)), con); close(con); unname(tools::md5sum(p))
}

# Closed quantitative allowlist. Assessment ages/spacing and all identifier fields
# are documentary targets only. DS0002/DS0003 research objects are never loaded.
core <- c("T_IDEAP", "T_IDEAK", "T_CHNGCP", "T_CHNG", "TCHCHNGK", "CLASSCHNGK")
dates <- c("TQDATEKF", "TQDATEKS", "TQSCDATEKF", "TQSCDATEKS")
definition_only <- c("ASMTAGEPF", "ASMTAGEPS", "ASMTAGEKF", "ASMTAGEKS",
  "AMSNTDAYP", "AMSNTDAYK", "ASMNTDAYPKK", "CHPARTP", "CHPARTK", "SCHLCHNGK",
  "SITE_PF", "SITE_PS", "SITE_TRPS", "SITE_TRKF", "SITE_TRKS")
quantitative <- c("STUDY_ID", core, dates)
waves <- c("PF", "PS", "KF", "KS")
grades <- c("Pre-K", "Kindergarten")
outcomes <- c("ppvt_english_standard_score", "applied_problems_english_standard_score",
  "sound_awareness_rhyming_raw_score", "tvip_spanish_standard_score", "tvip_spanish_raw_score",
  "woodcock_munoz_applied_problems_standard_score", "woodcock_munoz_applied_problems_w_score",
  "woodcock_munoz_letter_word_standard_score", "woodcock_munoz_letter_word_w_score")
belief_panel <- c("teacher_modernity_pre_k_fall_released", "teacher_modernity_kindergarten_fall_released")
cb <- "docs/icpsr/DS0001/04283-0001-Codebook.pdf"
qf <- "docs/icpsr/DS0001/04283-0001-Questionnaire.pdf"
guide <- "docs/icpsr/04283-User_guide.pdf"
cb2 <- "docs/icpsr/DS0002/04283-0002-Codebook.pdf"
cb3 <- "docs/icpsr/DS0003/04283-0003-Codebook.pdf"
docbase <- function(ds, extension) paste0("docs/icpsr/", ds, "/04283-000", substr(ds, 6, 6), "-Setup.", extension)

# Convert primary PDFs read-only, retaining physical-page boundaries. Page text
# fingerprints refer to normalized pdftotext -layout UTF-8 excerpts; PDF MD5s
# authenticate the original bytes. No OCR or web source is substituted.
primary_pages <- function() {
  exe <- Sys.which("pdftotext"); if (!nzchar(exe)) stop("pdftotext must be on PATH.")
  z <- lapply(c(cb, qf, guide, cb2, cb3), function(p) {
    dest <- tempfile(fileext = ".txt"); on.exit(unlink(dest), add = TRUE)
    status <- system2(exe, c("-layout", "-enc", "UTF-8", shQuote(here::here(p)), shQuote(dest)))
    stopifnot(status == 0L)
    text <- paste(readLines(dest, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    strsplit(text, "\f", fixed = TRUE)[[1]]
  })
  names(z) <- c(cb, qf, guide, cb2, cb3); z
}

make_evidence <- function(pages, setup, dct, inventory, issues, manifest) {
  rows <- list()
  evidence <- function(id, cls, fields, path, locator, excerpt, finding,
      limitation = "", issue = "", conflict = "", search = "") {
    stopifnot(file.exists(here::here(path)))
    rows[[length(rows) + 1L]] <<- data.frame(evidence_id = id, evidence_class = cls,
      fields = fields, source_path = path, source_locator = locator,
      source_md5 = unname(hashes(path)), excerpt_md5_utf8_normalized = md5_text(flat(excerpt)),
      excerpt = flat(excerpt), finding = finding, conflict = conflict,
      limitation = limitation, issue_id = issue, bounded_search = search)
  }
  change_section <- function(excerpt, field) {
    lines <- unlist(strsplit(excerpt, "\n", fixed = TRUE))
    start <- grep(paste0("^[[:space:]]*", field, ":"), lines)
    stopifnot(length(start) == 1L)
    # Variable headings begin at the left margin; indented labels such as
    # "K: CHANGE ..." are part of the current definition, not new variables.
    headings <- grep("^[A-Z][A-Z0-9_]*:", lines)
    following <- headings[headings > start]
    end <- if (length(following)) following[1] - 1L else length(lines)
    section <- lines[start:end]
    section[!grepl("^[[:space:]]*-[[:space:]]*[0-9]+[[:space:]]*-[[:space:]]*$", section)]
  }
  page <- function(id, cls, fields, path, pp, finding, limitation = "", issue = "", conflict = "") {
    excerpt <- pages[[path]][pp]
    locator <- paste0("physical pp. ", paste(pp, collapse = ","))
    sections <- switch(id, K_CHANGE = c("TCHCHNGK", "CLASSCHNGK"),
      FIELD_TCHCHNGK = "TCHCHNGK", FIELD_CLASSCHNGK = "CLASSCHNGK", character())
    if (length(sections)) {
      excerpt <- unlist(lapply(sections, change_section, excerpt = excerpt), use.names = FALSE)
      locator <- paste0(locator, "; variable sections ", paste(sections, collapse = ","),
        ": heading through metadata, excluding neighboring entries")
    }
    # Identifier entries include individual child/site listings. Retain only the
    # documentary headings, never the printed child/site values.
    if (id %in% c("CHILD_KEY", "SITE_MEANINGS")) {
      lines <- unlist(strsplit(excerpt, "\n", fixed = TRUE))
      excerpt <- lines[grepl("STUDY_ID:|SITE_(PF|PS|TRPS|TRKF|TRKS):", lines)]
      stopifnot(length(excerpt) > 0L)
    }
    evidence(id, cls, fields, path, locator,
      excerpt, finding, limitation, issue, conflict)
  }
  page("P_FORM", "documented_fact", "T_IDEAP", qf, c(17, 22, 24),
    "Fall Pre-K teacher form contains Ideas About Children item 31: general agreement, not a stated retrospective interval. Item 35 asks today's date.",
    "A date question on the form does not establish a released Pre-K completion-date field or actual respondent identity.")
  page("K_FORM", "documented_fact", "T_IDEAK;TQDATEKF", qf, c(29, 30, 33),
    "Fall 2002 Kindergarten teacher form contains Ideas About Children item 40 and today's date item 1.",
    "General agreement has no explicit retrospective reference period or exposure onset.")
  page("ROLE_CONTEXT", "documented_fact", "T_IDEAP;T_IDEAK", guide, c(13, 15, 37),
    "Pre-K recruitment selected classrooms and lead teachers; Kindergarten follow-up sought children's teachers; teacher questionnaires concern themselves, including beliefs.",
    "Recruitment and administration roles do not authenticate the actual respondent for each released child-attached belief.")
  page("FALL_MAPPING", "supported_inference", "T_IDEAP;T_IDEAK", guide, c(23, 26),
    "Form content and schedules support interpreting the released teacher-belief measures as grade-specific Fall questionnaire reports.",
    "Native Fall placement is also verified against unchanged structural provenance; Fall labels do not establish individual calendar order.")
  page("SPRING_FORMS", "documented_fact", "respondent correspondence", qf, c(45, 49, 57, 61),
    "Forms print classroom/school, teacher, and child identifier slots, with distinct teacher and about-child forms.",
    "Printed identifiers are not a mapping to released STUDY_ID, CASEID, LEAD_1, or site fields.", "Q05;Q06;Q07")
  page("P_CHILD_CHANGE", "documented_fact", "T_CHNGCP", cb, c(313, 314),
    "Child-level Fall-Spring indicator: no teacher/classroom change 972, teacher change 38, classroom change 5; all 1015 nonmissing.",
    "Construction, original reporter, exact endpoints, skips, and treatment of missing source reports are not given here.", "Q08")
  page("P_CLASS_MOVES", "documented_fact", "T_CHNGCP", guide, 15,
    "Five Fall Pre-K participants moved to a classroom at the same site; researchers sought Spring assessments and questionnaires in the new room; T_CHNGCP=2 identifies these children.",
    "Code 2 documents a classroom move, not by itself a teacher change, successful collection, or matched belief respondent.", "Q08")
  page("P_TQ_CHANGE", "documented_fact", "T_CHNG", cb, 580,
    "Teacher-questionnaire-labeled Fall-Spring indicator has 977 no change, 38 teacher change, zero classroom change.",
    "No underlying direct question or derivation is supplied in this entry; keep distinct from T_CHNGCP.", "Q08")
  page("P_CHANGE_UNRESOLVED", "unresolved_question", "T_CHNGCP;T_CHNG", cb, c(313, 580),
    "How do construction, source reports, population, skips, and missing-report treatment differ? Eight literal disagreements remain; no reconciled change flag is justified.",
    "Literal agreement is not evidence of equivalent definitions or validated teacher correspondence.", "Q08",
    "The two release-specific fields have different marginals; no source establishes they should be equivalent.")
  page("K_CHANGE", "documented_fact", "TCHCHNGK;CLASSCHNGK", cb, c(1115, 1116),
    "During-K-year change categories: teacher No/Yes/missing 828/82/105; classroom 859/51/105.",
    "The entries do not specify exact interval endpoints, reporter, construction, or connection to the Fall belief respondent.", "S09_K_ENDPOINTS")
  page("PARTICIPATION", "documented_fact", "CHPARTP;CHPARTK", guide, 14:17,
    "Pre-K Spring maintenance retained children at the same site and recruited replacements; Kindergarten sought Spring Pre-K participants. CHPARTK complete is a multi-instrument definition, not outcome-specific usability.",
    "Guide historical counts and release counts need not coincide. No participation exclusion or missingness recode is applied.")
  page("RELEASE_PARTICIPATION", "documented_fact", "CHPARTP;CHPARTK", cb, c(305, 1108, 1109),
    "CHPARTP released categories are 883 both, 56 Fall only, 76 Spring only. CHPARTK is 49 none, 132 partial, 778 complete, 56 missing.",
    "These release-specific coverage counts are not outcome eligibility or teacher correspondence; no exclusions are imposed.",
    conflict = "Guide pp.14-15 gives Fall/Spring Pre-K 940/960; released CHPARTP implies 939/959. Guide p.16 says CHPARTK missing for children not followed from Spring Pre-K; exact one-child historical difference is not explained. Retain released records unchanged.")
  page("SCHOOL_CHANGE", "documented_fact", "SCHLCHNGK", qf, 93,
    "Kindergarten parent item 19 asks number of school changes during 2002-2003, with zero for the same school all year.",
    "School changes are distinct from teacher/classroom changes and do not identify the belief respondent.")
  page("RELEASE_SCHOOL_CHANGE", "documented_fact", "SCHLCHNGK", cb, 992,
    "Released family-questionnaire school-change count uses the same 2002-2003 wording as parent item 19.",
    "No school-change to teacher/classroom-change recode is supported.")
  page("ASSESSMENT_SCHEDULE", "documented_fact", "assessment timing", guide, c(25, 27),
    "Study schedules describe Fall/Spring assessment occasions in 2001-2002 and 2002-2003.",
    "Schedules are not individual assessment calendar dates or evidence that Fall assessment preceded instruction.")
  page("CHILD_KEY", "documented_fact", "STUDY_ID", cb, 6,
    "STUDY_ID is documented as the unique child identifier.", "It is not documented here as a cross-file classroom or teacher key.", "Q05")
  page("SITE_MEANINGS", "documented_fact", "SITE_PF;SITE_PS;SITE_TRPS;SITE_TRKF;SITE_TRKS", cb,
    c(315, 317, 319, 1118, 1119),
    "Release labels describe Pre-K site IDs or sites where teachers rated a child.",
    "Site labels establish no unique teacher identity, stable teacher/classroom hierarchy, or Fall-to-Spring respondent match.", "Q07")
  page("CLASSROOM_CASE_KEYS", "documented_fact", "DS0002.CASEID;DS0003.CASEID", cb2, 6,
    "DS0002 labels CASEID only Case Identifier at classroom-record unit; DS0003 also labels CASEID only CASE IDENTIFIER.",
    "The separate DS0003 source evidence row verifies its label. No released child relationship is supplied by these labels.", "Q05")
  page("PREK_CASE_KEY", "documented_fact", "DS0003.CASEID", cb3, 6,
    "DS0003 is the Pre-K classroom-level public-use file and CASEID is a case identifier.", "No child linkage instruction in this entry.", "Q05")
  page("LEAD_SCOPE", "unresolved_question", "DS0003.LEAD_1", cb3, 159,
    "LEAD_1 is labeled Teacher ID without a uniqueness or longitudinal scope statement; frequencies 50:240, 52:1, 58:3, missing:1.",
    "No independent-teacher counts or child correspondence can be validated from this label/distribution.", "Q06")
  page("SCORING_CONTEXT", "unresolved_question", "T_IDEAP;T_IDEAK", guide, 40,
    "Existing Stage 06 scoring/direction questions remain unresolved; mean/reversal/progressive wording is retained as a discrepancy for review, not a new scoring rule.",
    "No new evidence here resolves release-specific construction; Stage 06 is not reopened.", "Q01",
    "General guide mean and direction language does not resolve released composite construction.")
  # Exact field-level release definitions, labels, replacements, and page excerpts.
  field_pages <- c(T_IDEAP = 538, T_IDEAK = 788, T_CHNGCP = 313, T_CHNG = 580,
    TCHCHNGK = 1115, CLASSCHNGK = 1116, TQDATEKF = 782, TQDATEKS = 837,
    TQSCDATEKF = 639, TQSCDATEKS = 681, ASMTAGEPF = 305, ASMTAGEPS = 307,
    ASMTAGEKF = 1110, ASMTAGEKS = 1112, AMSNTDAYP = 314, AMSNTDAYK = 1113,
    ASMNTDAYPKK = 1122)
  for (f in names(field_pages)) page(paste0("FIELD_", f), "documented_fact", f, cb, field_pages[[f]],
    if (f %in% dates) paste(f, "is a teacher-form completion date, not a child-assessment date.") else
    if (f %in% definition_only) paste(f, "records assessment age or elapsed assessment spacing, not a calendar anchor.") else
      paste(f, "release definition and unweighted frequencies."),
    if (f %in% dates) "No calendar epoch is supplied in this entry; completion does not date the onset of beliefs or teaching." else
      "Interpret within the documented unit and period; no undocumented transformation.")
  for (ds in c("DS0001", "DS0002", "DS0003")) {
    fs <- switch(ds, DS0001 = c("STUDY_ID", core, dates, definition_only),
      DS0002 = c("CASEID", "T_IDEAK", "TQDATEKF", "TQDATEKS"),
      DS0003 = c("CASEID", "LEAD_1", "T_IDEAP", "T_CHNG"))
    for (f in fs) {
      ix <- grep(paste0("[[:space:]]", f, "[[:space:]]"), dct[[ds]])
      stopifnot(length(ix) == 1L)
      evidence(paste("DCT", ds, f, sep = "_"), "documented_fact", paste(ds, f, sep = "."),
        docbase(ds, "dct"), paste0("line ", ix), dct[[ds]][ix],
        "Released dictionary declaration; variable label and storage/display type.",
        "A date-like numeric or string format without a documented epoch does not authorize decoding; identifiers do not establish a linkage.")
      st <- grep(paste0("^label define ", f, "[[:space:]]"), setup[[ds]])
      rp <- grep(paste0("^replace ", f, " = "), setup[[ds]])
      if (length(st)) {
        en <- st + which(grepl(";", setup[[ds]][st:length(setup[[ds]])], fixed = TRUE))[1] - 1L
        evidence(paste("SETUP", ds, f, sep = "_"), "documented_fact", paste(ds, f, sep = "."),
          docbase(ds, "do"), paste0("lines ", st, "-", en, "; replacement lines ", paste(rp, collapse = ",")),
          setup[[ds]][c(st:en, rp)], "Release label definitions and missing replacements; no derivation inferred.",
          "Released R NA does not preserve the original reason. Labeling code 0 does not explain handling of absent underlying reports.")
      }
    }
  }
  date_pattern <- "DATE|DATED|CALENDAR|ASSESS|ASMNT|ASMT|AMSNT|TIME|DAY|MONTH|YEAR|BIRTH"
  ix <- grep(date_pattern, dct$DS0001, ignore.case = TRUE)
  evidence("ASSESSMENT_DATE_ABSENCE", "unresolved_question", "child-assessment calendar dates", docbase("DS0001", "dct"),
    paste0("all declarations; date/timing matches at lines ", paste(ix, collapse = ",")), dct$DS0001[ix],
    "Bounded absence: approved planning search found no suitable released child-assessment calendar-date fields and no released Pre-K belief completion-date counterpart in inspected local release.",
    "This is a bounded search finding, not a claim about uninspected/restricted releases. No ordering counts or synthetic missing assessment-date vectors are generated.",
    "S09_ORDER", search = paste("Planning searched all DS0001 declarations and source-variable inventory; date/timing terms across all 1124 physical codebook pages; relevant assessment/date entries and forms; targeted DS0002/DS0003 dictionaries.",
      "Implementation rechecks declarations/inventory and all-page codebook date/timing search; definition-only ages/spacing remain excluded from computation."))
  # Only DS0001 has an approved all-codebook-page date search. Classroom
  # dictionaries/entries are inspected at the listed targets, not searched broadly.
  for (ds in "DS0001") {
    pp <- pages[[cb]]
    hits <- which(grepl("date|calendar|assessment|days between|time of", pp, ignore.case = TRUE))
    evidence(paste0("DATE_SEARCH_", ds), "documented_fact", "date-field search basis",
      switch(ds, DS0001 = cb, DS0002 = cb2, DS0003 = cb3),
      paste0("all ", length(pp), " physical pages; date/timing hit pages ", paste(hits, collapse = ",")),
      paste("Search terms: date|calendar|assessment|days between|time of; matched pages:", paste(hits, collapse = ",")),
      "Reproducible page-search index for the closed investigation, not new quantitative fields.",
      "Search matches are navigation only; field definitions and the approved completed planning check govern the bounded absence conclusion.")
  }
  inv <- inventory[inventory$dataset_id == "DS0001" & grepl(date_pattern,
    paste(inventory$raw_variable, inventory$r_label_attribute), ignore.case = TRUE), c("raw_variable", "r_label_attribute")]
  evidence("INVENTORY_SEARCH", "documented_fact", "date-field search basis", "output/tables/source_variable_inventory.csv",
    "DS0001 raw_variable and r_label_attribute; date/timing terms; documentary columns only",
    paste(inv$raw_variable, inv$r_label_attribute, sep = ": "), "Existing variable inventory consulted with declarations; no data field list is expanded.",
    "Inventory is a navigation aid; primary dictionary/codebook definitions govern.")
  miss <- grep("Supplemental_syntax", manifest, fixed = TRUE)
  evidence("MISSING_DERIVATION_SYNTAX", "unresolved_question", "derivations;linkage", "docs/icpsr/04283-manifest.txt",
    paste0("lines ", paste(miss, collapse = ",")), manifest[miss],
    "Manifest lists supplemental .do/.sas syntax for all three files; these six files are absent locally.",
    "No source acquisition in Stage 09; derivation and linkage questions remain bounded.", "Q01;Q05;Q08;S09_K_ENDPOINTS")
  evidence("PRIOR_ISSUES", "unresolved_question", "Q01;Q05;Q06;Q07;Q08", "docs/stage1_unresolved_issues.md",
    "Q01, Q05-Q08 headings", issues,
    "Prior issue register consulted; no issue is silently resolved by Stage 09.", "Read alongside primary-source rows; upstream issue register remains unchanged.")
  page("CORRESPONDENCE_ASSUMPTION", "possible_analytical_assumption", "Fall respondent;Spring teacher", guide, c(15, 37),
    "A future Spring exposure interpretation would need a separately justified assumption that the Fall belief report characterizes the child's relevant Spring teacher and exposure period.",
    "Only released change indicators are available; neither a no-change category nor joint availability validates that assumption.", "S09_CORRESPONDENCE")
  page("TIMING_ASSUMPTION", "possible_analytical_assumption", "belief timing;exposure", guide, c(23, 25, 26, 27),
    "Assuming prospective belief measurement, stability, or a pre-exposure Fall baseline would require additional justification; none is established by the seasonal schedules.",
    "Completion and belief onset, Fall assessment, Spring assessment, and teaching exposure are separate concepts.", "S09_ORDER")
  # Search the corresponding forms for actual change questions without attributing
  # a generic change question to a derived field. Record finite scope and hits.
  form_pp <- 17:64
  pattern <- "chang.{0,45}(teacher|classroom)|teacher.{0,45}chang|classroom.{0,45}chang|new teacher|same teacher"
  hits <- form_pp[vapply(pages[[qf]][form_pp], function(t) grepl(pattern, flat(t), ignore.case = TRUE), logical(1))]
  evidence("CHANGE_QUESTION_SEARCH", "unresolved_question", "T_CHNGCP;T_CHNG;TCHCHNGK;CLASSCHNGK", qf,
    "physical pp. 17-64 (Fall/Spring Pre-K and Kindergarten teacher and about-child forms); teacher/classroom change terms",
    paste("Pattern:", pattern, "; hit pages:", paste(hits, collapse = ",")),
    "No positively documented underlying question-to-derived-field mapping was established from these forms, release entries, setup blocks, or direct guide references.",
    "A phrase search alone cannot prove absence; searched form text and release entries provide no derivation. Stop at separate released categories.", "Q08;S09_K_ENDPOINTS")
  bind(rows)
}

make_fields <- function(evidence, src, dct, setup) {
  rows <- list()
  add <- function(ds, f, role, occasion, reference, population, implication, status = "documented_fact") {
    ix <- grep(paste0("[[:space:]]", f, "[[:space:]]"), dct[[ds]])
    stopifnot(length(ix) == 1L)
    es <- evidence$evidence_id[grepl(f, evidence$fields, fixed = TRUE) &
      (grepl(ds, evidence$fields, fixed = TRUE) | !grepl("DS000[23]", evidence$fields))]
    st <- grep(paste0("^label define ", f, "[[:space:]]"), setup[[ds]])
    en <- if (length(st)) st + which(grepl(";", setup[[ds]][st:length(setup[[ds]])], fixed = TRUE))[1] - 1L else integer()
    rp <- grep(paste0("^replace ", f, " = "), setup[[ds]])
    x <- if (ds == "DS0001" && f %in% quantitative) src[[f]] else NULL
    rows[[length(rows) + 1L]] <<- data.frame(dataset = ds, field = f, evidence_class = status,
      released_definition = trimws(dct[[ds]][ix]), respondent_unit = role,
      administration_period = occasion, reference_period = reference,
      population_skips = population, coding_and_missing = flat(setup[[ds]][c(if (length(st)) st:en, rp)]),
      observed_representation = if (is.null(x)) "not loaded; documentary only" else
        paste0("class=", paste(class(x), collapse = "/"), "; typeof=", typeof(x), "; attributes=", flat(capture.output(dput(attributes(x))))),
      calendar_decoding = if (f %in% dates) paste0("unresolved: ",
        if (ds == "DS0001") "numeric values; no Date class or documented epoch" else "dictionary string field; released child linkage and encoding unestablished",
        "; no conversion") else "not applicable",
      timing_limitation = "Seasonal occasion/form completion does not establish individual ordering or onset of teaching/beliefs.",
      correspondence_implication = implication, evidence_ids = paste(unique(es), collapse = ";"),
      source_path = docbase(ds, "dct"), source_locator = paste0("line ", ix),
      source_md5 = unname(hashes(docbase(ds, "dct"))))
  }
  for (f in c("T_IDEAP", "T_IDEAK")) add("DS0001", f,
    "Child-attached teacher questionnaire composite; intended teacher respondent; per-record actual respondent/lead status unresolved",
    if (f == "T_IDEAP") "Fall Pre-K; supported by form/schedule/provenance" else "Fall Kindergarten; supported by form/schedule/provenance",
    "General agreement; no explicit retrospective interval in Modernity items",
    "Observed in 987 Pre-K or 840 Kindergarten children; item completion and source skips unresolved",
    "Fall teacher report is supported; identifying it with Spring teacher/exposure requires an unvalidated correspondence assumption")
  for (f in c("T_CHNGCP", "T_CHNG")) add("DS0001", f,
    if (f == "T_CHNGCP") "Child-level derived change record; original reporter not established" else
      "Child-attached teacher-questionnaire-labeled change record; underlying question/reporter not established",
    "Pre-K Fall-Spring label; exact endpoint dates unresolved", "Fall-Spring label; no duration or complete history",
    "1015 nonmissing released records despite single-season participants; source report/skips/missing construction unresolved",
    "Retain 0/1/2 separately; code 2 is not proof of teacher change; Q08 unresolved")
  for (f in c("TCHCHNGK", "CLASSCHNGK")) add("DS0001", f,
    "Child-attached derived record; reporter and construction unresolved", "During Kindergarten year",
    "During K year; precise endpoints relative to Fall belief respondent and assessments unresolved",
    "910 nonmissing and 105 released missing; do not infer source missing-report treatment",
    "No/Yes are released change categories; no validated respondent correspondence or stable teacher identity")
  for (f in dates) add("DS0001", f,
    if (grepl("TQSC", f)) "Teacher questionnaire about individual study child; child-attached date" else
      "Teacher self/class questionnaire completion; child-attached date",
    if (grepl("KF$", f)) "Fall Kindergarten form" else "Spring Kindergarten form",
    "Date teacher completed the particular form; not assessment or exposure onset",
    "All-child, observed-belief, and mapped belief-plus-pair coverage; released NA reasons collapsed",
    if (f == "TQDATEKF") "Relevant Fall belief-form completion field; no assessment calendar anchor" else
      "Distinct form completion only; cannot substitute for belief completion or assessment date")
  for (f in definition_only) add("DS0001", f,
    if (grepl("^ASMTAGE|DAY", f)) "Child assessment administration metadata; definition only" else
    if (f == "SCHLCHNGK") "Parent/family questionnaire about child; item 19" else
    if (grepl("^CHPART", f)) "Child study participation record; study administration" else "Child-attached site record; not teacher identity",
    if (f == "SCHLCHNGK") "Kindergarten family form" else "As specified by released declaration",
    if (grepl("^ASMTAGE", f)) "Age in years at assessment" else
    if (grepl("DAY", f)) "Elapsed days between specified assessments" else
    if (f == "SCHLCHNGK") "2002-2003 school year" else "As labeled; no individual calendar sequence established",
    if (f == "CHPARTP") "Pre-K Fall/Spring/both; Spring replacement recruitment; no sample exclusion" else
    if (f == "CHPARTK") "Guide: Spring Pre-K follow-up; complete is multi-instrument coverage, not every outcome pair" else
      "Definition only; no new diagnostic or recoding",
    if (grepl("^ASMTAGE|DAY", f)) "Not a calendar date; no date reconstruction" else
    if (f == "SCHLCHNGK") "School changes do not identify teachers or classroom changes" else
    if (grepl("^SITE", f)) "Site/rating-site labels do not validate teacher/classroom identity or longitudinal correspondence" else
      "Participation coverage differs from score eligibility and teacher correspondence")
  add("DS0001", "STUDY_ID", "Unique child identifier", "Study record", "Child across structural occasions",
    "1015 unique keys", "No documented cross-file mapping to CASEID")
  for (ds in c("DS0002", "DS0003")) for (f in if (ds == "DS0002") c("CASEID", "T_IDEAK", "TQDATEKF", "TQDATEKS") else
    c("CASEID", "LEAD_1", "T_IDEAP", "T_CHNG")) add(ds, f,
      "Separate classroom-file record; documentary inspection only", "As labeled in release",
      "As labeled; no validated child correspondence", "No classroom-file research data loaded",
      "No explicit child-to-classroom/teacher linkage established; no merge or pattern/score matching")
  z <- bind(rows)
  absent <- z[1, ]; absent[] <- ""
  absent$dataset <- "DS0001 (bounded local release)"; absent$field <- "NO_SUITABLE_ASSESSMENT_CALENDAR_DATE_IDENTIFIED"
  absent$evidence_class <- "unresolved_question"
  absent$released_definition <- "No suitable released child-assessment calendar dates or Pre-K belief completion-date counterpart identified within approved search"
  absent$respondent_unit <- "Search conclusion; not a synthetic child-level variable"
  absent$administration_period <- "Fall/Spring Pre-K and Kindergarten"
  absent$population_skips <- "No paired-date or complete-three-date denominator exists for this investigation"
  absent$calendar_decoding <- "Unavailable; no ages/spacing reconstruction or questionnaire-date substitution"
  absent$timing_limitation <- "Cannot establish before/same-day/after or three-date sequence; no ordering statistics generated"
  absent$correspondence_implication <- "Temporal order remains unresolved independently of respondent correspondence"
  absent$evidence_ids <- "ASSESSMENT_DATE_ABSENCE;DATE_SEARCH_DS0001;INVENTORY_SEARCH"
  absent$source_path <- docbase("DS0001", "dct"); absent$source_locator <- "all declarations; see ASSESSMENT_DATE_ABSENCE"
  absent$source_md5 <- unname(hashes(absent$source_path))
  rbind(z, absent)
}

# Explicit released categories, including documented zero cells and a separate NA
# category. Category numbers are documentary labels, never inferred identities.
category_definition <- function(f, src, setup) {
  st <- grep(paste0("^label define ", f, "[[:space:]]"), setup)
  en <- st + which(grepl(";", setup[st:length(setup)], fixed = TRUE))[1] - 1L
  s <- flat(setup[st:en]); tokens <- regmatches(s, gregexpr('[-]?[0-9]+ "[^"]*"', s))[[1]]
  code <- as.integer(sub(' .*$', '', tokens)); label <- sub('^[-]?[0-9]+ "(.*)"$', '\\1', tokens)
  keep <- code >= 0L; code <- code[keep]; label <- label[keep]
  stopifnot(length(code) > 0L, !anyDuplicated(code), is.factor(src[[f]]))
  observed <- as.integer(sub("^\\(([0-9]+)\\).*$", "\\1", levels(src[[f]])))
  stopifnot(identical(observed, code), identical(sub("^\\([0-9]+\\) ", "", levels(src[[f]])), label))
  data.frame(code = c(as.character(code), "missing"), label = c(label, "Released NA; original missing reason unavailable"),
    kind = c(rep("released_value", length(code)), "source_missing"))
}
literal_codes <- function(x) ifelse(is.na(x), "missing", sub("^\\(([0-9]+)\\).*$", "\\1", as.character(x)))

make_diagnostics <- function(src, groups, definitions) {
  rows <- list()
  add <- function(gr, type, a, b = "", ca, la, ka, cbv = "", lb = "", kb = "",
      n, denom, nonmissing, status = "available", note = "") {
    z <- data.frame(grade = gr$grade, group_id = gr$id, group_kind = gr$kind, outcome = gr$outcome,
      language = gr$language, metric = gr$metric, group_status = gr$status,
      diagnostic = type, field_a = a, field_b = b, category_a = ca, label_a = la, kind_a = ka,
      category_b = cbv, label_b = lb, kind_b = kb,
      n_children = as.integer(n), denominator_group = as.integer(denom),
      denominator_nonmissing = as.integer(nonmissing), pct_group = pct(n, denom),
      pct_nonmissing = ifelse(ka == "source_missing" | kb == "source_missing" | type != "change_distribution" & type != "change_crosstab",
        NA_real_, pct(n, nonmissing)), diagnostic_status = status, interpretation = note)
    rows[[length(rows) + 1L]] <<- z
  }
  for (gr in groups) {
    use <- gr$use; d <- if (gr$status == "unmapped") NA_integer_ else sum(use)
    fs <- if (gr$grade == "Pre-K") c("T_CHNGCP", "T_CHNG") else c("TCHCHNGK", "CLASSCHNGK")
    for (f in fs) {
      defs <- definitions[[f]]; codes <- literal_codes(src[[f]])
      nm <- if (is.na(d)) NA_integer_ else sum(use & !is.na(src[[f]]))
      for (j in seq_len(nrow(defs))) add(gr, "change_distribution", f, ca = defs$code[j], la = defs$label[j], ka = defs$kind[j],
        n = if (is.na(d)) NA_integer_ else sum(use & codes == defs$code[j]), denom = d, nonmissing = nm,
        status = if (is.na(d)) "undefined_unmapped" else if (d == 0L) "empty_group" else "released_categories_only",
        note = "Released change report only; not validated Fall belief respondent to Spring teacher correspondence")
    }
    a <- definitions[[fs[1]]]; b <- definitions[[fs[2]]]
    va <- literal_codes(src[[fs[1]]]); vb <- literal_codes(src[[fs[2]]])
    nm <- if (is.na(d)) NA_integer_ else sum(use & !is.na(src[[fs[1]]]) & !is.na(src[[fs[2]]]))
    for (i in seq_len(nrow(a))) for (j in seq_len(nrow(b))) add(gr, "change_crosstab", fs[1], fs[2],
      a$code[i], a$label[i], a$kind[i], b$code[j], b$label[j], b$kind[j],
      if (is.na(d)) NA_integer_ else sum(use & va == a$code[i] & vb == b$code[j]), d, nm,
      if (is.na(d)) "undefined_unmapped" else if (d == 0L) "empty_group" else "released_categories_only",
      "Joint released categories; literal code equality does not imply common definitions or teacher identity")
    # The four date fields belong to Kindergarten. Pre-K has no released counterpart.
    if (gr$grade == "Kindergarten") for (f in dates) {
      x <- src[[f]]
      states <- ifelse(is.na(x), "source_missing", ifelse(!is.finite(x), "nonfinite_present",
        ifelse(x != trunc(x), "noninteger_present", "numeric_present_calendar_unvalidated")))
      for (st in c("source_missing", "nonfinite_present", "noninteger_present", "numeric_present_calendar_unvalidated"))
        add(gr, "questionnaire_date_coverage", f, ca = st, la = st, ka = st,
          n = if (is.na(d)) NA_integer_ else sum(use & states == st), denom = d,
          nonmissing = if (is.na(d)) NA_integer_ else sum(use & !is.na(x)),
          status = if (is.na(d)) "undefined_unmapped" else "calendar_encoding_unresolved",
          note = "Coverage of this form only; no calendar conversion, assessment substitution, or ordering comparison")
    }
    # Unestablished is a documentary status for the whole group, not zero matches.
    add(gr, "correspondence_status", "Fall belief respondent to Spring teacher", ca = "unestablished",
      la = "No validated correspondence relationship in inspected sources", ka = "documentary_status",
      n = NA_integer_, denom = d, nonmissing = NA_integer_, status = "not_quantifiable",
      note = "n_children is undefined, not zero validated matches; denominator_group is the support population, not a matched-teacher denominator")
  }
  z <- bind(rows); z$row_id <- paste0("diagnostic:", seq_len(nrow(z))); z
}

run_stage <- function(outdir) {
  paths_before <- protected_paths(); before <- hashes(paths_before)
  checks <- data.frame(check_id = character(), severity = character(), expected = character(),
    observed = character(), status = character(), detail = character())
  fmt <- function(x) paste(ifelse(is.na(x), "undefined", as.character(x)), collapse = " | ")
  hard <- function(id, condition, expected = TRUE, observed = condition, detail = "") {
    stopifnot(!id %in% checks$check_id)
    checks <<- rbind(checks, data.frame(check_id = id, severity = "hard", expected = fmt(expected), observed = fmt(observed),
      status = if (isTRUE(condition)) "pass" else "fail", detail = detail))
    if (!isTRUE(condition)) stop("Failed check: ", id, "; expected ", fmt(expected), "; observed ", fmt(observed))
  }
  # Context is read first. No upstream script is sourced or historical check rerun.
  cw <- read_csv("docs/stage1_variable_crosswalk.csv")
  prov <- read_csv("output/tables/verified_wide_provenance.csv")
  panel_prov <- read_csv("output/tables/structural_panel_provenance.csv")
  inventory <- read_csv("output/tables/source_variable_inventory.csv")
  issues <- readLines(here::here("docs/stage1_unresolved_issues.md"), warn = FALSE)
  prior_reports <- lapply(c("output/verification/belief_score_review.md", "output/reports/stage08_sample_profile.md"),
    function(p) readLines(here::here(p), warn = FALSE))
  hard("context_consulted", all(core %in% cw$raw_variable) && all(core %in% prov$raw_variable) &&
    all(c("Q05", "Q06", "Q07", "Q08") %in% regmatches(paste(issues, collapse = " "),
      gregexpr("Q0[5-8]", paste(issues, collapse = " ")))[[1]]) && all(lengths(prior_reports) > 0L))
  head <- system2("git", c("rev-parse", "HEAD"), stdout = TRUE)
  branch <- system2("git", c("branch", "--show-current"), stdout = TRUE)
  hard("current_head_recorded", is.null(attr(head, "status")) && length(head) == 1L && nzchar(head),
    "readable actual Git HEAD", head)
  hard("current_branch_recorded", is.null(attr(branch, "status")) && length(branch) <= 1L,
    "readable actual branch (or detached HEAD)", if (length(branch)) branch else "(detached HEAD)")
  if (!length(branch)) branch <- "(detached HEAD)"
  hard("tracked_tree_clean", system2("git", c("diff", "--quiet")) == 0L)
  hard("index_clean", system2("git", c("diff", "--cached", "--quiet")) == 0L)
  raw_path <- "Data/raw/icpsr_04283/04283-0001-Data.rda"
  env <- new.env(parent = baseenv()); loaded <- load(here::here(raw_path), envir = env)
  hard("isolated_ds0001_load", identical(loaded, "da04283.0001"))
  raw <- env[[loaded]]
  hard("source_dimensions", identical(dim(raw), c(1015L, 1210L)), "1015 x 1210", dim(raw))
  hard("source_release_fingerprint", unname(hashes(raw_path)) == "e1dd29c3fe46e0ac1ebb90f51ef041d3")
  hard("finite_allowlist_present", all(quantitative %in% names(raw)))
  src <- raw[quantitative]; rm(raw, env)
  hard("source_child_key_unique", !anyNA(src$STUDY_ID) && !anyDuplicated(src$STUDY_ID))
  wide <- readRDS(here::here("Data/processed/verified_child_wide.rds"))
  panel <- readRDS(here::here("Data/processed/outcome_cleaning_panel.rds"))
  structural <- readRDS(here::here("Data/processed/structural_child_wave_panel.rds"))
  hard("wide_dimensions", identical(dim(wide), c(1015L, 62L)))
  hard("panel_dimensions", identical(dim(panel), c(4060L, 65L)))
  hard("structural_dimensions", identical(dim(structural), c(4060L, 37L)))
  hard("original_panel_columns_preserved", identical(panel[names(structural)], structural))
  ix <- match(wide$STUDY_ID, src$STUDY_ID)
  hard("source_to_wide_child_join", !anyNA(ix) && !anyDuplicated(ix) && identical(src$STUDY_ID[ix], wide$STUDY_ID))
  # The verified wide preserves source sequence. Avoid data.frame row subsetting,
  # which drops the release's nonstandard value.labels attribute on numeric fields.
  hard("source_sequence_preserved", identical(ix, seq_len(nrow(src))))
  for (f in core) hard(paste0("source_to_wide:", f), identical(src[[f]], wide[[f]]))
  hard("structural_keys", !anyNA(panel$STUDY_ID) && !anyDuplicated(panel[c("STUDY_ID", "wave")]) &&
    setequal(panel$STUDY_ID, wide$STUDY_ID) && all(table(panel$STUDY_ID) == 4L))
  by_wave <- setNames(lapply(waves, function(w) {
    z <- panel[panel$wave == w, ]; j <- match(wide$STUDY_ID, z$STUDY_ID)
    hard(paste0("panel_join:", w), nrow(z) == 1015L && !anyNA(j) && !anyDuplicated(j))
    z[j, , drop = FALSE]
  }), waves)
  for (g in 1:2) for (w in waves) hard(paste("native_fall_belief", g, w, sep = ":"),
    if (w == waves[2L * g - 1L]) identical(as.numeric(by_wave[[w]][[belief_panel[g]]]), as.numeric(wide[[core[g]]])) else
      all(is.na(by_wave[[w]][[belief_panel[g]]])))
  for (f in core) {
    pr <- prov[prov$raw_variable == f, ]
    hard(paste0("raw_provenance:", f), nrow(pr) == 1L && pr$included_in_output && pr$transformation_applied == "none")
  }
  for (g in 1:2) {
    pr <- panel_prov[panel_prov$source_variable == core[g] & panel_prov$mapping_class == "source_specific_native_wave", ]
    hard(paste0("belief_provenance:", g), nrow(pr) == 1L && pr$wave == waves[2L * g - 1L])
  }
  dct <- setNames(lapply(c("DS0001", "DS0002", "DS0003"), function(ds)
    readLines(here::here(docbase(ds, "dct")), warn = FALSE)), c("DS0001", "DS0002", "DS0003"))
  setup <- setNames(lapply(names(dct), function(ds)
    readLines(here::here(docbase(ds, "do")), warn = FALSE)), names(dct))
  pages <- primary_pages()
  hard("all_1124_child_codebook_pages", length(pages[[cb]]) == 1124L, 1124L, length(pages[[cb]]))
  manifest <- readLines(here::here("docs/icpsr/04283-manifest.txt"), warn = FALSE)
  supplemental <- unlist(lapply(1:3, function(i) paste0("docs/icpsr/DS000", i, "/04283-000", i,
    "-Supplemental_syntax.", c("do", "sas"))))
  hard("six_manifest_syntax_files_absent", all(!file.exists(here::here(supplemental))) &&
    sum(grepl("Supplemental_syntax", manifest, fixed = TRUE)) == 6L)
  evidence <- make_evidence(pages, setup, dct, inventory, issues, manifest)
  fields <- make_fields(evidence, src, dct, setup)
  hard("evidence_classes", setequal(evidence$evidence_class,
    c("documented_fact", "supported_inference", "possible_analytical_assumption", "unresolved_question")))
  hard("evidence_unique", !anyDuplicated(evidence$evidence_id) && all(nzchar(evidence$source_locator)) && all(nzchar(evidence$excerpt)))
  for (id in c("K_CHANGE", "FIELD_TCHCHNGK", "FIELD_CLASSCHNGK")) {
    z <- evidence$excerpt[evidence$evidence_id == id]
    fs <- if (id == "K_CHANGE") c("TCHCHNGK", "CLASSCHNGK") else sub("FIELD_", "", id, fixed = TRUE)
    hard(paste0("bounded_change_excerpt:", id), length(z) == 1L &&
      all(vapply(fs, function(f) grepl(paste0(f, ":"), z, fixed = TRUE), logical(1))) &&
      grepl("Based upon 910 valid cases out of 1,015 total cases.", z, fixed = TRUE) &&
      grepl("System Missing", z, fixed = TRUE) && grepl("Variable Type: numeric", z, fixed = TRUE) &&
      grepl("(Range of) Missing Values: -99", z, fixed = TRUE) &&
      !grepl("SITE_ECK:", z, fixed = TRUE))
  }
  hard("no_neighbor_site_identifier_listings", !any(grepl("SITE_[A-Z0-9_]+:", evidence$excerpt) &
    grepl("Value Label", evidence$excerpt, fixed = TRUE)))
  for (p in unique(evidence$source_path)) hard(paste0("source_evidence_hash:", p),
    all(evidence$source_md5[evidence$source_path == p] == unname(hashes(p))))
  for (i in seq_len(nrow(evidence))) hard(paste0("excerpt_hash:", evidence$evidence_id[i]),
    md5_text(evidence$excerpt[i]) == evidence$excerpt_md5_utf8_normalized[i])
  hard("field_rows_unique", !anyDuplicated(fields[c("dataset", "field")]) && nrow(fields) == 35L, 35L, nrow(fields))
  definitions <- setNames(lapply(core[3:6], category_definition, src = src, setup = setup$DS0001), core[3:6])
  expected <- list(T_CHNGCP = c(972L, 38L, 5L, 0L), T_CHNG = c(977L, 38L, 0L, 0L),
    TCHCHNGK = c(828L, 82L, 105L), CLASSCHNGK = c(859L, 51L, 105L))
  for (f in names(definitions)) {
    n <- as.integer(table(factor(literal_codes(src[[f]]), levels = definitions[[f]]$code)))
    hard(paste0("released_change_marginal:", f), identical(n, expected[[f]]), expected[[f]], n)
  }
  equal <- literal_codes(src$T_CHNGCP) == literal_codes(src$T_CHNG)
  hard("pre_k_literal_agreements", sum(equal) == 1007L && sum(!equal) == 8L, c(1007, 8), c(sum(equal), sum(!equal)))
  beliefs <- lapply(core[1:2], function(f) !is.na(src[[f]]))
  hard("belief_coverage", identical(vapply(beliefs, sum, integer(1)), c(987L, 840L)), c(987, 840), vapply(beliefs, sum, integer(1)))
  hard("observed_beliefs_finite", all(vapply(src[core[1:2]], function(x) all(is.finite(x[!is.na(x)])), logical(1))))
  support <- read_csv("output/tables/stage08_belief_outcome_support.csv")
  counts <- read_csv("output/tables/outcome_cleaning_counts.csv")
  groups <- list()
  for (g in 1:2) {
    add_group <- function(id, kind, outcome = "all_outcomes", use, status = "defined", language = "not applicable", metric = "not applicable") {
      groups[[length(groups) + 1L]] <<- list(id = id, kind = kind, grade = grades[g], outcome = outcome,
        use = use, status = status, language = language, metric = metric)
    }
    add_group(paste0("g", g, ":all"), "all_children", use = rep(TRUE, nrow(src)))
    add_group(paste0("g", g, ":belief"), "belief_observed", use = beliefs[[g]])
    for (o in outcomes) {
      wi <- (2L * g - 1L):(2L * g)
      co <- counts[counts$outcome == o, ]; co <- co[match(waves, co$wave), ]
      hard(paste("mapping_rows", g, o, sep = ":"), nrow(co) == 4L && !anyNA(co$wave) && !anyDuplicated(co$wave))
      ef <- paste0(o, "_eligible_current_rules")
      e <- lapply(by_wave[waves[wi]], `[[`, ef)
      mapped <- all(co$mapped[wi])
      for (j in 1:2) {
        r <- by_wave[[waves[wi[j]]]][[paste0(o, "_cleaning_reason")]]
        hard(paste("unchanged_eligibility", g, o, j, sep = ":"), is.logical(e[[j]]) &&
          identical(is.na(e[[j]]), r == "unresolved_score_value") &&
          all(e[[j]][!is.na(e[[j]])] == (r[!is.na(e[[j]])] == "retained_under_current_rules")) &&
          sum(e[[j]] %in% TRUE) == co$n_eligible_current_rules[wi[j]])
      }
      z <- support[support$outcome == o & support$grade == grades[g], ]
      hard(paste("stage08_support_keys", g, o, sep = ":"), nrow(z) == 3L && setequal(z$outcome_period, c("fall", "spring", "both")))
      for (period in c("fall", "spring", "both")) {
        jj <- switch(period, fall = 1L, spring = 2L, both = 1:2)
        valid <- Reduce(`&`, lapply(e[jj], function(x) x %in% TRUE))
        unres <- Reduce(`|`, lapply(e[jj], is.na))
        zz <- z[z$outcome_period == period, ]; mp <- all(co$mapped[wi[jj]])
        hard(paste("stage08_support_reconciliation", g, o, period, sep = ":"), zz$mapped == mp &&
          zz$denominator_all_children == 1015L && zz$denominator_belief_nonmissing == sum(beliefs[[g]]) &&
          if (mp) zz$n_overlap == sum(beliefs[[g]] & valid) && zz$n_outcome_usable == sum(valid) &&
            zz$n_outcome_unresolved == sum(unres) && zz$n_belief_with_unresolved_outcome == sum(beliefs[[g]] & unres) else
            is.na(zz$n_overlap) && is.na(zz$n_outcome_usable))
      }
      both <- z[z$outcome_period == "both", ]
      use <- if (mapped) beliefs[[g]] & e[[1]] %in% TRUE & e[[2]] %in% TRUE else rep(FALSE, nrow(src))
      add_group(paste0("g", g, ":pair:", o), "belief_plus_complete_pair", o, use,
        if (mapped) "defined" else "unmapped", both$language, both$metric)
    }
  }
  hard("applied_problems_support_721_756", identical(vapply(groups[c(4, 15)], function(gr) sum(gr$use), integer(1)), c(721L, 756L)))
  diagnostics <- make_diagnostics(src, groups, definitions)
  for (gr in groups) {
    z <- diagnostics[diagnostics$group_id == gr$id, ]
    parts <- split(z[z$diagnostic != "correspondence_status", ],
      interaction(z$diagnostic[z$diagnostic != "correspondence_status"], z$field_a[z$diagnostic != "correspondence_status"], drop = TRUE))
    for (key in names(parts)) {
      a <- parts[[key]]; d <- if (gr$status == "unmapped") NA_integer_ else sum(gr$use)
      hard(paste("partition", gr$id, key, sep = ":"), if (is.na(d)) all(is.na(a$n_children)) && all(is.na(a$denominator_group)) else
        sum(a$n_children) == d && all(a$denominator_group == d), d, if (is.na(d)) NA_integer_ else sum(a$n_children))
      hard(paste("percent_group", gr$id, key, sep = ":"), same(a$pct_group, pct(a$n_children, a$denominator_group)))
      eligible <- a$kind_a != "source_missing" & a$kind_b != "source_missing" &
        a$diagnostic %in% c("change_distribution", "change_crosstab")
      hard(paste("percent_nonmissing", gr$id, key, sep = ":"),
        same(a$pct_nonmissing, ifelse(eligible, pct(a$n_children, a$denominator_nonmissing), NA_real_)))
      # Independent direct denominator from released missingness, not sum of cells.
      nm <- if (is.na(d)) NA_integer_ else if (all(a$diagnostic == "change_crosstab"))
        sum(gr$use & !is.na(src[[a$field_a[1]]]) & !is.na(src[[a$field_b[1]]])) else
        sum(gr$use & !is.na(src[[a$field_a[1]]]))
      hard(paste("nonmissing_denominator", gr$id, key, sep = ":"), same(a$denominator_nonmissing, rep(nm, nrow(a))))
    }
    cross <- z[z$diagnostic == "change_crosstab", ]
    for (f in unique(z$field_a[z$diagnostic == "change_distribution"])) {
      marg <- z[z$diagnostic == "change_distribution" & z$field_a == f, ]
      for (j in seq_len(nrow(marg))) {
        use <- if (f == cross$field_a[1]) cross$category_a == marg$category_a[j] else cross$category_b == marg$category_a[j]
        hard(paste("crosstab_marginal", gr$id, f, j, sep = ":"),
          same(marg$n_children[j], if (gr$status == "unmapped") NA_integer_ else sum(cross$n_children[use])))
      }
    }
  }
  old_cross <- read_csv("output/tables/descriptive_context_crosstabs.csv")
  for (i in 1:2) {
    old <- old_cross[old_cross$pair_id == i, ]
    now <- diagnostics[diagnostics$group_id == paste0("g", i, ":all") & diagnostics$diagnostic == "change_crosstab", ]
    old_a <- ifelse(old$category_kind_a == "source_missing", "missing", sub("^\\(([0-9]+)\\).*$", "\\1", old$category_label_a))
    old_b <- ifelse(old$category_kind_b == "source_missing", "missing", sub("^\\(([0-9]+)\\).*$", "\\1", old$category_label_b))
    j <- match(paste(now$category_a, now$category_b), paste(old_a, old_b))
    hard(paste0("stage05_existing_cross:", i), !anyNA(j) && same(now$n_children, old$n_children[j]))
  }
  hard("dates_numeric_metadata_no_epoch", all(vapply(src[dates], function(x)
    is.numeric(x) && !inherits(x, "Date") && identical(names(attributes(x)), "value.labels"), logical(1))))
  for (f in dates) {
    k <- match(f, dates)
    hard(paste0("date_coverage:", f), sum(!is.na(src[[f]])) == c(828L, 801L, 821L, 807L)[k],
      c(828L, 801L, 821L, 807L)[k], sum(!is.na(src[[f]])))
    hard(paste0("date_finite_integer:", f), all(is.finite(src[[f]][!is.na(src[[f]])])) &&
      all(src[[f]][!is.na(src[[f]])] == trunc(src[[f]][!is.na(src[[f]])])))
  }
  hard("no_ordering_diagnostics", !any(grepl("ordering|before_assessment|after_assessment|same_day", diagnostics$diagnostic)) &&
    !any(grepl("assessment_date", names(diagnostics))))
  hard("unestablished_correspondence_not_zero_matches", all(is.na(diagnostics$n_children[diagnostics$diagnostic == "correspondence_status"])))
  hard("zero_denominator_fixture", all(is.na(pct(c(0, 1), c(0, 0)))))
  empty_groups <- groups[1]; empty_groups[[1]]$use[] <- FALSE
  fixture <- make_diagnostics(src, empty_groups, definitions)
  hard("empty_group_fixture", all(fixture$denominator_group == 0L) && all(is.na(fixture$pct_group)) &&
    all(is.na(fixture$pct_nonmissing)) && all(fixture$n_children[fixture$diagnostic != "correspondence_status"] == 0L))
  all_missing <- src; all_missing$T_CHNGCP[] <- NA; all_missing$T_CHNG[] <- NA
  fixture <- make_diagnostics(all_missing, groups[1], definitions)
  hard("all_missing_fixture", all(fixture$denominator_nonmissing[fixture$diagnostic != "correspondence_status"] == 0L) &&
    all(is.na(fixture$pct_nonmissing)))
  hard("unmapped_groups_undefined", all(is.na(diagnostics$n_children[diagnostics$group_status == "unmapped"])) &&
    all(is.na(diagnostics$denominator_group[diagnostics$group_status == "unmapped"])))
  tables <- list(evidence, fields, diagnostics)
  for (i in 1:3) {
    hard(paste0("aggregate_schema:", i), !any(c("STUDY_ID", "CASEID", "LEAD_1", "teacher_id", "child_id", "date_value") %in% names(tables[[i]])))
    write_csv(tables[[i]], file.path(outdir, basename(destinations[i])))
    hard(paste0("csv_readback:", i), check_csv(tables[[i]], file.path(outdir, basename(destinations[i]))))
  }
  report <- make_report(groups, diagnostics, evidence, head, branch, before)
  p <- file.path(outdir, basename(destinations[5])); con <- file(p, "wb")
  writeBin(charToRaw(enc2utf8(paste0(paste(report, collapse = "\n"), "\n"))), con); close(con)
  hard("report_readback", identical(readLines(p, encoding = "UTF-8", warn = FALSE), report))
  hard("protected_file_set", identical(paths_before, protected_paths()))
  after <- hashes(paths_before)
  for (f in paths_before) hard(paste0("preserved:", f), before[[f]] == after[[f]], before[[f]], after[[f]])
  for (i in seq_along(destinations)) hard(paste0("ignored:", destinations[i]), check_ignore()[i])
  hard("worker_checks_unique_all_pass", !anyDuplicated(checks$check_id) && all(checks$status == "pass"))
  write_csv(checks, file.path(outdir, basename(destinations[4])))
  stopifnot(check_csv(checks, file.path(outdir, basename(destinations[4]))))
  message("PASS worker: ", nrow(evidence), " evidence rows; ", nrow(fields), " fields; ", nrow(diagnostics),
    " diagnostics; ", nrow(checks), " checks; ", length(before), " protected fingerprints unchanged.")
}

make_report <- function(groups, diagnostics, evidence, head, branch, protected) {
  lines <- c("# Stage 09: Fall belief timing and Spring teacher correspondence", "",
    paste0("HEAD `", head, "`; branch `", branch, "`. Script MD5 `", unname(hashes(script_path)), "`."),
    "Evidence classes: documented fact, supported inference, possible analytical assumption, unresolved question. Seasonal administration is supported; individual ordering and Fall-respondent/Spring-teacher correspondence remain unestablished for both grades.", "",
    "## Pre-K", "",
    "The Fall Pre-K teacher form contains Modernity item 31 (questionnaire physical pp. 17,22); it asks general agreement, with no explicit retrospective interval. The guide's recruitment of lead teachers (p.13) describes the intended sample, not proof of the actual respondent in each child-attached composite. The form date question is on p.24, but no released Pre-K belief completion-date counterpart was identified. T_IDEAP's Fall interpretation is supported by the form, guide p.23 and unchanged native-Fall provenance. Belief onset and the start/duration of instruction remain unknown. [P_FORM; ROLE_CONTEXT; FALL_MAPPING]", "",
    "T_CHNGCP documents 972 no teacher/classroom change, 38 teacher changes and five classroom changes among all 1015 children. Guide p.15 explains the five same-site classroom moves and attempted Spring collection in the new room. T_CHNG instead reports 977/38/0. The two fields agree literally for 1007 children and disagree for eight. Neither the equal cells nor the five moves reconcile construction, missing-report treatment or respondent identity. Both stay separate; Q08 remains open. The release entries do not document a direct underlying question or exact date endpoints. [P_CHILD_CHANGE; P_CLASS_MOVES; P_TQ_CHANGE; P_CHANGE_UNRESOLVED; CHANGE_QUESTION_SEARCH]", "",
    "There are 987 observed Pre-K beliefs. Belief plus usable English Applied Problems Fall/Spring scores is 721 children. This is joint availability, not 721 validated exposures or independent teachers. A future grade-specific association involving the Fall report may be considered after resolving measurement and stating timing/correspondence assumptions. Spring-teacher exposure is not validated, including within the released no-change group.", "",
    "## Kindergarten", "",
    "Modernity appears in Fall 2002 teacher item 40 (questionnaire pp.29-30,33; guide p.26). General agreement has no explicit retrospective period. TQDATEKF is the relevant teacher-belief form completion field; TQDATEKS belongs to the Spring teacher form. TQSCDATEKF/KS are distinct questionnaires about the study child, not child assessment dates. [K_FORM; FIELD_TQDATEKF; FIELD_TQDATEKS; FIELD_TQSCDATEKF; FIELD_TQSCDATEKS]", "",
    "All-child numeric date coverage (denominator 1015) is TQDATEKF 828 present/187 NA; TQDATEKS 801/214; TQSCDATEKF 821/194; TQSCDATEKS 807/208. All present values are finite integers. The R attributes contain no date class or epoch, and the dictionary has numeric display formats rather than documented calendar decoding. These counts describe form-date availability only. Calendar conversion and marginal calendar summaries are withheld; no epoch is guessed from numeric ranges or school-year plausibility. Original -99/-6 reasons have collapsed to NA. [DCT_DS0001_TQDATEKF and corresponding date DCT/SETUP rows]", "",
    "Teacher change No/Yes/NA is 828/82/105; classroom change is 859/51/105. Conditional nonmissing denominators are 910 for each, separate from all-child 1015. 'During K year' does not establish endpoints relative to the belief report or assessments, identify the reporter, or authenticate that a no-change record concerns that Fall respondent. There are 840 observed Kindergarten beliefs and 756 with usable English Applied Problems pairs. No Spring exposure is assigned. [K_CHANGE]", "",
    "## Four distinct timing concepts", "",
    "1. Fall baseline assessment is a measurement occasion; it may already reflect instruction.",
    "2. Belief-questionnaire completion records a report; it does not establish belief onset or exposure onset.",
    "3. Spring assessment is the later outcome measurement occasion.",
    "4. Teaching exposure has its own teacher, start, duration, and possible changes; these are not recovered by questionnaire labels.", "",
    "The approved planning search covered all DS0001 dictionary declarations and the source-variable inventory, date/timing searches across all 1124 physical child-codebook pages, relevant entries/forms and targeted DS0002/DS0003 dictionaries. It identified no suitable released child-assessment calendar-date fields. This script rechecks the declarations/inventory and records an all-page codebook search index. This bounded absence is not a claim about uninspected or restricted materials. Assessment ages ASMTAGEPF/PS/KF/KS and AMSNTDAYP/K/ASMNTDAYPKK are definition-only: neither ages nor elapsed spacing anchors an assessment relative to form completion. No ordering statistics, paired-date denominators, synthetic missing child-assessment dates, or reconstructed dates are created. [ASSESSMENT_DATE_ABSENCE; DATE_SEARCH_DS0001; INVENTORY_SEARCH; FIELD_ASMTAGEPF and other age/spacing rows]", "",
    "If a separately reviewed extension later establishes comparable dates attached to the same child and relevant forms, the following interpretations could be considered conditional on measurement and respondent validity:", "",
    "| Completion timing | Possible interpretation and remaining assumption |",
    "|---|---|",
    "| Before Fall assessment | Recorded before both assessments; baseline adjustment may be considered, but Fall performance may already reflect instruction. Adjustment need not represent the total exposure-period association. |",
    "| Between Fall and Spring assessments | Fall baseline then belief report then Spring outcome can support consideration of a baseline-adjusted association. Later completion than Fall is not disqualifying; earlier exposure and performance-related belief reporting still matter. |",
    "| After Spring assessment | A descriptive association remains possible; treating the report as an earlier measure requires stability or retrospective-measurement assumptions. It is not a prospectively recorded belief measure. |",
    "| Unknown ordering (current endpoint) | Seasonal labels and marginal distributions cannot establish sequence. Any assumed sequence must be explicit. |", "",
    "Same-day dates cannot establish within-day order. A future extension would need parent populations, paired-date coverage/missing/unusable partitions and a separate complete-three-date denominator before any sequence classification.", "",
    "## Correspondence and linkage", "",
    "The forms contain teacher/classroom/child identifier slots (questionnaire pp.17,29,45,49,57,61); this is collection design, not a released merge map. STUDY_ID is the unique child key (child codebook p.6); classroom-file CASEID labels only a case identifier (both classroom codebooks p.6). DS0003 LEAD_1 is labeled Teacher ID (p.159), without documented uniqueness/scope; its published frequency distribution is not usable teacher identity evidence. Site fields identify sites or where teachers rated children, not validated teachers, classrooms, schools, or longitudinal respondent matches. No linkage instruction establishing the needed relationship was found in these entries, dictionaries/setup, guide passages, forms, prior issue register, or manifest. [SPRING_FORMS; CHILD_KEY; CLASSROOM_CASE_KEYS; PREK_CASE_KEY; LEAD_SCOPE; SITE_MEANINGS]", "",
    "Only released change indicators are available. Fall-respondent to Spring-teacher correspondence is unestablished in both grades; a supported subset cannot be identified from this bounded evidence. Correspondence counts in the diagnostics are undefined, not zero successful matches. No teacher count, cross-file merge, score/identifier-pattern matching, or new site-equality statistic is attempted. The manifest-listed six supplemental syntax files are absent locally; acquisition is outside this stage. [MISSING_DERIVATION_SYNTAX]", "",
    "## Support populations and aggregate interpretation", "",
    "Each grade includes all children, observed native Fall beliefs, and each outcome's belief-plus-complete usable pair, using unchanged Stage 07 eligibility and Stage 08 support. Instruments, languages and metrics remain separate. Unmapped pairs have undefined denominators/counts rather than zero support. Questionnaire-date coverage is tabulated for the Kindergarten groups only; the four fields are Kindergarten forms. Cross-grade Pre-K groups are not given Kindergarten form-date summaries. All documented change categories (including zero cells), released missing categories, full-group percentages and separate nonmissing denominators are retained. Tables do not select a final sample.", "",
    "| Grade | Outcome series | Belief plus complete pair | Status |",
    "|---|---|---:|---|")
  for (gr in groups) if (gr$kind == "belief_plus_complete_pair") lines <- c(lines,
    paste0("| ", gr$grade, " | ", gr$outcome, " (", gr$language, "; ", gr$metric, ") | ",
      if (gr$status == "unmapped") "Undefined" else sum(gr$use), " | ", gr$status, " |"))
  lines <- c(lines, "", "## Unresolved issue register and next-design consequences", "",
    "| Issue | Exact remaining question / evidence checked | Consequence and alternatives |",
    "|---|---|---|",
    "| Q01 measurement | What are the released scoring, reversal, completion, direction and cross-grade equivalence rules? Existing Stage 06 report, release entries, forms and guide p.40 checked; no new resolving evidence. | Preserve released values; grade-specific descriptive associations would still require interpretable within-grade measurement. Harmonization/direction claims remain blocked. |",
    "| S09_ORDER | Where are comparable individual assessment calendar dates and the Pre-K form completion counterpart? Closed declaration/inventory/codebook/form search found none suitable. Kindergarten numeric date epoch also unvalidated. | Individual sequence is unresolved. Seek separately reviewed date metadata/extension or state explicit timing/stability assumptions; do not substitute child-questionnaire dates or reconstruct from ages/spacing. |",
    "| Q08 Pre-K derivation | Why do T_CHNGCP and T_CHNG differ, and how were population/skips/missing reports handled? Child codebook pp.313-314,580, setup labels, guide p.15 and corresponding forms checked; supplemental syntax absent. | Keep both distinct. No preferred flag, teacher-change recode for code 2, or validated no-change subset. Explicit derivation could permit review of an indicator later. |",
    "| S09_K_ENDPOINTS | What reporters, interval endpoints, and actual teachers do TCHCHNGK/CLASSCHNGK refer to? Codebook pp.1115-1116, setup, forms and guide checked. | Describe No/Yes only. Assuming they validate the Fall respondent at Spring is an additional unsupported step. Obtain construction evidence or retain unresolved correspondence. |",
    "| Q05/Q06/Q07 and S09_CORRESPONDENCE | Which released key maps a child's Fall belief respondent to the Spring teacher, with what scope/coverage? Identifier entries, dictionaries/setup, printed form IDs and guide checked; LEAD_1/site labels provide no validated relationship. | No Spring exposure or independent-unit count. Obtain a documented mapping and coverage audit, or explicitly frame a later association around the child-attached Fall report with correspondence limitations. |",
    "| Participation coverage | CHPARTP/CHPARTK describe study participation, not outcome usability or respondent matching. Guide pp.14-17 and child codebook pp.305,1108-1109 checked. SCHLCHNGK is parent-reported school changes (item 19, p.93; codebook p.992), not teacher change. | Guide Fall/Spring Pre-K counts 940/960 differ from released CHPARTP-implied 939/959; retain released coverage and records without forcing agreement. No exclusions, inferred missing reasons, or school-to-teacher recodes. [RELEASE_PARTICIPATION; RELEASE_SCHOOL_CHANGE] |", "",
    "These are unresolved endpoints, not newly resolved conflicts. The two Pre-K change fields are distinct released measures; no release-specific instruction requires treating them as equivalent. No affected interpretation is forced, so no new user decision is needed to complete this bounded stage. No upstream issue register is edited.", "",
    "What the evidence permits next: consider separately specified, grade-specific descriptive questions relating a child's attached Fall belief report to Fall/Spring performance, or discuss a baseline-adjusted Spring association. A completion date after Fall assessment alone would not reject baseline adjustment. Such designs still require explicit measurement validity/direction, respondent correspondence, prior exposure and reporting/stability assumptions, along with selection/assignment, exposure-period and dependence/weighting questions. If correspondence later becomes supported only for a subset, report its coverage and population implications before choosing a sample. Current evidence cannot validate a Spring-teacher exposure design. No estimator, final sample, regression, clustering, weighting rule, causal interpretation, or belief transformation is chosen here.", "",
    "## Reproducibility, publication and preservation", "",
    "Exact invocation from the verified Git root:", "```powershell", "$env:LC_ALL = 'English_United States.utf8'",
    "& 'C:/Program Files/R/R-4.6.1/bin/Rscript.exe' --vanilla code/revision/09_investigate_belief_timing_correspondence.R", "```", "",
    "The parent launches two fresh Rscript --vanilla workers with --worker and separate temporary directories. Each extracts local PDFs with pdftotext -layout -enc UTF-8, checks source/wide/panel preservation, reconciles all Stage 08 support cells and category denominators, and writes exactly three tables, a worker-check CSV and this report. All five worker artifacts are byte-compared before publication. Temporary worker directories are removed. The final checks CSV adds actual parent/publication audits; it is intentionally different from the pre-publication worker-check file.", "",
    paste0("Protected paths: ", length(protected), " files, including the script plus all existing tracked files and files under Data/docs/code/output/paper. The preserved:* checks contain before/after MD5s. Source_evidence contains original source MD5s and exact normalized excerpt fingerprints/locators; excerpts are UTF-8 pdftotext -layout text with whitespace normalized. Primary pages are embedded except child/site identifier listings, for which only documentary headings are retained; field-specific setup/dictionary rows give exact lines. No child-level values/IDs are exported."),
    paste0("Runtime: ", R.version.string, "; locale: ", Sys.getlocale(), "."),
    "Publication is gated by git check-ignore for all five destinations, CSV exact read-back, byte reproduction, unchanged protected fingerprints and an unchanged working tree/index. Existing outputs are not rewritten. No staging, committing or pushing occurs.", "")
  # Keep this explanatory slice next to the support discussion. The full table
  # contains every outcome group and all zero/missing cross-cells.
  at <- match("## Unresolved issue register and next-design consequences", lines)
  continuity <- c("## Reported changes in selected availability groups", "",
    "The following counts are released reports within the stated support groups. A no-change report still does not validate the belief respondent as the Spring teacher. These groups are diagnostic populations, not selected estimation samples.", "",
    "| Grade / group | Field | Released category counts (including missing) | Denominator |",
    "|---|---|---|---:|")
  for (gr in groups) if (gr$kind %in% c("all_children", "belief_observed") ||
      gr$outcome == "applied_problems_english_standard_score") {
    z <- diagnostics[diagnostics$group_id == gr$id & diagnostics$diagnostic == "change_distribution", ]
    for (f in unique(z$field_a)) {
      a <- z[z$field_a == f, ]
      continuity <- c(continuity, paste0("| ", gr$grade, " / ", gr$kind,
        if (gr$kind == "belief_plus_complete_pair") " (English Applied Problems standard)" else "",
        " | ", f, " | ", paste(paste0(a$category_a, "=", a$n_children), collapse = "; "),
        " | ", a$denominator_group[1], " |"))
    }
  }
  c(lines[seq_len(at - 1L)], continuity, "", lines[at:length(lines)])
}

main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) && args[1] == "--worker") {
    stopifnot(length(args) == 2L, dir.exists(args[2])); run_stage(args[2]); return(invisible(NULL))
  }
  if (length(args)) stop("Unknown arguments.")
  protected <- protected_paths(); before <- hashes(protected)
  staging <- tempfile("stage09_"); dir.create(staging)
  on.exit(unlink(staging, recursive = TRUE), add = TRUE)
  dirs <- file.path(staging, c("run1", "run2")); invisible(lapply(dirs, dir.create))
  rscript <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
  for (i in 1:2) {
    log <- file.path(staging, paste0("run", i, ".log"))
    message("Worker ", i, " command: ", shQuote(rscript), " --vanilla ", shQuote(here::here(script_path)),
      " --worker ", shQuote(dirs[i]))
    status <- system2(rscript, c("--vanilla", shQuote(here::here(script_path)), "--worker", shQuote(dirs[i])), stdout = log, stderr = log)
    message(paste(readLines(log, warn = FALSE), collapse = "\n"))
    if (status != 0L) stop("Stage 09 worker ", i, " failed; no outputs published.")
  }
  a <- file.path(dirs[1], basename(destinations)); b <- file.path(dirs[2], basename(destinations))
  stopifnot(all(file.exists(a)), all(file.exists(b)), identical(unname(tools::md5sum(a)), unname(tools::md5sum(b))),
    identical(protected_paths(), protected), identical(hashes(protected), before))
  ck <- read.csv(a[4], colClasses = "character", na.strings = character(), fileEncoding = "UTF-8")
  add <- function(id, expected, observed, detail = "") {
    ck <<- rbind(ck, data.frame(check_id = id, severity = "hard", expected = expected, observed = observed, status = "pass", detail = detail))
  }
  add("fresh_process_all_five_bytes", "5 byte-identical worker artifacts", "5 byte-identical worker artifacts",
    "Two fresh Rscript --vanilla processes; three tables, worker checks and memo; no timestamp exclusions.")
  for (i in seq_along(destinations)) add(paste0("reproducible_worker_md5:", destinations[i]),
    unname(tools::md5sum(a[i])), unname(tools::md5sum(b[i])))
  add("parent_protected_before_publication", as.character(length(protected)), as.character(length(protected)))
  invisible(check_ignore()); add("parent_ignore_gate", "5 ignored destinations", "5 ignored destinations")
  diff <- system2("git", c("diff", "--check"), stdout = TRUE, stderr = TRUE)
  stopifnot(is.null(attr(diff, "status")))
  lines <- readLines(here::here(script_path), warn = FALSE)
  stopifnot(!any(grepl("[ \t]+$", lines)), !any(grepl("^(<<<<<<<|=======|>>>>>>>)", lines)))
  add("git_diff_and_untracked_script_whitespace", "clean", "clean")
  substantive <- c(1:3, 5)
  stopifnot(all(file.copy(a[substantive], here::here(destinations[substantive]), overwrite = TRUE)))
  stopifnot(identical(unname(tools::md5sum(a[substantive])), unname(tools::md5sum(here::here(destinations[substantive])))),
    identical(protected_paths(), protected), identical(hashes(protected), before), all(check_ignore()))
  add("post_publication_substantive_bytes", "4 exact published copies", "4 exact published copies")
  add("post_publication_protected_preservation", as.character(length(protected)), as.character(length(protected)))
  for (i in substantive) add(paste0("published_md5:", destinations[i]), unname(tools::md5sum(a[i])),
    unname(tools::md5sum(here::here(destinations[i]))))
  add("post_publication_index_clean", "clean", "clean")
  stopifnot(system2("git", c("diff", "--cached", "--quiet")) == 0L, system2("git", c("diff", "--quiet")) == 0L,
    !anyDuplicated(ck$check_id), all(ck$status == "pass"))
  write_csv(ck, a[4]); stopifnot(check_csv(ck, a[4]))
  stopifnot(file.copy(a[4], here::here(destinations[4]), overwrite = TRUE),
    identical(unname(tools::md5sum(a)), unname(tools::md5sum(here::here(destinations)))),
    identical(hashes(protected), before), all(check_ignore()))
  message("PASS: five ignored outputs published; ", nrow(ck), " passing checks; ", length(protected),
    " protected fingerprints unchanged; no staging, commit, or push.")
}
main()
