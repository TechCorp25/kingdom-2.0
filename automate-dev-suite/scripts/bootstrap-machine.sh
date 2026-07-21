#!/usr/bin/env bash
# bootstrap-machine.sh — new-machine handover (DD-001).
# Run once after cloning the kingdom repo on a fresh machine:
#   re-clones every registered project from its own remote, re-creates the
#   state symlinks, installs boundary hooks, then runs a full sync + boundary check.
set -euo pipefail
KINGDOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$KINGDOM"

command -v git >/dev/null || { echo "git is required" >&2; exit 1; }
command -v gh  >/dev/null || { echo "gh CLI is required (gh auth login first)" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "gh is not authenticated — run: gh auth login" >&2; exit 1; }

mkdir -p projects .orchestrator/runtime

registry_rows() {
  python3 -c "
import json
for p in json.load(open('.orchestrator/registry/projects.json'))['projects']:
    print(f\"{p['name']}\t{p['remote']}\")"
}

while IFS=$'\t' read -r name remote; do
  echo "── $name ──"
  if [ ! -d "projects/$name/.git" ]; then
    git clone --quiet "$remote" "projects/$name"
    echo "  cloned $remote"
  else
    echo "  already cloned"
  fi
  # Re-create state symlinks (state itself arrived with the kingdom clone)
  [ -L "projects/$name/.orchestrator" ] || ln -s "../../.orchestrator/projects/state/$name" "projects/$name/.orchestrator"
  [ -L "projects/$name/.claude" ]      || ln -s "../../.orchestrator/projects/state/$name/claude" "projects/$name/.claude"
  # Install the boundary pre-commit hook
  install -m 0755 automate-dev-suite/scripts/git-hooks/project-pre-commit "projects/$name/.git/hooks/pre-commit"
  echo "  symlinks + boundary hook in place"
done < <(registry_rows)

echo
automate-dev-suite/scripts/boundary-verify.sh
echo
echo "Machine bootstrap complete. Start Claude Code from $KINGDOM."
