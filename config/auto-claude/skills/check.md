---
name: check
description: Pre-submission review combining strategic oversight and simplicity checks. Diffs against base branch, analyzes code health, and provides comprehensive feedback before committing changes.
---

# Check Skill

Comprehensive pre-submission review for manually written code changes. Combines strategic oversight (overseer) with simplicity analysis before you commit.

## Purpose

Use this when you've been manually writing code and want a full review before submission. This is NOT the automated review from the workflow - it's for checking your own work.

## Process

### 1. Identify Base Branch and Get Stats

First, locate the bin directory and run the helper scripts:

```bash
# Find the git-base-branch and git-diff-stats scripts
# They may be in ./bin, ../bin, or need to be called with full path
BASE_BRANCH=$(./bin/git-base-branch 2>/dev/null || ../bin/git-base-branch 2>/dev/null || git-base-branch)
STATS=$(./bin/git-diff-stats 2>/dev/null || ../bin/git-diff-stats 2>/dev/null || git-diff-stats)
```

If scripts aren't found, calculate manually:
```bash
# Determine base branch
BASE_BRANCH=$(git rev-parse --verify main 2>/dev/null && echo "main" || echo "master")

# Get stats
git diff --shortstat $BASE_BRANCH...HEAD
```

### 2. Get Full Diff

```bash
git diff $BASE_BRANCH...HEAD
```

If diff is empty, check for unstaged changes:
```bash
git diff
```

If still empty, ask the user what they're working on.

### 3. Strategic Review (Overseer-style)

Analyze through a strategic lens:

**Focus Areas:**
- **Naming**: Clear intent? Consistent with codebase? Will it make sense in 6 months?
- **Boundaries**: Right place? Coupling issues? Clear responsibilities?
- **Patterns**: Duplicating existing code? Time to abstract? Premature abstraction?
- **Future Pain**: Will this make next features harder? Hidden complexity? Ignored edge cases?

**Communication Style:**
- Ask questions, don't dictate
- Be minimal - short observations, specific questions
- Respect judgment - you're a second pair of eyes

### 4. Simplicity Review

Analyze code quality with concrete metrics:

**Universal Checks:**
- File size limits (300 line HARD LIMIT, warn at 250)
- Function complexity (cyclomatic)
- Nesting depth (max 3, blocker at 4+)
- Function parameters (warn at 5+)
- Variable naming (proportional to scope)

**Language-Specific:**
- **Go**: Proverbs (interface size, error handling, zero values, etc.)
- **JS/TS**: Async patterns, type safety, immutability
- **CSS**: Nesting depth, selector specificity
- **HTML/Templ**: Semantic structure, accessibility

**Severity Levels:**
- BLOCKER: File > 300 lines, complexity > 15, nesting > 4
- WARNING: Approaching limits, naming issues, pattern violations
- NOTE: Improvement opportunities

### 5. Changed Files Analysis

List all changed files with their line counts:
```bash
git diff --stat $BASE_BRANCH...HEAD
```

Identify files that need closer inspection based on:
- Size of changes
- Criticality (core business logic, security, data handling)
- Complexity increase

## Output Format

```markdown
## Pre-Submission Review

### Branch Status
- Base: [main/master]
- Changes: [+X -Y lines]
- Files modified: X

### Changed Files
[List from git diff --stat with analysis of significant changes]

---

## Strategic Review

### Observations
[2-3 sentences on what you see happening]

### Questions
- [Specific question about naming/structural choice]
- [Another question if warranted]

### Flags
- [Anything that could cause future pain - or "None"]

---

## Simplicity Review

### Metrics
- Files analyzed: X
- Total lines changed: +X -Y
- Files exceeding limits: X
- Functions exceeding complexity: X

### BLOCKERS (Must Fix)
[File > 300 lines, complexity > 15, nesting > 4, etc.]

### WARNINGS (Should Fix)
[Approaching limits, style issues, pattern violations]

### NOTES (Improvements)
[Optional improvements, suggestions]

### Language-Specific Observations
[Go proverbs, TS patterns, etc.]

---

## Summary

**Strategic Concerns:** [count or "None"]
**Blockers:** [count or "None"]
**Warnings:** [count]
**Notes:** [count]

**Recommendation:** ✅ READY TO COMMIT | ⚠️ REVIEW CONCERNS | ❌ MUST FIX BLOCKERS

### Next Steps
[If issues found, list specific actions needed]
```

