#!/usr/bin/env bash
# common-ground.sh <init|add|tier|validate|list|render|graph|path|summary> [--project P] [options]
#   Kingdom-local assumption ledger for the common-ground skill.
# Deterministic file I/O only — classification and interaction are the skill's job.
# State lives at .orchestrator/projects/state/{p}/patterns/common-ground/ so it is
# sandbox-guarded (DD-001) and rides kingdom PRs. ground.index.json is the source
# of truth; COMMON-GROUND.md is always regenerated from it, never hand-edited.
set -euo pipefail
KINGDOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$KINGDOM"

CMD="${1:?command: init|add|tier|validate|list|render|graph|path|summary}"
shift

case "$CMD" in
  init|add|tier|validate|list|render|graph|path|summary) ;;
  *) echo "✗ bad command '$CMD' (init|add|tier|validate|list|render|graph|path|summary)" >&2; exit 2;;
esac

PROJECT=""
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --project) PROJECT="${2:?--project needs a value}"; shift 2;;
    *) ARGS+=("$1"); shift;;
  esac
done

# Project identity comes from the kingdom registry + session binding — never from
# a git remote or pwd. This removes the upstream shell-outs entirely.
if [ -z "$PROJECT" ]; then
  PROJECT=$(python3 -c "import json;print(json.load(open('.orchestrator/runtime/current-session.json'))['project'])" 2>/dev/null || echo "")
fi
if [ -z "$PROJECT" ]; then
  echo "✗ no project bound — run automate-dev-suite/scripts/select-project.sh <n> first," >&2
  echo "  or pass --project <name> (session lifecycle step 2)." >&2
  exit 1
fi
if ! python3 -c "
import json,sys
reg=json.load(open('.orchestrator/registry/projects.json'))
sys.exit(0 if sys.argv[1] in [p['name'] for p in reg['projects']] else 1)
" "$PROJECT" 2>/dev/null; then
  echo "✗ '$PROJECT' is not a registered project (.orchestrator/registry/projects.json)" >&2
  exit 1
fi

DIR=".orchestrator/projects/state/$PROJECT/patterns/common-ground"
INDEX="$DIR/ground.index.json"
GROUND="$DIR/COMMON-GROUND.md"
TS="$(date +%Y-%m-%dT%H:%M:%S)"
TS_FILE="$(date +%Y-%m-%dT%H-%M-%S)"

if [ "$CMD" = "path" ]; then echo "$DIR"; exit 0; fi

if [ "$CMD" != "init" ] && [ ! -f "$INDEX" ]; then
  echo "! no ground file for '$PROJECT' — run: automate-dev-suite/scripts/common-ground.sh init" >&2
  exit 1
fi

mkdir -p "$DIR/archive"

python3 - "$CMD" "$PROJECT" "$INDEX" "$GROUND" "$DIR" "$TS" "$TS_FILE" "${ARGS[@]+"${ARGS[@]}"}" <<'PY'
import json, os, sys

cmd, project, index_p, ground_p, dirp, ts, ts_file, *rest = sys.argv[1:]

TIERS = ["ESTABLISHED", "WORKING", "OPEN"]
TYPES = ["stated", "inferred", "assumed", "uncertain"]
TIER_BLURB = {
    "ESTABLISHED": "High confidence assumptions. Treat as premises.",
    "WORKING": "Medium confidence. Use but flag if contradicted.",
    "OPEN": "Low confidence. Ask before assuming.",
}


def die(msg, code=2):
    print(f"✗ {msg}", file=sys.stderr)
    sys.exit(code)


def opts(argv):
    """--key value pairs into a dict; bare --flag becomes True."""
    out, i = {}, 0
    while i < len(argv):
        a = argv[i]
        if not a.startswith("--"):
            die(f"unexpected argument '{a}'")
        k = a[2:]
        if i + 1 < len(argv) and not argv[i + 1].startswith("--"):
            out[k], i = argv[i + 1], i + 2
        else:
            out[k], i = True, i + 1
    return out


def load():
    with open(index_p) as f:
        return json.load(f)


def save(d):
    d["last_updated"] = ts
    tmp = index_p + ".tmp"
    with open(tmp, "w") as f:
        json.dump(d, f, indent=2, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, index_p)


