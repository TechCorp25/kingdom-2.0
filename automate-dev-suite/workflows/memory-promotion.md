# Workflow — memory promotion

**Purpose:** keep the four memory tiers accurate without context bloat (DD-002).
**Trigger points:** task completion · session end · pre-compact · goals achieved.
**Gate class:** success/go (self-verifying checks inside the script).

## Steps

1. **Task complete** → write `## Outcome` in `TASK.md` (what was achieved, how
   verified, follow-ups) → `scripts/memory-promote.sh task`.
   The script refuses to promote an empty outcome — that refusal is the gate.
2. **Session end / pre-compact** → ensure `SESSION.md` reflects reality →
   `scripts/memory-promote.sh session` → complete the printed checklist
   (distil to `PROJECT.md`, NEXT-SESSION todos, reset, commit + sync).
3. **Never demote:** information flows upstream only; downstream tiers are
   reset, not edited retroactively.

## Reporting hook

Task archives land in `state/{p}/reports/tasks/{ts}/` and session archives in
`state/{p}/reports/sessions/` automatically — the reporting workflow reads
these; nothing extra to write.

## Token-cost rationale

Promotion is file I/O only (no model calls). Archives are referenced by path,
never re-read wholesale. A resumed session costs three small file reads
regardless of how long the previous session ran.
