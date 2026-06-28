#!/usr/bin/env bash
# Shared PostToolUse(Bash) audit log with size-based rotation.
set -uo pipefail

agent=${1:-agent}
case "$agent" in
  claude) F="$HOME/.claude/audit.log" ;;
  codex) F="$HOME/.codex/audit.log" ;;
  *) F="$HOME/.agents/audit.log" ;;
esac

MAX=$((10 * 1024 * 1024))
DIR=$(dirname "$F")
mkdir -p "$DIR"

if [ -f "$F" ]; then
  SZ=$(stat -f%z "$F" 2>/dev/null || stat -c%s "$F" 2>/dev/null || echo 0)
  [ "$SZ" -gt "$MAX" ] && mv -f "$F" "$F.1"
fi

jq -c '{
  t: now|todate,
  session_id,
  turn_id,
  cwd,
  tool_name,
  cmd: (.tool_input.command // .tool_input.cmd // .command)
}' >> "$F"
