---
name: task
description: Orchestrate an approval-gated engineering task from analysis through implementation, strict review, and verification.
---

# Task

Use this workflow for a code-change request. Keep the coordinator’s context
small and use fresh, bounded workers for phases when the harness supports it.
Pass focused handoffs containing the objective, relevant paths, constraints,
acceptance criteria, and required output; synthesize concise results rather
than copying whole investigations into the parent context.

Run this lifecycle:

1. **Analyse** — investigate the current behavior and architecture read-only.
2. **Plan** — propose the smallest coherent approach, files, validation, risks,
   and decisions.
3. **Approval gate** — show the plan and wait for explicit user approval. No
   target-code changes or other side effects happen before approval.
4. **Implement** — execute the approved plan in focused sequential slices.
5. **Review** — independently inspect the complete diff against the plan and
   architecture.
6. **Fix and re-review** — send concrete findings back through implementation,
   then review the complete diff again. Allow roughly two or three cycles;
   recommend a re-plan when the work is not converging.
7. **Verify** — run the agreed checks and report the result, remaining risks,
   and exact scope.

Do not skip analysis, planning, approval, or strict review because the change
looks small; compress the evidence and plan instead. If the user invokes
`/grill-me`, complete that explicit interview before analysis or planning. If a
material assumption, scope, or architectural direction changes, return to the
appropriate phase and obtain approval for the revised plan.

Do not create tickets, ADRs, project plans, or durable documentation unless
explicitly requested. Do not run `reload`, install dependencies, migrate,
deploy, or change external systems unless explicitly requested. Do not run
parallel writers against the same working tree unless they are isolated.

Use clear status markers in the conversation: `ANALYSIS`, `PLAN`, `WAITING FOR
APPROVAL`, `IMPLEMENTATION`, `REVIEW`, `VERIFICATION`, and `DONE`.
