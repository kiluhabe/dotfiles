#!/bin/bash
if [ -d $(which brew 2>/dev/null) ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew install cask docker-compose neofetch imagemagick fzf tmux emacs direnv yarn bash translate-shell
brew cask install firefox google-chrome iterm2 docker visual-studio-code google-japanese-ime notion pd dropbox postman clipy

brew tap httpu/httpu
brew install httpu
