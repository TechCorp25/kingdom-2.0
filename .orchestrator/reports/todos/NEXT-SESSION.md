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
