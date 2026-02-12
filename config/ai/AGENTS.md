# AI Agent Instructions

## Core Philosophy

### Complexity is bad

Your primary duty is to help the programmer say "no" to complexity:
- **Say no**: Decline unnecessary features and abstractions.
- **Say ok (with compromise)**: When you can't say no, pursue the 80/20 solution—deliver 80% of desired value with 20% of the code.
- **Question abstractions**: "Is this solving a problem we have TODAY?"
- **Understand before making changes**: Before removing or refactoring code, understand WHY it exists.

---

## Tech Stack Quick Reference

### Java
**Anti-pattern**: Isolated data holder classes (DTO packages, standalone model files). Data lives where it's used. Embed inner classes next to the logic consuming them—follow Go/Clojure thinking.

**Modern Java Patterns (Java 16+):**
- Use records instead of data classes
- Prefer inner classes for data structures local to one service
- Use sealed interfaces for fixed type hierarchies
- Static factory methods over constructors
- Local records for temporary data structures within methods
- Avoid excessive abstraction - 3 similar lines beat a complex pattern

Split only when multiple unrelated consumers and semantic boundaries are clear.

### CSS
**Rule**: Never inline styles. All styling lives in separate CSS files. Styles are the source of truth; keep them organized and discoverable, not hidden in markup.

---

## Workflow
For non-trivial tasks (more than a one-line fix), follow this sequence:

```
ANALYZE → PLAN → [user approval] → IMPLEMENT → REVIEW
```

Do not skip steps. Do not implement without explicit approval.

### Step 1: Analyze
- Use grep/glob to find files, read relevant ones, trace data flow. Understand existing code before replacing it.
- Identify gotchas and edge cases.

---

### Step 2: Plan
Design the simplest implementation that works and get user approval.

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
Execute the approved plan with minimal, correct code.

Key Requirements:
1. Make exactly the changes specified - no more, no less
2. Write tests as part of implementation (see Testing Strategy)

Prohibited Actions:
- Don't add unplanned features or refactor adjacent code
- Don't suppress lint warnings or comment them out

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

### Function Size Limits

- **Core logic**: 70 LOC max (keep cohesive, don't over-split)
- **Helper functions**: 10-20 LOC
- **Utilities**: 5-10 LOC

### Abstraction
- Wait for 3+ copies before abstracting
- Good: Narrow interfaces, internal complexity
- Bad: Single-use helpers, "extensibility" for hypotheticals

### Locality of Behavior
Put code in the thing that does it. Don't scatter functionality across files.

### Expression Complexity
- Use named intermediate variables
- Guard clauses over nesting (max 2 levels)
- If you can't explain it simply, it's too complex

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
- **Reproduce first**: understand how to trigger it
- **Gather evidence**: logs, errors, stack traces
- **Trace the flow**: follow the request path
- **Check the obvious**: config, connectivity, permissions
- **Look at recent changes**: prime suspects

---

## UI Development

### Core Principles

- **Obvious affordances**: Users should never guess what's clickable or how things work
- **Information density**: Show what matters, hide what doesn't, waste no space
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

## Testing
  REQUIRED: Integration test for every non-trivial change
  Test: happy path, edge cases, errors, integration points
  DON'T: Test internal implementation details

---

## Refactoring

**Large refactors frequently fail. Keep changes small.** Before removing code, understand WHY it exists (Chesterton's Fence). Code that looks stupid might be handling an ugly edge case.

- Refactor in tiny, working increments
- Keep the system working after each step
- Don't add abstraction during refactoring unless it emerges naturally
- If refactoring reveals complexity demons, simplify first, then refactor
- Wait for natural "cut points" to become obvious

---

## Creating commits

When commiting agents are always required to credit themselves as a co-author with:

`Co-authored-by: Qwen <noreply@qwen.ai>` (for Qwen models only)
