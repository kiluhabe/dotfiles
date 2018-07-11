#!/bin/bash

fixssh() {
  if [ -z {$TMUX+x} ]; then
    export SSH_AUTH_SOCK=$(tmux show-environment | grep '^SSH_AUTH_SOCK' | cut -d'=' -f2)
    echo "SSH_AUTH_SOCK has been fixed."
    return 0
  fi

  echo "you are not running on tmux."
  return 1
}
