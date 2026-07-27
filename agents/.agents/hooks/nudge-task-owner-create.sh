#!/usr/bin/env bash
# PreToolUse hook for TaskCreate. Non-blocking reminder to assign a tier owner.
set -uo pipefail

cat >/dev/null 2>&1 || true

printf 'note: after creating tasks, assign a tier owner (architect/implementer/mechanical) via TaskUpdate; keep-it-myself tasks use owner "self".\n' >&2
exit 0
