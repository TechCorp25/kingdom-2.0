# Code Quality Assessment Report

## Summary

| Field | Value |
|-------|-------|
| **File** | `{{filename}}` |
| **Assessment Date** | {{date}} |
| **Overall Status** | {{status}} |
| **Overall Score** | {{score}}/100 |

---

## Component Results

### Compatibility Check

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Score | {{compat_score}} | ≥95 | {{compat_status}} |
| Issues Found | {{compat_issues}} | 0 | {{compat_issue_status}} |

**Issues:**
{{compat_issue_list}}

---

### Breaking Change Detection

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Changes Detected | {{breaking_count}} | 0 unapproved | {{breaking_status}} |
| Requiring Approval | {{approval_count}} | All approved | {{approval_status}} |

**Changes:**
{{breaking_change_list}}

---

### Functionality Preservation

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Original Features | {{original_features}} | - | - |
| Preserved | {{preserved_features}} | 100% | {{preserved_status}} |
| Lost | {{lost_features}} | 0 | {{lost_status}} |
| Preservation Rate | {{preservation_rate}}% | 100% | {{rate_status}} |

**Lost Features:**
{{lost_feature_list}}

---

### Code Quality

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Quality Score | {{quality_score}} | ≥80 | {{quality_status}} |
| File Lines | {{line_count}} | ≤500 | {{line_status}} |
| Issues | {{quality_issues}} | 0 | {{issue_status}} |

**Quality Issues:**
{{quality_issue_list}}

---

### React Native Analysis (if applicable)

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| RN Quality Score | {{rn_score}} | ≥90 | {{rn_status}} |
| Analysis Mode | {{rn_mode}} | - | - |
| Files Analyzed | {{rn_files_analyzed}} | - | - |
| Issues Found | {{rn_total_issues}} | 0 CRITICAL/HIGH | {{rn_issue_status}} |

**Issues by Category:**

| Category | Count |
|----------|-------|
| Component Quality | {{rn_component_count}} |
| Navigation | {{rn_navigation_count}} |
| Native Modules | {{rn_native_module_count}} |
| Performance | {{rn_performance_count}} |

**Issue Details:**
{{rn_issue_list}}

---

## Approval Requirements

{{#if requires_approval}}
⚠️ **The following items require explicit user approval before delivery:**

{{approval_item_list}}

**To approve, user must respond with explicit "yes" for each item or all items.**
{{else}}
✅ No approval required - all checks passed.
{{/if}}

---

## Recommendations

{{recommendation_list}}

---

## Approval Chain

- [ ] Compatibility verified (score ≥95)
- [ ] No unapproved breaking changes
- [ ] All features preserved (or approved)
- [ ] Quality thresholds met
- [ ] React Native quality verified (score ≥90, if applicable)

---

## Final Verdict

**Status:** {{final_status}}

{{verdict_message}}
