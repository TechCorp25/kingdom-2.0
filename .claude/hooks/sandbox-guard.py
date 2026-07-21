#!/usr/bin/env python3
"""PreToolUse guard — enforces (1) old-kingdom read-only, (2) session project
sandbox, (3) select-before-write. Exit 2 = deny (stderr goes to the model).
Tier-3 behavior: scope comes from .orchestrator/runtime/current-session.json."""
import json
import os
import re
import sys

kingdom = os.path.realpath(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd())
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)  # unparseable input: never wedge the session

tool = data.get("tool_name", "")
ti = data.get("tool_input") or {}
old_kingdom = os.path.join(os.path.expanduser("~"), "kingdom")
proj_root = os.path.join(kingdom, "projects")
state_root = os.path.join(kingdom, ".orchestrator", "projects", "state")


def deny(msg):
    print(msg, file=sys.stderr)
    sys.exit(2)


def bound_project():
    try:
        with open(os.path.join(kingdom, ".orchestrator", "runtime", "current-session.json")) as f:
            return json.load(f)["project"]
    except Exception:
        return None


def project_of(path, root):
    """Name of the project subtree of `root` that `path` falls inside, else None."""
    rp = os.path.realpath(path)
    if rp.startswith(root + os.sep):
        return rp[len(root) + 1:].split(os.sep, 1)[0]
    return None


proj = bound_project()
WRITE_TOOLS = {"Write", "Edit", "MultiEdit", "NotebookEdit"}
READ_TOOLS = {"Read", "Grep", "Glob"}

if tool in WRITE_TOOLS | READ_TOOLS:
    path = ti.get("file_path") or ti.get("notebook_path") or ti.get("path") or ""
    if not path:
        sys.exit(0)
    rp = os.path.realpath(path)

    if tool in WRITE_TOOLS and (rp == old_kingdom or rp.startswith(old_kingdom + os.sep)):
        deny("BLOCKED: ~/kingdom is the retired v1 environment — read-only reference. "
             "Work happens in ~/kingdom-2.0 (CLAUDE.md).")

    q = project_of(rp, proj_root) or project_of(rp, state_root)
    if q:
        if proj is None and tool in WRITE_TOOLS and project_of(rp, proj_root):
            deny("BLOCKED: no project selected. Run automate-dev-suite/scripts/select-project.sh <n> "
                 "first (session lifecycle step 2).")
        if proj is not None and q != proj:
            deny(f'BLOCKED: session is sandboxed to project "{proj}" — cross-project access to '
                 f'"{q}" is not permitted (CLAUDE.md session lifecycle).')

elif tool == "Bash":
    cmd = ti.get("command", "")
    mutating = (
        re.search(r"(^|[\s;&|(])(rm|mv|cp|tee|truncate|mkdir|touch|ln|chmod|chown|sed\s+-i"
                  r"|git\s+(commit|push|reset|checkout|clean|rebase|merge))\b", cmd)
        or re.search(r"[^<>]>{1,2}[^&]", cmd)
    )
    if mutating and re.search(
        re.escape(old_kingdom) + r"/|(^|[\s'\"=])~/kingdom/|\$HOME/kingdom/", cmd
    ):
        deny("BLOCKED: command mutates ~/kingdom (retired v1, read-only reference). "
             "Work happens in ~/kingdom-2.0.")
    if proj is not None:
        for m in re.finditer(r"(?:projects|state)/([A-Za-z0-9_][A-Za-z0-9_-]*)(?=/|\s|$|['\"])", cmd):
            q = m.group(1)
            if q != proj and (os.path.isdir(os.path.join(proj_root, q))
                              or os.path.isdir(os.path.join(state_root, q))):
                deny(f'BLOCKED: session is sandboxed to project "{proj}" — command references '
                     f'project "{q}".')

sys.exit(0)
