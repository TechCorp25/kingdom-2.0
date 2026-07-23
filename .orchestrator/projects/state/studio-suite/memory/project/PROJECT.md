# studio-suite — project memory (Tier 2)

Durable facts only. This file is read at every project bootstrap — keep it
small and current; move history to reports.

## What this project is

**Studio Suite** is the shared design system **and** application platform for
**Illuminate Studios**, a boutique editorial photography studio. One cross-platform
token system feeds a suite of product surfaces that run the studio's complete client
lifecycle — **Discover** (public marketing site) → **Enquire** (Luma AI concierge) →
**Book** → **Onboard** (intake questionnaires) → **Serve** (role-gated client portal:
galleries, contracts/e-sign, documents) → **Operate** (admin back office: CRM,
bookings, Documents Center, finance with hash-chained audit trail). Three auth
personas: public visitor, assigned client, studio admin.

## Durable facts

- **Remote:** https://github.com/TechCorp25/studio-suite.git (private, TechCorp25)
- **Stack:** full-stack **pnpm-workspace monorepo** — `packages/tokens`
  (`@illuminate/tokens`, the cross-platform TS source of truth: `tokens.ts` +
  `illuminate-design-spec.json`) → `apps/web` (React) + `apps/mobile` (Expo React Native).
- **Toolchain (baselined Session 01):** Node **22.22.1** via nvm (`.nvmrc`=22; machine
  default is v24, so `nvm use 22` each session). **pnpm 11** (corepack, `packageManager`
  pinned). Config lives in `pnpm-workspace.yaml` (NOT `.npmrc` — pnpm 11 ignores it):
  `nodeLinker: hoisted` (RN/Metro needs flat node_modules), `allowBuilds: esbuild`,
  `supportedArchitectures: current`. Apps depend on tokens via **`workspace:*`**. Scripts:
  root `pnpm typecheck` (`-r`), `pnpm web`, `pnpm mobile`; each pkg has `typecheck`.
- **Web build state:** **two entrypoints coexist.** (a) The zero-build **Babel-standalone
  prototype** stays at `apps/web/index.html` (multi-file `src/**/*.jsx` via `window.*`) —
  still the working app. (b) A real **Vite + React + TS skeleton** now lives isolated at
  `apps/web/app/` (`root: "app"` in `vite.config.ts`; imports `@illuminate/tokens`).
  Session 02 migrates `src/features/*.jsx` (`window.*` → real imports) into the Vite app.
- **Mobile build state:** Expo RN app **boots** — `metro.config.js` wires the monorepo
  (watchFolders = workspace root); `expo export` bundles the full graph consuming the
  shared theme via `ThemeProvider`/`useTokens`. Feature screens, navigation, font loading
  still to build.
- **Design language:** "editorial luxury" — brass gold + navy ink on cool off-white
  (Light = default UI); cinematic black/cream/gold "lights-out" Dark **reserved** for
  gallery viewing only, gated by `darkAllowed`. Gold is the only brand accent
  (per-theme ramps, never one shared ramp). Fonts: Cinzel (display) · Cormorant
  Garamond (editorial) · Inter (UI) · JetBrains Mono (IDs). Max 3 families/page.
- **Seed:** v2.0 prototype imported 2026-07-23 (137-file monorepo + docs + policy/legal
  `uploads/`). Full definition: `docs/Studio-Suite_Project-Definition.md`; build history:
  `docs/HANDOFF.md`, `docs/CHECKPOINT.md`.

## Conventions and constraints

- **Universal Responsive standard is a LOAD-BEARING acceptance gate** on BOTH web and
  native equally (`docs/Studio-Suite_Universal-Responsive-Design-Requirements.md` +
  `-Viewport-Matrix.md`). Small-end gate = **375pt portrait, hard pass/fail**; zero
  dead-zones across the continuous range + both orientations; 44×44pt / 48×48dp tap
  targets. Native is mobile-first, runtime-geometry driven (`useWindowDimensions`),
  never device-ID branching. Web & native must be **exact replicas** in features,
  function, and styling.
- **Image Representation & Content Policy (binding on all copy + Luma output):** never
  imply client images are edited / retouched / enhanced. Forbidden-term list + approved
  swaps ("edited gallery" → "selected gallery") encoded in the spec and in
  `uploads/*POLICY*.md` / `uploads/*RESPONSE_VALIDATION*`.
- **Interaction lock:** right-click / long-press, text selection, and image drag are
  disabled app-wide (inputs exempt) to protect client imagery.
- **Web token discipline:** token values are frozen at desktop width; responsiveness is
  layered on top and never overrides a desktop value. Two themes only.
- **SECURITY debt (must-fix before non-dev use):** the OpenAI/Luma key is currently
  embedded in client-side JS and publicly visible — move behind a server proxy with a
  server-side env key and **rotate**. Any key handling is a HARD gate (owner-approved).

## Pointers

- Definition & scope: `docs/Studio-Suite_Project-Definition.md`, `docs/*HANDOFF*`, `docs/CHECKPOINT.md`
- Policy / legal / questionnaire source: `uploads/`
- Design source of truth: `packages/tokens/` (`tokens.ts`, `illuminate-design-spec.json`)
- Last session: see `last-session.md`
- Reports: `.orchestrator/reports/` (sessions, tasks, gates) · Patterns: `.orchestrator/patterns/`
