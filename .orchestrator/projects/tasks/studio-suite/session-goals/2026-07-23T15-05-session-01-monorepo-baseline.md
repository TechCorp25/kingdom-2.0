# Session plan — studio-suite — Session 01 — Monorepo & toolchain baseline

<!-- Authored 2026-07-23 during the studio-suite prep session. This is the
     pre-defined plan for the FIRST real build session. When that session runs:
     if it is a later date, re-date this file (or session-goals.sh --create) so
     project-bootstrap auto-selects it for that day. See 00-ROADMAP-first-sessions.md. -->

**Task framing (per Kingdom law):** this session is ONE discrete, individually
completable task — stand up the real monorepo build so both apps compile and
consume the shared tokens. No product/feature work; foundation only.

## Goals (ordered)

1. **Pin the toolchain.** Add Node version pin (`.nvmrc` = 22) and confirm
   `node -v` / `npm -v`; document the exact versions in the session report.
2. **Workspace wiring.** Introduce the monorepo workspace manager (pnpm
   workspaces — root `package.json` `workspaces` + `pnpm-workspace.yaml`) covering
   `packages/*` and `apps/*`; `pnpm install` completes clean from the repo root.
3. **Tokens package is buildable/consumable.** `packages/tokens` (`@illuminate/tokens`)
   exposes `tokens.ts` via its barrel and typechecks under `tsc --noEmit`; verify it
   can be imported by both apps (no build errors from the token entrypoint).
4. **Web: Vite + React + TS skeleton stands up** alongside the existing Babel-standalone
   prototype (do NOT delete the prototype). `apps/web` gets `vite`, `react`,
   `typescript`, tsconfig, and a minimal `main.tsx` that imports `@illuminate/tokens`
   and renders. `pnpm --filter @illuminate/web dev` serves without error. Feature
   migration is Session 02 — this is only the skeleton + one token-consuming render.
5. **Mobile: Expo scaffold boots** and consumes the shared tokens. `apps/mobile`
   `expo start` launches; the ThemeProvider/`useTokens` resolves against
   `@illuminate/tokens` (fix any workspace-resolution issue). No new screens.
6. **Record the baseline.** Session report notes: versions, what runs, and any
   deferred items. Promote task→session memory on completion.

## Success criteria

- `pnpm install` succeeds from repo root with the workspace graph resolved.
- `@illuminate/tokens` typechecks and is importable by web and mobile without error.
- `apps/web` Vite dev server serves a page that renders a value from the tokens.
- `apps/mobile` Expo dev server boots and reads the shared theme.
- The Babel-standalone prototype (`apps/web/index.html`) still opens and works.
- All green states captured in the session report; task memory promoted.

## Constraints

- **Foundation only** — NO feature migration, NO new product screens, NO visual/DS
  changes. Preserve the existing prototype behaviour (no breaking changes).
- Do not touch `docs/`, `uploads/`, or `scraps/` content beyond reading.
- Do not commit build output (`dist/`, `node_modules/`) — boundary `.gitignore` holds.
- No secrets in either repo layer; the embedded Luma key stays untouched this session
  (its removal is Session 05).
- Production-ready config only — no placeholder stubs left behind.

## Gate notes

- **Success/go:** the six success criteria above are this session's go-gate.
- **Self-check (Fable, PR-readiness only):** opening the project PR for the monorepo
  baseline → open PR first, then Fable self-check within envelope. NOTE: Fable
  self-check is currently BLOCKED (out of usage credits, per NEXT-SESSION.md) — if
  still blocked, PR-readiness parks pending the owner.
- **HARD (owner):** none expected this session. (EAS builds / signing keys / the Luma
  key-rotation are later and are HARD — not in scope here.)
- **Merges to main are the owner's**, always — assistant never merges.
