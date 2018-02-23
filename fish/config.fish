# direnv
type direnv > /dev/null ^&1
if test 0 -eq $status
   eval (direnv hook fish)
end

# set LOCAL
set -gx LANG ja_JP.UTF-8
set -gx LC_ALL $LANG

#peco
set fish_plugins theme peco

# Path to Oh My Fish install.
if test -d $HOME/.local/share/omf
  set -gx OMF_PATH "$HOME/.local/share/omf"
end

# Customize Oh My Fish configuration path.
if test -d $HOME/.config/omf
  set -gx OMF_CONFIG "$HOME/.config/omf"
end

# Load oh-my-fish configuration.
if test -e $OMF_PATH/init.fish
  source $OMF_PATH/init.fish
end

# rbenv setup
if test -d $HOME/.rbenv
  # status --is-interactive; and source (rbenv init -|psub)
  set -gx RBENV_ROOT $HOME/.rbenv
  set -gx fish_user_paths $fish_user_paths $RBENV_ROOT/bin $RBENV_ROOT/shims
  rbenv rehash >/dev/null ^&1
end

# pyenv setup
if test -d $HOME/.pyenv
  # status --is-interactive; and source (pyenv init -|psub)
  set -gx PYENV_ROOT $HOME/.pyenv
  set -gx fish_user_paths $fish_user_paths $PYENV_ROOT/bin $PYENV_ROOT/shims
  pyenv rehash >/dev/null ^&1
end

#node
if test -d $HOME/.nodenv
  # status --is-interactive; and source (nodenv init -|psub)
  set -gx NODENV_ROOT $HOME/.nodenv
  set -gx fish_user_paths  $fish_user_paths $NODENV_ROOT/bin $NODENV_ROOT/shims
  nodenv rehash >/dev/null ^&1
end

#tmux plugin path
if test -d $HOME/.tmux/plugins/
  set -gx TMUX_PLUGIN_PATH $HOME/.tmux/plugins/
end

# The next line enables shell command completion for gcloud.
if test -d $HOME/google-cloud-sdk/bin
  set -gx fish_user_paths $fish_user_paths $HOME/google-cloud-sdk/bin
end

#gopath
if test -d $HOME/gocode
  set -gx GOPATH $HOME/gocode
  set -gx fish_user_paths $fish_user_paths $GOPATH/bin
end

#rust path
if test -d $HOME/.cargo; and test -d $HOME/.rustup
  set -gx CARGO_HOME $HOME/.cargo
  set -gx RUSTUP_HOME $HOME/.rustup
  set -gx RUST_SRC_PATH $HOME/.rustup/toolchains/nightly-x86_64-apple-darwin/lib/rustlib/src/rust/src
  set -gx fish_user_paths $fish_user_paths $CARGO_HOME/bin
end

if test -e $HOME/.emacs/bin/emacs
  set -gx fish_user_paths $fish_user_paths $HOME/.emacs/bin
  set -gx EDITOR $HOME/.emacs/bin
else
  set -gx EDITOR emacs
end

# homebrew
string match -r '^Darwin' (uname -a) > /dev/null ^&1;
if test 0 -eq $status
   set -gx fish_user_paths $fish_user_paths /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
end

#alias
alias dotupdate='git -C $HOME/.dotfiles pull origin master; fish_update_completions'
alias tpm-init='git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'
alias docker-clean='docker rmi (docker images -aqf "dangling=true") 2> /dev/null; docker rm (docker ps -aqf "status=exited") 2> /dev/null'
alias refish='exec fish -l'
if test -e /usr/local/bin/code
  alias co='code'
else if test -e $HOME/.rbenv/shims/rmate
  alias co='rmate -p 52698'
end
alias docker-kill-all='docker stop (docker ps -a -q)'
alias vi='vim'
alias rust='cargo script'
alias es='emacs'
alias be='bundle exec'

if test -d /usr/local/tmux-2.3/bin
  alias tmux="/usr/local/tmux-2.3/bin/tmux"
end

if test -d $HOME/google-cloud-sdk/bin
  alias gcestart="gcloud compute instances start"
  alias gcels="gcloud compute instances list"
  alias gcekill="gcloud compute instances stop"
  alias gpjktls="gcloud projects list"
  alias gconfls="gcloud config list"
  alias gconfset="gcloud config set"
end


#function
function fish_user_key_bindings
  bind \cr peco_select_history # Bind for prco history to Ctrl+r
  bind \c] peco_change_directory # Bind for prco change directory to Ctrl+]
end
