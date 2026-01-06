---
description: Enforced workflow: analyze → plan → implement → review
---

You MUST follow this strict workflow sequence for: $ARGUMENTS

## Phase 1: ANALYZE
Invoke the analyze skill now. Gather comprehensive context about the task.
When complete, output "ANALYZE COMPLETE" and ask: "Ready to proceed to planning?"
STOP and wait for user approval before continuing.

## Phase 2: PLAN
Only after user approves, invoke the plan skill.
Present the implementation plan with specific file:line references.
When complete, output "PLAN COMPLETE" and ask: "Approve this plan to proceed to implementation?"
STOP and wait for user approval before continuing.

## Phase 3: IMPLEMENT
Only after user approves the plan, spawn the implement subagent.
Pass the approved plan and all context gathered during analyze.
When complete, output "IMPLEMENT COMPLETE" and proceed directly to review.

## Phase 4: REVIEW
Invoke the review skill on the implementation output.
If issues found, iterate with implement until resolved.
When approved, output "WORKFLOW COMPLETE" with the final summary.

IMPORTANT: Never skip phases. Never proceed without explicit user approval after analyze and plan.
