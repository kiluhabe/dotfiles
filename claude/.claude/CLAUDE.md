@AGENTS.md

## Claude Code 固有の補足

- 大きな探索や複数ファイル横断調査は Explore subagent / Agent ツールに委譲して
  メインの context を保つ。委譲後は同じ検索をこちらで繰り返さない。
- 計画合意が必要な変更は plan モードで合意してから着手する。
- Bash 実行履歴は `~/.claude/audit.log` に PostToolUse hook で追記される。10 MB
  超で `audit.log.1` に自動ローテ（1 世代のみ）。
