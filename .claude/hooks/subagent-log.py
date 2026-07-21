#!/usr/bin/env python3
"""SubagentStop — append a record of every subagent completion to the gate
audit backbone (Fable self-check reviews are subagents; their runs must be
traceable). Never blocks."""
import json
import os
import sys
import time

kingdom = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

rec = {
    "ts": time.strftime("%Y-%m-%dT%H:%M:%S"),
    "agent_id": data.get("agent_id") or data.get("session_id", ""),
    "agent_type": data.get("agent_type") or data.get("subagent_type", ""),
    "transcript": data.get("agent_transcript_path") or data.get("transcript_path", ""),
}
log = os.path.join(kingdom, ".orchestrator", "reports", "gates", "subagents.jsonl")
try:
    os.makedirs(os.path.dirname(log), exist_ok=True)
    with open(log, "a") as f:
        f.write(json.dumps(rec) + "\n")
except Exception:
    pass
sys.exit(0)
