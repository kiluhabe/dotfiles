#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

let input = '';
process.stdin.on('data', chunk => (input += chunk));
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);

    const model = data.model?.display_name || 'Unknown';
    const currentDir = data.workspace?.current_dir || data.cwd || '.';
    const dirName = path.basename(currentDir);
    const sessionId = data.session_id || '';

    // Git branch (cwd has a .git dir or file when in a worktree)
    let branch = '';
    if (currentDir && fs.existsSync(path.join(currentDir, '.git'))) {
      try {
        const name = execSync('git --no-optional-locks branch --show-current 2>/dev/null', {
          cwd: currentDir,
          encoding: 'utf-8',
        }).trim();
        if (name) branch = ` 🌿 ${name}`;
      } catch {}
    }

    // Context window % (Claude Code pre-calculates this; do not recompute)
    const ctxPct = Math.round(data.context_window?.used_percentage ?? 0);
    let ctxColor = '\x1b[32m';
    if (ctxPct >= 60) ctxColor = '\x1b[33m';
    if (ctxPct >= 80) ctxColor = '\x1b[91m';

    const fmtTokens = n =>
      n >= 1_000_000 ? `${(n / 1_000_000).toFixed(1)}M`
      : n >= 1_000 ? `${Math.round(n / 1_000)}k`
      : `${n}`;
    const totalIn = data.context_window?.total_input_tokens ?? 0;
    const totalOut = data.context_window?.total_output_tokens ?? 0;
    const sessionDisplay =
      totalIn || totalOut
        ? ` (in:${fmtTokens(totalIn)} out:${fmtTokens(totalOut)})`
        : '';
    const ctxDisplay = `${ctxColor}🧠 ${ctxPct}%${sessionDisplay}\x1b[0m`;

    // Cost (USD, client-side estimate; absent on first turn)
    const cost = data.cost?.total_cost_usd;
    const costDisplay =
      typeof cost === 'number' && cost > 0 ? ` | 💰 $${cost.toFixed(2)}` : '';

    // Rate limits (Pro/Max only; each window may be absent independently)
    const rl = data.rate_limits || {};
    const rlParts = [];
    if (typeof rl.five_hour?.used_percentage === 'number') {
      rlParts.push(`5h:${Math.round(rl.five_hour.used_percentage)}%`);
    }
    if (typeof rl.seven_day?.used_percentage === 'number') {
      rlParts.push(`7d:${Math.round(rl.seven_day.used_percentage)}%`);
    }
    const rlDisplay = rlParts.length ? ` | ⏳ ${rlParts.join(' ')}` : '';

    // Subagent execution (only present under --agent or agent settings)
    const agent = data.agent?.name;
    const agentDisplay = agent ? ` | 🤖 ${agent}` : '';

    const line = `[${model}] 📁 ${dirName}${branch} | ${ctxDisplay}${costDisplay}${rlDisplay}${agentDisplay} \x1b[90m| ${sessionId}\x1b[0m`;
    console.log(line);
  } catch {
    console.log('[Claude Code]');
  }
});
