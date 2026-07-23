- [x] 2026-07-21: v1 salvage COMPLETE (#11 mitigations, #13 backup/playbooks/identity); owner-only-merge policy live (#10)
- [x] 2026-07-23: live-wire validation PASSED (pin-force session) — session-start injection, sandbox guard, gates-guard, gate-record, memory-promote, boundary-verify all fired correctly; no misfires observed
- [x] 2026-07-23: pin-force governance docs triage — assessed + sorted ~25 dropped docs into GS-000 taxonomy; PR #5 squash-merged (origin/main b5d1b8f). GS-001 finalised as approved standard w/ real SHA binding (standards/SHA256SUMS)
- [ ] 2026-07-23 (owner: "pick up in a clean session"): pin-force governance FOLLOW-UPS —
      GS-003 standard: repair missing opening `---` fence + reconcile v2.0.0-filename vs v1.0.0-frontmatter version;
      freeze GS-000/GS-002/GS-003 approval records (still carry d41d8 empty-MD5 placeholder digests) like GS-001;
      GS-001 assessment-report + verification-package companion artifacts absent from repo (digests PENDING)
- [ ] then pin-force pilot goals 2-5: Expo test app scaffold -> EAS (Node 22 via nvm 22.22.1; keys = HARD stop at goal 5); plan: session-goals/2026-07-21T15-39-expo-pilot.md
- [ ] NOTE: Fable 5 self-check gate is BLOCKED — out of usage credits (hit 2026-07-22). PR-readiness self-checks park pending owner until topped up (/usage-credits) or model switched
- [ ] optional: run scripts/backup/snapshot-repos.sh before the machine handover when it comes
- [ ] 2026-07-21T21-38-36: session for 'chat-app' ended (other) with un-promoted SESSION.md —
      run session remediation in project bootstrap (memory-promote.sh session --project chat-app)
- [ ] 2026-07-21T23-39-05: session for 'chat-app' ended (other) with un-promoted SESSION.md —
      run session remediation in project bootstrap (memory-promote.sh session --project chat-app)
- [ ] 2026-07-23: chat-app leftover session-log artifacts (2 gate records re PR #2 merge status,
      plus sync/subagent append-logs) were STASHED on kingdom (`git stash@{0}`) during the
      studio-suite prep session — pop & reconcile in chat-app's next bootstrap. NOTE the corrective
      gate record: chat-app PR #2 was still OPEN (not merged) as of 2026-07-21T21:38.
- [x] 2026-07-23: studio-suite NEW-PROJECT PREP COMPLETE — created via new-project.sh (private
      remote TechCorp25/studio-suite, registered #3); v2.0 prototype monorepo seeded (project
      PR #1 OPEN — owner merge); PROJECT.md + project settings.json + first-sessions roadmap +
      Session-01 plan written; temp-directory-only consumed & deleted.
- [ ] studio-suite FIRST BUILD SESSION: plan pre-authored at
      `session-goals/2026-07-23T15-05-session-01-monorepo-baseline.md`
      (roadmap: `session-goals/00-ROADMAP-first-sessions.md`). If starting a LATER date, re-date
      the plan file (or session-goals.sh --create) so project-bootstrap auto-selects it.
      FIRST: owner merges project PR #1 (seed import).
- [ ] studio-suite SECURITY debt (Session 05, HARD gate): OpenAI/Luma key is embedded client-side
      → move behind a server proxy + rotate the key before any non-dev use.
