# Risk envelope — what a Fable self-check approval covers

Agreed 2026-07-21 (build prompt §9/§12). Changes to this file are themselves a
HARD gate.

## Inside the envelope (Fable may approve)

- Kingdom-repo PRs: suite scaffolding, workflows, templates, docs, skills,
  agents, hook *additions/tightenings*, promoted state and reports, registry.
- Project-repo PRs: code changes within the session-goals scope, with tests/
  checks green and the diff-scan security pass clean of high/critical findings.
- Private repo creation on the owner's GitHub via the standing new-project
  workflow.
- Patch/minor dependency updates with clean lockfiles.

## Outside the envelope (owner only — always)

- Secrets, API keys, tokens; anything that spends money; deployments.
- Destructive/irreversible operations (force-push, history rewrite, repo or
  branch deletion with unmerged work, data deletion).
- Making anything public or otherwise outward-facing.
- Weakening guards, gates, boundaries, or this envelope.
- Auth, payment, or data-migration code paths in any project.

## Reviewer duties on every approval

Confirm the PR is within scope of its stated gate class and this envelope;
verify the claimed evidence (tests, boundary-verify, security notes) is present
in the PR itself; reject anything it cannot verify from the artifact alone.
