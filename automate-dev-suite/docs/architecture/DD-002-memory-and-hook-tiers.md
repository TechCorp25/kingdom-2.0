# DD-002 — Four-tier memory and hook tiers

**Status:** Accepted · 2026-07-21
Reference: Anthropic memory & context-management docs
(`~/kingdom/projects/automate-dev-builder/official-documentation/`).

## Memory tiers

| Tier | Path | Owns | Never contains |
|---|---|---|---|
| 1 Global | `.orchestrator/.claude/memory/` | Environment health, startup orientation, kingdom-repo governance, last kingdom PR state | Project-specific detail |
| 2 Project | `projects/{p}/.orchestrator/memory/project/` (→ `state/{p}/…`, DD-001) | Durable project facts: `PROJECT.md`, `last-session.md` pointer | Kingdom/environment or other-project detail |
| 3 Session | `…/memory/project/session/SESSION.md` | Current session: intent, goals ref, decisions, progress | Anything meant to outlive the session un-promoted |
| 4 Task | `…/memory/project/session/task/` | `TASK.md` working state, `activity.jsonl` hook log, bulk scratch (search results, large outputs) | — (this tier IS the context-bloat sink) |

Every tier-file is markdown with a fixed skeleton (templates in
`automate-dev-suite/templates/`), so promotion is mechanical and diffs stay
reviewable in the kingdom repo.

## Promotion flow (upstream only)

```
task ──(task complete)──▶ session ──(session end · pre-compact · goals met)──▶ project
```

`scripts/memory-promote.sh task` — verifies `TASK.md` has an `## Outcome`,
appends it to `SESSION.md`, archives the task dir to
`state/{p}/reports/tasks/{ts}/`, resets a fresh `TASK.md`.

`scripts/memory-promote.sh session` — archives `SESSION.md` to
`state/{p}/reports/sessions/{ts}-session.md`, rewrites `last-session.md`, then
prints the checklist the assistant must complete: distil durable facts into
`PROJECT.md`, write NEXT-SESSION todos, sync the kingdom repo.

Distillation is judgement work and stays with the assistant; the script does
only the mechanical, lossless part. Nothing is deleted — archives are the audit
trail and sync to the kingdom remote.

## Hook tiers → physical mapping

Claude Code executes hooks from settings files only (user / project / local).
The four *logical* tiers map onto that reality honestly:

| Logical tier | Physical mechanism |
|---|---|
| 1 Kingdom | `~/kingdom-2.0/.claude/settings.json` + `.claude/hooks/*` |
| 2 Project | `projects/{p}/.claude/settings.json` (symlinked from kingdom state, DD-001) — loaded hierarchically when tools touch that subtree |
| 3 Session | Tier-1/2 hook scripts read `.orchestrator/runtime/current-session.json` and change behavior per selected project/session (sandbox scope, log targets) |
| 4 Task | Same scripts read the live task dir; `activity.jsonl` gives every task an automatic, zero-context-cost record |

## Token rationale (feeds DD-004)

- Bulk material lands in tier 4 files, referenced by path — never pasted into
  context twice.
- Session start reads exactly three small files for a project (`PROJECT.md`,
  `last-session.md`, `SESSION.md` if resuming) plus pointers; reports are read
  on demand only.
- Hook logging is append-only file I/O — no model calls, no context injection.
