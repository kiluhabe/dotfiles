#!/bin/bash

if ! [[ $(uname -a) =~ ^Darwin ]]; then
    ln -s ~/.dotfiles/.xinitrc  ~/.xinitrc
    ln -s ~/.dotfiles/i3 ~/.config/i3
    ln -s ~/.dotfiles/.Xresources ~/.Xresources
fi

ln -s ~/.dotfiles/.bashrc ~/.bashrc
ln -s ~/.dotfiles/.bash_profile ~/.bash_profile
ln -s ~/.dotfiles/.emacs.d/ ~
ln -s ~/.dotfiles/.tmux/.tmux.conf.local  ~/.tmux.conf.local
ln -s ~/.dotfiles/.tmux/.tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/.gitignore_global ~/.gitignore_global
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
