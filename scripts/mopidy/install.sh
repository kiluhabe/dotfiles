#!/bin/bash

brew tap mopidy/mopidy
brew install mopidy
brew reinstall gst-python --without-python --with-python@2
brew install mopidy-spotify ncmpcpp
