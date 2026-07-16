---
name: code-memory
description: >-
  Use when investigating, reading, or searching source files in a repository
  that may have been explored before, especially for repeated codebase
  spelunking, file role lookup, design overview recall, or stale per-file notes.
---

# code-memory

Persistent per-file notes about what source files do, invalidated by sha256.
Memory is an exploration index and understanding cache, not a substitute for
the current source file.

MEM=`~/dotfiles/agents/.agents/skills/code-memory/mem.py`
(Storage lives under `$XDG_CACHE_HOME/agent-memory`; no setup needed.)

## Startup Guard

1. If `python3 --version` fails, this skill is unavailable. Tell the user
   "code-memory requires Python3, so I will investigate normally" and skip the
   rest of this skill.
2. If `python3 $MEM query` prints the "sqlite3/FTS5 unavailable" warning, do
   not stop. Search continues through the grep fallback. Mention the setup
   guidance once if it matters to the user.

## Flow

1. Before reading or grepping code, run `python3 $MEM query "<question>"`.
   Each JSONL row is `{path, role_excerpt, recorded_sha, current_sha, stale}`.
2. Use `stale=false` hits to choose files, recall file roles, confirm known
   design summaries, and review previously found caveats.
3. For `stale=true` hits, run `python3 $MEM forget <file>`, then read the
   current file.
4. For implementation edits, line-level explanations, current concrete
   behavior, and security decisions, read the source file even when memory says
   `stale=false`.
5. Save only when the content has reuse value:
   `python3 $MEM save <file>` with
   `{"role":"...","symbols":["..."],"findings":["..."]}` on stdin.
6. If Markdown memories are edited by hand, run `python3 $MEM reindex`.
   Normal `query` searches the SQLite cache and does not reread every Markdown
   file.
7. Keep responsibilities separate: `mem.py` handles deterministic hashing,
   search, deletion, and reindexing. The LLM decides file roles, missing
   context, and whether a note is worth saving.

## When Memory Is Enough

Use memory for:
- Choosing candidate files to inspect
- Recalling file roles or known design summaries
- Checking prior caveats, constraints, and related symbols

Read the source file for:
- Implementation edits, reviews, and security decisions
- Line-level explanations or current behavior claims
- Cases where `stale=false` is not precise enough for the question
- Cases where role/findings are not enough evidence

## When To Save

Save when at least one is true:
- The file is likely to be referenced again
- The file role is not obvious from a quick read
- Understanding required multiple files
- You found reusable design decisions, constraints, or caveats
- Exploration took meaningful time or multiple searches

Do not save:
- Simple configuration files
- Obvious components
- Facts that are quick to rediscover
- Files that are unlikely to be read again

## Search Limits

SQLite FTS and the grep fallback are tuned for word searches across path,
role, symbol, and finding text. Markdown memory text and query text are
English-only because the current tokenizer is not reliable for Japanese
natural-language search. Use paths, symbols, alphanumeric keywords, and short
split English terms.

## Red Flags - STOP

- About to read or grep code without querying memory first? Query first.
- Treating this as an optional convenience? It is the exploration index.
- Skipping query because the file seems simple? Query first; then decide.
- Trusting `role_excerpt` without checking `stale`? Check `stale`.
- Assuming `stale=false` means source is unnecessary? Read source for edits,
  line details, behavior claims, and security decisions.
- Saving just because a file was read? Save only when the save criteria match.

## Rationalization Table

| Excuse | Reality |
|---|---|
| Reading directly is faster. | Query is cheap, and a valid role can save thousands of tokens. |
| The note might be stale, so I should read everything. | Query reports `stale`; forget only stale hits and reread those files. |
| There probably is no memory, so query is pointless. | Empty output is cheap; a hit is valuable. |
| Memory exists, so I do not need source. | Memory is an index. Source is the evidence for implementation and correctness. |
| Saving everything helps future runs. | Obvious notes increase context cost and search noise. |
