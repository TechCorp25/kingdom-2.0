#!/usr/bin/env bash
# PreCompact — lossless protection of context integrity around compaction:
# snapshot session+task memory so nothing depends on what compaction keeps.
# (The post-compact SessionStart injection points back at this snapshot.)
set -u
KINGDOM="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$KINGDOM" || exit 0
TS="$(date +%Y-%m-%dT%H-%M-%S)"
SNAP=".orchestrator/runtime/compact-snapshots/$TS"

proj=$(python3 -c "import json;print(json.load(open('.orchestrator/runtime/current-session.json'))['project'])" 2>/dev/null || true)
mkdir -p "$SNAP"
if [ -n "$proj" ]; then
  sess=".orchestrator/projects/state/$proj/memory/project/session"
  [ -d "$sess" ] && cp -r "$sess" "$SNAP/session"
  echo "$proj" > "$SNAP/project"
fi
cp -f .orchestrator/runtime/kingdom-activity.jsonl "$SNAP/" 2>/dev/null || true
# Keep only the five most recent snapshots (machine-local, never synced)
ls -1dt .orchestrator/runtime/compact-snapshots/* 2>/dev/null | tail -n +6 | xargs -r rm -rf
exit 0
