---
name: japanese-writing
description: Style norms for writing and revising Japanese prose (book chapters, drafts, articles, explanatory text). Covers formatting, paragraph/argument structure, logical rigor, reader cognitive load, voice, rhetorical restraint, banning empty LLM-isms, and cutting redundancy. Use when writing or editing Japanese documents.
---

# Japanese Writing Norms

Follow these norms when writing or revising Japanese prose.
(Rules govern Japanese-language output; examples stay in Japanese.)

## Formatting

- One sentence per line; separate paragraphs with a blank line.
- Put code, diffs, logs, and config fragments in code blocks.
- Push side notes (term origins, names of formalizations) into footnotes
  (`[^label]`), not the main text.
- Enumerated definitions/classifications may be bullet lists. Bold the
  term being defined.
- Bold a term at its first defining introduction. For an already-introduced
  term used as a topic, and for quotes/nicknames, use 「」 — not bold.
- Do not use dashes (em `—`, horizontal bar `―`, doubled「——」) in Japanese
  running text or headings. For appositive insertion use parentheses（）;
  for restatement split into two sentences with 句点 or join with 読点.
  En dash `–` for ranges, English compounds (`Curry–Howard`), code, and
  bibliographic data are exempt.
- Do not use 中黒（・）for Japanese coordination; allowed inside a single
  proper noun.
- Do not cram two elements into a heading with a rule/dash
  (「種別──主題」). Headings are a single natural phrase; column headings
  name the content (「同値関係としての分類」), not just a category (「基礎」).
- For term-definition bullets use a full-width colon: 「**用語**：説明」.

## Paragraph and argument structure

Default to paragraph writing: each paragraph is one step of the argument,
followable on its own.

- One topic per paragraph. Split long paragraphs that mix phases
  (investigation, report, verification, evaluation) into one step each.
- The first sentence tells the reader what the paragraph is about.
- Open each paragraph by marking its logical relation to the previous one
  (であれば / 実際 / しかし / この例自体からも).
- Argue in one direction. Do not conclude, then handle objections, then
  restate the conclusion. Finish objections and doubts first, then state
  the conclusion once.
- Defer defenses of an example (looks contrived, etc.) to the start of the
  next section; do not break the climax.
- Deny a likely misreading explicitly before giving the real reason
  (「その理由は『〜だから』ではない。〜だからだ」).
- When you write 「AではなくB」, add one sentence of grounds for the
  negation; counterfactuals (「もしAなら〜だっただろう」) often serve.
- In concessions (確かに〜), stay at fact-checking. Do not assert as the
  author a causal claim you later correct; attribute a surface diagnosis to
  the reader or received view (「〜と要約できてしまうかもしれない」).
- Do not preview climax information (numbers, specific facts) in the
  preceding paragraph.
- When negating/limiting, quote the exact proposition in 「」; avoid vague
  negations like 「何もかもが解決するわけではない」.
- Place forward references (「後の章で扱う」) at a resting point (end of
  paragraph/section), not mid-argument.

## Logical rigor

Leave no opening for objection. After drafting, anticipate the reader and check:

- Do not mechanically turn conjecture / possibility / reader doubt /
  counterfactual into assertion. Drop かもしれない・だろう・ようだ・らしい
  only when they weaken a claim without cause; keep them for unverified
  possibility, a character's perception, log-based inference, or likely
  reader doubt. Assert only when in-text grounds settle the proposition.
- Do not lump distinct things as "the same" (separate decisions, separate
  causes, different kinds of problem). Take them apart.
- Do not reduce a multi-cause event to one cause. If an example holds
  several problem types, separate them and map which tool explains which.
- Keep a concept's treatment consistent across chapters/sections
  (don't classify it as 「人間が決める」 in one place and 「チームで合意する」
  in another).
- When claiming causality, give the mechanism in one sentence; don't write
  「AだとBになる」 with no reason.
- Do not write detection/guarantee/resolution as always possible; state it
  conditionally (〜しやすい / 〜できることが多い / 〜が成り立つときに限り).
- Confirm the cited example actually supports the whole claim; if it
  supports only part, narrow the claim to fit.
- A point deferred to 「次節で扱う」 must actually be paid off there.
- After a concession/limit (ただし / とはいえ), always advance; don't end
  hanging on the adversative.
- Define a section's central term (its scope) before using it.
- When collapsing several concepts into one supertype, state in one
  sentence just before naming that they reduce to the same thing.

## Reader cognitive load

Treat reader memory and attention as finite.

- Don't introduce proper names (files, functions, identifiers) you won't
  reference again; use a general phrase (「仕様書」「金額計算のユーティリティ」).
- When an abstract phrase's referent isn't uniquely fixed by context, pin
  it in place with a parenthetical apposition rather than making the reader
  look back.
- When a new example adds context to hold, say up front how it differs from
  the previous one and why another is needed.
- Don't pack chapter/section openings with detail unrelated to the coming
  example.
- Within an example, omit only detail irrelevant to that section's
  question/conclusion (decorative agent-report precision — timestamps, HTTP
  status, coverage % — and never-referenced proper names). Keep specifics
  the argument needs.

## Voice and narration

- In examples, use an actor as subject in a chain of actions
  (「リポジトリを調査して特定し、見つけてくれた」), not result lists or
  passive voice (「特定され、判明した」).
