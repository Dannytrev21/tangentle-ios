# Self-Refine Prompting

## Overview
Self-Refine is an iterative improvement technique where an initial solution is generated, then feedback is provided to refine it through multiple iterations. The process continues until the solution meets quality standards or no further improvements are identified.

This technique produces polished, high-quality output through deliberate iteration.

## When to Use
- UI polish and visual refinement
- Code quality improvements
- Documentation where tone and clarity matter
- Iterative improvement of any artifact
- Situations where "good enough" isn't sufficient
- Creative tasks benefiting from multiple passes

## How It Works

### Iteration 0: Initial Generation
- Produce a first attempt without overthinking
- Get something on paper to iterate on

### Iteration 1+: Feedback → Refinement Loop
- Generate specific, actionable feedback on the current version
- Address each feedback point in a new version
- Evaluate if improvement is sufficient

### Stopping Criteria
- All quality dimensions meet threshold
- No further actionable feedback
- Maximum iterations reached

## Execution Instructions

```
## SELF-REFINE EXECUTION PROTOCOL

### Iteration 0: Initial Generation

**First Attempt**:
[Initial implementation - produce something to iterate on]

---

### Iteration 1: Feedback → Refinement

#### Self-Feedback on Iteration 0

**Correctness**:
- [ ] Does it handle the main case correctly?
- [ ] Edge case 1: [handled/missing]
- [ ] Edge case 2: [handled/missing]
- Issues: [Specific problems found]

**Code Quality**:
- [ ] Clear variable names?
- [ ] Appropriate comments?
- [ ] No magic numbers?
- [ ] DRY (no repetition)?
- Issues: [Specific problems found]

**Performance**:
- Current complexity: O(?)
- Could be improved: [yes/no]
- Specific inefficiencies: [List]

**Robustness**:
- [ ] Input validation?
- [ ] Error handling?
- [ ] Type safety?
- Issues: [Specific problems found]

**Actionable Feedback Summary**:
1. [Specific thing to fix #1]
2. [Specific thing to fix #2]
3. [Specific thing to fix #3]

#### Refinement Based on Feedback

**Addressing each feedback point**:
1. To fix [issue 1]: [change]
2. To fix [issue 2]: [change]
3. To fix [issue 3]: [change]

**Refined Implementation (v1)**:
[Improved code incorporating feedback]

---

### Iteration 2: Feedback → Refinement

#### Self-Feedback on Iteration 1

**Correctness**: [Better/Same/Worse] - [Details]
**Code Quality**: [Better/Same/Worse] - [Details]
**Performance**: [Better/Same/Worse] - [Details]
**Robustness**: [Better/Same/Worse] - [Details]

**Remaining Issues**:
1. [Any remaining problems]

**New Issues Introduced**: [Any regressions]

#### Refinement Based on Feedback

**Refined Implementation (v2)**:
[Further improved code]

---

### Iteration 3: Final Check

#### Self-Feedback on Iteration 2

**Quality Checklist**:
- [x] All edge cases handled
- [x] Code is readable and maintainable
- [x] Performance is acceptable
- [x] Proper error handling
- [x] Well documented

**Is further refinement needed?**: [YES → continue / NO → done]

---

### Stopping Criteria Met

**Final Implementation**:
[Final polished solution]

**Improvement Journey**:
| Aspect | Initial | After Iter 1 | After Iter 2 | Final |
|--------|---------|--------------|--------------|-------|
| Correctness | X/10 | X/10 | X/10 | X/10 |
| Quality | X/10 | X/10 | X/10 | X/10 |

**Total iterations**: N
**Key improvements made**:
1. [Improvement 1]
2. [Improvement 2]
```

## Example Application

**Task**: Write a function to format currency

**Self-Refine Application**:
1. **Initial**: Basic formatting with fixed locale
2. **Feedback**: Missing negative handling, hardcoded currency
3. **Refine v1**: Add negative handling, parameterize currency
4. **Feedback**: Missing thousands separator edge case
5. **Refine v2**: Fix edge case, add documentation
6. **Done**: All quality criteria met

## Common Pitfalls
- Providing vague feedback that can't be acted on
- Over-iterating without meaningful improvements
- Introducing new bugs during refinement (regressions)
- Not having clear stopping criteria
- Losing sight of original requirements during polish
- Focusing on style over substance

## Verification Checklist
- [ ] Initial version produced (something to iterate on)
- [ ] Feedback is specific and actionable
- [ ] Each refinement addresses identified issues
- [ ] No regressions introduced
- [ ] Stopping criteria clearly defined
- [ ] Final version measurably better than initial
- [ ] Quality dimensions assessed consistently
