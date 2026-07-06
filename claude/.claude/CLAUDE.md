@AGENTS.md

## Claude Code specifics

- For changes that need plan agreement, use plan mode before starting.
- Bash history is appended to `~/.claude/audit.log` via PostToolUse
  hook. Auto-rotates to `audit.log.1` past 10 MB (1 generation only).

### Subagent model / effort routing

- Default to session inheritance. When unsure, leave model/effort
  unspecified and inherit.
- Guideline: Haiku for mechanical work (simple search, formatting,
  enumeration). Sonnet for most research/implementation. Opus for
  high-stakes work (design decisions, multi-step reasoning,
  adversarial review).
- Set effort by how multi-step the task is. Low for simple, medium
  for standard, high+ for involved reasoning.
- This is guidance, not a hard branch. Scale up with the cost of
  being wrong. Scale down when the work is cheap and reversible.
- A subagent that gets stuck should not push through. Return early
  with what it reached, the blocker, and what's missing.
  The caller can then re-delegate on a stronger model.
- Escalate on signal, not reflex. Watch for repeated failure,
  irreducible ambiguity, or a design call surfacing mid-task.
- Step up one tier at a time, roughly once per subtask. If a second
  bump is needed, rethink the split instead.
