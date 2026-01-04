---
name: plan-rollback
description: Rollback current step's uncommitted changes with memory bank options
---

# Plan Rollback

Safely rollback uncommitted changes from a step, with options to preserve lessons learned.

## Instructions

### Step 1: Locate Plan and Step

```bash
PLAN_DIR=$(ls -d .windsurf/plans/$ARGS* 2>/dev/null | head -1)
cat $PLAN_DIR/progress.json
```

Find step to rollback:
1. If step has `status: "in_progress"` → rollback that step
2. If no in_progress → rollback most recent `completed` step
3. If step is `pending` → nothing to rollback

Extract from step:
- `files.created` - Files to delete
- `files.modified` - Files to revert
- `files.deleted` - Files to restore
- `files.renamed` - Files to rename back
- `techniquesUsed` - For technique history display
- `selfCorrectionNotes` - For memory bank preservation

### Step 2: Check Git Status

For each tracked file, check commit state:

```bash
# Check if files have uncommitted changes
git status --porcelain {files} 2>/dev/null
```

Categorize results:
| Prefix | Meaning | Action |
|--------|---------|--------|
| ` M` | Modified, unstaged | Can rollback |
| `M ` | Modified, staged | Warn user |
| `??` | Untracked (created) | Can delete |
| ` D` | Deleted, unstaged | Can restore |
| (none) | Clean/committed | Cannot rollback |

### Step 3: Handle Edge Cases

#### All Files Committed
```
═══════════════════════════════════════
  ❌ CANNOT ROLLBACK
═══════════════════════════════════════

All changes from Step {N} are committed.

Committed files:
- {file1}
- {file2}

To undo committed changes, use:
  git revert {commit_hash}

Or review manually:
  git log --oneline -5
═══════════════════════════════════════
```

#### No Files Tracked
```
═══════════════════════════════════════
  ℹ️ NOTHING TO ROLLBACK
═══════════════════════════════════════

Step {N} has no tracked file changes.

Step status: {status}
Files tracked: 0

Run `/plan-status {NNN}` to view details.
═══════════════════════════════════════
```

#### Mixed State
```
═══════════════════════════════════════
  ⚠️ MIXED STATE DETECTED
═══════════════════════════════════════

Some files committed, some not.

Committed (cannot rollback):
- src/committed.py

Uncommitted (can rollback):
- src/uncommitted.py

Options:
1. **Partial** - Rollback uncommitted only
2. **Cancel** - Abort rollback

Choice? (partial / cancel)
═══════════════════════════════════════
```

### Step 4: Show Preview

```
═══════════════════════════════════════
  ROLLBACK PREVIEW: Step {N}
═══════════════════════════════════════

## Files to Revert (restore previous):
- src/service.py
- src/utils.py

## Files to Delete (created in step):
- src/new-feature.py
- tests/test_feature.py

## Files to Restore (deleted in step):
- (none)

## Files to Rename Back:
- (none)

## Will NOT Change:
- .windsurf/** files
- Other steps' files
- Committed changes

## Memory Bank Options:
- **preserve** - Keep lessons from attempts
- **reset** - Clear lessons (fresh start)
- **cancel** - Abort rollback

Proceed? (preserve / reset / cancel)
═══════════════════════════════════════
```

### Step 5: Execute Rollback

If confirmed (preserve or reset):

#### Revert Modified Files
```bash
for file in {files.modified}; do
  git checkout -- "$file" && echo "✅ Reverted: $file"
done
```

#### Delete Created Files
```bash
for file in {files.created}; do
  [ -f "$file" ] && rm "$file" && echo "✅ Deleted: $file"
done
```

#### Restore Deleted Files
```bash
for file in {files.deleted}; do
  git checkout HEAD -- "$file" && echo "✅ Restored: $file"
done
```

#### Undo Renames
```bash
for rename in {files.renamed}; do
  # rename format: "old_path:new_path"
  old="${rename%%:*}"
  new="${rename##*:}"
  git mv "$new" "$old" && echo "✅ Renamed back: $new → $old"
done
```

### Step 6: Handle Memory Bank

#### If "preserve"
Keep lessons in progress.json for retry:
```json
{
  "memoryBank": {
    "preservedFrom": "{timestamp}",
    "lessons": [
      "Lesson from selfCorrectionNotes[0]",
      "Lesson from selfCorrectionNotes[1]"
    ]
  }
}
```

