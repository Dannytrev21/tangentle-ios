# Plan Next Command

You are executing the next step in an implementation plan. This command handles:
1. Finding the current step
2. Loading the prompt
3. Executing the implementation
4. Verifying completion
5. Updating progress
6. Preparing context for next session

## Input
Plan identifier: $ARGUMENTS

## Process

### Step 1: Locate and Validate Plan
```bash
# Find the plan directory
PLAN_DIR=$(ls -d .claude/plans/$ARGUMENTS* 2>/dev/null | head -1)
```

If not found, list available plans:
```bash
ls -la .claude/plans/
```

### Step 2: Load Current State
Read the progress file:
```bash
cat $PLAN_DIR/progress.json
```

Extract:
- `currentStep` - The step number to execute
- `status` - Overall plan status
- `steps[currentStep-1]` - Current step details

### Step 3: Verify Prompts Exist
Check if prompts have been generated:
```bash
ls $PLAN_DIR/prompts/*.prompt.md 2>/dev/null | wc -l
```

If no prompts exist, inform user:
```
Prompts not yet generated for this plan.
Run `/plan-prompts $ARGUMENTS` first.
```

### Step 4: Load Context
Read accumulated context for continuity:
```bash
cat $PLAN_DIR/context.md
```

This provides:
- What's been completed
- Key decisions made
- Files created/modified
- Things to remember

### Step 5: Display Step Summary
Before starting, show:

```
═══════════════════════════════════════════════════════════════
  PLAN: {Plan Name} ({NNN})
  STEP: {N} of {Total} - {Step Name}
  STATUS: {Previous step status}
═══════════════════════════════════════════════════════════════

## Previous Context
{Summary from context.md}

## This Step Will:
{Brief description from step file}

## Prerequisites
{List of dependencies}

## Estimated Time: {estimate}

Ready to proceed? Starting implementation...
═══════════════════════════════════════════════════════════════
```

### Step 5.5: Display Technique Information

If the step has technique assignments in progress.json (technique-aware plans), display before execution:

```
═══════════════════════════════════════════════════════════════
  STEP EXECUTION: {N} of {Total} - {Step Name}
═══════════════════════════════════════════════════════════════

  Problem Type: {step.problemType}
  Risk Level: {step.riskLevel}

  Techniques:
  ┌─────────────────┬────────────────────────────────────────┐
  │ Planning        │ {step.techniques.planning}             │
  │ Implementation  │ {step.techniques.implementation}       │
  │ Verification    │ {step.techniques.verification}         │
  └─────────────────┴────────────────────────────────────────┘

  Retry Budget:
  - Same technique: {step.retryConfig.maxSameTechnique} attempts
  - Alternative: {step.retryConfig.maxAlternative} attempts
  - Total budget: {step.retryConfig.maxTotal}

═══════════════════════════════════════════════════════════════
```

**Note**: For plans without technique metadata (legacy plans), skip this section and proceed with standard execution.

### Step 5.6: Load Implementation Context (Feedback Integration)

Before execution, load any previous implementation attempts for this step:

```python
import sys
sys.path.insert(0, '.claude/scripts')
from feedback_store import FeedbackStore
from implementation_tracker import ImplementationTracker

store = FeedbackStore()
store.ensure_directory()
tracker = ImplementationTracker(store)
summary = tracker.get_attempt_summary('{plan_id}', {step_id})
print(summary)
```

If there are previous attempts, include in the step display:

```
═══════════════════════════════════════════════════════════════
  IMPLEMENTATION CONTEXT
═══════════════════════════════════════════════════════════════

  ## Previous Implementation Attempts

  {attempt_summary}

  ## Suggested Technique
  Based on history: {recommended technique}
  (Avoiding: {failed techniques})

═══════════════════════════════════════════════════════════════
```

To get suggested technique if previous attempts exist:

```python
import sys
sys.path.insert(0, '.claude/scripts')
from feedback_store import FeedbackStore
from implementation_tracker import ImplementationTracker

store = FeedbackStore()
tracker = ImplementationTracker(store)

# Get available techniques from step config
available = ["{step.techniques.implementation}"]  # From progress.json

suggestion = tracker.suggest_next_technique('{plan_id}', {step_id}, available)
failed = tracker.get_failed_techniques('{plan_id}', {step_id})

if suggestion:
    print(f"Suggested: {suggestion}")
if failed:
    print(f"Avoiding: {', '.join(failed)}")
```

### Step 6: Load and Execute Prompt with Technique Phases
Read the prompt file:
```bash
cat $PLAN_DIR/prompts/{NN}-{step-name}.prompt.md
```

