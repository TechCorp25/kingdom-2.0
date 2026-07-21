# chat-app — project memory (Tier 2)

Durable facts only. This file is read at every project bootstrap — keep it
small and current; move history to reports.

## What this project is

Modern mobile chat application: users must authenticate before reaching any
chat surface (auth gate), messaging is powered by CometChat (provisioned and
managed via the CometChat MCP server), built as an Expo React Native app and
kept EAS-deployable. Also serves as the first end-to-end validation run of the
Kingdom v2 environment (hooks, gates, boundary, memory tiers).

## Durable facts

- Remote: https://github.com/TechCorp25/chat-app.git (private, HTTPS — never SSH on this machine)
- Stack: Expo React Native (Node 22 via nvm 22.22.1), CometChat via MCP, EAS for builds
- Owner GitHub account: TechCorp25
- Created 2026-07-21 during the first live Kingdom v2 session
- CometChat app: id 1681081b01e3fd459, region eu, name "chat-app"
  (owner's account techcorp2024@gmail.com; free plan; provisioned 2026-07-21
  via `npx @cometchat/skills-cli provision setup`). App id/region are
  client-public; the auth key lives ONLY in the project's gitignored `.env`
  (EXPO_PUBLIC_COMETCHAT_* — deny-listed from direct reads; verify via
  `node scripts/smoke-cometchat.mjs`). CLI state: `.cometchat/config.json`
  (gitignored). Pre-seeded test users cometchat-uid-1..5.

## Conventions and constraints

- Auth gate is non-negotiable: no chat screen is reachable unsigned-in.
- CometChat credentials (app ID, region, auth key) are secrets — gitignored env
  files only; provisioning/keys handling is a HARD gate (owner approval).
- Session branches `session/YYYY-MM-DD-<slug>`; PRs to this project's own
  remote; owner merges personally.

## Pointers

- Last session: see `last-session.md`
- Reports: `.orchestrator/reports/` (sessions, tasks, gates)
- Patterns: `.orchestrator/patterns/`
