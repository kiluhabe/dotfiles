function dotcheck
  set dotfiles_dir $HOME/.dotfiles/.git

  if test ! -d $dotfiles_dir
    return 1
  end

  if test -z (which git)
    return 1
  end

  set remote_newest_commit ( git --git-dir=$dotfiles_dir ls-remote origin master 2> /dev/null | cut -f1 )

  if test $status -ne 0
    return 1
  end

  set local_newest_commit ( git --git-dir=$dotfiles_dir log -1 master 2> /dev/null | sed -n 1p | cut -d' ' -f2 )

  if test $status -ne 0
    return 1
  end

  if test \( -z $remote_newest_commit \) -o \( -z $local_newest_commit \)
    return 1
  end

  if test $remote_newest_commit != $local_newest_commit
    echo "the new version of dotfiles is available."
    return 1
  end

  echo "dotfiles are latest."
  return 0
end
