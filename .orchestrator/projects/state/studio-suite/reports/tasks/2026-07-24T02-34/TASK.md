# Task — Session 01: monorepo & toolchain baseline — 2026-07-23

Tier 4. Working state for the CURRENT task only. Park bulk material (search
results, long outputs, drafts) as files beside this one and reference by path.

## Objective

Stand up the real monorepo build so both apps compile and consume the shared
`@illuminate/tokens`. Foundation only — no product/feature work.

## Working state

- Complete. All six goals verified (see report).

## Scratch files

- `reports/sessions/2026-07-23T22-16-session.md` — full session report (versions,
  verifications, decisions, gotchas, deferrals).
- (session scratchpad) `env.sh` — Node-22 + pnpm prelude used per Bash call.

## Outcome

**Achieved:** Real pnpm-workspace monorepo baseline on Node 22.22.1 / pnpm 11.16.0.
All 6 goals met: (1) `.nvmrc`=22; (2) pnpm workspaces + clean `pnpm install`;
(3) `@illuminate/tokens` typechecks (`tsc --noEmit`) and is consumed by both apps;
(4) web Vite+React+TS skeleton at `apps/web/app/` (prototype at `apps/web/index.html`
left intact) — `vite build` + `vite dev` both render a token value; (5) Expo/Metro
bundles the mobile app consuming the shared theme (`expo export` → Hermes bundle
contains the full token system); (6) baseline recorded.

**Verified how:** `pnpm -r typecheck` green ×3; `pnpm --filter @illuminate/web build`
(brand-gold `#a8884f` in bundle) + `vite` dev server 200 with token module resolved;
`expo export --platform android` success + string-table inspection of the Hermes bundle.

**Key fixes:** `workspace:*` (pnpm 11 dropped implicit `*` linking); `nodeLinker:
hoisted` must live in `pnpm-workspace.yaml` not `.npmrc` (else Metro can't resolve
`@babel/runtime`); `allowBuilds: esbuild`; `supportedArchitectures: current`; and a
pre-existing runtime bug in `apps/mobile/src/theme/useTokens.ts` (`shadow("gold")`
would crash — narrowed the type).

**Follow-ups:** Session 02 = migrate prototype `src/features/*.jsx` into the Vite app.
Fable PR-readiness self-check parked (out of credits). Deprecated transitive subdeps
to revisit at next Expo SDK bump.
