# Step 12: Workflow - /plan-rollback

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Structure safe rollback flow
- **Implementation**: tdd - Test rollback correctness
- **Verification**: reflexion - Learn from rollback edge cases

## Risk Level
**high** - Data loss risk; must be safe and accurate

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 3 attempts
- Escalation: After 5 total failures

## Context
`/plan-rollback` reverts a step's uncommitted changes. It uses per-step file tracking to precisely revert only the affected files. It must refuse to rollback committed changes and warn on partial/mixed states.

## Goal
Create the `/plan-rollback` workflow with safe, precise rollback using per-step file tracking.

## Prerequisites
- Step 9 completed (plan-next tracks file changes)
- Step 5 completed (memory bank for lessons preservation)

## High-Level Steps
1. Load plan state and target step
2. Check if changes are committed
3. Display rollback preview
4. Confirm with user
5. Revert modified files
6. Delete created files
7. Restore deleted files
8. Handle renamed files
9. Reset step status
10. Handle memory bank (preserve or discard lessons)
11. Update progress.json

## Detailed Requirements

### Pre-Rollback Checks

#### Committed Changes Check
```bash
# Check if step files are committed
git status --porcelain {files} | grep -v '^??' | wc -l
```
If result > 0 for unstaged changes, rollback is possible.
If files are staged or committed, refuse rollback.

#### Mixed State Detection
If some files are committed and some are not:
```markdown
⚠️ **Mixed State Detected**

Some changes from this step are committed:
- Committed: src/file1.py
- Uncommitted: src/file2.py

Options:
1. **Partial rollback** - Revert only uncommitted files
2. **Manual review** - I'll list all files for you to decide
3. **Cancel** - Do not rollback

Choose an option:
```

### Rollback Preview
```markdown
## Rollback Preview: Step {N}

### What WILL be reverted:
- Modified: `src/existing.py` (restored to previous state)
- Created: `src/new-file.py` (will be deleted)
- Deleted: `src/removed.py` (will be restored)
- Renamed: `old.py` → `new.py` (will be renamed back)

### What will NOT be changed:
- Unrelated files
- .windsurf/** files
- Other steps' changes

### Memory Bank Options:
- **Preserve lessons** - Keep what we learned from this attempt
- **Full reset** - Discard lessons (fresh start)

**Proceed with rollback?** (yes/no/preserve/reset)
```

### Rollback Operations

#### Revert Modified Files
```bash
git checkout -- {file}
```

#### Delete Created Files
```bash
rm {file}
```

#### Restore Deleted Files
```bash
git checkout HEAD -- {file}
```

#### Handle Renamed Files
```bash
git mv {new_name} {old_name}
```

### Memory Bank Options
1. **Preserve lessons** - Keep memory bank entries from this step
2. **Full reset** - Remove entries from this step's attempts

### Progress Update
After rollback:
```json
{
  "steps": [{
    "status": "pending",
    "attempts": 0,  // or preserved if "preserve"
    "techniquesUsed": [],  // or preserved if "preserve"
    "startedAt": null,
    "completedAt": null,
    "verificationPassed": null,
    "testsPassed": null,
    "testsWritten": [],
    "files": {
      "created": [],
      "modified": [],
      "deleted": [],
      "renamed": []
    }
  }],
  "currentStep": {N-1 or same},
  "updatedAt": "..."
}
```

### Output Format
```markdown
## Rollback Complete: Step {N}

### Actions Taken:
- ✅ Reverted 3 modified files
- ✅ Deleted 2 created files
- ✅ Restored 1 deleted file
- ✅ Renamed 0 files back

### Memory Bank:
{preserved / reset}

### Step Status:
- Status: pending
- Attempts: {0 or preserved}

### Next Commands:
- `/plan-next {NNN}` - Retry the step
- `/plan-status {NNN}` - View plan status
```

## Files to Create
- `.windsurf/workflows/plan-rollback.md`

## Files to Modify
- Plan's `progress.json` (step reset)
- Plan's `memory-bank.json` (if full reset)

## Patterns to Follow
Reference: `.claude/commands/plan-rollback.md` for flow

## Acceptance Criteria
- [ ] Workflow file under 12,000 characters
- [ ] Refuses rollback for committed changes
- [ ] Warns on mixed state with options
- [ ] Shows clear preview before rollback
- [ ] Reverts modified files correctly
- [ ] Deletes created files
- [ ] Restores deleted files
- [ ] Handles renamed files
- [ ] Offers memory bank preservation option
- [ ] Updates progress.json correctly

## Testing Requirements

### Unit Tests
**N/A** - Workflow tested via execution.

### Integration Tests
- [ ] Create step that modifies files
- [ ] Run step partially (don't complete)
- [ ] Run `/plan-rollback {plan}`
- [ ] Verify preview shown
- [ ] Confirm rollback
- [ ] Verify files reverted
- [ ] Verify progress.json reset
- [ ] Test "preserve lessons" option

### Manual Verification
- [ ] No data loss from unrelated files
- [ ] Committed changes rejected
- [ ] Mixed state handled correctly

## Verification Commands
```bash
# Before rollback: check step file state
git status --porcelain $(cat .windsurf/plans/{NNN}-xxx/progress.json | \
  python3 -c "import json,sys; s=json.load(sys.stdin)['steps'][N]; print(' '.join(s.get('files',{}).get('modified',[])))")

# After rollback: verify files reverted
git status

# Verify step reset
python3 -c "
import json
with open('.windsurf/plans/{NNN}-xxx/progress.json') as f:
    s = json.load(f)['steps'][N]
    print(f\"Status: {s['status']}, Attempts: {s['attempts']}\")
"
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check file tracking accuracy
2. Verify git commands work
3. Check for permission issues
4. Validate JSON updates

## Do NOT
- Rollback committed changes
- Delete files not tracked in step
- Lose memory bank lessons without confirmation
- Skip preview/confirmation step
