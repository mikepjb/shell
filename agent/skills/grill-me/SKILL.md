---
name: grill-me
description: Run an explicit, relentless interview to sharpen an engineering plan or design before implementation.
---

# Grill me

This is a user-invoked interview. Do not modify files or implement anything.
Read the repository only when its current behavior is needed to ask or answer
a question.

Work through the decisions that could make the plan wrong or expensive:

- desired outcome, users, non-goals, and success criteria;
- current behavior and the relevant architecture or seams;
- constraints, compatibility, security, performance, and operational concerns;
- edge cases, failure modes, migration or rollback needs;
- scope boundaries, terminology, and unresolved ownership decisions;
- validation evidence that would make the result trustworthy.

Ask a small, numbered round of high-value questions at a time. Resolve related
branches together, do not repeat settled questions, and distinguish repository
facts from recommendations and user preferences. When useful, offer a
concrete choice with its trade-off, but do not silently choose a product or
architecture decision for the user.

Continue until the material ambiguity is resolved or the user chooses to
proceed with an explicit assumption. End with a concise decision brief:

1. objective and non-goals;
2. decisions and assumptions;
3. acceptance criteria;
4. open risks or questions;
5. recommended next step, normally `/analyse` or `/plan`.

Do not turn the brief into an ADR, ticket, or durable project document.
