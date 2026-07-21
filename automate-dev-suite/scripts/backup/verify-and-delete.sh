#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# verify-and-delete.sh — delete source folders ONLY after their snapshot verifies
#
# Reads a snapshot directory produced by snapshot-repos.sh, and for each folder:
#   1. re-verifies SHA256SUMS (backup integrity)
#   2. runs `git bundle verify` on any .bundle (git-level integrity)
#   3. confirms the expected archive(s) exist
#   4. reads the ORIGINAL source path from the manifest (never guessed)
#   5. refuses unsafe targets ($HOME, ~/kingdom, the snapshot dir, etc.)
#   6. warns if the source changed AFTER the snapshot (stale backup)
# A source folder is deleted only if every check for its own backup passes.
#
# Safe by default: DRY RUN unless --confirm is given.
#
# Usage:
#   ./verify-and-delete.sh <snapshot-dir>             # dry run: verify + preview
#   ./verify-and-delete.sh <snapshot-dir> --confirm   # delete verified sources
#   ./verify-and-delete.sh <snapshot-dir> --confirm --force   # also delete STALE sources
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SNAP_DIR="${1:-}"
[ "$#" -gt 0 ] && shift || true
CONFIRM=0
FORCE=0
for a in "$@"; do
  case "$a" in
    --confirm) CONFIRM=1 ;;
    --force) FORCE=1 ;;
    --help|-h) sed -n '3,24p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown argument: $a (use --help)" >&2; exit 2 ;;
  esac
done

if [ -z "$SNAP_DIR" ] || [ ! -d "$SNAP_DIR" ]; then
  echo "Usage: $0 <snapshot-dir> [--confirm] [--force]" >&2
  exit 2
fi
SNAP_DIR="$(cd "$SNAP_DIR" && pwd)"

log()  { printf '  \033[0;32m✓\033[0m %s\n' "$1"; }
fail() { printf '  \033[0;31m✗\033[0m %s\n' "$1"; }
warn() { printf '  \033[0;33m!\033[0m %s\n' "$1"; }
info() { printf '\033[1m%s\033[0m\n' "$1"; }

