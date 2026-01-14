---
name: simplify
description: Review code for simplicity violations. Checks file size limits (300 line hard cap), complexity metrics, naming conventions, and language-specific best practices. Can be invoked standalone or automatically as part of review.
---

# Code Simplification Skill

Analyze code for simplicity, maintainability, and adherence to best practices.

## Core Philosophy

**Simple is better than complex. Complex is better than complicated.**

Key principles:
- Code should be easy to understand at a glance
- Complexity should be justified by genuine need
- Abstractions should pay for themselves
- Clear > Clever

## Universal Rules (All Languages)

### File Size Limits

**HARD LIMITS:**
- Source files: 300 lines MAXIMUM (BLOCKER - refuse approval)
- Test files: 500 lines maximum
- Strong warning at 250 lines

**SOFT TARGETS:**
- Source files: aim for 200 lines
- Single function: < 50 lines (warn at 40)
- Single struct/class: < 100 lines

**EXCEPTIONS (must be justified):**
- Generated code (must have header comment indicating generation)
- Lookup tables/data (suggest moving to JSON/data file)
- Large switch statements (suggest table-driven approach)

**When file > 300 lines: BLOCKER**
- This is a hard failure. File must be split before approval.
- Provide specific splitting strategy based on file contents

### Variable Naming Rules

**Principle: Name length ∝ scope/lifetime**

| Scope | Lifetime | Length | Examples |
|-------|----------|--------|----------|
| Loop iterator | 1-5 lines | 1-2 chars | `i`, `j`, `k`, `x`, `y` |
| Function local | 5-20 lines | 3-8 chars | `err`, `ctx`, `user`, `count` |
| Function param | Function lifetime | 4-10 chars | `userID`, `config`, `timeout` |
| Struct field | Struct lifetime | 5-15 chars | `Username`, `CreatedAt`, `StatusCode` |
| Package level | Package scope | 8-20 chars | `DefaultTimeout`, `MaxRetries` |
| Global/exported | Cross-package | 10-30 chars | `UserAuthenticationManager` |

**Acceptable abbreviations:**
- `ctx`, `err`, `req`, `resp`, `db`, `cfg`, `msg`, `idx`, `tmp`

**Avoid:**
- Single letters except for: loop counters, math variables, Go receivers
- Generic names: `data`, `info`, `handle`, `manager`, `processor` (without context)
- Abbreviations in long-lived variables

### Complexity Metrics

**Function Cyclomatic Complexity:**
- 1-5: Simple ✓
- 6-10: Moderate ✓
- 11-15: Complex ⚠️ (review required)
- 16+: High risk ❌ (must refactor)

**Calculation heuristic:**
Count: `if`, `for`, `while`, `case`, `&&`, `||`, `?:`, `catch`

**Function Cognitive Complexity:**
- 1-10: Easy ✓
- 11-15: Acceptable ✓
- 16-25: Getting hard ⚠️
- 26+: Difficult ❌ (must refactor)

**Calculation heuristic:**
Base complexity + (nesting depth multiplier × nested branches) + breaks in linear flow

**Nesting Depth (Code):**
- 1-2 levels: Acceptable ✓
- 3 levels: Warning ⚠️
- 4+ levels: Refactor required ❌

**Strategy:** Use guard clauses and early returns

**Function Parameters:**
- ≤ 4 parameters: ✓
- 5+ parameters: ⚠️ Consider parameter object or builder pattern

**Function Length:**
- < 50 lines: ✓
- 40-50 lines: ⚠️ Consider splitting
- > 50 lines: ❌ Must split

### Code Structure Principles

**Single Responsibility:**
- Each function/class/file should do ONE thing
- If you can't name it without "and", it's doing too much

