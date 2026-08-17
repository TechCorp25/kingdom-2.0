#!/usr/bin/env bash
# common-ground.sh <init|add|tier|archive|validate|list|render|graph|path|summary> [--project P] [options]
#   Kingdom-local assumption ledger for the common-ground skill.
# Deterministic file I/O only — classification and interaction are the skill's job.
# State lives at .orchestrator/projects/state/{p}/patterns/common-ground/. ground.index.json
# is the source of truth; COMMON-GROUND.md is always regenerated from it, never hand-edited.
# --project is refused while a session is bound: sandbox-guard.py's Bash arm does NOT cover
# this tree (its regex consumes "projects/state" and yields "state"), so the binding is
# enforced here rather than relied upon from the guard.
set -euo pipefail
KINGDOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$KINGDOM"

USAGE="usage: common-ground.sh <init|add|tier|archive|validate|list|render|graph|path|summary> [--project P] [options]"

if [ $# -eq 0 ]; then echo "✗ no command — $USAGE" >&2; exit 2; fi
CMD="$1"; shift

case "$CMD" in
  init|add|tier|archive|validate|list|render|graph|path|summary) ;;
  *) echo "✗ bad command '$CMD' — $USAGE" >&2; exit 2;;
esac

PROJECT=""
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --project)
      if [ $# -lt 2 ] || [ -z "${2:-}" ]; then echo "✗ --project needs a value" >&2; exit 2; fi
      PROJECT="$2"; shift 2;;
    *) ARGS+=("$1"); shift;;
  esac
done

# Project identity comes from the kingdom registry + session binding — never from
# a git remote or pwd. This removes the upstream shell-outs entirely.
BOUND=$(python3 -c "import json;print(json.load(open('.orchestrator/runtime/current-session.json'))['project'])" 2>/dev/null || echo "")

if [ -n "$PROJECT" ] && [ -n "$BOUND" ] && [ "$PROJECT" != "$BOUND" ]; then
  echo "✗ session is bound to '$BOUND' — cross-project access to '$PROJECT' is not permitted" >&2
  echo "  (CLAUDE.md session sandbox). Drop --project, or start a session for '$PROJECT'." >&2
  exit 1
fi
[ -z "$PROJECT" ] && PROJECT="$BOUND"

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
import json, os, re, sys

cmd, project, index_p, ground_p, dirp, ts, ts_file, *rest = sys.argv[1:]

TIERS = ["ESTABLISHED", "WORKING", "OPEN"]
TYPES = ["stated", "inferred", "assumed", "uncertain"]
TIER_BLURB = {
    "ESTABLISHED": "High confidence assumptions. Treat as premises.",
    "WORKING": "Medium confidence. Use but flag if contradicted.",
    "OPEN": "Low confidence. Ask before assuming.",
}
ALLOWED = {
    "add": {"title", "type", "tier", "assumption", "source", "context", "reason"},
    "list": {"tier"},
    "graph": {"file", "standalone"},
    "init": set(), "validate": set(), "render": set(), "summary": set(),
    "tier": set(), "archive": set(),
}


def die(msg, code=2):
    print(f"✗ {msg}", file=sys.stderr)
    sys.exit(code)


def opts(argv, allowed):
    """--key value pairs into a dict; bare --flag becomes True. Unknown keys are fatal."""
    out, i = {}, 0
    while i < len(argv):
        a = argv[i]
        if not a.startswith("--"):
            die(f"unexpected argument '{a}'")
        k = a[2:]
        if k not in allowed:
            die(f"unknown option '--{k}' for {cmd} (allowed: {', '.join(sorted(allowed)) or 'none'})")
        if i + 1 < len(argv) and not argv[i + 1].startswith("--"):
            out[k], i = argv[i + 1], i + 2
        else:
            out[k], i = True, i + 1
    return out


def val(o, key):
    """Option value as a string, or None when absent/bare."""
    v = o.get(key)
    return None if v is None or v is True else v


def load():
    try:
        with open(index_p) as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        die(f"ground.index.json is not valid JSON ({e}). Repair the JSON by hand, "
            f"then run 'common-ground.sh render' to rebuild the markdown.", 1)
    except OSError as e:
        die(f"cannot read {index_p}: {e}", 1)


