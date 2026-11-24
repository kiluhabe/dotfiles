# Input:  {"plan": plan.json, "ranges": {path: {"RIGHT": [[start, end]], "LEFT": [...]}},
#          "sent": sent.json}
# Output: {"review": REST review payload or null, "replies": [...], "reactions": [...]}
# Inline comments outside the diff would be rejected by GitHub, so they are
# folded into the review body instead. Items already in sent.json are dropped
# so a rerun after a partial failure never posts twice. A plain COMMENT with
# nothing in it is not sent at all, so a reactions-only plan posts no review.
# The "sent by Claude" note goes on each comment and reply, never on the
# review body itself, so a bare approve reads just "LGTM！".

.plan as $p
| .ranges as $ranges
| .sent as $sent
| "<sub>このコメントは Claude が @\($p.login) と合意して送信しました</sub>" as $comment_note
| "<sub>この返信は Claude が @\($p.login) と合意して送信しました</sub>" as $reply_note
| def in_diff: . as $c | any(($ranges[$c.path][$c.side] // [])[]; $c.line >= .[0] and $c.line <= .[1]);
  [($p.comments // [])[] | .side //= "RIGHT" | .body = "\(.body)\n\n\($comment_note)"] as $comments
| [$comments[] | select(in_diff)] as $inline
| [$comments[] | select(in_diff | not) | "**`\(.path):\(.line)`**\n\n\(.body)"] as $moved
| (if ($p.body // "") == "" and $p.event == "APPROVE" then "LGTM！" else $p.body // "" end) as $body
| {
    review: (if $sent.review != null
                or ($p.event == "COMMENT" and $body == "" and ($inline | length) == 0 and ($moved | length) == 0)
             then null else {
      commit_id: $p.commit_id,
      event: $p.event,
      body: ([$body | select(. != "")] + $moved | join("\n\n")),
      comments: $inline
    } end),
    replies: [($p.replies // [])[] | select(.comment_id as $id | $sent.replies | index($id) | not)
              | {comment_id, kind: (.kind // "review_comment"), body: "\(.body)\n\n\($reply_note)"}],
    reactions: [($p.reactions // [])[] | select(.comment_id as $id | $sent.reactions | index($id) | not)]
  }
