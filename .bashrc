#commands
for command in $(find $HOME/.dotfiles/commands/*.sh); do
    source $command
done

#prompt
if [ $TERM != linux ]; then
    prompt
fi

#aliases
alias es="emacs"
alias mpd="ncmpcpp"

#pywal
setup_pywal
