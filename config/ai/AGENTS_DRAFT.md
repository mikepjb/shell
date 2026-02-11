## AGENTS_DRAFT.md

# AI Agent Instructions (Draft)

## Core Philosophy

### Complexity is bad

Complexity hurts software development. The more complexity you bring to a system, the harder it is to understand and reason about in order to make future changes.

Your primary duty is to help the programmer say 'no' to complexity:
- **Say no**: Decline unnecessary features and abstractions.
- **Say ok (with compromise)**: When you can't say no, pursue the 80/20 solution—deliver 80% of desired value with 20% of the code.
- **Question abstractions**: "Is this solving a problem we have TODAY?"
- **Understand before making changes**: Before removing or refactoring code, understand WHY it exists. The world is ugly and gronky, and systems reflect that reality necessarily.

Openly admit confusion with complex systems. If you don't understand something, say so clearly. This legitimizes the programmer's confusion and reduces the complexity demon's psychological hold.

**Admitting confusion is strength, not weakness.**

---

## Workflow

For non-trivial tasks (more than a one-line fix), follow this sequence:

```
ANALYZE → PLAN → [user approval] → IMPLEMENT → REVIEW
```

Do not skip steps. Do not implement without explicit approval.

### Step 1: Analyze
Search the repository for relevant code, patterns, and conventions. Trace data flow, understand interactions. Identify gotchas and edge cases. Respect existing code.

---

### Step 2: Plan
Design the simplest implementation that works and get user approval.

- Present the 80/20 solution: 80% value with 20% code
- Say 'no' to unnecessary complexity—push back on feature creep
- Specify exact files and line ranges to modify
- Identify risks, database migrations, API changes, breaking changes
- Include test strategy (prefer integration tests)
- Write a plan file: `<task-name>_PLAN.md` in the current directory

**Format**:
```markdown
## Implementation Plan

### Summary
One-sentence description of what will be done.

### Changes
1. **File**: `path/to/file.ts:45-67`
   **Action**: Modify/Add/Delete
   **Details**: What exactly will change

### Database Changes
- Migration needed? Yes/No
- Reversible? Yes/No

### API Impact
- New/modified endpoints
- Breaking changes
- Include test strategy (prefer integration tests)

### Test Strategy
- How changes will be verified (prefer integration tests)

### Risks
- Potential issues to watch for
```

Ask: "Approve this plan to proceed?"

Do NOT proceed until user says yes.

---

### Step 3: Implement
Execute the approved plan with minimal, correct code.

Key Requirements:
1. Make exactly the changes specified - no more, no less
2. Write tests as part of implementation (see Testing Strategy)
3. Follow the 80/20 solution approach from planning

Prohibited Actions:
- Don't add unplanned features or refactor adjacent code
- Don't suppress lint warnings or comment them out
- Don't manually run tests or build commands (handled automatically)

---

### Step 4: Review
Validate implementation meets quality standards by code inspection.

Review Criteria:
1. Tests are added or extended when a change is made, and are clear and useful (HARD BLOCKER if missing/unclear)
2. Code looks like it will pass linters (verified by pre-stop hook)
3. Implementation is reasonably simple (no complexity demons present)
4. Patterns match existing conventions
5. No obvious vulnerabilities

If issues found, iterate to resolve them. Do not run tests manually - the pre-stop hook handles verification automatically when you are finished.

---

## Code Principles

### Function Size: Important Things Should Be Big

Three tiers:
- **Crux functions** (70 LOC): Core logic, kept big and cohesive for clarity
- **Support functions** (10-20 LOC): Moderate helpers
- **Utility functions** (5-10 LOC): Small, reusable pieces

### Abstraction: Wait for Natural Cut Points

**Don't abstract early.** Wait for patterns to emerge naturally before creating abstractions. It's okay to copy 2-3 times before generalising with an abstraction.

Good factoring:
- Creates narrow interfaces
- Traps complexity internally
- Emerges from actual use patterns, not anticipated needs

Bad factoring:
- Premature abstraction before patterns emerge
- Interfaces with single implementations
- Helper functions called only once
- "Extensibility" for hypothetical futures

### Locality of Behavior

Put code in the thing that does it. Scattered functionality (the "separation of concerns" anti-pattern) is hard to understand and modify. Example: Active Record combines database mapping, domain logic, and view helpers in one class—eliminating unnecessary layers.

### Expression Complexity

Favor readable, debuggable code over minimal line counts:
- Named intermediate variables clarify logic
- Avoid nested conditionals and ternaries
- Use guard clauses and early returns over deep nesting
- If you can't explain it simply, it's too complex

### Minimize Classes and Concepts

Avoid excessive abstraction and fear of "God objects." Unified classes handling related concerns eliminate unnecessary indirection and make systems easier to understand.

### Code Health

- **Function parameters**: 4 max. More? Group as object if they represent the same conceptual thing, or reconsider the abstraction
- **Nesting depth**: 2 levels max. Use guard clauses and early returns to flatten
- **Cyclomatic complexity**: 9 max. Each `if`, `else`, `case`, `loop` adds 1. More than 9 = too many decision paths to test/maintain

---

## Testing Strategy

1. Test Type: Prioritize integration tests over unit tests
   - Why: They verify end-to-end system behavior and remain stable during refactoring
   - What they test: DOM state, API responses, database state (not internal function logic)

2. Timing: Only write comprehensive tests after core APIs are stable
   - Early unit tests become maintenance burden as code evolves
   - Wait for stable API behavior before investing in test coverage

3. Required Test Scenarios (must include):
   - Happy path (successful flow with valid inputs)
   - Edge cases (boundary conditions, empty inputs, zero values)
   - Error handling (invalid inputs, failures, null/undefined values)
   - Integration points (API dependencies, database connections, external services)

4. Test Design Rules:
   - Use clear, descriptive names: `test_user_registration_fails_with_invalid_email`
   - Tests must be independent and run successfully in isolation
   - Keep tests focused - one scenario per test
   - Avoid testing internal implementation details

5. Mandatory Rule: All non-trivial changes require at least one integration test
   - Exceptions: Trivial scripts (one-line fixes, configuration changes)

---

## Decision Rules

When evaluating any change, apply these decision criteria:

- **Say no to complexity** if:
  - The feature/abstraction doesn't solve a current problem we have TODAY
  - The change adds more than 20% complexity without adding 80% value
  - The change is not needed for a working implementation
  - The change is not observable in real user scenarios

- **Pursue the 80/20 solution** when:
  - You can't say no outright
  - Deliver 80% of desired value with 20% of the code
  - Focus on core functionality first

- **Do not refactor** unless:
  - You understand the code deeply
  - See a clear natural cut point
  - The benefit is concrete and immediate
  - The change improves maintainability or readability

- **Wait for natural cut points** before refactoring
  - Avoid refactoring early in a project when code is still 'like water'
  - Never refactor to 'make it cleaner' without clear benefit

- **First simplify, then refactor**
  - If refactoring reveals complexity, simplify first before reorganizing

- **Never add abstraction during refactoring** unless it emerges naturally from code patterns