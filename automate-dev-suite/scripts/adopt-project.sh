#!/usr/bin/env bash
# adopt-project.sh <name> <git-url> — bring a project with an EXISTING remote
# under kingdom governance (used for pin-force): clone, wire state + boundary,
# register. Does NOT create a remote and does NOT rewrite project history.
set -euo pipefail
KINGDOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$KINGDOM"

NAME="${1:?usage: adopt-project.sh <name> <git-url>}"
URL="${2:?usage: adopt-project.sh <name> <git-url>}"
[[ "$NAME" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "✗ name must match ^[a-z0-9][a-z0-9-]*$" >&2; exit 1; }
[ -e "projects/$NAME" ] && { echo "✗ projects/$NAME already exists" >&2; exit 1; }

TS="$(date +%Y-%m-%d)"
STATE=".orchestrator/projects/state/$NAME"

git clone --quiet "$URL" "projects/$NAME"

# Refuse to shadow real in-repo dirs with symlinks
for clash in .orchestrator .claude; do
  if [ -e "projects/$NAME/$clash" ]; then
    echo "✗ adopted repo already contains $clash/ — resolve before wiring (would shadow it)" >&2
    exit 1
  fi
done

mkdir -p "$STATE"/{memory/project/session/task,reports/{sessions,tasks,gates},patterns,claude} \
         ".orchestrator/projects/tasks/$NAME/session-goals"
sed -e "s/{project}/$NAME/g" automate-dev-suite/templates/PROJECT.template.md > "$STATE/memory/project/PROJECT.md"
sed -e "s/{project}/$NAME/g" -e "s/{started}/$TS/" -e "s/{goals-file}/(none yet)/" \
    automate-dev-suite/templates/SESSION.template.md > "$STATE/memory/project/session/SESSION.md"
sed -e "s/{title}/first task/" -e "s/{started}/$TS/" \
    automate-dev-suite/templates/TASK.template.md > "$STATE/memory/project/session/task/TASK.md"
printf '{\n  "permissions": { "deny": ["Read(**/.env)", "Read(**/.env.*)", "Read(**/*.pem)", "Read(**/*.key)"] }\n}\n' \
    > "$STATE/claude/settings.json"

ln -s "../../.orchestrator/projects/state/$NAME" "projects/$NAME/.orchestrator"
ln -s "../../.orchestrator/projects/state/$NAME/claude" "projects/$NAME/.claude"
install -m 0755 automate-dev-suite/scripts/git-hooks/project-pre-commit "projects/$NAME/.git/hooks/pre-commit"

# Boundary block in the project .gitignore (append-only; landing it upstream
# is a normal project-repo change via branch -> PR)
if ! grep -q '^\.orchestrator$' "projects/$NAME/.gitignore" 2>/dev/null; then
  { echo ""; cat automate-dev-suite/templates/project-gitignore.template; } >> "projects/$NAME/.gitignore"
  echo "· appended kingdom boundary block to projects/$NAME/.gitignore — commit it via a project PR"
fi

python3 - "$NAME" "$URL" "$TS" <<'PY'
import json, sys
name, url, ts = sys.argv[1:4]
reg = json.load(open('.orchestrator/registry/projects.json'))
reg['projects'].append({
    "name": name,
    "remote": url,
    "created": ts,
    "status": "active",
    "description": f"adopted from {url}",
})
reg['updated'] = ts
json.dump(reg, open('.orchestrator/registry/projects.json', 'w'), indent=2)
PY

echo ""
automate-dev-suite/scripts/boundary-verify.sh "$NAME"
echo ""
echo "✓ $NAME adopted from $URL and registered."
echo "  Seed $STATE/memory/project/PROJECT.md from the project's own docs, then commit kingdom changes."
