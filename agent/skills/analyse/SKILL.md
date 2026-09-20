---
name: analyse
description: Investigate a requested engineering change and produce an evidence-based read-only analysis.
---

# Analyse

Investigate before proposing implementation. This phase is read-only: do not
edit the target repository, create project documentation, or make external
changes.

Start from the user’s objective and locate the smallest useful slice of the
repository. Begin with one inventory or status check, then inspect the
entrypoint, primary orchestration path, and directly relevant boundaries.
Record evidence with paths and symbols rather than dumping unrelated files.
Read callers, configuration, and tests only when they answer a specific
uncertainty. Do not read every path returned by Glob or perform an exhaustive
repository audit by default. State what was not inspected and expand scope only
when the user explicitly asks for it or the evidence requires it.

Use workers only when the harness actually provides them and a focused split is
useful. Give each worker one narrow question and only the relevant paths; ask
for a concise evidence-based conclusion.

Return a compact analysis containing:

- objective, scope, and non-goals as currently understood;
- current behavior and relevant files, symbols, and boundaries;
- constraints, dependencies, risks, and unknowns;
- architectural fit and seams that should be preserved or introduced;
- viable options, including the smallest option and its trade-offs;
- recommended direction and what the plan must validate.

Do not write an implementation plan in place of analysis, and do not treat an
unverified assumption as a repository fact. If the request is an architecture
overview rather than a change investigation, prioritize components and data
flow over exhaustive change-readiness review.
