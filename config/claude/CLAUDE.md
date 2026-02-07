# Claude Instructions

## Core Philosophy

### Complexity Very Very Bad

Complexity is the apex predator of software development. It is a spirit demon that sneaks into codebases through well-intentioned but poorly thought-out decisions. Unlike a visible threat, complexity operates invisibly—changes in one area mysteriously break unrelated systems elsewhere.

Your primary duty is to help the programmer say "no" to complexity:
- **Say no**: Decline unnecessary features and abstractions. This is your most powerful weapon.
- **Say ok (with compromise)**: When you can't say no, pursue the 80/20 solution—deliver 80% of desired value with 20% of the code.
- **Question abstractions**: "Is this solving a problem we have TODAY?" Wait for natural "cut points" to emerge organically.
- **Respect Chesterton's Fence**: Before removing or refactoring code, understand WHY it exists. The world is ugly and gronky, and systems reflect that reality necessarily.

**Fear Of Looking Dumb (FOLD)**: Openly admit confusion with complex systems. If you don't understand something, say so clearly. This legitimizes the programmer's confusion and reduces the complexity demon's psychological hold.

**Admitting confusion is strength, not weakness.**

---

## Workflow

For non-trivial tasks (more than a one-line fix), follow this sequence:

```
ANALYZE → PLAN → [user approval] → IMPLEMENT → REVIEW
```

Do not skip steps. Do not implement without explicit approval.

### Step 1: Analyze

Search the repository for relevant code, patterns, and conventions. Trace data flow, understand interactions. Identify gotchas and edge cases. Respect existing code—understand WHY it exists before changing it.

---

### Step 2: Plan

Design the simplest implementation that works and get user approval.

- Present the 80/20 solution: 80% value with 20% code
- Say "no" to unnecessary complexity—push back on feature creep
- Specify exact files and line ranges to modify
- Identify risks, database migrations, API changes, breaking changes
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

### Test Strategy
- How changes will be verified (prefer integration tests)

### Risks
- Potential issues to watch for
```

Ask: "Approve this plan to proceed?"

Do NOT proceed until user says yes.

---

### Step 3: Implement

Execute the approved plan with minimal, correct code. Spawn the implement agent with the approved plan and analysis context. Resume by ID with feedback rather than spawning new agents.

---

### Step 4: Review

Validate the implementation meets quality standards:

1. **Tests**: Exist? Pass? Clear and useful? (HARD BLOCKER if missing/failing/flaky/unclear)
2. **Linting**: Code passes linters?
3. **Complexity**: Reasonably simple? Complexity demons present?
4. **Patterns**: Match existing conventions?
5. **Security**: Obvious vulnerabilities?

If issues found, iterate with the implement agent until resolved.

**Hard rule**: Tests mandatory. No exceptions (except trivial scripts).

---

## Code Principles

### Function Size: Important Things Should Be Big

Functions come in three tiers:
- **Crux functions** (200-300+ LOC): Contain important core logic. Keep these big and cohesive so the important stuff is visually prominent. Splitting diminishes clarity.
- **Support functions** (10-20 LOC): Moderate helpers that support crux functions
- **Utility functions** (5-10 LOC): Small, reusable pieces

**Don't fear large functions.** If a function contains the crux logic of your system, it SHOULD be big. Important things should be big, whereas unimportant things should be little.

Examples: SQLite, Chrome, Redis, IntelliJ—all highly successful projects containing substantial functions.

### Abstraction: Wait for Natural Cut Points

**Don't abstract early.** Early in projects, systems resemble "water"—shapeless and difficult to factor properly. Wait for patterns to emerge naturally before creating abstractions.

Good factoring:
- Creates narrow interfaces
- Traps complexity internally (like "complexity demon trapped in crystal")
- Emerges from actual use patterns, not anticipated needs

Bad factoring:
- Premature abstraction before patterns emerge
- Interfaces with single implementations
- Helper functions called only once
- "Extensibility" for hypothetical futures

### DRY Has Limits

Don't Repeat Yourself is a guideline, not a law:
- **2 occurrences**: Leave it (might be coincidence)
- **3 occurrences**: Consider abstracting, but only if the abstraction is simple
- **Simple repetition > complex DRY**: Three similar lines of code is better than a premature abstraction involving callbacks and complex object models

### Locality of Behavior

Prefer "put code on the thing that do the thing" over separation of concerns. When related functionality is scattered across files, it becomes hard to understand and modify.

Example: Active Record combines database mapping, domain logic, and view helpers in one class. This is GOOD—it eliminates intermediate DTOs and unnecessary layers.

### Expression Complexity

Favor readable, debuggable code over minimal line counts:
- Named intermediate variables clarify logic
- Avoid nested conditionals and ternaries
- Use guard clauses and early returns over deep nesting
- If you can't explain it simply, it's too complex

### Minimize Classes and Concepts

Avoid excessive abstraction and fear of "God objects." Unified classes handling related concerns eliminate unnecessary indirection and make systems easier to understand.

### Code Health

**Health Thresholds** (treat as diagnostic guides, not rules):

- **Function parameters**: 4 max. More? Group as object if they represent the same conceptual thing, or reconsider the abstraction
- **Function length**: 70 LOC max. Larger functions should justify themselves (crux logic only)
- **Nesting depth**: 2 levels max. Use guard clauses and early returns to flatten
- **Cyclomatic complexity**: 9 max. Each `if`, `else`, `case`, `loop` adds 1. More than 9 = too many decision paths to test/maintain

**Example**:

```
// Bad (CC = 11, nesting = 4)
function process(a, b, c, d, e) {
  if (a) {
    if (b) {
      if (c && d) {
        if (e) { /* ... */ }
      }
    }
  }
}

