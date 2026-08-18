# 003 — common-ground port

Record of the `common-ground` integration: what was imported, what was converted
and why, and what the owner still has to do. Companion to the PR on
`claude/common-ground-kingdom-integration-wfdbjk`.

## Provenance

| Field | Value |
|---|---|
| Source | `github.com/jeffallan/claude-skills` |
| Path | `commands/common-ground` + its direct dependency `docs/workflow/common-ground.md` |
| Pinned commit | `e8be415bc94d8d6ebddc2fb50e5d03c6e27d4319` (2026-05-20) |
| Retrieved | git protocol clone (the session proxy blocks `api.github.com` and `github.com` HTML) |

SHA256 of the imported files at that commit:

```
7c7091eda37d8c79b67f8a6550006de678da228329b68e7e9a213170cf7a079f  COMMAND.md
2f48ff6b7d85b64914a670c3fcef0e9ba0a537549af6097c54841ac9ad964adc  common-ground.yaml
01ed385df6c4abca331cbce649fcf6c442ba09c1de89fa414d9bb802d12f9867  references/assumption-classification.md
c3ce200c9d8123942be93d156ce4eebb44cb8c84c036ee154e7896ed467d753b  references/file-management.md
5cb2c3dc96cd384d0c05edfd02a565f5394ce7ee6fb5d799d0dcf1459ab31eb1  references/reasoning-graph.md
```

`docs/COMMON_GROUND.md` in the upstream repo was **excluded**: the README points
at it, but `common-ground` does not reference it, so it is a reverse reference
rather than a direct dependency.

## External dependencies found, and how each was converted

Upstream's own doc claims "No external tooling required". That checked out —
there was no MCP, no network call, no database, no daemon, and no `jq`, `curl`,
`node`, or `npm`. The real externalities were storage location and identity.

| Externality | Conversion | Rationale |
|---|---|---|
| State in `~/.claude/common-ground/{project_id}/` | `.orchestrator/projects/state/{p}/patterns/common-ground/` | Home-dir state escapes both git layers and every guard. `sandbox-guard.py` only resolves projects under `projects/` and `.orchestrator/projects/state/` — a kingdom-global path returns `None` from `project_of()` and gets **no sandbox check at all**. `patterns/` is the pre-approved slot in the DD-001 boundary table. Coverage caveat: this buys the **file-tool** arm of the guard, not the Bash arm — see "Guard defect raised" below. |
| `git remote get-url origin` + URL normalisation | Registry `name` + session binding | Registry names already match `^[a-z0-9][a-z0-9-]*$`, so they are filesystem-safe and unique by construction. The normalisation algorithm becomes unnecessary. |
| `pwd` fallback → `local/{munged-path}` | Removed — unbound is an error | A silent fallback would write state for an unregistered project outside sandbox enforcement. Fail closed. |
| Global `index.md` project registry | Dropped | `projects.json` already is the registry; a second one duplicates state (DD-004 principle 4). |
| `REASONING.mermaid` in the project root | Kingdom state dir, `--standalone` only | In the project working tree the generated project `.gitignore` matches nothing like it, so it would be committed to the project's own remote — a DD-001 breach. |
| `common-ground.yaml` command manifest | Dropped | Upstream plugin packaging. Kingdom has no `.claude/commands/` and no manifest; skills are auto-discovered from `SKILL.md`. |
| `archive/{timestamp}-{reason}.md` with `:` | Dash-form `YYYY-MM-DDTHH-MM-SS` | Kingdom filename convention. |

Net result: the port runs on `bash` and `python3` only. Both upstream shell-outs
are gone, so it has fewer external dependencies than the original.

## Defects found in the source and fixed in the port

1. `--check` wrote a `last_validated` field that appeared in no schema. Now declared.
2. The history `action` enum disagreed between the markdown table and the JSON
   schema (`Archived` in one, absent from the other; `validated` written but never
   declared). Fixed at `created|promoted|demoted|validated|archived`.
3. Graph alternative nodes used `A{n}` while assumption IDs use `A{n}` too
   (`A001`). After `--graph` both live in one file and `A1` is ambiguous against
   `A001`. Alternatives are now `ALT{n}`.
4. Flag precedence was undefined upstream (`--graph` and `--check` both invoke
   default mode). The skill states the order explicitly.

## Division of labour

Deterministic file I/O lives in `scripts/common-ground.sh`; classification and
owner interaction live in the skill. This mirrors `memory-promote.sh` — the
script is the part that must be reproducible and testable, and it makes the
capability auditable without a model in the loop.

Writes are atomic (`.tmp` + `os.replace`), so an interrupted run cannot leave a
half-written index or truncated ground file.

## Gate position

`gates-guard.py` forbids the assistant from editing `gate-map.md`, so the two new
rows are a **proposal** at
`automate-dev-suite/gates/_proposals/2026-07-25T08-46-44-gate-map.md`.

Until the owner promotes it the action is unlisted, and `gate-check` resolves an
unlisted action to the nearest listed analogue or HARD — safe, but it will prompt
on every assumption write. Promote with:

```bash
git mv automate-dev-suite/gates/_proposals/2026-07-25T08-46-44-gate-map.md \
       automate-dev-suite/gates/gate-map.md
```

## Regression evidence

A read-only before/after snapshot (tracked-file checksums, on-disk tree,
`settings.json`, skill/agent/script/workflow inventories, gate-file checksums,
registry, `.gitignore`, syntax checks) was captured either side of the change.
The only non-additive lines in the diff are the git HEAD hash and the checksum
of `.orchestrator/reports/gates/subagents.jsonl`, which the SubagentStop hook
appends to on its own. No pre-existing file's checksum changed.

Note for anyone re-running that snapshot: it must not use `python3 -m py_compile`
to syntax-check the hooks — that writes `__pycache__/` into `.claude/hooks/` and
mutates the very tree being measured. Use `ast.parse` instead.

## Guard defect raised (pre-existing — not introduced here)

`sandbox-guard.py`'s **Bash** arm does not protect
`.orchestrator/projects/state/{p}/…`. The regex at `sandbox-guard.py:80` matches
non-overlapping, so on that path it consumes `projects/state` and captures
`"state"` — never the project name — and the cross-project denial never fires:

```
.orchestrator/projects/state/chat-app/…  →  ['state']      (no denial)
projects/chat-app/…                      →  ['chat-app']   (denial works)
```

The **file-tool** arm (Write/Edit/Read/Grep/Glob) is unaffected and denies
correctly. `memory-promote.sh:12` carries the same `--project` override and is
exposed the same way, so this is a general gap rather than anything specific to
common-ground.

Mitigation taken here: `common-ground.sh` refuses a `--project` that contradicts
the session binding, in the script itself, instead of relying on the guard.

Fixing the guard is a HARD-gated change (`gate-map.md`: "Weakening or removing a
guard/gate/boundary rule"; tightening one still touches guard code), so it is
**left for the owner** and carried in `NEXT-SESSION.md` rather than patched in
this PR.