### Context Awareness
Before starting this step, check your context usage:
```bash
# Run /context to see current usage
```

| Current Usage | Recommendation |
|---------------|----------------|
| Under 70% | Proceed normally |
| 70-84% | Consider `/compact` after step completion |
| 85%+ | `/compact` now before starting |
| 93%+ | `/clear` and read context.md to resume |

**Step Position Consideration**:
- Step 1: Full context available
- Steps 2-4: Normal context usage expected
- Steps 5+: Monitor context more carefully
- Long plans (8+ steps): Consider fresh sessions

Then execute the prompt contents using technique phases (if technique-aware plan):

#### Phase A: Planning

If the step has a planning technique assigned:

1. Locate the **Planning Methodology** section in the prompt
2. Execute the planning steps as described by the technique:
   - **ToT (Tree of Thoughts)**: Generate multiple approaches, evaluate each, select best
   - **PS+ (Plan-and-Solve Plus)**: Break down problem, create structured plan
   - **Self-Consistency**: Generate multiple plans, find consensus
3. Document planning decisions in your notes
4. **Log**: "Planning phase complete using {technique}"

For steps without a planning methodology section, proceed to implementation.

#### Phase B: Implementation

**Record Attempt Start** (Feedback Integration):
Before starting implementation, record the attempt:

```python
import sys
sys.path.insert(0, '.claude/scripts')
from feedback_store import FeedbackStore
from implementation_tracker import ImplementationTracker

store = FeedbackStore()
store.ensure_directory()
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

Execute using the assigned implementation technique(s):

1. Load the **Implementation Methodology** section from the prompt
2. For single technique:
   - Execute according to technique methodology
   - **TDD**: Write tests first, then implementation
   - **Self-Refine**: Implement, generate feedback, refine
   - **Reflexion**: Implement with reflection on past failures
   - **Chain-of-Code**: Mix executable logic with semantic reasoning
3. For multi-technique steps (e.g., ["tdd", "self-refine"]):
   - Execute primary technique first (TDD: write tests, implement)
   - Apply secondary technique (Self-Refine: polish implementation)
4. Track which techniques were actually used
5. **Log**: "Implementation complete using {technique(s)}"

#### Phase C: Verification

Apply the verification technique:

1. Load the **Verification Methodology** section from prompt
2. Execute based on assigned technique:
   - **Reflexion**: Set up memory bank for lessons, track what worked/failed
   - **Self-Consistency**: Run verification multiple ways, check agreement
   - **TDD**: Run test suite, all tests must pass
   - **Self-Refine**: Generate quality feedback, iterate if needed
   - **GoT (Graph of Thoughts)**: Aggregate findings from multiple paths
3. Record verification outcome
4. **Log**: "Verification using {technique}"

#### Standard Execution (Legacy Plans)

For plans without technique metadata, use the standard flow:

1. **Pre-Implementation Checklist**
   - Read all required files
   - Verify prerequisites
   - Understand current state

2. **Implementation**
   - Follow step-by-step instructions
   - Apply patterns from examples
   - Handle edge cases

3. **Verification**
   - Run all verification commands
   - Check all acceptance criteria
   - Fix any failures

4. **Testing (MANDATORY)**
   - Write tests as specified in the step's Testing Requirements
   - Run tests and ensure they pass
   - A step CANNOT be marked complete without passing tests

5. **Completion Protocol**
   - Update progress.json (including testsWritten and testsPassed)
   - Update context.md
   - Update documentation if required

### Step 7: Handle Verification Results with Self-Correction

For technique-aware plans, use the step's retry configuration for self-correction. For legacy plans, use the default 2-attempt limit.

#### Pre-Completion Check: Tests Required
Before marking any step complete, verify:
1. Tests are written per the Testing Requirements section
2. All tests pass when run
3. Test file paths are recorded

```bash
# Run tests for the feature
xcodebuild test -scheme Tangentle -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:TangentleTests 2>&1 | tail -20
```

**If tests are missing or failing, the step is NOT complete.**

#### Self-Correction Protocol (Technique-Aware Plans)

If verification fails, apply self-correction based on retry configuration:

##### Attempt 1 of {maxSameTechnique} (Same Technique)
```
Current: Attempt 1 of {step.retryConfig.maxSameTechnique}
Technique: {current_technique}
```

1. Read error/failure details carefully
2. Apply technique-specific recovery:
   - **Reflexion**: Add failure to memory bank, consult lessons learned
   - **TDD**: Analyze failing tests, fix implementation to match
   - **Self-Refine**: Generate feedback on what went wrong, apply refinement
   - **Chain-of-Code**: Check if LMulator/executable boundary is correct
3. Retry implementation with same technique
4. Record: "Attempt {n}: {what was tried} → {outcome}"

##### If Same Technique Exhausted → Rotate Technique
```
Switching technique: {current} → {alternative}
Attempt 1 of {step.retryConfig.maxAlternative}
```

1. Load alternative technique from rotation (e.g., Self-Refine → Reflexion)
2. Regenerate approach using new technique methodology
3. Retry implementation with new technique
4. Record: "Rotated from {old} to {new}: {rationale}"

##### If All Retries Exhausted → Escalate
```
═══════════════════════════════════════════════════════════════
  ⚠️ ESCALATION REQUIRED
  All {step.retryConfig.maxTotal} attempts exhausted.
