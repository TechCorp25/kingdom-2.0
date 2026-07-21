---
name: session-lifecycle
description: Run the mandatory Kingdom session lifecycle — kingdom bootstrap, numbered project selection, project bootstrap, session-goals file. Use at every session start, after /clear, when the SessionStart injection appears, or when asked to "start the session", "bootstrap", "pick a project", or "continue".
---

# Session lifecycle

Execute the four steps IN ORDER; a session that skips one is invalid.

1. **Kingdom bootstrap** — follow `automate-dev-suite/workflows/kingdom-bootstrap.md`
   against the SessionStart injection (drift, todos, per-project sync).
2. **Project selection** — ask the owner which project this session is for as a
   NUMBERED multiple-choice question (numbers from the injected registry menu),
   then run `automate-dev-suite/scripts/select-project.sh <n>`. The sandbox is
   active from that moment.
3. **Project bootstrap** — follow `automate-dev-suite/workflows/project-bootstrap.md`
   (memory reads, remediation, git state, session branch).
4. **Session goals** — follow `automate-dev-suite/workflows/session-goals.md`
   (`scripts/session-goals.sh`, create from owner input if absent).

Then work the goals through task-tier memory, promoting on completion
(`scripts/memory-promote.sh task`), with gates per `automate-dev-suite/gates/`.
