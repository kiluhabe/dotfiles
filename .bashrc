#commands
for command in $(find $HOME/.dotfiles/commands/*.sh); do
    source $command
done

#prompt
prompt

#login message
login_message

#aliases
alias es="emacs"

#pywal
setup_pywal
