export type UnassignedTask = { id: string; subject: string }

declare module 'claude-code' {
  interface PluginState {
    'agent-nudges': {
      reads: Record<string, number>
      edits: Record<string, number>
      unassigned: UnassignedTask[]
    }
  }
}
