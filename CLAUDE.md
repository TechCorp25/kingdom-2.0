# Kingdom v2 — Operating Contract

File-based, Claude Code-native control plane governing every project developed here.
Root: `~/kingdom-2.0`. CC always runs from this root — never from inside a project.
The old `~/kingdom` is a retired, read-only reference. Never modify it.

## Locked architecture

Pure CC-native, file-based state. **No Postgres, no Docker, no custom MCP control
plane.** All environment and project state lives in files synced through two git
layers; the remotes are the distributed state store. Everything is implemented
with hooks, settings permissions, agents, skills, and workflows.
Rationale and decisions: `automate-dev-suite/docs/architecture/`.

## Sources of truth

- **Kingdom** (this repo) — the environment: state, health, project registry
  (`.orchestrator/registry/projects.json`), global rules, cross-project governance.
- **Each project** — itself, individually. Projects never read or write each
  other's state. Zero cross-project or environment contamination.

## Git boundary (hook-enforced — DD-001)

| Syncs to kingdom remote | Syncs to each project's own remote |
|---|---|
| Suite, hooks, workflows, templates, rules | All project source code and docs |
| Per-project memories, reports, patterns, permissions (`.orchestrator/projects/state/{p}/`) | — |

`projects/` is ignored by this repo entirely. Each project's `.orchestrator` and
`.claude` are symlinks into `.orchestrator/projects/state/{p}/`, so memories,
reports, and permissions physically live in the kingdom tree and can never land
in a project remote. Generated project `.gitignore` + a pre-commit hook in every
project repo enforce the same boundary from the other side.
Verify anytime: `automate-dev-suite/scripts/boundary-verify.sh`.

## Four-tier memory (DD-002)

1. **Global** — `.orchestrator/.claude/memory/` · environment health, orientation,
   repo governance. Never project-specific.
2. **Project** — `projects/{p}/.orchestrator/memory/project/` · one project only.
3. **Session** — `.../memory/project/session/` · current session intent and goals.
4. **Task** — `.../memory/project/session/task/` · current task working state so
   large intermediate material never bloats context.

**Promotion:** task → session on task completion; session → project at session
end, before compaction, or when goals are achieved.
Run: `automate-dev-suite/scripts/memory-promote.sh {task|session}`.

## Session lifecycle (mandatory, in order)

1. **Kingdom bootstrap** — remote↔local drift check on kingdom `main`; pick up
   `.orchestrator/reports/todos/NEXT-SESSION.md`; per-project remote checks.
   (SessionStart hook injects status; workflow: `automate-dev-suite/workflows/kingdom-bootstrap.md`.)
2. **Project selection** — ask the owner which project, as a numbered
   multiple-choice question; then run
   `automate-dev-suite/scripts/select-project.sh <n>`. **Sandbox:** after
   selection, no cross-project file access for the rest of the session
   (enforced by the PreToolUse guard, not convention).
3. **Project bootstrap** — read project + last-session memory and referenced
   reports; sync check; remediate if the last session ended unexpectedly; new
   tracked branch; clean tree. Workflow: `workflows/project-bootstrap.md`.
4. **Session goals** — latest `DateTime-{session-plan}.md` in
   `.orchestrator/projects/tasks/{p}/session-goals/` for today, else ask the
   owner and write one.

## Gates (DD-003)

- **Hard stop** — owner approval required. No bypass. (Secrets/keys, destructive
  or irreversible actions, spending, anything in `gates/gate-map.md` marked HARD.)
- **Self-check** — a fresh-context **Fable** reviewer subagent approves in place
  of the owner, within the risk envelope. The PR must be **opened before**
  approval; every decision is recorded via `scripts/gate-record.sh`.
- **Success/go** — objective checklist to keep moving toward session goals.

Definitions, per-workflow map, and risk envelope: `automate-dev-suite/gates/`.

## Working rules

- Token-efficient by default: Grep/Glob over Read, Explore agent for breadth,
  batch independent calls, pointers over pasted dumps, task-tier files for bulk
  intermediate output.
- Production-ready code only; no placeholder stubs. Preserve existing behavior —
  no breaking changes without explicit approval.
- Secrets only in gitignored env files. Never in either repo layer.
- Kingdom-level changes land by branch → PR on this repo; project changes by
  branch → PR on the project repo. Squash-merge; delete source branch; never
  force-push over a squash.
- Record keeping is not optional: hooks log activity; workflows write reports;
  gate decisions are always recorded.

## Everyday commands

```bash
automate-dev-suite/scripts/sync-check.sh          # kingdom + all projects drift check
automate-dev-suite/scripts/select-project.sh <n>  # bind session to project n
automate-dev-suite/scripts/new-project.sh <name>  # scaffold + private remote + wiring
automate-dev-suite/scripts/boundary-verify.sh     # audit the git boundary
automate-dev-suite/scripts/memory-promote.sh task # promote task → session memory
```
