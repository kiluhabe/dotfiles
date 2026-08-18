#!/usr/bin/env bash
# Steers subagent routing to the role-based roster.
# The roster is closed: architect / implementer / mechanical / scout.
# Built-in agents (general-purpose, claude, Explore, Plan) are blocked because
# their model is unpinned — they inherit the session's, so a wide sweep lands on
# the expensive tier. scout covers read-only search at a fixed model; producing a
# plan is implementer + writing-plans, reviewed by architect.
# Reviews specifically: a per-task review (spec + quality gate after one task)
# routes to implementer — it's a scoped check, not a high-stakes call. Only the
# final whole-branch/merge review routes to architect. Don't default every
# review to architect just because a skill template says general-purpose.
# Dual-mode: Claude Code PreToolUse on the Agent tool (.tool_input.subagent_type),
# Codex SubagentStart (.agent_type). Same allowlist on both paths.
set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
CODEX_TYPE=$(printf '%s' "$INPUT" | jq -r '.agent_type // empty')

if [ -n "$CODEX_TYPE" ]; then
  TYPE="$CODEX_TYPE"
else
  TYPE=$(printf '%s' "$INPUT" | jq -r '.tool_input.subagent_type // empty')
fi

case "$TYPE" in
  architect|implementer|mechanical|scout) exit 0 ;;
esac

printf 'BLOCKED by nudge-agent-tier: route by role — architect / implementer / mechanical / scout (read-only search). Got: %s\nFor reviews: per-task review -> implementer, final whole-branch review -> architect.\n' "${TYPE:-<none>}" >&2
exit 2
