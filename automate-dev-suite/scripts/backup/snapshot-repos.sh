#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# snapshot-repos.sh — recoverable, single-folder backups before deletion
#
# For each source folder, captures everything that exists only on this machine:
#   • <name>.bundle           full git history, all refs (incl. UNPUSHED commits)
#   • <name>-worktree.tar.gz  modified + untracked files the bundle cannot see
#                             (respects .gitignore, so node_modules etc. excluded)
#   • <name>-full.tar.gz      whole folder, for NON-git sources (no history to bundle)
#   • <name>.manifest.txt     git status / unpushed log / remotes / checksums
# A single Markdown report summarising all folders is written alongside.
#
# Read-only on the sources: never commits, stashes, or modifies the repos.
#
# Usage:
#   ./snapshot-repos.sh                 # snapshot the default folder list
#   ./snapshot-repos.sh /path/a /path/b # snapshot specific folders
#   SNAPSHOT_DIR=/somewhere ./snapshot-repos.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# Default targets: the kingdom itself plus every registered project
# (override by passing folder paths as arguments).
KINGDOM_ROOT="$HOME/kingdom-2.0"
if [ "$#" -gt 0 ]; then
  SOURCES=("$@")
else
  SOURCES=("$KINGDOM_ROOT")
  while IFS= read -r p; do
    SOURCES+=("$KINGDOM_ROOT/projects/$p")
  done < <(python3 -c "import json;[print(p['name']) for p in json.load(open('$KINGDOM_ROOT/.orchestrator/registry/projects.json'))['projects']]" 2>/dev/null)
fi

# Folders that are regenerable and never worth archiving from non-git sources.
EXCLUDES=(node_modules .git .expo dist build .next .venv .turbo)

TS="$(date +%Y-%m-%dT%H-%M-%S)"
# Backups must live OUTSIDE the tree they back up (and outside both repos).
DEST_ROOT="${SNAPSHOT_DIR:-$HOME/kingdom-backups/snapshots}/$TS"
mkdir -p "$DEST_ROOT"
REPORT="$DEST_ROOT/${TS}-snapshot-report.md"

log()  { printf '  \033[0;32m✓\033[0m %s\n' "$1"; }
warn() { printf '  \033[0;33m!\033[0m %s\n' "$1"; }
info() { printf '\033[1m%s\033[0m\n' "$1"; }

sanitize() { printf '%s' "$1" | tr -c 'A-Za-z0-9._-' '_'; }

{
  echo "# Repository snapshot report"
  echo
  echo "- Created: $TS"
  echo "- Destination: \`$DEST_ROOT\`"
  echo
  echo "Each git source produces a \`.bundle\` (full history, including unpushed"
  echo "commits) plus a \`-worktree.tar.gz\` (uncommitted + untracked files)."
  echo "Non-git sources produce a single \`-full.tar.gz\`. Restore instructions are"
  echo "at the end of this report."
  echo
} > "$REPORT"

info "Snapshot → $DEST_ROOT"

for src in "${SOURCES[@]}"; do
  if [ ! -d "$src" ]; then
    warn "missing, skipped: $src"
    { echo "## (missing) $src"; echo; echo "Folder not found — skipped."; echo; } >> "$REPORT"
    continue
  fi

  name="$(basename "$src")"
  safe="$(sanitize "$name")"
  out="$DEST_ROOT/$safe"
  mkdir -p "$out"
  manifest="$out/$safe.manifest.txt"
  info "$name"
  { echo "## $name"; echo; echo "- Source: \`$src\`"; } >> "$REPORT"

  if [ -d "$src/.git" ]; then
    # 1) Full history bundle (all refs → includes unpushed commits).
    git -C "$src" bundle create "$out/$safe.bundle" --all >/dev/null 2>&1
    if git -C "$src" bundle verify "$out/$safe.bundle" >/dev/null 2>&1; then
      log "bundle created + verified"
    else
      warn "bundle verify FAILED — inspect manually"
    fi

    # 2) Working-tree delta: modified + untracked, .gitignore-respecting.
    mapfile -d '' -t dirty < <(cd "$src" && git ls-files -z --modified --others --exclude-standard)
    if [ "${#dirty[@]}" -gt 0 ]; then
      (cd "$src" && printf '%s\0' "${dirty[@]}" \
        | tar --null --no-recursion -czf "$out/$safe-worktree.tar.gz" -T -)
      log "worktree archive: ${#dirty[@]} modified/untracked file(s)"
    else
      log "working tree clean — no worktree archive needed"
    fi

    # 3) Manifest: human-readable record of what was unique.
    {
      echo "REPO: $src"
      echo "DATE: $TS"
      echo
      echo "== branch / status =="
      git -C "$src" status --short --branch
      echo
      echo "== unpushed commits (local, not on any remote) =="
      git -C "$src" log --branches --not --remotes --oneline || true
      echo
      echo "== remotes =="
      git -C "$src" remote -v
    } > "$manifest"
    { echo "- Type: git repo"; echo "- Files: \`$safe.bundle\`, worktree archive (if dirty), \`$safe.manifest.txt\`"; } >> "$REPORT"
  else
    # Non-git: archive the whole folder minus regenerable dirs.
    tar_excludes=()
    for e in "${EXCLUDES[@]}"; do tar_excludes+=(--exclude="$e"); done
    tar -czf "$out/$safe-full.tar.gz" "${tar_excludes[@]}" -C "$(dirname "$src")" "$name"
    log "full archive (non-git source)"
    {
      echo "NON-GIT FOLDER: $src"
      echo "DATE: $TS"
      echo "Archived whole folder, excluding: ${EXCLUDES[*]}"
    } > "$manifest"
    { echo "- Type: NON-git (no remote safety net — full archive made)"; echo "- Files: \`$safe-full.tar.gz\`, \`$safe.manifest.txt\`"; } >> "$REPORT"
  fi

  # Checksums for integrity verification later.
  (cd "$out" && sha256sum ./* > "SHA256SUMS" 2>/dev/null) || true
  size="$(du -sh "$out" | cut -f1)"
  { echo "- Snapshot size: $size"; echo; } >> "$REPORT"
done

{
  echo "## Restore instructions"
  echo
  echo '```bash'
  echo '# Git history (recreates a working clone with ALL branches/commits):'
  echo 'git clone <name>.bundle restored-<name>'
  echo 'cd restored-<name> && git branch -a        # confirm branches incl. unpushed work'
  echo
  echo '# Re-apply uncommitted + untracked files on top of the clone:'
  echo 'tar xzf ../<name>-worktree.tar.gz -C .'
  echo
  echo '# Non-git folder:'
  echo 'tar xzf <name>-full.tar.gz'
  echo
  echo '# Verify integrity of any snapshot folder:'
  echo 'sha256sum -c SHA256SUMS'
  echo '```'
} >> "$REPORT"

echo
info "Done. Report: $REPORT"
du -sh "$DEST_ROOT"