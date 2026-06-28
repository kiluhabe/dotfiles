#!/usr/bin/env bash
# PreToolUse hook for Bash tools.
# Steers exploration commands to structured agent file tools instead of raw shell output.
set -uo pipefail

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && exit 0

nudge() {
  printf 'BLOCKED by nudge-bash: use %s instead of `%s`\nCommand: %s\n' "$2" "$1" "$CMD" >&2
  exit 2
}

check_segment() {
  local seg="$1"
  seg="${seg#"${seg%%[![:space:]]*}"}"
  seg="${seg%"${seg##*[![:space:]]}"}"
  [ -z "$seg" ] && return 0

  local first="${seg%%[[:space:]]*}"
  first="${first##*/}"

  if [ "$first" = "xargs" ]; then
    local -a toks
    read -r -a toks <<<"$seg"
    local skip_next=0 target=""
    local i
    for ((i=1; i<${#toks[@]}; i++)); do
      local w="${toks[i]}"
      if [ "$skip_next" = "1" ]; then skip_next=0; continue; fi
      case "$w" in
        -n|-P|-L|-I|-E|-d|-s|-a|--max-args|--max-procs|--max-lines|--replace|--eof|--delimiter|--max-chars|--arg-file)
          skip_next=1; continue ;;
        -*) continue ;;
        *) target="$w"; break ;;
      esac
    done
    if [ -n "$target" ]; then
      check_segment "$target"
    fi
    return 0
  fi

  case "$first" in
    cat|bat|less|more|head)
      if printf '%s' "$seg" | grep -qE '<<-?[[:space:]]*'\''?[A-Za-z_]'; then
        return 0
      fi
      nudge "$first" "Read tool (use offset/limit for large files)"
      ;;
    tail)
      if printf '%s' "$seg" | grep -qE '[[:space:]]-[a-zA-Z]*[fF]'; then
        return 0
      fi
      nudge "tail" "Read tool (use offset to read end of file)"
      ;;
    ls|find)
      nudge "$first" "Glob tool (e.g. pattern \"**/*.ts\")"
      ;;
  esac
}

split_chains() {
  local s="$1"
  s="${s//&&/$'\n'}"
  s="${s//||/$'\n'}"
  s="${s//|/$'\n'}"
  s="${s//;/$'\n'}"
  printf '%s' "$s"
}

TMP=$(split_chains "$CMD")
while IFS= read -r seg; do
  check_segment "$seg"
done <<<"$TMP"

SUBS=$(printf '%s' "$CMD" | grep -oE '\$\([^()]*\)|`[^`]*`' | sed -E 's/^\$\(|\)$|^`|`$//g')
if [ -n "$SUBS" ]; then
  SUBS=$(split_chains "$SUBS")
  while IFS= read -r seg; do
    check_segment "$seg"
  done <<<"$SUBS"
fi

exit 0
