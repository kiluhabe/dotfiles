# set LOCAL
set -gx LANG ja_JP.UTF-8 
set -gx LC_ALL $LANG

#peco
set fish_plugins theme peco

# Path to Oh My Fish install.
set -gx OMF_PATH "$HOME/.local/share/omf"

# Customize Oh My Fish configuration path.
set -gx OMF_CONFIG "$HOME/.config/omf"

# Load oh-my-fish configuration.
source $OMF_PATH/init.fish

# homebrew
set -gx fish_user_paths $fish_user_paths /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# rbenv setup
#eval "$(rbenv init -)"
set -gx RBENV_ROOT $HOME/.rbenv
set -gx fish_user_paths $fish_user_paths $RBENV_ROOT/bin $RBENV_ROOT/shims
rbenv rehash >/dev/null ^&1

# pyenv setup
#eval "$(pyenv init -)"
set -gx PYENV_ROOT $HOME/.pyenv
set -gx fish_user_paths $fish_user_paths $PYENV_ROOT/bin $PYENV_ROOT/shims
pyenv rehash >/dev/null ^&1

#node
#eval "$(nodenv init -)"
set -gx NODENV_ROOT $HOME/.nodenv
set -gx fish_user_paths  $fish_user_paths $NODENV_ROOT/bin $NODENV_ROOT/shims
nodenv rehash >/dev/null ^&1

#tmux plugin path
set -gx TMUX_PLUGIN_PATH $HOME/.tmux/plugins/

# The next line enables shell command completion for gcloud.
set -gx fish_user_paths $fish_user_paths $HOME/google-cloud-sdk/bin

#gopath
set -gx GOPATH ~/gocode
set -gx fish_user_paths $fish_user_paths $GOPATH/bin

#rust path
set -gx CARGO_HOME $HOME/.cargo
set -gx RUSTUP_HOME $HOME/.rustup
set -gx fish_user_paths $fish_user_paths $CARGO_HOME/bin

#alias
alias dotupdate='git -C $HOME/.dotfiles pull'
alias tpm-init='git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'
alias docker-clean='docker rmi (docker images -aqf "dangling=true") 2> /dev/null; docker rm (docker ps -aqf "status=exited") 2> /dev/null'
alias refish='exec fish -l'
alias co='code'
alias docker-kill-all='docker stop (docker ps -a -q)'

#function
function fish_user_key_bindings
  bind \cr peco_select_history # Bind for prco history to Ctrl+r
  bind \c] peco_change_directory # Bind for prco change directory to Ctrl+]
end
