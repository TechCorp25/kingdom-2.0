# Playbook — review & verify (v1-proven)

## Which review tool when

- `/code-review` — the current working diff, correctness-focused. Low/medium
  effort = fewer, high-confidence findings; high/max = broader, may include
  uncertain ones. `--comment` posts inline PR comments; `--fix` applies
  findings to the working tree.
- `/simplify` — quality-only pass (reuse / simplification / efficiency); it
  does NOT hunt bugs — use `/code-review` for correctness.
- `/security-review` (and the `security-review` skill's reference workflows) —
  required for security-adjacent work (auth, rate limiting, tokens, data
  handling) before the PR is declared ready.

## Verify — prove it works, don't trust the build

- Green build ≠ works. After a change, actually run it: execute the test
  suite, then exercise the real surface (start the app/server, hit the
  endpoint, render the screen — per the project's PROJECT.md validation
  commands).
- Prefer driving the running app to observe real behaviour over asserting
  success from logs or exit codes.
- For UI: render the actual screens (mobile + desktop, both themes where
  applicable) before calling it done.

## Gating order at a green close

lint → types → tests → (security pass if sensitive) → promote task memory →
PR opened/refreshed → gate-check (self-check = PR readiness) → hand to owner.
