---
name: new-project
description: Create or adopt a project under Kingdom governance — scaffold state tiers, wire the git boundary, create/attach the remote, register it. Use when the owner asks to start a new project, add a repo, or bring an existing repo under kingdom management.
---

# New / adopted project

- **Brand-new project:** `automate-dev-suite/scripts/new-project.sh <name> ["description"]`
  — creates state tiers, symlinks, boundary hook, a private remote on the
  owner's GitHub (suite-owned creation), and registers it.
- **Existing repo (has its own remote):** `automate-dev-suite/scripts/adopt-project.sh <name> <git-url>`
  — clones, wires the same governance, keeps the remote untouched.

After either:

1. Seed `state/<name>/memory/project/PROJECT.md` from the project's real docs
   (purpose, stack, conventions) — never leave template placeholders.
2. Commit the kingdom-side changes (registry + state) on the session's kingdom
   branch; adopted repos also get a project PR for the boundary `.gitignore` block.
3. `automate-dev-suite/scripts/boundary-verify.sh <name>` must be all `✓`.

Names: `^[a-z0-9][a-z0-9-]*$`. Details: `workflows/git-layer.md`, DD-001.
