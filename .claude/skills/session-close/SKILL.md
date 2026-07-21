---
name: session-close
description: Close a Kingdom session cleanly — promote memory, distil durable facts, carry todos, commit and PR both git layers, verify sync. Use when the owner says "wrap up", "end the session", "close", when goals are met, or before an imminent context compaction.
---

# Session close

Follow `automate-dev-suite/workflows/session-end.md` end-to-end:

1. `automate-dev-suite/scripts/memory-promote.sh task` (if the task has an
   outcome) then `memory-promote.sh session`.
2. Complete the script's printed checklist — distil to `PROJECT.md`, write
   `NEXT-SESSION.md` todos, reset `SESSION.md`.
3. Project repo: commit → push → PR. Kingdom repo: commit promoted state +
   reports on the kingdom branch → push → PR.
4. `automate-dev-suite/scripts/sync-check.sh` — all lines `✓`, or carry `!`
   lines as todos.

Never end a session with an un-promoted `SESSION.md`; if forced to stop early,
say so and let the SessionEnd hook's remediation marker stand.
