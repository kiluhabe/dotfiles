#!/bin/bash

if [[ ! $(uname -a) =~ ^Darwin ]]; then
    echo "this script is only available on macos."
    return 1
fi
brew install mopidy
brew reinstall gst-python --without-python --with-python@2
brew install mopidy-spotify ncmpcpp
