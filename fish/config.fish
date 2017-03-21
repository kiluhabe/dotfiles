#reset path
set -u PATH
set -u GOPATH
set -u RBENV_ROOT
set -u PYENV_ROOT
set -u NODENV_ROOT
set -u TMUX_PLUGIN_PATH

# set LOCAL
set -x LANG ja_JP.UTF-8 
set -x LC_ALL $LANGN

#peco
set fish_plugins theme peco

# Path to Oh My Fish install.
set -gx OMF_PATH "$HOME/.local/share/omf"

# Customize Oh My Fish configuration path.
set -gx OMF_CONFIG "$HOME/.config/omf"

# Load oh-my-fish configuration.
source $OMF_PATH/init.fish

# homebrew
set -U fish_user_paths /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin $fish_user_paths

# rbenv setup
#eval "$(rbenv init -)"
set -U RBENV_ROOT $HOME/.rbenv $RBENV_ROOT
set -U fish_user_paths $RBENV_ROOT/bin $RBENV_ROOT/shims $fish_user_paths
rbenv rehash >/dev/null ^&1

# pyenv setup
#eval "$(pyenv init -)"
set -U PYENV_ROOT $HOME/.pyenv $PYENV_ROOT
set -U fish_user_paths $PYENV_ROOT/bin $PYENV_ROOT/shims $fish_user_paths
pyenv rehash >/dev/null ^&1

#node
#eval "$(nodenv init -)"
set -U NODENV_ROOT $HOME/.nodenv $NODENV_ROOT
set -U fish_user_paths $NODENV_ROOT/bin $NODENV_ROOT/shims $fish_user_paths
nodenv rehash >/dev/null ^&1

#tmux plugin path
set -U TMUX_PLUGIN_PATH $HOME/.tmux/plugins/ $TMUX_PLUGIN_PATH

#alias
alias dotupdate='git -C $HOME/.dotfiles pull'
alias tpm-init='git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'
alias docker-clean='docker rmi (docker images -aqf "dangling=true") 2> /dev/null; docker rm (docker ps -aqf "status=exited") 2> /dev/null'
alias refish='exec fish -l'
alias co='code'

#function
function fish_user_key_bindings
  bind \cr peco_select_history # Bind for prco history to Ctrl+r
  bind \c] peco_change_directory # Bind for prco change directory to Ctrl+]
end
source ~/.rsvm/rsvm.fish

# The next line enables shell command completion for gcloud.
set -U fish_user_paths $HOME/google-cloud-sdk/bin $fish_user_paths

#gopath
set -U GOPATH ~/gocode $GOPATH
set -U fish_user_paths $GOPATH/bin $fish_user_paths
