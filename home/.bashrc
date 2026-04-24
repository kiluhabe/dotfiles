export EDITOR=nano

# path
if [[ $(uname -a) =~ ^Darwin ]]; then
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH
    export TERM=xterm-256color
    export BASH_SILENCE_DEPRECATION_WARNING=1
    export PATH="/opt/homebrew/opt/avr-gcc@8/bin:$PATH"
    export PATH="/opt/homebrew/opt/arm-none-eabi-binutils/bin:$PATH"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

#prompt
unset PROMPT_COMMAND
PROMPT_COMMAND='printf "\n"'
PS1="\$(prompt) "

# direnv
if command -v direnv &>/dev/null; then
   eval "$(direnv hook bash)"
fi

# set LOCAL
if [[ $(uname -a) =~ ^Darwin ]]; then
    export LANG="ja_JP.UTF-8"
else
    (tty|grep -Fq 'tty') && export LANG="C" || export LANG="ja_JP.UTF-8"
fi
export LC_ALL="$LANG"

# rbenv setup
if [ -d "$HOME/.rbenv" ]; then
  export RBENV_ROOT="$HOME/.rbenv"
  export PATH="$RBENV_ROOT/bin:$PATH"
  eval "$(rbenv init -)"
fi

# pyenv setup
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

#node
if [ -d "$HOME/.nodenv" ]; then
  export NODENV_ROOT="$HOME/.nodenv"
  export PATH="$NODENV_ROOT/bin:$PATH"
  eval "$(nodenv init -)"
fi

# jenv
if [ -d "$HOME/.jenv" ]; then
    export JENV_ROOT="$HOME/.jenv"
    export PATH="$JENV_ROOT/bin:$PATH"
    eval "$(jenv init -)"
fi

# tfenv
if [ -d "$HOME/.tfenv" ]; then
    export TFENV_ROOT="$HOME/.tfenv"
    export PATH="$TFENV_ROOT/bin:$PATH"
fi

# The next line enables shell command completion for gcloud.
if [ -d "$HOME/google-cloud-sdk/bin" ]; then
  export PATH="$PATH:$HOME/google-cloud-sdk/bin"
fi

# go
if [ -d "$HOME/.goenv" ]; then
  export GOENV_ROOT="$HOME/.goenv"
  export PATH="$GOENV_ROOT/bin:$PATH"
  eval "$(goenv init -)"
fi

# rust
if [ -d "$HOME/.cargo" ]; then
    export CARGO_HOME="$HOME/.cargo"
    export RUSTUP_HOME="$HOME/.rustup"
    export RUST_SRC_PATH="$(rustc --print sysroot 2>/dev/null)/lib/rustlib/src/rust/library"
    source "$CARGO_HOME/env"
fi

# deno
if [ -d "$HOME/.deno" ]; then
    export DENO_INSTALL="$HOME/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"
fi

# wal
if [ -d ~/.cache/wal ]; then
    (cat ~/.cache/wal/sequences &)
    cat ~/.cache/wal/sequences
    source ~/.cache/wal/colors-tty.sh
fi

#aliases
alias xcopy='xsel --clipboard --input'
alias es="env TERM=xterm emacs"
alias tm="tmux -u"
alias tmux="tmux -u"
alias reload-x="xrdb $HOME/.Xresources"
alias roficlip="rofi -modi 'clipmenu:env CM_LAUNCHER=rofi-script clipmenu' -show clipmenu"
alias comp="cargo compete"
