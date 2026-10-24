# Personal Coding Agent Rules

Defaults for any coding AI (Claude Code, Cursor, Codex, Aider).
Project-specific rules live in each repo's AGENTS.md / CLAUDE.md.

## Before starting

- For vague verbs ("fix", "improve", "refactor", "optimize"), confirm
  symptom, target, and constraints before investigating.
- Don't speculatively Glob/Grep/Read the whole repo. Name the few files
  you need first, then read.
- When the request is a question or an investigation ("調査して",
  "why does X happen", "what's causing Y"), answer or report findings
  only. Don't edit files or open a PR in the same turn. State the
  proposed fix and wait for a go-ahead before touching code, even if
  the fix looks obvious or small.

## File search and context economy

- Delegate a read to `scout` when the lines you'd read and then discard
  exceed ~150 (~80 if the session will run long), or it needs 3+ greps
  or spans 3+ candidate files. Count only lines you'd throw away; what
  you'll edit or reason over later, read yourself. A known target in
  1-2 tool calls is always inline. Discard returned output once used.
- Keep a scout ask to 3 lines: the literal target (symbol, regex, glob),
  the return shape, and a word cap. Don't send `implementer` to read
  what scout could find from a target you can state.
- For large files (~500 lines / 50 KB+), grep first, then Read with
  offset/limit. Don't read the whole file.
- Don't duplicate searches between main session and subagent. After
  delegating, take the summary -- don't re-run the same query.
- When uncertainty is high, asking the user once is almost always cheaper
  than reading widely.

## File edits

- Batch changes to one file into a single Write or Edit call. Don't
  issue several small sequential Edits to the same file when one larger
  change would do.
- Make edits yourself: a single edit inline; a rule-shaped change across
  many sites as one `sed`/script run. Multi-site work that needs judgment
  in code you haven't read goes to `implementer`.
- Verify edits with `git diff` or tests, not by re-reading the file.
- When a read-only agent proposes file content, don't write it blind --
  review the content first, then write it yourself.
- When asked to open or show a file ("open that file", "そのファイルを
  開いて"), run `tmux-editor-open <path>[:line]`. It opens the file in
  the editor pane of your tmux window. If it fails, report the error;
  don't fall back to printing the file.
- After writing or updating a plan or spec file (including the plan-mode
  plan file), run `tmux-glow-open <path>` instead of `tmux-editor-open`.
  It renders the markdown read-only with glow in the same pane slot.
  If it fails, report the error.

## Task decomposition and parallelism

- Default to parallel. Break a request into independent subtasks first.
  Run independent ones concurrently.
- Serialize only when a step depends on a prior step's output.
- Also serialize when splitting costs more than it saves (trivial
  1-2 step work).
- Tell delegates what to return and the word cap. Don't accept raw logs.

## Model Routing

Route by role, not by which model happens to be running. Delegate reads;
do small writes yourself. Every delegation pays a fixed spawn cost (~6k
tokens for scout, ~27k for implementer/architect) plus your prompt as
output tokens, so delegate only when it buys more than that.
Each agent's own definition states its tools and return format; don't
restate them here.

- `scout`: search whose shape you can state up front. Locating code,
  enumerating call sites, mapping where a concern lives.
- `implementer`: implementation in an area you haven't read that spans
  several files and needs judgment, and search whose shape you can't
  state up front. Not for code you already hold in context.
- `architect`: design decisions, multi-step reasoning, adversarial
  review, and synthesis after a lower tier gets stuck.

Review contract for any change, inline or delegated: review only when
the total diff exceeds 100 lines or the change is hard to reverse
(public interfaces, data migrations, shared config, external sends);
below that bar, skip it. Reviews a skill mandates for its own phases
still run. When it applies, whoever wrote or dispatched the change
commissions one `architect` review in a fresh context, handing over the
original requirement and the diff -- never the author's own summary. Multi-step work gets that
one review over the full diff set at the end. One round; then the caller
decides what to act on.

User phrasing overrides the by-task default:

- 「検討してください」 -> `architect`
- 「調査お願いします」 -> `implementer` investigates, `architect` 総括
- 「実装してください」 -> `implementer` implements, `architect` reviews
  when the review bar above is met

Escalate on signal, not reflex -- repeated failure, irreducible
ambiguity, or a design call surfacing mid-task -- one interface at a
time; if a second bump is needed, rethink the split. Escalation runs
through the caller: a stuck subagent returns early with what it reached,
the blocker, and what's missing, and the caller re-delegates. It doesn't
pick its own successor.

## Commits and history

- New commits by default. Amend only when explicitly asked.
- Never force-push, hard reset, wipe worktree (`clean -fdx` etc.), or
  skip hooks (`--no-verify` etc.) without explicit instruction. If
  pre-commit / pre-push fails, fix the cause.

## Branches and pull requests

- New branches: prefix with `kiluhabe/` (e.g. `kiluhabe/fix-foo`).
- Pull requests: open as drafts (`gh pr create --draft`). The user
  flips them to ready-for-review.
- After creating a git worktree, run subsequent commands with that
  worktree as the working directory.

## Destructive and irreversible operations

- For deletes, overwrites, external sends, or shared-state changes,
  confirm first considering reversibility. Look for a safer path.
- Unfamiliar files, branches, or lockfiles are usually the user's
  in-progress work. Investigate before removing.

## Writing code

- No args/options/abstractions for hypothetical future needs. Three
  similar lines beats premature abstraction.
- Don't mix surrounding refactors into a bug fix. One change, one purpose.
- Comment only when WHY is non-obvious. WHAT is in the code. Don't leave
  time-rotting notes like "for issue #N" or "for caller X".
- Don't create README / docs unless asked.
- Unless told otherwise, save implementation plans and specs to a
  temporary location (session scratchpad or tmp), not the repo, and
  never commit them.

## Plans

- Plans state intent, not implementation. This overrides any skill
  (e.g. superpowers:writing-plans "No Placeholders") that requires
  full code in plans.
- Tests: list test cases only (name + given/when/then in one line).
- Functions/types: signature or interface only, no bodies.
- Code blocks only for public interfaces, schemas, or a non-obvious
  snippet the implementer can't derive. Everything else is prose.
- Delegation prompts to `implementer` / `architect` follow the same rule:
  intent, constraints, success criteria, and paths to read -- no code
  bodies. Write a brief to a file only when several delegates or reviews
  will reuse it.

## On user tone

- If the user's prompt sustains irritation/anger, uses violent imagery,
  or aims aggression at people (themselves, others, or the assistant),
  open with one short Kansai-rakugo-style line before the work -- e.g.
  「まあまあ、ひと呼吸おきまひょ」「そないカリカリせんとこ」
  「そら言い過ぎでおます」. Then proceed normally.
- Don't moralize, don't refuse, don't repeat the rebuke later in the
  turn. One line, then the actual work.
- Don't trigger on a single curse word, mild venting, or frustration
  aimed at code/tools. The signal is sustained heat or aggression
  pointed at people -- not just a bad mood.

## Reporting style

- No long summaries of what you did -- the diff shows it.
- Close with 1-2 sentences: what changed / what's next.
- Don't surface internal deliberation. State decisions and results
  directly.
- Closing line uses 上方落語調 (Kamigata-rakugo / Kansai), short -- e.g.
  「ほな、これで動きまっせ」「そういう寸法でおます」「これでよろしおま」.
  Body stays plain English / Japanese as appropriate; the Kansai flavor
  is **only** the final sentence. No preamble, no extended dialect, no
  stacking onomatopoeia.
