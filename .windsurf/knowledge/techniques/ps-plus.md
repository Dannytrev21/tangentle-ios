# Plan-and-Solve Plus (PS+)

## Overview
PS+ is a structured planning technique that emphasizes complete problem understanding before taking action. It breaks down complex problems into clear phases: understanding, planning, execution, and verification. Each phase builds on the previous, with explicit intermediate checkpoints.

This technique is ideal for straightforward problems where the path forward is relatively clear, but careful planning prevents mistakes.

## When to Use
- Structured planning tasks with clear requirements
- Straightforward implementation where approach is known
- Documentation and configuration tasks
- Foundation and infrastructure setup
- Any task benefiting from step-by-step decomposition

## How It Works

### Phase 1: Problem Understanding
- Restate the problem in your own words
- Identify inputs, outputs, and constraints
- List edge cases to consider
- Clarify any assumptions

### Phase 2: Plan Formulation
- Develop a high-level strategy
- Create detailed step-by-step plan
- For each step: define input, operation, expected output, and potential errors

### Phase 3: Execution with Verification
- Execute each step from the plan
- After each step, verify the intermediate result
- If verification fails, re-examine and adjust

### Phase 4: Final Verification
- Test with multiple cases including edge cases
- Analyze complexity if applicable
- Confirm all requirements are met

## Execution Instructions

```
## PS+ EXECUTION PROTOCOL

### Step 1: Problem Understanding

**Problem Statement** (in my own words):
[Restate the problem to ensure understanding]

**Inputs**:
- [Variable 1]: [Type, constraints, example]
- [Variable 2]: [Type, constraints, example]

**Expected Outputs**:
- [Output 1]: [Type, format, constraints]

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

### Step 2: Plan Formulation

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

[Continue for all steps...]

---

### Step 3: Execution with Intermediate Verification

#### Executing Step 1

[Implementation]

**Intermediate Result Check**:
- Expected: [What we should have]
- Actual: [What we got]
- ✓/✗ Proceeding

[Continue for all steps...]

---

### Step 4: Final Verification

**Complete Solution**:
[Full implementation]

**Test Cases**:
| Input | Expected | Actual | Pass? |
|-------|----------|--------|-------|
| [Edge case 1] | | | |
| [Normal case] | | | |

**Final Confidence**: [High/Medium/Low] because [reason]
```

## Example Application

**Task**: Implement a function to validate email addresses

**PS+ Application**:

1. **Understanding**: Email validation needs to check format, domain, and special characters
2. **Plan**: (a) Parse email into local and domain parts, (b) Validate local part, (c) Validate domain, (d) Return result
3. **Execute**: Implement each validation step with intermediate checks
4. **Verify**: Test with valid emails, invalid formats, edge cases

## Common Pitfalls
- Rushing to implementation before fully understanding requirements
- Creating plans that are too vague to execute
- Skipping intermediate verification checkpoints
- Not considering edge cases during planning phase
- Failing to update plan when intermediate results differ from expectations

## Verification Checklist
- [ ] Problem restated in own words
- [ ] All inputs and outputs identified
- [ ] Edge cases explicitly listed
- [ ] Step-by-step plan with clear operations
- [ ] Each step has expected intermediate result
- [ ] Final solution tested against edge cases
- [ ] Complexity analyzed (if applicable)
