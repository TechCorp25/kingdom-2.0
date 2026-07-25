# Assumption classification

> Reference for: common-ground
> Load when: classifying assumptions, determining type or tier

Ported from `jeffallan/claude-skills@e8be415` `commands/common-ground/references/assumption-classification.md`.
Classification logic is unchanged — it has no external dependencies. Only the
storage and identity layers were converted (see `ground-file-management.md`).

---

## Assumption types

Types indicate **how** an assumption was derived. Types are immutable once set —
the script rejects any attempt to change one, because the type is the audit trail.

| Type | Evidence | Confidence | Markers | Example |
|------|----------|-----------|---------|---------|
| `stated` | Explicit quote from the owner | High | owner said / requested / specified | "Use TypeScript for all new code" |
| `inferred` | Code analysis, config files, structure | Medium-high | config shows, code uses, pattern observed | "Uses ESLint with Airbnb config" — from `.eslintrc.js` |
| `assumed` | Industry standards, common patterns | Medium | best practice, common convention, typically | "Tests should have >80% coverage" |
| `uncertain` | None, conflicting, or incomplete | Low | unknown, unclear, conflicting signals | "Legacy browser support required?" — no browserslist found |

---

## Assumption tiers

Tiers indicate **confidence** and how to act. The owner can change tiers freely.

### ESTABLISHED (high confidence)

Owner-validated facts that can be treated as premises.

- **Action:** act confidently without re-asking.
- **Use when:** the owner explicitly validated it; verified by direct
  observation; documented in project configuration.

### WORKING (medium confidence)

Reasonable inferences to use, but surface if contradicted.

- **Action:** use as a basis for work, but flag the moment evidence contradicts it.
- **Use when:** inferred from code/config patterns; informally confirmed;
  no contradicting evidence found.

### OPEN (low confidence)

Unvalidated assumptions requiring input before acting.

- **Action:** ask before making decisions that depend on this.
- **Use when:** `uncertain` type; conflicting signals; high-impact and unvalidated.

---

## Tier transitions

| From | To | Trigger |
|------|-----|---------|
| OPEN | WORKING | Owner confirms informally in conversation |
| WORKING | ESTABLISHED | Owner explicitly validates ("yes, that's correct") |
| ESTABLISHED | WORKING | Owner says "usually, but…" or notes an exception |
| WORKING | OPEN | Contradiction found in code/config |
| Any | Archived | Superseded by new information |

Record every transition through the script so it lands in the history table:

```bash
automate-dev-suite/scripts/common-ground.sh tier A001 ESTABLISHED "owner confirmed"
```

---

## Classification process

**Step 1 — identify the source:**

| Source | Typical type | Typical tier |
|--------|-------------|--------------|
| Owner statement | stated | ESTABLISHED |
| Config file | inferred | WORKING |
| Code pattern | inferred | WORKING |
| Convention | assumed | WORKING |
| Unknown / gap | uncertain | OPEN |

**Step 2 — assess evidence strength:**

| Evidence | Tier |
|----------|------|
| Explicit owner confirmation | ESTABLISHED |
| Multiple corroborating sources | WORKING |
| Single source, no contradictions | WORKING |
| No evidence, or conflicting | OPEN |

**Step 3 — consider impact.** High-impact assumptions (architecture, security,
data handling, anything touching a HARD gate) start at OPEN unless strongly
evidenced. When an assumption would bear on auth, payments, data deletion, or
migrations, say so — those carry a HARD gate in `gates/gate-map.md`.

---

## Worked examples

| Assumption | Type | Tier | Reasoning |
|------------|------|------|-----------|
| "Uses TypeScript" | inferred | WORKING | `tsconfig.json` present |
| "React 18 with hooks" | inferred | WORKING | `package.json` shows react@18 |
| "No server-side rendering" | inferred | OPEN | High impact, needs validation |
| "2-space indentation" | inferred | ESTABLISHED | Consistent across all files |
| "Prefer named exports" | assumed | WORKING | Convention, not enforced |
| "80% coverage target" | assumed | OPEN | No config found, assumed |
| "Integration tests required" | uncertain | OPEN | Unknown requirement |
| "Prefers verbose explanations" | stated | ESTABLISHED | Owner said "explain thoroughly" |

---

## Owner-added assumptions

When the owner adds one via "Other", they may specify tier and type:

**Format:** `{assumption text} [tier] [type]` —
e.g. `Must work offline [ESTABLISHED] [stated]`.

If type is unspecified, default to `stated` (the owner is adding it directly).
If tier is unspecified, default to `WORKING`.
