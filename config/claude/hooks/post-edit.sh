#!/bin/bash
# Post-edit hook: run project linter after Edit/Write
# Exit 0 = success, Exit 2 = blocking error (fed back to Claude)
#
# Priority:
# 1. make lint (if Makefile has lint target)
# 2. npm run lint (if package.json has lint script)
# 3. deno task lint (if deno.json has lint task)

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# Check for make lint
if [[ -f "Makefile" ]] && grep -q '^lint:' Makefile 2>/dev/null; then
    if ! make lint >&2; then
        exit 2
    fi
    exit 0
fi

# Check for npm run lint
if [[ -f "package.json" ]] && grep -q '"lint"' package.json 2>/dev/null; then
    if ! npm run lint >&2; then
        exit 2
    fi
    exit 0
fi

# Check for deno task lint
if [[ -f "deno.json" ]] && grep -q '"lint"' deno.json 2>/dev/null; then
    if ! deno task lint >&2; then
        exit 2
    fi
    exit 0
fi

exit 0