═══════════════════════════════════════════════════════════════

  Techniques tried:
  - {technique1}: {attempts} attempts
  - {technique2}: {attempts} attempts

  Last error: {error_summary}

  Options:
  1. Review error details and provide guidance
  2. Modify step requirements
  3. Mark as blocked and continue with next step
  4. Manual intervention needed
═══════════════════════════════════════════════════════════════
```

1. Document all attempts and failures
2. Save partial progress to progress.json
3. Update context.md with detailed failure log
4. **Do NOT mark step as failed without user input**

#### Record Outcome (Feedback Integration)

After verification completes (pass or fail), record the outcome:

**On Success:**

```python
import sys
sys.path.insert(0, '.claude/scripts')
from feedback_store import FeedbackStore
from effectiveness_tracker import EffectivenessTracker
from implementation_tracker import ImplementationTracker

store = FeedbackStore()
store.ensure_directory()

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
metrics = store.get_metrics()
store.update_metrics(completedSteps=metrics["completedSteps"] + 1)

print("Feedback recorded successfully")
```

**On Failure (during self-correction):**

```python
import sys
sys.path.insert(0, '.claude/scripts')
from feedback_store import FeedbackStore
from implementation_tracker import ImplementationTracker

store = FeedbackStore()
store.ensure_directory()

# Record implementation attempt outcome (for retry tracking)
impl_tracker = ImplementationTracker(store)
impl_tracker.end_attempt(
    plan_id="{plan_id}",
    step_id={step_id},
    success=False,
    error_summary="{brief error description}"
)

# NOTE: Don't record to effectiveness tracker on partial failure
# Only record when step is fully given up on
```

**On Final Failure (after all retries exhausted):**

```python
import sys
sys.path.insert(0, '.claude/scripts')
from feedback_store import FeedbackStore
from effectiveness_tracker import EffectivenessTracker

store = FeedbackStore()
store.ensure_directory()

# Record effectiveness failure
eff_tracker = EffectivenessTracker(store)
eff_tracker.record_outcome(
    problem_type="{step.problemType}",
    technique="{technique_used}",
    success=False,
    attempts={total_attempts}
)
```

#### If ALL Acceptance Criteria AND Tests Pass:

1. **Update progress.json** with technique tracking:
```javascript
// Read current progress
const progress = JSON.parse(fs.readFileSync('progress.json'));

// Update current step - Standard fields
progress.steps[currentStep - 1].status = 'completed';
progress.steps[currentStep - 1].completedAt = new Date().toISOString();
progress.steps[currentStep - 1].verificationPassed = true;
progress.steps[currentStep - 1].testsPassed = true;
progress.steps[currentStep - 1].testsWritten = ['TestFile1.swift', 'TestFile2.swift'];
progress.steps[currentStep - 1].attempts = (progress.steps[currentStep - 1].attempts || 0) + 1;

// Technique tracking (for technique-aware plans)
progress.steps[currentStep - 1].techniquesUsed = [
  // Record actual techniques used in each phase
  {"technique": "ps-plus", "phase": "planning", "attempts": 1},
  {"technique": "chain-of-code", "phase": "implementation", "attempts": 1},
  {"technique": "reflexion", "phase": "verification", "attempts": 2}
];
progress.steps[currentStep - 1].finalAttempt = 2;
progress.steps[currentStep - 1].techniqueRotations = 0;  // How many times we switched techniques
progress.steps[currentStep - 1].selfCorrectionNotes = [
  // If any retries occurred, document what happened
  "Attempt 1: Failed due to missing edge case",
  "Attempt 2: Added nil check, succeeded"
];

// Advance to next step
progress.currentStep = currentStep + 1;
progress.updatedAt = new Date().toISOString();

