#!/bin/bash

# Concise fuzzy finder using standard Unix tools
# Usage: ./fuzzy_finder.sh < input_file

fuzzy_finder() {
    local input_file=$(mktemp)
    local query=""
    local selected=0
    local max_display=10
    
    # Store input in temp file
    cat > "$input_file"
    
    # Terminal setup
    exec < /dev/tty
    stty -echo
    tput civis
    
    cleanup() {
        stty echo
        tput cnorm
        rm -f "$input_file"
        tput cup $(tput lines) 0
    }
    trap cleanup EXIT
    
    while true; do
        tput clear
        tput cup 0 0
        echo "Query: $query"
        echo "---"
        
        # Generate fuzzy grep pattern and get results
        local results=()
        if [ -n "$query" ]; then
            # Convert "abc" to "a.*b.*c" for fuzzy matching
            local pattern=$(echo "$query" | sed 's/./&.*/g' | sed 's/\.\*$//')
            mapfile -t results < <(grep -i "$pattern" "$input_file" | head -n "$max_display")
        else
            mapfile -t results < <(head -n "$max_display" "$input_file")
        fi
        
        # Display results
        for i in "${!results[@]}"; do
            if [ $i -eq $selected ]; then
                echo "> ${results[$i]}"
            else
                echo "  ${results[$i]}"
            fi
        done
        
        [ ${#results[@]} -eq 0 ] && echo "No matches"
        
        # Handle input
        read -n1 -s key
        case "$key" in
            $'\n'|$'\r') 
                [ ${#results[@]} -gt 0 ] && echo "${results[$selected]}"
                break ;;
            $'\x7f'|$'\b') 
                query="${query%?}"
                selected=0 ;;
            $'\x1b') 
                read -n2 -s key2
                case "$key2" in
                    '[A') [ $selected -gt 0 ] && ((selected--)) ;;
                    '[B') [ $selected -lt $((${#results[@]} - 1)) ] && ((selected++)) ;;
                esac ;;
            $'\x03') break ;;
            *) [[ "$key" =~ [[:print:]] ]] && { query+="$key"; selected=0; } ;;
        esac
    done
}

fuzzy_finder
