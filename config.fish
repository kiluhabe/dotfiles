
set -x LANG ja_JP.UTF-8 $LANG

# Path to Oh My Fish install.
set -gx OMF_PATH "$HOME/.local/share/omf"

# Customize Oh My Fish configuration path.
set -gx OMF_CONFIG "$HOME/.config/omf"

# Load oh-my-fish configuration.
source $OMF_PATH/init.fish

# homebrew
set -U fish_user_paths /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/local/go/bin $fish_user_paths

# rbenv setup
#eval "$(rbenv init -)"
set -x RBENV_ROOT $HOME/.rbenv $RBENV_ROOT
set -x PATH $RBENV_ROOT/bin $RBENV_ROOT/shims $PATH
rbenv rehash >/dev/null ^&1

# pyenv setup
#eval "$(pyenv init -)"
set -x PYENV_ROOT $HOME/.pyenv $PYENV_ROOT
set -x PATH $PYENV_ROOT/bin $PYENV_ROOT/shims $PATH
pyenv rehash >/dev/null ^&1

#go setup
set -x GOPATH $HOME/.go $GOPATH

#node
#eval "$(nodenv init -)"
set -x NODENV_ROOT $HOME/.nodenv/ $NODENV_ROOT
set -x PATH $NODENV_ROOT/bin $NODENV_ROOT/shims $PATH
nodenv rehash >/dev/null ^&1

#PATH
set -x PATH $RBENV_ROOT/bin $RBENV_ROOT/shims $PYENV_ROOT/bin $PYENV_ROOT/shims /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/local/go/bin $PATH

#tmux plugin path
set -x TMUX_PLUGIN_PATH $HOME/.tmux/plugins/ $TMUX_PLUGIN_PATH

alias dotupdate='git -C $HOME/.dotfiles pull'
alias tpm-init='git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'
