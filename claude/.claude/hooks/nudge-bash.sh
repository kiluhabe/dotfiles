#!/usr/bin/env bash
# PreToolUse hook for the Bash tool.
# Steers exploration commands (cat/head/tail/less/more/bat/ls/find) to
# Read/Glob tools so results land in structured cache instead of raw shell output.
set -uo pipefail

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && exit 0

nudge() {
  # shellcheck disable=SC2016  # printf format string, not shell expansion
  printf 'BLOCKED by nudge-bash: use %s instead of `%s`\nCommand: %s\n' "$2" "$1" "$CMD" >&2
  exit 2
}

check_segment() {
  local seg="$1"
  # Drop everything from the first pipe (right side of `|` is fine).
  local head_seg="${seg%%|*}"
  # Trim leading/trailing whitespace.
  head_seg="${head_seg#"${head_seg%%[![:space:]]*}"}"
  head_seg="${head_seg%"${head_seg##*[![:space:]]}"}"
  [ -z "$head_seg" ] && return 0
  local first="${head_seg%%[[:space:]]*}"
  case "$first" in
    cat|bat|less|more|head)
      # Allow heredoc writes such as `cat <<EOF`.
      if printf '%s' "$head_seg" | grep -qE '<<-?[[:space:]]*'\''?[A-Za-z_]'; then
        return 0
      fi
      nudge "$first" "Read tool (use offset/limit for large files)"
      ;;
    tail)
      # Allow follow mode (`tail -f` / `-F`) which Read cannot replace.
      if printf '%s' "$head_seg" | grep -qE '[[:space:]]-[a-zA-Z]*[fF]'; then
        return 0
      fi
      nudge "tail" "Read tool (use offset to read end of file)"
      ;;
    ls|find)
      nudge "$first" "Glob tool (e.g. pattern \"**/*.ts\")"
      ;;
  esac
}

# Split on ; && || so each simple command is checked.
TMP="${CMD//&&/$'\n'}"
TMP="${TMP//||/$'\n'}"
TMP="${TMP//;/$'\n'}"

while IFS= read -r seg; do
  check_segment "$seg"
done <<<"$TMP"

exit 0
