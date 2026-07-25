# Ground file management

> Reference for: common-ground
> Load when: storage operations, project identity, ground file format

Converted from `jeffallan/claude-skills@e8be415`
`commands/common-ground/references/file-management.md`. This is the file the
conversion changed most: upstream stored state in the user's home directory and
derived identity by shelling out to git. Both are gone.

---

## Conversion record — what changed and why

| Upstream | Kingdom | Reason |
|---|---|---|
| `~/.claude/common-ground/{project_id}/` | `.orchestrator/projects/state/{p}/patterns/common-ground/` | Home-dir state escapes both git layers entirely and every guard. State under `state/{p}/` is tracked, rides kingdom PRs, and is covered by `sandbox-guard.py`'s **file-tool** arm. `patterns/` is the pre-approved slot in the DD-001 boundary table. |
| `git remote get-url origin`, then URL normalisation | `.orchestrator/registry/projects.json` + the session binding in `.orchestrator/runtime/current-session.json` | Removes both shell-outs. Registry names already match `^[a-z0-9][a-z0-9-]*$`, so they are filesystem-safe and unique by construction — the whole normalisation algorithm is unnecessary. |
| `pwd` fallback → `local/...` id | *(none — unbound is an error)* | A pwd fallback would silently write state for an unregistered project, outside sandbox enforcement. Failing closed is the kingdom default. |
| Global `~/.claude/common-ground/index.md` registry | *(dropped)* | `projects.json` already is the project registry. A second one duplicates state and violates DD-004 principle 4. |
| `REASONING.mermaid` in the **project root** | `…/patterns/common-ground/REASONING.mermaid` (only with `--standalone`) | In the project working tree it is untracked by the generated project `.gitignore`, so it would be committed to the project's own remote — a DD-001 boundary breach. |
| `archive/{timestamp}-{reason}.md` with `:` in the name | `archive/YYYY-MM-DDTHH-MM-SS-{reason}.md` | Kingdom filename convention: colons become dashes in filenames, `%H:%M:%S` only inside file content. |
| `common-ground.yaml` command manifest | *(dropped)* | Upstream plugin packaging with no kingdom analogue. Skills are auto-discovered from `SKILL.md`; there is no manifest to register with. |
| No external tooling required (upstream's own claim) | Verified true — `git`/`pwd` were the only shell-outs and both are now gone | The kingdom port has **zero** external binaries beyond `bash` and `python3`. |

---

## Directory structure

```
.orchestrator/projects/state/{p}/patterns/common-ground/
├── COMMON-GROUND.md      # human-readable, GENERATED — never hand-edit
├── ground.index.json     # machine-readable, SOURCE OF TRUTH
├── REASONING.mermaid     # only when --standalone was requested
└── archive/
    └── YYYY-MM-DDTHH-MM-SS-{reason}.md
```

Resolve the directory for the bound project with:

```bash
automate-dev-suite/scripts/common-ground.sh path
```

---

## Project identity

Identity is the registry `name` of the bound project — nothing is derived, parsed,
or normalised. The script resolves it in this order:

1. `["project"]` from `.orchestrator/runtime/current-session.json` (set by
   `select-project.sh`) — this always wins.
2. `--project <name>`, honoured **only when no session is bound**.
3. Otherwise **exit 1** with instructions. There is no fallback.

Any name that is not in `.orchestrator/registry/projects.json` is rejected, which
is also what stops path traversal through `--project`.

> **Why the script enforces the binding itself rather than trusting the guard.**
> `sandbox-guard.py` has two arms. Its **file-tool** arm (Write/Edit/Read/Grep/Glob)
> correctly denies cross-project access to this tree. Its **Bash** arm does not:
> the regex at `sandbox-guard.py:80` matches non-overlapping, so on
> `.orchestrator/projects/state/{p}/…` it consumes `projects/state` and yields
> `"state"` — never the project name — and no denial fires. This script writes via
> Bash, so it would be uncovered. It therefore refuses a `--project` that
> contradicts the binding, in the script itself.
>
> That regex is a **pre-existing guard defect**, not one this capability
> introduced, and `memory-promote.sh` carries the same `--project` override. Fixing
> a guard is a HARD-gated change, so it is raised for the owner separately rather
> than patched here.

---

## Machine index (`ground.index.json`) — source of truth

```json
{
  "version": "1.0",
  "project_id": "{registry name}",
  "project_name": "{registry name}",
  "created": "{YYYY-MM-DDTHH:MM:SS}",
  "last_updated": "{YYYY-MM-DDTHH:MM:SS}",
  "last_validated": null,
  "next_id": 1,
  "assumptions": [
    {
      "id": "A001",
      "title": "{short title}",
      "type": "stated|inferred|assumed|uncertain",
      "tier": "ESTABLISHED|WORKING|OPEN",
      "assumption": "{full description}",
      "source": "{evidence}",
      "validated": "{timestamp or empty}",
      "context": "{when it applies}",
      "created": "{timestamp}",
      "history": [
        {"date": "{timestamp}", "action": "created|promoted|demoted|validated|archived",
         "from_tier": null, "to_tier": "WORKING", "reason": null}
      ]
    }
  ],
  "archived": [],
  "reasoning_graph": null
}
```

Two schema corrections against upstream, both from defects found during
conversion:

- **`last_validated` is declared.** Upstream's `--check` mode wrote this field
  but it appeared in no schema.
- **The history action enum is fixed at `created|promoted|demoted|validated|archived`.**
  Upstream's markdown table and JSON schema disagreed (`Archived` appeared in one
  and not the other), and `validated` was written by `--check` but never declared.

