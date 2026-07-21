#!/usr/bin/env bash
# boundary-verify.sh [project] — audit the two-layer git boundary (DD-001).
# Checks, for one project or all registered projects:
#   1. kingdom repo tracks nothing under projects/
#   2. project repo tracks no state paths (.orchestrator, .claude, memory, env/keys)
#   3. state symlinks exist and resolve into .orchestrator/projects/state/{p}
#   4. project pre-commit boundary hook is installed
# Exit 0 = clean; exit 1 = violations (printed).
set -euo pipefail
KINGDOM="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$KINGDOM"
fail=0
say() { printf '%s\n' "$*"; }

# 1. Kingdom side — nothing under projects/ may be tracked.
if tracked=$(git ls-files projects/ | head -5) && [ -n "$tracked" ]; then
  say "✗ kingdom repo tracks files under projects/:"; say "$tracked" | sed 's/^/    /'; fail=1
else
  say "✓ kingdom repo tracks nothing under projects/"
fi

# Which projects to audit
if [ $# -ge 1 ]; then
  projects="$1"
else
  projects=$(python3 -c "import json;print('\n'.join(p['name'] for p in json.load(open('.orchestrator/registry/projects.json'))['projects']))" 2>/dev/null || true)
fi
[ -z "$projects" ] && { say "· no registered projects to audit"; exit $fail; }

STATE_PATTERN='^(\.orchestrator(/|$)|\.claude(/|$))|(^|/)\.env($|\.)|\.(pem|key)$'
for p in $projects; do
  dir="projects/$p"
  [ -d "$dir" ] || { say "✗ $p: directory missing ($dir)"; fail=1; continue; }

  # 2. Project side — no tracked state paths.
  if [ -e "$dir/.git" ]; then
    if bad=$(git -C "$dir" ls-files | grep -E "$STATE_PATTERN" | grep -Ev '(^|/)\.env\.example$' | head -5) && [ -n "$bad" ]; then
      say "✗ $p: project repo tracks state/secret paths:"; say "$bad" | sed 's/^/    /'; fail=1
    else
      say "✓ $p: project repo tracks no state paths"
    fi
  else
    say "✗ $p: not a git repository"; fail=1
  fi

  # 3. Symlink integrity.
  for link in .orchestrator .claude; do
    target="$dir/$link"
    if [ -L "$target" ] && [ -d "$target" ] && case "$(readlink -f "$target")" in "$KINGDOM/.orchestrator/projects/state/$p"*) true;; *) false;; esac; then
      say "✓ $p: $link symlink intact"
    else
      say "✗ $p: $link symlink missing or mis-targeted"; fail=1
    fi
  done

  # 4. Pre-commit boundary hook installed.
  if [ -x "$dir/.git/hooks/pre-commit" ] && grep -q "Kingdom boundary guard" "$dir/.git/hooks/pre-commit" 2>/dev/null; then
    say "✓ $p: pre-commit boundary hook installed"
  else
    say "✗ $p: pre-commit boundary hook missing"; fail=1
  fi
done
exit $fail
