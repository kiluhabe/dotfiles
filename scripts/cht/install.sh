#!/bin/bash

main () {
    if [ -e "$(which cht 2>/dev/null)" ]; then
        return 0
    fi

    curl https://cht.sh/:cht.sh > $HOME/.local/bin/cht
    chmod +x $HOME/.local/bin/cht
}

main
