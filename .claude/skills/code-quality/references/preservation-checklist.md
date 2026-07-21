# Preservation Checklist

## Feature Inventory Template

Before modifying any file, create an inventory:

```markdown
## Feature Inventory: [filename]

### Public Functions
| Function | Parameters | Returns | Purpose |
|----------|------------|---------|---------|
| func1 | (a: str, b: int) | dict | Description |
| func2 | (items: list) | None | Description |

### Public Classes
| Class | Methods | Purpose |
|-------|---------|---------|
| MyClass | method1, method2 | Description |

### Exports
| Symbol | Type | Used By |
|--------|------|---------|
| CONST_A | str | module_x, module_y |
| helper | function | module_z |

### Integration Points
| Component | Interaction Type | Notes |
|-----------|-----------------|-------|
| database | read/write | Uses connection pool |
| cache | read | Redis integration |

### Side Effects
| Operation | Effect | Trigger |
|-----------|--------|---------|
| func1 | Writes to log | On error |
| func2 | Updates cache | On success |
```

## Functionality Verification Steps

### Step 1: Pre-Modification Snapshot
- [ ] Document all public APIs
- [ ] List all function signatures
- [ ] Record all class interfaces
- [ ] Identify all exports
- [ ] Map integration points

### Step 2: Post-Modification Verification
- [ ] All original functions still exist
- [ ] All function signatures unchanged (or approved)
- [ ] All class interfaces preserved
- [ ] All exports available
- [ ] All integration points functional

### Step 3: Behavioral Verification
- [ ] Default behaviors unchanged
- [ ] Error handling consistent
- [ ] Side effects preserved
- [ ] Data transformations identical

### Step 4: Documentation Update
- [ ] Update docstrings if needed
- [ ] Update type hints if improved
- [ ] Note any intentional (approved) changes

## Integration Point Mapping

### Identify Dependencies
```
For target file:
  1. List all imports
  2. Identify which project files import this file
  3. Map function calls between files
  4. Document shared data structures
```

### Verify Compatibility
```
For each integration point:
  1. Confirm interface unchanged
  2. Test data flow preserved
  3. Verify error propagation works
  4. Check logging consistency
```

## Regression Prevention Measures

### Before Changes
1. Run existing tests (if available)
2. Document current behavior
3. Create feature inventory
4. Identify high-risk areas

### During Changes
1. Make incremental modifications
2. Verify each change
3. Test frequently
4. Document decisions

### After Changes
1. Run all tests
2. Compare against inventory
3. Verify all features present
4. Document any approved deviations

## Verification Checklist Summary

```
□ Pre-modification inventory complete
□ All public APIs documented
□ Integration points mapped
□ Changes made incrementally
□ Each feature verified present
□ Signatures unchanged (or approved)
□ Behaviors preserved (or approved)
□ Tests pass (if applicable)
□ Assessment report generated
□ All approved changes documented
```
