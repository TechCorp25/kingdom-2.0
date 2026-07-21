# Policy — secrets & configuration

- **Configuration via environment variables only** (`.env`, gitignored). No
  secrets in code, ever. `.env.example` is the committed contract
  (placeholders); real values live only in `.env`.
- **Never commit** `.env`, credentials, tokens, keys, data dumps, or backups.
- **Never put a secret in** a commit message, PR title/body, code comment,
  memory file, report, session archive, or any pushed artifact — both repo
  layers are equally forbidden. Continuity docs state explicitly: "secrets are
  never in this document."
- Before any push, confirm nothing sensitive is staged:
  `git diff --cached --name-only` and check for `.env` / key material. (The
  project pre-commit boundary hook backstops this; the check is still yours.)
- Generate strong values:
  `python3 -c "import secrets; print(secrets.token_hex(32))"`.
- Bind any local service (API, DB, dev server) to **localhost only** — never
  expose it publicly.
- Persist tokens **hashed** (SHA-256 / HMAC / bcrypt per use); raw values are
  never stored (v1 IlluminateMyGallery auth model — it held up).
- Keys are requested from the owner at **point of use** (hard gate), used,
  and never echoed back into any tracked file or log.
