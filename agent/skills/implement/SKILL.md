---
name: implement
description: Implement an explicitly approved engineering plan in focused, reviewable slices and validate the result.
---

# Implement

Implement only after an explicit approved plan is present in the conversation.
If there is no approved plan, stop and request the analysis, plan, and approval
gate instead of editing.

Re-read the relevant code and make the smallest coherent change that satisfies
the approved scope. Preserve existing conventions and compatibility unless the
plan explicitly changes them. Do not add speculative abstractions, unrelated
cleanup, or durable documentation. If the code reveals a materially different
problem, stop and return the evidence for re-planning.

Use a fresh, bounded worker context by default when the harness supports it.
Give a worker one coherent vertical slice, the exact relevant paths, acceptance
criteria, constraints, and validation command. Keep writes sequential in one
working tree; use parallel workers only for disjoint isolated worktrees or
read-only investigation.

After each meaningful slice, run the narrowest useful checks, then run the
plan’s broader validation before handoff. Do not run `reload`, install
dependencies, migrate data, deploy, or alter external configuration unless the
user explicitly requests it.

Handoff with:

- what changed and how it maps to the approved plan;
- files or symbols touched;
- validation run and results;
- known limitations, risks, or follow-up questions.
- a concise, imperative suggested commit message based on the current diff;
  treat it as provisional if review changes the implementation and refresh it
  from the complete resulting diff.

The next phase is an independent `/review`; implementation is not complete
until review and verification pass.
