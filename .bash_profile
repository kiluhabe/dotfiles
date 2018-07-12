test -r ~/.bashrc && . ~/.bashrc

# direnv
type direnv > /dev/null
if [ 0 = $? ]; then
   eval "$(direnv hook bash)"
fi

# set LOCAL
export LANG=ja_JP.UTF-8
export LC_ALL=$LANG

# rbenv setup
if [ -d $HOME/.rbenv ]; then
  export RBENV_ROOT=$HOME/.rbenv
  export PATH=$PATH:$RBENV_ROOT/bin:$RBENV_ROOT/shims
  rbenv rehash >/dev/null
  eval "$(rbenv init -)"
fi

# pyenv setup
if [ -d $HOME/.pyenv ]; then
  export PYENV_ROOT=$HOME/.pyenv
  export PATH=$PATH:$PYENV_ROOT/bin:$PYENV_ROOT/shims
  pyenv rehash >/dev/null
  eval "$(pyenv init -)"
fi

#node
if [ -d $HOME/.nodenv ]; then
  export NODENV_ROOT=$HOME/.nodenv
  export PATH=$PATH:$NODENV_ROOT/bin:$NODENV_ROOT/shims
  nodenv rehash >/dev/null
  eval "$(nodenv init -)"
fi

# The next line enables shell command completion for gcloud.
if [ -d $HOME/google-cloud-sdk/bin ]; then
  export PATH=$PATH:$HOME/google-cloud-sdk/bin
fi

#rust path
if [ -d $HOME/.cargo ] && [ -d $HOME/.rustup ]; then
  export CARGO_HOME=$HOME/.cargo
  export RUSTUP_HOME=$HOME/.rustup
  export RUST_SRC_PATH=$HOME/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src
  export PATH=$PATH:$CARGO_HOME/bin
fi

if [ -d $HOME/.emacs/bin ]; then
  export PATH=$PATH:$HOME/.emacs/bin
  export EDITOR=$HOME/.emacs/bin
else
  export EDITOR=emacs
fi

# homebrew
if [[ $(uname -a) =~ ^Darwin ]]; then
   export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.local/bin
fi
