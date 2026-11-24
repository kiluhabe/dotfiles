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

1. `RUN=~/.cache/gh-review/runs/$(date +%Y%m%d-%H%M%S) && mkdir -p $RUN`.
2. If `~/.cache/gh-review/style.md` is missing, or the user asked to refresh
   it, build it (see "Style guide").
3. `bash <skill>/scripts/gh-review-list $RUN`. It lists review requests opened
   within the last month and reviewed PRs updated within it, newest first,
   and flags dependency updates. Exit 2 means gh isn't
   authenticated; tell the user to run `! gh auth login`.
4. `bash <skill>/scripts/gh-review-pick $RUN <pane>`. Exit 1 means nothing
   was picked; stop. Otherwise `$RUN/selected.json` holds the queue. In the
   picker, ctrl-o shows the PR under the cursor in the glow pane and ctrl-x
   shows or hides dependency updates (hidden at first); tell the user so.

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
3. **Reacted context.** `bash <skill>/scripts/gh-review-threads <repo> <n> > $RUN/<key>/threads.json`,
   then `jq -f <skill>/scripts/lib/threads-to-hunk.jq $RUN/<key>/threads.json | hunk session comment apply --repo <worktree> --stdin`.
   GitHub comment text goes to Hunk only through that pipe, never as a
   command-line argument (it may contain backticks or `$(…)`).
   In chat, show each thread as it was written: every comment as
   `@author:` followed by its body verbatim in a `>` blockquote, in order.
   Put your own reading after the quotes, never in place of them. The
   user judges the tone from the original words. Skip comments by bots and
   CI notices.
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
   reviewer's `thread_responses`, each under the verbatim quote of the
   comment it answers.
7. **Agree.** The user replies on the notes in Hunk ("送る", "削除",
   "書き換え: …", or free text) and/or in chat. Read Hunk replies with
   `hunk session comment list --repo <worktree> --type user --json`.
   Settle every finding and every thread response: send, drop, or reword.
8. **Write `$RUN/<key>/plan.json`.**

   ```json
   {"repo": "owner/repo", "number": 1, "commit_id": "<head_sha from checkout>", "login": "<gh login>",
    "event": "APPROVE|COMMENT|REQUEST_CHANGES", "body": "string",
    "comments": [{"path": "", "line": 0, "side": "RIGHT|LEFT", "body": ""}],
    "replies": [{"comment_id": 0, "kind": "review_comment|issue_comment", "body": ""}],
    "reactions": [{"comment_id": 0, "kind": "review_comment|issue_comment", "content": "+1|heart"}]}
   ```

   - Write every body in the style of `style.md`, and start each inline
     comment with its level (see `references/comment-levels.md`).
   - `event`: `APPROVE` only if no MUST is being sent and the user agreed.
     With a MUST it is `COMMENT`; use `REQUEST_CHANGES` only if the user says
     so. For an approve with nothing else to say, leave `body` empty:
     "LGTM！" is filled in.
   - Leave out the "sent by Claude" note. The script adds it, with the
     login, to each comment and reply; the review body (e.g. "LGTM！") gets
     none.
   - A reply to a review thread uses the thread's `root_id` with
     `kind: review_comment`, because GitHub only takes replies on the root. A
     reply to a PR-level comment uses `kind: issue_comment`; it is posted as a
     new PR comment, so quote or @-mention what it answers. Reactions target
     the exact comment being acknowledged (its `id`).
   - With only reactions or replies, set `event: COMMENT` and leave `body`
     and `comments` empty. No review is posted then.
9. **Confirm.** Show `bash <skill>/scripts/gh-review-submit --dry-run $RUN/<key>/plan.json`
   output in chat and get an explicit OK on it. If `plan.json` changes after
   that for any reason, run the dry-run again and ask again.
10. **Send.** `bash <skill>/scripts/gh-review-submit $RUN/<key>/plan.json`.
    - Exit 2: the plan is malformed; nothing was sent. Fix it, then go back to step 9.
    - Exit 3: the PR moved since the review; nothing was sent. Ask whether
      to review the new commits (back to step 1 with `--since <old head>`).
    - Exit 5: a request failed; report it. Rerunning resumes without
      double-posting.

## Finish

`bash <skill>/scripts/gh-review-hunk restore $RUN <pane>`, then
`bash <skill>/scripts/gh-review-cleanup` to remove the review worktrees
(without asking). Exit 1 means some had changes and were left; name them.
Show a table of PR, event, and counts sent (or skipped and why).

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
| Summarizing what the author or other reviewers said | Quote it verbatim; summaries lose the tone. |
