# Least-to-Most Prompting (Decomposition)

## Overview
Least-to-Most is a decomposition technique that solves complex problems by breaking them into simpler subproblems, then solving each in order from simplest to most complex. Each solution builds on previous solutions, creating a scaffolding of understanding.

This technique mirrors how humans naturally learn: master fundamentals before tackling advanced concepts.

## When to Use
- Problems that can be decomposed into hierarchical subproblems
- Infrastructure and setup tasks that have dependencies
- Data modeling where simpler entities must exist before complex ones
- Integration tests that require foundational components
- Any problem where complexity can be reduced through ordering

## How It Works

### Phase 1: Decomposition
- Identify the original problem clearly
- Break into subproblems from simplest to most complex
- Map dependencies between subproblems
- Ensure each subproblem has clear inputs and outputs

### Phase 2: Sequential Solving
- Solve the simplest subproblem first
- Use that solution as context for the next
- Build incrementally toward the full solution
- Verify each subproblem solution before proceeding

### Phase 3: Final Integration
- Combine all subproblem solutions
- Test the integrated solution
- Verify the original problem is solved

## Execution Instructions

```
## LEAST-TO-MOST EXECUTION PROTOCOL

### Phase 1: Decomposition

**Original Problem**: [Restate the problem clearly]

**Subproblems (from simplest to most complex)**:

1. **Subproblem 1** (Simplest prerequisite):
   - Description:
   - Input:
   - Output:
   - Dependencies: None

2. **Subproblem 2**:
   - Description:
   - Input:
   - Output:
   - Dependencies: Subproblem 1

3. **Subproblem 3**:
   - Description:
   - Input:
   - Output:
   - Dependencies: Subproblems 1, 2

[Continue as needed...]

**N. Final Integration** (Most complex):
   - Description: Combine all subproblems into final solution
   - Dependencies: All previous

---

### Phase 2: Sequential Solving

#### Solving Subproblem 1

**Context**: Starting fresh, this is the foundation.

**Solution**:
[Code/implementation]

**Verification**: [How we know this works]

---

#### Solving Subproblem 2

**Context**: We now have Solution 1 available:
- [Summary of what Subproblem 1 provides]

**Solution**:
[Code/implementation building on Subproblem 1]

**Verification**: [How we know this works]

---

[Continue for all subproblems...]

---

### Phase 3: Final Integration

**All Available Components**:
1. [Subproblem 1 result]
2. [Subproblem 2 result]
3. [Subproblem 3 result]

**Final Solution**:
[Complete integrated solution]

**Integration Test**: [Verify the complete solution works]
```

## Example Application

**Task**: Build a user authentication system

**Decomposition**:
1. Password hashing utility (no dependencies)
2. User model with credentials (uses hashing)
3. Login validation logic (uses model and hashing)
4. Session management (uses login validation)
5. Complete auth flow (integrates all above)

**Solving**: Start with password hashing, verify it works, then use it in user model, and so on.

## Common Pitfalls
- Decomposing into subproblems that are still too complex
- Missing dependencies between subproblems
- Solving subproblems in wrong order (complex before simple)
- Not verifying each solution before proceeding
- Creating too large a gap between subproblem complexities

## Verification Checklist
- [ ] Problem decomposed into ordered subproblems
- [ ] Dependencies between subproblems identified
- [ ] Simplest subproblem has no dependencies
- [ ] Each subproblem verified before moving on
- [ ] Solutions reference previous solutions correctly
- [ ] Final integration tested end-to-end
