# Session plan — studio-suite — Session 02 — Web: Babel-standalone → Vite + React + TS

<!-- Authored 2026-07-24 at the close of Session 01, from the roadmap entry for S02
     (00-ROADMAP-first-sessions.md) plus what S01 actually built. If this session runs
     on a LATER date, re-date this file (or session-goals.sh --create) so
     project-bootstrap auto-selects it for that day. -->

**Task framing (per Kingdom law):** ONE discrete, individually completable task —
move `apps/web` off the zero-build prototype onto the real Vite + React + TS build
with **feature parity**. Migration only: no new product scope, no design changes.

## Starting state (what S01 left)

- Vite + React + TS skeleton is **live but isolated** at `apps/web/app/`
  (`vite.config.ts` has `root: "app"`; `tsconfig.json` `include: ["app"]`). It renders
  only a token probe — not the product UI.
- The working app is still the **Babel-standalone prototype** at `apps/web/index.html`,
  loading `src/**/*.jsx` via `<script type="text/babel">` from a unpkg CDN, sharing state
  through `window.*`. Styles: `src/styles/styles.css`, `src/styles/ds-styles.css`.
  Root component: `src/features/auth/app.jsx`. Tweak defaults + the interaction lock are
  **inline scripts in `index.html`**.
- Toolchain: Node 22 (`nvm use 22`), pnpm 11. `pnpm -r typecheck` is green; keep it green.

## Decision to make FIRST (blocks everything else)

**Reconcile the directory layout.** The Vite root (`apps/web/app/`) and the prototype
sources (`apps/web/src/`) are currently siblings. Pick one and record it in `SESSION.md`:
- **(A) Move sources under the Vite root** — migrate `src/**` → `app/src/**` as `.tsx`.
  Cleanest end state; the prototype `index.html` keeps working off the old tree until retired.
- **(B) Repoint Vite root to `apps/web/`** — set `root: "."` and give the Vite entry a
  non-colliding html (prototype owns `index.html`), migrating `src/**` in place.
  Less file churn; two html entries coexist longer.
Recommendation: **(B) while migrating** (smaller diffs, easy parity diffing against the
prototype), then collapse to a single `index.html` when the prototype is retired.

## Goals (ordered)

1. **Layout decision + Vite/tsconfig wiring** per above; `pnpm --filter @illuminate/web dev`
   still serves and `typecheck` still passes after the re-wire.
2. **Foundation modules.** Port the prototype's non-feature scaffolding into the Vite app:
   `src/styles/*.css` imported from the entry; `window.TWEAK_DEFAULTS` → a real typed
   module; the **interaction lock** (contextmenu / selectstart / dragstart handlers) → a
   real module invoked at startup. Behaviour must be identical.
3. **Shared layer to real modules.** `src/data/data.jsx` and `src/components/*.jsx`
   (`components.jsx`, `tweaks-panel.jsx`) → typed `.tsx` with real `export`/`import`.
4. **Migrate feature domains one at a time**, each compiling under TS with real imports
   and no `window.*` cross-module reads: marketing, auth, client-portal, admin, documents,
   questionnaires, finance, luma. (Suggested order: auth/app shell → marketing →
   client-portal → documents → questionnaires → admin → finance → luma.)
5. **App shell / routing.** `features/auth/app.jsx` becomes the real root rendered by the
   Vite entry, so the full experience runs under Vite.
6. **Parity + regression verification.** All eight surfaces reachable and visually
   unchanged vs the prototype baseline; `pnpm -r typecheck` clean; `vite build` succeeds.
   Confirm the 8 already-resolved cross-platform token conflicts still hold.
7. **Record + promote.** Session report; task→session memory; note whether the prototype
   is ready for retirement (owner decision — do NOT delete it unilaterally).

## Success criteria

- `pnpm --filter @illuminate/web dev` serves the **full app** (not the token probe), all
  eight surfaces reachable.
- `pnpm --filter @illuminate/web build` succeeds; `pnpm -r typecheck` green across all
  three packages.
- **No `window.*` cross-module state sharing** remains in migrated code.
- Feature parity vs the prototype — no visual regressions, no missing surfaces.
- Interaction lock still active app-wide; Image Representation & Content Policy copy
  untouched and intact.
- The Babel-standalone prototype still opens and works (until the owner approves retirement).

## Constraints

- **Migration only** — no new features/screens, no DS/token/visual changes. Preserve
  existing behaviour; no breaking changes without explicit approval.
- Web token discipline holds: values frozen at desktop width; responsiveness layered on
  top (the responsive gate itself is Session 03, not here). Two themes only; `darkAllowed`
  keeps Dark to gallery viewing.
- Do not touch `docs/`, `uploads/`, `scraps/` beyond reading. No build output committed.
- The embedded Luma key stays untouched (its removal is Session 05).
- Node 22 via `nvm use 22`; pnpm config lives in `pnpm-workspace.yaml`, not `.npmrc`.

## Gate notes

- **Success/go:** the success criteria above (parity + typecheck + build).
- **Self-check (Fable, PR-readiness only):** open the project PR first, then the self-check.
  NOTE: this gate was BLOCKED at the end of S01 (out of usage credits) — if still blocked,
  PR-readiness parks pending the owner.
- **HARD (owner):** none expected. Two items need an explicit owner call, not an
  assistant decision: (a) **retiring/deleting the prototype `index.html`**;
  (b) **Vite 5 → 6 upgrade** — a dependabot branch (`vite-6.4.3`) is open against
  studio-suite `main` and overlaps this session's surface area; decide before migrating.
- **Merges to `main` are the owner's**, always — the assistant never merges.
