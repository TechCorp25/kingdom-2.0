# Workflow — common ground

**Purpose:** surface and validate the assumptions Claude is operating on before
they drive work, and keep them as durable, owner-validated project state.
**Trigger points:** intake · before planning · mid-execution when work feels
misaligned · when the owner asks what Claude is assuming · alongside project
bootstrap on a resumed session.
**Gate class:** a success/go row for recording assumptions is *proposed* at
`gates/_proposals/2026-07-25T08-46-44-gate-map.md` and is **not live** until the
owner promotes it — until then these actions are unlisted and take the HARD
default (`gate-check` skill). Changes to the skill or script are self-check.

## Steps

1. **Bind and initialise** → `scripts/common-ground.sh init`. Identity comes from
   the registry via the session binding; an unbound session is an error, not a
   fallback. The command is idempotent and re-renders existing state.
2. **Surface** → scan config files, conversation, and the existing ground file;
   classify by type and tier per the skill's
   `references/assumption-classification.md`. High-impact assumptions (auth,
   payments, data deletion, migrations) start at OPEN and are flagged — those
   carry a HARD gate in `gates/gate-map.md`.
3. **Validate with the owner** → present via `AskUserQuestion`; ask direct
   questions for anything `uncertain`. Type is immutable; tier changes need
   owner confirmation. Record each with `add` / `tier <ID> <TIER> "<reason>"`.
4. **Read back** → `list` for the full view, `summary` for counts, `validate`
   to mark the set still current.
5. **Graph (optional)** → build the mermaid per `references/reasoning-graph.md`,
   then `graph --file <path>`. Alternatives are greyed, never deleted;
   superseded graphs archive automatically.

## Reporting hook

State lives at `.orchestrator/projects/state/{p}/patterns/common-ground/` and is
tracked, so it rides the session's kingdom PR with no extra reporting step.
`ground.index.json` is the source of truth; `COMMON-GROUND.md` is generated and
must never be hand-edited. Superseded graphs land in `archive/` under the
dash-form timestamp convention.

## Token-cost rationale

File I/O only — no model calls, no network, no external binaries beyond `bash`
and `python3`. The ground file is the point: a resumed session reads one small
file instead of re-deriving project assumptions from scratch, and `summary`
costs a handful of lines when the full list is not needed. Assumptions carried
forward this way are cheaper and more reliable than re-inferring them, which is
the same economics as the memory tiers (DD-004).
