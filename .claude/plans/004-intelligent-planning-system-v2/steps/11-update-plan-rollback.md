# Step 11: Update plan-rollback

## Context
The `/plan-rollback` command reverts failed changes. With technique tracking, rollback needs to reset technique state and preserve lessons learned.

## Goal
Update the `/plan-rollback` command to properly reset technique state while preserving valuable learning from failed attempts.

## Problem Type
`refactor`

## Technique Selection
- **Planning**: PS+ (structured rollback process)
- **Implementation**: Self-Refine (careful state handling)
- **Verification**: Self-Refine (verify clean rollback)

## Risk Level
**Low** - Rollback is already a recovery mechanism

## Prerequisites
- Steps 1-9 completed (technique state exists to rollback)

## High-Level Steps
1. Analyze current plan-rollback.md
2. Add technique state reset
3. Preserve memory bank lessons
4. Update rollback confirmation
5. Test rollback with technique data

## Detailed Requirements

### Current Rollback Flow
1. Assess current state
2. Confirm rollback
3. Revert files
4. Reset progress

### New Rollback Flow
1. Assess current state (including technique data)
2. **Show technique attempts summary**
3. **Decide: preserve or discard lessons**
4. Confirm rollback
5. Revert files
6. **Reset technique state but optionally preserve memory bank**
7. Update progress

### Changes to plan-rollback.md

#### Updated Rollback Confirmation

```markdown
### Step 2: Confirm Rollback (UPDATED)

\`\`\`
═══════════════════════════════════════════════════════════════
  ⚠️ ROLLBACK CONFIRMATION
═══════════════════════════════════════════════════════════════

  Step: {N} - {Step Name}

  ## Technique Execution History
  ┌──────────────┬────────────────┬──────────┬──────────┐
  │ Phase        │ Technique      │ Attempts │ Result   │
  ├──────────────┼────────────────┼──────────┼──────────┤
  │ Planning     │ {technique}    │ 1        │ Success  │
  │ Implement    │ {technique}    │ 3        │ Failed   │
  │ Verify       │ {technique}    │ 2        │ Failed   │
  └──────────────┴────────────────┴──────────┴──────────┘

  Total attempts: {n}
  Techniques rotated: {n} times

  ## Memory Bank Contents (if Reflexion used)
  - Lesson 1: {lesson}
  - Lesson 2: {lesson}

  ## Rollback Options
  1. Full reset (discard all technique state and lessons)
  2. Preserve lessons (keep memory bank, reset attempts)
  3. Cancel

  What would you like to do?

═══════════════════════════════════════════════════════════════
\`\`\`
```

#### Technique State Reset

```markdown
### Step 4.5: Reset Technique State (NEW)

Based on rollback option chosen:

#### Option 1: Full Reset
\`\`\`json
// progress.json update
{
  "steps[N-1]": {
    "status": "pending",
    "techniquesUsed": [],
    "finalAttempt": 0,
    "techniqueRotations": 0,
    "selfCorrectionNotes": [],
    "memoryBank": null
  }
}
\`\`\`

#### Option 2: Preserve Lessons
\`\`\`json
// progress.json update
{
  "steps[N-1]": {
    "status": "pending",
    "techniquesUsed": [],
    "finalAttempt": 0,
    "techniqueRotations": 0,
    "selfCorrectionNotes": [],
    "memoryBank": {
      "preservedFrom": "{timestamp}",
      "lessons": [
        "Lesson 1: {lesson}",
        "Lesson 2: {lesson}"
      ],
      "note": "Preserved during rollback to accelerate retry"
    }
  }
}
\`\`\`
```

#### Updated Context.md Entry

```markdown
### Step 5: Update Context (UPDATED)

Add rollback entry with technique details:

\`\`\`markdown
---

## Rollback - {timestamp}

### Step Rolled Back
Step {N}: {Step Name}

### Technique History Before Rollback
- Planning: {technique} - succeeded
- Implementation: {technique} - failed after 3 attempts
- Verification: {technique} - failed after 2 attempts

### Lessons Preserved
{If option 2 chosen:}
- Lesson 1: Edge case needs nil check
- Lesson 2: Async method requires await

{If option 1 chosen:}
(No lessons preserved - full reset)

### Reason for Rollback
{User-provided or inferred}

### Recommendations for Retry
Based on failure patterns:
1. Consider using {alternative_technique} instead of {failed_technique}
2. Review {specific area} before retry
3. Memory bank available: {yes/no}

---
\`\`\`
```

## Files to Create
- None (modifying existing)

## Files to Modify
- `.claude/commands/plan-rollback.md`: Add technique state handling

## Patterns to Follow
Reference: Current plan-rollback.md structure (lines 1-180)

## Acceptance Criteria
- [ ] Rollback shows technique execution history
- [ ] Option to preserve or discard memory bank
- [ ] Technique state properly reset
- [ ] Lessons preserved when requested
- [ ] Context.md includes technique rollback info

## Testing Requirements

### Manual Testing
- [ ] Rollback step with technique history
- [ ] Choose preserve lessons option
- [ ] Choose full reset option
- [ ] Verify progress.json is updated correctly

## Verification Commands
```bash
# Check technique state reset
grep -q "Reset Technique State" .claude/commands/plan-rollback.md

# Check preserve lessons option
grep -q "Preserve Lessons" .claude/commands/plan-rollback.md
```

## Documentation Updates
- [ ] Update rollback docs in CLAUDE.md

## Error Recovery
If technique state is corrupted:
1. Force full reset
2. Clear memoryBank
3. Log the issue

## Do NOT
- Lose user's memory bank without explicit choice
- Leave partial technique state
