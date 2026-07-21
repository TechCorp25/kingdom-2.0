#!/usr/bin/env bash
# SessionStart — inject the operating contract + live bootstrap status.
# Terse by design: detail lives behind pointers (DD-004). stdout → context.
set -u
KINGDOM="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$KINGDOM" || exit 0

# Session source (startup|resume|clear|compact): clear stale project binding
# except when resuming or recovering from a compact.
SOURCE=$(python3 -c "import json,sys;print(json.load(sys.stdin).get('source','startup'))" 2>/dev/null || echo startup)
if [ "$SOURCE" != "resume" ] && [ "$SOURCE" != "compact" ]; then
  rm -f .orchestrator/runtime/current-session.json
fi

echo "KINGDOM v2 OPERATING CONTRACT — authoritative copy: CLAUDE.md (read pointers, not dumps)"
echo "1. Token-efficient by default; bulk material goes to task-tier files, referenced by path."
echo "2. MANDATORY lifecycle: kingdom bootstrap -> numbered project selection"
echo "   (scripts/select-project.sh) -> project bootstrap -> session-goals file."
echo "   After selection the session is hook-sandboxed to that project."
echo "3. Gates govern all work (automate-dev-suite/gates/): HARD = owner, SELF-CHECK = Fable"
echo "   reviewer with PR opened first (PR-readiness only), SUCCESS/GO = objective checklist."
echo "   Record every decision. ALL merges to main are owner-only — never merge."
echo "4. Promotion: memory-promote.sh task on task completion; session at close/pre-compact."
echo "5. All work on a fresh per-session branch -> PR. Owner reviews + merges main personally;"
echo "   their report-back triggers session close. Secrets never in either repo layer."
echo ""

if [ "$SOURCE" = "compact" ]; then
  last_snap=$(ls -1dt .orchestrator/runtime/compact-snapshots/* 2>/dev/null | head -1 || true)
  echo "POST-COMPACT RECOVERY: context was compacted. Session/task memory snapshot: ${last_snap:-none}."
  echo "Re-read SESSION.md and TASK.md for the bound project before continuing."
  echo ""
fi

echo "── Bootstrap status ──"
# Kingdom drift (degrade gracefully offline)
if timeout 8 git fetch -q origin main 2>/dev/null; then
  counts=$(git rev-list --left-right --count origin/main...main 2>/dev/null || echo "? ?")
  set -- $counts; behind=${1:-?}; ahead=${2:-?}
  echo "kingdom main: $ahead ahead / $behind behind origin ($(git branch --show-current) checked out)"
else
  echo "kingdom drift check: OFFLINE — run scripts/sync-check.sh when network returns"
fi

if [ -s .orchestrator/reports/todos/NEXT-SESSION.md ]; then
  echo "── Carried-over todos (.orchestrator/reports/todos/NEXT-SESSION.md) ──"
  head -20 .orchestrator/reports/todos/NEXT-SESSION.md
fi

echo "── Registered projects ──"
python3 -c "
import json
ps = json.load(open('.orchestrator/registry/projects.json'))['projects']
if not ps:
    print('(none registered yet — new-project.sh / adopt-project.sh to add one)')
for i, p in enumerate(ps, 1):
    print(f\"{i}. {p['name']} [{p['status']}] — {p.get('description','')[:60]}\")" 2>/dev/null || echo "(registry unreadable)"
echo ""
if [ "$SOURCE" = "resume" ] || [ "$SOURCE" = "compact" ]; then
  bound=$(python3 -c "import json;print(json.load(open('.orchestrator/runtime/current-session.json'))['project'])" 2>/dev/null || true)
  [ -n "$bound" ] && echo "Session already bound to project: $bound (sandbox active)."
fi
echo "NEXT: finish per-project sync checks (scripts/sync-check.sh), then ask the owner which"
echo "project this session is for as a NUMBERED question and run scripts/select-project.sh <n>."
exit 0