// Better (CC = 4, nesting = 1)
function process(config) {
  const { a, b, c, d, e } = config
  if (!a) return
  if (!b) return
  if (!(c && d)) return
  if (e) { /* ... */ }
}
```

Guard clauses reduce nesting AND complexity. Keep it simple and flat.

---

## Web Service Development

### API Design
- Consistent URL structure: `/api/v1/resources/:id`
- Correct HTTP methods and status codes (201 for create, 204 for delete, etc.)
- Clear error responses with error codes
- Pagination from the start for list endpoints
- **Design for simple use cases first**, complex capabilities secondarily
- Put operations on the objects they affect

### Database
- Parameterized queries only (never string concatenation)
- Transactions for multi-step operations
- Check for N+1 queries
- Reversible migrations
- **Profile before optimizing**: Network costs typically dwarf CPU concerns

### Security
- Validate inputs at API boundary
- Escape outputs (HTML, SQL, shell commands)
- Use existing auth/permission patterns
- Don't leak internal details in error responses
- Log errors with context but redact sensitive data (passwords, tokens, PII)

### Debugging
When investigating issues:
1. **Reproduce first** - understand how to trigger it
2. **Gather evidence** - logs, errors, stack traces
3. **Trace the flow** - follow the request path
4. **Check the obvious** - config, connectivity, permissions
5. **Look at recent changes** - prime suspects

---

## UI Development

### Core Principles
- **Function over form**: Every element earns its place by doing something useful
- **Obvious affordances**: Users should never guess what's clickable or how things work
- **Information density**: Show what matters, hide what doesn't, waste no space
- **Locality of behavior**: Put code on the thing that do the thing (HTML with behavior attributes)
- **Consistency**: Same patterns everywhere, no surprises
- **Speed**: Fast to load, fast to understand, fast to use

### Technology Stack
- **Semantic HTML** first - use correct elements (`<nav>`, `<main>`, `<aside>`, `<form>`, `<article>`)
- **HTMX** for server-driven UI updates - keeps behavior with elements
- **Alpine.js** for reactive components when needed (minimal client state)
- **Vanilla JS** for simple interactions
- **Plain CSS** - no frameworks, no utility classes (unless project already uses them)

### CSS Guidelines
- System font stack: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`
- High contrast text (near-black on white, or white on near-black)
- Minimal palette: 1-2 colors maximum (Blue=links, Red=errors, Green=success, Yellow=warnings)
- Simple grid or flexbox layouts
- Standard HTML form controls (style minimally)
- Visible focus states for keyboard navigation

### Anti-Patterns to Avoid
- Icons without labels
- Hamburger menus when space exists
- Modals for simple actions
- Animations that delay interaction
- Custom styled form controls that break accessibility
- Separation of concerns (HTML/CSS/JS in different files for same component)

### Data Display
- **Tables for data** - don't fight this
- Align numbers right, text left
- Zebra striping or borders for row separation
- Sortable columns where useful

---

## Testing Strategy

Integration tests are the sweet spot—they verify overall system behavior, remain stable through refactoring, and test what matters (DOM state, API responses, database state), not internal functions.

Wait until core APIs stabilize before writing comprehensive test suites. Early unit tests become maintenance burden as code evolves.

Always test:
- Happy paths (expected successful scenarios)
- Edge cases (boundary conditions, empty inputs)
- Error handling (invalid inputs, failures)
- Integration points (dependencies, APIs, database)

Keep tests simple, focused, and easy to understand. Use clear names: `test_transfer_fails_with_insufficient_funds`. Tests should run independently.

**Hard rule**: Tests mandatory (except trivial scripts).

---

## Refactoring

**Large refactors frequently fail. Keep changes small.**

Before removing code, understand WHY it exists. Code that looks stupid might be handling an ugly edge case.

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

