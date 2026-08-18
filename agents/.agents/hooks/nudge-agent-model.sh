#!/usr/bin/env bash
# PreToolUse hook for the Agent tool.
# Each agent role (architect/implementer/mechanical/scout) pins its own model
# in its definition. Passing a model override here defeats routing-by-role
# and silently changes cost/quality tradeoffs the user didn't ask for.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
MODEL=$(printf '%s' "$INPUT" | jq -r '.tool_input.model // empty')

[ -z "$MODEL" ] && exit 0

printf 'BLOCKED by nudge-agent-model: do not override model on Agent calls — let the agent definition set it. Got model: %s\n' "$MODEL" >&2
exit 2
