# Stage 1 unresolved documentation issues

This record accompanies `docs/stage1_variable_crosswalk.csv`. It separates documentary uncertainty from empirical checks in `output/tables/crosswalk_validation.csv`. No issue below authorizes a transformation, dataset linkage, sample restriction, or model choice.

## Q01 - Released construction of `T_IDEAP` and `T_IDEAK`

- **Human-review status:** Reviewed. The documentary scale conflict is confirmed; review does not authorize a transformation.
- **Exact question:** How were the two released Modernity variables scored, and is dividing `T_IDEAP` by 16 the formally correct way to place it on the same scale as `T_IDEAK`?
- **Sources checked:** DS0001 codebook pp. 538 and 788; DS0002 codebook p. 57; DS0001 Stata dictionary and setup file; DS0001 questionnaire p. 22 (Fall Pre-K item 31) and p. 33 (Fall Kindergarten item 40); study user guide pp. 23, 26, and 40; manifest.
- **Established documentation:** Both questionnaires contain the same 16 Likert items. The user guide says scores are means, non-traditional beliefs are reverse-scored, and higher values indicate more progressive beliefs. `T_IDEAP` is from the Fall Pre-K teacher questionnaire and `T_IDEAK` is from the Fall Kindergarten teacher questionnaire.
- **Released-dataset location:** `T_IDEAK` occurs in both DS0001 and DS0002. The DS0001 copy is the relevant child-level variable for this reconstruction.
- **Conflict:** The released child file stores `T_IDEAP` on a sum-like scale but `T_IDEAK` on a mean-like scale. The older guide's Kindergarten summary is also sum-like, despite the released Kindergarten variable being mean-like. No available release-specific source explicitly authorizes `T_IDEAP / 16`.
- **Why it matters:** An undocumented rescaling would determine the magnitude and interpretation of the teacher-belief measure and its change across grades.
- **Blocked later step:** `T_IDEAP / 16`, harmonization, construction of any generic teacher-belief column, spring carry-forward or grade assignment, and the Fall Pre-K-to-Fall Kindergarten variation audit.
- **Alternatives after resolution:** (a) apply an explicitly documented release transformation; (b) retain the two released scales separately; or (c) omit cross-grade change analyses if comparability cannot be established.
- **Evidence that could resolve it:** The manifest-listed DS0001 supplemental derivation syntax or another release-specific source that explicitly states the released scoring transformation.

### Required timing distinction for later work

If harmonization is approved later, the panel design must keep distinct fields for `teacher_idea_observed`, `teacher_idea_grade_assigned`, `teacher_idea_source_period`, and `teacher_idea_carried_forward`. `T_IDEAP` is directly observed in Fall Pre-K and `T_IDEAK` in Fall Kindergarten. A value placed on a spring row would be a carry-forward or grade assignment, not a contemporaneous spring teacher-belief measurement. The later diagnostic must therefore be described as **Fall Pre-K to Fall Kindergarten teacher-belief variation**. This distinction matters because documented teacher/classroom-change indicators can show that the spring teacher differs from the fall respondent.

## Q02 - Meaning of `ASMSTATPS` code `8 = DR`

- **Exact question:** What does the Spring Pre-K assessment-status label `DR` mean?
- **Sources checked:** DS0001 codebook p. 80, Stata setup lines 210-216, questionnaire, and study user guide.
- **Conflicting or incomplete evidence:** Release-specific sources consistently label code 8 only as `DR`; no expansion or definition was found.
- **Why it matters:** Interpreting the code could affect assessment-language and missingness classifications.
- **Blocked later step:** Any recode that assigns code 8 to an absence, refusal, language, or completion category.
- **Alternatives after resolution:** Retain `DR` as its own category, or apply a documented expansion if one is found.
- **Evidence that could resolve it:** Release-specific field documentation, supplemental syntax, or a study instrument note defining `DR`.

## Q03 - Theoretical valid-score bounds for PPVT and Applied Problems

