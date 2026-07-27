#!/usr/bin/env bash
# Stop hook. Blocks stopping while pending/in_progress tasks lack a tier owner.
# escape hatch: any non-empty owner (e.g. "self") counts as assigned.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
SID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty')
[ -z "$SID" ] && exit 0

DIR="$HOME/.claude/tasks/$SID"
[ -d "$DIR" ] || exit 0

shopt -s nullglob
FILES=("$DIR"/*.json)
[ ${#FILES[@]} -eq 0 ] && exit 0

UNASSIGNED=$(jq -rs '
  map(select((.status=="pending" or .status=="in_progress")
    and ((.owner // "") == "")))
  | .[] | "  - [\(.id)] \(.subject)"' "${FILES[@]}")

if [ -n "$UNASSIGNED" ]; then
  printf 'BLOCKED by enforce-task-owner: assign a tier owner to these tasks (or owner "self" to keep them) before stopping.\n%s\n' "$UNASSIGNED" >&2
  exit 2
fi

exit 0
