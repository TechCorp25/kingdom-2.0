# Code Standards Reference

## Python Standards

### Type Hints
```python
# Required for all function signatures
def process_data(items: list[dict], config: Config) -> ProcessResult:
    ...
```

### Docstrings
```python
def complex_function(param1: str, param2: int) -> dict:
    """
    Brief description of function purpose.
    
    Args:
        param1: Description of param1
        param2: Description of param2
        
    Returns:
        Description of return value
        
    Raises:
        ValueError: When param1 is empty
    """
```

### Error Handling
```python
# Use specific exceptions, never bare except
try:
    result = risky_operation()
except SpecificError as e:
    logger.error(f"Operation failed: {e}")
    raise OperationFailedError(f"Could not complete: {e}") from e
```

### Logging
```python
import logging
logger = logging.getLogger(__name__)

# Log significant operations
logger.info("Starting process for %s items", len(items))
logger.debug("Processing item: %s", item_id)
logger.error("Failed to process: %s", error_message)
```

## JavaScript/TypeScript Standards

### Type Definitions
```typescript
// Always use explicit types
interface UserConfig {
  id: string;
  settings: Settings;
}

function processUser(config: UserConfig): Promise<Result> {
  ...
}
```

### Error Handling
```typescript
// Use try-catch with specific error types
try {
  const result = await riskyOperation();
} catch (error) {
  if (error instanceof NetworkError) {
    logger.error('Network failure:', error.message);
    throw new OperationError('Network unavailable', { cause: error });
  }
  throw error;
}
```

### Async Patterns
```typescript
// Prefer async/await over callbacks
async function fetchData(): Promise<Data> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new FetchError(`HTTP ${response.status}`);
  }
  return response.json();
}
```

## Universal Standards

### Naming Conventions
- Functions: verb + noun (`getUserById`, `validateInput`)
- Variables: descriptive nouns (`userCount`, `isValid`)
- Constants: SCREAMING_SNAKE_CASE (`MAX_RETRIES`, `API_BASE_URL`)
- Classes: PascalCase (`UserService`, `DataProcessor`)

### Code Organization
- One concept per function
- Maximum function length: ~50 lines
- Maximum file length: ~500 lines
- Group related functions together

### Comments
```python
# Good: Explains WHY, not WHAT
# Rate limit to prevent API throttling (max 100 req/min)
await rate_limiter.acquire()

# Bad: Restates the code
# Increment counter by 1
counter += 1
```

### Security
- Never log sensitive data (passwords, tokens, PII)
- Validate all external input
- Use parameterized queries for database operations
- Sanitize output to prevent injection attacks
