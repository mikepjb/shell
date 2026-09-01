---
name: review
description: Perform a strict independent review of an implementation for correctness, architecture fit, and maintainability.
---

# Review

Review the implementation independently against both the approved plan and
the repository’s existing architecture. Do not modify files while reviewing.
Use a fresh, bounded worker context by default when the harness supports it;
the reviewer must be able to disagree with the implementer.

Inspect the actual diff and surrounding code. Check at least:

- requested behavior, acceptance criteria, and accidental scope changes;
- architecture fit, seams, coupling, data/control flow, and compatibility;
- edge cases, errors, partial failure, security, and operational behavior;
- tests at stable behavior or integration boundaries and missing regression
  coverage for likely bugs;
- readability, concept/interface/class count, unnecessary abstraction, and
  consistency with local conventions.

Report findings with severity, exact location, issue, impact, and a concrete
fix. Every concrete actionable issue blocks approval, including a minor issue
that could make the change wrong, fragile, or harder to maintain. Do not block
on unsupported personal taste; tie standards findings to the repository,
approved plan, or explicit working agreement. Do not propose unrelated
refactors.

Return `APPROVED` only when there are no concrete findings and the validation
evidence is credible. Otherwise return `CHANGES REQUIRED`, ordered by impact.
After fixes, review the complete resulting diff again rather than assuming a
local fix is sufficient. If two or three focused implementation/review cycles
do not converge, recommend a re-plan with the new evidence.
