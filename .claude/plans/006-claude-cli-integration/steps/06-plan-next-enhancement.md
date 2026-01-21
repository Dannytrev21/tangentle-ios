# Step 6: Plan-Next Enhancement

## Problem Type
`refactor`

## Technique Selection
- **Planning**: ps-plus - Structured approach to command enhancement
- **Implementation**: self-refine - Iteratively improve guidance
- **Verification**: tdd - Verify output includes context guidance

## Risk Level
**medium** - Modifying core execution command

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Reasoning Depth
**Think hard about** how context management guidance integrates into execution flow.

## Context
This step enhances the plan-next command to include context management guidance. The guide emphasizes strategic context management to prevent failed long sessions.

## Goal
Update plan-next.md to include context management reminders and suggestions at appropriate points in step execution.

## Prerequisites
- Step 1 completed (knowledge base with context-management.md)

## High-Level Steps
1. Read current plan-next.md command
2. Add context awareness section to pre-step instructions
3. Add mid-step context check reminder
4. Add post-step context guidance
5. Add "Document and Clear" pattern instructions
6. Verify command includes all guidance

## Detailed Requirements

### Pre-Step Context Check
Add after loading the prompt:
```markdown
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

If this is Step 1, you have full context available.
If this is Step 5+, consider context budget.
```

### Mid-Step Reminder
Add to execution instructions:
```markdown
### During Implementation
If you notice:
- Responses becoming shorter or less detailed
- Missing context from earlier in conversation
- Confusion about previously discussed topics

**Stop and check**: Run `/context` to verify usage.
Consider "Document and Clear" pattern:
1. Write current progress to context.md
2. Commit all changes
3. Run `/clear`
4. Read context.md and continue
```

### Post-Step Context Guidance
Add to completion instructions:
```markdown
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
```

### Document and Clear Pattern
Add as reference section:
```markdown
## Document and Clear Pattern
For multi-session work or when context is high:

1. **Document current state**:
   ```bash
   # Update context.md with full state
   ```

2. **Commit everything**:
   ```bash
   git add -A && git commit -m "progress: step {N} in progress"
   ```

3. **Clear context**:
   ```bash
   /clear
   ```

4. **Resume**:
   ```
   Read .claude/plans/{NNN}/context.md and continue from where we left off
   ```

This gives you fresh 200K context while preserving all progress.
```

## Files to Create
- None

## Files to Modify
- `.claude/commands/plan-next.md`: Add context management guidance

## Patterns to Follow
Reference: `.claude/knowledge/context-management.md` for thresholds
Reference: Guide's "Document and Clear" pattern

## Acceptance Criteria
- [ ] Pre-step context check section added
- [ ] Mid-step reminder for context issues added
- [ ] Post-step context guidance added
- [ ] Document and Clear pattern documented
- [ ] Threshold table (70%, 85%, 93%) included
- [ ] Instructions are actionable and clear
- [ ] Command structure remains logical

## Testing Requirements
**N/A - Reason**: Command documentation enhancement
**Manual Verification**:
- Run `/plan-next` and verify guidance appears
- Check that thresholds match guide
- Verify Document and Clear pattern is clear

## Verification Commands
```bash
# Verify new sections exist
grep -c "Context Awareness" .claude/commands/plan-next.md
grep -c "During Implementation" .claude/commands/plan-next.md
grep -c "Post-Step Context" .claude/commands/plan-next.md
grep -c "Document and Clear" .claude/commands/plan-next.md

# Verify thresholds
grep -c "70-84%" .claude/commands/plan-next.md
grep -c "85%+" .claude/commands/plan-next.md
grep -c "93%+" .claude/commands/plan-next.md
```

## Documentation Updates
- [ ] Update step notes in progress.json

## Error Recovery
If verification fails:
1. Identify missing section
2. Add content from knowledge base reference
3. Verify command still executes correctly
4. Re-run verification

## Do NOT
- Add automatic context tracking (guidance only per decision)
- Change core step execution logic
- Add dependencies on external tools
- Make guidance overly verbose
