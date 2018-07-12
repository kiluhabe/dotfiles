#!/bin/bash

_terminal_program() {
    if [ $TERM_PROGRAM = "iTerm.app" ]; then
        echo "iterm2"
    else
        return 0
    fi
}

_wallpaper() {
    if [ ! -d $HOME/.wallpapers ] || [ -z "$(ls -A $HOME/.wallpapers)" ]; then
        return 0
    fi
    images=()
    for image in $(find $HOME/.wallpapers -name '*.jpg' -o -name '*.jpeg' -o -name '*.png'); do
        images+=($image)
    done
    echo ${images[RANDOM % ${#images[@]}]}
}

_set_colorscheme() {
    if [ -z $(which wal) ] || [ -z $1 ]; then
        return 0
    fi
    wal -i $1
}

_copy_wallpaper() {
    if [ ! -d $HOME/.wallpapers ]; then
        mkdir $HOME/.wallpapers
    fi
    if [ ! -z "$(ls -A $HOME/.wallpapers)" ]; then
        return 0
    fi

    cp $HOME/.dotfiles/.wallpapers/* $HOME/.wallpapers/
}

login_message() {
    if [ -z $(which neofetch) ] || [ ! -z $TMUX ]; then
        return 0
    fi

    _copy_wallpaper
    terminal_program=$(_terminal_program)
    wallpaper=$(_wallpaper)

    if [ -z $terminal_program ] && [ -z $wallpaper ]; then
        neofetch
        return 0
    fi

    _set_colorscheme $wallpaper
    eval "neofetch --$(_terminal_program) $(_wallpaper) --size 50%"
    echo ""
    echo ""
}
