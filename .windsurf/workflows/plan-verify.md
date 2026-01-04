---
name: plan-verify
description: Re-run verification for current step with technique-aware checking
---

# Plan Verify

Re-run verification for a step to check fixes or ensure nothing regressed.

## Instructions

### Step 1: Locate Plan and Step

```bash
PLAN_DIR=$(ls -d .windsurf/plans/$ARGS* 2>/dev/null | head -1)
cat $PLAN_DIR/progress.json
```

Find step to verify:
1. If step has `status: "in_progress"` → verify that step
2. Otherwise → verify most recent `completed` step
3. Extract step's technique assignments from `techniques.verification`

### Step 2: Load Verification Content

Read the step's prompt file:
```bash
cat $PLAN_DIR/prompts/{NN}-{step-name}.prompt.md
```

Extract:
1. **Acceptance Criteria**: Lines starting with `- [ ]`
2. **Verification Commands**: Code blocks after `Verify:`
3. **Expected Outputs**: Text after commands

### Step 3: Run Verification Commands

For each acceptance criterion:

```bash
# Run verification command
output=$({command} 2>&1)
exit_code=$?

if [ $exit_code -eq 0 ]; then
  echo "✅ PASS: {description}"
else
  echo "❌ FAIL: {description}"
  echo "Output: $output"
fi
```

Track results:
- `passed_count` - Number passing
- `failed_count` - Number failing
- `failed_details` - Error messages

### Step 4: Technique-Specific Verification

Check `step.techniques.verification` and apply additional checks:

#### TDD Verification
```
═══════════════════════════════════════
  Verification Mode: TDD
  Expected: All tests pass
═══════════════════════════════════════
```

- Run test suite for this step's files
- Report: X/Y tests passing
- Show failing test names and expected vs actual

#### Reflexion Verification
```
═══════════════════════════════════════
  Verification Mode: Reflexion
  Memory Bank: {lessons from attempts}
═══════════════════════════════════════
```

- Check memory bank for lessons about this step
- Verify lessons were applied in implementation
- Report: NEW failure or REPEAT (in memory bank)

#### Self-Consistency Verification
```
═══════════════════════════════════════
  Verification Mode: Self-Consistency
  Runs: 3 independent verifications
  Threshold: 2/3 agreement required
═══════════════════════════════════════
```

- Run verification commands 3 times
- Compare outputs for consistency
- Report agreement level

#### Self-Refine Verification
```
═══════════════════════════════════════
  Verification Mode: Self-Refine
  Quality Threshold: 90%
═══════════════════════════════════════
```

- Generate quality feedback against AC
- Score against 90% threshold
- Suggest refinements if below threshold

#### GoT Verification
```
═══════════════════════════════════════
  Verification Mode: GoT
  Aggregation: Multiple verification paths
═══════════════════════════════════════
```

- Run multiple verification approaches
- Aggregate findings from different paths
- Report consolidated results

#### Standard Verification (Legacy)
For steps without technique metadata, use standard flow from Step 3.

### Step 5: Report Results

#### All Pass
```
═══════════════════════════════════════
  ✅ VERIFICATION PASSED
═══════════════════════════════════════

All {N} acceptance criteria passed.

## Results
✓ AC1: {description}
✓ AC2: {description}
✓ AC3: {description}

## Next Action
Run `/plan-next {NNN}` to:
1. Mark step as complete
2. Update progress tracking
3. Advance to next step
═══════════════════════════════════════
```

#### Partial Pass
```
═══════════════════════════════════════
  ⚠️ VERIFICATION PARTIAL
═══════════════════════════════════════

{X} of {N} acceptance criteria passed.

## Results
✓ AC1: {description}
✗ AC2: {description}
  Error: {error details}
✓ AC3: {description}

## Failed Criterion Details
### AC2: {description}
**Command**: {command}
**Expected**: {expected}
**Actual**: {actual}

**Possible Causes**:
1. {cause 1}
2. {cause 2}

**Suggested Fixes**:
1. {fix 1}
2. {fix 2}

## Next Actions
1. Review failed criterion
2. Apply suggested fix
3. Run `/plan-verify {NNN}` again
═══════════════════════════════════════
```

