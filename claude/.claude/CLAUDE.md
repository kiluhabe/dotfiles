@AGENTS.md

## Claude Code specifics

- Delegate large or cross-file exploration to the Explore subagent /
  Agent tool to preserve main context. After delegating, don't re-run
  the same search.
- For changes that need plan agreement, use plan mode before starting.
- Bash history is appended to `~/.claude/audit.log` via PostToolUse
  hook. Auto-rotates to `audit.log.1` past 10 MB (1 generation only).
- Fire independent Read / Bash / Agent calls in parallel within a single
  message. Serialize only when later calls depend on earlier results.
- When a subagent cannot write files (e.g. Explore, Plan, or any
  read-only agent), have it return the proposed content in its summary.
  The main agent reviews it and performs the actual Write/Edit. Don't
  swap in a write-capable agent just to skip the review step.
