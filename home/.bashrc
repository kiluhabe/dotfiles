#prompt
unset PROMPT_COMMAND
source $HOME/.dotfiles/prompt.sh
export PS1=$(prompt)

#aliases
alias es="emacs"

#pywal
if [ -e "$(which setup_pywal 2>/dev/null)" ]; then
    setup_pywal
fi
