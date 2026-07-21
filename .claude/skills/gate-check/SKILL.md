---
name: gate-check
description: Run the gate protocol for a pending action — classify it against the gate map, then execute the hard-stop, Fable self-check, or go-gate procedure with full audit recording. Use before merging any PR, proceeding past a checkpoint, or whenever an action's gate class is in doubt.
---

# Gate check

1. **Classify** the action against `automate-dev-suite/gates/gate-map.md`
   (hard rules in `gates.md` §1 override; unlisted actions default to the
   nearest listed analogue, or HARD if genuinely novel).
2. **Hard stop** → stop and ask the owner plainly; record
   `gate-record.sh hard <workflow> "<action>" pending owner`, update to the
   owner's decision when given. Never proceed or work around while pending.
3. **Self-check** → follow `gates.md` §2 exactly: PR opened first → record
   `pending` → spawn `fable-reviewer` fresh with PR ref + gate context only →
   record its verdict → merge/proceed only on APPROVE within the envelope.
4. **Go gate** → check the objective criteria (goals file, tests,
   boundary-verify, sync); record `go`/`no-go` for session-level checkpoints;
   a `no-go` loops the work, never skips the check.

Every decision is recorded — an unrecorded gate did not happen.
