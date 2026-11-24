---
name: gh-review
description: Use when the user wants to work through the GitHub pull requests waiting on their review — "レビュー依頼を捌く", "PR レビューを回す", "review my requested PRs" — including PRs where the author has replied to or pushed after the user's earlier review. Needs gh, tmux (txdf layout with glow viewer and Hunk diff panes), fzf and jq.
---

# gh-review

## Overview

Turns the user's review queue into sent reviews, one PR at a time: collect
and classify, let the user pick, have a subagent do a first-pass review,
put its findings in Hunk, agree with the user on what to send, then send it
in the user's own voice with a note that Claude sent it on their behalf.

Nothing reaches GitHub without the user's explicit OK on the exact payload.
That covers reviews, replies, reactions, and clones.

`<skill>` below is this skill's directory. Scripts that call `gh`, `git` or
`tmux` must run with the sandbox disabled: gh fails TLS inside it, and git
and tmux write outside the workspace. Pass `$TMUX_PANE` as `<pane>`.

## Setup (once per run)

1. `RUN=~/.cache/gh-review/runs/$(date +%Y%m%d-%H%M%S)`.
2. If `~/.cache/gh-review/style.md` is missing, or the user asked to refresh
   it, build it (see "Style guide").
3. `bash <skill>/scripts/gh-review-list $RUN`. Exit 2 means gh isn't
   authenticated; tell the user to run `! gh auth login`.
4. `bash <skill>/scripts/gh-review-pick $RUN <pane>`. Exit 1 means nothing
   was picked; stop. Otherwise `$RUN/selected.json` holds the queue.

## Per PR (in selected.json order)

`<key>` is `<owner>__<repo>__<n>`; keep this PR's files in `$RUN/<key>/`.

1. **Checkout.** `bash <skill>/scripts/gh-review-checkout <repo> <n> [--since <since_sha>]`
   (`--since` only for reacted). Exit 4 = no clone under `~/work` or `~/code`:
   ask whether to clone and into which root, then rerun with
   `--clone-into <root>`, or skip the PR if declined. If `fallback_full` is
   true, tell the user the last reviewed commit is gone (force push) and the
   whole PR is shown.
2. **Show it.** `tmux-glow-open $RUN/desc/<key>.md`, then
   `bash <skill>/scripts/gh-review-hunk open $RUN <pane> <worktree> <range>`,
   adding `-- <paths...>` from the checkout output for reacted PRs. Exit 6 =
   no diff pane, exit 7 = Hunk didn't start; report and stop.
3. **Reacted context.** `bash <skill>/scripts/gh-review-threads <repo> <n>`.
   Put each earlier thread into Hunk with
   `hunk session comment add --repo <worktree> --file <path> --new-line <line> --author <login> --summary <first line>`
   (`--old-line` for `side: LEFT`), replies with `--reply-to`.
4. **Pick the reviewer** and tell the user in one line why:
   - `architect` for design or structural changes, public interfaces,
     schemas or migrations, auth and security, concurrency, large changes
     spanning layers, or a reacted PR whose open points were about design.
   - `implementer` otherwise (the default).
5. **First pass.** Dispatch it with `references/review-brief.md`, filled in.
   Wait for `$RUN/<key>/findings.json`.
6. **Into Hunk.**
   `jq --arg agent <reviewer> '{agent: $agent, findings: .findings}' $RUN/<key>/findings.json | jq -f <skill>/scripts/lib/findings-to-hunk.jq | hunk session comment apply --repo <worktree> --stdin --focus`.
   In chat, give the summary, counts per level, `unread_links`, and the
   reviewer's `thread_responses`.
7. **Agree.** The user replies on the notes in Hunk ("送る", "削除",
   "書き換え: …", or free text) and/or in chat. Read Hunk replies with
   `hunk session comment list --repo <worktree> --type user --json`.
   Settle every finding and every thread response: send, drop, or reword.
8. **Write `$RUN/<key>/plan.json`.**

   ```json
   {"repo": "owner/repo", "number": 1, "commit_id": "<head_sha from checkout>", "login": "<gh login>",
    "event": "APPROVE|COMMENT|REQUEST_CHANGES", "body": "string",
    "comments": [{"path": "", "line": 0, "side": "RIGHT|LEFT", "body": ""}],
    "replies": [{"comment_id": 0, "body": ""}],
    "reactions": [{"comment_id": 0, "kind": "review_comment|issue_comment", "content": "+1|heart"}]}
   ```

   - Write every body in the style of `style.md`, and start each inline
     comment with its level (see `references/comment-levels.md`).
   - `event`: `APPROVE` only if no MUST is being sent and the user agreed.
     With a MUST it is `COMMENT`; use `REQUEST_CHANGES` only if the user says
     so. For an approve with nothing else to say, leave `body` empty:
     "LGTM！" is filled in.
   - Leave out the "sent by Claude" note. The script adds it to the review
     body and each reply, with the login.
9. **Confirm.** Show `bash <skill>/scripts/gh-review-submit --dry-run $RUN/<key>/plan.json`
   output in chat and get an explicit OK on it.
10. **Send.** `bash <skill>/scripts/gh-review-submit $RUN/<key>/plan.json`.
    - Exit 3: the PR moved since the review; nothing was sent. Ask whether
      to review the new commits (back to step 1 with `--since <old head>`).
    - Exit 5: a request failed; report it. Rerunning resumes without
      double-posting.

## Finish

`bash <skill>/scripts/gh-review-hunk restore $RUN <pane>`. Show a table of
PR, event, and counts sent (or skipped and why). Ask before removing the
worktrees under `~/.cache/gh-review/worktrees/`
(`git -C <clone> worktree remove <path>`).

There is no resume. Running the skill again re-lists everything: PRs you
reviewed drop out, and come back as reacted once someone responds.

## Style guide

1. `bash <skill>/scripts/gh-review-style-sample $RUN/style-sample.json`.
2. Dispatch `scout` with `model: haiku`: read that file and return a draft
   `style.md` (max 800 words). The draft covers sentence endings and
   politeness, emoji, how levels are written, how suggestions are phrased
   (suggestion blocks or not), length, and recurring phrases, with short
   generic examples.
3. Before showing the draft, remove any repository name, URL, person,
   product name, or code fragment from it. Show the draft and save it to
   `~/.cache/gh-review/style.md` only once the user approves. Then delete
   the sample file.

## Common mistakes

| Mistake | Instead |
|---------|---------|
| Posting with `gh api` directly | Always go through `gh-review-submit` (head check, diff-range check, note, resume). |
| Sending after "looks good" on the findings | The OK has to be on the dry-run payload. |
| Writing the "sent by Claude" note into `plan.json` | The script adds it; writing it too doubles it. |
| Running `hunk diff` in your own shell | It's a TUI; the diff pane gets it via `gh-review-hunk open`. |
| Reviewing every file of a reacted PR | Review the `range` from checkout; the earlier review covered the rest. |
| Copying repo or company names into `style.md` | It holds abstract traits only. |
