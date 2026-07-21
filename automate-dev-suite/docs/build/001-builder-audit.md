# Build audit 001 — automate-dev-builder inventory

**Date:** 2026-07-21 · **Source:** `~/kingdom/projects/automate-dev-builder/` (785 files)
Port/rebuild decisions for the v2 suite. The builder directory is reference-only
and is retired once the build completes.

## Inventory and decisions

### `.agents/` — 525 files, 6.3 MB
Fork of the wshobson/agents plugin marketplace (72 plugins / 112 agents /
146 skills) **plus** the in-house generation:

| Component | Verdict | Notes |
|---|---|---|
| `automate-dev/` plugin (code-explorer / code-architect / code-reviewer agents, agent-teams, references: quality-gates, iteration-protocols, token-budgeting, workflow-phases; orchestration scripts) | **PORT** | Proven daily in old kingdom (`.claude/skills/automate-dev`). Port the current kingdom copy (newest wiring), not the plugin fork. |
| `conductor/` (context-driven development, track templates: spec/plan/metadata, style guides) | **PORT (templates only)** | Track-plan/spec templates feed v2 session-goals and workflow templates. |
| `agent-orchestration/` (context-manager agent, multi-agent-optimize) | Cherry-pick ideas | Superseded by v2 four-tier memory + reporting. |
| Marketplace skill/plugin bulk (68+ skill dirs) | **SKIP** | Reference library. Cherry-pick individual skills on demand per project; never bulk-install (token cost, contamination risk). |

### `dev-automation-suite-main/` — 225 files
v1-era (Le Répertoire / MyLocalFoodie) prompt suite, 00–09 phase prompts +
ST-* task prompts + hooks.

| Component | Verdict | Notes |
|---|---|---|
| Hook concepts: session-start log, session-end summary, pre-compact orchestrator, subagent quality gate | **PORT (rewritten)** | Concepts proven; scripts are project-specific and chatty. v2 rewrites them lean (see DD-004 token rationale). |
| `Stop`-hook blanket quality passes (180 s timeouts) | **REBUILD as gates** | Known pain: slow, noisy, per-turn cost. v2 replaces with explicit gate checkpoints. |
| UserPromptSubmit AI prompt-linting | **SKIP** | Adds a model call to every prompt; poor cost/benefit for a single owner-operator. |
| Token-budget discipline (TOKEN-BUDGET-GUIDE, per-phase budgets, slice rule) | **PORT (as policy)** | Distilled into DD-004 + workflow token-cost sections. |
| 00–09 phase prompts, ST-* prompts | Cherry-pick | Structure informs v2 workflow docs; content too project-specific. |

### `claude-tools/` — 19 files
Security skill pack: threat-model, security-scan, deep-scan, diff-scan,
finding discovery/triage/fix/validation/writeup, hardening proposals, tracking.
**Verdict: PORT nearly wholesale** into the v2 security workflow + skills.
`personal-preferences.md`: fold into root CLAUDE.md working rules.

### `official-documentation/` — 10 files
Anthropic references (memory & context management, compaction, permissions,
skill authoring, multi-agent orchestration). **Verdict: KEEP as reference**;
cited by DD-002/DD-004. Not copied into the suite.

### `dev-session-root/` — 4 files
| Component | Verdict | Notes |
|---|---|---|
| `session-start.sh` (terse operating-contract injection) | **PORT** | Proven pattern; v2 version also injects bootstrap status + project menu. |
| `kingdom-CLAUDE.md` (v1: uv/FastAPI/Postgres/MCP control plane) | **SUPERSEDED** | v2 locked decision: pure file-based state. No DB, no MCP server. |
| `continuation-baseline.template`, `env.example` | **PORT** | Feed handover workflow + env template. |

### Old kingdom `.claude/skills/` (live, outside builder dir)
Proven current generation: `automate-dev`, `code-quality`, `handover`,
`codebase-review`, `skill-creator`, `use-expo`, `frontend-design`.
**Verdict: PORT** (automate-dev, code-quality, handover, use-expo for the
pilot) with paths rewired to v2. Others on demand.

## Key empirical findings feeding design

1. Git cannot track files inside nested project repos → symlinked state
   inversion (DD-001).
2. v1 MCP control plane had intermittent machine-local failures → locked
   file-based architecture (build prompt §2).
3. Blanket Stop/UserPromptSubmit model-call hooks were the main v1 token/latency
   sink → v2 uses explicit gates + lean command hooks only (DD-004).
