# Step 9: Workflow - /plan-next

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Structure complex execution flow
- **Implementation**: tdd - Test phase transitions and state updates
- **Verification**: reflexion - Learn from execution issues

## Risk Level
**high** - Core execution engine; affects all plan implementations

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 3 attempts
- Escalation: After 5 total failures

## Context
`/plan-next` is the execution engine. It loads plan state, executes the next pending step using phase-based techniques, enforces mandatory testing, tracks file changes, supports self-correction on failure, and updates progress state.

## Goal
Create the `/plan-next` workflow with phase-based execution, file tracking, test enforcement, self-correction, and commit prompting.

## Prerequisites
- Step 5 completed (self-correction engine)
- Step 8 completed (prompts generated)

## High-Level Steps
1. Load plan state and find next pending step
2. Load step prompt
3. Execute Planning phase
4. Execute Implementation phase (with file tracking)
5. Execute Verification phase (test enforcement)
6. Handle failures with self-correction
7. Update progress.json with results
8. Update context.md with learnings
9. Prompt for commit
10. Advance to next step or complete plan

## Detailed Requirements

### Plan Selection
If no plan number provided:
1. List all plans with `progress.json`
2. Select plan with most recent `updatedAt`
3. If tie, prompt user to choose

### Step Selection
Find the next step to execute:
1. If a step is `in_progress`, continue it
2. Otherwise, find first `pending` step
3. If all steps complete, report plan completion

### Phase-Based Execution

#### Planning Phase
1. Read prompt file
2. Apply planning technique (from step.techniques.planning)
3. Understand requirements
4. Identify approach
5. Output: Understanding summary

#### Implementation Phase
1. Apply implementation technique (from step.techniques.implementation)
2. Create/modify files as needed
3. **Track all file operations**:
   - `filesCreated`: New files
   - `filesModified`: Changed files
   - `filesDeleted`: Removed files
   - `filesRenamed`: Moved/renamed files
4. Write tests BEFORE marking complete
5. Output: Implementation summary

#### Verification Phase
1. Apply verification technique (from step.techniques.verification)
2. Run verification commands from prompt
3. **Tests are MANDATORY** - step cannot complete without passing tests
4. Check all acceptance criteria
5. Output: Verification results (PASS/FAIL per criterion)

### File Tracking
During implementation, track all file operations and store in step metadata:
```json
{
  "files": {
    "created": ["src/new-file.py"],
    "modified": ["src/existing.py"],
    "deleted": [],
    "renamed": []
  }
}
```

### Test Enforcement
Step cannot be marked complete unless:
- [ ] Tests are written (if new code created)
- [ ] All tests pass
- [ ] Verification commands succeed

### Self-Correction Flow
On verification failure:
1. Record failure in memory bank
2. Check retry budget
3. If retries available:
   - Apply guidance from memory bank
   - Re-attempt with same or alternative technique
4. If budget exhausted:
   - Escalate to user
   - Do NOT mark step complete

### Progress Update
After successful step:
```json
{
  "steps": [{
    "status": "completed",
    "completedAt": "2026-01-02T...",
    "verificationPassed": true,
    "testsPassed": true,
    "testsWritten": ["TestFile.py"],
    "files": {...},
    "attempts": 1,
    "techniquesUsed": ["tdd"]
  }],
  "currentStep": 2,
  "updatedAt": "2026-01-02T..."
}
```

### Commit Prompting
After step completes:
```markdown
## Step {N} Complete

### Files Changed
- Created: {list}
- Modified: {list}

### Would you like to commit these changes?
Suggested message: `feat: Complete step {N} - {Step Title}`

(yes / no / custom message)
```

If yes, stage ONLY step files (never `.windsurf/**`) and commit.

### Output Format
```markdown
## Executing: Step {N} - {Step Title}

### Planning Phase
{planning output}

### Implementation Phase
{implementation output}

### Verification Phase
{verification results}

### Result: {PASSED / FAILED}

{if passed: commit prompt}
{if failed: retry/escalation info}
```

## Files to Create
- `.windsurf/workflows/plan-next.md`

## Files to Modify
- Plan's `progress.json` (step status, file tracking)
- Plan's `context.md` (learnings)

## Patterns to Follow
Reference: `.claude/commands/plan-next.md` for execution flow
Reference: Self-correction engine from Step 5

## Acceptance Criteria
- [ ] Workflow file under 12,000 characters
- [ ] Selects correct next step
- [ ] Executes all three phases
- [ ] Tracks file operations per step
- [ ] Enforces test requirement
- [ ] Uses self-correction on failure
- [ ] Updates progress.json correctly
- [ ] Updates context.md with learnings
- [ ] Prompts for commit with file list
- [ ] Never stages .windsurf/** files

## Testing Requirements

### Unit Tests
**N/A** - Workflow tested via execution.

### Integration Tests
- [ ] Create test plan with 2 steps
- [ ] Run `/plan-next {plan}`
- [ ] Verify step 1 starts (status: in_progress)
- [ ] Complete step 1, verify commit prompt
- [ ] Run `/plan-next` again
- [ ] Verify step 2 starts
- [ ] Verify progress.json updated after each step

### Manual Verification
- [ ] Phase outputs are visible
- [ ] File tracking captures all changes
- [ ] Self-correction triggers on failure
- [ ] Commit excludes .windsurf/**

## Verification Commands
```bash
# Check progress after step execution
python3 -c "
import json
with open('.windsurf/plans/{NNN}-xxx/progress.json') as f:
    p = json.load(f)
    for s in p['steps']:
        print(f\"Step {s['id']}: {s['status']}\")
"

# Verify file tracking
python3 -c "
import json
with open('.windsurf/plans/{NNN}-xxx/progress.json') as f:
    p = json.load(f)
    for s in p['steps']:
        if 'files' in s:
            print(f\"Step {s['id']}: {len(s['files'].get('created',[]))} created\")
"

# Verify context.md updated
tail -20 .windsurf/plans/{NNN}-xxx/context.md
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check self-correction engine output
2. Verify retry budget not exhausted
3. Check memory bank for lessons
4. Verify progress.json is valid JSON

## Do NOT
- Mark step complete without passing tests
- Stage .windsurf/** files for commit
- Skip file tracking
- Ignore self-correction retry budget
- Auto-commit without user confirmation