Also preserve in memory-bank.json:
```bash
python3 .windsurf/scripts/windsurf_plan.py memory context \
  --plan {NNN} --step {N}
# Lessons remain for retry
```

#### If "reset"
Clear memory bank for this step:
```bash
python3 .windsurf/scripts/windsurf_plan.py memory clear \
  --plan {NNN} --step {N}
```

### Step 7: Update Progress

```python
python3 -c "
import json
from datetime import datetime

with open('$PLAN_DIR/progress.json', 'r') as f:
    p = json.load(f)

step = p['steps'][{N-1}]

# Preserve or reset based on choice
preserve = '{choice}' == 'preserve'

# Store rollback note
old_notes = step.get('notes', '')
step['notes'] = f'Rolled back at {datetime.now().isoformat()}. Previous: {old_notes}'

# Reset step state
step['status'] = 'pending'
step['startedAt'] = None
step['completedAt'] = None
step['verificationPassed'] = None
step['testsPassed'] = None
step['testsWritten'] = []

# Reset technique state
step['techniquesUsed'] = []
step['finalAttempt'] = 0
step['techniqueRotations'] = 0

if preserve:
    # Keep lessons
    step['memoryBank'] = {
        'preservedFrom': datetime.now().isoformat(),
        'lessons': step.get('selfCorrectionNotes', [])
    }
    step['attempts'] = step.get('attempts', 0)  # Keep attempt count
else:
    # Full reset
    step['memoryBank'] = None
    step['attempts'] = 0

step['selfCorrectionNotes'] = []

# Clear file tracking
step['files'] = {
    'created': [],
    'modified': [],
    'deleted': [],
    'renamed': []
}

# Update plan state
p['updatedAt'] = datetime.now().isoformat()

# Remove from context arrays
for f in step.get('files', {}).get('created', []):
    if f in p['context']['filesCreated']:
        p['context']['filesCreated'].remove(f)
for f in step.get('files', {}).get('modified', []):
    if f in p['context']['filesModified']:
        p['context']['filesModified'].remove(f)

with open('$PLAN_DIR/progress.json', 'w') as f:
    json.dump(p, f, indent=2)

print('Progress updated')
"
```

### Step 8: Update Context

Append to context.md:

```markdown
---

## Rollback - {timestamp}

### Step Rolled Back
Step {N}: {Name}

### Technique History Before Rollback
- Planning: {tech} - {result}
- Implementation: {tech} - {result}
- Verification: {tech} - {result}
- Rotations: {n}

### Memory Bank
{preserve}: Lessons preserved for retry
{reset}: Full reset, no lessons preserved

### Files Reverted
- `{path}`: restored to previous

### Files Deleted
- `{path}`: was created in this step

### Files Restored
- `{path}`: was deleted in this step

### Ready for Retry
Run `/plan-next {NNN}` to retry step.
```

### Step 9: Output Summary

```
═══════════════════════════════════════
  ✅ ROLLBACK COMPLETE
═══════════════════════════════════════

Step {N} has been rolled back.

## Actions Taken
- Reverted: {n} files
- Deleted: {n} files
- Restored: {n} files
- Renamed: {n} files

## Memory Bank
{Status}: {preserve/reset}
{If preserve: "Lessons available for retry"}

## Step State
- Status: pending
- Attempts: {n} (preserved) / 0 (reset)

## Next Commands
- `/plan-next {NNN}` - Retry step
- `/plan-status {NNN}` - View progress
═══════════════════════════════════════
```

## Safety Rules

| Rule | Enforcement |
|------|-------------|
| No committed rollback | Check git status, refuse if committed |
| Preview required | Show files before any action |
| Confirm required | Wait for preserve/reset/cancel |
| Memory choice | User decides lesson fate |
| .windsurf/ protected | Never modify .windsurf/** |

## Error Recovery

### File Revert Fails
```bash
# Try manual revert
git checkout HEAD -- {file}
# Or show status
git status {file}
```

### Delete Fails
```bash
# Check permissions
ls -la {file}
# Force delete
rm -f {file}
```

### Restore Fails
```bash
# Check if file exists in git
git ls-files --error-unmatch {file}
# Show file history
git log --oneline -3 -- {file}
```

## Do NOT

- Do NOT rollback committed changes (suggest git revert)
- Do NOT delete files not tracked by step
- Do NOT skip preview/confirmation
- Do NOT auto-reset memory bank (user must choose)
- Do NOT modify .windsurf/** files
- Do NOT exceed 12,000 character limit
