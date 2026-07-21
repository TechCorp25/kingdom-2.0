# Policy — stack & data boundaries

The kingdom governs multiple projects with **different stacks**. Never
cross-pollinate them, and never mix kingdom control-plane state with project
business data.

## Stacks are separate — use the right one per project

Each project's authoritative stack lives in its own Tier-2 memory
(`state/{p}/memory/project/PROJECT.md`). Never import a pattern, framework, or
dependency choice from one project into another because it "worked there."

v1 lineage worth remembering (reference; per-project memory wins):

| Project | Stack |
|---|---|
| **CivicMAPS / pin-force** | Node/Express + **PostgreSQL** · Node 22 required |
| **IlluminateMyGallery** | FastAPI + Vite/React 19 + Tailwind/shadcn · MongoDB Atlas + Cloudflare R2 · Railway |
| **Le Répertoire** | **Flask** + **MongoDB/MongoEngine** |

The costly v1 confusion this table killed: Flask/Mongo belongs to
Le Répertoire, Node/Express to CivicMAPS — assistants repeatedly assumed one
project's stack in another's code.

## Data boundary

- The kingdom holds **control-plane state only** (memory, reports, patterns,
  permissions, registry, gates). Project business data never lands in the
  kingdom tree, and kingdom state never lands in a project repo — this is the
  DD-001 boundary, hook-enforced from both sides.
- Project source lives under `projects/{p}/` (wholly ignored by the kingdom
  repo) and syncs only to that project's own remote.

## Hierarchy of rules

Root `CLAUDE.md` applies everywhere under the kingdom; a project's own
project-scoped settings/memory (via the state symlinks) refine — never
contradict — the root contract.
