---
name: code-memory
description: Use when about to investigate, read, or grep source files in a repository you may have explored before — recall remembered file roles before re-reading code, and refresh notes whose source has changed. Symptoms: "what does X do", "where is Y handled", re-reading a file you looked at earlier, repeated codebase spelunking across sessions.
---

# code-memory

Persistent per-file notes about what source files do, invalidated by sha256.
Consulting memory before exploring is not optional — it is the first step.

MEM=`~/dotfiles/agents/skills/code-memory/mem.py`
(Storage lives under `$XDG_CACHE_HOME/agent-memory`; no setup needed.)

## 起動ガード
1. `python3 --version` が失敗 → このスキルは使用不可。「code-memory は Python3 が
   必要なため使えない。通常どおり調査する」とユーザーに伝え、以降の手順をスキップ。
2. `python3 $MEM query` 実行時に "sqlite3/FTS5 unavailable" 警告が出ても**停止しない**
   （grep で継続）。導入ガイダンス行はユーザーに一度だけ伝える。

## フロー（探索の前後で必ず）
1. **コードを読む/grep する前に**必ず: `python3 $MEM query "<問い>"`。
   JSONL の各行 = `{path, role_excerpt, recorded_sha, current_sha, stale}`。
2. `stale=false` のヒット → **そのファイルを読まない**。role_excerpt と .md を使う。
   問いに情報が不足していれば**その1ファイルだけ**読み、
   `python3 $MEM save <file>`（stdin に `{"findings":["…"]}`）で追記。
3. `stale=true` のヒット → `python3 $MEM forget <file>` してから現物を読み直す。
4. メモリに無いファイルを実際に探索したら → mechanical(Haiku) subagent に
   「Role 1段落＋Key symbols」を要約させ、`python3 $MEM save <file>` に
   `{"role":"…","symbols":["…"]}` を渡す（要約で main context を汚さない）。
5. 分業を厳守: hash/検索/削除/reindex = `mem.py`（決定論）、役割要約・不足判定 = Haiku。

## Red Flags — STOP
- 「ファイルを読もう / grep しよう」と思った → **まだ query していないなら STOP**。先に query。
- 「メモリツールはあれば便利なオプション」→ 違う。探索の前提。必ず引く。
- 「今回は単純だから query しなくていい」→ 単純かどうかは query してから決まる。
- 「role_excerpt にこう書いてある（stale 未確認）」→ `stale` を見ずに信じない。
- 「役割要約を自分で書く」→ Haiku に委譲する。

## Rationalization table
| 言い訳 | 現実 |
|---|---|
| ツールの存在は知っているが直接読む方が速い | query は数百ms。既存 role があれば再読の数千トークンを丸ごと省ける |
| メモが古いかもしれないから最初から読む | query は `stale` を返す。古ければそこだけ捨てればよく、全再読は不要 |
| メモに無いはずだから query は無駄 | 無ければ空 JSONL が返るだけ。コストはほぼ0、当たれば大きい |
