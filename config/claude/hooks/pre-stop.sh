#!/bin/bash
# Pre-stop hook: verify tests pass before Claude finishes
# Exit 0 = allow stop, Exit 2 = block stop (Claude must continue)

set -euo pipefail

INPUT=$(cat)

# Check if any CODE files changed (skip .md, .txt, etc)
CODE_EXTS='\.(go|js|ts|tsx|jsx|py|rs|c|cpp|h|hpp|java|rb|sh|sql|css|scss|html|vue|svelte)$'
CHANGED_CODE=$(git diff --name-only HEAD 2>/dev/null; git diff --cached --name-only HEAD 2>/dev/null)
CHANGED_CODE=$(echo "$CHANGED_CODE" | grep -E "$CODE_EXTS" || true)

if [[ -n "$CHANGED_CODE" ]]; then
    # There are changes - we should verify tests pass

    # Detect test command
    TEST_CMD=""

    if [[ -f "Makefile" ]] && grep -q "^test:" Makefile 2>/dev/null; then
        TEST_CMD="make test"
    elif [[ -f "package.json" ]] && grep -q '"test"' package.json 2>/dev/null; then
        TEST_CMD="npm test"
    elif [[ -f "go.mod" ]]; then
        TEST_CMD="go test ./..."
    elif [[ -f "Cargo.toml" ]]; then
        TEST_CMD="cargo test"
    elif [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        if command -v pytest &>/dev/null; then
            TEST_CMD="pytest"
        fi
    fi

    if [[ -n "$TEST_CMD" ]]; then
        echo "Running tests before stop: $TEST_CMD" >&2
        if ! $TEST_CMD 2>&1; then
            echo "Tests failed. Please fix before completing." >&2
            exit 2
        fi
    fi
fi

exit 0
