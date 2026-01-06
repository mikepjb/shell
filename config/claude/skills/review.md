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

### Security
- No hardcoded secrets, credentials, or API keys
- Proper input validation at system boundaries
- Outputs are properly encoded/escaped for context (HTML, SQL, shell, etc.)

### Tests
- All tests passing?
- New code has appropriate coverage?
- No skipped or disabled tests?

### Style
- Matches existing codebase patterns?
- No unnecessary complexity?
- Clean, readable code?

## Security Review (OWASP-Informed)

### Injection
- [ ] SQL: Parameterized queries only, no string concatenation
- [ ] Command: No user input in shell commands; if unavoidable, strict allowlist
- [ ] LDAP/NoSQL/XPath: Inputs escaped for target interpreter
- [ ] Template: Server-side templates don't evaluate user input

### Authentication & Session
- [ ] Passwords hashed with bcrypt/argon2 (not MD5/SHA1)
- [ ] Session tokens are random, long, and httpOnly
- [ ] Logout actually invalidates session server-side
- [ ] Failed logins don't reveal if user exists
- [ ] MFA flows can't be bypassed

### Authorization
- [ ] Every endpoint checks permissions (not just UI hiding)
- [ ] No IDOR: Users can't access others' data by changing IDs
- [ ] Privilege escalation: Can't grant yourself higher roles
- [ ] Default deny: New resources are private by default

### XSS & Output Encoding
- [ ] User content HTML-escaped before rendering
- [ ] JSON responses use proper Content-Type
- [ ] CSP headers in place for web apps
- [ ] No `dangerouslySetInnerHTML` or `innerHTML` with user data

### CSRF & Request Forgery
- [ ] State-changing operations require CSRF tokens
- [ ] SSRF: URLs from users validated against allowlist
- [ ] Webhooks verify signatures/origins

### Cryptography
- [ ] Using well-known libraries, not custom crypto
- [ ] Secrets in env vars or secret manager, not code
- [ ] TLS for all external communications
- [ ] Timing-safe comparison for secrets/tokens

### Data Exposure
- [ ] API responses don't leak extra fields (use explicit serialization)
- [ ] Errors don't expose stack traces, SQL, or internal paths
- [ ] Logs redact PII, passwords, tokens
- [ ] No sensitive data in URLs (appears in logs/referer)

### Output Validation
- [ ] API responses validated against schema before sending
- [ ] Redirects only to allowlisted domains/paths
- [ ] Generated URLs validated (no open redirect)
- [ ] File downloads have correct Content-Type and Content-Disposition
- [ ] Emails/notifications don't reflect user input unsanitized

### Rate Limiting & DoS
- [ ] Public endpoints have rate limits
- [ ] File uploads have size limits
- [ ] Regex patterns aren't vulnerable to ReDoS
- [ ] Pagination prevents unbounded queries

### Dependencies
- [ ] No known vulnerable dependencies (check npm audit, cargo audit, etc.)
- [ ] Lock files committed
- [ ] Dependencies from trusted sources only

## Operational Concerns

### Database
- [ ] Queries efficient (no N+1, indexes exist)
- [ ] Transactions used where needed
- [ ] Migrations are reversible
- [ ] No data loss scenarios

### Observability (Wide Events)
Prefer one context-rich log event per request per service over scattered log lines.

- [ ] Single structured event per request with all context (user, request_id, duration, status, etc.)
- [ ] Include timing breakdowns (db_ms, external_api_ms, total_ms)
- [ ] Capture request metadata (endpoint, method, params, user_agent)
- [ ] Include business context (order_id, customer_tier, feature_flags)
- [ ] No sensitive data logged (redact tokens, passwords, PII)
- [ ] Errors include full context for debugging without log correlation

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
