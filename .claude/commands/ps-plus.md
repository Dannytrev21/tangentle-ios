# Plan-and-Solve Plus (PS+) Prompting

## Task: $ARGUMENTS

## Instructions

I will first understand the problem completely, devise a detailed plan, then execute it step-by-step with careful attention to intermediate results.

---

<!-- SECTION:PLANNING -->
## Phase 1: Problem Understanding

**Problem Statement** (in my own words):
[Restate the problem to ensure understanding]

**Inputs**:
- [Variable 1]: [Type, constraints, example]
- [Variable 2]: [Type, constraints, example]
- ...

**Expected Outputs**:
- [Output 1]: [Type, format, constraints]
- ...

**Edge Cases to Consider**:
1. Empty input
2. Single element
3. Maximum size
4. Invalid input
5. [Domain-specific edge cases]

**Constraints**:
- Time complexity requirement:
- Space complexity requirement:
- Other constraints:

---

## Phase 2: Plan Formulation

**High-Level Strategy**: [One sentence approach]

**Detailed Step-by-Step Plan**:

1. **Step 1**: [Description]
   - Input at this step: 
   - Operation:
   - Output/Result:
   - Potential error:

2. **Step 2**: [Description]
   - Input at this step:
   - Operation:
   - Output/Result:
   - Potential error:

3. **Step 3**: [Description]
   - Input at this step:
   - Operation:
   - Output/Result:
   - Potential error:

[Continue for all steps...]

**Final Step**: [How to produce final output]

<!-- /SECTION:PLANNING -->

---

<!-- SECTION:IMPLEMENTATION -->
## Phase 3: Execution with Intermediate Verification

### Executing Step 1

```
[Implementation]
```

**Intermediate Result Check**:
- Expected: [What we should have]
- Actual: [What we got - verify manually or with test]
- ✓/✗ Proceeding

---

### Executing Step 2

```
[Implementation]
```

**Intermediate Result Check**:
- Expected: [What we should have]
- Actual: [What we got]
- ✓/✗ Proceeding

---

[Continue for all steps...]

<!-- /SECTION:IMPLEMENTATION -->

---

<!-- SECTION:VERIFICATION -->
## Phase 4: Final Verification

**Complete Solution**:
```
[Full implementation]
```

**Test Cases**:

| Input | Expected | Actual | Pass? |
|-------|----------|--------|-------|
| [Edge case 1] | | | |
| [Edge case 2] | | | |
| [Normal case] | | | |
| [Large input] | | | |

**Complexity Analysis**:
- Time: O(?)
- Space: O(?)

**Final Confidence**: [High/Medium/Low] because [reason]
<!-- /SECTION:VERIFICATION -->

<!-- SECTION:ERROR_RECOVERY -->
## Error Recovery

If intermediate verification fails:
1. Identify which step produced incorrect results
2. Check the inputs to that step
3. Review the operation being performed
4. Consider if the plan needs adjustment
5. Re-execute from the failed step
<!-- /SECTION:ERROR_RECOVERY -->
