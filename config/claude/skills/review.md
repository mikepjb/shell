---
name: review
description: Validate implementation changes before completion. Checks correctness, security, code health, and strategic concerns. Iterates with implement until satisfied.
---

# Review Skill

Validate implementation quality, strategic decisions, and provide sign-off.

## Process

1. Run `git diff` to see what changed
2. Check the review checklist below
3. If issues found, return to implement with specific feedback
4. When approved, output final summary

## Review Checklist

### Correctness
- Does the code do what the plan specified?
- Are edge cases handled?
- No obvious bugs or logic errors?

### Strategic Concerns (from Overseer)

**Naming**
- Does this name communicate intent?
- Is it consistent with similar things in the codebase?
- Will this make sense in 6 months?

**Boundaries**
- Is this code in the right place?
- Is there coupling that will hurt later?
- Are responsibilities clear?

**Patterns**
- Is this duplicating something that exists?
- Is this the third time a pattern appears (time to abstract)?
- Is this an unnecessary abstraction (YAGNI)?

**Future Pain**
- Will this decision make the next feature harder?
- Is there hidden complexity being introduced?
- Are there edge cases being ignored that will bite later?

### Security (OWASP-Informed)

**Injection**
- [ ] SQL: Parameterized queries only, no string concatenation
- [ ] Command: No user input in shell commands; if unavoidable, strict allowlist
- [ ] Template: Server-side templates don't evaluate user input

**Authentication & Session**
- [ ] Passwords hashed with bcrypt/argon2 (not MD5/SHA1)
- [ ] Session tokens are random, long, and httpOnly
- [ ] Failed logins don't reveal if user exists

**Authorization**
- [ ] Every endpoint checks permissions (not just UI hiding)
- [ ] No IDOR: Users can't access others' data by changing IDs
- [ ] Default deny: New resources are private by default

**XSS & Output Encoding**
- [ ] User content HTML-escaped before rendering
- [ ] No `dangerouslySetInnerHTML` or `innerHTML` with user data

**Data Exposure**
- [ ] API responses don't leak extra fields
- [ ] Errors don't expose stack traces, SQL, or internal paths
- [ ] Logs redact PII, passwords, tokens

### Operational

**Database**
- [ ] Queries efficient (no N+1, indexes exist)
- [ ] Transactions used where needed
- [ ] Migrations are reversible

**Observability**
- [ ] Structured logging with request context
- [ ] Errors include enough context for debugging
- [ ] No sensitive data logged

## Communication Style

Prefer questions over commands. Instead of:
> "You should rename this to X"

Say:
> "Why `UserPrefs` instead of `UserPreferences`? The rest of the codebase uses full words."

Be minimal. Don't write essays. Short observations, specific questions.

## Severity Levels

- **Blocker**: Must fix before sign-off (security, data loss, crashes)
- **Warning**: Should fix, but can proceed with acknowledgment
- **Note**: Minor observation, won't block

## Customer Impact Awareness

Be pragmatic, not pedantic:
- Defensive defaults are OK: "Out of Stock" for undefined stock_level is good UX
- Graceful degradation: Customer-facing UI should fail gracefully
- Only raise issues that would actually harm users or cause confusion

## Iteration with Implement

If issues found:
1. List specific issues with file:line references
2. Categorize by severity
3. Return to implement for fixes
4. Re-review after fixes

## When Everything Looks Good

If the changes look fine - clean naming, good structure, no red flags - just say:

```
Looks good. No concerns.
```

Don't invent feedback for the sake of it.

## Final Output

When approved:

```markdown
## Review Complete

### Summary
Brief description of what was implemented.

### Files Modified
- `path/to/file.ts` - What changed

### Manual Testing

#### Steps
1. Step-by-step instructions to verify
2. Expected behavior at each step

#### Edge Cases to Verify
- List edge cases to check

### Notes
- Any observations for future reference
```
