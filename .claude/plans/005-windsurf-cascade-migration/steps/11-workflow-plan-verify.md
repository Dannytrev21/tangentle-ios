# Step 11: Workflow - /plan-verify

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Structure verification flow
- **Implementation**: tdd - Test verification accuracy
- **Verification**: reflexion - Learn from verification gaps

## Risk Level
**high** - Verification accuracy is critical

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 3 attempts
- Escalation: After 5 total failures

## Context
`/plan-verify` re-runs verification for the current step. It extracts verification criteria from the step prompt, executes each check, reports explicit PASS/FAIL, and applies technique-specific verification when metadata exists.

## Goal
Create the `/plan-verify` workflow that re-runs verification with technique-aware checking.

## Prerequisites
- Step 9 completed (plan-next does initial verification)
- Step 8 completed (prompts contain verification section)

## High-Level Steps
1. Load plan state and current step
2. Extract verification section from step prompt
3. Parse acceptance criteria and commands
4. Execute each verification command
5. Apply technique-specific verification
6. Report results with PASS/FAIL
7. Update progress.json if all pass
8. Trigger self-correction if failures

## Detailed Requirements

### Verification Extraction
From step prompt, extract:
1. **Acceptance Criteria** - `- [ ]` items under "## Acceptance Criteria"
2. **Verification Commands** - Commands under "## Verification Commands"
3. **Testing Requirements** - Test files and expected behaviors

### Verification Execution

#### Command Execution
For each verification command:
```bash
# Run command
{command}

# Capture exit code and output
if [ $? -eq 0 ]; then
  echo "✅ PASS: {command description}"
else
  echo "❌ FAIL: {command description}"
  echo "Output: {output}"
fi
```

#### Technique-Specific Verification
Apply additional checks based on step technique:

| Technique | Additional Verification |
|-----------|------------------------|
| TDD | Run tests again, check coverage |
| Reflexion | Check lessons applied from memory bank |
| Self-Consistency | Run multiple times, compare outputs |
| Self-Refine | Check for improvement from last attempt |
| GoT | Verify merged solution addresses all branches |

### Result Reporting

```markdown
## Verification Results: Step {N}

### Acceptance Criteria
- ✅ PASS: All tests pass
- ✅ PASS: Build succeeds
- ❌ FAIL: API endpoint returns 200
- ✅ PASS: Documentation updated

### Command Results
| Command | Result | Output |
|---------|--------|--------|
| `xcodebuild build` | ✅ PASS | Build succeeded |
| `xcodebuild test` | ❌ FAIL | 2 tests failed |

### Technique Verification: {technique}
{technique-specific results}

### Summary
- **Passed**: {N}/{total}
- **Failed**: {N}/{total}
- **Overall**: {PASS / FAIL}

{if FAIL: self-correction suggestion}
```

### Self-Correction Integration
If verification fails:
1. Call self-correction engine
2. Get retry/rotate/escalate decision
3. Output guidance for next attempt
4. Update progress.json with attempt count

### Progress Update
If all verifications pass:
```json
{
  "steps": [{
    "verificationPassed": true,
    "lastVerifiedAt": "2026-01-02T..."
  }]
}
```

## Files to Create
- `.windsurf/workflows/plan-verify.md`

## Files to Modify
- Plan's `progress.json` (verification status)

## Patterns to Follow
Reference: `.claude/commands/plan-verify.md` for structure

## Acceptance Criteria
- [ ] Workflow file under 12,000 characters
- [ ] Extracts AC from step prompt
- [ ] Runs all verification commands
- [ ] Reports PASS/FAIL explicitly per item
- [ ] Applies technique-specific verification
- [ ] Integrates with self-correction on failure
- [ ] Updates progress.json on success

## Testing Requirements

### Unit Tests
**N/A** - Workflow tested via execution.

### Integration Tests
- [ ] Create step with known passing verification
- [ ] Run `/plan-verify {plan}`
- [ ] Verify all items show ✅ PASS
- [ ] Create step with failing verification
- [ ] Run `/plan-verify {plan}`
- [ ] Verify ❌ FAIL items shown
- [ ] Verify self-correction triggered

### Manual Verification
- [ ] Command output captured accurately
- [ ] Technique-specific checks applied
- [ ] Self-correction guidance helpful

## Verification Commands
```bash
# Check progress after verification
python3 -c "
import json
with open('.windsurf/plans/{NNN}-xxx/progress.json') as f:
    p = json.load(f)
    for s in p['steps']:
        print(f\"Step {s['id']}: verified={s.get('verificationPassed', 'N/A')}\")
"
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check command paths are correct
2. Verify AC parsing is accurate
3. Check technique detection logic
4. Ensure self-correction is invoked

## Do NOT
- Mark verification passed if any item fails
- Skip technique-specific verification
- Suppress command output
- Ignore self-correction budget
