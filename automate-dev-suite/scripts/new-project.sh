#!/usr/bin/env bash
# new-project.sh <name> ["description"] — standing new-project workflow:
# scaffold state tiers, wire symlinks + boundary, init the project repo,
# create its PRIVATE remote via gh (suite-owned repo creation), register it.
set -euo pipefail
KINGDOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$KINGDOM"

NAME="${1:?usage: new-project.sh <name> [description]}"
DESC="${2:-}"
OWNER="TechCorp25"

[[ "$NAME" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "✗ name must match ^[a-z0-9][a-z0-9-]*$" >&2; exit 1; }
[ -e "projects/$NAME" ] && { echo "✗ projects/$NAME already exists" >&2; exit 1; }
gh repo view "$OWNER/$NAME" >/dev/null 2>&1 && { echo "✗ $OWNER/$NAME already exists on GitHub" >&2; exit 1; }

TS="$(date +%Y-%m-%d)"
STATE=".orchestrator/projects/state/$NAME"

# 1. Kingdom-side state tiers (DD-001/DD-002)
mkdir -p "$STATE"/{memory/project/session/task,reports/{sessions,tasks,gates},patterns,claude} \
         ".orchestrator/projects/tasks/$NAME/session-goals"
sed -e "s/{project}/$NAME/g" automate-dev-suite/templates/PROJECT.template.md > "$STATE/memory/project/PROJECT.md"
sed -e "s/{project}/$NAME/g" -e "s/{started}/$TS/" -e "s/{goals-file}/(none yet)/" \
    automate-dev-suite/templates/SESSION.template.md > "$STATE/memory/project/session/SESSION.md"
sed -e "s/{title}/first task/" -e "s/{started}/$TS/" \
    automate-dev-suite/templates/TASK.template.md > "$STATE/memory/project/session/task/TASK.md"
printf '{\n  "permissions": { "deny": ["Read(**/.env)", "Read(**/.env.*)", "Read(**/*.pem)", "Read(**/*.key)"] }\n}\n' \
    > "$STATE/claude/settings.json"

# 2. Project repo + boundary wiring
mkdir "projects/$NAME"
git -C "projects/$NAME" init -qb main
ln -s "../../.orchestrator/projects/state/$NAME" "projects/$NAME/.orchestrator"
ln -s "../../.orchestrator/projects/state/$NAME/claude" "projects/$NAME/.claude"
cp automate-dev-suite/templates/project-gitignore.template "projects/$NAME/.gitignore"
printf '# %s\n\n%s\n\nDeveloped inside Kingdom v2 — state and memory sync via the kingdom repo, never this one.\n' \
    "$NAME" "${DESC:-New Kingdom project.}" > "projects/$NAME/README.md"
git -C "projects/$NAME" add -A
git -C "projects/$NAME" commit -qm "chore: bootstrap $NAME (Kingdom v2 project scaffold)"
install -m 0755 automate-dev-suite/scripts/git-hooks/project-pre-commit "projects/$NAME/.git/hooks/pre-commit"

# 3. Private remote (suite-owned creation)
gh repo create "$OWNER/$NAME" --private --source "projects/$NAME" --push \
    ${DESC:+--description "$DESC"}

# 4. Register
python3 - "$NAME" "$DESC" "$TS" "$OWNER" <<'PY'
import json, sys
name, desc, ts, owner = sys.argv[1:5]
reg = json.load(open('.orchestrator/registry/projects.json'))
reg['projects'].append({
    "name": name,
    "remote": f"https://github.com/{owner}/{name}.git",
    "created": ts,
    "status": "active",
    "description": desc,
})
reg['updated'] = ts
json.dump(reg, open('.orchestrator/registry/projects.json', 'w'), indent=2)
PY

echo ""
automate-dev-suite/scripts/boundary-verify.sh "$NAME"
echo ""
echo "✓ $NAME created, remote https://github.com/$OWNER/$NAME (private), registered."
echo "  Kingdom repo now has unstaged registry/state changes — commit them on this session's kingdom branch."