- **Exact question:** What are the release-supported theoretical valid-score limits for the PPVT and Woodcock-Johnson III Applied Problems standard scores?
- **Sources checked:** DS0001 codebook pages for all four waves, Stata setup, study user guide pp. 48, 54, and 56, and questionnaires.
- **Conflicting or incomplete evidence:** The codebook reports empirical distributions and identifies standard-score types, but no explicit theoretical lower and upper bounds were found. Empirical minima and maxima are not documentary authorization.
- **Why it matters:** Range checks in cleaning should not silently classify legitimate scores as invalid.
- **Blocked later step:** Hard valid-range recodes beyond documented special-value handling.
- **Alternatives after resolution:** Use documented instrument bounds if supplied, or retain all non-special released values without imposing theoretical bounds.
- **Evidence that could resolve it:** Release scoring documentation or instrument documentation explicitly incorporated into the study release.

## Q04 - Missing-reason provenance collapsed in the `.rda`

- **Exact question:** Can the original distinctions among system missing, item missing, and no response/not applicable be recovered for values already stored as `NA` in the released R objects?
- **Sources checked:** DS0001-DS0003 Stata setup files and released `.rda` objects.
- **Conflicting or incomplete evidence:** Setup files document source codes such as `-99`, `-6`, and `-5`, but the R objects have already collapsed most of them to `NA`. Eight Applied Problems `-7` values survive because the setup did not recode them.
- **Why it matters:** Missing-reason flags cannot be reconstructed honestly from `NA` alone.
- **Blocked later step:** Retrospective missing-reason classification for already collapsed values.
- **Alternatives after resolution:** Continue with undifferentiated `NA`, or obtain a raw export that preserves original codes.
- **Evidence that could resolve it:** A release format retaining original special codes, such as the manifest-listed fixed-width or Stata source files.

## Q05 - Linkage of child and classroom-level datasets

- **Exact question:** Is there a documented key linking DS0001 child records to DS0002 Kindergarten classroom records or DS0003 Pre-K classroom records?
- **Sources checked:** All three codebooks, Stata dictionaries and setup files, user guide, manifest, and available study documentation.
- **Conflicting or incomplete evidence:** DS0001 documents `STUDY_ID` as the unique child identifier. DS0002 and DS0003 document `CASEID` only as a case identifier. No cross-dataset key or relationship was found.
- **Why it matters:** Matching on undocumented numeric patterns could create incorrect child/classroom assignments.
- **Blocked later step:** Any DS0001-to-DS0002 or DS0001-to-DS0003 merge.
- **Alternatives after resolution:** Link only with an explicit documented key; otherwise keep the datasets separate.
- **Evidence that could resolve it:** Release-specific linkage documentation or syntax defining the relationship.

## Q06 - Scope and usability of `LEAD_1`

- **Exact question:** Does `LEAD_1` identify unique teachers, and over what population or period is it unique?
- **Sources checked:** DS0003 codebook p. 159, Stata dictionary line 122, Stata setup, questionnaire, and user guide.
- **Conflicting or incomplete evidence:** The documentary label is only `Teacher ID`; no uniqueness or scope statement was found. The released DS0003 file has 245 rows, 244 nonmissing `LEAD_1` observations, and three distinct nonmissing values (50, 52, and 58). The earlier claim of only three nonmissing values was incorrect. These empirical facts cannot substitute for missing documentation.
- **Why it matters:** Treating it as a unique teacher key could seriously misstate teacher counts and nesting.
- **Blocked later step:** Unique-teacher counts, children-per-teacher calculations, or clustering based on `LEAD_1`.
- **Alternatives after resolution:** Use it only if scope and uniqueness are documented, or report that a usable teacher identifier is unavailable.
- **Evidence that could resolve it:** Release-specific identifier documentation or construction syntax.

## Q07 - Interpretation of `SITE_*` fields for nesting

