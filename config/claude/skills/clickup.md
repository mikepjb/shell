---
name: clickup
description: Integrate with ClickUp to list tasks, create planning docs, and update acceptance criteria checkboxes. Helps manage development workflow by pulling tasks from ClickUp boards and tracking progress.
---

# ClickUp Skill

Integrate with ClickUp to pull tasks, create planning documents, and track acceptance criteria completion.

## Setup

Required environment variables:
- `CLICKUP_API_TOKEN` - Your personal API token from ClickUp settings
- `CLICKUP_TEAM_ID` - Your workspace/team ID (first number in ClickUp URL, e.g., `2658768`)
- `CLICKUP_LIST_ID` - Your list/board ID (full ID from ClickUp URL after `/v/b/`, e.g., `X-XXXXXXXXXXX-X`)

Optional environment variables:
- `CLICKUP_SPACE_ID` - If set, can browse tasks across spaces instead of a specific list

## Process

### 1. List Tasks

Fetch tasks from ClickUp and let the user select which one to work on.

**API Call**:
```bash
# Get tasks from a list
curl -H "Authorization: $CLICKUP_API_TOKEN" \
  "https://api.clickup.com/api/v2/list/{list_id}/task?archived=false&page=0"

# Or get tasks from a space (across all lists)
curl -H "Authorization: $CLICKUP_API_TOKEN" \
  "https://api.clickup.com/api/v2/space/{space_id}/task?archived=false&page=0"
```

**Display Format**:
Present tasks to user with:
- Task ID and name
- Priority (flag tasks with priority 1=urgent or 2=high)
- Due date (only mention if overdue)
- Status
- Assignees (mention but not critical for selection)
- URL link

**Priority Detection**:
- Check `priority.id`: 1=urgent, 2=high (flag these)
- Check `due_date`: Only warn if overdue (rare but important)
- Look for priority keywords in task name or description

### 2. Create Planning Document

Once user selects a task, create `./docs/{task-id}-plan.md` with task details.

**API Call**:
```bash
# Get full task details including custom fields and checklists
curl -H "Authorization: $CLICKUP_API_TOKEN" \
  "https://api.clickup.com/api/v2/task/{task_id}?include_subtasks=true"
```

**Parse Task Format**:
The task description should contain:
- **Context**: Background and problem statement
- **Solution**: Proposed approach
- **Acceptance Criteria (AC)**: Checklist items

**Document Template**:
```markdown
# {task-name}

**ClickUp Task**: {task-url}
**Status**: {status}
**Priority**: {priority}

## Context

{parsed from task description}

## Solution

{parsed from task description}

## Acceptance Criteria

{parsed from task checklists - convert to markdown checkboxes}

## Notes

{space for additional notes during implementation}
```

If task description doesn't have clear Context/Solution/AC sections, include the full description as-is and let the user organize it.

### 3. Update AC Checkboxes

Mark acceptance criteria as complete in ClickUp when work is done.

**Find Checklists**:
Task checklists are in the `checklists` array of the task response. Each checklist has items with:
- `id` - The checklist item ID
- `name` - The AC text
- `resolved` - Boolean for completion status
- `parent` - The checklist ID

**API Call**:
```bash
# Mark a checklist item as resolved
curl -X PUT \
  -H "Authorization: $CLICKUP_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"resolved": true}' \
  "https://api.clickup.com/api/v2/checklist/{checklist_id}/checklist_item/{checklist_item_id}"
```

**Process**:
1. Fetch current task details
2. Find matching checklist items (by name/text)
3. Update each item to `resolved: true`
4. Confirm updates to user

**Warnings**:
- If no checklists are found in the task, warn the user - this means there are no formal ACs to track, which shouldn't happen for normal development tasks.
- If multiple checklists are found, warn the user - there should only be one checklist for acceptance criteria.

## Navigation

If you need to discover IDs:

**Get Workspaces/Teams**:
```bash
curl -H "Authorization: $CLICKUP_API_TOKEN" \
  "https://api.clickup.com/api/v2/team"
```

**Get Spaces** (given team ID):
```bash
curl -H "Authorization: $CLICKUP_API_TOKEN" \
  "https://api.clickup.com/api/v2/team/{team_id}/space?archived=false"
```

**Get Lists** (given space ID):
```bash
curl -H "Authorization: $CLICKUP_API_TOKEN" \
  "https://api.clickup.com/api/v2/space/{space_id}/list?archived=false"
```

## API Response Examples

**Task Object** (key fields):
```json
{
  "id": "abc123",
  "name": "Implement feature X",
  "description": "Context: ...\n\nSolution: ...\n\nAC: ...",
  "status": {
    "status": "in progress",
    "type": "open"
  },
  "priority": {
    "id": "2",
    "priority": "high",
    "color": "#ffcc00"
  },
  "due_date": "1641024000000",
  "url": "https://app.clickup.com/t/abc123",
  "assignees": [{"username": "john"}],
  "checklists": [
    {
      "id": "checklist_123",
      "name": "Acceptance Criteria",
      "items": [
        {
          "id": "item_456",
          "name": "User can login",
          "resolved": false
        }
      ]
    }
  ]
}
```

## Guidelines

- Always fetch fresh data - no caching
- Respect ClickUp API rate limits (100 requests/minute)
- Parse due dates from milliseconds timestamp
- Handle missing fields gracefully (not all tasks have priorities, due dates, etc.)
- `CLICKUP_API_TOKEN`, `CLICKUP_TEAM_ID`, and `CLICKUP_LIST_ID` are required - guide user to set them if missing
- Task IDs in ClickUp are alphanumeric strings, not just numbers
- The docs/ directory will be created automatically on first use - don't create it manually
- Assignees are informational only - not critical for task selection
- Due dates are rarely used - only flag if overdue
- Tasks should have exactly one checklist for acceptance criteria - warn if zero or multiple
