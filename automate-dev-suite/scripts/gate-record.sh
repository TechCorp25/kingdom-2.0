#!/usr/bin/env bash
# gate-record.sh <hard|self-check|go> <workflow> "<action>" <decision> <approver> ["notes"]
#   decision: approved|rejected|pending|go|no-go
# Appends to the kingdom gate audit trail; mirrors to the bound project's gate
# reports when a session is bound. The audit trail is append-only.
set -euo pipefail
KINGDOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$KINGDOM"

CLASS="${1:?class: hard|self-check|go}"
WORKFLOW="${2:?workflow name}"
ACTION="${3:?action description}"
DECISION="${4:?decision: approved|rejected|pending|go|no-go}"
APPROVER="${5:?approver: owner|fable-reviewer|self}"
NOTES="${6:-}"

case "$CLASS" in hard|self-check|go) ;; *) echo "✗ bad class '$CLASS'" >&2; exit 2;; esac
case "$DECISION" in approved|rejected|pending|go|no-go) ;; *) echo "✗ bad decision '$DECISION'" >&2; exit 2;; esac

TS="$(date +%Y-%m-%dT%H:%M:%S)"
LOG=".orchestrator/reports/gates/gates-$(date +%Y-%m).jsonl"
mkdir -p "$(dirname "$LOG")"

proj=$(python3 -c "import json;print(json.load(open('.orchestrator/runtime/current-session.json'))['project'])" 2>/dev/null || echo "")

rec=$(python3 - "$TS" "$CLASS" "$WORKFLOW" "$ACTION" "$DECISION" "$APPROVER" "$NOTES" "$proj" <<'PY'
import json, sys
ts, cls, wf, action, decision, approver, notes, proj = sys.argv[1:9]
print(json.dumps({"ts": ts, "class": cls, "workflow": wf, "action": action,
                  "decision": decision, "approver": approver, "notes": notes,
                  "project": proj or "kingdom"}))
PY
)
echo "$rec" >> "$LOG"
if [ -n "$proj" ] && [ -d ".orchestrator/projects/state/$proj/reports/gates" ]; then
  echo "$rec" >> ".orchestrator/projects/state/$proj/reports/gates/gates-$(date +%Y-%m).jsonl"
fi
echo "✓ gate recorded: [$CLASS/$DECISION] $WORKFLOW — $ACTION (approver: $APPROVER)"
