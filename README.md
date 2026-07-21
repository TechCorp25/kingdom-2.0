# Kingdom v2 — automate-dev-suite

File-based, Claude Code-native control plane for AI-assisted software development.
Root path: `~/kingdom-2.0`. Runs on Linux (ChromeOS Crostini, user `techcorp2024`).

This repo is the **environment safety net**: it syncs the entire kingdom
scaffolding (suite, hooks, workflows, templates, rules) **plus** every project's
persistent memories, reports, patterns, and permissions. Project source code
never lives here — each project under `projects/` is its own nested git repo
with its own remote, and `projects/` is ignored by this repo entirely.

## Layout

```
CLAUDE.md               Root operating contract (read first)
.claude/                Tier-1 hooks, skills, agents, settings
automate-dev-suite/     The suite: workflows, scripts, templates, gates, docs
.orchestrator/
  .claude/memory/       Tier-1 global environment memory
  registry/             Project registry (kingdom = source of truth)
  reports/              Kingdom-level reports, gate audit trail, todos
  projects/
    state/{project}/    Canonical per-project kingdom-synced state (memory,
                        reports, patterns, permissions) — symlinked into each
                        project at projects/{project}/.orchestrator
    tasks/{project}/session-goals/   DateTime-{session-plan}.md files
projects/               Nested project repos (each syncs to its OWN remote)
```

## Bootstrap on a new machine

```bash
git clone git@github.com:TechCorp25/kingdom-2.0.git ~/kingdom-2.0
cd ~/kingdom-2.0 && automate-dev-suite/scripts/bootstrap-machine.sh   # re-clones projects, relinks state
claude   # always run Claude Code from this root, never from inside a project
```

See `automate-dev-suite/docs/` for architecture decisions and runbooks.
