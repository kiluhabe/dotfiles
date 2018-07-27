#!/bin/bash

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install cask
brew cask install firefox firefox-developer-edition google-chrome 1password6 slack iterm2 docker docker-compose visual-studio-code google-japanese-ime notion pd dropbox postman
