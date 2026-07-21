#!/usr/bin/env bash
# sync-check.sh [project] — remote↔local drift report for the kingdom repo and
# one/all registered projects. Report-only (bringing things current is workflow
# judgement). Also records the result for the reporting backbone.
set -uo pipefail
KINGDOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$KINGDOM"
OUT=".orchestrator/reports/sync/last-check.txt"
mkdir -p "$(dirname "$OUT")"

check_repo() {  # <label> <dir>
  local label="$1" dir="$2"
  if [ ! -d "$dir/.git" ] && [ ! -f "$dir/.git" ]; then
    echo "✗ $label: not a git repo"; return 1
  fi
  local branch dirty counts behind ahead default
  branch=$(git -C "$dir" branch --show-current 2>/dev/null || echo '?')
  dirty=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l)
  if ! timeout 10 git -C "$dir" fetch -q origin 2>/dev/null; then
    echo "? $label: offline (fetch failed) · branch=$branch · dirty=$dirty"; return 0
  fi
  default=$(git -C "$dir" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||')
  default=${default:-main}
  counts=$(git -C "$dir" rev-list --left-right --count "origin/$default...$default" 2>/dev/null || echo "? ?")
  set -- $counts; behind=${1:-?}; ahead=${2:-?}
  local flag="✓"
  { [ "$ahead" != "0" ] || [ "$behind" != "0" ] || [ "$dirty" != "0" ]; } && flag="!"
  echo "$flag $label: $default ahead=$ahead behind=$behind · checked-out=$branch · dirty-files=$dirty"
}

{
  echo "sync-check $(date +%Y-%m-%dT%H:%M:%S)"
  check_repo "kingdom" "."
  if [ $# -ge 1 ]; then
    check_repo "$1" "projects/$1"
  else
    while IFS= read -r p; do
      check_repo "$p" "projects/$p"
    done < <(python3 -c "import json;[print(p['name']) for p in json.load(open('.orchestrator/registry/projects.json'))['projects']]" 2>/dev/null)
  fi
} | tee "$OUT"
