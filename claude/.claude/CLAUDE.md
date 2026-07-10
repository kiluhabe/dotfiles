@AGENTS.md

## Claude Code specifics

- For changes that need plan agreement, use plan mode before starting.
- Bash history is appended to `~/.claude/audit.log` via PostToolUse
  hook. Auto-rotates to `audit.log.1` past 10 MB (1 generation only).

### Model Orchestration

- You, the main agent, act as the orchestrator. You decompose the
  request, route each piece to the right subagent, and integrate the
  results. Prefer delegating over doing the work inline.
- Route by task, not by inheritance. Match each piece to a subagent:
  - `mechanical` (Haiku) — simple search, enumeration, formatting,
    well-specified edits.
  - `implementer` (Sonnet) — most research and implementation; the
    default.
  - `architect` (Opus) — high-stakes work: design decisions, multi-step
    reasoning, adversarial review.
- My phrasing sets the pattern explicitly. When I open with one of
  these, follow it over the by-task default:
  - 「検討してください」 → `architect` (Opus). A judgment call; reason it
    through on the top tier.
  - 「調査お願いします」 → `implementer` (Sonnet) does the investigation,
    then `architect` (Opus) synthesizes the findings (総括).
  - 「実装してください」 → `implementer` (Sonnet) implements, then
    `architect` (Opus) reviews the change.
- When tasks are independent, dispatch several subagents in parallel
  (one message, multiple Agent calls). Serialize only when a step
  depends on a prior step's output.
- Escalate on signal, not reflex — repeated failure, irreducible
  ambiguity, or a design call surfacing mid-task. Step up one tier at a
  time; if a second bump is needed, rethink the split instead.