// Update context
progress.context.filesCreated.push(...newFiles);
progress.context.filesModified.push(...modifiedFiles);
progress.context.testsCreated.push(...newTestFiles);
progress.context.learnings.push(anyLearnings);

// Check if plan complete
if (progress.currentStep > progress.totalSteps) {
  progress.status = 'completed';
}

fs.writeFileSync('progress.json', JSON.stringify(progress, null, 2));
```

2. **Update context.md** with technique execution log:

For technique-aware plans, include the technique execution log:
```markdown
---

## Step {N} Complete - {timestamp}

### Summary
{What was accomplished}

### Technique Execution Log
- **Planning**: {technique} - success on attempt 1
- **Implementation**: {technique} - success on attempt 1
- **Verification**: {technique} - success on attempt {n}
  - Attempt 1: Failed due to {reason}
  - Lesson learned: {lesson}
  - Attempt 2: Applied {fix}, succeeded

### Files Created
- `{path}`: {purpose}

### Files Modified
- `{path}`: {what changed}

### Tests Written
- `TangentleTests/Unit/{TestFile}.swift`: {N} test cases
- Status: All passing

### Verification Results
- [x] {AC1}: Passed
- [x] {AC2}: Passed
- [x] {AC3}: Passed
- [x] All tests pass

### Key Decisions
- {decision made}: {rationale}

### Learnings
- {anything learned}

### Ready for Next Step
Step {N+1}: {Next step name}
Prerequisites met: {yes/no}
```

For legacy plans without technique metadata, omit the "Technique Execution Log" section.

3. **Output Success**:
```
═══════════════════════════════════════════════════════════════
  ✅ STEP {N} COMPLETE
═══════════════════════════════════════════════════════════════

## Verification Results
✓ {AC1}
✓ {AC2}
✓ {AC3}

## Tests
✓ {N} tests written
✓ All tests passing
  Files: {list of test files}

## Files Changed
Created: {list}
Modified: {list}

## Implementation Summary
- Technique: {technique_used}
- Attempts: {step.attempts}
- Feedback: Recorded ✓

## Progress
{N}/{Total} steps complete ({percentage}%)
{visual progress bar}

## Next Step
Step {N+1}: {Next step name}

Run `/plan-next $ARGUMENTS` to continue.
═══════════════════════════════════════════════════════════════
```

#### If Verification PARTIALLY Passes:

1. **Identify Specific Failures**
```
## Verification Results
✓ {AC1}: Passed
✗ {AC2}: FAILED - {reason}
✓ {AC3}: Passed
```

2. **Attempt Self-Correction**
For each failure:
- Read the error message
- Check error recovery section in prompt
- Apply appropriate fix
- Re-run verification

3. **If Fix Succeeds**
Continue with completion protocol.

4. **If Fix Fails After 2 Attempts**
```
═══════════════════════════════════════════════════════════════
  ⚠️ STEP {N} NEEDS ATTENTION
═══════════════════════════════════════════════════════════════

## What Worked
✓ {AC1}
✓ {AC3}

## What Failed
✗ {AC2}
  Error: {error message}
  Attempted fixes:
  1. {fix 1} - {result}
  2. {fix 2} - {result}

## Implementation Attempts Tracked
{attempt_summary from impl_tracker.get_attempt_summary()}

## Suggested Alternative
Based on failure patterns, try: {suggested_technique}
(This technique has not been tried or has better history)

## Recommended Actions
1. Review the error in detail
2. Check if spec needs adjustment
3. Try suggested alternative technique
4. Manual debugging may be needed

## Progress Saved
Current state has been preserved in:
- progress.json (step marked as 'blocked')
- context.md (failure details recorded)
- planning-data/ (attempts tracked)

Resume with `/plan-next $ARGUMENTS` after fixing.
═══════════════════════════════════════════════════════════════
```

Update progress.json:
```json
{
  "steps[N-1].status": "blocked",
  "steps[N-1].attempts": 2,
  "steps[N-1].notes": "Failed verification: {specific failure}",
  "context.blockers": ["Step {N}: {failure description}"]
}
```

#### If ALL Verification Fails:

1. **Do NOT mark any progress**
2. **Document the failure thoroughly**
3. **Preserve all state for debugging**

```
═══════════════════════════════════════════════════════════════
  ❌ STEP {N} FAILED
═══════════════════════════════════════════════════════════════

## All Verifications Failed
✗ {AC1}: {error}
✗ {AC2}: {error}
✗ {AC3}: {error}

## Possible Causes
1. Prerequisites not met
2. Spec misunderstood
3. Breaking change in dependencies

