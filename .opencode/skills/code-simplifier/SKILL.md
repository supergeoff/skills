---
name: code-simplifier
description: Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality. Focuses on recently modified code unless instructed otherwise.
compatibility: opencode
metadata:
  audience: developers
  workflow: code-review
---

## Core Principles

### 1. Preserve Functionality
Never change what the code does - only how it does it. All original features, outputs, and behaviors must remain intact.

### 2. Apply AGENTS.md Standards
Follow the established coding standards from **AGENTS.md** including:
- Use ES modules with proper import sorting and extensions
- Prefer `function` keyword over arrow functions for top-level
- Use explicit return type annotations for top-level functions
- Follow proper React component patterns with explicit Props types
- Use proper error handling patterns (avoid try/catch when possible)
- Maintain consistent naming conventions

### 3. Enhance Clarity Through Simplification

**Reduce Complexity**:
- Extract nested conditionals into named functions
- Break large functions into smaller, focused units
- Replace deeply nested if-else chains with early returns
- Use guard clauses to reduce nesting

**Eliminate Anti-patterns**:
- Replace nested ternary operators with switch statements or if-else chains
- Avoid overly compact one-liners that sacrifice readability
- Remove magic numbers/string with named constants
- Consolidate repeated logic into reusable functions

**Improve Naming**:
- Rename variables for clarity (e.g., `d` → `daysSinceLastUpdate`)
- Use verbs for functions (e.g., `calculate` vs `process`)
- Be explicit about return values

**Remove Noise**:
- Delete comments describing obvious code
- Remove blank lines that create artificial separation
- Eliminate redundant abstractions that add no value

### 4. Maintain Balance

Avoid over-simplification that could:
- Remove helpful abstractions that improve organization
- Combine too many concerns into single functions
- Make the code harder to debug or extend
- Sacrifice clarity for fewer lines

---

## Simplification Patterns

### Nested Ternaries → if-else/switch
```javascript
// BEFORE (avoid)
const status = a ? b ? c ? 'yes' : 'no' : 'maybe' : 'unknown';

// AFTER (prefer)
function getStatus(a, b, c) {
  if (!a) return 'unknown';
  if (!b) return 'maybe';
  return c ? 'yes' : 'no';
}
```

### Deep Nesting → Early Returns
```javascript
// BEFORE
function processUser(user) {
  if (user) {
    if (user.profile) {
      if (user.profile.settings) {
        if (user.profile.settings.theme) {
          return user.profile.settings.theme;
        }
      }
    }
  }
  return 'default';
}

// AFTER
function processUser(user) {
  if (!user?.profile?.settings?.theme) {
    return 'default';
  }
  return user.profile.settings.theme;
}
```

### Magic Values → Named Constants
```javascript
// BEFORE
if (status === 1 || status === 2 || status === 3) {
  // process
}

// AFTER
const ACTIVE_STATUSES = [1, 2, 3];
if (ACTIVE_STATUSES.includes(status)) {
  // process
}
```

### Long Function → Composed Helpers
```javascript
// BEFORE
function processOrder(order) {
  // 100+ lines of logic
}

// AFTER
function processOrder(order) {
  validateOrder(order);
  calculateTotals(order);
  applyDiscounts(order);
  finalizeOrder(order);
}
```

---

## Validation Checklist

Before concluding simplification:

- [ ] Functionality preserved (same inputs → same outputs)
- [ ] No new nesting introduced
- [ ] Naming is clear and consistent
- [ ] Anti-patterns eliminated
- [ ] ES module standards followed
- [ ] Comments removed (except for complex business logic)
- [ ] Tests still pass
- [ ] Typecheck passes
- [ ] Lint passes
