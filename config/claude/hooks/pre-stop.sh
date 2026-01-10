#!/bin/bash
# Pre-stop hook: verify tests pass before Claude finishes
# Exit 0 = allow stop, Exit 2 = block stop (Claude must continue)

set -euo pipefail

INPUT=$(cat)

# Check if we have uncommitted changes (meaning work was done)
if ! git diff --quiet HEAD 2>/dev/null && ! git diff --cached --quiet HEAD 2>/dev/null; then
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
