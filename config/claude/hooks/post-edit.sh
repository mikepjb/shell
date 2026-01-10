#!/bin/bash
# Post-edit hook: format and lint files after Edit/Write
# Exit 0 = success, Exit 2 = blocking error (fed back to Claude)

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract file path from tool_input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
    exit 0  # No file to process
fi

# Get file extension
EXT="${FILE_PATH##*.}"

ERRORS=""

# Format based on file type
case "$EXT" in
    go)
        if command -v gofmt &>/dev/null; then
            gofmt -w "$FILE_PATH" 2>/dev/null || true
        fi
        # Run go vet if in a go module
        if [[ -f "go.mod" ]] && command -v go &>/dev/null; then
            VET_OUTPUT=$(go vet "$FILE_PATH" 2>&1) || ERRORS+="$VET_OUTPUT"$'\n'
        fi
        ;;
    ts|tsx|js|jsx|json)
        # Try prettier if available
        if command -v npx &>/dev/null && [[ -f "node_modules/.bin/prettier" ]]; then
            npx prettier --write "$FILE_PATH" 2>/dev/null || true
        fi
        # Run eslint if available
        if command -v npx &>/dev/null && [[ -f "node_modules/.bin/eslint" ]]; then
            LINT_OUTPUT=$(npx eslint "$FILE_PATH" 2>&1) || ERRORS+="$LINT_OUTPUT"$'\n'
        fi
        ;;
    py)
        # Format with black if available
        if command -v black &>/dev/null; then
            black -q "$FILE_PATH" 2>/dev/null || true
        fi
        # Run ruff or flake8
        if command -v ruff &>/dev/null; then
            LINT_OUTPUT=$(ruff check "$FILE_PATH" 2>&1) || ERRORS+="$LINT_OUTPUT"$'\n'
        elif command -v flake8 &>/dev/null; then
            LINT_OUTPUT=$(flake8 "$FILE_PATH" 2>&1) || ERRORS+="$LINT_OUTPUT"$'\n'
        fi
        ;;
    rs)
        if command -v rustfmt &>/dev/null; then
            rustfmt "$FILE_PATH" 2>/dev/null || true
        fi
        ;;
esac

# If there were lint errors, report them back to Claude
if [[ -n "$ERRORS" ]]; then
    echo "Lint errors in $FILE_PATH:" >&2
    echo "$ERRORS" >&2
    exit 2
fi

exit 0