# Refuse to ever delete dangerous paths. Returns 0 (true) if UNSAFE.
is_unsafe() {
  local rp
  rp="$(realpath -m "$1")"
  [ -z "$rp" ] && return 0
  [ "$rp" = "/" ] && return 0
  [ "$rp" = "$HOME" ] && return 0
  case "$rp" in "$HOME"/?*) ;; *) return 0 ;; esac          # must live under $HOME
  case "$rp" in "$HOME"/kingdom|"$HOME"/kingdom/*) return 0 ;; esac  # never touch v1 kingdom (read-only reference)
  case "$rp" in "$HOME"/kingdom-2.0|"$HOME"/kingdom-2.0/*) return 0 ;; esac  # never touch the live environment
  case "$SNAP_DIR" in "$rp"|"$rp"/*) return 0 ;; esac        # rp is/contains the snapshot
  case "$rp" in "$SNAP_DIR"/*) return 0 ;; esac              # rp lives inside the snapshot
  return 1
}

info "Verifying snapshot: $SNAP_DIR"
[ "$CONFIRM" -eq 1 ] && echo "Mode: CONFIRM (will delete verified sources)" \
                     || echo "Mode: DRY RUN (no deletions; use --confirm to delete)"
echo

declare -a TO_DELETE=()
declare -a SKIPPED=()
total=0

for D in "$SNAP_DIR"/*/; do
  D="${D%/}"
  [ -d "$D" ] || continue
  total=$((total + 1))
  name="$(basename "$D")"
  info "$name"
  ok=1

  # Locate manifest + source path.
  manifest="$(find "$D" -maxdepth 1 -name '*.manifest.txt' | head -1)"
  if [ -z "$manifest" ]; then
    fail "no manifest — cannot determine source; skipping"
    SKIPPED+=("$name (no manifest)"); continue
  fi
  src="$(sed -n 's/^REPO: //p; s/^NON-GIT FOLDER: //p' "$manifest" | head -1)"
  if [ -z "$src" ]; then
    fail "manifest has no source path; skipping"
    SKIPPED+=("$name (no source path)"); continue
  fi
  echo "  source: $src"

  # 1. Checksum integrity of the backup.
  if [ -f "$D/SHA256SUMS" ] && (cd "$D" && sha256sum -c SHA256SUMS >/dev/null 2>&1); then
    log "checksums OK"
  else
    fail "checksum verification FAILED"; ok=0
  fi

  # 2. Bundle integrity (git sources): a real test-clone proves recoverability.
  bundle="$(find "$D" -maxdepth 1 -name '*.bundle' | head -1)"
  if [ -n "$bundle" ]; then
    tc="$(mktemp -d)"
    if git clone -q "$bundle" "$tc/clone" >/dev/null 2>&1 \
       && [ -n "$(git -C "$tc/clone" rev-list --all --max-count=1 2>/dev/null)" ]; then
      log "bundle test-clone OK (recoverable)"
    else
      fail "bundle test-clone FAILED"; ok=0
    fi
    rm -rf "$tc"
  else
    # 3. Non-git sources must have a full archive.
    if find "$D" -maxdepth 1 -name '*-full.tar.gz' | grep -q .; then
      log "full archive present (non-git source)"
    else
      fail "no .bundle and no -full.tar.gz — incomplete backup"; ok=0
    fi
  fi

  # 5. Safety guard on the deletion target.
  if is_unsafe "$src"; then
    fail "UNSAFE target, refusing to ever delete: $src"; ok=0
  fi
  if [ ! -d "$src" ]; then
    warn "source no longer present (already deleted?) — nothing to do"
    SKIPPED+=("$name (source gone)"); continue
  fi

  # 6. Staleness: any working file newer than the snapshot?
  if [ "$ok" -eq 1 ] && [ -d "$src" ]; then
    newer="$(find "$src" -type f \
              -not -path '*/node_modules/*' -not -path '*/.git/*' \
              -newer "$D/SHA256SUMS" -print -quit 2>/dev/null || true)"
    if [ -n "$newer" ]; then
      if [ "$FORCE" -eq 1 ]; then
        warn "source modified after snapshot — overridden by --force"
      else
        fail "source modified AFTER snapshot (e.g. $newer) — re-snapshot, or use --force"
        ok=0
      fi
    fi
  fi

  if [ "$ok" -eq 1 ]; then
    TO_DELETE+=("$src")
    log "VERIFIED — eligible for deletion"
  else
    SKIPPED+=("$name → $src")
  fi
  echo
done

# ─── Summary + action ────────────────────────────────────────────────────────
info "Summary"
echo "  folders examined : $total"
echo "  verified         : ${#TO_DELETE[@]}"
echo "  skipped/failed   : ${#SKIPPED[@]}"
if [ "${#SKIPPED[@]}" -gt 0 ]; then
  echo "  not deleting:"
  for s in "${SKIPPED[@]}"; do echo "    - $s"; done
fi
echo

if [ "${#TO_DELETE[@]}" -eq 0 ]; then
  info "Nothing eligible to delete."
  exit 0
fi

if [ "$CONFIRM" -eq 0 ]; then
  info "DRY RUN — these sources WOULD be deleted (all backups verified):"
  for s in "${TO_DELETE[@]}"; do echo "    rm -rf  $s"; done
  echo
  echo "Re-run with --confirm to delete them."
  exit 0
fi

info "Deleting verified sources..."
for s in "${TO_DELETE[@]}"; do
  # Re-check the guard immediately before removal (defence in depth).
  if is_unsafe "$s" || [ ! -d "$s" ]; then
    fail "guard tripped at delete time, skipping: $s"; continue
  fi
  rm -rf -- "$s"
  log "deleted: $s"
done
echo
info "Done. Backups remain in: $SNAP_DIR"
echo "Restore any folder later using the instructions in the snapshot report."