## Examples

### Clean Changes
```markdown
## Pre-Submission Review

### Branch Status
- Base: main
- Changes: +47 -12 lines
- Files modified: 3

### Changed Files
- handlers/user.go (+32 -8) - Added validation logic
- models/user.go (+12 -2) - New fields for profile
- handlers/user_test.go (+3 -2) - Updated tests

---

## Strategic Review

### Observations
Adding user profile fields with validation in the handler. Clean separation between model and handler logic.

### Questions
None - structure looks good.

### Flags
None

---

## Simplicity Review

### Metrics
- Files analyzed: 3
- Total lines changed: +47 -12
- Files exceeding limits: 0
- Functions exceeding complexity: 0

### BLOCKERS
None

### WARNINGS
None

### NOTES
- `handlers/user.go:45` - Consider extracting validation into separate function if more validations are added

---

## Summary

**Strategic Concerns:** None
**Blockers:** None
**Warnings:** 0
**Notes:** 1

**Recommendation:** ✅ READY TO COMMIT
```

### Issues Found
```markdown
## Pre-Submission Review

### Branch Status
- Base: main
- Changes: +156 -23 lines
- Files modified: 2

### Changed Files
- service/processor.go (+142 -20) - Major refactoring ⚠️
- service/processor_test.go (+14 -3) - New tests

---

## Strategic Review

### Observations
Large refactoring of processor logic with added caching layer. Mixing business logic with cache management.

### Questions
- The cache is using a global variable. How will tests isolate cache state?
- `ProcessWithCache()` does I/O (cache read) under a lock. Could this block other requests?
- Cache invalidation: What happens when data changes? Currently no invalidation logic.

### Flags
- Cache coupling: The processor now depends on global cache state, making it harder to reason about behavior
- Missing error handling: Cache read errors are silently ignored, might mask issues

---

## Simplicity Review

### Metrics
- Files analyzed: 2
- Total lines changed: +156 -23
- Files exceeding limits: 1
- Functions exceeding complexity: 1

### BLOCKERS
- `service/processor.go` - File is 324 lines (HARD LIMIT: 300) ❌
  - Strategy: Extract cache logic to `service/cache.go` (~50 lines) and helper functions to `service/helpers.go` (~30 lines)

### WARNINGS
- `service/processor.go:78-145` - Function `ProcessWithCache` complexity 12 (recommended: ≤10) ⚠️
  - Refactor: Extract cache lookup, validation, and processing into separate functions
- `service/processor.go:89` - Nesting depth 4 (recommended: ≤3) ⚠️

### NOTES
- Variable `data` used in multiple contexts (lines 45, 89, 123) - consider more specific names

### Language-Specific (Go)
- Proverb violation: "Clear is better than clever" @ `processor.go:156`
  - Complex one-liner makes logic hard to follow
- Pattern: Global cache variable should be passed as dependency for better testability

---

## Summary

**Strategic Concerns:** 3
**Blockers:** 1 (file size)
**Warnings:** 2
**Notes:** 1

**Recommendation:** ❌ MUST FIX BLOCKERS

### Next Steps
1. Split `service/processor.go` into multiple files (REQUIRED)
2. Address cache coupling and error handling (RECOMMENDED)
3. Consider simplifying `ProcessWithCache` function (RECOMMENDED)
```

## When to Say Nothing

If changes look good - clean naming, good structure, no red flags:

```markdown
## Pre-Submission Review

### Branch Status
- Base: main
- Changes: +12 -3 lines
- Files modified: 1

---

## Strategic Review
Looks good. No strategic concerns.

## Simplicity Review
All metrics within acceptable ranges. No issues found.

---

## Summary
**Recommendation:** ✅ READY TO COMMIT
```

## Integration with Bin Scripts

The skill uses these helper scripts:
- `bin/git-base-branch` - Determines main vs master
- `bin/git-diff-stats` - One-line diff summary

These scripts are deterministic and save tokens by providing consistent output.

## Notes

- Be practical, not pedantic
- Focus on issues that would actually impact code health
- Provide actionable feedback with specific file:line references
- Context matters: adjust strictness based on code criticality
- Don't invent feedback for the sake of it
- If everything looks good, say so and move on
