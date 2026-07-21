# DD-001 — Git boundary: symlinked per-project state

**Status:** Accepted · 2026-07-21 · load-bearing for the whole suite

## Requirement (build prompt §4)

Kingdom remote syncs environment scaffolding **plus** per-project memories,
reports, patterns, and permissions. Project remotes sync project code only and
must never contain memories, reports, or CC permissions.

## Evidence

The naive layout (state physically inside `projects/{p}/.orchestrator/`, tracked
by the kingdom repo through ignore-rule whitelists) is impossible: git refuses to
track files inside a nested repository. Empirically verified 2026-07-21 on git
2.x (Crostini):

- `git add projects/proj/.orchestrator/memory/project.md` from the kingdom root
  → silently ignored (nested repo boundary; no index entry created).
- `git add -A` → `error: 'projects/proj/' does not have a commit checked out`,
  `fatal: adding files failed`.

## Decision

Invert the physical layout; preserve the logical one with symlinks.

- Canonical per-project kingdom-synced state:
  `.orchestrator/projects/state/{project}/{memory,reports,patterns,claude}/`
  — tracked by the kingdom repo.
- Wiring inside each project (created by new-project/adopt-project, ignored by
  the generated project `.gitignore`):
  - `projects/{p}/.orchestrator` → `../../.orchestrator/projects/state/{p}`
  - `projects/{p}/.claude`      → `../../.orchestrator/projects/state/{p}/claude`
- The kingdom repo ignores `/projects/` entirely.

Consequences:

- The build-prompt §5 paths hold exactly as written from inside a project
  (`projects/{p}/.orchestrator/memory/project/...`), and CC's hierarchical
  `.claude` loading picks up project-scoped settings/permissions through the
  symlink — while the bytes live in, and sync with, the kingdom repo.
- Project code **cannot** leak into the kingdom remote (structural: `/projects/`
  ignored) and state **cannot** leak into a project remote (structural: state is
  outside the project repo; the symlinks themselves are gitignored there).

## Enforcement layers

1. **Structural** — the symlink inversion above (primary; survives operator error).
2. **Generated `.gitignore`** per project (template:
   `automate-dev-suite/templates/project-gitignore.template`) ignoring
   `.orchestrator`, `.claude`, env/secret files.
3. **Pre-commit hook** installed into every project repo
   (`automate-dev-suite/scripts/git-hooks/project-pre-commit`) blocking any
   commit that stages state paths — belt-and-braces if ignore rules are edited.
4. **Audit** — `automate-dev-suite/scripts/boundary-verify.sh` checks all three
   layers plus symlink integrity; runs in kingdom bootstrap and session end.

## New-machine handover

`git clone` kingdom → `scripts/bootstrap-machine.sh` re-clones each registered
project from its own remote and re-creates the two symlinks per project. State
arrives with the kingdom clone; code arrives with the project clones; nothing
else to restore.
