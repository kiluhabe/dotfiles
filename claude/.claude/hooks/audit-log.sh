#!/usr/bin/env bash
# PostToolUse(Bash) audit log with size-based rotation.
# Keeps ~/.claude/audit.log under 10 MB by rotating to audit.log.1.
set -uo pipefail

F="$HOME/.claude/audit.log"
MAX=$((10 * 1024 * 1024))

if [ -f "$F" ]; then
  SZ=$(stat -f%z "$F" 2>/dev/null || stat -c%s "$F" 2>/dev/null || echo 0)
  [ "$SZ" -gt "$MAX" ] && mv -f "$F" "$F.1"
fi

jq -c '{t: now|todate, cmd: .tool_input.command, cwd: .cwd}' >> "$F"
