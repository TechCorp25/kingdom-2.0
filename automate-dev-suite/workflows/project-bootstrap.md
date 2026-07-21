# Workflow — project bootstrap (session lifecycle step 3)

**Trigger:** immediately after `select-project.sh` binds the session.
**Gate class:** success/go, with one hard stop noted below.

## Steps

1. **Memory** — read, in order: `PROJECT.md`, `last-session.md`, and (if
   resuming) `SESSION.md`; open reports only when a memory file points at one.
2. **Remediation check** — if `NEXT-SESSION.md` carries a marker for this
   project, or `SESSION.md` is newer than the last session archive, the prior
   session ended unexpectedly (crash/power/network):
   - Reconstruct from `SESSION.md`, `task/activity.jsonl`, and any compact
     snapshot in `.orchestrator/runtime/compact-snapshots/`.
   - Promote what is promotable (`memory-promote.sh session --project <p>`),
     then continue.
3. **Git state** — `sync-check.sh <p>`:
   - behind → `git -C projects/<p> pull --ff-only`
   - ahead → push (or open the PR the last session should have opened)
   - diverged → **HARD STOP: owner decides** (recorded via `gate-record.sh`)
   - dirty tree → stash or commit onto the prior session branch before
     starting fresh work
4. **Session branch** — `git -C projects/<p> checkout -b session/YYYY-MM-DD-<slug>`
   from up-to-date `main` (tracking pushed on first commit).
5. **Clean slate** — fresh `TASK.md` (promote leftovers first), then proceed to
   the session-goals workflow.

## Reporting

Remediation actions and git decisions are recorded in `SESSION.md` decisions;
diverged-history decisions additionally via `gate-record.sh`.

## Token rationale

Three small reads for a healthy project. Remediation reads archives selectively
— never the whole reports tree.
