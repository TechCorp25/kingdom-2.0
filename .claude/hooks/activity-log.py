#!/usr/bin/env python3
"""PostToolUse — append one JSONL record per mutating tool call to the task-tier
activity log (tier 4's automatic, zero-context-cost record). Never blocks."""
import json
import os
import sys
import time

kingdom = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

ti = data.get("tool_input") or {}
target = ti.get("file_path") or ti.get("notebook_path") or (ti.get("command", "")[:200] or None)
rec = {
    "ts": time.strftime("%Y-%m-%dT%H:%M:%S"),
    "tool": data.get("tool_name", ""),
    "target": target,
}

try:
    with open(os.path.join(kingdom, ".orchestrator", "runtime", "current-session.json")) as f:
        proj = json.load(f)["project"]
    log = os.path.join(kingdom, ".orchestrator", "projects", "state", proj,
                       "memory", "project", "session", "task", "activity.jsonl")
except Exception:
    log = os.path.join(kingdom, ".orchestrator", "runtime", "kingdom-activity.jsonl")

try:
    os.makedirs(os.path.dirname(log), exist_ok=True)
    with open(log, "a") as f:
        f.write(json.dumps(rec) + "\n")
except Exception:
    pass
sys.exit(0)
