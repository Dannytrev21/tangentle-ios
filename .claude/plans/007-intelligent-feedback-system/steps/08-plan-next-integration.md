# Step 8: Plan-Next Integration

## Problem Type
`refactor`

## Technique Selection
- **Planning**: ps-plus - Clear integration points
- **Implementation**: tdd + self-refine - Tests for integration code, then iterative refinement
- **Verification**: reflexion - Learn from any workflow issues

## Risk Level
**medium** - Modifying core plan execution workflow

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
This step integrates the feedback system into the `/plan-next` command. After each step completes, the system records:
1. Technique effectiveness outcome
2. Implementation attempts made
3. Plan metrics update

This is the critical integration point that makes the feedback loop functional.

## Goal
Modify `/plan-next` to:
1. Load implementation tracker at step start
2. Record attempts during implementation
3. Record outcome to effectiveness tracker
4. Update plan metrics
5. Show attempt summary in step context

## Prerequisites
- Step 3 (Effectiveness Tracker) completed
- Step 4 (Implementation Tracker) completed
- Step 5 (Technique Selector Enhancement) completed

## High-Level Steps
1. Add feedback recording to step completion
2. Add attempt tracking during implementation
3. Inject attempt summary into prompts
4. Update metrics on completion
5. Test full workflow

## Detailed Requirements

### Modified plan-next.md Sections

#### Add to Step 5.5: Load Implementation Context

```markdown
### Step 5.5: Load Implementation Context

Before displaying step info, load any previous implementation attempts:

```bash
# Load implementation tracker
python3 -c "
from scripts.feedback_store import FeedbackStore
from scripts.implementation_tracker import ImplementationTracker

store = FeedbackStore()
tracker = ImplementationTracker(store)
summary = tracker.get_attempt_summary('{plan_id}', {step_id})
print(summary)
"
```

If there are previous attempts, include in the step display:

```
═══════════════════════════════════════════════════════════════
  STEP EXECUTION: {N} of {Total} - {Step Name}
═══════════════════════════════════════════════════════════════

  ## Previous Implementation Attempts

  {attempt_summary}

  ## Methods to Avoid
  {list of failed methods}

  ## Suggested Technique
  Based on history: {recommended technique}
  (Avoiding: {failed techniques})

═══════════════════════════════════════════════════════════════
```
```

#### Add to Step 6: Track Implementation Start

```markdown
### Track Implementation Start

Before starting implementation, record the attempt:

```python
# Record attempt start (add to prompt context)
from scripts.feedback_store import FeedbackStore
from scripts.implementation_tracker import ImplementationTracker

store = FeedbackStore()
tracker = ImplementationTracker(store)

attempt_num = tracker.start_attempt(
    plan_id="{plan_id}",
    step_id={step_id},
    problem_type="{step.problemType}",
    technique="{technique_being_used}",
    method_description="{brief description of approach}"
)

print(f"Starting attempt #{attempt_num}")
```

Include this context at the start of implementation.
```

#### Add to Step 7: Record Outcome

```markdown
### Record Outcome

After verification completes (pass or fail), record the outcome:

#### On Success:

```python
from scripts.feedback_store import FeedbackStore
from scripts.effectiveness_tracker import EffectivenessTracker
from scripts.implementation_tracker import ImplementationTracker

store = FeedbackStore()

# Record implementation attempt outcome
impl_tracker = ImplementationTracker(store)
impl_tracker.end_attempt(
    plan_id="{plan_id}",
    step_id={step_id},
    success=True,
    error_summary=None
)

# Record technique effectiveness
eff_tracker = EffectivenessTracker(store)
eff_tracker.record_outcome(
    problem_type="{step.problemType}",
    technique="{technique_used}",
    success=True,
    attempts={step.attempts}
)

# Update plan metrics
store.update_metrics(
    completed_steps_delta=1
)
```

#### On Failure:

```python
# Record implementation attempt outcome
impl_tracker.end_attempt(
    plan_id="{plan_id}",
    step_id={step_id},
    success=False,
    error_summary="{brief error description}"
)