- **Exact question:** Can any wave-specific site variable support classroom, school, state, or teacher nesting beyond its documented site meaning?
- **Sources checked:** DS0001 codebook pp. 315, 317, 319, 1116, 1118, and 1119; Stata dictionary and setup; user guide.
- **Conflicting or incomplete evidence:** Release sources explicitly call these fields site IDs or sites where teachers rated children. They do not establish unique teacher, classroom, school, or state identifiers. `SITE_WT` is a sampling weight and is not an identifier.
- **Why it matters:** Incorrect relabeling would invalidate counts and any later inference design based on nesting.
- **Blocked later step:** Teacher/classroom/school/state counts and any clustering choice that relies on those interpretations.
- **Alternatives after resolution:** Count documented sites only, or use a newly documented identifier at its supported level.
- **Evidence that could resolve it:** Release-specific site-code documentation describing hierarchical scope and stability across waves.

## Q08 - Relationship between `T_CHNGCP` and `T_CHNG`

- **Human-review status:** Reviewed. The indicators are related but distinct; exact derivation and reconciliation remain unresolved.
- **Exact question:** How does the child-level `T_CHNGCP` construction differ from the teacher-questionnaire `T_CHNG`, including their treatment of classroom changes and missing reports?
- **Sources checked:** DS0001 codebook pp. 313 and 580; DS0003 codebook; DS0001 and DS0003 Stata dictionaries and setup files; questionnaire; and user guide.
- **Released-dataset location:** `T_CHNG` occurs in both DS0001 and DS0003. The DS0001 copy is directly relevant to comparison with child-level `T_CHNGCP`.
- **Conflicting or incomplete evidence:** Both use categories for no change, teacher change, and classroom change, but one is explicitly based on child-level data and the other comes from the teacher questionnaire. No available derivation explains discrepancies.
- **Why it matters:** Selecting one without understanding construction could misclassify exposure to a different teacher.
- **Blocked later step:** A preferred or reconciled Pre-K change flag. Code `2 = classroom change` must not be treated as proof of teacher change without separate documentation.
- **Alternatives after resolution:** Report both separately, prioritize an explicitly documented derivation, or construct a reconciled flag only if authorized.
- **Evidence that could resolve it:** DS0001 supplemental derivation syntax or another release-specific construction note.

## Q09 - English/Spanish assessment mapping and comparability

- **Human-review status:** Reviewed. The conservative implementation rule is confirmed; the Kindergarten Spanish-battery English-PPVT mapping remains unresolved.
- **Exact question:** Which released field implements the guide's statement that Kindergarten Spanish-battery children received a separate English PPVT, and are any English and Spanish scores intended to be combined?
- **Sources checked:** DS0001 codebook and setup entries for PPVT, TVIP, and Woodcock-Muñoz fields; user guide pp. 25, 27, 48, 54, and 56; assessment-status variables.
- **Conflicting or incomplete evidence:** The guide distinguishes English and Spanish batteries and notes a separate English PPVT in Kindergarten. It does not identify a cross-language conversion, equating, harmonization, or imputation rule. The exact public-release field for the separately described Kindergarten English PPVT among Spanish-battery children has not been identified, so ordinary `PPVTEKF` and `PPVTEKS` must not be assumed to contain those scores.
- **Assessment-status correction:** `ASMSTATPF` code `4 = Non-English, Spanish-Speaking Child Failed Pre-LAS` has 6 observations. Code 4 was zero only in the later waves checked, not in every wave.
- **Why it matters:** Combining batteries without a documented rule would change outcome definitions and could conflate distinct instruments and score metrics.
- **Blocked later step:** Any cross-language pooling, equating, conversion, combined outcome, or imputation from another battery.
- **Alternatives after resolution:** Keep batteries separate, or apply only an explicitly documented release harmonization.
- **Evidence that could resolve it:** Release-specific scoring or variable-mapping documentation.

## Review boundary

Human review is recorded for Q01, Q08, and Q09, but all transformations marked `blocked` or `proposed_not_approved` remain unauthorized. Review confirms conservative implementation restrictions; it does not approve a transformation. This tranche does not recode special values, harmonize teacher beliefs, carry values into spring periods, build a cleaned wide file or long panel, link datasets, define an estimation sample, run Stage 2 diagnostics, or estimate regressions.
