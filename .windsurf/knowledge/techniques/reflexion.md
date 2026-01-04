# Reflexion Prompting (Learning from Failures)

## Overview
Reflexion attempts a task, evaluates the results, reflects on failures, stores lessons in a memory bank, and retries with accumulated wisdom. Unlike simple retry logic, Reflexion builds understanding across attempts and applies learned lessons to improve.

This technique enables genuine learning from mistakes and progressive improvement.

## When to Use
- Learning from failures during implementation
- Self-correction when initial attempts fail
- Debugging complex issues requiring multiple attempts
- Verification where failures provide diagnostic information
- Any task where accumulated experience improves outcomes
- High-risk steps where failure analysis is valuable

## How It Works

### Memory Bank
- Accumulates lessons learned across attempts
- Stores: failure type, context, lesson, resolution
- Consulted before each new attempt

### Attempt Cycle
1. **Actor**: Generate solution (consulting memory bank)
2. **Evaluator**: Score result against criteria
3. **Self-Reflection**: Analyze failures, extract lessons
4. **Memory Update**: Add lessons to memory bank

### Stopping Criteria
- All tests pass
- Maximum attempts reached
- Escalation required

## Memory Bank Entry Format

```json
{
  "timestamp": "ISO date",
  "stepId": 1,
  "failureType": "test_failure|logic_error|integration|timeout",
  "context": "What was attempted",
  "lesson": "What was learned",
  "techniqueUsed": "tdd|reflexion|etc",
  "resolution": "How it was resolved"
}
```

## Execution Instructions

```
## REFLEXION EXECUTION PROTOCOL

### Memory Bank
[This section accumulates across attempts]

**Lessons Learned**:
- (Empty at start, populated by reflections)

---

### Attempt 1

#### Actor (Generate Solution)

**Consulting Memory Bank**: [No lessons yet]

**Approach**: [Initial strategy]

**Implementation**:
[First attempt at solution]

#### Evaluator (Score Result)

**Test Results**:
| Test | Expected | Actual | Status |
|------|----------|--------|--------|
| Test 1 | | | ✓/✗ |
| Test 2 | | | ✓/✗ |
| Test 3 | | | ✓/✗ |

**Score**: X/Y tests passing

**Failure Analysis**:
- Which tests failed?
- What was the actual vs expected behavior?
- Was it a logic error, edge case, or misunderstanding?

#### Self-Reflection

**What went wrong**:
[Specific, actionable identification of the problem]

**Why it went wrong**:
[Root cause analysis]

**What to do differently**:
[Concrete change for next attempt]

**Adding to Memory Bank**:
> Lesson 1: [Specific lesson from this failure]

---

### Attempt 2

#### Actor (Generate Solution)

**Consulting Memory Bank**:
- Lesson 1: [Apply this lesson]

**Revised Approach**: [Strategy informed by reflection]

**Implementation**:
[Second attempt, addressing identified issues]

#### Evaluator (Score Result)

**Test Results**:
| Test | Expected | Actual | Status |
|------|----------|--------|--------|
| Test 1 | | | ✓/✗ |
| Test 2 | | | ✓/✗ |
| Test 3 | | | ✓/✗ |

**Score**: X/Y tests passing

**Improvement from Attempt 1**: [What got better]

#### Self-Reflection

**What went wrong** (if anything):
[Analysis of remaining issues]

**Adding to Memory Bank**:
> Lesson 2: [Additional lesson]

---

### Attempt 3 (if needed)

#### Actor (Generate Solution)

**Consulting Memory Bank**:
- Lesson 1: [Apply]
- Lesson 2: [Apply]

**Refined Approach**: [Strategy with full context of past failures]

**Implementation**:
[Third attempt]

#### Evaluator

[Continue pattern...]

---

### Final Result

**Successful Implementation**:
[Final working solution]

**Total Attempts**: N

**Accumulated Wisdom** (Memory Bank Final State):
1. [Lesson 1]
2. [Lesson 2]
3. [Lesson N]

**Key Insight**: The most important lesson from this task was...

---

### Memory Bank Persistence

For plan-level persistence, save to:
`.windsurf/plans/{NNN}/memory-bank.json`

Format:
```json
{
  "maxEntries": 10,
  "entries": [
    {
      "timestamp": "2026-01-02T15:00:00Z",
      "stepId": 4,
      "failureType": "logic_error",
      "context": "Technique selection returned wrong phase",
      "lesson": "Check phase parameter explicitly, don't assume order",
      "techniqueUsed": "reflexion",
      "resolution": "Added explicit phase validation"
    }
  ]
}
```

FIFO: When entries exceed maxEntries, remove oldest.
```

## Example Application

**Task**: Fix a bug where date parsing fails for edge cases

**Reflexion Application**:
1. **Attempt 1**: Fix obvious case, tests reveal another failure
   **Lesson**: Multiple date formats in use
2. **Attempt 2**: Handle two formats, new edge case appears
   **Lesson**: Timezone handling needed
3. **Attempt 3**: Full timezone support, all tests pass
   **Final**: Memory bank has 2 lessons for future date work

## Common Pitfalls
- Not consulting memory bank before new attempts
- Lessons too vague to apply ("be more careful")
- Not recording failures systematically
- Giving up before reflection yields insights
- Memory bank entries too verbose (keep lessons concise)
- Not applying lessons from similar past failures

## Verification Checklist
- [ ] Memory bank initialized
- [ ] Each attempt records test results
- [ ] Failures analyzed with root cause
- [ ] Lessons are specific and actionable
- [ ] Memory bank consulted before each attempt
- [ ] Progress tracked (scores improving)
- [ ] Final solution incorporates learned lessons
- [ ] Memory bank persisted for future use
