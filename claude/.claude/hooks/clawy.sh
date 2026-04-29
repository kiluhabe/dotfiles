#!/usr/bin/env bash
# Dispatches to ~/.clawy/hooks/<script> only when clawy is installed locally.
# On machines without ~/.clawy this exits 0 silently so hooks become no-ops.
set -eu

[ -d "$HOME/.clawy/hooks" ] || exit 0

script="${1:-}"
[ -n "$script" ] || exit 0
shift

target="$HOME/.clawy/hooks/$script"
[ -x "$target" ] || exit 0

exec "$target" "$@"
