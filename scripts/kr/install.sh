#!/bin/bash

_check_dependencies () {
    if [ ! -e "$(which cargo 2>/dev/null)" ]; then
        echo "kr needs cargo"
        echo "run: curl https://sh.rustup.rs -sSf | sh"
    fi
    if [ ! -e "$(which cargo-web 2>/dev/null)" ]; then
        echo "kr needs cargo-web"
    fi
    if [ ! -e "$(which go 2>/dev/null)" ]; then
        echo "kr needs go"
    fi
    if [ ! -e "$GOPATH" ]; then
        echo "please set GOPATH"
    fi
    if [ ! -e "$(which node 2>/dev/null)" ]; then
        echo "kr needs node"
    fi
    if [ ! -e "$(which rsync 2>/dev/null)" ]; then
        echo "kr needs rsync"
    fi
}

main () {
    if [ ! -n _check_dependencies ]; then
        _check_dependencies
        return 1
    fi

    go get github.com/kryptco/kr
    cd $GOPATH/src/github.com/kryptco/kr
    git submodule update --init --recursive
    make

    make install
    make start
}

main
