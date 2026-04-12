# Workflow: Code Simplification

This workflow identifies the most problematic code areas in the codebase, allows the user to select a target, and refines it for clarity and maintainability while preserving all functionality.

---

## Phase 1: Global Code Analysis

Use the `@explore` sub-agent with **very thorough** depth to scan the entire workspace and identify code quality issues. Focus on:

1. **Cyclomatic Complexity**: Functions with deeply nested conditionals, multiple branching paths
2. **Nesting Depth**: Code blocks with more than 3 levels of nesting
3. **Function Length**: Functions exceeding 50 lines that could be decomposed
4. **File Size**: Files with more than 300 lines that may need splitting
5. **Code Duplication**: Repeated patterns that should be abstracted
6. **Anti-patterns**: Nested ternary operators, overly compact one-liners, magic values
7. **Readability Issues**: Poor naming, unclear logic flow, excessive comments explaining obvious code

For each issue found, document:
- File path and line number
- Type of issue (complexity, nesting, length, duplication, anti-pattern)
- Severity: high/medium/low
- Brief description of the problem

---

## Phase 2: Top 5 Pain Points Presentation

After the analysis, compile the findings and present the **Top 5 most impactful issues** to the user in this format:

```
## Top 5 Code Complexity Hotspots

### 1. [File Path] - [Issue Type]
**Severity**: [High/Medium/Low]
**Lines**: [X-Y]
**Problem**: [Brief description]
**Impact**: [Why this matters for maintainability]

### 2. ...
```

---

## Phase 3: User Selection

Use the `@questioning` skill to ask the user which of the 5 areas they want to simplify first.

**Q1: Which code area would you like me to simplify?**

○ 1. [Top issue from list]
○ 2. [Second issue]
○ 3. [Third issue]
○ 4. [Fourth issue]
○ 5. [Fifth issue]
○ Other (specify a different file or area)

---

## Phase 4: Standards & Context

Only after the user selects the target:

1. **Read AGENTS.md** to understand project-specific coding standards and conventions
2. **Read the target file(s)** to understand the code that needs simplification
3. **Identify the specific transformation** to apply based on the issue type

---

## Phase 5: Simplification Execution

Apply the following refinement rules from the `@code-simplifier` skill:

1. **Preserve Functionality**: Never change what the code does - only how it does it
2. **Reduce Nesting**: Extract inner blocks into named functions
3. **Eliminate Anti-patterns**: Replace nested ternaries with switch/if-else
4. **Improve Naming**: Rename variables/functions for clarity
5. **Consolidate Logic**: Merge redundant operations
6. **Remove Obvious Comments**: Delete comments describing self-evident code
7. **Apply ES Module Standards**: Proper imports, function keyword, explicit return types
8. **Follow React Patterns**: Explicit Props types if applicable

---

## Phase 6: Validation

After simplification:

1. **Run Lint** (if available):
   ```bash
   npm run lint
   ```
2. **Run Typecheck** (if available):
   ```bash
   npm run typecheck
   ```
3. **Run Tests** (if available):
   ```bash
   npm test
   ```

If any validation fails:
- Revert the changes
- Report the failure
- Suggest manual review

---

## Phase 7: Summary Report

Present a concise summary of changes made:

```
## Simplification Complete

**File**: [path]
**Issue**: [original problem]
**Changes**:
- [Change 1]
- [Change 2]
- [Change 3]

**Validation**: All checks passed ✓
```