### Assumption IDs

Format `A{n:03d}` — `A001`, `A002`. Sequential per project, **never reused**, with
the high-water mark held in `next_id`. The script owns allocation; never pick an
ID by hand.

---

## Ground file (`COMMON-GROUND.md`) — generated

Regenerated in full from the index on every mutating command. Sections in order:
header block, `ESTABLISHED`, `WORKING`, `OPEN`, `History`, then `Reasoning Graph`
when one has been embedded.

**Never hand-edit it.** Edits are silently destroyed on the next render. To change
content, mutate the index through the script and let it re-render.

---

## Operations

| Intent | Command |
|---|---|
| Create / repair state | `common-ground.sh init` |
| Add an assumption | `common-ground.sh add --title T --type X --tier Y --assumption A [--source S] [--context C] [--reason R]` |
| Promote / demote | `common-ground.sh tier A001 ESTABLISHED "owner confirmed"` |
| Retire a superseded one | `common-ground.sh archive A001 "superseded by X"` |
| Mark all still valid | `common-ground.sh validate` |
| Read-only view | `common-ground.sh list [--tier ESTABLISHED]` |
| Counts only | `common-ground.sh summary` |
| Re-render after manual index repair | `common-ground.sh render` |
| Embed a reasoning graph | `common-ground.sh graph --file <path> [--standalone]` |
| Print the state directory | `common-ground.sh path` |

`--project <name>` is accepted only when no session is bound (see above).

Unknown options are rejected per command — a typo like `--teir` fails loudly
rather than being silently ignored.

**Atomicity, precisely.** `ground.index.json` and `COMMON-GROUND.md` are each
written to a `.tmp` and `os.replace`d, so neither file can be observed
half-written or truncated. They are two separate replacements, so a run killed
between them can leave the markdown one revision behind the index — `render`
fixes that, and the index is the source of truth either way. Archive files and
`REASONING.mermaid` are written directly. A killed run can leave a `.tmp` beside
the index in a tracked directory; delete it and re-run.

---

## Error handling

| Scenario | Behaviour | Exit |
|----------|-----------|------|
| No project bound and no `--project` | Message pointing at `select-project.sh` | 1 |
| `--project` contradicts the session binding | Refused as cross-project access | 1 |
| Project not in the registry (incl. traversal attempts) | Rejected by name | 1 |
| Command run before `init` | Message pointing at `init` | 1 |
| Unknown assumption ID | Rejected | 1 |
| `graph` with no assumptions yet | Refused — never graph unconfirmed premises | 1 |
| Mermaid file missing | Rejected | 1 |
| Corrupted `ground.index.json` | Named error naming the parse fault, with the repair instruction | 1 |
| No command, bad command, unknown option, bad type/tier, missing required option | Usage message | 2 |
| Mermaid not starting `flowchart` | Rejected | 2 |

`|` and newlines inside any recorded value are escaped when the markdown is
generated, so a stray pipe in a reason cannot break the History table.
