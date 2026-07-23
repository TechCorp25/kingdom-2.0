# pin-force — project memory (Tier 2)

## What this project is

CivicMAPS **pin-force**: governed repository foundation for a
multi-jurisdiction, multi-organisation public-sector field-operations platform
(municipal-first). The current tree is the approved FOUNDATION ONLY — no
runtime, framework, database, identity, GIS, or hosting decisions are approved
yet; those arrive via governance (ADRs under `docs/architecture/`).

## Durable facts

- Remote: `https://github.com/CivicMAPS/pin-force.git` (private, default `main`)
- Adopted into Kingdom v2 2026-07-21 via `adopt-project.sh`; **pilot project**
  for the suite's end-to-end dry-run.
- Node monorepo: `@civicmaps/platform`, workspaces `apps/*`, `services/*`,
  `domains/*`, `packages/*`. Root scripts: `verify:structure`,
  `validate:contracts`, `validate:deployment-wiring`, `security:baseline`,
  `test`, `ci`.
- Deployment manifest present but `enabled: false` (`deployment-adr-pending`).
- **SHA verification (2026-07-21, §11 of the build prompt):**
  - Section 01 `7a8a49b4…ec58` — MATCHES recorded baseline ✓
  - Section 03 `922f2811…4699` — MATCHES recorded baseline ✓
  - Section 02 actual `ffab7b9a…cb57` vs recorded source-candidate
    `f18a976f…1628` — expected difference: the record is the pre-approval
    source candidate; post-approval bytes were "verified separately" (guide
    §17), and git confirms the file is untouched since bootstrap commit
    `280e72f`. Provenance intact.

## Governance document structure (established 2026-07-23, PR #5 `b5d1b8f`)

`docs/governance/` taxonomy (derived from the repo's own GS-000 Document
Governance Framework — §4 hierarchy, §5 lifecycle states, §8.2 naming
`CivicMAPS_[Class]_[Name]_v[MAJOR.MINOR.PATCH].md`):

- `approved-source/` — approved programme specs (Sections 01-03 + SHA256SUMS). **HARD-gated.**
- `standards/` — Formally Approved / Operative Governance Standards (GS-000, GS-001, GS-002, GS-003) + `SHA256SUMS` (verifiable; `sha256sum -c`).
- `approvals/` — Formal Approval Records / Declarations.
- `drafts/` — under-assessment / draft docs (kept as historical pre-approval records even after approval).
- `templates/` — governance templates.
- `assessments/` — commissioned Assessment Records (CMP-001..004 + transmittal).
- `decisions/` — Decision Records (ODR risk-acceptance, decision-selection pack, S04 freeze proposal).
- `baselines/{,approved/,superseded/}` — baseline artifacts; superseded records.
- `requirements/` — (empty).

Convention: a file cannot embed its own SHA; real hashes live in the external
`SHA256SUMS` + the approval record's `approved_document.sha256`. GS-001 is the
only standard frozen with real SHAs so far (`approved_document.sha256` ==
`deaecb20..33b8`).

OPEN governance follow-ups (owner):
- GS-003 standard: missing opening `---` frontmatter fence AND filename `v2.0.0`
  vs frontmatter `version: 1.0.0` — reconcile canonical version + repair fence.
- GS-000/GS-002/GS-003 approval records still carry the `d41d8..`(empty-MD5)
  placeholder digests — freeze them like GS-001 when ready.
- GS-001 assessment-report + verification-package companion artifacts are not in
  the repo (their digests are labelled PENDING in the approval record).

## Conventions and constraints

- Governance-first: approved source docs live under
  `docs/governance/approved-source/` and are never edited casually; changes to
  approved baselines are HARD-gated on the owner.
- Branches consume shared capabilities; application/domain forks are
  prohibited (README). Unowned `common`/`misc` dumping grounds prohibited.
- Required local validation: `npm ci --ignore-scripts` + root `ci` script.
- **Node 22 required** (`nvm use 22.22.1`) — from the recorded bootstrap run
  (`~/.codex/memories/`, rollout 2026-07-19): the repo was bootstrapped and
  SHA-validated under Node 22 via `bootstrap-civicmaps-repository.sh` +
  `SHA256SUMS`; the remote baseline replacement was SHA-bound and
  force-with-lease published. Use Node 22 for the Expo pilot.
- CivicMAPS lineage (read-only v1 reference, upstream of this repo's
  governance docs): `~/kingdom/projects/civic-maps-preview/docs/assesment/`
  (Sections 01–04 authoritative foundation) and
  `docs/development_records/authoritive-decision-records/`. Consult, never
  modify; the approved copies inside THIS repo win where they overlap.
- Stack boundary: CivicMAPS is Node/Express + PostgreSQL — never import
  patterns from other kingdom projects' stacks
  (`automate-dev-suite/docs/policies/stack-boundaries.md`).
- Local working copy has a modified `.gitignore` (kingdom boundary block
  appended at adoption) — land it via the first project PR.

## Pilot task (owner-defined, build prompt §11)

Basic **Expo React Native test application** in working order, deployed via
**EAS**, with full git workflow automations (branch → PR → checks → merge →
deploy). Expo API keys/tokens are a HARD STOP: request from the owner at
deployment, store only in gitignored env files — never in either repo layer.

## Pointers

- Reports: `.orchestrator/reports/` · Goals:
  `~/kingdom-2.0/.orchestrator/projects/tasks/pin-force/session-goals/`
