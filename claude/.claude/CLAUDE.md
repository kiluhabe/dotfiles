@AGENTS.md
@CLAUDE.WORK.md

## Claude Code specifics

- For changes that need plan agreement, use plan mode before starting.
- After creating a worktree with `git worktree add`, switch the session into
  it with `EnterWorktree` (`path`) so the tmux editor/diff panes follow.
- Bash history is appended to `~/.claude/audit.log` via PostToolUse
  hook. Auto-rotates to `audit.log.1` past 10 MB (1 generation only).
