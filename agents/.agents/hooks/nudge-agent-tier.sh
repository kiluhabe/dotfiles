#!/usr/bin/env bash
# PreToolUse hook for the Agent tool.
# Steers subagent routing toward role-based tiers (architect/implementer/mechanical)
# or purpose-specific agents, blocking generic default routing.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
TYPE=$(printf '%s' "$INPUT" | jq -r '.tool_input.subagent_type // empty')

case "$TYPE" in
  general-purpose|claude|"")
    printf 'BLOCKED by nudge-agent-tier: route by role — use architect / implementer / mechanical (or a purpose-specific agent like Explore). Got: %s\n' "${TYPE:-<none>}" >&2
    exit 2
    ;;
esac

exit 0