- Don't attach pointless fictional personas (「入社2年目のエンジニアが」).
- Don't address the reader as 「あなた」 mid-argument; use a role name
  (開発者 / 読者). Reserve second person for scene setup (〜としよう) or a
  chapter/book closing.
- Choose specific referents; don't blur with broad words like AI / ツール.
- Once you introduce a formalization/term (K, 契約, 不変条件), keep using it;
  don't retreat to vague words (文脈 / ツール / AI) — though 文脈 as a
  pre-formalization lead-in is fine.
- Pick the field's conventional term/translation (push notification is
  配信, not 配送); don't substitute a near-synonym 漢語 by feel.
- Refer to people by original spelling (Lehman, Bainbridge); use the
  established katakana nickname for historical figures or eponymous concepts
  known that way.
- Don't borrow term-sounding words for non-term uses (calling a
  system-to-human span 「経路」); say it plainly (「届くまでの流れ」).

## Rhetorical restraint

Not a ban — a norm of moderation. Use rhetoric only where it works.

- Use buildup (「ここには〜が潜んでいる」) or rhetorical questions only where
  tension serves the argument; otherwise state it plainly.
- Don't overuse a short punch line as its own paragraph. A short 体言止め
  inside a paragraph (「ここまでわずか数十秒。」) is fine only at a climax.
- Don't overuse bold in body text; limit to logical hinges (a
  misreading-preventing negation, a section conclusion), one or two per
  section. Otherwise use word order and structure.
- Prefer 「〜するわけにはいかない」 (a worker's judgment) over the imperative
  「〜してはならない」.
- Don't over-dramatize turning points; one factual sentence usually
  suffices. An exclamation is allowed only at a genuine climax.
- Don't stoke fear by listing consequences.
- Don't preface with 「重要なのは〜である」; state the claim. A style-declaring
  preface (「標語として言い換えれば」) is fine.
- Don't overuse the 「AではなくBだった」 antithesis; light asides go in
  parentheses.
- Avoid twisted idioms (「知識を体に入れる」) and non-unique metaphors; say it
  with plain verbs (「身につく」「気付く機会が減る」).

## Ban empty LLM-isms

Don't fall for the hollow templates LLMs mass-produce. Book terms
(本質的複雑さ, 回収, 判断の配置) are fine in argument; the problem is empty
decoration. After drafting, audit for these — do not use them:

- **Preview/summary**: 重要なのは〜である / 本章では〜を扱う・探求する /
  ここでは〜を見ていく / まとめると・要するに (when only restating) / 〜に他ならない
- **"Head-on"**: 正面から扱う・回収する・見る — declaring stance instead of content
- **Empty adjectives**: 不可欠 / 核心的 / 鍵となる / 根本的な / 多角的 / 包括的 /
  総合的 (emphasis without substance)
- **Empty verbs**: 掘り下げる / 深掘りする / 言語化する / 触れる / 言及する
- **Connective templates**: 〜において / 〜という側面から / 〜の観点から (no new
  info); repeated さらに・また・加えて
- **Weak hedging/praise**: 〜と言えるだろう / 〜かもしれない (only when weakening
  without cause; keep for conjecture/hypothesis/reader doubt/character
  perception); 非常に・極めて・大いに

## Cut redundancy

- Don't restate one claim in reworded form; write it once.
- If adjacent sections say the same thing from another angle, merge them.
- Don't re-summarize a scene right after describing it; leave one sentence of
  significance.
- Combine parallel facts of the same logical role into one sentence, marking
  their status with the opening word (「当然、経理部の月次処理も顧客の支払いも〜」).
- Don't spell out intermediate steps the reader can supply.
- If a multi-sentence argument compresses to one, keep only that sentence
  (要するに may signal the compression).
- Don't add sentences that only connect or evaluate (「それ自体はよいことである」).
- Don't stage Q&A with an imagined reader, or perform-and-answer a reaction
  (「〜と感じたかもしれない。そのとおりである」); make concessions plainly in the
  main text.
- Don't frame a reader's likely idea meta (「ここまでの話には自然な続きがある」);
  write the idea directly. A genuine reader question may stay a question.
- Don't write author-stance disclaimers (「本書もそれを否定しない」); state the
  fact.
- Share context in the fewest words; if a derivation reads without
  step-by-step unfolding, name the structure and assert it.
- Don't introduce a concept or document name before the text has introduced it.
- Don't settle for weak predicates (「有効な対策であり」) when in-text grounds
  let you assert specifically (「活用において必須であり」); keep weak predicates
  only for real uncertainty. Deliberate tonal softening (「必須だと言ってもいい」)
  is fine.
- Connectives for rhythm (「しかし一方で」) are not redundancy.

## Headings

- Make headings specify content: the question the section answers or the
  object it treats. Not bare task steps (「例に戻す」) or contentless labels.
- Don't make a heading the section's punch line; don't spoil the payoff.
- A noun phrase naming the object is fine.
- Question form or declarative — either is fine; what matters is that it
  points at the object or the reader's question. Pick what fits the tone.

## Honesty to the reader

- If an example may look contrived, don't hide it: acknowledge the doubt and
  add brief grounds that it's realistic.
- Ground it in the reader's own experience or received view
  (「この症状は珍しくないだろう」), not an author assertion (「十分あり得る状況だ」).
- Don't write unverified things as though verified.
