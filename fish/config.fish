# set LOCAL
set -gx LANG ja_JP.UTF-8 
set -gx LC_ALL $LANG

#peco
set fish_plugins theme peco

# Path to Oh My Fish install.
if test -d $HOME/.local/share/omf
  set -gx OMF_PATH "$HOME/.local/share/omf"
else
  NOT_FOUNDS $NOT_FOUNDS "Oh My Fish"
end

# Customize Oh My Fish configuration path.
if test -d $HOME/.config/omf
  set -gx OMF_CONFIG "$HOME/.config/omf"
else
  NOT_FOUNDS $NOT_FOUNDS "Oh My Fish Configration File"
end

# Load oh-my-fish configuration.
if test -e $OMF_PATH/init.fish
  source $OMF_PATH/init.fish
end

# homebrew
set -gx fish_user_paths $fish_user_paths /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# rbenv setup
#eval "$(rbenv init -)"
if test -d $HOME/.rbenv
  set -gx RBENV_ROOT $HOME/.rbenv
  set -gx fish_user_paths $fish_user_paths $RBENV_ROOT/bin $RBENV_ROOT/shims
  rbenv rehash >/dev/null ^&1
else
  NOT_FOUNDS $NOT_FOUNDS "rbenv"
end

# pyenv setup
#eval "$(pyenv init -)"
if test -d $HOME/.pyenv
  set -gx PYENV_ROOT $HOME/.pyenv
  set -gx fish_user_paths $fish_user_paths $PYENV_ROOT/bin $PYENV_ROOT/shims
  pyenv rehash >/dev/null ^&1
else
  NOT_FOUNDS $NOT_FOUNDS "pyenv"
end

#node
#eval "$(nodenv init -)"
if test -d $HOME/.nodenv
  set -gx NODENV_ROOT $HOME/.nodenv
  set -gx fish_user_paths  $fish_user_paths $NODENV_ROOT/bin $NODENV_ROOT/shims
  nodenv rehash >/dev/null ^&1
else
  NOT_FOUNDS $NOT_FOUNDS "nodenv"
end

#tmux plugin path
if test -d $HOME/.tmux/plugins/
  set -gx TMUX_PLUGIN_PATH $HOME/.tmux/plugins/
else
  NOT_FOUNDS $NOT_FOUNDS "tmux plugings directory"
end

# The next line enables shell command completion for gcloud.
if test -d $HOME/google-cloud-sdk/bin
  set -gx fish_user_paths $fish_user_paths $HOME/google-cloud-sdk/bin
else
  NOT_FOUNDS $NOT_FOUNDS "gcloud sdk"
end

#gopath
if test -d $HOME/gocode
  set -gx GOPATH $HOME/gocode
  set -gx fish_user_paths $fish_user_paths $GOPATH/bin
else
  NOT_FOUNDS $NOT_FOUNDS "gocode directory"
end

#rust path
if test -d $HOME/.cargo; and test -d $HOME/.rustup
  set -gx CARGO_HOME $HOME/.cargo
  set -gx RUSTUP_HOME $HOME/.rustup
  set -gx RUST_SRC_PATH $HOME/.rustup/toolchains/nightly-x86_64-apple-darwin/lib/rustlib/src/rust/src
  set -gx fish_user_paths $fish_user_paths $CARGO_HOME/bin
else
  NOT_FOUNDS $NOT_FOUNDS "cargo or rustup"
end

#alias
alias dotupdate='git -C $HOME/.dotfiles pull'
alias tpm-init='git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'
alias docker-clean='docker rmi (docker images -aqf "dangling=true") 2> /dev/null; docker rm (docker ps -aqf "status=exited") 2> /dev/null'
alias refish='exec fish -l'
alias co='code'
alias docker-kill-all='docker stop (docker ps -a -q)'
alias vi='vim'

#function
function fish_user_key_bindings
  bind \cr peco_select_history # Bind for prco history to Ctrl+r
  bind \c] peco_change_directory # Bind for prco change directory to Ctrl+]
end

if test -z '$NOT_FOUNDS'
  echo 'these are not found.'
  echo $NOT_FOUNDS
end
