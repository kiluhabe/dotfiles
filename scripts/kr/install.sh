#!/bin/bash

_check_dependencies () {
    if [ ! -e "$(which cargo 2>/dev/null)" ]; then
        echo "kr needs cargo"
        echo "run: curl https://sh.rustup.rs -sSf | sh"
        return 1
    fi
    if [ ! -e "$(which cargo-web 2>/dev/null)" ]; then
        echo "kr needs cargo-web"
        return 1
    fi
    if [ ! -e "$(which go 2>/dev/null)" ]; then
        echo "kr needs go"
        return 1
    fi
    if [ ! -e "$GOPATH" ]; then
        echo "please set GOPATH"
        return 1
    fi
    if [ ! -e "$(which node 2>/dev/null)" ]; then
        echo "kr needs node"
        return 1
    fi
    if [ ! -e "$(which rsync 2>/dev/null)" ]; then
        echo "kr needs rsync"
        return 1
    fi
}

main () {
    if [ ! _check_dependencies ]; then
        return 1
    fi

    go get github.com/kryptco/kr
    cd $GOPATH/src/github.com/kryptco/kr
    git submodule update --init --recursive
    make

    make install
    make start
    kr pair
}