# NOTE: Don't record to effectiveness tracker on partial failure
# Only record when step is fully given up on
```

#### On Final Failure (after all retries):

```python
# Record effectiveness failure
eff_tracker.record_outcome(
    problem_type="{step.problemType}",
    technique="{technique_used}",
    success=False,
    attempts={total_attempts}
)
```
```

#### Add to Completion Protocol

```markdown
### Update Feedback Data

After updating progress.json and context.md:

```python
# Update feedback data
from scripts.feedback_store import FeedbackStore

store = FeedbackStore()

# Record technique usage
store.update_technique_stats(
    problem_type="{step.problemType}",
    technique="{primary_technique}",
    success={verification_passed},
    attempts={total_attempts}
)

# Update plan metrics
metrics = store.get_metrics()
if plan_complete:
    store.update_metrics(
        completed_plans_delta=1,
        total_steps=len(progress.steps),
        average_steps_per_plan=(
            (metrics['averageStepsPerPlan'] * metrics['totalPlans'] + len(progress.steps))
            / (metrics['totalPlans'] + 1)
        )
    )
```
```

### Success Output Enhancement

Update the success output to show feedback recorded:

```markdown
═══════════════════════════════════════════════════════════════
  ✅ STEP {N} COMPLETE
═══════════════════════════════════════════════════════════════

## Verification Results
✓ {AC1}
✓ {AC2}

## Implementation Summary
- Technique: {technique}
- Attempts: {attempts}
- Time: {duration}
- Feedback: Recorded ✓

## Effectiveness Update
- {problem_type} + {technique}: {success_rate}% ({sample_count} samples)

## Next Step
...
═══════════════════════════════════════════════════════════════
```

### Error Output Enhancement

Show what was tracked when failure occurs:

```markdown
═══════════════════════════════════════════════════════════════
  ⚠️ STEP {N} NEEDS ATTENTION
═══════════════════════════════════════════════════════════════

## What Failed
✗ {AC2}

## Implementation Attempts Tracked
{attempt_summary}

## Methods Tried
- {technique1}: {error1}
- {technique2}: {error2}

## Suggestion
Based on failure patterns, try: {suggested_alternative}
(This technique has {success_rate}% success for {problem_type})

═══════════════════════════════════════════════════════════════
```

## Files to Create
- None

## Files to Modify
- `.claude/commands/plan-next.md`: Add feedback integration

## Patterns to Follow
Reference: Existing step tracking in plan-next.md

## Acceptance Criteria
- [ ] Implementation attempts tracked during execution
- [ ] Outcomes recorded to effectiveness tracker
- [ ] Plan metrics updated on completion
- [ ] Attempt summary shown in step context
- [ ] Success/failure output shows feedback status
- [ ] All existing tests still pass

## Testing Requirements

### Integration Tests
- [ ] Test file: `.claude/tests/test_plan_next_integration.py`
- [ ] Test cases:
  - `test_step_start_records_attempt()`
  - `test_step_success_records_outcome()`
  - `test_step_failure_records_outcome()`
  - `test_metrics_updated_on_completion()`
  - `test_attempt_summary_displayed()`
  - `test_effectiveness_updates_after_threshold()`

### What to Test
- Full execution flow
- Feedback data persistence
- Metrics calculation
- Display formatting

## Verification Commands
```bash
# Test feedback files created
ls -la .claude/planning-data/

# Check effectiveness data
cat .claude/planning-data/technique-effectiveness.json | python3 -m json.tool

# Check attempts data
cat .claude/planning-data/implementation-attempts.json | python3 -m json.tool
```

## Documentation Updates
- [ ] Update plan-next.md with feedback sections

## Error Recovery
If verification fails:
1. Check feedback store imports
2. Verify file paths
3. Test recording functions in isolation

## Do NOT
- Skip recording on success
- Record partial results as final
- Break existing plan-next flow
