#!/bin/bash

brew tap mopidy/mopidy
brew install mopidy
brew install mopidy-spotify ncmpcpp
brew reinstall gst-python --without-python --with-python@2
