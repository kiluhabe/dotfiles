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

# mise
# --quiet silences hook-env's "missing: ..." WARN on each prompt;
# declared-but-uninstalled tools are intentional (see mise/config.toml).
if command -v mise &>/dev/null; then
    eval "$(mise activate bash --quiet)"
fi

# gcloud
if [ -d "$HOME/google-cloud-sdk/bin" ]; then
  export PATH="$PATH:$HOME/google-cloud-sdk/bin"
fi

# wal
if [ -d ~/.cache/wal ]; then
    (cat ~/.cache/wal/sequences &)
    cat ~/.cache/wal/sequences
    source ~/.cache/wal/colors-tty.sh
fi

export CLAUDE_CODE_ENABLE_TELEMETRY=1

#aliases
alias codex='codex --profile default'
alias xcopy='xsel --clipboard --input'
alias es="env TERM=xterm emacs"
alias tm="tmux -u"
alias tmux="tmux -u"
alias reload-x="xrdb $HOME/.Xresources"
alias roficlip="rofi -modi 'clipmenu:env CM_LAUNCHER=rofi-script clipmenu' -show clipmenu"
alias comp="cargo compete"