## State Preserved
No changes committed. Working state in:
- {files with changes}

## Recovery Options
1. `/plan-verify $ARGUMENTS` - Re-run verification only
2. `/plan-rollback $ARGUMENTS` - Discard changes
3. Manual review and fix

## Debug Information
{Relevant error logs}
{State of affected files}
═══════════════════════════════════════════════════════════════
```

### Step 8: Prepare for Next Session
Always update context.md with session summary, even on failure:

```markdown
---

## Session End - {timestamp}

### Work Attempted
Step {N}: {Step name}

### Result
{Completed / Partial / Failed}

### Current State
{Description of where things stand}

### To Resume
1. Read this context.md
2. Run `/plan-next $ARGUMENTS`
3. {Any specific instructions}

### Files in Progress
{List of files being worked on}

### Known Issues
{Any issues to be aware of}
```

## Special Cases

### First Step of Plan
If `currentStep === 1`:
- Set `status: "in_progress"` in progress.json
- Create initial context.md content
- Verify all prerequisites from plan.md

### Last Step of Plan
If `currentStep === totalSteps` and verification passes:
- Set `status: "completed"` in progress.json
- Generate completion summary
- Suggest follow-up actions

```
═══════════════════════════════════════════════════════════════
  🎉 PLAN COMPLETE: {Plan Name}
═══════════════════════════════════════════════════════════════

## Summary
- Started: {date}
- Completed: {date}
- Duration: {time}
- Steps: {N} of {N} complete

## Files Created
{list}

## Files Modified
{list}

## Tests Created
{list of test files}
Total: {N} test cases across {M} test files

## Documentation Updated
{list}

## Key Achievements
{from context.md learnings}

## Recommended Follow-ups
1. Run full test suite: `xcodebuild test -scheme Tangentle ...`
2. Check test coverage report
3. Manual QA testing
4. Code review
5. Update related documentation
═══════════════════════════════════════════════════════════════
```

### Resuming After Compact/New Session
If context.md exists with recent session data:
1. Display previous session summary
2. Show what was in progress
3. Verify state before continuing
4. Resume from last known good state

## Quality Assurance

### Before Each Step
- [ ] Prerequisites verified
- [ ] Required files read
- [ ] Context loaded
- [ ] Testing requirements reviewed

### During Implementation
- [ ] Following established patterns
- [ ] Handling edge cases
- [ ] No debug code left
- [ ] Writing tests alongside implementation

**Context Warning Signs**:
If you notice:
- Responses becoming shorter or less detailed
- Missing context from earlier in conversation
- Confusion about previously discussed topics
- Repeated questions about things already established

**Stop and check**: Run `/context` to verify usage.

**If context is high** (85%+):
1. Write current progress to context.md
2. Commit all changes: `git add -A && git commit -m "progress: step {N} in progress"`
3. Run `/clear`
4. Resume: "Read .claude/plans/{NNN}/context.md and continue step {N}"

### After Each Step
- [ ] All AC verified
- [ ] **Tests written and passing** (MANDATORY)
- [ ] Progress updated (including testsWritten)
- [ ] Context updated (including tests created)
- [ ] Ready for next step

### Post-Step Context Management
After completing this step:

1. **Update context.md** with:
   - What was completed
   - Files created/modified
   - Key decisions made
   - Any learnings

2. **Check context usage**:
   - If 70%+: Consider `/compact` before next step
   - If multi-step session: Commit progress

3. **For long plans (8+ steps)**:
   - Consider fresh session for next step
   - context.md preserves state across sessions
   - Each step can be executed independently

### Testing Checklist
- [ ] Unit tests for new functions/methods
- [ ] Integration tests if components interact
- [ ] UI tests for user-facing changes
- [ ] Edge cases covered
- [ ] Error handling tested
- [ ] All tests pass: `xcodebuild test -scheme Tangentle ...`

## Document and Clear Pattern
For multi-session work or when context is high:

### Pattern
1. **Document current state**:
   Update `.claude/plans/{NNN}/context.md` with:
   - Current step and status
   - Work completed
   - Key decisions
   - Next actions

2. **Commit everything**:
   ```bash
   git add -A && git commit -m "progress: step {N} documented for session break"
   ```

3. **Clear context**:
   ```bash
   /clear
   ```

4. **Resume in fresh session**:
   ```
   Read .claude/plans/{NNN}/context.md and continue from where we left off
   ```

### When to Use
- Context usage approaching 85%
- Taking a break from work
- Switching to unrelated task
- Before starting a complex step
- At end of day

This gives you fresh 200K context while preserving all progress.
