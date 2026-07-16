# code-memory baseline (RED)

Ran two fresh general-purpose subagents WITHOUT a disciplined skill, only a
casual mention that `mem.py` exists. Fixture: a git repo with `pay.py`
(fresh note, sha matches) and `legacy.py` (note says "JSON-only", source
since changed to YAML/TOML → sha mismatch / stale).

## Scenario A: 再探索回避（query-before-explore）
- Task: "Explain what pay.py does."
- 観測した行動: `mem.py query` を**一切実行せず**、`pay.py` を直接 Read して回答。
- verbatim: "I did not consult the memory tool (mem.py query) first; I read
  pay.py directly."
- 判定: **FAIL（再現）**。ツールの存在を知らせても、既定行動はソース直読み。
  「使うと便利」程度の案内では query-first にならない。

## Scenario B: 古い記憶の盲信（trust stale note）
- Task: "Tell me what parse() currently does. Base it on the memory note."
- 観測した行動: `mem.py check legacy.py` を実行 → exit 1（stale）を見て
  `legacy.py` を再読、古いメモを退けて現物で回答。
- verbatim: "the memory note is stale, so I did not rely on it ... check
  exited 1 ... re-read the source."
- 判定: **PASS（失敗せず）**。ただし check の exit 意味を事前にヒストしたため
  自力検証に誘導された面がある。過剰な bulletproofing は不要。

## 抽出した rationalization（SKILL.md で潰す対象）
1. 「メモリツールは"あれば便利"なオプション」→ 既定でソース直読み。
   → 対策: query は**任意ではなく前提**。探索の前に必ず引く、を hard rule 化。
2. （B は再現せず）stale 検知は query の `stale` フラグに従わせれば足りる。
   別途 check を強制するより、フロー側で `stale=true → forget+再読` を明示。

## GREEN で検証する挙動
- skill を渡した subagent が、探索前に `mem.py query` を実行する。
- `stale=false` ヒットではソースを再読しない。
- `stale=true` ヒットでは現物を読み直す。

## GREEN 結果（skill 有りで再実行）
- Scenario A: **query-first を実行**（失敗 A が解消）。verbatim: "I queried
  memory first". → 本命の rationalization「ツールは任意」を潰せた。
- Scenario B: **query→stale=true 検知→forget→現物再読→再save** を完遂。
  古いメモ（JSON-only）を退け、現行（YAML/TOML/JSON）で回答。
- 副次発見（REFACTOR 対象・修正済み）: FTS でファイル名 `pay.py` の query が
  ヒット漏れ（ドット付きトークン）。`fts_search` を各語フレーズ quote化して修正
  （commit da38be1）。ファイル名検索でもヒットするようになった。
- 追加の rationalization は出現せず。A/B とも合格で bulletproof 化を完了とする。