def save(d):
    d["last_updated"] = ts
    tmp = index_p + ".tmp"
    with open(tmp, "w") as f:
        json.dump(d, f, indent=2, ensure_ascii=False)
        f.write("\n")
    os.replace(tmp, index_p)


def cell(s):
    """Make a value safe inside a markdown table cell / bullet line."""
    return str(s).replace("|", "\\|").replace("\r", " ").replace("\n", " ")


def uniq(path):
    """First free filename — never clobber an existing archive."""
    if not os.path.exists(path):
        return path
    stem, ext = os.path.splitext(path)
    n = 2
    while os.path.exists(f"{stem}-{n}{ext}"):
        n += 1
    return f"{stem}-{n}{ext}"


def render(d):
    """COMMON-GROUND.md is generated from the index — never edited by hand."""
    L = [
        "# Project Common Ground",
        "",
        f"**Project:** {cell(d['project_name'])}",
        f"**Project ID:** {cell(d['project_id'])}",
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
                f"### {a['id']}: {cell(a['title'])}",
                "",
                f"- **Type:** {a['type']}",
                f"- **Assumption:** {cell(a['assumption'])}",
                f"- **Source:** {cell(a['source']) if a['source'] else '(none recorded)'}",
                f"- **Validated:** {a['validated'] or '(not validated)'}",
                f"- **Context:** {cell(a['context']) if a['context'] else '(any)'}",
                "",
            ]
        L += ["---", ""]

    archived = d.get("archived", [])
    if archived:
        L += ["## Archived", "",
              "Superseded — retained for the audit trail.", "",
              "| ID | Title | Last tier | Archived | Reason |",
              "|----|-------|-----------|----------|--------|"]
        for a in archived:
            L.append(f"| {a['id']} | {cell(a['title'])} | {a['tier']} | "
                     f"{a.get('archived_at', '')} | {cell(a.get('archived_reason') or '')} |")
        L += ["", "---", ""]

    L += ["## History", "", "| Date | Action | ID | Details |", "|------|--------|------|---------|"]
    hist = []
    for a in d["assumptions"] + archived:
        for h in a.get("history", []):
            frm, to = h.get("from_tier"), h.get("to_tier")
            move = f"{frm or '-'} → {to or '-'}"
            extra = f"; {cell(h['reason'])}" if h.get("reason") else ""
            hist.append((h["date"], h["action"], a["id"], f"{move}{extra}"))
    for row in sorted(hist):
        L.append(f"| {row[0]} | {row[1].capitalize()} | {row[2]} | {row[3]} |")
    L += ["", "---", ""]

    graph = d.get("reasoning_graph")
    if graph:
        L += [
            "## Reasoning Graph",
            "",
            f"Last generated: {graph['generated']}",
            f"Nodes: {graph.get('nodes', '?')} · Decision points: {graph.get('decisions', '?')} · "
            f"Open questions: {graph.get('uncertain', '?')}",
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
    opts(rest, ALLOWED["init"])
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
used_ids = {a["id"] for a in d["assumptions"]} | {a["id"] for a in d.get("archived", [])}

# ── add ─────────────────────────────────────────────────────────────────
if cmd == "add":
    o = opts(rest, ALLOWED["add"])
    for req in ("title", "type", "tier", "assumption"):
        if val(o, req) is None:
            die(f"add needs --{req} with a value")
    if o["type"] not in TYPES:
        die(f"bad --type '{o['type']}' ({'|'.join(TYPES)})")
    if o["tier"] not in TIERS:
        die(f"bad --tier '{o['tier']}' ({'|'.join(TIERS)})")
    n = d["next_id"]
    while f"A{n:03d}" in used_ids:      # never reuse, even after a hand repair
        n += 1
    aid = f"A{n:03d}"
    d["next_id"] = n + 1
    d["assumptions"].append({
        "id": aid,
        "title": o["title"],
        "type": o["type"],                       # immutable — audit trail
        "tier": o["tier"],
        "assumption": o["assumption"],
        "source": val(o, "source") or "",
        "validated": ts if o["tier"] == "ESTABLISHED" else "",
        "context": val(o, "context") or "",
        "created": ts,
        "history": [{"date": ts, "action": "created", "from_tier": None,
                     "to_tier": o["tier"], "reason": val(o, "reason")}],
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

# ── archive (Any → Archived) ────────────────────────────────────────────
if cmd == "archive":
    if len(rest) < 1:
        die("archive needs <ID> [reason]")
    aid = rest[0]
    reason = rest[1] if len(rest) > 1 else None
    a = next((x for x in d["assumptions"] if x["id"] == aid), None)
    if a is None:
        die(f"no such active assumption '{aid}'", 1)
    a["history"].append({"date": ts, "action": "archived", "from_tier": a["tier"],
                         "to_tier": None, "reason": reason})
    a["archived_at"] = ts
    a["archived_reason"] = reason
    d["assumptions"].remove(a)
    d.setdefault("archived", []).append(a)
    save(d)
    render(d)
    print(f"✓ {aid} archived (was {a['tier']}) — ID retired, never reused")
    sys.exit(0)

# ── validate ────────────────────────────────────────────────────────────
if cmd == "validate":
    opts(rest, ALLOWED["validate"])
    d["last_validated"] = ts        # upstream parity: stamp only, no history spam
    save(d)
    render(d)
    print(f"✓ {len(d['assumptions'])} assumptions revalidated at {ts}")
    sys.exit(0)

# ── render ──────────────────────────────────────────────────────────────
if cmd == "render":
    opts(rest, ALLOWED["render"])
    render(d)
    print(f"✓ {ground_p} regenerated from index")
    sys.exit(0)

# ── graph ───────────────────────────────────────────────────────────────
if cmd == "graph":
    o = opts(rest, ALLOWED["graph"])
    src = val(o, "file")
    if not src:
        die("graph needs --file <path-to-mermaid> [--standalone]")
    if not d["assumptions"]:
        die("no confirmed assumptions — surface some before graphing "
            "(upstream constraint: never graph without confirmed assumptions)", 1)
    if not os.path.exists(src):
        die(f"no such mermaid file '{src}'", 1)
    with open(src) as f:
        mermaid = f.read().strip()
    if not mermaid.startswith("flowchart"):
        die("mermaid must begin with 'flowchart' (see references/reasoning-graph.md)")
    if d.get("reasoning_graph"):
        prev = uniq(os.path.join(dirp, "archive", f"{ts_file}-graph-superseded.md"))
        with open(prev, "x") as f:
            f.write(f"# Superseded reasoning graph\n\nGenerated: {d['reasoning_graph']['generated']}\n"
                    f"Archived: {ts}\n\n```mermaid\n{d['reasoning_graph']['mermaid']}\n```\n")
    # Count declared nodes: an identifier immediately followed by a shape bracket.
    # Bracketed text inside edge labels ("[inferred]") has no leading identifier,
    # so it is not matched.
    body = "\n".join(ln for ln in mermaid.splitlines()[1:]
                     if ln.strip() and not ln.strip().startswith(("%%", "style ")))
    ids = set(re.findall(r"\b([A-Za-z][A-Za-z0-9_]*)[\[{(]", body))
    d["reasoning_graph"] = {
        "generated": ts,
        "mermaid": mermaid,
        "nodes": len(ids),
        "decisions": sum(1 for i in ids if i.startswith("D")),
        "uncertain": sum(1 for i in ids if i.startswith("U")),
    }
    save(d)
    render(d)
    g = d["reasoning_graph"]
    msg = (f"✓ reasoning graph embedded in {ground_p}\n"
           f"  nodes: {g['nodes']} · decision points: {g['decisions']} · open questions: {g['uncertain']}")
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
    opts(rest, ALLOWED["summary"])
    print(f"project: {project}")
    print(f"tracked: {len(d['assumptions'])}")
    for t in TIERS:
        print(f"{t}: {c[t]}")
    print(f"archived: {len(d.get('archived', []))}")
    print(f"last_validated: {d.get('last_validated') or '(never)'}")
    sys.exit(0)

o = opts(rest, ALLOWED["list"])
want = val(o, "tier")
if want and want not in TIERS:
    die(f"bad --tier '{want}' ({'|'.join(TIERS)})")
print(f"## Common Ground: {project}")
print(f"\n**Last Updated:** {d['last_updated']}")
print(f"**Last Validated:** {d.get('last_validated') or '(never)'}\n")
if not d["assumptions"]:
    print("No assumptions tracked yet. Run the common-ground skill to surface some.")
    sys.exit(0)
for t in TIERS:
    if want and want != t:
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
