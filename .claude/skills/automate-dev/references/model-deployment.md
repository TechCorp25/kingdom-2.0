# Model Deployment Strategy — Opus 4.8 Optimised

## Table of Contents

1. [Model Family Overview](#model-family-overview)
2. [Difficulty Classification](#difficulty-classification)
3. [Model Routing Matrix](#model-routing-matrix)
4. [Effort Level Configuration](#effort-level-configuration)
5. [Migration from Opus 4.7](#migration-from-opus-47)
6. [Migration from Opus 4.6 and Earlier](#migration-from-opus-46-and-earlier)
7. [Prompt Adjustments for Opus 4.8](#prompt-adjustments-for-opus-48)

---

## Model Family Overview

The automate-dev skill is optimised for **Claude Opus 4.8** (`claude-opus-4-8`)
as the flagship model for high-difficulty workflows, while retaining Sonnet 4.6
for exploration and breadth-focused work.

| Model | API Identifier | Primary Use |
|-------|---------------|-------------|
| Claude Opus 4.8 | `claude-opus-4-8` | High-difficulty reasoning, review, assessment, architecture |
| Claude Opus 4.7 | `claude-opus-4-7` | Previous-generation Opus — pin only if 4.8 is unavailable |
| Claude Sonnet 4.6 | `claude-sonnet-4-6` | Exploration, tracing, breadth-focused work |
| Claude Haiku 4.5 | `claude-haiku-4-5` | Simple classification, routing, quick validation (not used in this skill by default) |

### Opus 4.8 Capabilities Leveraged

- **1M token context window** at standard API pricing — handles large codebases
- **128k max output tokens** — sufficient for comprehensive review reports
- **xhigh effort level** (default in Claude Code) — between `high` and `max`
- **Adaptive thinking** — automatic reasoning depth based on task complexity
- **Mid-session system prompts** (Opus 4.8 only, no beta header) — inject operator
  instructions mid-run without invalidating the prompt cache (see below)
- **Prompt caching** — reduces cost on repeated SKILL.md / reference / .CLAUDE.md loads
- **Task budgets (public beta)** — token-spend ceiling the model self-moderates against
- **High-resolution vision** — useful for UI review with screenshots

### Opus 4.8 Pricing (as of release)

- Input: $5 per million tokens
- Output: $25 per million tokens
- Unchanged from Opus 4.7 and 4.6
- Tokenizer: Opus 4.8 shares the Opus 4.7 tokenizer (the one introduced with 4.7,
  which produces 1.0–1.35× more tokens than the older 4.6 tokenizer for the same
  text). Token counts are **unchanged** when migrating from Opus 4.7 — re-benchmark
  only if you are coming from Opus 4.6 or earlier.

### Mid-Session System Prompts (Opus 4.8)

Opus 4.8 accepts `{"role": "system", ...}` entries appended to the `messages`
array — operator instructions delivered partway through a session without editing
the top-level system prompt (which would invalidate the cached prefix). Use it for
context the workflow learns mid-run: a mode toggle, a revised constraint, an
updated budget, or async context from the user. Phrase these as context, not
override commands. No beta header is required; this is Opus 4.8 only — on older
models, fall back to a `<system-reminder>` block inside a user turn.

---

## Difficulty Classification

Every workflow task is classified by difficulty. The classification determines
model selection and effort level.

### Classification Criteria

| Level | Characteristics | Model | Effort |
|-------|----------------|-------|--------|
| **low** | Single-file reads, obvious fixes, simple lookups, formatting | sonnet | default |
| **medium** | Multi-file changes with clear scope, routine refactors, tracing | sonnet | `high` |
| **high** | Code review, architectural decisions, self-assessment, quality gates | **claude-opus-4-8** | `xhigh` |
| **xhigh** | Complex multi-file refactoring, subtle debugging, security review | **claude-opus-4-8** | `xhigh` |
| **max** | Formal verification, algorithmic proofs, cryptographic review | **claude-opus-4-8** | `max` |

### Examples by Phase

| Phase | Task | Classification | Model |
|-------|------|---------------|-------|
| 1 (Analyse) | Codebase exploration | medium | sonnet |
| 1 (Analyse) | Dependency mapping | medium | sonnet |
| 2 (Build) | Routine implementation | medium | sonnet |
| 2 (Build) | Architectural design | high | **opus-4-8** |
| 3 (Review) | Quality review (simplicity) | high | **opus-4-8** |
| 3 (Review) | Functional correctness review | high | **opus-4-8** |
| 3 (Review) | Conventions review | high | **opus-4-8** |
| 4 (Test) | Test execution | low-medium | sonnet |
| 5 (Fix) | Root cause analysis for complex bugs | high | **opus-4-8** |
| 5 (Fix) | Straightforward bug fixes | medium | sonnet |
| 6 (Simplify) | Refactoring analysis | high | **opus-4-8** |
| 7 (Validate) | Final quality gate assessment | high | **opus-4-8** |
| 7 (Validate) | Self-review of agent outputs | high | **opus-4-8** |
| 8 (Ship) | Deployment readiness check | medium | sonnet |

### Self-Review Always Uses Opus 4.8

Any workflow step involving **review of agent output** by another agent
must use Opus 4.8. This includes:

- Reviewing code written by subagents
- Validating architectural decisions produced by code-architect
- Assessing exploration output from code-explorer for gaps
- Final validation before ship
- Band-aid pattern detection in AI-generated fixes

---

## Model Routing Matrix

### Agent Configuration

| Agent | Model | Effort | Difficulty Bucket |
|-------|-------|--------|-------------------|
| code-explorer | `sonnet` | `high` | medium |
| code-architect | `claude-opus-4-8` | `xhigh` | high |
| code-reviewer | `claude-opus-4-8` | `xhigh` | high+ |
| team-lead | `claude-opus-4-8` | `xhigh` | high |
| team-implementer | `claude-opus-4-8` | `xhigh` | high |
| team-reviewer | `claude-opus-4-8` | `xhigh` | high+ |
| team-debugger | `claude-opus-4-8` | `xhigh` | high+ |

### Phase Routing

```
Phase 1 (Analyse):
  ├─ code-explorer × 2-3   → sonnet (parallel exploration)
  └─ dev_orchestrator.py   → script (rule-based inventory)

Phase 2 (Build):
  ├─ code-architect × 2-3  → claude-opus-4-8 xhigh (parallel design)
  └─ Implementation        → Main agent (varies by task difficulty)

Phase 3 (Review):
  ├─ code-reviewer × 3     → claude-opus-4-8 xhigh (parallel review)
  ├─ code_reviewer.py      → script (band-aid + security detection)
  └─ fix_validator.py      → script (preservation + breaking changes)

Phase 5 (Fix):
  ├─ Root cause analysis   → claude-opus-4-8 xhigh (complex bugs)
  └─ fix_validator.py      → script (band-aid detection in diffs)

Phase 6 (Simplify):
  ├─ Simplification review → claude-opus-4-8 xhigh (judgment)
  └─ code_simplifier.py    → script (structural analysis)

Phase 7 (Validate):
  ├─ code-reviewer × 3     → claude-opus-4-8 xhigh (final review)
  └─ dev_orchestrator.py   → script (full gate check)
```

---

## Effort Level Configuration

Opus 4.8 supports `xhigh` as an effort level between `high` and `max`.
Choose effort based on task complexity:

| Effort | Use For | Latency Impact | Cost Impact |
|--------|---------|---------------|-------------|
| `default` | Simple tasks, quick validation | Low | Low |
| `high` | Most coding tasks, routine review | Moderate | Moderate |
| `xhigh` | **Default for automate-dev agents** — architectural decisions, complex debugging, deep review | High | Higher |
| `max` | Cryptographic review, formal proofs, security audits | Very high | Highest |

### Treat Effort as a Per-Task Dial (Opus 4.8)

On Opus 4.8, effort matters more than on prior Opus models and the relationship
to cost/quality is not monotonic — higher effort up front often *reduces* total
turn count and cost on agentic work, while some routine tasks reach the same
result at `high` or `medium` in less time. `xhigh` remains the right default for
the coding and agentic work this skill performs, but sweep `high`/`medium` on
latency- or cost-sensitive steps and pick per route from your own eval set.
Reserve `max` for genuinely hardest, latency-insensitive cases.

### Setting Effort in Claude Code

```bash
# Session-level
/effort xhigh

# Per-command (if supported)
/model claude-opus-4-8 --effort xhigh

# Environment variable
export ANTHROPIC_DEFAULT_EFFORT=xhigh
```

### Setting Effort via Agent Frontmatter

```yaml
---
name: code-reviewer
model: claude-opus-4-8
effort: xhigh
---
```

---

## Migration from Opus 4.7

Opus 4.8 keeps the **same request surface** as Opus 4.7 — there are no new
breaking changes. Adaptive thinking remains the only thinking mode
(`thinking: {type: "adaptive"}`; `budget_tokens` still 400s), sampling
parameters (`temperature`, `top_p`, `top_k`) are still rejected, last-assistant
prefills still 400, and `thinking.display` still defaults to `omitted`. Moving a
4.7 deployment to 4.8 is therefore a **model-ID swap plus light prompt
re-tuning**.

### Required Changes

1. **Pin the new identifier**: Replace `claude-opus-4-7` with `claude-opus-4-8`
   in agent frontmatter, scripts, and any pinned API calls.
2. **No tokenizer change**: Opus 4.8 shares the 4.7 tokenizer — token budgets and
   `max_tokens` settings carry over unchanged. (Cache keys still change because the
   model string changed — the first call on 4.8 writes the cache fresh.)

### Behavioural Re-Tuning (Optional but Recommended)

These are prompt-level tweaks, not API requirements — see
[Prompt Adjustments for Opus 4.8](#prompt-adjustments-for-opus-48) for the
full set. The headline shifts versus 4.7:

- **More narration by default** — 4.8 writes more between tool calls and longer
  wrap-ups. Remove any "summarise after every N tool calls" scaffolding; add a
  silence-default if a coding agent is too chatty.
- **Warmer, less hedged voice** — roughly the opposite of 4.7's clipped style.
  Re-evaluate any style prompts you added to counter 4.7's directness.
- **More deliberate — asks more often** — grant autonomy on small, reversible
  decisions while keeping caution on scope changes and destructive actions.
- **More conservative tool/subagent reach** — instruct subagent, search, and
  memory use explicitly; prescriptive "call this when…" tool descriptions help.

---

## Migration from Opus 4.6 and Earlier

If transitioning from an earlier automate-dev deployment using Opus 4.6 or
the `opus` alias, apply these changes (then the 4.7→4.8 re-tuning above):

### Required Changes

1. **Pin model identifier**: Replace `opus` with `claude-opus-4-8` in agent
   frontmatter to avoid alias drift
2. **Add effort level**: Set `effort: xhigh` for code-architect and code-reviewer
3. **Switch to adaptive thinking**: `thinking: {type: "enabled", budget_tokens: N}`
   returns 400 on Opus 4.7/4.8 — use `thinking: {type: "adaptive"}` and control
   depth with `effort`
4. **Remove sampling parameters**: Opus 4.7/4.8 return 400 errors for non-default
   `temperature`, `top_p`, `top_k` — remove these from any API calls
5. **Re-benchmark token budgets**: The 4.7/4.8 tokenizer produces 1.0–1.35× more
   tokens than 4.6 — increase `max_tokens` by at least 35% headroom
6. **Update prompt caching keys**: Different tokenization means different
   cache keys for previously cached content

### Behavioural Changes to Expect

Opus 4.7/4.8 follow instructions more literally than 4.6. If your prompts
relied on inference or loose interpretation:

- **Before (4.6)**: "Review the code for issues" — model infers scope
- **After (4.8)**: "Review the code in [files] for: (1) bugs, (2) security, (3) conventions. Return top 5 issues ranked by severity with file:line references."

Opus 4.7/4.8 also spawn fewer subagents by default. If you need parallel
exploration, explicitly instruct the model:

- "Launch 3 code-explorer subagents in parallel, one for each of: [a], [b], [c]"

---

## Prompt Adjustments for Opus 4.8

Opus 4.8 inherits Opus 4.7's literal instruction following, so the scope,
output-format, and explicit-parallelism guidance below all still apply. The
behavioural-shift subsections at the end cover what changed in 4.8.

### Be Explicit About Scope

```
BAD (relies on inference):
"Check the auth module for problems"

GOOD (literal and explicit):
"Review files under app/api/v1/features/auth/ for:
1. Logic errors in token validation
2. Missing input sanitisation on login endpoint
3. Deviations from .CLAUDE.md conventions
Return findings as: file:line — severity — description"
```

### Specify Output Format

```
BAD:
"Summarise what you found"

GOOD:
"Return findings as a JSON array with fields:
- file (string)
- line (integer)
- severity (CRITICAL|HIGH|MEDIUM|LOW)
- description (string)
- suggested_fix (string)"
```

### Request Parallel Work Explicitly

Opus 4.8 is **more conservative** about spawning subagents than earlier models,
so explicit parallel instructions matter even more:

```
BAD:
"Explore the codebase for similar features"

GOOD:
"Launch 3 subagents in parallel:
1. Subagent A: find features similar to [feature] in app/api/v1/features/
2. Subagent B: map architecture patterns in app/models/
3. Subagent C: identify UI conventions in app/templates/
Each subagent must return a list of 5-10 key files."
```

### Calibrate Response Length and Narration

Opus 4.8 calibrates verbosity to perceived task complexity and narrates more
between tool calls than 4.7. For a focused coding agent, set a silence default:

```
"Default to silence between tool calls. Only write text when you find something,
change direction, or hit a blocker — one sentence each. When done, give a one- or
two-sentence outcome. Do not narrate routine actions or recap every file."
```

For concise final output specifically:

```
"Return a concise summary — maximum 200 words, no preamble."
```

### Grant Autonomy on Small Decisions

Opus 4.8 is more deliberate and asks for confirmation more often than 4.7. Keep
it moving on reversible choices while preserving caution where it matters:

```
"For minor choices (naming, formatting, default values, which approach among
equivalents), pick a reasonable option and note it rather than asking. For scope
changes or destructive actions, still ask first."
```

### Trigger Subagents, Search, and Memory Explicitly

Opus 4.8 under-reaches for capabilities that need an explicit "decide to use
this" step. State *when* each applies — in the system prompt and in each tool's
own description:

```
"When a task fans out across independent items (many files to read, many tests to
run, many candidates to check), delegate to subagents rather than iterating
serially. Before any task longer than a few turns, check your notes for relevant
prior context and write new findings back as you go."
```

### Steer Mid-Run with a System Message

When the workflow needs to change Opus 4.8's behaviour partway through a session
(mode switch, revised constraint, updated budget), append a `role: "system"`
message to `messages` rather than rebuilding the top-level system prompt — this
preserves the cached prefix. State the new fact as context, not as an override
command. Opus 4.8 only; fall back to a `<system-reminder>` user-turn block on
older models.
