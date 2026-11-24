# Input:  {"login": <viewer login>, "prs": [GraphQL PullRequest nodes]}
# Output: list.json entries, reacted first. PRs waiting on their author are
# dropped. Missing connections are treated as empty so callers and fixtures
# only need the fields that matter.

def is_bot: . != null and (.__typename == "Bot" or (.login // "" | endswith("[bot]")));
def login_of: if . == null then null else .login end;
def nodes($c): $c.nodes // [];
def truncated($c): ($c.pageInfo.hasNextPage // false) or ($c.pageInfo.hasPreviousPage // false);
# Dependency bots often run under a plain User account, so this looks at
# what the PR is (Renovate/Dependabot body, branch and title conventions)
# rather than who opened it.
def dependency_update:
  (.body // "" | test("(^|\n)(This PR contains the following updates|Bumps \\[)|Dependabot will"))
  or (.headRefName // "" | test("^(renovate|dependabot)[/-]"))
  or (.title // "" | test("^(chore|fix|build)\\(deps(-dev)?\\)|^Bump .+ from .+ to |^Update dependency |^Lock file maintenance|^Pin dependenc"; "i"));

.login as $me
| [.prs | unique_by(.id)[]
   | select((.isDraft // false) | not)
   | select(dependency_update | not)
   | select((.author | login_of) != $me)
   | . as $pr
   | [nodes(.reviews)[] | select(.state != "PENDING")] as $valid
   | ([$valid[] | select((.author | login_of) == $me)] | sort_by(.submittedAt) | last) as $mine
   | {
       repo: .repository.nameWithOwner,
       number,
       title,
       url,
       author: (.author | login_of),
       base: .baseRefName,
       head_sha: .headRefOid
     }
   + if $mine == null then
       {
         category: "new",
         untouched: ([$valid[] | select(.author | is_bot | not)] | length == 0),
         reasons: [],
         since_sha: null
       }
     else
       $mine.submittedAt as $t
       | ([nodes($pr.reviewThreads)[]
           | nodes(.comments) as $cs
           | select(any($cs[]; (.author | login_of) == $me))
           | $cs[]
           | select(.createdAt > $t and (.author | login_of) != $me and (.author | is_bot | not))]
          | length) as $replies
       | {
           category: "reacted",
           untouched: false,
           since_sha: $mine.commit.oid,
           reasons: [
             (if $replies > 0 then "replies:\($replies)" else empty end),
             (if any(nodes($pr.comments)[]; .createdAt > $t and (.author | login_of) == ($pr.author | login_of))
              then "author-comment" else empty end),
             (if $pr.headRefOid != $mine.commit.oid then "pushed" else empty end),
             (if any(nodes($pr.reviewRequests)[].requestedReviewer; .__typename == "User" and .login == $me)
              then "re-requested" else empty end),
             (if truncated($pr.reviews) or truncated($pr.reviewThreads) or truncated($pr.comments)
                 or any(nodes($pr.reviewThreads)[]; truncated(.comments))
              then "truncated" else empty end)
           ]
         }
       | select(.reasons | length > 0)
     end
  ]
| sort_by(.category != "reacted", .repo, .number)
