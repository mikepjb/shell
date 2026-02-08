#!/bin/bash
# Pre-stop hook: review code quality and verify tests pass before Claude finishes
# Returns JSON decision to block Claude if linting or tests fail
# Uses stop_hook_active flag to prevent infinite loops
#
# Logic:
# 1. Check if already running (stop_hook_active) to prevent loops
# 2. Find changed code files (go, ts, js, templ, java) via git diff
# 3. Run CodeScene review if available (blocking if issues found)
# 4. Run linting (blocking if fails)
# 5. Run unit/integration tests (blocking if fails, excludes e2e)

set -euo pipefail

INPUT=$(cat)

# Prevent infinite loops: if Claude already tried to fix and failed, let it stop
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [[ "$STOP_HOOK_ACTIVE" == "true" ]]; then
    echo "Stop hook already ran once, allowing stop to prevent infinite loop." >&2
    exit 0
fi

BLOCK_REASON=""

# Skip if this doesn't look like a code project
if [[ ! -f "Makefile" && ! -f "./gradlew" && ! -f "package.json" && ! -f "deno.json" && ! -f "go.mod" && ! -f "pom.xml" && ! -f "build.gradle" ]]; then
    # Try monorepo: search first-level subdirectories for config files
    FOUND_DIRS=()
    for dir in */; do
        if [[ -f "${dir}Makefile" || -f "${dir}go.mod" || -f "${dir}package.json" || -f "${dir}deno.json" || -f "${dir}pom.xml" || -f "${dir}build.gradle" || -f "${dir}gradlew" ]]; then
            FOUND_DIRS+=("$dir")
        fi
    done

    if [[ ${#FOUND_DIRS[@]} -gt 0 ]]; then
        echo "❌ This is a monorepo. Restart Claude from one of these directories:" >&2
        printf '  - %s\n' "${FOUND_DIRS[@]}" >&2
        jq -n '{decision: "block", reason: "Monorepo detected. Restart Claude from a sub-project directory."}'
        exit 0
    fi

    exit 0  # Not a code project, allow stop
fi

# Only these extensions trigger tests
TEST_EXTS='\.(go|ts|tsx|js|jsx|templ|java)$'

# Get changed files that should trigger tests
CHANGED_CODE=$(git diff --name-only HEAD 2>/dev/null; git diff --cached --name-only HEAD 2>/dev/null)
CHANGED_CODE=$(echo "$CHANGED_CODE" | grep -E "$TEST_EXTS" | sort -u || true)

if [[ -z "$CHANGED_CODE" ]]; then
    exit 0  # No relevant code changes
fi

echo "Changed files:" >&2
echo "$CHANGED_CODE" | sed 's/^/  /' >&2

# --- CodeScene Review (blocking if available) ---
if command -v cs &>/dev/null; then
    CS_ISSUES=""
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            OUTPUT=$(cs review "$file" 2>&1) || true
            # Check if there are actual issues (not just "No issues" or "No scorable code")
            if [[ -n "$OUTPUT" && "$OUTPUT" != *"No issues"* && "$OUTPUT" != *"No scorable code"* && "$OUTPUT" == *"🚩 Issue"* ]]; then
                CS_ISSUES+="$file:"$'\n'"$OUTPUT"$'\n'
            fi
        fi
    done <<< "$CHANGED_CODE"

    if [[ -n "$CS_ISSUES" ]]; then
        echo "CodeScene issues found (must be fixed):" >&2
        echo "$CS_ISSUES" >&2
        BLOCK_REASON="CodeScene issues found"
    fi
fi

# --- Linter (blocking on failure) ---
# Run before tests to fail fast on style issues
# Priority: make lint → npm run lint → deno task lint

if [[ -f "Makefile" ]] && grep -q '^lint:' Makefile 2>/dev/null; then
    echo "Running make lint..." >&2
    if ! make lint >&2; then
        echo "Linting failed. Claude must fix before completing." >&2
        BLOCK_REASON="Linting failed"
    fi
elif [[ -f "package.json" ]] && grep -q '"lint"' package.json 2>/dev/null; then
    echo "Running npm run lint..." >&2
    if ! npm run lint >&2; then
        echo "Linting failed. Claude must fix before completing." >&2
        BLOCK_REASON="Linting failed"
    fi
elif [[ -f "deno.json" ]] && grep -q '"lint"' deno.json 2>/dev/null; then
    echo "Running deno task lint..." >&2
    if ! deno task lint >&2; then
        echo "Linting failed. Claude must fix before completing." >&2
        BLOCK_REASON="Linting failed"
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

run_java_tests() {
    # Prefer Gradle if available
    if [[ -f "./gradlew" ]]; then
        echo "Running Gradle tests..." >&2
        ./gradlew test >&2
    elif [[ -f "pom.xml" ]] && command -v mvn &>/dev/null; then
        echo "Running Maven tests..." >&2
        mvn test >&2
    fi
}

# Detect what kind of changes we have
HAS_GO=$(echo "$CHANGED_CODE" | grep -E '\.go$' || true)
HAS_NODE=$(echo "$CHANGED_CODE" | grep -E '\.(ts|tsx|js|jsx)$' || true)
HAS_TEMPL=$(echo "$CHANGED_CODE" | grep -E '\.templ$' || true)
HAS_JAVA=$(echo "$CHANGED_CODE" | grep -E '\.java$' || true)

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

if [[ -n "$HAS_JAVA" ]]; then
    if ! run_java_tests; then
        FAILED=1
    fi
fi

if [[ $FAILED -eq 1 ]]; then
    echo "Tests failed. Claude must fix before completing." >&2
    BLOCK_REASON="Tests failed"
fi

# Return proper hook decision JSON
if [[ -n "$BLOCK_REASON" ]]; then
    jq -n --arg reason "$BLOCK_REASON" '{decision: "block", reason: $reason}'
    exit 0
else
    echo "All checks passed." >&2
    exit 0
fi
