#!/bin/bash

main() {
    if [ ! -z $(which pyenv) ]; then
        echo "pyenv installed."
        return 0
    fi

    git clone https://github.com/pyenv/pyenv.git ~/.pyenv
    cd pyenv/plugins/python-build && ./install.sh
    cd $HOME
}

main
