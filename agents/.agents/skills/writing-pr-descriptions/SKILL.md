---
name: writing-pr-descriptions
description: Use when writing or updating a pull request description / PR body / cover letter (e.g. `gh pr create`, filling in a PR template, drafting the merge-request summary). Applies whenever you produce prose that explains a change to reviewers.
---

# Writing PR Descriptions

The diff already shows *what* changed and *how*. The description exists to carry what the diff cannot: why the change is needed, what it does beyond the code, and how a reviewer can trust it. Write only that.

## What the description IS

A PR description is these four things. Cover all four. They need not be four headings — merge or reorder to fit the change, but nothing in the four may be missing.

1. **意図 (Intent) — why.** What problem, need, or decision forced this change. The reader should understand why *not* making it was unacceptable. Not "added X" but "X was needed because …".
2. **影響 (Impact).** Behavior the change produces — both what tests pin down *and* what they don't: predicted runtime behavior, user-visible effects, downstream or operational consequences. Name the effects a reviewer can't infer from the diff alone.
3. **リスク (Risk).** What is gained and what is given up by merging this, and your confidence in each. State the failure modes you can foresee and how likely they are. If a risk is unverified, say so.
4. **検証手段 (Verification).** Steps a reviewer can reproduce to confirm the change works — commands, scenarios, expected output. Enough that they don't have to trust you.

## What to leave out

The diff is the source of truth for *what/how*. Do not restate it: no change-by-change file walkthrough, no re-listing of functions, flags, or config keys added, no "Changes" section that paraphrases the patch. If you find yourself narrating the implementation, delete it and ask instead: why, what effect, what risk, how to check.

## Quick reference

| Element | The question it answers | Not |
|---|---|---|
| 意図 | Why was this change necessary? | "What did I add" |
| 影響 | What behavior/effect results, tested and predicted? | Restating the code |
| リスク | What do we gain/lose, and how sure am I? | Silence / "no risk" |
| 検証手段 | How can the reviewer reproduce the check? | "Tested locally" |

## Common mistakes

- **Implementation dump.** A bullet list mirroring the diff. The diff is right there — cut it and write intent/impact/risk.
- **Missing why.** Starting from "Added…". If the opening sentence isn't a reason, rewrite it.
- **"No risk."** Every change trades something. If you truly see none, state what you checked to conclude that — that *is* the risk section.
- **Unreproducible verification.** "Confirmed it works" / "tested locally" gives the reviewer nothing. Give the command and the expected result.
