#!/usr/bin/env bash
# PostToolUse(Bash) audit log with size-based rotation.
set -uo pipefail

F="$HOME/.codex/audit.log"
MAX=$((10 * 1024 * 1024))

if [ -f "$F" ]; then
  SZ=$(stat -f%z "$F" 2>/dev/null || stat -c%s "$F" 2>/dev/null || echo 0)
  [ "$SZ" -gt "$MAX" ] && mv -f "$F" "$F.1"
fi

jq -c '{t: now|todate, session_id, turn_id, cwd, cmd: .tool_input.command}' >> "$F"
