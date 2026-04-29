#!/usr/bin/env bash
# PreToolUse hook for the Bash tool.
# Permission deny rules cannot reliably catch flag variants or shell-side
# secret reads (cat/head/grep are auto-allowed). This hook covers those.
set -uo pipefail

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && exit 0

block() { printf 'BLOCKED by guard-bash: %s\nCommand: %s\n' "$1" "$CMD" >&2; exit 2; }

# rm with both -r and -f (any order/casing)
if printf '%s' "$CMD" | grep -qE '\brm[[:space:]]+(-[a-zA-Z]*[rR][a-zA-Z]*[fF]|-[a-zA-Z]*[fF][a-zA-Z]*[rR]|-[rR][[:space:]]+-[a-zA-Z]*[fF]|-[fF][[:space:]]+-[a-zA-Z]*[rR]|--recursive[[:space:]]+--force|--force[[:space:]]+--recursive)'; then
  block "rm -rf"
fi

# Reading secrets via auto-allowed read-only commands
if printf '%s' "$CMD" | grep -qE '\b(cat|bat|less|more|head|tail|grep|rg|awk|sed|xxd|strings)[[:space:]]+([^|;&]*[[:space:]/])?(\.env([^a-zA-Z0-9_-]|$)|id_rsa|id_ed25519|\.ssh/|\.aws/|\.gnupg/|\.netrc|\.npmrc|\.pypirc)'; then
  block "secret read via shell"
fi

# Force push, no-verify, fork bomb, disk wipe, world-writable chmod
if printf '%s' "$CMD" | grep -qE '\bgit[[:space:]]+push[[:space:]]+[^|;&]*(-f([[:space:]]|$)|--force)'; then
  block "git push --force"
fi
if printf '%s' "$CMD" | grep -qE '\bgit[[:space:]]+[a-z-]+[[:space:]]+[^|;&]*--no-verify'; then
  block "git --no-verify"
fi
if printf '%s' "$CMD" | grep -qE ':\(\)[[:space:]]*\{[[:space:]]*:[[:space:]]*\|[[:space:]]*:?[[:space:]]*&[[:space:]]*\}'; then
  block "fork bomb"
fi
if printf '%s' "$CMD" | grep -qE '\b(dd[[:space:]]+if=|mkfs[.[:space:]]|wipefs[[:space:]])'; then
  block "low-level disk write"
fi
if printf '%s' "$CMD" | grep -qE '\bchmod[[:space:]]+(-R[[:space:]]+)?[0-7]?7{2}([[:space:]]|$)'; then
  block "world-writable chmod"
fi

exit 0
