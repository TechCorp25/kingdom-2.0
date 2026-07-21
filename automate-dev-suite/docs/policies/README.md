# Policies — hard-won lessons from Kingdom v1

Ported 2026-07-21 from `~/kingdom/knowledge/policies/` (read-only v1 reference).
These were learned at real cost in the first kingdom build; they are preserved
here so they cannot be re-learned the expensive way. Owner mandate: these
mitigations MUST stay integrated and current.

Triage note: v1 policies describing superseded v1 mechanisms (knowledge
checkpoints, run-close, `/automate-dev` default, global-approval flow) were
NOT ported wholesale — their unique lessons are folded into these files and
into the v2 equivalents (workflows, gates, the gates-guard hook).

| File | The lesson it preserves |
|---|---|
| `merge-hygiene.md` | Squash-merge traps: stranded branches, stacked-PR auto-close, ff-only discipline |
| `python-gotchas.md` | Python/FastAPI traps that produced silent runtime failures |
| `token-budget.md` | Token economy: search/read discipline, agents, context reserve |
| `secrets.md` | Secret handling beyond "gitignore it" |
| `stack-boundaries.md` | Per-project stacks never cross-pollinate; control plane vs business data |
| `confidential-areas.md` | Confidential/fragile material handling |
| `context-continuity.md` | The behavioural handover rule — hooks alone cannot save a compacted session |
