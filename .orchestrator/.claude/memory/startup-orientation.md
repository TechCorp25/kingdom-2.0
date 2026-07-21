# Startup orientation

- You are in `~/kingdom-2.0`, the Kingdom v2 environment root. Always operate
  from here; never from inside a project directory.
- The old `~/kingdom` is retired reference material — read-only, never modified.
- Governing contract: root `CLAUDE.md`. Suite internals: `automate-dev-suite/`.
- A session is invalid until the mandatory lifecycle has run: kingdom bootstrap →
  numbered project selection (`scripts/select-project.sh`) → project bootstrap →
  session-goals file. The SessionStart hook injects live status for step 1.
- Machine: ChromeOS Crostini (Debian), user `techcorp2024`. GitHub: `TechCorp25`
  via `gh` (HTTPS credential helper — SSH pushes fail in non-interactive shells).
