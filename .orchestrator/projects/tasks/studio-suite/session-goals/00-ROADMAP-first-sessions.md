# studio-suite — First-sessions roadmap

Authored 2026-07-23 (prep session). A **proposed** ordered plan for the first
build sessions. Each session is framed as ONE discrete, individually completable
task per Kingdom law (task-tier working memory, promoted task→session on
completion, session→project at close). The owner may reprioritise the order at any
session start — this is a starting map, not a contract.

**Where the project stands at Session 01:** web app exists as a zero-build
React + Babel-standalone prototype (feature-complete surfaces, `window.*` state
sharing); mobile is an Expo scaffold (tokens + theme wired, no screens); the
`packages/tokens` design source-of-truth exists. The **Universal Responsive
standard** (`docs/Studio-Suite_Universal-Responsive-*.md`) is a load-bearing
acceptance gate on both surfaces.

**Sequencing rationale:** foundation first (S01), then bring the furthest-along
surface (web) onto its real build and gate it responsively (S02–S03), then grow
the native surface the standard names as the primary long-term touchpoint
(S04+), then close the known security debt (S05). If the owner wants
**mobile-first** ordering (the responsive doc's stated design priority), swap the
web/native emphasis of S02–S04 — the S01 foundation serves either order.

---

## Session 01 — Monorepo & toolchain baseline
- **Objective:** real monorepo build; both apps compile and consume `@illuminate/tokens`.
- **Deliverable/acceptance:** `pnpm install` clean; tokens typecheck + importable;
  web Vite skeleton + mobile Expo both boot on shared tokens; prototype still works.
- **Gates:** success/go (build green). PR-readiness self-check (Fable — may be parked).
- **Detail:** `2026-07-23T15-05-session-01-monorepo-baseline.md`.

## Session 02 — Web: Babel-standalone → Vite + React + TS migration
- **Objective:** migrate `apps/web` off the prototype onto the Vite+TS target;
  convert `window.*` state sharing to real `import`/`export`; `features/*` compile
  under TS. Verify the 8 already-resolved cross-platform token conflicts hold.
- **Deliverable/acceptance:** web app runs under Vite with **feature parity** to the
  prototype (all surfaces: marketing, auth, client-portal, admin, documents,
  questionnaires, finance, luma); typecheck clean; no visual regressions vs baseline.
- **Gates:** success/go (parity + typecheck). PR-readiness self-check.

## Session 03 — Universal Responsive gate: web harness + CI matrix
- **Objective:** operationalise the responsive standard on web — Playwright viewport
  matrix (per `-Viewport-Matrix.md`), zero-horizontal-overflow gate across the
  continuous range, 375px small-end hard pass/fail; fix surfaced dead-zones.
- **Deliverable/acceptance:** Playwright suite green across the matrix; small-end +
  both orientations pass; 44×44 tap targets verified. This gate becomes standing CI.
- **Gates:** success/go (responsive acceptance gate = load-bearing). PR-readiness self-check.

## Session 04 — Mobile: first vertical slice (Expo RN feature screens)
- **Objective:** build the first native surfaces beyond scaffold — auth + client-portal
  gallery — mirroring web 1:1, runtime-geometry responsive per the native matrix
  (`useWindowDimensions`, `react-native-safe-area-context`, orientation, keyboard).
- **Deliverable/acceptance:** the slice renders on the native device-class matrix incl.
  small-end 375pt portrait/landscape + a tablet split-view case; no clipped/unreachable
  content; font-scale axis checked.
- **Gates:** success/go (native responsive matrix for the slice). PR-readiness self-check.
- **Note:** any EAS build / device signing = **HARD gate (owner)** — keys + credits.

## Session 05 — Luma security: server proxy + key rotation
- **Objective:** close the known security debt — move the OpenAI/Luma call behind a
  server-side proxy with a server env key; **rotate** the currently-embedded client
  key; keep the policy validator + forbidden-term + booking-state guards intact.
- **Deliverable/acceptance:** no secret in client JS; proxy enforces the content policy;
  old key rotated/revoked; Luma still functions behind the proxy.
- **Gates:** **HARD (owner)** — key handling/rotation is owner-approved, non-bypassable.
  Secrets only in gitignored env files.

---

## Cross-cutting, every session
- Fresh per-session branch → PR on the **project** repo; kingdom-side changes → PR on
  the **kingdom** repo. **The assistant never merges to main** — the owner reviews and
  squash-merges; the report-back triggers session close.
- Binding product constraints carried in `PROJECT.md`: Image Representation & Content
  Policy (never imply images edited/retouched), interaction lock, two-theme +
  `darkAllowed` discipline, web token-freeze-at-desktop rule.
- Promote task→session memory on each task's completion; session→project at close.
