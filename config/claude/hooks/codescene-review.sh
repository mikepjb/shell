#!/bin/bash
# Post-edit hook: run CodeScene review on modified files
# This extracts the pattern from your review skill

set -euo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# Only run if cs command is available
if ! command -v cs &>/dev/null; then
    exit 0
fi

# Run CodeScene review
CS_OUTPUT=$(cs review "$FILE_PATH" 2>&1) || true

# CodeScene findings are warnings, not blockers (per your review skill)
# Output as additional context if there are issues
if [[ -n "$CS_OUTPUT" && "$CS_OUTPUT" != *"No issues"* ]]; then
    # Return as JSON with additional context
    echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PostToolUse\", \"additionalContext\": \"CodeScene review: $CS_OUTPUT\"}}"
fi

exit 0
