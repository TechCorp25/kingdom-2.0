---
name: common-ground
description: Surface Claude's hidden assumptions about the bound project, classify them by type and confidence tier, and get them owner-validated before they drive work. Use when assumptions are building up — at intake, before planning, mid-execution, when work feels misaligned, or when asked to list, check, or graph what Claude is assuming.
---

# Common ground

Assumptions live in the bound project's kingdom state, never in `~/.claude` and
never in a project working tree. All file I/O goes through
`automate-dev-suite/scripts/common-ground.sh` — `ground.index.json` is the source
of truth and `COMMON-GROUND.md` is regenerated, never hand-edited.

1. **Bind first** — the script reads the session's project from the registry;
   an unbound session is an error, not a fallback. `common-ground.sh init` is
   idempotent and safe to run every time.
2. **Surface & select** (no flags) — scan config files, conversation, and the
   existing ground file; classify each assumption per
   `references/assumption-classification.md`; present via `AskUserQuestion`
   (multiSelect) and ask direct questions for anything `uncertain`.
3. **Adjust tiers** — confirm proposed tiers with the owner, then record each
   with `common-ground.sh add` / `tier <ID> <TIER> "<reason>"`. Type is
   immutable; tier changes need owner confirmation.
4. **`--list`** → `common-ground.sh list [--tier T]` · **`--check`** → present the
   summary, then `validate` if confirmed, else re-enter step 3.
5. **`--graph`** → build the mermaid per `references/reasoning-graph.md`, then
   `common-ground.sh graph --file <path>`; never drop alternative branches.

Storage layout, formats, and error handling: `references/ground-file-management.md`.
Recording assumptions is `go`-class; shipping changes to this skill is self-check.
