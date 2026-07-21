# DD-003 — Gates and the Fable self-check protocol

**Status:** Accepted · 2026-07-21 (owner decision, locked pre-build)

## Why a higher-model reviewer

The suite must work autonomously where risk is contained, without diluting the
owner's control where it is not. The middle class — self-check stop gates —
substitutes a **higher model** (Fable, `claude-fable-5`) for owner approval,
under three constraints that make the substitution honest:

1. **Fresh context.** The reviewer judges the artifact, never the conversation
   that produced it — the same information position the owner would be in.
2. **PR opened first.** The artifact under review is exactly what would merge;
   nothing is approved that the owner could not later inspect at the same URL.
3. **Recorded, bounded authority.** Every decision is in the append-only audit
   trail (`reports/gates/`), and approvals are void outside the risk envelope
   (`gates/risk-envelope.md`) — whose own modification is a hard gate.

## Why three classes, not two

Owner-only gating blocks autonomy; review-everything burns tokens and
attention on mechanical checkpoints. The go-gate class captures objective,
self-verifiable criteria (tests green, boundary clean, sync ✓) where a model
reviewer adds nothing over the evidence itself — recorded, but not escalated.

## Audit backbone

- `gate-record.sh` → `reports/gates/gates-YYYY-MM.jsonl` (+ per-project mirror)
- SubagentStop hook → `reports/gates/subagents.jsonl` (every reviewer run is
  independently traceable)
- Both sync via the kingdom repo: the audit trail survives machines and is
  reviewable by the owner at any time.

## Token rationale

Gate reviews are bounded, on-demand subagent runs at real decision points —
the antithesis of v1's per-turn Stop-hook passes (build audit 001). A review
costs one fresh-context agent reading one PR; the session pays only for the
verdict.
