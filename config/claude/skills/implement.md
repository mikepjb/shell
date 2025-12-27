---
name: implement
description: Execute approved implementation plans. Use this skill to write code, make changes, and ensure tests pass. For UI work, also use the frontend-design skill. Automatically passes to review when complete.
---

# Implement Skill

Execute the approved plan with minimal, correct code.

## Process

1. **Follow the plan**: Make exactly the changes specified
2. **Match patterns**: Follow existing codebase conventions
3. **Run tests**: Execute the full test suite
4. **Fix failures**: Address any broken tests before completing
5. **Pass to review**: Hand off for validation

## For UI Work

When the implementation involves frontend/UI changes:
- Use the `frontend-design` skill for visual quality
- Avoid generic aesthetics
- Match existing design patterns in the codebase

## Web Service Consistency

### API Responses
- Match existing response envelope format
- Use consistent error response structure
- Return appropriate HTTP status codes:
  - `200` success with body
  - `201` created
  - `204` success no content
  - `400` bad request (validation)
  - `401` unauthorized
  - `403` forbidden
  - `404` not found
  - `409` conflict
  - `500` internal error

### Error Handling
- Use existing error classes/types
- Don't leak internal details in responses
- Log errors with appropriate context
- Include request IDs for tracing

### Database
- Use transactions for multi-step operations
- Follow existing query patterns (ORM vs raw)
- Add appropriate indexes for new queries
- Handle connection errors gracefully

### Validation
- Validate at API boundary
- Use existing validation patterns/libraries
- Return clear validation error messages

### Logging & Observability
- Log at appropriate levels (info, warn, error)
- Include correlation IDs
- Don't log sensitive data (passwords, tokens)

## Guidelines

### Do
- Make minimal, focused changes
- Match existing code style exactly
- Run tests after every significant change
- Include the line numbers being modified
- Fix any failing tests (even unrelated ones)

### Don't
- Over-engineer or add unnecessary abstractions
- Add comments unless logic is non-obvious
- Refactor code outside the plan scope
- Skip tests or leave them failing
- Add features not in the approved plan

## Handoff to Review

When implementation is complete, provide:
- List of files modified with brief description
- Test results (all must pass)
- Any deviations from the plan and why

## Iteration

If review identifies issues:
- Address feedback promptly
- Re-run tests after fixes
- Re-submit to review
- Continue until review approves
