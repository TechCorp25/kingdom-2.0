# Task — live CometChat wiring — 2026-07-21T20-22

Tier 4. Working state for the CURRENT task only. Park bulk material (search
results, long outputs, drafts) as files beside this one and reference by path.

## Objective

Session goal 3 completion: connect the app to the real CometChat backend
after the owner's merge report-back and MCP/credential setup.

## Working state

- Complete; see Outcome.

## Scratch files

- $CLAUDE_JOB_DIR/tmp/smoke.log — last smoke run output (disposable)

## Outcome

Live CometChat verified end to end; PR #2 opened and self-check APPROVED.

- Owner merged PR #1 (d8a72c9); local main synced, branch deleted.
- CometChat skills installed (`npx @cometchat/skills add` + `--family native`)
  → land in kingdom state via the .claude symlink (boundary works).
- Owner signed into CometChat CLI in browser; app "chat-app"
  (1681081b01e3fd459, eu) provisioned; creds written to gitignored .env by
  `skills-cli provision setup` (authKey never in transcript). HARD gate
  approved + corrective re-record after fork wiped session binding.
- scripts/smoke-cometchat.mjs (Node + JS SDK + browser shims): init → login
  cometchat-uid-1 → sendMessage → conversations → logout, ALL GREEN against
  the live eu app. Node-shim gotchas: undici rejects referrer:"no-referrer";
  SDK needs XHR/localStorage/document.querySelector/location stubs.
- PR #2: https://github.com/TechCorp25/chat-app/pull/2 — self-check APPROVED
  in-envelope (no src/ changes; dev tooling only).
- LIVE-WIRE FINDINGS (suite backlog): (1) SessionStart:fork wipes
  runtime/current-session.json mid-session → sandbox-guard "no project
  selected" + gate mirror loss; remediation = re-run select-project + 
  corrective gate record. (2) sandbox-guard blocks Write tool but not Bash
  file mutations when unbound. (3) sync-check flags its own report file
  dirty. (4) use-expo orchestrator references stale ./plugins paths.

Follow-ups: owner merges PR #2; owner on-device Expo Go test (sign in as
cometchat-uid-2, message cometchat-uid-1 — smoke messages id 1-2 visible);
sign-up flow live test creates real users; EAS build behind spend gate.
