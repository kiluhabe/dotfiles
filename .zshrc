#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

export LANG=ja_JP.UTF-8

setopt print_eight_bit

setopt auto_cd

setopt no_beep

setopt nolistbeep

setopt auto_pushd

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt share_history

setopt hist_ignore_dups

setopt hist_ignore_all_dups

setopt hist_ignore_space

setopt hist_reduce_blanks


autoload -U promptinit; promptinit
prompt pure

export PURE_PROMPT_SYMBOL=">>"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# rbenv setup
export RBENV_ROOT=$HOME/.rbenv
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"

# pyenv setup
export PYENV_ROOT=$HOME/.pyenv
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PYENV_ROOT/bin:$PYENV_ROOT/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

git -C $HOME/.dotfiles pull

zsh -c 'for f in `\find $HOME/.dotfiles/.??* -maxdepth 0 -type f` do; [[ "$f" == ".git" ]] && continue; [[ "$f" == ".DS_Store" ]] && continue; ln -s $f $HOME ; done;'
