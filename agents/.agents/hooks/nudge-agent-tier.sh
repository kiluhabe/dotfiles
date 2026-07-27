#!/usr/bin/env bash
# Steers subagent routing toward role-based tiers (architect/implementer/mechanical).
# Dual-mode:
#   Claude Code — PreToolUse hook for the Agent tool. Reads .tool_input.subagent_type;
#     denylist: blocks generic default routing (general-purpose/claude/empty), passes
#     purpose-specific agents (Explore, Plan, etc.).
#   Codex — SubagentStart hook. Reads .agent_type; allowlist: the roster is exactly the
#     three tiers, so anything else is blocked.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
CODEX_TYPE=$(printf '%s' "$INPUT" | jq -r '.agent_type // empty')

if [ -n "$CODEX_TYPE" ]; then
  # Codex path: allowlist the three tiers.
  case "$CODEX_TYPE" in
    architect|implementer|mechanical) exit 0 ;;
    *)
      printf 'BLOCKED by nudge-agent-tier: route by role — use architect / implementer / mechanical. Got: %s\n' "$CODEX_TYPE" >&2
      exit 2
      ;;
  esac
fi

# Claude Code path: denylist generic default routing.
TYPE=$(printf '%s' "$INPUT" | jq -r '.tool_input.subagent_type // empty')
case "$TYPE" in
  general-purpose|claude|"")
    printf 'BLOCKED by nudge-agent-tier: route by role — use architect / implementer / mechanical (or a purpose-specific agent like Explore). Got: %s\n' "${TYPE:-<none>}" >&2
    exit 2
    ;;
esac

exit 0
