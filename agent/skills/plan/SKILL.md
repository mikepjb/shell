---
name: plan
description: Turn an analysed engineering change into a precise, approval-ready implementation plan without modifying the repository.
---

# Plan

Produce an implementation plan from the request and available analysis. This
phase is read-only. If the analysis is missing important repository evidence,
perform the smallest additional read-only investigation or state the gap; do
not pretend the plan is certain.

Prefer a small, direct change that fits existing boundaries. Make the plan
concrete enough that another engineer or worker can execute it without
rediscovering the design. Include:

- objective, non-goals, and acceptance criteria;
- chosen approach and why it fits the current architecture;
- ordered implementation steps naming files, symbols, seams, or data flows;
- tests and other validation, including failure and compatibility cases;
- risks, rollback or migration considerations, and observability needs;
- delegation boundaries and dependencies between steps;
- decisions or assumptions that require the user’s confirmation.

Do not create tickets, ADRs, project plans, or other durable documents. Present
the plan in the conversation and clearly mark the approval gate. No
implementation may begin until the user explicitly approves this plan. If the
user changes the objective or a material assumption, revise the plan before
any code is changed.
