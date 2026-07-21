# Workflow — session end

**Trigger:** the owner reports back that the session's PR(s) are reviewed and
merged; or the owner ends the session early; or goals are met with PRs handed
over; or context compaction is imminent. **Gate class:** success/go; skipping
promotion is a contract breach. (Merging to `main` is never part of this
workflow — it is the owner's own action, upstream of it.)

## Steps

1. Promote the live task if it has an outcome (`memory-promote.sh task`);
   otherwise record its state honestly in `TASK.md` (it will be remediated
   next session).
2. Update `SESSION.md` to reality, then `memory-promote.sh session` and
   complete its printed checklist:
   - distil durable facts → `PROJECT.md`
   - carried-over todos → `.orchestrator/reports/todos/NEXT-SESSION.md`
   - reset `SESSION.md` for next time
3. **Project repo** — commit session-branch work; push; open/refresh the
   project PR (`workflows/git-layer.md`).
4. **Kingdom repo** — commit promoted state + reports + registry changes on
   the session's kingdom branch; push; ensure the kingdom PR exists.
5. `scripts/sync-check.sh` — everything `✓` (or `!` lines carried as todos).

The SessionEnd hook independently logs the close and flags un-promoted
sessions for next-bootstrap remediation — it is the safety net, not the workflow.

## Token rationale

Promotion is scripted file I/O; the only model work is distillation (judgement)
— exactly the part worth spending tokens on.
