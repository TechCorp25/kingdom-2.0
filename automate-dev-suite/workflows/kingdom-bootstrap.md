# Workflow — kingdom bootstrap (session lifecycle step 1)

**Trigger:** every session start. The SessionStart hook injects the contract,
drift status, carried-over todos, and the numbered project menu automatically;
this workflow is what the assistant then completes.
**Gate class:** success/go (all checks must be green or explicitly remediated).

## Steps

1. **Environment drift** — the injected status shows kingdom `main` vs origin.
   If behind: `git pull --ff-only` on `main`. If ahead or diverged: STOP —
   investigate before any new work (never force past; root CLAUDE.md hygiene).
2. **Carried-over todos** — injected from `.orchestrator/reports/todos/NEXT-SESSION.md`.
   Fold them into today's plan; remediation markers (un-promoted sessions,
   crashed sessions) are handled during project bootstrap.
3. **Per-project drift** — `scripts/sync-check.sh` (writes
   `.orchestrator/reports/sync/last-check.txt`). Any `!` line = remediation
   item for that project's bootstrap.
4. **Global memory refresh** — skim `.orchestrator/.claude/memory/MEMORY.md`
   pointers; update `environment-health.md` if tooling/sync facts changed.
5. Proceed to **project selection**: ask the owner the numbered question, run
   `scripts/select-project.sh <n>`.

## Reporting

Sync results land in `reports/sync/` automatically; environment changes go to
tier-1 memory. Nothing else to write.

## Token rationale

The hook pre-computes everything injectable (~35 lines); the assistant reads
two small files at most. Per-project detail is deferred until a project is
actually selected.
