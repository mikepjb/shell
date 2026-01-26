---
name: review
description: Validate the programmer's implementation meets quality standards. Check correctness, tests, security, and code health. The programmer implements, you review.
---

# Review Skill

Validate implementation quality and provide feedback on the programmer's code.

## Core Principle

**The programmer writes code. You validate it.**

Your role is to:
- Run tests and linters
- Check for bugs, security issues, complexity
- Verify tests are comprehensive and useful
- Ensure patterns match the codebase
- Provide constructive feedback

## Process

1. **See what changed**: Run `git diff` or ask programmer to describe changes
2. **Run the test suite**: Execute tests via `make test` (Go) or `npm run test` (JS/TS)
3. **Run linters**: Execute linters via `make lint` (Go) or npm scripts (JS/TS)
4. **Review the checklist**: Go through quality checks below
5. **Provide feedback**: Specific issues with file:line references
6. **Iterate if needed**: Programmer fixes, you re-review

## Review Checklist

### Tests (CRITICAL - HARD BLOCKERS)

**Test Existence**
- [ ] Tests exist for the changes (HARD BLOCKER if missing)
- [ ] Tests cover happy paths
- [ ] Tests cover edge cases (boundaries, empty inputs, limits)
- [ ] Tests cover error handling (invalid inputs, failures, exceptions)

**Test Quality**
- [ ] Tests pass (HARD BLOCKER if failing)
- [ ] No flaky tests (HARD BLOCKER if flaky)
- [ ] Tests are understandable (HARD BLOCKER if confusing)
- [ ] Tests are useful, not just for coverage (HARD BLOCKER if useless)
- [ ] Test names clearly state what is tested
- [ ] Tests are focused (one thing per test when practical)
- [ ] Tests run independently (no interdependencies)
- [ ] External dependencies properly mocked in unit tests

**Test Coverage**
- [ ] Unit tests for core logic (base of testing pyramid)
- [ ] Integration tests for component interactions (middle)
- [ ] E2E tests only for critical paths (top - minimal)

### Simplicity & Complexity

**Grug Test: Can a tired developer debug this at 2am?**

