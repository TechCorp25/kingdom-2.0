# Build report 002 — end-to-end dry-run (build prompt §12.5)

**Date:** 2026-07-21 · **Pilot:** pin-force

## What ran, in lifecycle order — all green

1. **Kingdom bootstrap** — SessionStart injection produced contract + live
   drift (0/0 vs origin) + numbered menu showing `1. pin-force [pilot]`.
2. **Project selection** — `select-project.sh 1` bound the session and
   printed the bootstrap checklist.
3. **Project bootstrap** — `sync-check.sh pin-force`: both layers 0 ahead/0
   behind; the single dirty file was goal 1's uncommitted `.gitignore`.
4. **Session goals** — `session-goals.sh` discovered today's latest plan
   (`2026-07-21T15-39-expo-pilot.md`).
5. **Real task through task memory** — goal 1 executed: session branch on
   pin-force → boundary `.gitignore` commit (the project's own pre-commit
   boundary hook passed it) → pushed → **PR CivicMAPS/pin-force#4** opened.
6. **Gates** — go-gate recorded for goal 1; the project merge recorded
   `hard/pending owner` (consistent with the kingdom stack parking).
7. **Promotion** — task → SESSION.md (archive `reports/tasks/2026-07-21T15-41/`),
   session → `reports/sessions/2026-07-21T15-41-session.md`, `last-session.md`
   rewritten, NEXT-SESSION todos written, SESSION.md reset.
8. **Repo sync outcome** — pin-force code went only to `CivicMAPS/pin-force`;
   pin-force memories/reports/registry went only to the kingdom repo (this
   commit). `boundary-verify.sh`: all checks ✓.

## Governance event of record

The first Fable self-check review (kingdom PR #1) returned **REJECT** — not on
the artifact (technical review clean) but on bootstrap circularity: the gate
framework cannot authorize its own ratification. All seven kingdom PRs +
pin-force#4 are parked **hard/pending owner**. This is the gate system
behaving as designed; the reviewer's one technical finding (fail-open audit
check) was fixed in Component 6. Once the owner ratifies PR #5, self-check
substitution activates for future in-envelope merges.

## Honest caveats

- Hook scripts are validated standalone (14/14 guard cases, injection, logs);
  **live wiring** (CC loading `.claude/settings.json` and firing hooks in a
  real session from the kingdom-2.0 root) is validated the first time the
  owner starts a session there — carried as a NEXT-SESSION todo.
- Pilot goals 2–5 (Expo scaffold → EAS deploy) are the next session's work;
  goal 5's keys remain a hard stop at point of use.
- `new-project.sh` (fresh-remote path) shares its wiring with the adopt path
  but has not yet created a real repo; first real use is gated self-check.
