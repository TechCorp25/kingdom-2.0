# Assessment Criteria Reference

## Quality Metrics

### Compatibility Score (0-100)

| Score Range | Status | Action |
|-------------|--------|--------|
| 95-100 | PASS | Proceed with delivery |
| 80-94 | WARN | Review issues, may proceed with documentation |
| 0-79 | FAIL | Block delivery, resolve issues |

**Scoring Factors:**
- Import compatibility: 30 points
- Function signature compatibility: 25 points
- Class interface compatibility: 25 points
- Integration point compatibility: 20 points

### Breaking Change Severity

| Level | Definition | Action Required |
|-------|------------|-----------------|
| CRITICAL | Removes public API, changes return types | Block + explicit approval |
| HIGH | Changes function signatures, renames exports | Block + explicit approval |
| MEDIUM | Changes default behavior | Warning + approval recommended |
| LOW | Internal implementation changes | Document only |

### Functionality Preservation Rate

| Rate | Status | Action |
|------|--------|--------|
| 100% | PASS | Proceed |
| 95-99% | WARN | Document missing features, request approval |
| <95% | FAIL | Block delivery |

## Code Quality Thresholds

### Complexity (Cyclomatic)
- **Target**: ≤10 per function
- **Warning**: 11-15
- **Fail**: >15

### Maintainability Index
- **Target**: ≥80
- **Warning**: 65-79
- **Fail**: <65

### Test Coverage (when applicable)
- **Target**: ≥80%
- **Warning**: 60-79%
- **Fail**: <60%

### Documentation Coverage
- **Target**: 100% public APIs documented
- **Warning**: >80% documented
- **Fail**: <80% documented

## Pass/Fail Decision Matrix

| Criteria | Required for PASS |
|----------|-------------------|
| Compatibility Score | ≥95 |
| Breaking Changes | None OR all approved |
| Functionality Preservation | 100% OR explicitly approved |
| Code Complexity | All functions ≤15 |
| Maintainability | ≥65 |
| React Native Quality (if applicable) | ≥90 |

**Overall Status:**
- **PASS**: All criteria met
- **CONDITIONAL PASS**: Minor warnings, documented
- **FAIL**: Any required criteria not met

### React Native Quality Score (0-100)

| Score Range | Status | Action |
|-------------|--------|--------|
| 90-100 | PASS | Proceed with delivery |
| 70-89 | WARN | Review issues, may proceed with documentation |
| 0-69 | FAIL | Block delivery, resolve issues |

**Scoring Deductions:**
- CRITICAL issue: -15 points per occurrence
- HIGH issue: -8 points per occurrence
- MEDIUM issue: -3 points per occurrence
- LOW issue: -1 point per occurrence

**Category Breakdown:**

| Category | Rules Checked |
|----------|---------------|
| Component Quality | hooks-conditional, hooks-loop |
| Performance | useeffect-no-deps, inline-style-object, anonymous-handler-prop, flatlist-no-keyextractor, flatlist-no-getitemlayout |
| Navigation | untyped-navigation-hooks |
| Native Modules | native-no-platform-check, turbo-module-no-platform |
