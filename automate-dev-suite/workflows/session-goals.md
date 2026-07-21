# Workflow — session goals (session lifecycle step 4)

**Trigger:** after project bootstrap completes.
**Gate class:** success/go — a session without a goals file is invalid.

## Steps

1. `scripts/session-goals.sh` — reports today's latest
   `DateTime-{session-plan}.md` for the bound project, or its absence.
2. **Exists** → read it; mirror goals into `SESSION.md` (intent + goals-file
   pointer); confirm scope with the owner only if goals are ambiguous.
3. **Absent** → ask the owner for this session's instructions/goals, then
   `scripts/session-goals.sh --create <slug>` and fill: goals (ordered,
   verifiable), success criteria, constraints, gate notes.
4. Goals define the session's **success/go gates**; the gate notes section
   pre-declares any hard-stop or self-check actions expected this session.

## Template · Reporting · Tokens

Template: `templates/session-goals.template.md`. The goals file itself is the
report (it syncs with the kingdom repo). One small file read/written.
