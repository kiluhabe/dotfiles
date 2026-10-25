#!/usr/bin/env bash
# Steers subagent routing to the role-based roster.
# The routable roster is closed: architect / implementer / scout.
# thinker is also allowed, but it's a direct-dial consultation the user
# names explicitly for one heavy question — not a role the assistant picks on
# its own, and deliberately left out of the printed guidance below.
# Built-in agents (general-purpose, claude, Explore, Plan) are blocked because
# their model is unpinned — they inherit the session's, so a wide sweep lands on
# the expensive tier. scout covers read-only search at a fixed model; producing a
# plan is implementer + writing-plans, reviewed by architect.
# Reviews specifically: there is no per-task review. One architect review of
# the whole diff, and only when it exceeds 100 lines or is hard to reverse —
# below that bar, skip the review rather than downgrading it to implementer.
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
  architect|implementer|scout|thinker) exit 0 ;;
esac

printf 'BLOCKED by nudge-agent-tier: route by role — architect / implementer / scout (read-only search). Got: %s\nFor reviews: architect, only when the diff exceeds 100 lines or is hard to reverse; no per-task review.\n' "${TYPE:-<none>}" >&2
exit 2
