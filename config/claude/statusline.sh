#!/bin/bash

input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
EXCEEDS=$(echo "$input" | jq -r '.exceeds_200k_tokens')
TRANSCRIPT=$(echo "$input" | jq -r '.transcript_path')

# Get current folder name
FOLDER=$(basename "$PWD")

# Get git branch if in a git repo
BRANCH=$(git branch --show-current 2>/dev/null)
if [ -n "$BRANCH" ]; then
    GIT_INFO=" ($BRANCH)"
else
    GIT_INFO=""
fi

# Model-specific context window sizes (in tokens)
case "$MODEL" in
    *"Sonnet"*|*"sonnet"*)
        MAX_CONTEXT=200000
        ;;
    *"Opus"*|*"opus"*)
        MAX_CONTEXT=200000
        ;;
    *"Haiku"*|*"haiku"*)
        MAX_CONTEXT=200000
        ;;
    *)
        MAX_CONTEXT=200000
        ;;
esac

# Check if context_window field exists (newer versions)
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // null')

if [ "$CONTEXT_SIZE" != "null" ]; then
    # Use context_window data if available
    USAGE=$(echo "$input" | jq '.context_window.current_usage')
    if [ "$USAGE" != "null" ]; then
        CURRENT_TOKENS=$(echo "$USAGE" | jq '.input_tokens + .output_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
        PERCENT_USED=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
        echo "[$FOLDER$GIT_INFO] [$MODEL] Context: ${PERCENT_USED}%"
    else
        echo "[$FOLDER$GIT_INFO] [$MODEL] Context: 0%"
    fi
else
    # Calculate from transcript JSONL file if available
    if [ -f "$TRANSCRIPT" ]; then
        # Find the most recent main-chain entry with usage data
        # Filter out sidechain agents, errors, and entries without usage
        USAGE_LINE=$(tac "$TRANSCRIPT" 2>/dev/null | while read -r line; do
            # Skip empty lines
            [ -z "$line" ] && continue
            # Check if line has usage data and is not a sidechain/error
            has_usage=$(echo "$line" | jq -r 'select(.usage != null) | select(.isSidechain != true) | select(.error == null) | .usage' 2>/dev/null)
            if [ -n "$has_usage" ] && [ "$has_usage" != "null" ]; then
                echo "$line"
                break
            fi
        done)

        if [ -n "$USAGE_LINE" ]; then
            # Extract actual token counts from usage object
            INPUT_TOKENS=$(echo "$USAGE_LINE" | jq -r '.usage.input_tokens // 0')
            CACHE_READ=$(echo "$USAGE_LINE" | jq -r '.usage.cache_read_input_tokens // 0')
            CACHE_CREATE=$(echo "$USAGE_LINE" | jq -r '.usage.cache_creation_input_tokens // 0')

            CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_READ + CACHE_CREATE))
            PERCENT_USED=$((CURRENT_TOKENS * 100 / MAX_CONTEXT))

            # Cap at 100% for display purposes
            if [ $PERCENT_USED -gt 100 ]; then
                PERCENT_USED=100
            fi

            echo "[$FOLDER$GIT_INFO] [$MODEL] Context: ${PERCENT_USED}%"
        else
            echo "[$FOLDER$GIT_INFO] [$MODEL] Context: 0%"
        fi
    else
        # Final fallback: use exceeds_200k_tokens flag
        if [ "$EXCEEDS" == "true" ]; then
            echo "[$FOLDER$GIT_INFO] [$MODEL] Context: >90%"
        else
            echo "[$FOLDER$GIT_INFO] [$MODEL]"
        fi
    fi
fi
