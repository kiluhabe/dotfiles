# Input:  {"plan": plan.json, "ranges": {path: {"RIGHT": [[start, end]], "LEFT": [...]}},
#          "sent": sent.json}
# Output: {"review": REST review payload or null, "replies": [...], "reactions": [...]}
# Inline comments outside the diff would be rejected by GitHub, so they are
# folded into the review body instead. Items already in sent.json are dropped
# so a rerun after a partial failure never posts twice.

.plan as $p
| .ranges as $ranges
| .sent as $sent
| "<sub>このレビューは Claude が @\($p.login) と合意して送信しました</sub>" as $review_note
| "<sub>この返信は Claude が @\($p.login) と合意して送信しました</sub>" as $reply_note
| def in_diff: . as $c | any(($ranges[$c.path][$c.side] // [])[]; $c.line >= .[0] and $c.line <= .[1]);
  ($p.comments // []) as $comments
| [$comments[] | select(in_diff)] as $inline
| [$comments[] | select(in_diff | not) | "**`\(.path):\(.line)`**\n\n\(.body)"] as $moved
| (if ($p.body // "") == "" and $p.event == "APPROVE" then "LGTM！" else $p.body // "" end) as $body
| {
    review: (if $sent.review != null then null else {
      commit_id: $p.commit_id,
      event: $p.event,
      body: ([$body | select(. != "")] + $moved + [$review_note] | join("\n\n")),
      comments: $inline
    } end),
    replies: [($p.replies // [])[] | select(.comment_id as $id | $sent.replies | index($id) | not)
              | {comment_id, body: "\(.body)\n\n\($reply_note)"}],
    reactions: [($p.reactions // [])[] | select(.comment_id as $id | $sent.reactions | index($id) | not)]
  }
