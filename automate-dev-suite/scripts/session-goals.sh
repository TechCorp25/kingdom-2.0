#!/usr/bin/env bash
# session-goals.sh [--create <slug>] [project] — session lifecycle step 4.
# Finds today's LATEST DateTime-{session-plan}.md for the bound project, or
# (with --create, after the owner has given goals) seeds one from the template.
set -euo pipefail
KINGDOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$KINGDOM"

CREATE=""; SLUG=""
if [ "${1:-}" = "--create" ]; then CREATE=1; SLUG="${2:?--create needs a slug}"; shift 2; fi
PROJECT="${1:-}"
if [ -z "$PROJECT" ]; then
  PROJECT=$(python3 -c "import json;print(json.load(open('.orchestrator/runtime/current-session.json'))['project'])" 2>/dev/null || true)
fi
[ -z "$PROJECT" ] && { echo "no project bound (select-project.sh first) and none given" >&2; exit 1; }

DIR=".orchestrator/projects/tasks/$PROJECT/session-goals"
mkdir -p "$DIR"
TODAY="$(date +%Y-%m-%d)"

if [ -n "$CREATE" ]; then
  TS="$(date +%Y-%m-%dT%H-%M)"
  FILE="$DIR/$TS-$SLUG.md"
  sed -e "s/{project}/$PROJECT/g" -e "s/{date-time}/$TS/" \
      automate-dev-suite/templates/session-goals.template.md > "$FILE"
  echo "✓ created $FILE — fill in the owner's goals, criteria, constraints, gate notes now"
  exit 0
fi

latest=$(ls -1 "$DIR/$TODAY"T*.md 2>/dev/null | sort | tail -1 || true)
if [ -n "$latest" ]; then
  echo "✓ today's session plan (latest): $latest"
  echo "— read it and mirror its goals into SESSION.md"
else
  echo "· no session plan for today in $DIR"
  echo "  ASK THE OWNER for this session's instructions/goals, then run:"
  echo "  automate-dev-suite/scripts/session-goals.sh --create <slug> $PROJECT"
fi
