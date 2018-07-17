#!/bin/bash

_terminal_program() {
    if [ "$TERM_PROGRAM" = "iTerm.app" ]; then
        echo "iterm2"
    elif [ -e "$(which w3m 2>/dev/null)" ]; then
        echo "w3m"
    else
        echo "none"
    fi
}

_wallpaper() {
    if [ ! -d $HOME/wallpapers ] || [ -z "$(ls -A $HOME/wallpapers)" ]; then
        return 0
    fi
    images=()
    for image in $(find $HOME/wallpapers -name '*.jpg' -o -name '*.jpeg' -o -name '*.png'); do
        images+=($image)
    done
    echo ${images[RANDOM % ${#images[@]}]}
}

_set_colorscheme() {
    if [ -z "$(which wal 2>/dev/null)" ] || [ -z $1 ]; then
        return 0
    fi
    wal -i $1
}

_copy_wallpaper() {
    if [ ! -d $HOME/wallpapers ]; then
        mkdir $HOME/wallpapers
    fi
    if [ ! -z "$(ls -A $HOME/wallpapers)" ]; then
        return 0
    fi

    cp $HOME/.dotfiles/wallpapers/* $HOME/wallpapers/
}

login_message() {
    if [ -z "$(which neofetch 2>/dev/null)" ] || [ ! -z $TMUX ]; then
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
    eval "neofetch --$terminal_program $wallpaper --crop_mode fit"
    echo ""
    echo ""
}
