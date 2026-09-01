---
name: longplan
description: Analyse a large multi-step engineering change and produce a phased, low-disruption plan without implementing it.
---

# Long plan

This is a planning-only workflow. Investigate the repository read-only and
return the plan in the conversation. Do not implement, create tickets, write
ADRs, generate durable project plans, or make external changes.

Use bounded fresh workers for independent discovery when supported. Map the
current system, ownership, dependencies, stable interfaces, data flows,
operational constraints, and likely seams. Separate repository facts from
assumptions. Consider the smallest viable outcome and alternatives before
committing to a broad redesign.

Design phases that are independently reviewable and useful, with each phase
small enough to execute as an approved `/task`. For every phase specify:

- purpose, bounded scope, non-goals, and expected user or system value;
- dependencies, affected areas, ownership, and safe parallelism;
- compatibility strategy, migration steps, validation, observability, and
  rollback or cleanup;
- risks, decisions for the human, and the evidence needed before the next
  phase.

Minimize disruption. Prefer additive seams, compatibility boundaries, and
incremental migration where they reduce risk. Evaluate a Strangler Fig
approach when an existing capability can be surrounded and replaced gradually:
route a small slice, compare behavior, migrate more, then remove the old path
only when evidence supports it. Do not force that pattern when a direct small
change, a stable interface, or a one-time migration is simpler and safer.

End with the recommended phase order, cross-phase risks, explicit open
decisions, and a ready-to-use prompt for the next `/task`. If discovery shows
that a later phase needs a different architecture, say where the plan should
be revisited rather than inventing detail now.
