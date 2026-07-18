#!/usr/bin/env bash
# Summarize shared hook audit logs by session.
set -uo pipefail

agent=${1:-agent}
case "$agent" in
  claude) F="$HOME/.claude/audit.log" ;;
  codex) F="$HOME/.codex/audit.log" ;;
  *) F="$HOME/.agents/audit.log" ;;
esac

[ -f "$F" ] || exit 0

jq -Rsr '
  def n: tonumber? // 0;
  def b: . == true or . == "true";

  split("\n")
  | map(select(length > 0) | fromjson?)
  | sort_by(.session_id // "")
  | group_by(.session_id // "")
  | map({
      session: (.[0].session_id // ""),
      calls: length,
      input_tokens: (map(.input_tokens | n) | max // 0),
      output_tokens: (map(.output_tokens | n) | max // 0),
      delegations: (map(select(.is_delegation | b)) | length),
      redelegations: (map(select((.is_delegation | b) and ((.subagent_name // "") | tostring | length > 0))) | length),
      tools: (
        reduce .[] as $event ({}; .[$event.tool_name // "unknown"] += 1)
        | to_entries
        | sort_by(.key)
        | map("\(.key)=\(.value)")
        | join(",")
      )
    })
  | .[]
  | "session=\(.session) calls=\(.calls) tokens=in:\(.input_tokens)/out:\(.output_tokens) delegations=\(.delegations) redelegation_rate=\(if .delegations == 0 then 0 else ((.redelegations * 100 / .delegations) | floor) end)% tools=\(.tools)"
' "$F"
