# First-pass review brief

Send this to the chosen reviewer (`architect` or `implementer`) with the
placeholders filled in. The reviewer writes a draft for discussion, not the
comments that get sent: wording is redone later in the user's style.

---

Review the pull request below and write your findings to `<run-dir>/<key>/findings.json`.

- PR: `<url>` (`<owner/repo>#<n>`), description in `<desc-file>`
- Code: worktree `<worktree>` at the PR head; review the diff `git diff <range>`<limited to: paths>
- Kind: `<new | reacted>`. For reacted, these threads are the earlier conversation; check whether each point was addressed and judge each reply:
  `<threads: comment_id, kind, author, body ...>`
- Comment levels: `<skill-dir>/references/comment-levels.md`

What to read, beyond the diff:

1. Every link in the description. GitHub issues/PRs with `gh`, Jira or Confluence with the Atlassian MCP tools when available, public pages with web-fetch. List the ones you couldn't read in `unread_links`.
2. The code around the change: callers and callees of what changed, the tests that cover it, and the repo's AGENTS.md / CLAUDE.md / contributing docs for conventions.
3. You may run the repo's existing tests or linters if they are quick. Do not edit any file.

`findings.json` has exactly this shape:

```json
{
  "summary": "two or three sentences: what the PR does and your overall verdict",
  "suggested_event": "APPROVE | COMMENT",
  "findings": [
    {"level": "MUST|WANT|NITS|Q|FYI", "path": "repo-relative path", "line": 0,
     "side": "RIGHT|LEFT", "title": "one line", "body": "the point and why", "evidence": ["file:line or URL"]}
  ],
  "thread_responses": [
    {"comment_id": 0, "kind": "review_comment|issue_comment",
     "reaction": "+1|heart|null", "reply_draft": "string or null"}
  ],
  "unread_links": []
}
```

- `line` is a line inside the diff on that `side` (RIGHT = new file, LEFT = removed lines). A point about code outside the diff goes on the nearest changed line, with the real location in `evidence`.
- `suggested_event` is `APPROVE` only when there is no MUST.
- `thread_responses`, reacted PRs only: `+1` for a reply that agrees or acknowledges, `heart` for one that reports a fix or thanks; `reply_draft` only when something still needs saying.

Reply with the path you wrote and one line of counts per level. No other report.
