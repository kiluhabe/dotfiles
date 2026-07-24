---
name: deciding-oversight-mode
description: Use when deciding how much a human should stay involved while an AI agent does a task, before any planning or coding, given an issue or task description. Symptoms - unsure whether to approve each step (HITL / human-in-the-loop) or let it run and review after (HOTL / human-on-the-loop); task is vague or underspecified; success is subjective, visual, or "feels right"; the change is irreversible or touches production. Produces a judgment context to hand off to a planning tool, not a plan.
---

# Deciding Oversight Mode (HITL vs HOTL)

## Overview

**Oversight mode follows from verifiability.** If the goal of a piece of work can be checked by available automated means, the agent can run it and the human reviews the result (**HOTL**, human-on-the-loop). If it cannot, the human must approve as it goes (**HITL**, human-in-the-loop).

Two rules make this real:
- **Decide per phase, not per task.** Almost every task mixes modes (investigate / decide / implement / verify). Classify each phase on its own.
- **This skill STOPS at the judgment.** It produces a *judgment context* — the goal, the per-phase modes, and why — and hands off to the planning tool (Superpowers plan / OpenSpec / AI-DLC). It does not write the plan, commits, or PR.

## When to Use

- Before planning or coding, when handed an issue or a task description.
- When unsure how autonomous to let the agent be.
- When success is subjective/visual, the task is vague, or the change is hard to undo.

