# Step 9: Plan-Rollback Recovery Enhancement

## Problem Type
`refactor`

## Technique Selection
- **Planning**: ps-plus - Structured approach to enhancement
- **Implementation**: self-refine - Iteratively improve recovery guidance
- **Verification**: self-refine - Verify comprehensive recovery patterns

## Risk Level
**low** - Adding documentation to existing command

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Reasoning Depth
**Think about** recovery patterns from the guide.

## Context
The guide describes recovery patterns including `/rewind`, Escape, and git checkpoints. This step enhances plan-rollback.md with these patterns to improve failure recovery.

## Goal
Update plan-rollback.md with comprehensive recovery patterns from the Claude Code CLI guide.

## Prerequisites
- Step 1 completed (knowledge base with recovery patterns)

## High-Level Steps
1. Read current plan-rollback.md
2. Add recovery pattern reference section
3. Add git checkpoint recovery guidance
4. Add /rewind integration guidance
5. Add Escape interrupt guidance
6. Verify all patterns documented

## Detailed Requirements

### Recovery Pattern Reference Section
Add new section:
```markdown
## Recovery Patterns

Claude Code provides multiple recovery mechanisms. Choose based on situation:

### Immediate Interruption
- **Press Escape**: Interrupts current operation, preserves context
- **Double-tap Escape**: Access checkpoint history
- Use when: Claude is going in wrong direction

### Conversation Recovery
- **`/rewind`**: Revert to previous conversation state
  - Conversation only: Keep code changes
  - Code only: Keep conversation
  - Both: Full restore
- Use when: Need to undo recent conversation turns

### Code Recovery
- **Git reset**: `git reset --hard HEAD`
- **Git checkout**: `git checkout -- {file}`
- **Previous commit**: `git reset --hard HEAD~1`
- Use when: Code changes need reverting

### Plan-Specific Recovery
- **This command (`/plan-rollback`)**: Plan-aware rollback
  - Updates progress.json
  - Preserves memory bank learnings
  - Optionally resets technique attempts
```

### Git Checkpoint Recovery
Add section:
```markdown
## Git Checkpoint Strategy

### Before Risky Steps
Always checkpoint before high-risk operations:
```bash
git add -A && git commit -m "checkpoint: before step {N}"
```

### Recovery from Checkpoint
If step fails badly:
```bash
# Find the checkpoint
git log --oneline -10

# Reset to checkpoint
git reset --hard {checkpoint-commit}

# Update progress.json to reflect rollback
```

### Partial Recovery
If some work is salvageable:
```bash
# Stash good changes
git stash

# Reset to checkpoint
git reset --hard {checkpoint}

# Re-apply good changes
git stash pop
```
```

### /rewind Integration
Add section:
```markdown
## Integration with /rewind

`/rewind` offers three recovery modes:

| Mode | Effect | Use Case |
|------|--------|----------|
| Conversation only | Rewind conversation, keep code | Wrong approach discussed, code is fine |
| Code only | Keep conversation, revert files | Code broke, but conversation is valuable |
| Both | Full restore | Complete restart needed |

### When to Use /rewind vs /plan-rollback
- **/rewind**: Mid-step recovery, conversation issues
- **/plan-rollback**: Step-level rollback, plan state management

### Combining Both
For severe failures:
1. Use `/rewind` to restore conversation state
2. Use `/plan-rollback` to update plan status
3. Use git reset to restore code
```

### Escape Interrupt Guidance
Add section:
```markdown
## Interrupt and Correct

### Single Escape
Press Escape during Claude's response to:
- Stop current generation
- Preserve all context
- Provide course correction

**Effective corrections**:
- "That approach won't work because X. Try Y instead."
- "Stop. Let's reconsider the approach first."
- "Wait - I need to provide more context."

### Double Escape
Access `/rewind` checkpoint selection:
- See conversation history
- Select restore point
- Choose what to restore
```

### Update CLAUDE.md Prevention
Add to existing guidance:
```markdown
## Post-Rollback Actions

After any rollback:
1. **Document the failure** in context.md learnings section
2. **Update CLAUDE.md** if rollback reveals missing guidance
3. **Consider technique change** if same technique failed multiple times
4. **Checkpoint immediately** before retry
```

## Files to Create
- None

## Files to Modify
- `.claude/commands/plan-rollback.md`: Add recovery pattern documentation

## Patterns to Follow
Reference: Guide's recovery patterns section
Reference: `.claude/knowledge/claude-code-mastery.md` recovery section

## Acceptance Criteria
- [ ] Recovery Pattern Reference section added
- [ ] Git Checkpoint Strategy documented
- [ ] /rewind integration explained
- [ ] Escape interrupt guidance included
- [ ] Post-rollback actions documented
- [ ] When to use which recovery method is clear
- [ ] Command remains functional

## Testing Requirements
**N/A - Reason**: Command documentation enhancement
**Manual Verification**:
- Read through updated command
- Verify recovery patterns are comprehensive
- Check that guidance is actionable

## Verification Commands
```bash
# Verify new sections
grep -c "Recovery Patterns" .claude/commands/plan-rollback.md
grep -c "Git Checkpoint" .claude/commands/plan-rollback.md
grep -c "/rewind" .claude/commands/plan-rollback.md
grep -c "Escape" .claude/commands/plan-rollback.md
grep -c "Post-Rollback Actions" .claude/commands/plan-rollback.md
```

## Documentation Updates
- [ ] Update step notes in progress.json

## Error Recovery
If verification fails:
1. Identify missing recovery pattern
2. Review guide's recovery section
3. Add missing documentation
4. Re-run verification

## Do NOT
- Remove existing rollback functionality
- Make recovery patterns overly complex
- Skip the /rewind integration
- Ignore post-rollback actions