**DRY (Don't Repeat Yourself):**
- 2 occurrences: Leave it (might be coincidence)
- 3+ occurrences: Abstract it

**Guard Clauses Over Nesting:**
```
BAD:
if (condition) {
    if (otherCondition) {
        // deep nesting
    }
}

GOOD:
if (!condition) return;
if (!otherCondition) return;
// linear flow
```

**Early Returns:**
Prefer multiple return points with clear guard clauses over deeply nested if/else

## Language-Specific Rules

### Go-Specific

#### Go Proverbs (19 Total)

1. **"Don't communicate by sharing memory, share memory by communicating"**
   - Flag: Shared mutable state without synchronization
   - Prefer: Channels for data passing between goroutines

2. **"Concurrency is not parallelism"**
   - Design for concurrent structure, not parallel execution
   - Goroutines are about code organization, not CPU cores

3. **"Channels orchestrate; mutexes serialize"**
   - Use channels for: producer-consumer, pipelines, orchestration
   - Use mutexes for: protecting shared state, critical sections

4. **"The bigger the interface, the weaker the abstraction"**
   - Flag: Interfaces with > 3 methods
   - Ideal: 1-2 methods per interface
   - Suggest: Split into smaller, focused interfaces

5. **"Make the zero value useful"**
   - Structs should work correctly when zero-initialized
   - Avoid requiring explicit initialization

6. **"interface{} says nothing"**
   - Flag: Unnecessary use of `interface{}` or `any`
   - Prefer: Concrete types or generic constraints (Go 1.18+)

7. **"A little copying is better than a little dependency"**
   - Evaluate: Is this dependency worth it?
   - For < 50 lines of trivial code, copying may be better

8. **"Clear is better than clever"**
   - Flag: Complex one-liners, obscure optimizations
   - Readable code > "smart" code

9. **"Errors are values"**
   - Treat errors as values, not exceptions
   - Use error wrapping for context

10. **"Don't just check errors, handle them gracefully"**
    - Flag: `_ = err` or ignored errors
    - Require: Meaningful error handling or explicit documentation why ignored

11. **"Design the architecture, name the components, document the details"**
    - High-level design matters more than low-level comments

12. **"Documentation is for users"**
    - Focus on what, why, and how to use
    - Not on implementation details

13. **"Don't panic"**
    - Panics are for programmer errors, not expected errors
    - Return errors instead

14. **"Gofmt's style is no one's favorite, yet gofmt is everyone's favorite"**
    - Use standard formatting, don't debate style

15. **"Cgo is not Go"**
    - Flag: Unnecessary cgo usage
    - Cgo has costs: slower builds, cross-compilation issues, GC complexity

16. **"With the unsafe package there are no guarantees"**
    - Flag: unsafe usage
    - Require: Strong justification and documentation

17. **"Syscall must always be guarded with build tags"**
    - Platform-specific code needs build constraints

18. **"The bigger the interface, the weaker the abstraction"** (repeated emphasis)
    - Really important: small interfaces!

19. **"Make the zero value useful"** (repeated emphasis)
    - Really important: usable defaults!

#### Go-Specific Patterns

**Interface Design:**
- 1-3 methods ideal
- Define interfaces at point of use (consumer side)
- Accept interfaces, return concrete types

**Error Handling:**
- Wrap errors with context: `fmt.Errorf("doing X: %w", err)`
- Custom error types for control flow
- Sentinel errors for expected conditions

**Package Organization:**
- Flat is better than nested
- Internal packages for truly internal code
- `pkg/` only if building reusable libraries

**Receiver Naming:**
- Single letter acceptable: `func (s *Server)` or `func (h *Handler)`
- Be consistent within a type

### JavaScript/TypeScript-Specific

**Async Patterns:**
- Prefer async/await over promise chains
- Avoid callback hell (> 2 levels of callbacks)
- Handle rejections/errors in async code

**Type Safety (TypeScript):**
- Flag: `any` usage (weakens type safety)
- Use: `unknown` for true unknowns
- Prefer: Specific types or generic constraints

**Immutability:**
- Prefer `const` over `let`
- Use immutable patterns for state updates
- Array methods: `map`, `filter`, `reduce` over mutations

**Function Style:**
- Arrow functions for closures/callbacks
- Function declarations for named exports
- Avoid long promise chains (use async/await)

**Module Patterns:**
- Use ESM (`import/export`) over CommonJS
- Named exports over default exports (better refactoring)
- Barrel exports (`index.ts`) sparingly

### CSS-Specific

**Nesting Depth:**
- 1-2 levels: ✓
- 3 levels: ⚠️
- 4+ levels: ❌ (too specific, hard to override)

**Selector Strategy:**
- Prefer classes over IDs for styling
- IDs only for anchors and form labels
- Avoid overly specific selectors

**Magic Numbers:**
- Use CSS variables/custom properties
- No hardcoded colors, spacing values
- Define design tokens

**Organization:**
- Group related properties (positioning, box model, typography, visual)
- Logical sectioning with comments
- One media query per breakpoint

**Naming:**
- Semantic class names (what it is, not what it looks like)
- BEM or similar methodology for consistency
- Avoid presentational classes like `.blue-text`

### HTML-Specific

**Semantic HTML:**
- Use: `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<footer>`
- Avoid: Generic `<div>` soup
- Accessibility: proper heading hierarchy (h1 → h2 → h3)

**Nesting Depth:**
- 1-5 levels: ✓
- 6-7 levels: ⚠️
- 8+ levels: ❌ (extract components)

**Accessibility:**
- `alt` text for images
- ARIA labels for interactive elements
- Semantic structure (landmarks, headings)
- Form labels associated with inputs

**ID Usage:**
- Prefer classes over IDs (except for anchors/form labels)
- IDs must be unique per page

**Component Size:**
- > 200 lines: Break into partials/components

### Templ-Specific

**Component Size:**
- ≤ 200 lines per component
- Extract sub-components for reusability
- Single responsibility per component

**Props/Parameters:**
- ≤ 5 parameters per component
- Use structs for > 5 related parameters

**Logic Placement:**
- Keep Go logic minimal in templates
- Move complex logic to handlers/services
- Compute values before passing to template

**Nesting:**
- 1-5 levels: ✓
- 6-7 levels: ⚠️
- 8+ levels: ❌ (extract sub-components)

**Semantic HTML:**
- Use semantic elements within templ
- Maintain accessibility standards

**Conditional Rendering:**
- Use guard clauses in templ where possible
- Avoid complex expressions in templates

## Review Process

1. **Detect language** from file extension
2. **Calculate metrics:**
   - Line count per file
   - Function complexity (cyclomatic approximation)
   - Nesting depth
   - Parameter counts
3. **Check universal rules:**
   - File size limits
   - Variable naming
   - Complexity thresholds
   - Function length
4. **Apply language-specific rules:**
   - Go proverbs and patterns
   - JS/TS async and typing
   - CSS nesting and organization
   - HTML semantics
   - Templ component design
5. **Prioritize findings:**
   - BLOCKER: File > 300 lines, complexity > 15, nesting > 4
   - WARNING: Approaching limits, naming issues, proverb violations
   - NOTE: Improvement opportunities

## Output Format

```markdown
## Simplification Review

### Metrics
- Files analyzed: X
- Total lines: X (excluding tests)
- Files exceeding limits: X
- Functions exceeding complexity: X

### BLOCKERS (Must Fix)
- `file.go:123` - File size 350 lines (HARD LIMIT: 300) ❌
  - Strategy: Split into: `file_core.go`, `file_handlers.go`, `file_utils.go`
- `handler.ts:45-120` - Function complexity 18 (LIMIT: 15) ❌
  - Refactor: Extract validation and processing into separate functions

### WARNINGS (Should Fix)
- `service.go:34` - Interface has 5 methods (recommended: 1-3) ⚠️
  - Suggestion: Split into `Reader` and `Writer` interfaces
- `component.tsx:78` - Nesting depth 4 (recommended: ≤3) ⚠️
  - Refactor: Use guard clauses and early returns

### NOTES (Improvements)
- `utils.js:12` - Variable `data` is generic (scope: function, 30 lines)
  - Suggestion: Rename to describe what it contains: `userRecords`, `apiResponse`, etc.

### Proverb Violations (Go)
- "Clear is better than clever" @ `parser.go:89`
  - One-liner with nested ternaries is hard to parse
  - Suggestion: Break into explicit steps with named intermediates
- "The bigger the interface, the weaker the abstraction" @ `storage.go:12`
  - `Storage` interface has 7 methods
  - Suggestion: Split into `StorageReader`, `StorageWriter`, `StorageLister`

### Refactoring Examples

#### 1. Extract Function (file.go:45-95)
```go
// BEFORE: Complexity 14, 50 lines
func ProcessOrder(order Order) error {
    if order.Status != "pending" {
        return errors.New("invalid status")
    }
    if order.Total < 0 {
        return errors.New("invalid total")
    }
    // ... 45 more lines of mixed validation and processing
}

// AFTER: Complexity 3 per function
func ProcessOrder(order Order) error {
    if err := ValidateOrder(order); err != nil {
        return fmt.Errorf("validation failed: %w", err)
    }
    if err := ExecuteOrder(order); err != nil {
        return fmt.Errorf("execution failed: %w", err)
    }
    return nil
}

func ValidateOrder(order Order) error {
    if order.Status != "pending" {
        return errors.New("invalid status")
    }
    if order.Total < 0 {
        return errors.New("invalid total")
    }
    // ... focused validation logic
    return nil
}
```

#### 2. Reduce Nesting (handler.js:23-45)
```javascript
// BEFORE: Nesting depth 4
function handleUser(user) {
    if (user) {
        if (user.isActive) {
            if (user.permissions.includes('admin')) {
                if (user.lastLogin > cutoff) {
                    return processAdmin(user);
                }
            }
        }
    }
    return null;
}

// AFTER: Guard clauses, nesting depth 1
function handleUser(user) {
    if (!user) return null;
    if (!user.isActive) return null;
    if (!user.permissions.includes('admin')) return null;
    if (user.lastLogin <= cutoff) return null;

    return processAdmin(user);
}
```

#### 3. Split File (handlers.go: 450 lines)
```
// BEFORE: All handlers in one file
handlers.go (450 lines)
  - User handlers (120 lines)
  - Order handlers (140 lines)
  - Product handlers (110 lines)
  - Common middleware (80 lines)

// AFTER: Split by resource
handlers/
  users.go (120 lines)      - User-specific handlers
  orders.go (140 lines)     - Order-specific handlers
  products.go (110 lines)   - Product-specific handlers
  common.go (80 lines)      - Shared middleware
```

#### 4. Flatten CSS (styles.scss)
```css
/* BEFORE: 5 levels deep, overly specific */
.container {
    .header {
        .nav {
            .menu {
                .item {
                    color: blue;
                    &:hover {
                        color: darkblue;
                    }
                }
            }
        }
    }
}

/* AFTER: Flat, semantic classes */
.nav-menu-item {
    color: blue;
}

.nav-menu-item:hover {
    color: darkblue;
}
```

### Summary
- BLOCKERS: X (must fix before approval)
- WARNINGS: X (should address)
- NOTES: X (optional improvements)

**Recommendation:** [APPROVE / APPROVE WITH WARNINGS / REJECT]
```

## Severity Rules

**BLOCKER (Must fix before approval):**
- File > 300 lines (hard limit)
- Cyclomatic complexity > 15
- Nesting depth > 4
- Security issues (from universal checks)

**WARNING (Should fix, but can proceed with acknowledgment):**
- File > 250 lines (approaching limit)
- Complexity 11-15
- Nesting depth 3
- Function > 50 lines
- Interface > 3 methods (Go)
- 5+ function parameters

**NOTE (Improvement opportunity):**
- File > 200 lines (soft target)
- Generic variable names
- Minor proverb violations
- Style inconsistencies
- Missing opportunities for simplification

## Integration with Review

When called from `/review`, this skill runs after tests pass but before final sign-off.

Workflow:
1. Tests pass ✓
2. Linting passes ✓
3. CodeScene review (if available) ⚠️
4. **Simplify review** (this skill) ⚠️ / ❌
5. Final sign-off

## Standalone Usage

Can be invoked directly as `/simplify` for quick checks:
- Analyze specific files
- Review git diff
- Provide refactoring suggestions

## Notes

- Be practical, not pedantic
- Context matters: internal tooling vs customer-facing code
- Justify strictness: is this rule helping or hurting?
- Provide actionable feedback with concrete examples
- Focus on teaching, not just flagging
