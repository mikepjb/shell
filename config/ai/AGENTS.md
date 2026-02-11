# AI Agent Instructions

## Core Philosophy

### Complexity is bad

Complexity hurts software development. The more complexity you
bring to a system, the harder it is to understand and reason
about in order to make future changes.

Your primary duty is to help the programmer say "no" to complexity:
- **Say no**: Decline unnecessary features and abstractions.
- **Say ok (with compromise)**: When you can't say no, pursue the 80/20 solution—deliver 80% of desired value with 20% of the code.
- **Question abstractions**: "Is this solving a problem we have TODAY?"
- **Understand before making changes**: Before removing or refactoring code, understand WHY it exists. The world is ugly and gronky, and systems reflect that reality necessarily.

Openly admit confusion with complex systems. If you don't understand something, say so clearly. This legitimizes the programmer's confusion and allows open discussion to solve the problem at hand.

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
- Say "no" to unnecessary complexity—push back on feature creep
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
1. Tests are added or extended when a change is made, and are
   clear and useful (HARD BLOCKER if missing/unclear)
2. Code looks like it will pass linters (verified by pre-stop hook)
3. Implementation is reasonably simple (no complexity demons present)
4. Patterns match existing conventions
5. No obvious vulnerabilities

If issues found, iterate to resolve them. Do not run tests
manually - the pre-stop hook handles verification automatically
when you are finished.

---

## Code Principles

### Function Size: Important Things Should Be Big

Three tiers:
- **Crux functions** (70 LOC): Core logic, kept big and cohesive for clarity
- **Support functions** (10-20 LOC): Moderate helpers
- **Utility functions** (5-10 LOC): Small, reusable pieces

### Abstraction: Wait for Natural Cut Points

**Don't abstract early.** Wait for patterns to emerge naturally
before creating abstractions. It's okay to copy 2-3 times before
generalising with an abstraction.

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

## Web Service Development

### API Design

- Consistent URL structure: `/api/v1/resources/:id`
- Use correct HTTP methods and status codes (e.g., 201 for create, 204 for delete)
- Clear error responses with error codes
- Pagination from the start for list endpoints
- Design for simple use cases first — add complex capabilities secondarily
- Put operations on the objects they affect

### Database
- Use parameterized queries only (never string concatenation)
- Use transactions for multi-step operations
- Check for N+1 queries
- Reversible migrations

### Security
- Validate inputs at API boundary
- Escape outputs (HTML, SQL, shell commands)
- Do not leak internal details in error responses
- Log errors with context but redact sensitive data (passwords, tokens, PII)

### Debugging
1. **Reproduce first** — understand how to trigger it  
2. **Gather evidence** — logs, errors, stack traces  
3. **Trace the flow** — follow the request path  
4. **Check the obvious** — config, connectivity, permissions  
5. **Look at recent changes** — prime suspects

---

## UI Development

### Core Principles

- **Function over form**: Every element earns its place by doing something useful  
- **Obvious affordances**: Users should never guess what's clickable or how things work  
- **Information density**: Show what matters, hide what doesn’t, waste no space  
- **Locality of behavior**: Put code on the thing that does it (HTML with behavior attributes)  
- **Consistency**: Same patterns everywhere, no surprises  
- **Speed**: Fast to load, fast to understand, fast to use  

### Technology Stack
- **Semantic HTML** first — use correct elements (`<nav>`, `<main>`, `<aside>`, `<form>`, `<article>`)  
- **HTMX** for server-driven UI updates — keeps behavior with elements  
- **Alpine.js** for reactive components when needed (minimal client state)  
- **Vanilla JS** for simple interactions  
- **Plain CSS** — no frameworks, no utility classes (unless project already uses them)  

### Anti-Patterns to Avoid
- Icons without labels  
- Hamburger menus when space exists  
- Modals for simple actions  
- Animations that delay interaction  
- Custom styled form controls that break accessibility  
- Separation of concerns (HTML/CSS/JS in different files for same component)  

### Data Display
- **Tables for data** — don’t fight this  
- Align numbers right, text left  
- Zebra striping or borders for row separation  
- Sortable columns where useful

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

## Refactoring

**Large refactors frequently fail. Keep changes small.** Before removing code, understand WHY it exists (Chesterton's Fence). Code that looks stupid might be handling an ugly edge case.

**Rules**:
- Refactor in tiny, working increments
- Keep the system working after each step
- Don't add abstraction during refactoring unless it emerges naturally
- If refactoring reveals complexity demons, simplify first, then refactor
- Wait for natural "cut points" to become obvious

**When to Refactor**: When you understand the code deeply, see the natural cut point clearly, and the benefit is concrete and immediate.

**When NOT to Refactor**: To make code "cleaner" without clear benefit, to match another project's pattern, because it "feels wrong," or early in a project when code is still "like water."

---

## On Saying No

**Saying "no" to complexity is your most powerful weapon**, but it can harm career advancement. Balance pragmatism with workplace reality:

- Push back on feature creep: "Is this necessary for the task at hand?"
- Question premature optimization: "Can we wait until we measure the actual bottleneck?"
- Resist over-decomposition: "Does splitting this make it easier to understand?"
- Challenge unnecessary abstractions: "Are we solving a problem we have TODAY?"

When you can't say no outright, pursue the 80/20 solution and deliver most value with minimal code.

---

## Language & Framework Guidance

### Java
**Anti-pattern**: Isolated data holder classes (DTO packages, standalone model files). Data lives where it's used. Embed inner classes next to the logic consuming them—follow Go/Clojure thinking.

```java
// Better: inner class with TransferService, not its own file
public class TransferService {
  public static class Request {
    BigDecimal amount;
    String fromAccount, toAccount;
  }
  public void transfer(Request req) { /* ... */ }
}
```

**Modern Java Patterns (Java 16+):**
- Use records instead of data classes: `public record Request(BigDecimal amount, String fromAccount, String toAccount) {}`
- Prefer inner classes for data structures local to one service
- Use sealed interfaces for fixed type hierarchies: `sealed interface Result permits Success, Failure {}`
- Static factory methods over constructors: `PaymentMethod.card("visa")` instead of `new PaymentMethod(...)`
- Local records for temporary data structures within methods
- Avoid excessive abstraction - 3 similar lines beat a complex pattern

Split only when multiple unrelated consumers and semantic boundaries are clear.

### CSS
**Rule**: Never inline styles. All styling lives in separate CSS files. Styles are the source of truth; keep them organized and discoverable, not hidden in markup.

```html
<!-- Bad -->
<div style="color: blue; margin: 16px;">Alert</div>

<!-- Good -->
<div class="alert">Alert</div>
<!-- styles.css: .alert { color: blue; margin: 16px; } -->
```

## Creating commits

When commiting agents are always required to credit themselves as a co-author with:

`Co-authored-by: Qwen <noreply@qwen.ai>` (for Qwen models only)
