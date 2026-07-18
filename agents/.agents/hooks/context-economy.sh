#!/usr/bin/env bash
# PostToolUse hook that warns about repeated context-heavy tool use.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

input_file=$(mktemp "${TMPDIR:-/tmp}/context-economy.XXXXXX") || exit 0
trap 'rm -f "$input_file"' EXIT
cat > "$input_file" || exit 0
[ -s "$input_file" ] || exit 0

session_id=$(jq -r '.session_id // "unknown"' "$input_file" 2>/dev/null) || exit 0
cwd=$(jq -r '.cwd // empty' "$input_file" 2>/dev/null) || exit 0
tool_name=$(jq -r '.tool_name // empty' "$input_file" 2>/dev/null) || exit 0

safe_session=$(printf '%s' "$session_id" | tr -c 'A-Za-z0-9._-' '_')
[ -n "$safe_session" ] || safe_session=unknown

STATE_DIR="$HOME/.agents/state/context-economy/$safe_session"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0

hash_key() {
  printf '%s' "$1" | shasum -a 256 | awk '{print $1}'
}

emit_warning() {
  local message="$1"
  jq -nc --arg reason "$message" '{
    reason: $reason,
    additionalContext: $reason
  }'
}

inc_count() {
  local file="$1"
  local n=0
  if [ -f "$file" ]; then
    n=$(cat "$file" 2>/dev/null || echo 0)
  fi
  case "$n" in
    ''|*[!0-9]*) n=0 ;;
  esac
  n=$((n + 1))
  printf '%s\n' "$n" > "$file"
  printf '%s\n' "$n"
}

path_key() {
  jq -r '.tool_input.file_path // .tool_input.path // empty' "$input_file" 2>/dev/null
}

normalize_pattern() {
  printf '%s' "$1" |
    tr '[:upper:]' '[:lower:]' |
    sed -E 's/\\s\+/ /g; s/\\s\*/ /g; s/\.\*/ /g; s/\.\+/ /g; s/[[:space:][:punct:]]+//g'
}

response_text() {
  jq -r '
    def textify:
      if type == "string" then .
      elif type == "array" then map(textify) | join(" ")
      elif type == "object" then to_entries | map(.value | textify) | join(" ")
      else tostring
      end;
    if (.tool_response | type) == "object" then
      (.tool_response.content // .tool_response.text // .tool_response.result // .tool_response.output // .tool_response.object // .tool_response // empty)
    else
      (.tool_response // empty)
    end
    | textify
  ' "$input_file" 2>/dev/null
}

word_count() {
  wc -w | awk '{print $1}'
}

case "$tool_name" in
  Read)
    path=$(path_key)
    [ -n "$path" ] || exit 0
    key=$(hash_key "$path")
    count=$(inc_count "$STATE_DIR/read-$key.count")
    if [ "$count" -ge 2 ]; then
      emit_warning "Context economy warning: repeated Read of $path in this session ($count times). Reuse prior context or read only a targeted offset/limit."
    fi
    ;;

  Grep|Search)
    path=$(jq -r '.tool_input.path // .tool_input.file_path // .tool_input.glob // .cwd // empty' "$input_file" 2>/dev/null)
    [ -n "$path" ] || path="$cwd"
    pattern=$(jq -r '.tool_input.pattern // .tool_input.query // .tool_input.regex // empty' "$input_file" 2>/dev/null)
    [ -n "$pattern" ] || exit 0
    norm=$(normalize_pattern "$pattern")
    [ -n "$norm" ] || exit 0
    key=$(hash_key "$path|$norm")
    count=$(inc_count "$STATE_DIR/search-$key.count")
    if [ "$count" -ge 2 ]; then
      emit_warning "Context economy warning: similar grep repeated for $path ($pattern). Delegate exploration or narrow the next query instead of repeating the same search."
    fi
    ;;

  Edit|MultiEdit|Write)
    path=$(path_key)
    [ -n "$path" ] || exit 0
    key=$(hash_key "$path")
    count=$(inc_count "$STATE_DIR/edit-$key.count")
    if [ "$count" -ge 3 ]; then
      emit_warning "Context economy warning: $tool_name touched $path $count times. Batch remaining changes to this file into one edit."
    fi
    ;;

  Task|Agent)
    prompt=$(jq -r '.tool_input.prompt // .tool_input.description // .tool_input.message // empty' "$input_file" 2>/dev/null)
    cap=$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]' | sed -nE 's/.*(^|[^0-9])([0-9]+)[[:space:]]+words?.*/\2/p' | head -n 1)
    [ -n "$cap" ] || exit 0
    actual=$(response_text | word_count)
    if [ "$actual" -gt "$cap" ]; then
      emit_warning "Context economy warning: subagent response exceeded word cap ($actual words > $cap). Ask for a compressed answer instead of accepting raw logs."
    fi
    ;;
esac

exit 0