#### All Fail
```
═══════════════════════════════════════
  ❌ VERIFICATION FAILED
═══════════════════════════════════════

All {N} acceptance criteria failed.

## Results
✗ AC1: {description} - {error}
✗ AC2: {description} - {error}

## Analysis
This likely indicates:
- Prerequisites not met
- Fundamental implementation issue
- Environment problem

## Recommended Actions
1. Check prerequisites
2. Verify environment
3. Review implementation against spec
4. Consider rollback: `/plan-rollback {NNN}`
═══════════════════════════════════════
```

### Step 6: Handle Failures

If verification fails, apply self-correction:

1. **Record failure in memory bank**:
```bash
python3 .windsurf/scripts/windsurf_plan.py memory add \
  --plan {NNN} --step {N} \
  --failure "{error}" --technique {tech}
```

2. **Get retry guidance**:
```bash
python3 .windsurf/scripts/windsurf_plan.py retry \
  --plan {NNN} --step {N} \
  --technique {tech} \
  --failure "{failure details}" \
  --attempts-same {n} --attempts-alt {n}
```

3. **Output guidance based on response**:

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
  ⚠️ ESCALATION REQUIRED
═══════════════════════════════════════

All attempts exhausted.

Techniques tried:
- {tech1}: {n} attempts
- {tech2}: {n} attempts

Options:
1. Review and provide guidance
2. Modify requirements
3. Mark as blocked
═══════════════════════════════════════
```

### Step 7: Update Progress

After verification, update progress.json:

```python
python3 -c "
import json
from datetime import datetime

with open('$PLAN_DIR/progress.json', 'r') as f:
    p = json.load(f)

step = p['steps'][{N-1}]
step['lastVerifiedAt'] = datetime.now().isoformat()
step['verificationPassed'] = {True/False}

with open('$PLAN_DIR/progress.json', 'w') as f:
    json.dump(p, f, indent=2)
"
```

## Technique Failure Recovery

| Technique | Key Recovery Steps |
|-----------|-------------------|
| TDD | Tests={pass}/{total}. Read assertions, fix impl (test=spec) |
| Reflexion | Check memory bank for lessons, mark NEW/REPEAT failure |
| Self-Consistency | Run 3x, need 2/3 agree. Check race conditions |
| Self-Refine | Score vs 90%. Iterate up to 3 times |
| GoT | Aggregate paths, resolve conflicts |

## Technique Switch Suggestions

| Pattern | Switch | Reason |
|---------|--------|--------|
| Async failures | TDD→ReAct | Action-observation |
| Not converging | Self-Refine→Reflexion | Persistent memory |
| Inconsistent | Standard→Self-Consistency | Find non-determinism |

## Output Example

```
═══════════════════════════════════════
  VERIFICATION: Step 11 - plan-verify
═══════════════════════════════════════

## Acceptance Criteria
✅ PASS: Workflow under 12,000 characters
✅ PASS: Extracts AC from step prompt
❌ FAIL: Reports PASS/FAIL per item
✅ PASS: Updates progress.json

## Command Results
| Command | Result |
|---------|--------|
| `wc -c < workflow` | ✅ PASS |
| `grep -c "- \[ \]"` | ✅ PASS |

## Technique Verification: TDD
- Tests run: 8
- Tests passed: 6
- Tests failed: 2

## Summary
- **Passed**: 3/4 criteria
- **Overall**: ⚠️ PARTIAL

## Self-Correction Guidance
Action: retry
Guidance: Check output formatting
═══════════════════════════════════════
```

## Do NOT

- Do NOT mark verification passed if any item fails
- Do NOT skip technique-specific verification
- Do NOT suppress command output (needed for debugging)
- Do NOT ignore self-correction budget
- Do NOT exceed 12,000 character limit