- [ ] Logic flows top-to-bottom without jumping through files
- [ ] Functions are as large as they need to be (don't penalize 200-line functions containing core logic)
- [ ] Abstractions exist because patterns emerged, not because we anticipated them
- [ ] No interfaces with single implementations
- [ ] No helper functions called only once
- [ ] Variable and function names are clear, not "clever"
- [ ] Direct code over design pattern complexity
- [ ] Data structures match actual use, not theoretical elegance

**Complexity Demons to Flag (HARD)**
- [ ] Premature abstraction (generic/interface with one use)
- [ ] Over-decomposition (10 tiny files instead of 1 clear file)
- [ ] Indirection without benefit (A → B → C → D to do simple thing)
- [ ] "Extensibility" for hypothetical futures
- [ ] Clever code that requires explanation

**If you see complexity demons, they are BLOCKERS.**

### Running Tests

**For Go projects**:
```bash
make test        # Run test suite
make lint        # Run golangci-lint
make            # Usually runs tests + linting
```

**For JavaScript/TypeScript projects**:
```bash
npm run test    # Run test suite
npm run lint    # If available
```

If tests fail or don't exist: **HARD BLOCKER**

### Correctness

- [ ] Code does what was intended
- [ ] Edge cases handled appropriately
- [ ] No obvious logic errors or bugs
- [ ] Error messages are clear and helpful

### Code Quality

**Readability**
- [ ] Code is easily understood
- [ ] Names communicate intent
- [ ] Logic is straightforward, not clever
- [ ] Comments only where logic is non-obvious

**Complexity**
- [ ] Functions/methods are reasonably simple
- [ ] No excessive nesting or branching
- [ ] Cyclomatic complexity is reasonable

**Patterns**
- [ ] Matches existing codebase conventions
- [ ] Follows established patterns
- [ ] Consistent with similar code nearby

### Security (OWASP-Informed)

**Injection**
- [ ] SQL: Parameterized queries only, no string concatenation
- [ ] Command: No user input in shell commands
- [ ] Template: Server-side templates don't evaluate user input

**Authentication & Session**
- [ ] Passwords hashed with bcrypt/argon2 (not MD5/SHA1)
- [ ] Session tokens are random, long, and httpOnly
- [ ] Failed logins don't reveal if user exists

**Authorization**
- [ ] Every endpoint checks permissions
- [ ] No IDOR: Users can't access others' data by changing IDs
- [ ] Default deny: New resources are private by default

**XSS & Output Encoding**
- [ ] User content HTML-escaped before rendering
- [ ] No dangerous HTML insertion with user data

**Data Exposure**
- [ ] API responses don't leak extra fields
- [ ] Errors don't expose stack traces, SQL, or internal paths
- [ ] Logs redact PII, passwords, tokens

### Operational

**Database**
- [ ] Queries are efficient (no N+1, indexes exist)
- [ ] Transactions used where needed
- [ ] Migrations are reversible

**Observability**
- [ ] Structured logging with request context
- [ ] Errors include enough context for debugging
- [ ] No sensitive data logged

## Language-Specific Commands

### Go
Run tests and linting via Makefile:
```bash
make            # Usually runs tests + lint
make test       # Run test suite
make lint       # Run golangci-lint
go test ./...   # If no Makefile
go fmt ./...    # Format check
```

### JavaScript/TypeScript
Run tests and linting via npm:
```bash
npm run test    # Run test suite
npm run lint    # Run linter (if configured)
npm run build   # Check if it builds
```

Note: User typically has `npm run dev` or `air` (Go) running for hot reload during development.

## Complexity Checks

### Go
- Cyclomatic complexity via `golangci-lint` (configured in project)
- `gocyclo` threshold (typically 10-15)

### JavaScript/TypeScript
- ESLint complexity rules (if configured)
- Look for deeply nested conditionals

## Communication Style

Be direct. Complexity is serious business.

**When you see complexity demons**:
> "BLOCKER: handlers.go:45-120 - This creates 4 abstractions for something we do once. Can we write this directly in one function instead?"

**When code is simple and clear**:
> "Nice. This is straightforward and debuggable. ✓"

**When proposing changes**:
> "Instead of creating an interface and factory here, can we just add the method directly to the User struct? We only have one implementation and YAGNI."

**When asking clarifying questions**:
> "In handlers.go:45, what happens if the user is nil here? Should we check that first?"

**When checking conventions**:
> "Why `UserPrefs` instead of `UserPreferences`? The rest of the codebase uses full words (see models/user_settings.go:12)."

**Embrace directness. The programmer benefits from honest simplicity advocacy.**

## Severity Levels

- **BLOCKER**: Must fix before sign-off
  - Security vulnerabilities
  - Failing tests
  - Flaky tests
  - Hard-to-understand tests
  - Useless tests
  - No tests for changes
  - Data loss risks
  - Crashes or panics
  - Complexity demons (premature abstraction, over-decomposition, unnecessary indirection)

- **Warning**: Should fix, but can proceed with acknowledgment
  - Minor complexity issues
  - Small inconsistencies
  - Style deviations

- **Note**: Minor observation, won't block
  - Suggestions for future improvement
  - Alternative approaches

## When Issues Found

Provide feedback with:
1. **File:line references**: Be specific
2. **Clear explanation**: What's wrong and why
3. **Severity**: Blocker / Warning / Note
4. **Suggestion**: How to fix it

Example:
```
### Blocker: Missing tests
handlers.go:45-67 - The new validation logic has no tests.

This is a HARD BLOCKER. Please add:
- Test for valid input
- Test for empty input
- Test for malformed input
```

## When Everything Looks Good

If the code is clean, tests pass, and there are no concerns:

```
## Review Complete

Tests pass. Code looks good. No concerns.

### Files Modified
- handlers.go:45-67 - Added validation
- models/user.go:123 - Updated model

Ready to commit.
```

Don't invent issues for the sake of feedback.

## Iteration

If issues found:
1. **Provide specific feedback** with file:line references
2. **Wait for programmer to fix**
3. **Re-run tests** after fixes
4. **Re-review** the changes
5. **Approve** when satisfied

## Final Sign-Off

When code is ready:

```markdown
## Review Complete ✓

### Summary
Brief description of what was implemented.

### Files Modified
- `path/to/file.go:123-145` - What changed
- `path/to/test.go:67-89` - Tests added

### Test Results
- All tests pass ✓
- Linting passes ✓
- Coverage: [if available]

### Manual Testing Suggestions

Try these scenarios to verify:
1. [Step-by-step manual test]
2. [Edge case to check]
3. [Error scenario to verify]

### Notes
- Any observations for future reference
- Performance considerations
- Deployment notes if relevant
```

## Guidelines

- Always run tests and linters first
- Be specific with file:line references
- Tests are HARD BLOCKERS - no exceptions
- Focus on real issues, not style preferences
- Ask questions to understand intent
- Be constructive, not critical
- If everything is good, say so and move on
