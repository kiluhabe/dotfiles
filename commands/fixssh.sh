#!/bin/bash

fixssh() {
  export SSH_AUTH_SOCK=$(tmux show-environment | grep '^SSH_AUTH_SOCK' | cut -d'=' -f2)
  echo "SSH_AUTH_SOCK has been fixed."
  return 0
}
