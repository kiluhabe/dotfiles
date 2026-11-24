# Input:  gh-review-threads output
# Output: a `hunk session comment apply --stdin` batch, one note per earlier
# thread. Comment text from GitHub only ever travels as JSON, never as argv.

{comments: [.threads[] | select(.line != null) | {
    filePath: .path,
    author: "github:\(.comments[0].author)",
    summary: ((if .resolved then "[resolved] " else "" end)
              + "@\(.comments[0].author): \(.comments[0].body | split("\n")[0])"
              + (if (.comments | length) > 1 then " (+\(.comments | length - 1) replies)" else "" end)),
    rationale: ([.comments | to_entries[]
                 | "@\(.value.author) (\(if .key == 0 then "root_id" else "id" end) \(.value.id)): \(.value.body)"]
                | join("\n\n"))
  } + (if .side == "LEFT" then {oldLine: .line} else {newLine: .line} end)]}
