---
name: defining-specs
description: Use when turning an issue, a feature request, or an oversight-mode handoff into a spec and a task list before any code is written, with OpenSpec, Superpowers plans, AI-DLC, or any spec-driven workflow. Symptoms - about to write a spec straight from reading the issue; unsure whether a design fork should be decided now or asked about; a task list derived from a spec nobody reviewed; spec and tasks produced by one continuous context.
---

# Defining Specs

## Overview

**A spec is only as good as the boundaries it was built across.** Facts, decisions, and work items are three different artifacts; when one context produces all three, its early guesses become the spec's premises and nothing ever catches them.

This skill splits spec-writing into phases, routes each to the right subagent, and puts a **fresh-context adversarial review** plus a **human gate** between them.

**This skill STOPS at the task list.** It does not implement. Hand off to `subagent-driven-development`.

Position in the flow: `deciding-oversight-mode` → **this skill** → `subagent-driven-development` → `code-review`.

## When to Use

- You have an issue, a feature request, or a judgment-context handoff file, and need a spec + tasks.
- The repo uses OpenSpec (`openspec/`), Superpowers plans (`docs/superpowers/plans/`), or any spec-then-tasks workflow.

**Not for:** bug fixes with one obvious edit (just do it), or executing a spec that already exists (that's `subagent-driven-development`).

## Step 0: Inputs and Target

Do these before dispatching anything:

1. **Read the handoff file** from `deciding-oversight-mode` if one exists. It gives you the refined goal, the definability verdict, and the per-phase HITL/HOTL table.
   - No handoff file → **STOP and ask the user** whether to run `deciding-oversight-mode` first. Do not synthesize the goal yourself. A goal you invented is a goal nobody agreed to. Asking is the whole move here: the user decides whether to run that skill, and running it is their call, not a step you take on their behalf.
   - Handoff verdict is `Definable` or `Indefinable` → **STOP.** Spec-writing on an undefined goal produces a spec that reads as agreed. Send it back.
2. **Detect the target format.** `openspec/` exists → OpenSpec change proposal + `tasks.md`. Otherwise → `writing-plans` (spec section + plan). State which one you detected, in one line.
3. **Map the HITL/HOTL table onto the phases below.** The handoff's table is keyed to *implementation* phases (investigate / decide / implement / verify), so it will not line up one-to-one with this skill's five. Map by subject matter — investigate → Research, decide/scope → Brainstorming — and **default any phase the table does not cover to HITL**. State the mapping in one line each. HOTL phases skip the *human* gate. **No phase ever skips the adversarial review.**
4. **Pick the artifact location.** One numbered file per phase artifact and one per gate record, in a scratch directory outside the repo — unless the detected format prescribes an in-repo path (OpenSpec's `openspec/changes/<id>/`), in which case use that for the spec and tasks and keep gate records in scratch. Gate records are process exhaust; they don't belong in the repo's history.

## The Phases

| # | Phase | Produces | Route to | Adversarial reviewer |
|---|---|---|---|---|
| 1 | Research | research brief | `implementer` (wide search → `scout`) | `architect` |
| 2 | Brainstorming *(conditional)* | resolved forks | `architect` + `brainstorming` skill | human is the reviewer |
| 3 | Define Spec | spec document | `implementer` | `architect` |
| 4 | Brainstorming *(conditional)* | resolved forks | `architect` + `brainstorming` skill | human is the reviewer |
| 5 | Define Task | task list | `implementer` + `writing-plans` | `architect` |

Phases 2 and 4 are **conditional on an observable predicate**: run them if and only if the preceding phase's artifact has a non-empty **Open Forks** section. Empty → skip to the next phase.

`scout` is read-only and returns locations, so it feeds a phase, never produces one: the phase's producer writes the artifact from what scout returns.

### Artifact contracts

Each phase's artifact IS the sections below, in order. A phase output missing a section is not done.

**Research brief** — `Facts` (each with the file path / URL / command it came from) · `Prior art` · `Constraints` · `Open Forks` · `Unknowns` (what could not be established, and why).

Research records what is; it does not choose. Every design choice with more than one defensible answer goes in **Open Forks**, phrased as a question with the candidate answers and their trade-offs. Choosing one is phase 2's job, and phase 2's decider is the human.

**Spec document** — `Goal` (copied from the handoff, verbatim) · `Requirements` (each one checkable — a reader can say pass or fail) · `Decisions` (each with the fork it resolves and who resolved it) · `Non-goals` · `Open Forks`.

**Task list** — whatever the detected format prescribes (`writing-plans` task structure, or OpenSpec `tasks.md`). Every requirement in the spec maps to at least one task; every task cites the requirement it serves.

## The Gate Between Phases

After every phase, in this order, before the next phase starts:

1. **Adversarial review.** Dispatch a **fresh** `architect` subagent. Give it: the phase's *input artifact* and its *output artifact*, and the instruction to find where the output overreaches, assumes, or drops something. Ask for findings, not a verdict of approval.
2. **Human review** — unless the handoff marks this phase HOTL. Present the artifact and the review findings. Wait for the human.
3. Only then dispatch the next phase.

**The reviewer gets the artifacts, never the producer's summary.** A summary is the producer's own account of its work; reviewing it produces agreement, which is not review.

**The reviewer must be a fresh context.** Not the producing agent, not the agent that reviewed the previous phase, not you.

**One round per phase.** Apply the findings you accept, note the ones you reject and why, and take both to the human gate. Do not dispatch a second reviewer at the same artifact — that is the next phase's reviewer's job, since it reads this artifact as its input.

**Brainstorming phases (2 and 4) get no separate architect review.** Their artifact is a record of fork resolutions and the human resolved them, so the human gate *is* the review. Every other phase gets both.

**If you cannot afford a dispatch for every producer and every reviewer, spend the budget on reviewers** and produce the artifact yourself. Say in your report which artifacts you produced in the orchestrating context — a self-produced artifact still got an independent reviewer, which is the property that matters.

**No exceptions:**
- Not when the phase output "is obviously fine"
- Not when the phase was small
- Not when the review of the previous phase already covered this area
- Not by asking the producing agent to self-review instead
- Not by folding two phases into one dispatch to save a gate
- HOTL removes the human gate only. The adversarial review is not a human gate.

## Red Flags — STOP

- You are writing the spec yourself, in this context, instead of dispatching phase 3
- A design fork got decided inside Research ("I decided X because Y")
- Spec and tasks came out of the same dispatch
- You handed the reviewer your summary of the artifact
- "The handoff file doesn't exist, but the goal is clear enough"
- "Phase 1 and 3 are both HOTL, so I'll just run them back to back"
- "This spec is small, one review at the end covers it"

**All of these mean: back up to the last completed gate and run the phase properly.**

## Rationalizations

| Excuse | Reality |
|--------|---------|
| "The design choice is obvious, no need to log a fork" | Obvious to you inside the phase. The fork section is where the human learns a choice existed at all. |
| "I'll note the decision in the spec and the human can object" | A decision inside a spec reads as settled. Nobody objects to prose that sounds agreed. Forks get asked, not asserted. |
| "One review at the end is cheaper" | The end reviewer inherits phase 1's wrong premise and reviews the spec as built on it. Per-phase review is the only place a premise is still cheap to reject. |
| "The producing agent knows the artifact best" | It knows what it meant. The reviewer's value is not knowing that. |
| "Reviewing every phase is slow" | Slower than a spec that gets implemented and thrown away. |
| "HOTL means the agent can run unsupervised" | HOTL removes the human from the loop, not the reviewer. Autonomy is what makes adversarial review load-bearing. |
| "No handoff file, but I can infer the goal from the issue" | Inferring the goal is `deciding-oversight-mode`'s whole job, and it has a definability check you don't. |

## Handoff Out

When the task list has passed its gate, state: the artifact paths, which phases ran HOTL, and any Open Forks that were deliberately left open. Then hand off:

**REQUIRED SUB-SKILL:** Use `subagent-driven-development` to execute the task list.

Do not begin implementation in this context.
