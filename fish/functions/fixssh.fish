function fixssh
  if test -n "$TMUX"
    set -gx SSH_AUTH_SOCK (tmux show-environment | grep '^SSH_AUTH_SOCK' | cut -d'=' -f2)
    echo "SSH_AUTH_SOCK has been fixed."
    return 0
  end

  echo "you are not running on tmux."
  return 1
end
