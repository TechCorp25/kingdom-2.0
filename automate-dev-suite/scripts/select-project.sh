#!/usr/bin/env bash
# select-project.sh <number|name> — bind this session to one registered project
# (session lifecycle step 2). After this, the PreToolUse guard sandboxes the
# session to that project until the session ends.
set -euo pipefail
KINGDOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$KINGDOM"

sel="${1:?usage: select-project.sh <number|name>  (numbers as listed at session start)}"

name=$(python3 - "$sel" <<'PY'
import json, sys
sel = sys.argv[1]
ps = json.load(open('.orchestrator/registry/projects.json'))['projects']
if not ps:
    sys.exit("registry is empty — create a project first (new-project.sh / adopt-project.sh)")
if sel.isdigit():
    i = int(sel)
    if not 1 <= i <= len(ps):
        sys.exit(f"number {i} out of range 1..{len(ps)}")
    print(ps[i - 1]['name'])
else:
    if sel not in [p['name'] for p in ps]:
        sys.exit(f"'{sel}' is not a registered project")
    print(sel)
PY
)

[ -d "projects/$name" ] || { echo "✗ projects/$name missing on disk — run bootstrap-machine.sh" >&2; exit 1; }

mkdir -p .orchestrator/runtime
python3 - "$name" <<'PY'
import json, sys, time
json.dump(
    {"project": sys.argv[1], "started": time.strftime("%Y-%m-%dT%H:%M:%S")},
    open('.orchestrator/runtime/current-session.json', 'w'),
)
PY

echo "✓ session bound to project: $name (sandbox active — cross-project access is now blocked)"
echo ""
echo "PROJECT BOOTSTRAP (lifecycle step 3) — do now, in order:"
echo "  1. Read .orchestrator/projects/state/$name/memory/project/PROJECT.md and last-session.md"
echo "  2. Check .orchestrator/reports/todos/NEXT-SESSION.md for '$name' remediation markers"
echo "  3. automate-dev-suite/scripts/sync-check.sh $name   # bring local/remote current if behind"
echo "  4. Create the session branch in projects/$name (git checkout -b session/$(date +%Y-%m-%d)-<slug>)"
echo "  5. automate-dev-suite/scripts/session-goals.sh      # lifecycle step 4"
