# Workflow — pre/post-compact (context integrity)

**Purpose:** compaction must never cost accuracy. Protection is layered so no
single step failing loses state.

## Before compaction

1. **Automatic (PreCompact hook):** lossless snapshot of the bound project's
   `session/` tree + kingdom activity log to
   `.orchestrator/runtime/compact-snapshots/{ts}/` (last five kept).
2. **Behavioral (contract):** when compaction approaches, run the session-end
   promotion steps early — `SESSION.md` updated + `memory-promote.sh task` for
   any completed work. Promoted state is compaction-proof by construction.

## After compaction

The SessionStart hook (source=compact) re-injects the contract, keeps the
project binding, and points at the latest snapshot. Then:

1. Re-read `SESSION.md` and `TASK.md` (tier 3/4 — small by design).
2. Diff against the snapshot only if something reads as missing.
3. Continue; never re-derive from scratch what the tiers already hold.

## Token rationale

Recovery costs two small file reads because everything durable was already
outside the context window. That is the entire point of the tier design.
