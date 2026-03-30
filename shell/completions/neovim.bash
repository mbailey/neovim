#!/usr/bin/env bash
# Bash completion for neovim command
# Uses Click's built-in completion support

_neovim_completion() {
    local IFS=$'\n'
    local response

    # Set up Click completion environment
    response=$(env COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   _NEOVIM_COMPLETE=bash_complete \
                   neovim 2>/dev/null)

    # Parse response and add to completion reply
    for completion in $response; do
        # Click returns completions in "type,value" format
        IFS=',' read -r type value <<< "$completion"

        case "$type" in
            plain)
                COMPREPLY+=("$value")
                ;;
            file)
                # File completion
                COMPREPLY+=("$value")
                ;;
            dir)
                # Directory completion
                COMPREPLY+=("$value")
                ;;
        esac
    done
}

complete -F _neovim_completion neovim
