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
- If SSH is ever needed interactively: `eval "$(ssh-agent -s)"; ssh-add
  ~/.ssh/id_ed25519` (passphrase prompt), then `ssh -T git@github.com` — a
  **username** greeting (`Hi TechCorp25!`) = account key, good; a **repo-name**
  greeting = a single-repo deploy key, wrong key loaded.
- New-machine handover: `gh auth login` is the one manual prerequisite
  (bootstrap-machine.sh checks for it).
