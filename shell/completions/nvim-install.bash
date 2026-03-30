#!/usr/bin/env bash
# Bash completion for nvim-install

_nvim_install_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-v --verbose -s --from-source -h --help"

    # Complete with available options
    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
        return 0
    fi
}

complete -F _nvim_install_completion nvim-install
