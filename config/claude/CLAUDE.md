# Claude Instructions

## Mandatory Workflow

For ANY non-trivial task (more than a one-line fix), you MUST follow this sequence:

```
ANALYZE → PLAN → [await approval] → IMPLEMENT → REVIEW
```

**This is not optional.** Do not skip steps. Do not combine steps.

### Step 1: Analyze
Use the `analyze` skill. Gather context: find relevant files, trace data flow, understand existing patterns. Output a context summary with file:line references.

### Step 2: Plan
Use the `plan` skill. Propose specific changes with exact file paths and line numbers.

**STOP and explicitly ask**: "Approve this plan to proceed?"

Do NOT proceed until user says yes.

### Step 3: Implement
Only after explicit approval, spawn the `implement` subagent. Pass:
- The approved plan
- Key file:line references from analyze
- Any constraints from user

### Step 4: Review
Use the `review` skill on implementation output. If issues found, iterate with implement until resolved.

## Why Subagent for Implement

- Analyze/Plan/Review run in main context (fast, retains history)
- Implement runs isolated (heavy tool use, doesn't pollute main context)
- Resume implement agent with its ID when iterating

## Web Service Development

When working on web services, pay attention to:

### API Design
- Consistent URL structure: `/api/v1/resources/:id`
- Correct HTTP methods and status codes (201 for create, 204 for delete, etc.)
- Clear error responses with error codes
- Pagination from the start for list endpoints

### Database
- Parameterized queries only (never string concatenation)
- Transactions for multi-step operations
- Check for N+1 queries
- Reversible migrations

### Debugging
When investigating issues:
1. Reproduce first - understand how to trigger it
2. Gather evidence - logs, errors, stack traces
3. Trace the flow - follow the request path
4. Check the obvious - config, connectivity, permissions
5. Look at recent changes - prime suspects

## Principles

- **Minimal changes**: Only what's necessary for the task
- **Match existing patterns**: Follow codebase conventions
- **No over-engineering**: Don't add abstractions for hypothetical futures
- **Security by default**: Validate inputs, escape outputs, parameterize queries
