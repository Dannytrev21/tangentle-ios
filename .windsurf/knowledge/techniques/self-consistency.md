# Self-Consistency Prompting

## Overview
Self-Consistency generates multiple independent solutions to the same problem, then evaluates and selects the best one based on consensus and quality metrics. By sampling diverse approaches, it reduces the risk of a single flawed solution.

This technique is powerful for problems with verifiable correctness where multiple valid solutions may exist.

## When to Use
- Algorithm verification where correctness is critical
- System design validation requiring multiple perspectives
- Correctness checking with objective criteria
- Problems with multiple valid approaches
- High-stakes decisions benefiting from cross-validation
- Any situation where independent verification adds confidence

## How It Works

### Phase 1: Generate Multiple Solutions
- Generate N (typically 3-5) independent solutions
- Each solution should use a fresh approach
- Don't reference other solutions during generation

### Phase 2: Evaluation Matrix
- Score each solution on consistent criteria
- Criteria: correctness, readability, edge cases, performance, maintainability
- Sum scores for comparison

### Phase 3: Consensus Analysis
- Identify what solutions agree on
- Note where they diverge
- Extract common patterns

### Phase 4: Final Selection
- Select the highest-scoring solution
- Optionally incorporate improvements from others
- Document selection reasoning

## Execution Instructions

```
## SELF-CONSISTENCY EXECUTION PROTOCOL

### Phase 1: Generate Multiple Solutions

For each solution:
1. Start fresh without referencing other solutions
2. Use a slightly different approach or starting point
3. Include reasoning for design decisions

---

**SOLUTION 1:**
[Generate complete solution with reasoning]

**Approach**: [Brief description of approach taken]

**Implementation**:
[Code/solution]

**Edge Cases Considered**:
- [Edge case handling 1]
- [Edge case handling 2]

---

**SOLUTION 2:**
[Generate complete solution with different approach]

**Approach**: [Different starting point or strategy]

**Implementation**:
[Code/solution]

**Edge Cases Considered**:
- [Edge case handling]

---

**SOLUTION 3:**
[Generate complete solution exploring alternative]

**Approach**: [Another perspective]

**Implementation**:
[Code/solution]

---

**SOLUTION 4:**
[Generate complete solution with variation]

---

**SOLUTION 5:**
[Generate complete solution]

---

### Phase 2: Evaluation Matrix

| Criteria | Sol 1 | Sol 2 | Sol 3 | Sol 4 | Sol 5 |
|----------|-------|-------|-------|-------|-------|
| Correctness | /5 | /5 | /5 | /5 | /5 |
| Readability | /5 | /5 | /5 | /5 | /5 |
| Edge Cases | /5 | /5 | /5 | /5 | /5 |
| Performance | /5 | /5 | /5 | /5 | /5 |
| Maintainability | /5 | /5 | /5 | /5 | /5 |
| **TOTAL** | /25 | /25 | /25 | /25 | /25 |

---

### Phase 3: Consensus Analysis

**Agreement points** (what do most solutions share?):
- [Common approach 1]
- [Common pattern 2]
- [Shared design decision]

**Divergence points** (where do they differ?):
- [Difference 1]: Solutions 1,3 use X; Solutions 2,4,5 use Y
- [Difference 2]: Only Solution 3 handles [edge case]

**Best practices observed**:
- [Pattern worth keeping from multiple solutions]

---

### Phase 4: Final Selection

**Selected solution**: Solution [N]

**Reason**: [Why this one scored highest]

**Improvements from other solutions**:
- From Solution X: [Cherry-picked improvement]
- From Solution Y: [Additional enhancement]

---

### Final Implementation

[Present the refined final solution incorporating best elements]

**Confidence**: High - verified through [N] independent solutions
```

## Example Application

**Task**: Implement a function to check if a string is a palindrome

**Self-Consistency Application**:
1. **Solution 1**: Two-pointer approach
2. **Solution 2**: Reverse and compare
3. **Solution 3**: Recursive approach
4. **Solution 4**: Stack-based
5. **Solution 5**: Regex preprocessing + compare

**Evaluation**: Solutions 1 and 2 score highest for readability and performance.

**Consensus**: All handle case-insensitivity differently - adopt best approach.

## Common Pitfalls
- Solutions too similar (not truly independent)
- Inconsistent evaluation criteria across solutions
- Not using consensus insights
- Generating too few solutions for meaningful comparison
- Ignoring minority approaches that may have valuable insights
- Spending too much time on clearly inferior solutions

## Verification Checklist
- [ ] At least 3-5 independent solutions generated
- [ ] Each solution uses different approach/perspective
- [ ] Evaluation uses consistent criteria
- [ ] Scores documented objectively
- [ ] Consensus patterns identified
- [ ] Divergence points analyzed
- [ ] Final selection justified
- [ ] Best elements from multiple solutions incorporated
