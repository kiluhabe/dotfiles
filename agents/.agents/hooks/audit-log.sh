#!/usr/bin/env bash
# Shared PostToolUse(Bash) audit log with size-based rotation.
set -uo pipefail

agent=${1:-agent}
case "$agent" in
  claude) F="$HOME/.claude/audit.log" ;;
  codex) F="$HOME/.codex/audit.log" ;;
  *) F="$HOME/.agents/audit.log" ;;
esac

command -v jq >/dev/null 2>&1 || exit 0

MAX=$((10 * 1024 * 1024))
DIR=$(dirname "$F")
mkdir -p "$DIR" 2>/dev/null || exit 0

if [ -f "$F" ]; then
  SZ=$(stat -f%z "$F" 2>/dev/null || stat -c%s "$F" 2>/dev/null || echo 0)
  [ "$SZ" -gt "$MAX" ] && mv -f "$F" "$F.1" 2>/dev/null
fi

[ -e "$F" ] && [ ! -w "$F" ] && exit 0

jq -c --arg agent "$agent" '
def n:
  if type == "number" then
    .
  elif type == "string" then
    tonumber? // 0
  else
    0
  end;
{
  t: now|todate,
  agent: $agent,
  session_id,
  turn_id,
  cwd,
  hook_event_name,
  tool_name,
  cmd: (.tool_input.command // .tool_input.cmd // .command // .cmd),
  file_path: (.tool_input.file_path // .tool_input.path // .file_path // .path),
  input_tokens: (
    .context_window.total_input_tokens //
    .usage.input_tokens //
    .usage.prompt_tokens //
    0
    | n
  ),
  output_tokens: (
    .context_window.total_output_tokens //
    .usage.output_tokens //
    .usage.completion_tokens //
    0
    | n
  ),
  cost_usd: ((.cost_usd // .usage.cost_usd // 0) | n),
  subagent_name: (.subagent_name // .agent.name // .tool_input.subagent_name // .tool_input.agent // ""),
  is_delegation: ((.tool_name // "") as $tool | ["Task", "Agent", "mcp__multi-agent", "send_message_to_thread"] | index($tool) != null),
  response_chars: (
    if .tool_response == null then
      0
    elif (.tool_response | type) == "string" then
      (.tool_response | length)
    else
      (.tool_response | tojson | length)
    end
  )
}' >> "$F" 2>/dev/null || true

exit 0
