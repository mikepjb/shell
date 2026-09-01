---
name: analyse
description: Investigate a requested engineering change and produce an evidence-based read-only analysis.
---

# Analyse

Investigate before proposing implementation. This phase is read-only: do not
edit the target repository, create project documentation, or make external
changes.

Start from the user’s objective and locate the smallest useful slice of the
repository. Inspect existing behavior, adjacent tests, configuration, naming,
callers, and the architecture that the change must fit. Record evidence with
paths and symbols rather than dumping unrelated files. Identify constraints,
unknowns, likely failure modes, compatibility concerns, and the simplest
plausible approaches.

When the harness supports workers, use bounded fresh contexts by default for
independent questions such as current behavior, architecture fit, and test or
operational risk. Give each worker a narrow question and relevant paths; ask
for a concise evidence-based conclusion. Synthesize the results yourself and
call out disagreements or missing evidence.

Return a compact analysis containing:

- objective, scope, and non-goals as currently understood;
- current behavior and relevant files, symbols, and boundaries;
- constraints, dependencies, risks, and unknowns;
- architectural fit and seams that should be preserved or introduced;
- viable options, including the smallest option and its trade-offs;
- recommended direction and what the plan must validate.

Do not write an implementation plan in place of analysis, and do not treat an
unverified assumption as a repository fact. The next phase is `/plan`.
