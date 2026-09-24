# Project Instructions

## Repository Safety

- Before making any changes, run `git rev-parse --show-toplevel` and verify that the working directory is the correct project root. Do not proceed if the path is incorrect.
- Run `git status --short --branch` before making changes.
- Inspect existing uncommitted changes before modifying any affected file.
- Never discard, reset, restore, or overwrite existing user changes unless explicitly instructed.
- Make minimal, reversible edits.
- Stage only files relevant to the current task.
- Make atomic git commits.
- Always verify outputs after changes.
- If verification fails, debug the exact failing command with minimal edits.
- When fixing errors, address one root cause at a time and rerun after each fix.
- Do not claim verification unless you report the exact command run and its result.

## Branch and GitHub Policy

- Do not assume the current branch is `main`.
- Never push a feature/task branch directly to `main`.
- Before committing, run `git status --short --branch`.
- After completing and verifying a task, commit only the relevant changes.
- Push the current branch using `git push` if an upstream already exists.
- If the branch has no upstream, use `git push -u origin HEAD`.
- Do not merge into `main`, rebase shared branches, force-push, or delete branches unless explicitly instructed.
- After pushing, run `git status --short --branch`.
- Do not claim the task is complete unless the commit succeeds and any requested push succeeds.

## Data Safety

- Never modify files in raw-data directories.
- Do not commit raw, restricted, proprietary, or large research datasets.
- Do not commit processed/intermediate datasets unless explicitly instructed.
- `docs/icpsr/` contains ICPSR documentation/codebooks and should not be treated as research data.
- Before adding anything under `Data/`, inspect the files and determine whether they are documentation or research data.
- Never expose secrets, credentials, tokens, or private keys.
- Respect `.gitignore`.

## Paths and Project Structure

- Use `here::here()` for R paths.
- Use relative paths rather than machine-specific absolute paths.
- Keep raw data, processed data, code, outputs, and paper files logically separated.
- Do not introduce a new directory structure without first explaining why it is needed.
- Generated tables, figures, and reports should be reproducible from code.

## Legacy Analysis

- `code/analysis/data.Rmd` is an archival record of the earlier ECON 4261 analysis.
- Do not rewrite, reorganize, or "clean up" `code/analysis/data.Rmd` unless explicitly instructed.
- Do not use the legacy file as the primary implementation for the revised paper.
- Build the revised analysis in new modular files.
- Preserve the ability to inspect the old analysis for comparison.

## Econometric and Research Rules

- Do not choose, remove, or prefer specifications based on statistical significance.
- Report null and near-null results honestly.
- Do not use causal language unless the research design explicitly supports causal identification.
- Do not infer variable definitions from variable names alone.
- Verify substantive variable definitions against the supplied dataset documentation/codebooks.
- If documentation is ambiguous, stop and report the ambiguity rather than guessing.
- Record observation counts after important filters and sample restrictions.
- Do not silently drop observations.
- Within each outcome, nested specifications must use the same estimation sample unless explicitly instructed otherwise.
- Do not add redundant fixed effects or controls.
- Do not select a standard-error clustering level without first examining the child/teacher/classroom/site structure.
- Apply the chosen inference procedure consistently across comparable specifications.
- Keep data construction, estimation, diagnostics, and presentation code separate where practical.

## Current Revision Strategy

The revised paper should initially investigate the following specification sequence for each outcome:

1. Bivariate pooled association.
2. Pooled regression with observed controls.
3. Add assessment-period fixed effects.
4. Child + assessment-period fixed effects.

The primary purpose is to examine how the teacher-attitude coefficient changes as increasingly demanding controls for heterogeneity are introduced.

The first implementation phase should focus on data reconstruction and diagnostics before finalizing the inference strategy.

Important diagnostics include:

- within-child variation in teacher attitude between Pre-K and Kindergarten;
- number of unique children, teachers, classrooms, schools/sites, and states where identifiable;
- children per teacher/classroom;
- teacher changes across grades;
- missingness by variable and wave;
- balanced versus unbalanced panel counts;
- sample attrition under alternative restrictions;
- availability and validity of teacher/classroom/site identifiers.

Do not implement the old median-split Difference-in-Differences exercise as part of the revised core analysis.

Treat the CCNES-based Modernity measure as a possible secondary robustness exercise, not as part of the core model unless explicitly instructed.

## Coding and Reproducibility

- Prefer modular scripts over one large analysis document.
- Cleaning code must not depend on manually edited intermediate data.
- Tables and figures must be generated programmatically.
- Do not manually enter regression coefficients into the paper.
- The analysis should run from a fresh R session.
- Add assertions/checks for important assumptions where practical.
- Keep machine-readable regression results available for later tables and plots.

## Reporting Requirements

After each completed implementation task, report:

- exact commands run;
- files created or changed;
- important design decisions made;
- verification commands and results;
- any unresolved warnings or ambiguities;
- commit hash, if a commit was made;
- whether the push succeeded, if a push was requested;
- final `git status --short --branch`.
