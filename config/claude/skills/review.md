---
name: review
description: Validate implementation changes before completion. Use this skill to check code quality, test coverage, and provide sign-off. Iterates with implement until satisfied. Outputs final summary with manual testing instructions.
---

# Review Skill

Validate implementation quality and provide sign-off.

## Review Checklist

### Correctness
- Does the code do what the plan specified?
- Are edge cases handled?
- No obvious bugs or logic errors?

### Safety
- No security vulnerabilities (injection, XSS, etc.)
- No hardcoded secrets or credentials
- Proper input validation at boundaries

### Tests
- All tests passing?
- New code has appropriate coverage?
- No skipped or disabled tests?

### Style
- Matches existing codebase patterns?
- No unnecessary complexity?
- Clean, readable code?

## Web Service Security & Ops

### API Security
- [ ] New endpoints have appropriate auth
- [ ] Authorization checks in place (who can access what)
- [ ] Input validation on all user data
- [ ] Rate limiting considered for public endpoints
- [ ] No SQL injection vulnerabilities (parameterized queries)
- [ ] No sensitive data in URL parameters

### Error Handling
- [ ] Errors don't leak internal details (stack traces, SQL)
- [ ] Consistent error response format
- [ ] Appropriate HTTP status codes
- [ ] Errors are logged with context

### Database
- [ ] Queries are efficient (check for N+1, missing indexes)
- [ ] Transactions used where needed
- [ ] Migrations are reversible
- [ ] No data loss scenarios

### Observability
- [ ] Key operations are logged
- [ ] Logs include correlation/request IDs
- [ ] No sensitive data logged
- [ ] Metrics/monitoring considered

## Customer Impact Awareness

Be pragmatic, not pedantic:
- **Defensive defaults are OK**: "Out of Stock" for undefined stock_level is good UX
- **Graceful degradation**: Customer-facing UI should fail gracefully
- **Context matters**: Internal APIs need strict correctness; UI needs user-friendly behavior
- Only raise issues that would actually harm users or cause confusion

## Severity Levels

- **Blocker**: Must fix before sign-off (security, data loss, crashes)
- **Warning**: Should fix, but can proceed with acknowledgment
- **Note**: Minor observation, won't block

## Iteration with Implement

If issues found:
1. List specific issues with file:line references
2. Categorize by severity
3. Return to implement for fixes
4. Re-review after fixes

## Final Output

When approved, provide:

```markdown
## Review Complete

### Changes Summary
- Brief description of what was implemented

### Files Modified
- `path/to/file.ts` - What changed

### API Changes
- New/modified endpoints with methods

### Database Changes
- Migrations applied
- Schema changes

### Test Coverage
- Which tests cover this change
- Test suite status: PASSING

### Manual Testing

#### Prerequisites
- Environment setup needed

#### Steps
1. Step-by-step instructions to verify the feature
2. Expected behavior at each step

#### API Testing (if applicable)
```bash
curl -X POST http://localhost:3000/api/endpoint \
  -H "Content-Type: application/json" \
  -d '{"example": "payload"}'
```

#### Edge Cases to Verify
- List edge cases to check

### Notes
- Any observations for future reference
```
