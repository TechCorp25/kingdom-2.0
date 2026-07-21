# DD-004 — Token-cost strategy

**Status:** Accepted · 2026-07-21
Every suite component ships with a token-cost rationale (build prompt §12.4).
This DD holds the global strategy those rationales appeal to; v1 evidence in
build audit 001.

## Principles

1. **No model calls in hooks.** v1's AI prompt-linting (UserPromptSubmit) and
   blanket Stop-hook quality passes (180 s, every turn) were its largest
   latency/token sink. v2 hooks are pure local exec: bash + python3 stdlib.
   Model-judgement checkpoints exist only as explicit gates, invoked at
   defined workflow points, on fresh-context subagents.
2. **Fixed, small context injection.** Exactly one hook injects context
   (SessionStart, ~35 lines: contract + live status + project menu). All other
   hooks are silent on success.
3. **Bulk material lands in tier-4 files** and is referenced by path. Search
   results, long tool output, drafts — never pasted twice into context.
4. **Pointers over dumps.** CLAUDE.md, memory files, and workflow docs link to
   detail; nothing authoritative is duplicated (single source per fact — drift
   is a token cost too: contaminated context must be re-established).
5. **Grep/Glob before Read; Explore agent for breadth; batch independent
   calls.** Standing rules injected at session start.
6. **Automatic records are free records.** PostToolUse/SubagentStop append
   JSONL locally — a complete activity/audit trail costs zero context.
7. **Skills are thin triggers.** Skill bodies point at workflow docs; the doc
   is read once when the workflow actually runs, not on every session load.

## Per-hook budget

| Hook | Cost profile |
|---|---|
| SessionStart | ~35 lines context, one 8 s-capped network fetch |
| PreToolUse guard | local exec ≤ ~50 ms; context cost only on DENY (2-line reason) |
| PostToolUse log | local append; zero context |
| PreCompact snapshot | local file copy; zero context |
| SessionEnd / SubagentStop | local append; zero context |

## Review cadence

Re-audit hook latency and injection size whenever a workflow adds a hook, and
at every environment-health check that reports sluggish sessions.
