#!/usr/bin/env bash
# SessionEnd — record the session close; flag un-promoted work for the next
# bootstrap. Cannot block; must never fail.
set -u
KINGDOM="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$KINGDOM" || exit 0
TS="$(date +%Y-%m-%dT%H-%M-%S)"

reason=$(python3 -c "import json,sys;print(json.load(sys.stdin).get('reason',''))" 2>/dev/null || echo "")
proj=$(python3 -c "import json;print(json.load(open('.orchestrator/runtime/current-session.json'))['project'])" 2>/dev/null || true)

mkdir -p .orchestrator/reports/sessions .orchestrator/reports/todos
printf '{"ts":"%s","project":"%s","reason":"%s"}\n' "$TS" "${proj:-kingdom}" "$reason" >> .orchestrator/reports/sessions/log.jsonl

# If a project was bound and its SESSION.md was never promoted this session,
# leave a remediation marker for the next kingdom bootstrap.
if [ -n "$proj" ]; then
  sess=".orchestrator/projects/state/$proj/memory/project/session/SESSION.md"
  last_archive=$(ls -1t ".orchestrator/projects/state/$proj/reports/sessions/" 2>/dev/null | head -1 || true)
  if [ -f "$sess" ] && [ "$sess" -nt ".orchestrator/projects/state/$proj/reports/sessions/${last_archive:-__none__}" ] 2>/dev/null || { [ -f "$sess" ] && [ -z "$last_archive" ]; }; then
    {
      echo "- [ ] $TS: session for '$proj' ended (${reason:-unknown}) with un-promoted SESSION.md —"
      echo "      run session remediation in project bootstrap (memory-promote.sh session --project $proj)"
    } >> .orchestrator/reports/todos/NEXT-SESSION.md
  fi
fi
exit 0
