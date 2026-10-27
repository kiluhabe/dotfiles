// Pure helpers ported from the shell hooks, kept apart so tests can call them.

const XARGS_OPTS_WITH_ARG = new Set([
  '-n', '-P', '-L', '-I', '-E', '-d', '-s', '-a',
  '--max-args', '--max-procs', '--max-lines', '--replace', '--eof',
  '--delimiter', '--max-chars', '--arg-file',
])

const splitChains = (s: string): string[] =>
  s.replace(/&&|\|\||\||;/g, '\n').split('\n')

function segmentRunsCat(segment: string): boolean {
  const seg = segment.trim()
  if (seg === '') return false

  const [head = '', ...args] = seg.split(/\s+/)
  const first = head.split('/').pop()

  if (first === 'xargs') {
    for (let i = 0; i < args.length; i++) {
      const tok = args[i] ?? ''
      if (XARGS_OPTS_WITH_ARG.has(tok)) { i++; continue }
      if (tok.startsWith('-')) continue
      return segmentRunsCat(tok)
    }
    return false
  }

  // `cat <<EOF` writes a heredoc; that's not reading a file.
  return first === 'cat' && !/<<-?\s*'?[A-Za-z_]/.test(seg)
}

export function runsCat(command: string): boolean {
  if (splitChains(command).some(segmentRunsCat)) return true

  const subs = [...command.matchAll(/\$\([^()]*\)|`[^`]*`/g)]
    .map(m => m[0].replace(/^\$\(|\)$|^`|`$/g, ''))
  return subs.flatMap(splitChains).some(segmentRunsCat)
}

// First line that names a cap wins; within it, the last "<n> words".
export function wordCap(prompt: string): number | undefined {
  for (const line of prompt.toLowerCase().split('\n')) {
    const last = [...line.matchAll(/(?:^|[^0-9])([0-9]+)\s+words?/g)].pop()
    if (last?.[1] !== undefined) return Number(last[1])
  }
  return undefined
}

function textify(v: unknown): string {
  if (typeof v === 'string') return v
  if (Array.isArray(v)) return v.map(textify).join(' ')
  if (v !== null && typeof v === 'object') return Object.values(v).map(textify).join(' ')
  return v === undefined ? '' : String(v)
}

export function responseText(result: unknown): string {
  if (result !== null && typeof result === 'object' && !Array.isArray(result)) {
    const r = result as Record<string, unknown>
    const picked = r.content ?? r.text ?? r.result ?? r.output ?? r.object
    if (picked !== undefined) return textify(picked)
  }
  return textify(result)
}

export const wordCount = (s: string): number => s.split(/\s+/).filter(Boolean).length
