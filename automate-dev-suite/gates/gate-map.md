# Gate map — which class governs which action

Hard rules in `gates.md` §1 always apply on top of this map.

| Workflow / action | Gate class |
|---|---|
| **Kingdom bootstrap** — pull ff-only when behind | go |
| Kingdom `main` diverged | **HARD** |
| **Project bootstrap** — ff-pull / push / stash-and-branch | go |
| Project history diverged | **HARD** |
| Session remediation (promote crashed session) | go |
| **Suite/kingdom PR merge** (scaffolding, workflows, docs, state) | self-check |
| Suite hook/permission changes (`.claude/settings.json`, guards) | self-check |
| Weakening or removing a guard/gate/boundary rule | **HARD** |
| **Project PR merge** — code within session goals, tests green | self-check |
| Project PR touching auth, payments, data deletion, or migrations | **HARD** |
| Dependency updates — patch/minor, lockfile clean | self-check |
| Dependency updates — major version | **HARD** |
| **New project creation** (repo on owner's GitHub, private) | self-check |
| Making any repo public, deleting a repo/branch with unmerged work | **HARD** |
| Deployment to a hosted service (EAS, Railway, …) | **HARD** (keys + go/no-go are the owner's) |
| Security finding high/critical — merge despite it | **HARD** |
| Security finding medium/low — fix lands in normal PR | self-check |
| Memory promotion, reports, session-goals files | go |
| Modifying `gates/`, `gate-map.md`, `risk-envelope.md` | **HARD** |
