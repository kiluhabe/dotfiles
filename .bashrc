#commands
for command in $(find $HOME/.dotfiles/commands/*.sh); do
    source $command
done

#prompt
prompt

#aliases
alias es="emacs"

#pywal
setup_pywal
