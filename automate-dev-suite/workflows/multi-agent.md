# Workflow — multi-agent orchestration

**Purpose:** specialised agents with scoped context and clean hand-offs; the
orchestrating session stays lean.

## Roles (agent definitions in `.claude/agents/`)

| Agent | Use for | Context handed off |
|---|---|---|
| `code-explorer` | breadth-first codebase understanding | question + paths; returns conclusions, not dumps |
| `code-architect` | design blueprints before implementation | goals + constraints + explorer findings |
| `code-reviewer` | multi-dimensional review of changed code | diff/branch pointer + review dimensions |
| `fable-reviewer` | self-check gate approvals (see `gates/`) | PR URL + gate record + risk envelope |

## Rules

1. **Scoped hand-offs** — a subagent gets the minimum brief that lets it
   succeed: goal, constraints, pointers. Never a transcript dump.
2. **Results land in files** — subagent output worth keeping goes to the task
   tier or a report, then is referenced; the orchestrator relays conclusions.
3. **Fresh context for judgement** — review/gate agents always start clean so
   they judge the artifact, not the conversation that produced it.
4. **Parallel only when independent** — file-disjoint work may fan out;
   anything sharing files runs sequentially with explicit ownership.
5. Every subagent completion is auto-logged (SubagentStop → gate backbone).

## Token rationale

Subagents spend their own context, not the session's; the session pays only
for briefs and conclusions. Exploration is delegated precisely because raw
exploration is the most token-hungry activity.
