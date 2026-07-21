# Policy — context continuity: the behavioural rule hooks cannot replace

v1's most expensive failure class: **a compact that lands before continuity
state is written silently loses the very state needed to continue.**

## Why this is policy, not just the PreCompact hook

The v2 PreCompact hook snapshots the session/task memory *files* — but it can
only snapshot what has already been written. The assistant gets no reliable
token meter, and any hook fires *as* the harness decides to compact — too late
to author a faithful `SESSION.md`/`TASK.md` if they were stale. So the
dependable mechanism is **behavioural**:

- Keep `SESSION.md` and `TASK.md` true to reality **continuously** — after
  every meaningful step, decision, or direction change — not retrospectively
  at session end.
- Keep ~15–20% of the context window in reserve. Rising context is itself the
  trigger: promote the task (`memory-promote.sh task`), bring `SESSION.md`
  current, and only then continue or allow a compact.
- At any clean task boundary with a heavy context: promote first, continue
  second.

## Reconstruction discipline (from the v1 handover method)

- Reconstruct git state **by observation** (`git log`, `gh pr list`) — never
  assert an unverified SHA or PR state into memory.
- Pull still-open items forward explicitly (NEXT-SESSION todos); the new
  record supersedes the old — no orphaned intentions.
- Dense and pointer-based: reference paths and reports rather than pasting
  bodies. Total-reconstructability-per-token is the metric.

A fresh session must be able to resume with absolute accuracy from the
promoted files alone. If it couldn't, the promotion wasn't done — regardless
of what the hooks logged.
