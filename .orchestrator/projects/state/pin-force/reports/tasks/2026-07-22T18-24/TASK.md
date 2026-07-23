# TASK — governance docs triage (pin-force) — 2026-07-22

Tier 4. Assess ~25 untracked governance docs in `docs/governance/` and sort into
correct directories per GS-000 taxonomy. Content NOT edited (flag, don't fix).

## Objective
Correctly classify + file every untracked governance doc; fix directory/file
naming; resolve duplicates. Owner ratifies mapping before execution (HARD).

## Authoritative basis
- **GS-000 §4** hierarchy: Governance Standards · Registers · Programme
  Specifications · Assessment Records · Decision Records · Approval Records ·
  Evidence Records.
- **GS-000 §5.1** states: Proposed Draft → Submitted → Under Assessment →
  Conditionally Approved → Approved → Formally Approved → Superseded → Withdrawn.
- **GS-000 §8.2** filename: `CivicMAPS_[Class]_[Name]_v[MAJOR.MINOR.PATCH].md`
  (no spaces, no double extensions, no double dots).
- No Programme Records Register exists yet → taxonomy is derived + owner-ratified.

## Existing TRACKED dirs (established semantics — respect them)
- `approved-source/` — approved programme specs (Sections 01-03 + SHA256SUMS).
  **HARD-gated, do not touch.**
- `approvals/` — Formal Approval Records (was empty).
- `baselines/` — baseline artifacts (REPOSITORY_TREE_INITIAL.txt).
- `baselines/approved/` — approved standard baselines (was empty).
- `requirements/` — requirements (empty).

## PROPOSED target structure (owner to ratify)
- `approved-source/`      — unchanged (HARD-gated).
- `baselines/approved/`   — Formally Approved / Operative Governance Standards.
- `baselines/`            — baseline artifacts (tree snapshot).
- `baselines/superseded/` — [rename superseeded] superseded records/standards.
- `approvals/`            — Formal Approval Records / Declarations (current).
- `drafts/`               — Under-Assessment / Draft docs (not yet approved).
- `templates/`            — governance templates.
- `assessments/`          — [replaces "risk assesment"] commissioned Assessment
                            Records (CMP-001..004 + transmittal).
- `decisions/`            — Decision Records (ODR risk-acceptance, decision-
                            selection pack, Section 04 freeze proposal).
- `requirements/`         — unchanged (empty).

## FULL INVENTORY + MAPPING (current → proposed) with issues

### A. Governance Standards
1. baselines/GS-000_Document_Governance_Framework_v1.0.0.md
   → DELETE (byte-identical dup of baselines/approved/ copy).
2. baselines/approved/GS-000_Document_Governance_Framework_v1.0.0.md
   → KEEP (Formally Approved/Operative). Canonical GS-000.
3. baselines/GS-002_Register_of_Authority_Standard_v1.0.0.md.txt
   → DELETE (byte-identical dup; bad .md.txt).
4. baselines/approved/GS-002_..._v1.0.0.md.txt
   → RENAME → baselines/approved/CivicMAPS_GS-002_Register_of_Authority_Standard_v1.0.0.md
5. baselines/"CivicMAPS _GS-003_Risk_Ownership_Register_Standard_v2.0.0.md"
   → RENAME → baselines/approved/CivicMAPS_GS-003_Risk_Ownership_Register_Standard_v2.0.0.md
   ⚠ V1: filename v2.0.0 vs frontmatter version 1.0.0 — canonical version?
6. drafts/GS-003_Risk_Ownership_Register_Standard_v.1.0.0.md (UNDER ASSESSMENT)
   → RENAME → drafts/CivicMAPS_GS-003_Risk_Ownership_Register_Standard_v1.0.0.md
7. baselines/superseeded/GS-001_Formal_Approval_Record_Standard.md
   (READY FOR FORMAL APPROVAL / UNDER ASSESSMENT — NOT superseded)
   → MOVE → drafts/CivicMAPS_GS-001_Formal_Approval_Record_Standard_v1.0.0.md
   ⚠ M1 misfiled as superseded. ⚠ C1 approvals/ GS-001 record says approved.
8. templates/GS-001_..._v1.0.0..md
   → DELETE (byte-identical to #7; not a template; double-dot).

### B. Templates
9. templates/GS-001_Formal_Approval_Record_Standard_v1.0.0.md.TEMPLATE (real template)
   → RENAME → templates/CivicMAPS_Formal_Approval_Record_Template_v1.0.0.md

### C. Approval Records / Declarations (→ approvals/)
10. approvals/GS-000_Approval_Decleration.md
    → RENAME → approvals/CivicMAPS_GS-000_Formal_Approval_Record_v1.0.0.md
    ⚠ CORRUPT-1: chat preamble + stray "yaml" fence before frontmatter.
11. approvals/GS-001_Approval_Decleration.md (clean)
    → RENAME → approvals/CivicMAPS_GS-001_Formal_Approval_Record_v1.0.0.md
12. approvals/GS-002_Approval_Decleration.md (clean)
    → RENAME → approvals/CivicMAPS_GS-002_Formal_Approval_Record_v1.0.0.md
13. approvals/GS-003_Approval_Decleration.md
    → RENAME → approvals/CivicMAPS_GS-003_Formal_Approval_Declaration_v1.0.0.md
    ⚠ CORRUPT-2: same chat-preamble/fence corruption as #10.
14. baselines/GS-000_Approval_Record_v1.4.0.md (FORMALLY APPROVED)
    → MOVE → approvals/CivicMAPS_GS-000_Formal_Approval_Record_v1.4.0.md
    ⚠ V2: two GS-000 approval records (v1.0.0 #10, v1.4.0 #14).
15. baselines/superseeded/GS-000_Approval_Record_v1.0.0.md (superseded by v1.4.0)
    → MOVE → baselines/superseded/CivicMAPS_GS-000_Formal_Approval_Record_v1.0.0.md
    (differs from #10; correctly superseded).

### D. Assessment Records — commissioned (→ assessments/, from "risk assesment/")
16-20. Commission_00_Submission_Transmittal, CMP-001_Privacy_PIA,
    CMP-002_Security_VPDSF_ISM_IRAP, CMP-003_Records_Evidentiary,
    CMP-004_Obsolescence_Risk → assessments/ (COMMISSIONED, NOT EXECUTED).

### E. Decision Records (→ decisions/)
21. Decision_Selection_Records_Stack_Pack.md → decisions/
22. ODR_Risk_Acceptance_Provisional_Build.md → decisions/ (DRAFT)
23. Section_04_Index_Freeze_Proposal.md → decisions/ (DECISION MEMO)

### F. Programme Specification draft (→ drafts/)
24. drafts/Section_03_Target_State_Architecture_Candidate_v2_3_1.md
    → KEEP (candidate v2.3.1; approved index v2.1.0 lives in approved-source/).

### G. Stray
25. docs/governance/.gitkeep → DELETE (root has real files).
    approvals/.gitkeep, baselines/approved/.gitkeep → DELETE once real files land.
    requirements/.gitkeep → KEEP (stays empty).

## OPEN OWNER DECISIONS
- TAXONOMY: approve dir set (new assessments/, decisions/; approved standards in
  baselines/approved/).
- CORRUPT-1/2: repair chat-preamble corruption in GS-000 & GS-003 approval files
  now, or file as-is and defer content fix?
- V1: GS-003 canonical version (filename v2.0.0 vs frontmatter v1.0.0).
- C1: GS-001 approved vs under-assessment contradiction.
- V2: confirm GS-000 approval record v1.0.0 superseded by v1.4.0.

## Working state
- Owner ratified taxonomy (hybrid: split assessments/+decisions/ AND dedicated
  standards/ dir) and chose "repair now" for the 2 corrupt approval files.
- Executed + committed 69894ee. Tree verified (28 non-.gitkeep files; 21 sorted,
  3 dup deletions, 1 stray .gitkeep removed; no misspelled/space dirs remain).

## Scratch files
- (none beyond this file)

## Outcome
Governance docs triage COMPLETE and committed on branch
session/2026-07-22-governance-docs-triage as 69894ee.
- Verified: boundary-verify.sh all ✓; file accounting reconciles (nothing lost);
  approved-source/ untouched; both corrupt approval files now open on clean `---`
  frontmatter (GS-000 483→ stripped 4 junk lines; GS-003 same).
- Final structure: standards/ · approvals/ · drafts/ · templates/ ·
  assessments/ · decisions/ · baselines/{,approved/,superseded/} · requirements/.
FOLLOW-UPS flagged for owner (do NOT block this sort; content/metadata bugs):
  - V1: GS-003 approved copy filename says v2.0.0 but frontmatter version:1.0.0.
  - C1: GS-001 standard is "UNDER ASSESSMENT" yet has a FORMALLY APPROVED
    approval record in approvals/ — reconcile actual status.
  - V2: confirm GS-000 approval record v1.0.0 is superseded by v1.4.0 (both now
    filed: v1.0.0 in baselines/superseded/, v1.4.0 in approvals/).
NEXT: push branch, open PR on CivicMAPS/pin-force, Fable PR-readiness self-check
(parks HARD pending owner merge per project-merge policy).
