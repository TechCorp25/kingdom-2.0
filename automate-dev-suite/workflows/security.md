# Workflow — security (review · dependencies · secret hygiene)

**Gate class:** findings rated high/critical are hard stops on release-bound
work; fixes ride normal PRs. Ported from the proven v1 security pack
(builder `claude-tools/skills/security/` — see build audit 001).

## Cadence

| Check | When |
|---|---|
| Diff scan (changed code only) | every PR with code changes |
| Secret hygiene (`.env`/keys staged, tokens in code) | every commit (boundary pre-commit blocks the common cases) |
| Dependency/package audit (`npm audit`, `pip-audit`, lockfile currency) | project bootstrap when lockfiles changed; monthly otherwise |
| Deep scan / threat model | new attack surface (auth, uploads, external APIs) or on request |

## Steps (diff scan — the default)

1. Scope: the PR diff + directly-called code, nothing more.
2. Hunt: injection, authz gaps, secret exposure, unsafe deserialization,
   path traversal, SSRF — against the changed surface only.
3. Findings → `state/{p}/reports/gates/security-{ts}.md` (severity, path:line,
   scenario, fix). High/critical → gate record + fix before merge.
4. Verified-fixed findings get a validation note in the same report.

## Token rationale

Diff-scoped by default; deep scans are explicit, bounded events. Findings are
files, referenced by pointer — a security history that survives sessions for
free.
