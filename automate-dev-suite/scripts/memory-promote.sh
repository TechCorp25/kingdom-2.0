#!/usr/bin/env bash
# memory-promote.sh {task|session} [--project <name>]
# Mechanical, lossless half of the DD-002 promotion flow. Judgement work
# (distilling durable facts) stays with the assistant — this script archives,
# appends, resets, and prints exactly what remains to be done.
set -euo pipefail
KINGDOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$KINGDOM"

MODE="${1:-}"; shift || true
PROJECT=""
[ "${1:-}" = "--project" ] && PROJECT="${2:-}"
if [ -z "$PROJECT" ]; then
  PROJECT=$(python3 -c "import json;print(json.load(open('.orchestrator/runtime/current-session.json'))['project'])" 2>/dev/null || true)
fi
[ -z "$PROJECT" ] && { echo "No project selected (run select-project.sh) and no --project given" >&2; exit 1; }

STATE=".orchestrator/projects/state/$PROJECT"
SESSION_DIR="$STATE/memory/project/session"
TASK_DIR="$SESSION_DIR/task"
TS="$(date +%Y-%m-%dT%H-%M)"

case "$MODE" in
  task)
    [ -f "$TASK_DIR/TASK.md" ] || { echo "$TASK_DIR/TASK.md not found" >&2; exit 1; }
    # Outcome section must have real content (HTML comments stripped, may span lines)
    outcome=$(python3 - "$TASK_DIR/TASK.md" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
m = re.search(r'^## Outcome\s*$(.*)\Z', text, re.M | re.S)
body = m.group(1) if m else ''
body = re.sub(r'<!--.*?-->', '', body, flags=re.S).strip()
print(body)
PY
)
    [ -z "$outcome" ] && { echo "✗ TASK.md has an empty ## Outcome — write the outcome before promoting" >&2; exit 1; }

    {
      echo ""
      echo "### $TS — $(head -1 "$TASK_DIR/TASK.md" | sed 's/^# *//')"
      echo "$outcome"
    } >> "$SESSION_DIR/SESSION.md"

    archive="$STATE/reports/tasks/$TS"
    mkdir -p "$archive"
    find "$TASK_DIR" -mindepth 1 -maxdepth 1 -exec mv {} "$archive/" \;
    sed -e "s/{title}/next task/" -e "s/{started}/$TS/" \
      automate-dev-suite/templates/TASK.template.md > "$TASK_DIR/TASK.md"
    echo "✓ task promoted → SESSION.md · archived → $archive · fresh TASK.md ready"
    ;;
  session)
    [ -f "$SESSION_DIR/SESSION.md" ] || { echo "$SESSION_DIR/SESSION.md not found" >&2; exit 1; }
    mkdir -p "$STATE/reports/sessions"
    archive="$STATE/reports/sessions/$TS-session.md"
    cp "$SESSION_DIR/SESSION.md" "$archive"
    {
      echo "# Last session — $PROJECT"
      echo ""
      echo "- Ended: $TS"
      echo "- Full record: \`reports/sessions/$TS-session.md\`"
      echo "- Working branch: $(git -C "projects/$PROJECT" branch --show-current 2>/dev/null || echo 'n/a')"
    } > "$STATE/memory/project/last-session.md"
    echo "✓ session archived → $archive · last-session.md updated"
    echo ""
    echo "REMAINING (assistant judgement — do these now):"
    echo "  1. Distil durable facts from the archived session into $STATE/memory/project/PROJECT.md"
    echo "  2. Write carried-over todos to .orchestrator/reports/todos/NEXT-SESSION.md"
    echo "  3. Reset SESSION.md from the template for the next session (or leave if session continues)"
    echo "  4. Commit kingdom repo (state + reports ride kingdom PRs) and run sync-check.sh"
    ;;
  *)
    echo "usage: memory-promote.sh {task|session} [--project <name>]" >&2; exit 2;;
esac
