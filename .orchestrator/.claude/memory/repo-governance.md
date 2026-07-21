# Kingdom repo governance

- Remote: `https://github.com/TechCorp25/kingdom-2.0` (private). HTTPS + gh
  credential helper.
- All kingdom changes land branch → PR → squash-merge → delete branch. Never
  commit to `main` directly; never force-push over a squash (see root CLAUDE.md
  merge hygiene).
- Every PR carries its gate class in the body; gate decisions recorded via
  `scripts/gate-record.sh` before merge.
- Per-project state under `.orchestrator/projects/state/` rides kingdom PRs —
  a session's final commit must include promoted memory + reports (session-end
  workflow handles this).

## Open PR state

- Maintained by the session-end workflow. Check `gh pr list` at bootstrap.
