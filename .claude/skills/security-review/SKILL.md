---
name: security-review
description: Run Kingdom security work — diff scans on PRs, deep scans, threat models, dependency audits, and the finding lifecycle (discover, triage, fix, validate, track). Use for any security review, vulnerability question, secret-hygiene check, or when the security workflow's cadence table says a scan is due.
---

# Security review

Cadence and gate classes: `automate-dev-suite/workflows/security.md`
(diff scan on every code PR; high/critical findings are HARD gates on
release-bound work). Findings land in `state/{p}/reports/gates/security-{ts}.md`.

Proven v1 playbooks (ported wholesale — use the one matching the job):

| Job | Reference |
|---|---|
| PR / changed-code scan | `references/security-diff-scan.md` |
| Fast whole-surface scan | `references/security-scan.md` |
| Deep scan (auth, uploads, external APIs) | `references/deep-security-scan.md` |
| Threat model new surface | `references/threat-model.md` |
| Attack-path analysis | `references/attack-path-anylisis.md` |
| Finding lifecycle | `references/finding-discovery.md` → `triage-finding.md` → `fix-finding.md` → `validation.md` → `track-findings.md` |
| Written report | `references/vulnerability-writeup.md` |
| Hardening proposals | `references/propose-security-hardening.md` |

Read only the reference the job needs — they are playbooks, not required reading.
