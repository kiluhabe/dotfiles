import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, ToolCallResult } from 'claude-code'

import type { UnassignedTask } from '../types'
import { responseText, runsCat, wordCap, wordCount } from './text'

const reads = atom({ plugin: 'agent-nudges', key: 'reads' } as const, {})
const edits = atom({ plugin: 'agent-nudges', key: 'edits' } as const, {})
const unassigned = atom({ plugin: 'agent-nudges', key: 'unassigned' } as const, [])

async function bumpRead($: EngineInterface, path: string): Promise<number> {
  let n = 0
  await update($, reads, counts => {
    n = (counts[path] ?? 0) + 1
    return { ...counts, [path]: n }
  })
  return n
}

async function bumpEdit($: EngineInterface, path: string): Promise<number> {
  let n = 0
  await update($, edits, counts => {
    n = (counts[path] ?? 0) + 1
    return { ...counts, [path]: n }
  })
  return n
}

async function editWarning($: EngineInterface, tool: string, path: string): Promise<string | undefined> {
  const count = await bumpEdit($, path)
  return count >= 3
    ? `Context economy warning: ${tool} touched ${path} ${count} times. Batch remaining changes to this file into one edit.`
    : undefined
}

function withContext<R extends ToolCallResult>(ran: R, note: string | undefined): R {
  if (ran.deny !== undefined || note === undefined) return ran
  return { ...ran, context: [...(ran.context ?? []), note] }
}

const succeeded = (ran: ToolCallResult) => ran.deny === undefined && ran.isError !== true

async function findUnassigned($: EngineInterface, sessionId: string): Promise<UnassignedTask[]> {
  const home = await $.env.get('HOME')
  if (home === undefined) return []

  const dir = `${home}/.claude/tasks/${sessionId}`
  if (!(await $.fs.exists(dir))) return []

  const found: UnassignedTask[] = []
  for (const entry of await $.fs.list(dir)) {
    if (!entry.name.endsWith('.json')) continue
    try {
      const t = JSON.parse(await $.fs.read(`${dir}/${entry.name}`))
      const isOpen = t.status === 'pending' || t.status === 'in_progress'
      if (isOpen && !t.owner) found.push({ id: String(t.id), subject: String(t.subject) })
    } catch {}
  }
  return found
}

// Fails open, as the jq original did: an unreadable task store blocks nothing.
async function refreshUnassigned($: EngineInterface, sessionId?: string): Promise<UnassignedTask[]> {
  try {
    const tasks = await findUnassigned($, sessionId ?? (await $.session.id()))
    await update($, unassigned, () => tasks)
    return tasks
  } catch {
    return []
  }
}

export const register: Register = on => {
  // --- context economy -------------------------------------------------------

  on('tool.call', { tool: 'Read' }, async ($, e, next) => {
    const ran = await next(e)
    if (!succeeded(ran)) return ran

    const count = await bumpRead($, e.file_path)
    return count >= 2
      ? withContext(ran, `Context economy warning: repeated Read of ${e.file_path} in this session (${count} times). Reuse prior context or read only a targeted offset/limit.`)
      : ran
  })

  on('tool.call', { tool: 'Edit' }, async ($, e, next) => {
    const ran = await next(e)
    return succeeded(ran) ? withContext(ran, await editWarning($, 'Edit', e.file_path)) : ran
  })

  on('tool.call', { tool: 'Write' }, async ($, e, next) => {
    const ran = await next(e)
    return succeeded(ran) ? withContext(ran, await editWarning($, 'Write', e.file_path)) : ran
  })

  // --- Agent: model override is refused, word caps are checked -------------

  on('tool.call', { tool: 'Agent' }, async ($, e, next) => {
    if (e.model !== undefined) {
      return { deny: `BLOCKED by nudge-agent-model: do not override model on Agent calls — let the agent definition set it. Got model: ${e.model}` }
    }

    const ran = await next(e)
    if (!succeeded(ran)) return ran

    const cap = wordCap(e.prompt || e.description)
    if (cap === undefined) return ran

    const actual = wordCount(ran.text ?? responseText(ran.result))
    return actual > cap
      ? withContext(ran, `Context economy warning: subagent response exceeded word cap (${actual} words > ${cap}). Ask for a compressed answer instead of accepting raw logs.`)
      : ran
  })

  // --- Bash: steer cat to Read ---------------------------------------------

  on('tool.call', { tool: 'Bash' }, ($, e, next) =>
    runsCat(e.command)
      ? { deny: `BLOCKED by nudge-bash: use Read tool (use offset/limit for large files) instead of \`cat\`\nCommand: ${e.command}` }
      : next(e),
  )

  // --- task owners -----------------------------------------------------------

  on('tool.call', { tool: 'TaskCreate' }, async ($, e, next) => {
    const ran = await next(e)
    await refreshUnassigned($)
    return withContext(ran, 'note: after creating tasks, assign a tier owner (implementer) via TaskUpdate; keep-it-myself tasks use owner "self".')
  })

  on('tool.call', { tool: 'TaskUpdate' }, async ($, e, next) => {
    const ran = await next(e)
    await refreshUnassigned($)
    return ran
  })

  on('session.start', async ($, e, next) => {
    const started = await next(e)
    await refreshUnassigned($)
    return started
  })

  // A non-empty owner (e.g. "self") counts as assigned.
  on('classic.Stop', async ($, e, next) => {
    const result = await next(e)
    const tasks = await refreshUnassigned($, e.session_id)
    if (tasks.length === 0) return result

    const list = tasks.map(t => `  - [${t.id}] ${t.subject}`).join('\n')
    return {
      ...result,
      block: `BLOCKED by enforce-task-owner: assign a tier owner to these tasks (or owner "self" to keep them) before stopping.\n${list}`,
    }
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const below = await next(e)
    const tasks = await read($, unassigned)
    if (e.props.hasSurvey || tasks.length === 0) return below

    const { Box, Text } = $.ui.resolve(e)
    const row = (
      <Box>
        <Text color="yellow">owner 未設定 {tasks.length} 件: </Text>
        <Text dimColor>{tasks.map(t => `[${t.id}] ${t.subject}`).join(' · ')}</Text>
      </Box>
    )
    return below.type === 'engine' ? row : (
      <Box flexDirection="column">
        {below}
        {row}
      </Box>
    )
  })
}
