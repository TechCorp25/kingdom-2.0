#!/usr/bin/env python3
"""PreToolUse guard — the gate framework may not modify itself (v1
block-global-knowledge pattern, ported 2026-07-21). Blocks writes to
automate-dev-suite/gates/** except gates/_proposals/, from file tools and
mutating Bash. Owner promotes a proposal by hand (their own terminal):
    git mv automate-dev-suite/gates/_proposals/<ts>-<name>.md automate-dev-suite/gates/<name>.md
Exit 2 = deny (stderr goes to the model). The Bash arm is heuristic —
the honour rule in gates.md is the backstop, as in v1."""
import json
import os
import re
import sys

kingdom = os.path.realpath(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd())
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool = data.get("tool_name", "")
ti = data.get("tool_input") or {}
gates_root = os.path.join(kingdom, "automate-dev-suite", "gates")
proposals = os.path.join(gates_root, "_proposals")


def deny(msg):
    print(msg, file=sys.stderr)
    sys.exit(2)


def in_gates_not_proposals(path):
    rp = os.path.realpath(path)
    return (rp == gates_root or rp.startswith(gates_root + os.sep)) and not (
        rp.startswith(proposals + os.sep)
    )


DENY_MSG = (
    "BLOCKED: automate-dev-suite/gates/** is owner-gated — the gate framework "
    "cannot modify itself. Write the proposed change to "
    "automate-dev-suite/gates/_proposals/<ISO8601>-<target-name>.md instead; "
    "the owner promotes it by hand (that git mv IS the approval). See gates.md."
)

if tool in {"Write", "Edit", "MultiEdit", "NotebookEdit"}:
    path = ti.get("file_path") or ti.get("notebook_path") or ""
    if path and in_gates_not_proposals(path):
        deny(DENY_MSG)

elif tool == "Bash":
    cmd = ti.get("command", "")
    # Any gates/ reference outside _proposals/ ...
    refs = [
        m.group(0)
        for m in re.finditer(r"[^\s'\";|&]*automate-dev-suite/gates/[^\s'\";|&]*", cmd)
        if "/_proposals/" not in m.group(0)
    ]
    if refs:
        # ... combined with a mutation form (v1 block-global-bash catalogue).
        mutating = (
            re.search(
                r"(^|[\s;&|(])(rm|mv|cp|ln|dd|tee|truncate|install|rsync|mkdir|touch"
                r"|chmod|chown|sed\s+-i|git\s+(mv|rm|restore|checkout|clean))\b",
                cmd,
            )
            or re.search(r"[^<>]>{1,2}[^&]", cmd)
            or re.search(r"open\s*\([^)]*['\"](w|a)", cmd)
        )
        if mutating:
            deny(DENY_MSG)

sys.exit(0)
