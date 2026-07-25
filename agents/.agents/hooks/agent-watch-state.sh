#!/usr/bin/env bash
# Shared hook for exposing agent state to agent-watch through tmux pane options.
set -uo pipefail

state=${1:-}
case "$state" in
  answering|working|approval|idle) ;;
  *) exit 0 ;;
esac

[ -n "${TMUX_PANE:-}" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

tmux set-option -p -t "$TMUX_PANE" @agent-watch-state "$state" >/dev/null 2>&1 || true
exit 0
