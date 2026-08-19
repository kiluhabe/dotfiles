#!/usr/bin/env bash
# PostToolUse(Write|Edit): force the written file open in the tmux editor pane
# so the user reviews it instead of it landing unseen.
set -uo pipefail

[ -n "${TMUX:-}" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
command -v tmux-editor-open >/dev/null 2>&1 || exit 0

FILE=$(jq -r '.tool_input.file_path // empty')
[ -n "$FILE" ] || exit 0

tmux-editor-open "$FILE" >/dev/null 2>&1 || true
exit 0
