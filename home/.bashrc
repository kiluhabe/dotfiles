# path
if [[ $(uname -a) =~ ^Darwin ]]; then
   export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
fi
export PATH=$HOME/.local/bin:$HOME/bin:$PATH

#prompt
unset PROMPT_COMMAND
PS1="\$(prompt) "

# direnv
if [ -d "$(which direnv 2>/dev/null)" ]; then
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

# global npm module
if [ -d "$(which npm 2>/dev/null)" ]; then
    export PATH=$PATH:$(npm bin -g)
fi

# The next line enables shell command completion for gcloud.
if [ -d $HOME/google-cloud-sdk/bin ]; then
  export PATH=$PATH:$HOME/google-cloud-sdk/bin
fi

export EDITOR=emacs

# go
export GOPATH=$HOME/.go

# rust
export CARGO_HOME=$HOME/.cargo
export RUSTUP_HOME=$HOME/.rustup
export RUST_SRC_PATH=$(rustc --print sysroot 2> /dev/null)/lib/rustlib/src/rust/src
export PATH=$PATH:$CARGO_HOME/bin

#aliases
alias es="emacs"
