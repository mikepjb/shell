# Claude Instructions

## Workflow: Hybrid Skills + Subagent

### Flow: Analyze → Plan → [Implement] ↔ Review

| Stage | Type | Context |
|-------|------|---------|
| Analyze | skill | Main (fast, retains history) |
| Plan | skill | Main (fast, retains history) |
| Implement | **subagent** | Isolated (heavy lifting) |
| Review | skill | Main (sees implement output) |

### Stage Details

**Analyze** (skill - main context)
Use the `analyze` skill to gather context. Output stays in conversation for planning.

**Plan** (skill - main context)
Use the `plan` skill. ALWAYS wait for user approval before proceeding.

**Implement** (subagent - isolated)
Spawn the `implement` agent for code changes. Pass:
- The approved plan
- Key file:line references from analyze
- Any constraints from user

The agent works in isolation, returns summary of changes.

**Review** (skill - main context)
Use the `review` skill on the implement agent's output. If changes needed:
- Pass feedback back to implement agent (resume with agent ID)
- Iterate until review passes

### Why This Split

- **Analyze/Plan/Review in main**: Fast, low-latency, benefits from conversation history
- **Implement isolated**: Generates lots of tool calls and output that would pollute main context

### Rules

- Never skip analyze for non-trivial tasks
- Never proceed from plan to implement without user approval
- When spawning implement, include full context (it starts fresh)
- Resume implement agent with its ID when iterating with review
