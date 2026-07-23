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
- **Stack:** full-stack **monorepo** — `packages/tokens` (`@illuminate/tokens`, the
  cross-platform TS source of truth: `tokens.ts` + `illuminate-design-spec.json`) →
  `apps/web` (React) + `apps/mobile` (Expo React Native). Node 22 (via nvm), like the
  suite's other RN work.
- **Web build state:** currently a **zero-build React + Babel-standalone prototype**
  (open `apps/web/index.html` directly; multi-file JSX sharing state via `window.*`).
  Target is **Vite + React + TS** — `src/features/*` already matches that layout, so
  migration is mechanical (`window.*` → real `import`/`export`).
- **Mobile build state:** Expo RN app is **scaffolded only** — shared tokens + theme
  provider (`useTokens`) wired; feature screens, navigation, font loading still to build.
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
