# Gates — definitions and protocol

Three gate classes govern all work, in the kingdom and in every project.
Every gate decision is recorded (`scripts/gate-record.sh`) — an unrecorded
decision is a contract breach. Per-action assignments: `gate-map.md`.

## 1. Hard stop gates — owner approval, no bypass

The assistant stops, states plainly what needs approval and why, and does not
proceed, work around, or partially proceed. If the owner is absent, the item
is parked (recorded `pending`) and other in-envelope work continues.

Always hard-stop, regardless of gate-map: secrets/API keys/tokens (request at
point of use, store only in gitignored env files), destructive or irreversible
actions, spending money, diverged git history resolution, anything
outward-facing beyond the two governed repo layers.

## 2. Self-check stop gates — Fable approves in place of the owner

Enables autonomous work where risk is contained. Protocol (all steps required,
in order):

1. The work is committed on its branch and its **PR is opened first** — the
   reviewer judges the same artifact the owner could see.
2. Record the gate as `pending` (`gate-record.sh self-check <workflow> "<action>" pending fable-reviewer`).
3. Spawn `fable-reviewer` (`.claude/agents/fable-reviewer.md`, model
   `claude-fable-5`) as a **fresh-context subagent** — it receives the PR
   reference, the gate record, and the risk envelope; never the working
   conversation.
4. The reviewer returns APPROVE or REJECT with reasons; the SubagentStop hook
   logs the run automatically.
5. Record the decision (`approved`/`rejected` + notes). REJECT → fix and
   re-run from step 1; approvals outside the envelope are void.
6. Only then merge/proceed.

## 3. Success / go gates — objective checkpoints

Verifiable criteria (from the session-goals file and workflow docs) deciding
whether to keep moving: tests green, boundary-verify clean, sync ✓, promotion
done. Self-assessed, honestly, against evidence — record `go`/`no-go` for
session-level checkpoints; a failed go-gate loops work, never skips the check.
