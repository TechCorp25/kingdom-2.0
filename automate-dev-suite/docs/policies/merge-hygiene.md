# Policy — git & merge hygiene (v1 lessons + v2 additions)

The trap that stranded work in v1 more than once: **a squash-merge on `main`
is NOT an ancestor of its source branch.** Internalise the consequences.

## Squash-merge reality

- After a squash, `git merge/pull --ff-only` from the old branch will
  **refuse** — treat that refusal as the signal the branch diverged, never as
  something to force past.
- A branch forked *before* a prior squash may not have `origin/main` as an
  ancestor → land it ONLY via a fresh squash-merge PR, never a local merge.

## Hard rules

- **Never force-push** a post-squash feature branch onto `main` — it erases
  the PR merge. To land commits made after a squash, cherry-pick (or
  `rebase --onto origin/main`) only the genuinely-new commits, then
  fast-forward + push.
- **`git pull --ff-only` only.** If it refuses, STOP and reconcile — diagnose
  before acting. Any repo written by more than one actor makes blind merges
  dangerous.
- **"Committed locally" ≠ "on main".** Before building on prior work, confirm
  it shipped: `git diff --stat origin/main HEAD` and check key files exist on
  `origin/main`.
- **Delete the source branch in the same step as the squash-merge** (subject
  to the stacked-PR rule below), and branch fresh from updated `main`. Never
  keep committing on a branch whose earlier state was squashed — that is
  exactly how work gets stranded off `main`.
- **Stage by explicit path** — never `git add -A` on a dirty tree.
- **Push before you duplicate** — unpushed commits were the root cause of
  stale repo copies in v1.
- A `git push` failing on a **network** error may be retried with backoff
  (2/4/8/16 s). A non-fast-forward rejection means diverge → reconcile; never
  blind-retry.

## Stacked PRs (learned 2026-07-21, v2 stack merge)

- Squash-merging PR N with `--delete-branch` **auto-CLOSES** PR N+1 whose base
  was that branch — GitHub does not retarget after base deletion, and a closed
  PR cannot be reopened once its head has been force-pushed.
- Correct sequence per PR in a stack: rebase the branch onto updated `main`
  (duplicate patches drop automatically) → force-push **with lease** →
  retarget via REST (`gh api -X PATCH repos/{o}/{r}/pulls/N -f base=main` —
  `gh pr edit --base` hits a GraphQL projectCards bug) → merge **without**
  deleting the branch. Delete all stack branches only after the last PR lands.
