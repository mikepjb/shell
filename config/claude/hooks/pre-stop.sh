#!/bin/bash
# Pre-stop hook: review code quality and verify tests pass before Claude finishes
# Exit 0 = allow stop, Exit 2 = block stop (Claude must continue)
#
# Logic:
# 1. Find changed code files (go, ts, js, templ only) via git diff
# 2. Run CodeScene review on each changed file (warnings only, non-blocking)
# 3. Run unit/integration tests (excludes browser/e2e tests)

set -euo pipefail

INPUT=$(cat)

# Prevent infinite loops: if Claude already tried to fix and failed, let it stop
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [[ "$STOP_HOOK_ACTIVE" == "true" ]]; then
    echo "Stop hook already ran once, allowing stop to prevent infinite loop." >&2
    exit 0
fi

# Skip if this doesn't look like a code project
if [[ ! -f "Makefile" && ! -f "./gradlew" && ! -f "package.json" && ! -f "deno.json" && ! -f "go.mod" ]]; then
    exit 0  # Not a code project, allow stop
fi

# Only these extensions trigger tests
TEST_EXTS='\.(go|ts|tsx|js|jsx|templ)$'

# Get changed files that should trigger tests
CHANGED_CODE=$(git diff --name-only HEAD 2>/dev/null; git diff --cached --name-only HEAD 2>/dev/null)
CHANGED_CODE=$(echo "$CHANGED_CODE" | grep -E "$TEST_EXTS" | sort -u || true)

if [[ -z "$CHANGED_CODE" ]]; then
    exit 0  # No relevant code changes
fi

echo "Changed files:" >&2
echo "$CHANGED_CODE" | sed 's/^/  /' >&2

# --- CodeScene Review (non-blocking, informational) ---
if command -v cs &>/dev/null; then
    CS_ISSUES=""
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            OUTPUT=$(cs review "$file" 2>&1) || true
            if [[ -n "$OUTPUT" && "$OUTPUT" != *"No issues"* ]]; then
                CS_ISSUES+="$file: $OUTPUT"$'\n'
            fi
        fi
    done <<< "$CHANGED_CODE"

    if [[ -n "$CS_ISSUES" ]]; then
        echo "CodeScene findings (warnings):" >&2
        echo "$CS_ISSUES" >&2
    fi
fi

# --- Unit/Integration Tests (blocking on failure) ---
# Excludes: e2e, browser, cypress, playwright, puppeteer tests

run_go_tests() {
    if [[ -f "go.mod" ]] && command -v go &>/dev/null; then
        echo "Running Go tests..." >&2
        # Exclude any e2e/browser directories
        go test $(go list ./... | grep -v -E '/(e2e|browser|integration)') >&2
    fi
}

run_node_tests() {
    if [[ ! -f "package.json" ]]; then
        return
    fi

    # Look for unit test script (prefer test:unit over test)
    if grep -q '"test:unit"' package.json 2>/dev/null; then
        echo "Running npm test:unit..." >&2
        npm run test:unit >&2
    elif grep -q '"vitest"' package.json 2>/dev/null; then
        # Vitest: exclude e2e/browser directories
        echo "Running vitest (excluding e2e)..." >&2
        npx vitest run --exclude '**/e2e/**' --exclude '**/browser/**' --exclude '**/cypress/**' --exclude '**/playwright/**' >&2
    elif grep -q '"jest"' package.json 2>/dev/null; then
        # Jest: exclude e2e/browser directories
        echo "Running jest (excluding e2e)..." >&2
        npx jest --testPathIgnorePatterns='e2e|browser|cypress|playwright' >&2
    elif grep -q '"test"' package.json 2>/dev/null; then
        # Check if test script looks like it runs browser tests
        TEST_SCRIPT=$(grep '"test"' package.json | head -1)
        if echo "$TEST_SCRIPT" | grep -qE 'cypress|playwright|puppeteer|e2e'; then
            echo "Skipping npm test (appears to be browser tests)" >&2
        else
            echo "Running npm test..." >&2
            npm test >&2
        fi
    fi
}

# Detect what kind of changes we have
HAS_GO=$(echo "$CHANGED_CODE" | grep -E '\.go$' || true)
HAS_NODE=$(echo "$CHANGED_CODE" | grep -E '\.(ts|tsx|js|jsx)$' || true)
HAS_TEMPL=$(echo "$CHANGED_CODE" | grep -E '\.templ$' || true)

FAILED=0

if [[ -n "$HAS_GO" || -n "$HAS_TEMPL" ]]; then
    if ! run_go_tests; then
        FAILED=1
    fi
fi

if [[ -n "$HAS_NODE" ]]; then
    if ! run_node_tests; then
        FAILED=1
    fi
fi

if [[ $FAILED -eq 1 ]]; then
    echo "Tests failed. Please fix before completing." >&2
    exit 2
fi

echo "Tests passed." >&2
exit 0
