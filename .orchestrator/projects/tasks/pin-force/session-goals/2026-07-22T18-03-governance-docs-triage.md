# Session plan — pin-force — 2026-07-22T18-03

<!-- Filename convention: {YYYY-MM-DDTHH-MM}-{slug}.md in
     .orchestrator/projects/tasks/pin-force/session-goals/
     The project-bootstrap workflow selects the LATEST file for today. -->

## Intent

A batch of ~25 untracked governance documents has landed in
`projects/pin-force/docs/governance/` since last session, in a disorganised
state (misspelled/space-bearing directories, duplicate files across
baselines/approved/superseeded, inconsistent filenames). The owner wants these
assessed and correctly sorted into the right directories BEFORE the Expo pilot
resumes. This is governance-first, HARD-gated territory.

## Goals (ordered)

1. Derive the authoritative document taxonomy + naming convention from the
   governance framework itself (GS-000 Document Governance Framework, GS-001
   Approval Record Standard, GS-002 Register of Authority) — do not invent one.
2. Assess every untracked doc: identify its GS/CMP id, version, and lifecycle
   status (approved / baseline / draft / superseded / template / risk-commission)
   from its own content, not just its filename.
3. Produce a proposed mapping (current path → correct path), including directory
   renames (fix `superseeded`→`superseded`, `risk assesment`→correct name),
   filename fixes (`Decleration`, `.md.txt`, `..md`, leading-space), and
   duplicate resolution. Get owner sign-off on the mapping before executing.
4. Execute the sort with `git mv`/adds so history is clean; keep the tree
   matching the framework's prescribed structure.
5. Land via session branch → PR on `CivicMAPS/pin-force`.

## Success criteria

- Every doc filed in a directory justified by its actual status; no duplicates
  left ambiguous; no misspelled/space-bearing directory or file names remain.
- `docs/governance/approved-source/` (HARD-gated) is unchanged unless the owner
  explicitly approves an addition there.
- Structure validated against the governance framework's own taxonomy.
- boundary-verify.sh ✓; project change lands only in CivicMAPS/pin-force.
- Task/session memory promoted; gate decisions recorded.

## Constraints

- Nothing under `docs/governance/approved-source/` changes without explicit
  owner approval (existing approved foundation Sections 01–03 + SHA256SUMS).
- Content of the documents is NOT edited — this is a sort/rename/file task, not
  an authoring task. If a doc's content contradicts its filename status, flag to
  owner rather than silently refiling.
- No secrets in either repo layer.

## Gate notes

- **HARD (owner):** any change to `approved-source/`; final approval of the
  proposed sorting mapping before execution (owner ratifies the taxonomy call).
- **Self-check (Fable):** project PR readiness once the mapping is executed
  (parks as HARD pending owner per the standing project-merge policy).
- **Go:** each goal's success criteria above.
