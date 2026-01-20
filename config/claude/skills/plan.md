---
name: plan
description: Create detailed implementation plans after analysis. Use this skill to propose specific changes with exact file paths and line numbers. Plans require user approval before implementation proceeds.
---

# Plan Skill

Create clear, actionable implementation plans based on analysis output.

## Process

1. **Review analysis**: Understand the gathered context
2. **Design approach**: Choose the simplest solution that works
3. **Specify changes**: List exact files and line ranges to modify
4. **Identify risks**: Note anything that could go wrong
5. **Present for approval**: Wait for user to approve before proceeding
6. **Write plan file**:
   - Generate a task-specific filename: `<task-name>_PLAN.md` (e.g., `add-auth_PLAN.md`, `fix-login-bug_PLAN.md`)
   - Use lowercase with hyphens, derived from the task summary
   - BEFORE writing, check if the file already exists using Read tool
   - If it exists, STOP and ask the user whether to overwrite or use a different name
   - Write to `$PWD/<task-name>_PLAN.md`, NOT to `~/.claude/skills/plan/`

## Output Format

```markdown
## Implementation Plan

### Summary
One-sentence description of what will be done.

### Changes

#### 1. [Description of change]
**File**: `path/to/file.ts`
**Lines**: 45-67
**Action**: Modify/Add/Delete
**Details**: What exactly will change

#### 2. [Next change]
...

### Database Changes
- Migration needed? Yes/No
- Reversible? Yes/No
- Data backfill required? Yes/No

### API Impact
- New endpoints: `POST /api/v1/resource`
- Modified endpoints: None
- Breaking changes: None

### Test Strategy
- How changes will be verified
- Which tests cover this

### Deployment Notes
- Order of operations (migrate first? feature flag?)
- Rollback plan

### Risks
- Potential issues to watch for

### Questions (if any)
- Anything needing clarification before proceeding
```

## Web Service Considerations

### API Changes
- Is this a breaking change for existing clients?
- Does it need API versioning?
- Are request/response schemas documented?
- Will it require client updates?

### Database Migrations
- Is the migration reversible?
- Does it lock tables during execution?
- Is there a data backfill needed?
- What's the rollback strategy?

### Backwards Compatibility
- Can old and new code run simultaneously during deploy?
- Are there feature flags needed for gradual rollout?
- Do background jobs need coordination?

### Dependencies
- Are new packages/services required?
- Do environment variables need adding?
- Are there infrastructure changes?

## Guidelines

- Be specific: exact file paths, line numbers, function names
- Keep it minimal: only changes necessary for the task
- No implementation until user approves
- If multiple approaches exist, present options with trade-offs
- Flag any breaking changes or migrations needed
- IMPORTANT: Write your plan to `$PWD/<task-name>_PLAN.md` where `<task-name>` is a lowercase hyphenated version of the task (e.g., `add-user-auth_PLAN.md`)
- BEFORE writing, use Read tool to check if the file exists - if it does, ask the user before overwriting
- Never write plan files to `~/.claude/skills/plan/` - that directory is only for the skill definition itself