def render(d):
    """COMMON-GROUND.md is generated from the index — never edited by hand."""
    L = [
        "# Project Common Ground",
        "",
        f"**Project:** {d['project_name']}",
        f"**Project ID:** {d['project_id']}",
        f"**Created:** {d['created']}",
        f"**Last Updated:** {d['last_updated']}",
        f"**Last Validated:** {d.get('last_validated') or '(never)'}",
        "",
        "---",
        "",
    ]
    for tier in TIERS:
        rows = [a for a in d["assumptions"] if a["tier"] == tier]
        L += [f"## {tier}", "", TIER_BLURB[tier], ""]
        if not rows:
            L += ["_None tracked._", "", "---", ""]
            continue
        for a in rows:
            L += [
                f"### {a['id']}: {a['title']}",
                "",
                f"- **Type:** {a['type']}",
                f"- **Assumption:** {a['assumption']}",
                f"- **Source:** {a['source'] or '(none recorded)'}",
                f"- **Validated:** {a['validated'] or '(not validated)'}",
                f"- **Context:** {a['context'] or '(any)'}",
                "",
            ]
        L += ["---", ""]

    L += ["## History", "", "| Date | Action | ID | Details |", "|------|--------|------|---------|"]
    hist = []
    for a in d["assumptions"] + d.get("archived", []):
        for h in a.get("history", []):
            frm, to = h.get("from_tier"), h.get("to_tier")
            move = f"{frm or '-'} → {to or '-'}"
            hist.append((h["date"], h["action"], a["id"], f"{move}{'; ' + h['reason'] if h.get('reason') else ''}"))
    for row in sorted(hist):
        L.append(f"| {row[0]} | {row[1].capitalize()} | {row[2]} | {row[3]} |")
    L += ["", "---", ""]

    graph = d.get("reasoning_graph")
    if graph:
        L += [
            "## Reasoning Graph",
            "",
            f"Last generated: {graph['generated']}",
            "",
            "```mermaid",
            graph["mermaid"].rstrip("\n"),
            "```",
            "",
            "### Graph Legend",
            "",
            "| Colour | Meaning |",
            "|--------|---------|",
            "| Yellow | Decision point (requires choice) |",
            "| Green | Chosen path (high confidence) |",
            "| Grey | Alternative (not taken) |",
            "| Orange | Uncertain (needs clarification) |",
            "| Blue | Implementation (concrete action) |",
            "",
            "---",
            "",
        ]

    L += ["*Managed by the common-ground skill — regenerate, never hand-edit.*", ""]
    tmp = ground_p + ".tmp"
    with open(tmp, "w") as f:
        f.write("\n".join(L))
    os.replace(tmp, ground_p)


def counts(d):
    return {t: sum(1 for a in d["assumptions"] if a["tier"] == t) for t in TIERS}


# ── init ────────────────────────────────────────────────────────────────
if cmd == "init":
    if os.path.exists(index_p):
        d = load()
        render(d)
        print(f"· ground file already exists for {project} ({len(d['assumptions'])} assumptions) — re-rendered")
        sys.exit(0)
    d = {
        "version": "1.0",
        "project_id": project,
        "project_name": project,
        "created": ts,
        "last_updated": ts,
        "last_validated": None,
        "next_id": 1,
        "assumptions": [],
        "archived": [],
        "reasoning_graph": None,
    }
    save(d)
    render(d)
    print(f"✓ common-ground initialised for {project} — {dirp}")
    sys.exit(0)

d = load()

# ── add ─────────────────────────────────────────────────────────────────
if cmd == "add":
    o = opts(rest)
    for req in ("title", "type", "tier", "assumption"):
        if req not in o or o[req] is True:
            die(f"add needs --{req}")
    if o["type"] not in TYPES:
        die(f"bad --type '{o['type']}' ({'|'.join(TYPES)})")
    if o["tier"] not in TIERS:
        die(f"bad --tier '{o['tier']}' ({'|'.join(TIERS)})")
    aid = f"A{d['next_id']:03d}"
    d["next_id"] += 1
    d["assumptions"].append({
        "id": aid,
        "title": o["title"],
        "type": o["type"],                       # immutable — audit trail
        "tier": o["tier"],
        "assumption": o["assumption"],
        "source": o.get("source") if o.get("source") is not True else "",
        "validated": ts if o["tier"] == "ESTABLISHED" else "",
        "context": o.get("context") if o.get("context") is not True else "",
        "created": ts,
        "history": [{"date": ts, "action": "created", "from_tier": None,
                     "to_tier": o["tier"], "reason": o.get("reason") if o.get("reason") is not True else None}],
    })
    save(d)
    render(d)
    print(f"✓ {aid} added [{o['tier']}/{o['type']}] — {o['title']}")
    sys.exit(0)

