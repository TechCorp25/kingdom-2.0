# {project} — project memory (Tier 2)

Durable facts only. This file is read at every project bootstrap — keep it
small and current; move history to reports.

## What this project is

{one-paragraph purpose; product, stack, remote}

## Durable facts

- Remote: {url}
- Stack: {stack}
- {facts that survive across sessions}

## Conventions and constraints

- {project-specific rules the assistant must follow}

## Pointers

- Last session: see `last-session.md`
- Reports: `.orchestrator/reports/` (sessions, tasks, gates)
- Patterns: `.orchestrator/patterns/`
