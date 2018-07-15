#! /bin/sh

run_conky() {
    echo '{"version":1}'
    echo '[[],'
    exec conky -c $HOME/.config/i3/i3bar-conkyrc
}