**Not for:** producing the implementation plan itself (that is the planning tool's job — hand off after this).

## The Procedure

1. **Refine the goal to a sufficient condition.** Restate the goal so that "goal met" ⟺ "issue/task satisfied", and so it is *checkable* (you can state a pass/fail condition).

   **1a. Diagnose definability first.** Before refining, check whether a completion function f(artifact) -> {done, not done} can be defined so that independent implementers converge on the same verdict. Run this once against the goal as a whole, not per-phase.

   Score two axes (do not score the five symptoms independently — they are correlated; treat them as a symptom checklist per axis, not five separate deductions):

   - **Axis (a) — is there an observable signal at all?**
     - *Verifiability*: can you write a test/observation procedure? (bug fix: repro steps + expected behavior; improvement: a metric + a measurement method)
     - *Boundedness*: does the scope have a hard edge? ("etc.", "as needed", "on an ongoing basis" are deduction signals)
     - *Observability*: is the judgment material observable from the artifact itself? ("satisfaction" and similarly unobservable qualities are deduction signals)
   - **Axis (b) — does the signal map to a threshold multiple people share?**
     - *Uniqueness*: would independent implementers picture the same done-state? ("appropriately", "flexibly", "as needed" are deduction signals)
     - *External-dependency fixation*: does the verdict avoid depending on a reviewer's/stakeholder's taste, mood, or nuance?

   Classify the goal:
   - **Defined** — both axes hold with what you already know. Proceed to refine (below).
   - **Definable** — an axis fails only for lack of information that could close the gap. Before asking the user, search first (see Searching below) — investigate as much as you can on your own. Then ask the user the specific missing piece(s). On answer, re-run this diagnosis (Defined / Definable / Indefinable again). No retry limit — keep asking until it resolves.
   - **Indefinable** — an axis fails for a reason that no added information fixes (e.g. an inherently aesthetic judgment, a scope with no closable edge). **Stop here.** Tell the user f cannot be defined to converge across independent judges, and ask them to redefine the goal. Do not proceed to phase-splitting. No retry limit — wait for the redefinition.

   Note: passing this check is a floor, not a quality bar — a trivial, vacuous f (e.g. one that only confirms "something changed") can pass Defined and still be useless. Watch for that when accepting a Defined verdict.

   Refine the gap by:
   - **Searching.** Before asking the user anything, investigate as much as you can yourself. Search isn't limited to the issue's linked issues/PRs/dashboards — extend into the codebase: existing implementation, whether tests/CI/benchmarks already exist for this area, prior art for similar features, and spec docs (README, AGENTS.md/CLAUDE.md). Delegate broad or multi-file exploration to the Explore subagent (read-only, doesn't consume main context). This search directly feeds the definability diagnosis above — confirm whether verification means (tests/CI/benchmarks) actually exist in code before scoring Axis (a) low; don't guess.
   - **Asking the user** the minimum questions that close the remaining gap.

   Stop when the goal is a checkable sufficient condition. A goal you cannot make checkable is itself a signal (step 3).
2. **Split into phases.** Typical: investigate → decide/scope → implement → verify. Later steps classify each separately.
3. **Classify each phase by verifiability:**
   - Phase goal is verifiable by **available automated means** (tests, typecheck, CI, lint, scripts, metrics/dashboards) → **HOTL**.
   - Not verifiable, or existing means are insufficient (subjective/visual/taste, diagnosis, scoping) → **HITL**.
4. **Reversibility override.** If a phase does something irreversible or high-blast-radius (production, shared state, external send, unrecoverable deletes, a must-preserve invariant) → **HITL regardless of verifiability**.
5. **Reclassify via new verification.** If a phase is HITL *only because a verification means is missing but could be introduced* (a screenshot/visual-regression baseline, a benchmark, a metric assertion, a golden test), **propose introducing it**. If adopted and it makes the goal checkable → **reclassify that phase to HOTL** and lower the human's role to reviewing the result. Do not leave it as a human gate once the check exists.
6. **Emit the judgment context and STOP.** Write the output contract below to a handoff file, then hand off. Do not continue into planning or implementation.

## Output Contract (the judgment context)

State exactly these, in order. This is the whole deliverable:

- **Goal:** the refined, checkable sufficient condition.
- **Definability:** Defined / Definable / Indefinable for the goal as a whole. If it took more than one round (Definable → re-diagnosed), note briefly what closed the gap.
- **Questions:** resolved (with answers) and any still open.
- **Phases:** a table — `phase | mode (HITL/HOTL) | why (verifiable-by-X / not-verifiable / irreversible) | gate (what the human approves, if HITL)`.
- **Proposed new verification:** the means to introduce (if any) and the reclassification it enables.
- **Handoff:** which planning tool takes this next (Superpowers plan / OpenSpec / AI-DLC).

Write it to a **handoff file outside the codebase** (a scratch/plan location, not tracked source) so the planning tool consumes it and the repo history stays clean.

## Per-Phase Decision

This graph runs only after step 1a has classified the goal as **Defined** (or reclassified to Defined via Definable). An **Indefinable** or unresolved **Definable** goal never reaches phase-splitting.

```dot
digraph oversight {
  rankdir=LR;
  v [label="Phase goal verifiable\nby available automation?" shape=diamond];
  irr [label="Irreversible /\nhigh blast radius?" shape=diamond];
  intro [label="Verification means\nintroducible?" shape=diamond];
  hotl [label="HOTL" shape=box];
  hitl [label="HITL" shape=box];
  hotl2 [label="HOTL\n(after introducing it)" shape=box];

  v -> irr [label="yes"];
  irr -> hitl [label="yes"];
  irr -> hotl [label="no"];
  v -> intro [label="no"];
  intro -> hotl2 [label="yes, adopt"];
  intro -> hitl [label="no"];
}
```

## Common Mistakes

- **Writing a full execution plan here** (worktree, commits, PR). STOP at the judgment context; planning is a separate tool. This is the most common failure.
- **Classifying the whole task as one mode.** Split into phases — most tasks are mixed (e.g. scope=HITL, implement=HOTL, visual check=HITL).
- **Treating "success is subjective" as permanently HITL** without asking whether a verification means could be introduced (step 5). Introducing a screenshot/benchmark often converts a human gate into an automated check.
- **Skipping goal refinement.** A vague goal is not verifiable, so everything collapses to HITL. Refine to a checkable condition first.
- **Leaving the goal un-checkable.** If you cannot state a pass/fail condition, you have not refined enough — or the phase is genuinely HITL. Say which.
- **Skipping 1a and going straight to goal refinement.** If the goal is inherently Indefinable, repeated refinement attempts loop forever without converging. Diagnose definability first — don't discover it's impossible after several refinement passes.
- **Asking the user a Definable question before checking the codebase.** If the answer is discoverable from existing tests, CI config, or prior art, searching first is cheaper than a round-trip to the user.
