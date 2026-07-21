# GitHub & git identity (environment facts, from v1 — verified 2026-07-21)

- **Accounts:** personal `TechCorp25` (kingdom-2.0 remote); org `techcorp-DevApps`
  (some v1-era app repos); `CivicMAPS` org (pin-force). Same machine identity
  covers all.
- **git identity:** `user.name = techcorp2024`, `user.email =
  techcorp2024@gmail.com`. A placeholder email means commits don't link to the
  account — fix with `git commit --amend --reset-author` after correcting config.
- **Transport (v2 reality):** HTTPS + `gh` credential helper. The SSH key
  `~/.ssh/id_ed25519` exists but has a passphrase, so **SSH pushes fail in
  non-interactive shells** — v1's "always SSH" rule is superseded; keep remotes
  on `https://github.com/...`.
- **gh protocol gotcha (fixed 2026-07-21):** host-level `git_protocol: ssh` in
  `~/.config/gh/hosts.yml` silently overrides the global `https` setting, so
  `gh repo create --push` wired an SSH remote and broke `new-project.sh`
  mid-run (repo created, push failed, registry not written). Fixed with
  `gh config set -h github.com git_protocol https`. If a scaffold ever dies
  the same way: fix the remote URL, push, then run the script's step-4
  registration block manually and `boundary-verify.sh`.
- If SSH is ever needed interactively: `eval "$(ssh-agent -s)"; ssh-add
  ~/.ssh/id_ed25519` (passphrase prompt), then `ssh -T git@github.com` — a
  **username** greeting (`Hi TechCorp25!`) = account key, good; a **repo-name**
  greeting = a single-repo deploy key, wrong key loaded.
- New-machine handover: `gh auth login` is the one manual prerequisite
  (bootstrap-machine.sh checks for it).
