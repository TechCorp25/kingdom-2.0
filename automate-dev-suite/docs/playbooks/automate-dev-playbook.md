# Playbook — wielding the automate-dev skill (v1-proven)

The skill bundle lives in `.claude/skills/automate-dev/`. This is the *meta*
guidance for using it well, distilled from v1 daily use.

## When

Default path for code-changing work: build / fix / refactor / feature /
anything multi-file that must end green. Stays OFF for questions, reads,
audits, single-file trivial edits — firing a team for a read-only question is
a token-budget violation. The triage rule: **does this change application
code and need to end green?** → the skill. Otherwise → direct.

## How to run well

- **One task at a time.** Scope it to a single task, let it close green, then
  the next. Never hand it a multi-task batch — it loops
  build→review→test→fix per task.
- **Frame as task + operating context + explicit verification**, never as a
  persona.
- **Trust the gates over the script's score.** Its Python review scripts
  (`scripts/code_reviewer.py`, `references/quality-gates.md`) are heuristic
  and **non-authoritative for JSX/JS** — lint/types/tests + real review
  decide.
- **Verify by running**, not by green build alone. A green build ≠ it works /
  renders.
- It is the executor; architectural decisions and gated steps stay above it.
  It never self-approves past a gate — gate-check and the owner/Fable
  protocol own that (`automate-dev-suite/gates/`).

## Close-out (every green task)

1. Promote task memory (`scripts/memory-promote.sh task`).
2. Keep `SESSION.md` current; at session end follow
   `workflows/session-end.md` (promotion → PR handed to owner).
3. Context heavy → `docs/policies/context-continuity.md` first, then continue.

## Guardrails

- Security-critical work: review file changes one-by-one, never bulk-approve;
  don't push security-sensitive work past ~70–80% context.
- Zero breaking changes without explicit owner approval; preserve existing
  functionality always.