# ── tier (promote / demote) ─────────────────────────────────────────────
if cmd == "tier":
    if len(rest) < 2:
        die("tier needs <ID> <TIER> [reason]")
    aid, new_tier = rest[0], rest[1]
    reason = rest[2] if len(rest) > 2 else None
    if new_tier not in TIERS:
        die(f"bad tier '{new_tier}' ({'|'.join(TIERS)})")
    a = next((x for x in d["assumptions"] if x["id"] == aid), None)
    if a is None:
        die(f"no such assumption '{aid}'", 1)
    old = a["tier"]
    if old == new_tier:
        print(f"· {aid} already {new_tier} — no change")
        sys.exit(0)
    action = "promoted" if TIERS.index(new_tier) < TIERS.index(old) else "demoted"
    a["tier"] = new_tier
    if new_tier == "ESTABLISHED":
        a["validated"] = ts
    a["history"].append({"date": ts, "action": action, "from_tier": old,
                         "to_tier": new_tier, "reason": reason})
    save(d)
    render(d)
    print(f"✓ {aid} {action}: {old} → {new_tier}")
    sys.exit(0)

# ── validate ────────────────────────────────────────────────────────────
if cmd == "validate":
    d["last_validated"] = ts
    for a in d["assumptions"]:
        a["history"].append({"date": ts, "action": "validated", "from_tier": a["tier"],
                             "to_tier": a["tier"], "reason": "confirmed still valid"})
    save(d)
    render(d)
    print(f"✓ {len(d['assumptions'])} assumptions revalidated at {ts}")
    sys.exit(0)

# ── render ──────────────────────────────────────────────────────────────
if cmd == "render":
    render(d)
    print(f"✓ {ground_p} regenerated from index")
    sys.exit(0)

# ── graph ───────────────────────────────────────────────────────────────
if cmd == "graph":
    o = opts(rest)
    src = o.get("file")
    if not src or src is True:
        die("graph needs --file <path-to-mermaid> [--standalone]")
    if not os.path.exists(src):
        die(f"no such mermaid file '{src}'", 1)
    with open(src) as f:
        mermaid = f.read().strip()
    if not mermaid.startswith("flowchart"):
        die("mermaid must begin with 'flowchart' (see references/reasoning-graph.md)")
    if d.get("reasoning_graph"):
        prev = os.path.join(dirp, "archive", f"{ts_file}-graph-superseded.md")
        with open(prev, "w") as f:
            f.write(f"# Superseded reasoning graph\n\nGenerated: {d['reasoning_graph']['generated']}\n"
                    f"Archived: {ts}\n\n```mermaid\n{d['reasoning_graph']['mermaid']}\n```\n")
    d["reasoning_graph"] = {"generated": ts, "mermaid": mermaid}
    save(d)
    render(d)
    msg = f"✓ reasoning graph embedded in {ground_p}"
    if o.get("standalone"):
        # Kingdom divergence: standalone lives in kingdom state, never the project
        # working tree, so it can never reach a project remote (DD-001).
        stand = os.path.join(dirp, "REASONING.mermaid")
        with open(stand, "w") as f:
            f.write(mermaid + "\n")
        msg += f"\n✓ standalone written to {stand}"
    print(msg)
    sys.exit(0)

# ── list / summary ──────────────────────────────────────────────────────
c = counts(d)
if cmd == "summary":
    print(f"project: {project}")
    print(f"tracked: {len(d['assumptions'])}")
    for t in TIERS:
        print(f"{t}: {c[t]}")
    print(f"last_validated: {d.get('last_validated') or '(never)'}")
    sys.exit(0)

o = opts(rest)
want = o.get("tier")
if want and want is not True and want not in TIERS:
    die(f"bad --tier '{want}' ({'|'.join(TIERS)})")
print(f"## Common Ground: {project}")
print(f"\n**Last Updated:** {d['last_updated']}")
print(f"**Last Validated:** {d.get('last_validated') or '(never)'}\n")
if not d["assumptions"]:
    print("No assumptions tracked yet. Run the common-ground skill to surface some.")
    sys.exit(0)
for t in TIERS:
    if want and want is not True and want != t:
        continue
    rows = [a for a in d["assumptions"] if a["tier"] == t]
    print(f"### {t} ({c[t]})")
    if not rows:
        print("  (none)")
    for i, a in enumerate(rows, 1):
        print(f"  {i}. {a['id']} {a['title']} — {a['assumption']} [{a['type']}]")
    print()
print("(Read-only view. Run the common-ground skill to modify.)")
PY
