# Claude Instructions

## Workflow: Skills-Based Development

Follow this sequential workflow for all development tasks:

### 1. Analyze → 2. Plan → 3. Implement ↔ Review

| Stage | Skill | Purpose |
|-------|-------|---------|
| 1 | `analyze` | Gather context from codebase, web if needed |
| 2 | `plan` | Output markdown plan for user approval |
| 3 | `implement` | Make changes, iterate with review |
| 4 | `review` | Validate changes, provide summary |

### Stage Details

**Analyze**: Collects relevant context before any planning. Outputs concise markdown summary of findings with file:line references.

**Plan**: Produces a clear plan specifying exact files and line ranges to modify. ALWAYS wait for user approval before proceeding to implement.

**Implement**: Executes the approved plan. For UI work, use the `ui-design` skill. Passes changes to review automatically.

**Review**: Validates changes and iterates with implement until satisfied. Final output includes:
- Summary of changes made
- Test coverage status
- Manual testing instructions

### Rules

- Never skip the analyze stage for non-trivial tasks
- Never proceed from plan to implement without user approval
- Implement and review iterate until review is satisfied
- All tests must pass before review signs off
