# Session plan — chat-app — 2026-07-21T20-01

<!-- Filename convention: {YYYY-MM-DDTHH-MM}-{slug}.md in
     .orchestrator/projects/tasks/chat-app/session-goals/
     The project-bootstrap workflow selects the LATEST file for today. -->

## Goals (ordered)

Owner's instruction (verbatim intent): first session is an e2e run of the
kingdom environment — build a modern chat application with an authentication
gate for users, integrating CometChat (via MCP), deployable as an Expo React
Native application ready for use.

1. Scaffold the Expo React Native app in `projects/chat-app` (TypeScript,
   Expo Router) — runs clean locally.
2. Auth gate: sign-in/sign-up flow; no chat surface reachable without a
   session; auth state persisted across app restarts.
3. CometChat integration via the CometChat MCP server: provision/connect the
   app, wire the RN SDK (init, login, conversation list, 1-1 chat screen).
4. Modern chat UI: conversation list + message screen, sensible loading/empty
   states.
5. Deployment readiness: EAS config in place, env handling for CometChat
   credentials, README run instructions. PR opened on chat-app remote.

## Success criteria

- App boots in Expo without errors; unauthenticated launch always lands on the
  auth screen, never a chat screen.
- A signed-in user can open a conversation and send/receive a message through
  CometChat.
- No secrets in either repo layer (env files gitignored; boundary-verify ✓).
- PR opened (not merged) on TechCorp25/chat-app; kingdom PR carries state.
- E2e validation: hooks (session-start, sandbox, gates, logs) observed firing
  correctly; misfires recorded.

## Constraints

- Sandbox: chat-app only — no pin-force or cross-project file access.
- Expo/Node: Node 22 via nvm (22.22.1). No Postgres/Docker/custom MCP control
  plane (locked architecture).
- No breaking rewrites of scaffold defaults beyond what the goals need.

## Gate notes

- CometChat app creation / API keys / credentials = HARD stop (secrets/keys):
  owner provides or approves before any key touches disk.
- PR readiness = Fable self-check (PR opened first, recorded via
  gate-record.sh). All merges owner-only.
- EAS account/build spend, if reached = HARD stop (spending).
