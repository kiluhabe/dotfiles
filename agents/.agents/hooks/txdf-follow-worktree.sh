#!/usr/bin/env bash
# PostToolUse hook shared by Claude Code and Codex: when the agent moves into a
# git worktree, re-root the tmux-default-layout window's editor/diff/shell panes
# onto it. Never blocks the agent, so every path exits 0.
set -uo pipefail

# Drain stdin first so the agent never gets EPIPE on a large payload.
INPUT=$(cat) || INPUT=""

[ -n "${TMUX_PANE:-}" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

WINDOW=$(tmux display-message -p -t "$TMUX_PANE" '#{window_id}' 2>/dev/null) || exit 0
SESSION=$(tmux display-message -p -t "$TMUX_PANE" '#{session_id}' 2>/dev/null) || exit 0
tmux list-panes -s -t "$SESSION" \
  -F '#{@tmux-default-layout-role}|#{@tmux-default-layout-home}' 2>/dev/null \
  | grep -qxF "editor|$WINDOW" || exit 0

[ -n "$INPUT" ] || exit 0
TOOL=$(jq -r '.tool_name // empty' <<<"$INPUT" 2>/dev/null) || exit 0
CWD=$(jq -r '.cwd // empty' <<<"$INPUT" 2>/dev/null) || exit 0

# run-shell would expand #{...} / #(...) inside paths, so launch the helper
# directly, detached from the hook so it returns at once and the child outlives it.
launch() {
  (nohup tmux-txdf-reroot "$@" </dev/null >/dev/null 2>&1 &)
  exit 0
}

reroot() { launch "$WINDOW" "$1"; }

# Resolved paths of every worktree of the repo containing $1, main checkout first.
worktrees() {
  git -C "$1" worktree list --porcelain 2>/dev/null | while IFS= read -r line; do
    case "$line" in
      "worktree "*) (cd "${line#worktree }" 2>/dev/null && pwd -P) ;;
    esac
  done
}

resolve_dir() { (cd "$1" 2>/dev/null && pwd -P); }

case "$TOOL" in
  ExitWorktree)
    launch --origin "$WINDOW"
    ;;
  EnterWorktree)
    # tool_response.worktreePath names the worktree just entered, and cwd has
    # already moved there; either one will do.
    TARGET=$(jq -r '.tool_response.worktreePath // .cwd // empty' <<<"$INPUT" 2>/dev/null)
    [ -n "$TARGET" ] || exit 0
    TARGET=$(resolve_dir "$TARGET") || exit 0
    # Accept only a registered worktree other than the main checkout, so the
    # payload can't point the panes anywhere else.
    WTS=$(worktrees "$TARGET")
    MAIN=${WTS%%$'\n'*}
    [ "$TARGET" != "$MAIN" ] && grep -qxF "$TARGET" <<<"$WTS" && reroot "$TARGET"
    ;;
  Bash)
    CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT" 2>/dev/null)
    grep -Eq 'git[[:space:]].*worktree[[:space:]]+add' <<<"$CMD" || exit 0
    [ -n "$CWD" ] || exit 0
    WTS=$(worktrees "$CWD")
    MAIN=${WTS%%$'\n'*}
    FOUND=""
    set -f
    # Strip quotes, then resolve each word of the command against cwd and keep
    # the last one that is a registered worktree other than the main checkout.
    # shellcheck disable=SC2046 # word splitting is the point
    for TOK in $(tr -d "\"'" <<<"$CMD"); do
      case "$TOK" in -*) continue ;; esac
      [ "${TOK#/}" = "$TOK" ] && TOK="$CWD/$TOK"
      D=$(resolve_dir "$TOK") || continue
      [ "$D" != "$MAIN" ] && grep -qxF "$D" <<<"$WTS" && FOUND="$D"
    done
    # Paths containing spaces survive no word splitting; match them verbatim.
    while IFS= read -r D; do
      [ -n "$D" ] && [ "$D" != "$MAIN" ] && [[ $CMD == *"$D"* ]] && FOUND="$D"
    done <<<"$WTS"
    [ -n "$FOUND" ] && reroot "$FOUND"
    ;;
esac
exit 0
