---
name: hunk-review
description: Interacts with live Hunk diff review sessions via CLI. Inspects review focus, navigates files, hunks, and exact lines, reloads session contents, adds inline review comments, and paints attention marks on character ranges. Use when the user has a Hunk session running or wants to review diffs interactively.
---

# Hunk Review

Run `hunk skill show hunk-review` and follow its output. On Hunk versions
without `skill show` (0.23), read the file printed by `hunk skill path` instead.
Either way the instructions ship with the installed binary, so they match its CLI.

Do NOT run `hunk diff`, `hunk show`, or other interactive commands yourself;
the TUI belongs to the user. If `hunk session list` finds no session, ask the
user to start Hunk in the tmux diff pane.
