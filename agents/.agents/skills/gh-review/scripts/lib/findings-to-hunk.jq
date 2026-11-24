# Input:  {"agent": reviewer name, "findings": findings.json .findings}
# Output: a `hunk session comment apply --stdin` batch.

.agent as $agent
| {comments: [.findings[] | {
    filePath: .path,
    summary: "[\(.level)] \(.title)",
    rationale: ([.body] + (if (.evidence // []) == [] then [] else ["evidence: \(.evidence | join(", "))"] end) | join("\n\n")),
    author: "claude:\($agent)"
  } + (if .side == "LEFT" then {oldLine: .line} else {newLine: .line} end)]}
