- [ ] 2026-08-17 **OWNER ACTION — common-ground gate rows are STILL a PROPOSAL.** PR #21 was
      squash-merged (origin/main 025c657) and the capability is live, but **the merge did not
      promote the gate proposal** — verified: `_proposals/2026-07-25T08-46-44-gate-map.md` is still
      there and `gate-map.md` is byte-unchanged. That is by design; the `git mv` is a separate
      manual act and IS the approval signal. Until it happens the action is unlisted and resolves
      to HARD, so every assumption write prompts. Promote with:
      `git mv automate-dev-suite/gates/_proposals/2026-07-25T08-46-44-gate-map.md automate-dev-suite/gates/gate-map.md`
- [x] 2026-08-17: common-ground integration MERGED (PR #21 → origin/main 025c657); source branch
      auto-deleted by GitHub, local main ff-pulled. Skill + `scripts/common-ground.sh` + workflow +
      port record `docs/build/003-common-ground-port.md` all live. Additive only — `gate-map.md`,
      `settings.json`, every hook and pre-existing script/skill/workflow byte-identical.
- [ ] 2026-07-25 **OWNER ACTION (HARD — guard code).** `sandbox-guard.py:80` Bash arm does not
      protect `.orchestrator/projects/state/{p}/…`: the regex matches non-overlapping, consumes
      `projects/state` and captures `"state"`, so cross-project Bash access is never denied there
      (`projects/{p}/…` still works). File-tool arm is fine. `memory-promote.sh:12` has the same
      `--project` exposure. `common-ground.sh` self-enforces the binding as mitigation. Fixing the
      guard is HARD-gated — owner's call. Detail: `docs/build/003-common-ground-port.md`.
- [ ] 2026-07-25 (kingdom hygiene): DD-001:56 says `boundary-verify.sh` runs at kingdom bootstrap
      and session end — NOT implemented in either workflow (only new-project/adopt-project/
      bootstrap-machine invoke it). Either wire it in or correct DD-001.
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
- [x] 2026-07-23: studio-suite NEW-PROJECT PREP COMPLETE & CLOSED — created via new-project.sh
      (private remote TechCorp25/studio-suite, registered #3); v2.0 prototype monorepo seeded;
      PROJECT.md + project settings.json + first-sessions roadmap + Session-01 plan written;
      temp-directory-only consumed & deleted. BOTH PRs squash-merged & branches deleted by owner:
      kingdom #17 (main b957219), studio-suite #1 (main 1bef7c0).
- [x] 2026-07-23/24: studio-suite SESSION 01 (monorepo & toolchain baseline) COMPLETE & verified —
      Node 22.22.1 / pnpm 11 workspaces (hoisted); `@illuminate/tokens` typechecks & is consumed by
      both apps; web Vite skeleton at `apps/web/app/` (prototype left intact at `index.html`);
      Expo/Metro boots + bundles the shared theme. Report: `reports/sessions/2026-07-23T22-16-session.md`.
      BOTH PRs squash-merged + branches deleted by owner: studio-suite #2 (main `83ffd1e`),
      kingdom #19 (main `2b90512`). Local mains fast-forwarded, session branches deleted, refs
      pruned (2026-07-24). Fable PR-readiness self-check was PARKED (out of credits).
- [ ] studio-suite SESSION 02 — **READY TO START**: plan pre-authored at
      `session-goals/2026-07-24T09-56-session-02-web-vite-migration.md`
      (roadmap: `session-goals/00-ROADMAP-first-sessions.md`) — web Babel-standalone →
      Vite + React + TS migration to **feature parity** (8 surfaces), typecheck clean, no
      visual regressions. **FIRST DECISION (blocks the rest):** reconcile the directory layout —
      S01's Vite root is `apps/web/app/` while prototype sources are `apps/web/src/**`;
      options + recommendation are in the plan.
      If starting a LATER date, re-date the plan file so project-bootstrap auto-selects it.
- [ ] studio-suite OWNER DECISIONS pending for S02: (a) retire/delete the Babel-standalone
      prototype `apps/web/index.html` once parity lands? (the assistant will NOT delete it
      unilaterally); (b) **Vite 5 → 6** — dependabot branch `dependabot/npm_and_yarn/vite-6.4.3`
      is open on studio-suite and overlaps S02's surface area; decide before migrating.
      Also 3 dependabot vulns on `main` (1 high, 2 moderate) → schedule a dependency audit.
- [ ] 2026-07-24 (kingdom hygiene): a stray `memory-updater-temp-directory/` (cached Anthropic
      agent-memory API docs, NOT project content) sat at the kingdom repo root during S01 bootstrap;
      moved to session scratchpad (out of the repo). Confirm with owner it's disposable and find what
      dropped it so it doesn't recur.
- [ ] studio-suite SECURITY debt (Session 05, HARD gate): OpenAI/Luma key is embedded client-side
      → move behind a server proxy + rotate the key before any non-dev use.
