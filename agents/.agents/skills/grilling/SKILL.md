---
name: grilling
description: Use when explicitly invoked via /grilling on a plan, proposal, or design decision — before the user accepts it and before any implementation starts.
---

# Grilling

## Overview

Adversarial review of a plan, invoked on demand. The goal is to surface everything that
would embarrass the plan's author later — not to rubber-stamp it, and not to just list
generic caveats. Every question must be answerable by pointing at something concrete in
the plan (or at its absence).

## When to Use

- User runs `/grilling` against a plan, design doc, or proposal they just wrote or received.
- Before implementation starts, while the plan can still change cheaply.

**Not for:** reviewing code that's already written (that's code-review), or grilling a
one-line trivial decision with no real alternatives or failure surface.

## Core Pattern

Grill across exactly these four lenses. Skip a lens only if it's genuinely inapplicable
(say why in one line) — don't pad a lens with filler if the plan gives nothing to grab.

1. **Edge cases & failure scenarios** — concrete inputs/states that break the plan: what
   happens under load, on the failing dependency, on the concurrent write, on the empty/huge
   input, on rollback mid-way.
2. **Premise & scope validity** — is this even solving the right problem? Is the stated
   scope too big (solving problems nobody has yet) or too small (ignoring a requirement the
   plan itself implies)? What unstated assumption, if wrong, invalidates the whole plan?
3. **Alternatives comparison** — name at least one concrete alternative approach and say
   specifically why the plan's approach beats it, or why it doesn't. "Might be a simpler way"
   is not a finding; "approach X avoids the need for Y entirely, at cost of Z" is.
4. **Operability & maintainability** — what does this cost to run, monitor, debug, and roll
   back six months from now? Who gets paged, how do they know it's this system, how do they
   undo it?

Each question must cite what in the plan triggered it (a stated fact, or a specific gap).
Generic questions that would apply to any plan ("have you considered testing?") don't count.

## Output Format

```markdown
## Edge cases & failure scenarios
- [question] — triggered by: [what in the plan]
...

## Premise & scope validity
...

## Alternatives comparison
...

## Operability & maintainability
...

## Bottom line
[1-3 sentences: is this plan ready, or what must be resolved first]
```

## Common Mistakes

| Mistake | Fix |
|---|---|
| Listing generic best-practice reminders ("add tests", "add logging") | Only include questions the specific plan's content or gaps actually provoke |
| Treating all four lenses as equally weighted every time | Spend more space where the plan is actually thin; a one-line note is fine for a solid lens |
| Naming an alternative without a concrete tradeoff | State the specific cost/benefit delta, not just that an alternative "exists" |
| Softening into suggestions ("you might want to...") | State it as a question the plan must answer, not a nice-to-have |
