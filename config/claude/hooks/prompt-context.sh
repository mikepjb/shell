#!/bin/bash
# UserPromptSubmit hook: Add context based on prompt content
# - Detects implementation requests → adds workflow reminder
# - Detects UI/UX topics → adds ui-design principles
#
# Exit 0 with JSON output to add context to the conversation

set -euo pipefail

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]')

if [[ -z "$PROMPT" ]]; then
    exit 0
fi

CONTEXT=""

# Detect implementation requests (non-trivial work)
# Keywords that suggest code changes are needed
IMPL_PATTERNS="implement|add a|create a|build a|write a|make a|set up|fix the|refactor|update the|change the|modify|integrate|add support|new feature|add feature"

if echo "$PROMPT" | grep -qE "$IMPL_PATTERNS"; then
    CONTEXT+="WORKFLOW REMINDER: For non-trivial implementation work, follow the workflow:
1. ANALYZE first - gather context, understand the codebase
2. PLAN with specifics - file:line references, wait for user approval
3. IMPLEMENT only after plan is approved
4. REVIEW when complete - verify tests pass, check for issues

Do NOT skip steps. Do NOT implement without explicit plan approval.

"
fi

# Detect UI/UX topics
UI_PATTERNS="ui|ux|user interface|frontend|front-end|component|page|form|button|modal|layout|design|style|css|html|template|view|screen|dashboard|widget"

if echo "$PROMPT" | grep -qE "$UI_PATTERNS"; then
    CONTEXT+="UI DESIGN PRINCIPLES:
- Function over form: every element earns its place by doing something useful
- Obvious affordances: users should never guess what's clickable
- Information density: show what matters, hide what doesn't
- Use semantic HTML, HTMX for server updates, Alpine.js for client state
- No decorative CSS: no rounded corners everywhere, no drop shadows, no gradients
- System font stack, minimal color palette (1-2 colors for meaning, grays for everything else)
- Tables for data, visible focus states, clear disabled states
- Anti-patterns to avoid: icons without labels, hamburger menus when space exists, modals for simple actions, skeleton loaders, animations that delay interaction

"
fi

# Output context if we have any
if [[ -n "$CONTEXT" ]]; then
    # Escape for JSON
    ESCAPED=$(echo "$CONTEXT" | jq -Rs .)
    echo "{\"hookSpecificOutput\": {\"hookEventName\": \"UserPromptSubmit\", \"additionalContext\": $ESCAPED}}"
fi

exit 0
