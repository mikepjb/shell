# AI Agent Instructions

## Core Rule: Fight Complexity
- Say no to unnecessary features and abstractions
- When you can't say no, pursue the 80/20 solution — 80% value with 20% code
- Question: "Is this solving a problem we have TODAY?"
- Understand code before changing it (Chesterton's Fence)

## Tech Preferences

**Java (16+)**: Records over data classes. Inner classes over DTOs — data lives where it's used, not in isolated packages. Sealed interfaces for type hierarchies. Static factory methods over constructors. Split only when multiple unrelated consumers exist.

**CSS**: Never inline styles. All styling in separate CSS files (inline styles can't use pseudo-classes, media queries, or pseudo-elements).

**UI Stack**: Semantic HTML → HTMX → Alpine.js → Vanilla JS → Plain CSS

## Workflow (non-trivial tasks)

ANALYZE → PLAN → [user approval] → IMPLEMENT

1. **Analyze**: Read relevant files, trace data flow, identify edge cases
2. **Plan**: Design the simplest implementation. Present inline covering:
   - Changes: which files, what will change in each, and why
   - Database changes: migration needed? Reversible?
   - API impact: new/modified endpoints, breaking changes?
   - Test strategy
   - Risks
   Ask: "Approve this plan to proceed?" Do NOT proceed until user says yes.
3. **Implement**: Execute the approved plan with minimal, correct code.
   - Make exactly the changes specified — no more, no less
   - Write tests as part of implementation
   - Don't add unplanned features or refactor adjacent code
   - Don't suppress lint warnings or comment them out
   - Pre-stop hook handles linting and test verification automatically

## Code Standards

### Function Size
- **Core logic**: 70 LOC max (keep cohesive, don't over-split)
- **Helper functions**: 10-20 LOC
- **Utilities**: 5-10 LOC

### Abstraction
- Wait for 3+ copies before abstracting
- Good: Narrow interfaces, internal complexity
- Bad: Single-use helpers, "extensibility" for hypotheticals

### Locality of Behavior
Put code in the thing that does it. Don't scatter functionality across files.

### Code Health
- **Function parameters**: 4 max. More? Group as object or reconsider the abstraction
- **Nesting depth**: 2 levels max. Use guard clauses and early returns to flatten
- **Cyclomatic complexity**: 9 max. Each `if`, `else`, `case`, `loop` adds 1

## Web Service Development

### API Design
- REST conventions: consistent URLs (`/api/v1/resources/:id`), correct HTTP methods/status codes, clear error responses
- Pagination from the start for list endpoints
- Put operations on the objects they affect

### Database
- Use parameterized queries only (never string concatenation)
- Use transactions for multi-step operations
- Check for N+1 queries
- Reversible migrations
- Index the columns you query on
- NOT NULL by default

### Security
- Validate type, format, and length of all inputs at API boundary
- Escape outputs (HTML, SQL, shell commands)
- Return generic error messages to clients; log full details server-side only
- Redact passwords, tokens, and PII from logs

### Debugging
- Reproduce the bug before fixing it
- Check the obvious: config, connectivity, permissions
- Check recent git changes — prime suspects

## UI Development

### Technology Stack
- **Semantic HTML** first — use correct elements (`<nav>`, `<main>`, `<aside>`, `<form>`, `<article>`)
- **HTMX** for server-driven UI updates
- **Alpine.js** for reactive components when needed
- **Vanilla JS** for simple interactions
- **Plain CSS** — no frameworks, no utility classes (unless project already uses them)

### Anti-Patterns
- Icons without labels
- Modals for simple actions
- Custom styled form controls that break accessibility
- Separation of concerns (HTML/CSS/JS in different files for same component)

### Data Display
- **Tables for data** — don't fight this
- Align numbers right, text left
- Zebra striping or borders for row separation

## Testing
- REQUIRED: Integration test for every non-trivial change
- Test: happy path, edge cases, errors, integration points
- DON'T: Test internal implementation details
- Use table-driven tests for repeated assertions over different inputs

## Refactoring
- Refactor in tiny, working increments
- Keep the system working after each step
- Don't add abstraction during refactoring unless it emerges naturally
- If refactoring reveals complexity demons, simplify first, then refactor

## Commits
When commiting agents are always required to credit themselves as a co-author with:
`Co-authored-by: Qwen <noreply@qwen.ai>` (Qwen models only)
