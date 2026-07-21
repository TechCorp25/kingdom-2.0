# Policy — confidential & fragile areas

## General rules

- Don't commit confidential business material, contracts, client data, or
  legal drafts without explicit owner approval **and** a decision on the
  destination repo. Decide where confidential source docs live **before** any
  commit.
- Treat anything under a project's `docs/` that looks legal / financial /
  client-identifying as confidential until told otherwise.
- Don't silently change deployment config (service settings, `railway.toml`,
  `eas.json` profiles, DNS) — flag it to the owner.

## Fragile-path lesson (v1, IlluminateMyGallery)

A confidential contracts directory was named with a **trailing space**
(`docs/contracts `) — it broke globs, tab-completion, and scripts, and stayed
brittle for months because renaming it was never "the task at hand."
Lessons:

- Never create paths with leading/trailing whitespace or other shell-hostile
  characters; flag any you encounter immediately.
- Fix a fragile path only at a deliberate, safe point (dedicated commit, all
  references updated) — never casually mid-task.
