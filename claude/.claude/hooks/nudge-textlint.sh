#!/usr/bin/env bash
# PostToolUse hook for the Write/Edit tools.
# Lints .md files with textlint-rule-preset-japanese and nudges Claude
# to fix only the parts it just wrote. Skips silently if textlint isn't
# resolvable via `npx --no-install` (user explicitly opted into this).
set -uo pipefail

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] && exit 0

# Markdown only.
shopt -s nocasematch
case "$FILE" in
  *.md|*.markdown) ;;
  *) exit 0 ;;
esac
shopt -u nocasematch

[ -f "$FILE" ] || exit 0
command -v npx >/dev/null 2>&1 || exit 0

CONFIG="${HOME}/.claude/hooks/textlint.config.json"
[ -f "$CONFIG" ] || exit 0

OUTPUT=$(npx --no-install -p textlint -p textlint-rule-preset-japanese -- \
  textlint --no-color --config "$CONFIG" -f stylish "$FILE" 2>&1)
RC=$?

# Exit 0 = clean; nothing to say.
[ $RC -eq 0 ] && exit 0

# Non-zero without the file path in output means npx couldn't resolve
# textlint (or another tooling error) — skip silently per user policy.
if ! printf '%s' "$OUTPUT" | grep -qF "$FILE"; then
  exit 0
fi

printf 'BLOCKED by nudge-textlint: 以下の指摘のうち、今回あなたが追加・変更した範囲に該当するものだけ修正してください（既存箇所の lint 違反は触らないでください）\n%s\n' "$OUTPUT" >&2
exit 2
