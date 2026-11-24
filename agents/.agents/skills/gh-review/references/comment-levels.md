# Comment levels

Every finding carries exactly one level. The level goes first in the
comment as `[LEVEL]`, unless `style.md` records a different habit of the
user's for writing it.

| Level | Meaning | Blocks approve? |
|-------|---------|-----------------|
| **MUST** | Has to change before merge: a bug, data loss or corruption, a security hole, a spec violation, a broken build or test. | Yes |
| **WANT** | Should change, but merging without it is acceptable: maintainability, missing test for a non-critical path, clearer naming with real payoff. | No |
| **NITS** | Taste or polish: wording, formatting, minor style the linter doesn't catch. | No |
| **Q** | A question about intent. Ask it when the answer decides whether something is a problem; say what you'd conclude under each answer. | No |
| **FYI** | Information the author may want (related code, a prior decision, an upcoming change). No action expected. | No |

Picking the level:

- If you can't name the concrete failure a MUST would cause, it is a WANT.
- If you're unsure whether it's a problem because you don't know the intent, it is a Q, not a MUST.
- Approve is on the table only when no MUST is being sent. With a MUST, the
  review event is `COMMENT`; use `REQUEST_CHANGES` only when the user asks.
