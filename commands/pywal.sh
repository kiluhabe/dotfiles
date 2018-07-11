#!/bin/bash

setup_pywal() {
    # add this configuration to ~/.bashrc
    export HH_CONFIG=hicolor         # get more colors
    shopt -s histappend              # append new history items to .bash_history
    export HISTCONTROL=ignorespace   # leading space hides commands from history
    export HISTFILESIZE=10000        # increase history file size (default is 500)
    export HISTSIZE=${HISTFILESIZE}  # increase history size (default is 500)
    export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"   # mem/file sync
    # if this is interactive shell, then bind hh to Ctrl-r (for Vi mode check doc)
    if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hh -- \C-j"'; fi
    # if this is interactive shell, then bind 'kill last command' to Ctrl-x k
    if [[ $- =~ .*i.* ]]; then bind '"\C-xk": "\C-a hh -k \C-j"'; fi
    if [ -d ~/.cache/wal ]; then
        # Import colorscheme from 'wal' asynchronously
        # &   # Run the process in the background.
        # ( ) # Hide shell job control messages.
        (cat ~/.cache/wal/sequences &)
        # Alternative (blocks terminal for 0-3ms)
        cat ~/.cache/wal/sequences
        # To add support for TTYs this line can be optionally added.
        source ~/.cache/wal/colors-tty.sh
    fi
}
