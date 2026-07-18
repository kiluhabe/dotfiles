# Shared Agent Dotfile Rules

These rules apply to shared coding-agent dotfiles managed under `agents/.agents`.

## Context Economy Hooks

- `hooks/context-economy.sh` warns when a session repeats the same Read, repeats a similar Grep/Search, edits the same file too many times, or accepts a subagent response beyond the caller's word cap.
- `hooks/nudge-bash.sh` already blocks raw cat, bat, less, more, and head output except heredocs. Do not add a separate large-cat hook unless the existing behavior is intentionally narrowed first.
- `hooks/audit-summary.sh` summarizes audit logs by session, token fields when present, tool distribution, delegation count, and re-delegation rate.
