# Workflow — git layers (branch · commit · PR · sync)

**Applies to both layers** — kingdom repo and project repos — with the DD-001
boundary between them. **Gate class:** success/go; merges are gated per
`gates/gate-map.md`.

## Standing rules (both layers)

- Branch → PR → squash-merge → delete branch. Never commit to `main`.
- A squash on `main` is not an ancestor of its source branch: after any squash,
  branch FRESH from updated `main`; never force-push over one; land
  post-squash commits by cherry-pick/`rebase --onto` only.
- "Committed locally" ≠ "on main": verify with
  `git diff --stat origin/main HEAD` before building on prior work.
- Secrets never in either layer (gitignored env files only; boundary pre-commit
  hook also blocks `.env`/keys).

## Kingdom layer

- Session branch: `session/YYYY-MM-DD-<slug>` (or `build/NN-<component>` during
  suite builds). Carries: suite changes, promoted state, reports, registry.
- PR body declares the gate class of what it lands; gate decision recorded
  before merge (`scripts/gate-record.sh`).

## Project layer

- Session branch per project bootstrap; PR to the project's own remote;
  project CI/checks are that repo's own concern.
- The boundary pre-commit hook blocks state/secret paths; `boundary-verify.sh`
  audits both directions.

## Remote creation

Suite-owned: `new-project.sh` creates private project remotes via `gh`;
adopted projects (`adopt-project.sh`) keep their existing remote untouched.

## Reporting · Tokens

PR URLs and merge decisions land in `SESSION.md`; gate records in
`reports/gates/`. Use `git status`/`diff --stat` pointers, not full diffs, in
conversation; full diffs live in the PR where the reviewer reads them once.
