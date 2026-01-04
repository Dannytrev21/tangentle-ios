---
name: plan-next
description: Execute the next step in a plan with phase-based techniques and self-correction
---

# Plan Next

Execute plan steps with three-phase technique application, file tracking, and self-correction.

## Instructions

### Step 1: Locate Plan

```bash
PLAN_DIR=$(ls -d .windsurf/plans/$ARGS* 2>/dev/null | head -1)
```

If not found, list available plans:
```bash
ls .windsurf/plans/ | head -5
```

### Step 2: Load State

Read `$PLAN_DIR/progress.json`:
- `currentStep` - Step to execute
- `status` - Plan status
- Step details with techniques and retry config

### Step 3: Find Next Step

Priority:
1. Continue `in_progress` step
2. Execute first `pending` step
3. If all complete, show plan completion

### Step 4: Verify Prerequisites

```bash
# Check prompts exist
ls $PLAN_DIR/prompts/*.prompt.md 2>/dev/null | wc -l
```

If no prompts: "Run `/plan-prompts {NNN}` first."

Read `$PLAN_DIR/context.md` for prior decisions.

### Step 5: Display Summary

```
═══════════════════════════════════════
  PLAN: {Title} ({NNN})
  STEP: {N} of {Total} - {Name}
═══════════════════════════════════════

Problem Type: {type}
Risk Level: {level}

Techniques:
- Planning: {tech}
- Implementation: {tech}
- Verification: {tech}

Retry Budget: {same}/{alt}/{total}
═══════════════════════════════════════
```

### Step 6: Mark Started

Update progress.json:
```json
{
  "status": "in_progress",
  "startedAt": "{ISO}",
  "attempts": {current + 1}
}
```

### Step 7: Load Prompt

```bash
cat $PLAN_DIR/prompts/{NN}-{step}.prompt.md
```

### Step 8: Execute Phases

#### Phase A: Planning

Apply planning technique:
- **PS+**: Break down problem, create structured plan
- **ToT**: Evaluate multiple approaches
- **Least-to-Most**: Build from simple to complex

Output: Planning summary with approach decisions.

#### Phase B: Implementation

Apply implementation technique(s):
- **TDD**: Write tests first, then implement
- **Self-Refine**: Implement, get feedback, refine
- **Chain-of-Code**: Mix logic with semantic reasoning
- **Reflexion**: Implement with reflection on failures

**Track all file operations**:
```json
{
  "files": {
    "created": ["path/new.py"],
    "modified": ["path/existing.py"],
    "deleted": [],
    "renamed": []
  }
}
```

**Write tests before marking complete.**

#### Phase C: Verification

Apply verification technique:
- **Reflexion**: Record lessons in memory bank
- **Self-Consistency**: Multiple verification paths
- **TDD**: All tests must pass
- **GoT**: Aggregate verification findings

Check all acceptance criteria.

### Step 9: Handle Results

#### If ALL Pass:

Update progress.json:
```json
{
  "status": "completed",
  "completedAt": "{ISO}",
  "verificationPassed": true,
  "testsPassed": true,
  "testsWritten": ["tests/file.py"],
  "techniquesUsed": [
    {"technique": "{tech}", "phase": "planning", "attempts": 1},
    {"technique": "{tech}", "phase": "implementation", "attempts": 1},
    {"technique": "{tech}", "phase": "verification", "attempts": 1}
  ]
}
```

Advance `currentStep`.

Show commit prompt (Step 10).

#### If FAILED:

1. Record failure in memory bank:
```bash
python3 .windsurf/scripts/windsurf_plan.py memory add \
  --plan {NNN} --step {N} \
  --failure "{error}" --technique {tech}
```

2. Call self-correction:
```bash
python3 .windsurf/scripts/windsurf_plan.py retry \
  --plan {NNN} --step {N} \
  --technique {tech} \
  --failure "{error}" \
  --attempts-same {n} --attempts-alt {n}
```

3. Based on response:
   - **retry**: Re-attempt with same technique + guidance
   - **rotate**: Switch to alternative technique
   - **escalate**: Stop and report to user

##### Retry Same Technique
```
Attempt {n} of {max}
Technique: {current}
Guidance: {from memory bank}
```

##### Rotate Technique
```
Switching: {old} → {new}
Reason: {from failure pattern}
```

##### Escalate
```
═══════════════════════════════════════
  ⚠️ ESCALATION: All attempts exhausted
═══════════════════════════════════════

Techniques tried:
- {tech1}: {n} attempts
- {tech2}: {n} attempts

Options:
1. Provide guidance
2. Modify requirements
3. Mark blocked, continue
═══════════════════════════════════════
```

### Step 10: Commit Prompt

```
═══════════════════════════════════════
  Step {N} Complete
═══════════════════════════════════════

## Files Changed
Created: {list}
Modified: {list}

## Commit?
Suggested: `feat: Complete step {N} - {Title}`

(yes / no / custom)
═══════════════════════════════════════
```

If yes:
- Stage ONLY step files (**never .windsurf/**)
- Commit with message
- Update progress.json with commitHash

### Step 11: Update Context

Add to context.md:
```markdown
---

## Step {N} Complete - {date}

### Summary
{What was done}

### Technique Log
- Planning: {tech} - attempt 1
- Implementation: {tech} - attempt 1
- Verification: {tech} - attempt 1

### Files Created
- `{path}`: {purpose}

### Files Modified
- `{path}`: {changes}

### Tests
- `{file}`: {n} tests, all passing

### Verification
- [x] {AC1}
- [x] {AC2}

### Ready for Next
Step {N+1}: {Name}
```

### Step 12: Output

#### Success
```
═══════════════════════════════════════
  ✅ STEP {N} COMPLETE
═══════════════════════════════════════

✓ {AC1}
✓ {AC2}

Tests: {n} written, all passing
Files: {created} created, {modified} modified

Progress: {N}/{Total} ({%}%)
[████████░░]

Next: Step {N+1} - {Name}
Run `/plan-next {NNN}` to continue.
═══════════════════════════════════════
```

#### Partial Failure
```
═══════════════════════════════════════
  ⚠️ STEP {N} NEEDS ATTENTION
═══════════════════════════════════════

Passed:
✓ {AC1}

Failed:
✗ {AC2}: {error}

Attempted:
1. {fix1} → {result}
2. {fix2} → {result}

State saved. Resume with `/plan-next`.
═══════════════════════════════════════
```

## Special Cases

### First Step
If currentStep = 1:
- Set plan status to "in_progress"
- Initialize context.md

### Last Step
If step = totalSteps and passes:
- Set plan status to "completed"
- Show completion summary

```
═══════════════════════════════════════
  🎉 PLAN COMPLETE: {Title}
═══════════════════════════════════════

Steps: {N} of {N}
Files Created: {count}
Files Modified: {count}
Tests: {count} total

Recommended:
1. Run full test suite
2. Code review
3. Update documentation
═══════════════════════════════════════
```

### Resume After Compact
If context.md has in_progress step:
1. Show previous session state
2. Verify files exist
3. Continue from last checkpoint

## Test Enforcement

Steps CANNOT be marked complete unless:
- Tests written (for new code)
- All tests pass
- testsWritten recorded in progress.json

## File Tracking

During implementation, track ALL:
- New files → files.created
- Changed files → files.modified
- Removed files → files.deleted
- Renamed files → files.renamed

## Do NOT

- Mark complete without tests passing
- Stage .windsurf/** files
- Skip file tracking
- Exceed retry budget silently
- Auto-commit without user confirmation
