# Workflow — reporting (the record-keeping backbone)

**Purpose:** persistent, audit-grade state knowledge with near-zero context
cost. Feeds memory promotion, gate audits, and session remediation.

## What gets recorded, where, by whom

| Record | Path | Writer |
|---|---|---|
| Tool activity (task tier) | `state/{p}/.../session/task/activity.jsonl` | PostToolUse hook (automatic) |
| Task archives | `state/{p}/reports/tasks/{ts}/` | `memory-promote.sh task` |
| Session archives | `state/{p}/reports/sessions/{ts}-session.md` | `memory-promote.sh session` |
| Session close log | `.orchestrator/reports/sessions/log.jsonl` | SessionEnd hook (automatic) |
| Gate decisions | `.orchestrator/reports/gates/gates-YYYY-MM.jsonl` + per-project `state/{p}/reports/gates/` | `gate-record.sh` |
| Subagent runs | `.orchestrator/reports/gates/subagents.jsonl` | SubagentStop hook (automatic) |
| Sync results | `.orchestrator/reports/sync/last-check.txt` | `sync-check.sh` |
| Carried todos | `.orchestrator/reports/todos/NEXT-SESSION.md` | session-end workflow + hooks |

All of it syncs through the kingdom repo (DD-001) — the audit trail survives
machines and travels to teammates.

## Rules

- Automatic writers never block and never inject context (DD-004).
- Reports are append/archive — never rewritten. Corrections are new entries.
- Reports are read via pointers from memory files, on demand only.
