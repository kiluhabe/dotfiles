@AGENTS.md

## Claude Code specifics

- For changes that need plan agreement, use plan mode before starting.
- Bash history is appended to `~/.claude/audit.log` via PostToolUse
  hook. Auto-rotates to `audit.log.1` past 10 MB (1 generation only).
