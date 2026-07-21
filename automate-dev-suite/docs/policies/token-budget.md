# Policy — token budget

Token efficiency is mandatory across the kingdom and every project. Optimise
for **reconstructable signal per token**, not for length or thoroughness
theatre. (Complements DD-004; this file holds the operational discipline.)

## Search & read

- Prefer `Grep`/`Glob` over `Read` to locate things. Read only the slice you
  need (`offset`/`limit`), not whole files "to be safe."
- For breadth ("where is X / which files touch Y"), delegate to the
  **Explore** agent instead of opening many files in the main thread.
- Don't re-read a file you just wrote/edited — the harness tracks its state.
- Batch independent tool calls into one turn (parallel), not serial
  round-trips.

## Writing (memory, reports, replies)

- Point to paths and docs; don't paste large bodies that already live in the
  repo. Bulk material lands in task-tier files, referenced by path.
- Memory files are re-loaded every session — keep them dense and
  pointer-based. A bloated memory base taxes every future run.
- In replies, lead with the answer. Don't narrate options you won't take or
  re-derive facts already established in the conversation.

## Agents & skills

- Spawning a subagent or a multi-agent team has real token cost. Use it when
  the work genuinely needs it, never for questions/reads/single-file lookups.
- Reuse a running agent (continue it) rather than cold-spawning a fresh one
  when its context still applies.
- The triage rule from v1 that held up: **does this change application code
  and need to end green?** → structured multi-agent workflow. Otherwise →
  direct.

## Context window

- Treat the window as a budget **with a reserve** (~15–20%). Before it gets
  heavy: promote task/session memory and complete continuity steps
  (`context-continuity.md`) — never spend the last of the window and then try
  to hand off.
