import { describe, expect, test } from 'claude-code/testing'

import { runsCat, wordCap } from '../hooks/text'

describe('runsCat', () => {
  test('flags plain, piped, xargs and substituted cat', async () => {
    expect(runsCat('cat foo.txt')).toBe(true)
    expect(runsCat('ls && /bin/cat foo')).toBe(true)
    expect(runsCat('find . | xargs -n 1 cat')).toBe(true)
    expect(runsCat('echo $(cat foo)')).toBe(true)
  })

  test('leaves heredocs and other commands alone', async () => {
    expect(runsCat("cat <<'EOF' > out\nhi\nEOF")).toBe(false)
    expect(runsCat('grep cat foo.txt')).toBe(false)
    expect(runsCat('concat foo')).toBe(false)
  })
})

test('wordCap reads the cap a prompt states', async () => {
  expect(wordCap('Find X.\nReturn paths, under 200 words.')).toBe(200)
  expect(wordCap('no cap here')).toBeUndefined()
})

test('Bash cat is denied, other commands run', async ($, on) => {
  on('tool.call', () => ({ result: { stdout: '', stderr: '', interrupted: false } }) as never)

  const denied = await $.tool.call({ tool: 'Bash', command: 'cat README.md' })
  expect(denied.deny).toContain('nudge-bash')

  const ran = await $.tool.call({ tool: 'Bash', command: 'ls' })
  expect(ran.deny).toBeUndefined()
})

test('Agent model override is denied', async $ => {
  const denied = await $.tool.call({
    tool: 'Agent', description: 'd', prompt: 'p', subagent_type: 'scout', model: 'opus',
  })
  expect(denied.deny).toContain('nudge-agent-model')
})

test('second Read of the same file carries a warning', async ($, on) => {
  on('tool.call', () => ({ result: { type: 'text', file: { content: 'x' } } }) as never)

  const first = await $.tool.call({ tool: 'Read', file_path: '/tmp/a' })
  expect(first.context ?? []).toHaveLength(0)

  const second = await $.tool.call({ tool: 'Read', file_path: '/tmp/a' })
  expect(second.context?.[0]).toContain('repeated Read of /tmp/a')
})

test('over-cap subagent answer carries a warning', async ($, on) => {
  on('tool.call', () => ({ result: { content: 'one two three four five six' } }) as never)

  const ran = await $.tool.call({
    tool: 'Agent', description: 'd', prompt: 'answer in 3 words', subagent_type: 'scout',
  })
  expect(ran.context?.[0]).toContain('6 words > 3')
})
