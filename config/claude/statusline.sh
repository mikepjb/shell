#!/bin/bash

input=$(cat)

CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size')
USAGE=$(echo "$input" | jq '.context_window.current_usage')

if [ "$USAGE" != "null" ]; then
    CURRENT_TOKENS=$(echo "$USAGE" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
    PERCENT_USED=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))

    # Color code based on usage
    if [ "$PERCENT_USED" -lt 50 ]; then
        COLOR="green"
    elif [ "$PERCENT_USED" -lt 80 ]; then
        COLOR="yellow"
    else
        COLOR="red"
    fi

    echo "Context: ${PERCENT_USED}%"
else
    echo "Context: 0%"
fi
