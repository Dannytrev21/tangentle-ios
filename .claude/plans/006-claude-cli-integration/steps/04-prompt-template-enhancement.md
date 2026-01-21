# Step 4: Prompt Template Enhancement

## Problem Type
`documentation`

## Technique Selection
- **Planning**: ps-plus - Structured approach to template design
- **Implementation**: self-refine - Iteratively improve template quality
- **Verification**: got - Verify coherence of all template sections

## Risk Level
**medium** - Modifying core prompt template that affects all generated prompts

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Reasoning Depth
**Think hard about** how all guide principles integrate into the template.

## Context
This step enhances the prompt template in `plan-prompts.md` to embed Claude Code CLI mastery patterns. The template is used to generate prompts for each plan step, so changes here affect all future prompt generation.

## Goal
Update the prompt template to include thinking keywords, TDD emphasis, context management guidance, and commit checkpoint patterns.

## Prerequisites
- Step 1 completed (knowledge base for references)
- Step 3 completed (thinking keywords utility available)

## High-Level Steps
1. Read current plan-prompts.md template
2. Add Reasoning Depth section with thinking keyword placeholder
3. Strengthen TDD in Implementation Guide
4. Add Context Management section
5. Add Git Checkpoint guidance
6. Update Verification Protocol with guide patterns
7. Verify template is well-structured

## Detailed Requirements

### New Section: Reasoning Depth
Add after Mission, before Context:
```markdown
## Reasoning Depth
{THINKING_KEYWORD} the following aspects before implementation:
1. What are the potential failure modes?
2. What existing patterns should be followed?
3. What tests will verify success?
4. What could go wrong and how to prevent it?
```

Where `{THINKING_KEYWORD}` is replaced based on step risk level:
- low → "Think about"
- medium → "Think hard about"
- high/critical → "Ultrathink about"

### Enhanced TDD Section
Strengthen the Implementation Guide with:
```markdown
### TDD Approach (Mandatory for Code Steps)
The robots LOVE TDD. Follow this workflow:
1. **Write failing tests first**: Define expected behavior in tests
2. **Confirm tests fail**: Verify tests fail for the right reason
3. **Commit the tests**: Lock in the specification
4. **Implement to pass**: Write minimum code to pass
5. **Refactor**: Clean up while tests stay green
6. **Commit implementation**: Separate commit for implementation

If modifying existing code:
- Ensure a unit test exists first
- Create one if none exists
- Then modify the function
- Then run tests to verify
```

### New Section: Context Management
Add before Completion Protocol:
```markdown
## Context Management
Monitor your context usage during this step:

| Usage | Action |
|-------|--------|
| 50-69% | Work normally |
| 70-84% | Consider `/compact` after this step |
| 85-92% | Use `/compact` before continuing |
| 93%+ | Use `/clear` and resume from context.md |

If this is a long step:
- Commit progress frequently
- Update context.md with current state
- Consider "Document and Clear" pattern for fresh context
```

### Enhanced Git Checkpoint Guidance
Add to Completion Protocol:
```markdown
### Git Checkpoints
Git is your safety net. Create checkpoints:

**Before risky changes**:
```bash
git add -A && git commit -m "checkpoint: before {description}"
```

**After each acceptance criterion passes**:
```bash
git add -A && git commit -m "progress: {what was completed}"
```

**After full step completion**:
```bash
git add -A && git commit -m "step {N} complete: {step name}"
```

Commit frequently - don't batch up large changes.
```

### Enhanced Verification Protocol
Add to Verification Protocol:
```markdown
### Dual Review Pattern
For high-risk steps, consider:
1. Complete implementation
2. Use `/clear` or new terminal
3. Ask Claude to review the changes
4. Address any review feedback
5. Final commit
```

## Files to Create
- None

## Files to Modify
- `.claude/commands/plan-prompts.md`: Add all new sections to template

## Patterns to Follow
Reference: Current `plan-prompts.md` structure
Reference: `.claude/knowledge/tdd-patterns.md` for TDD workflow
Reference: `.claude/knowledge/context-management.md` for thresholds

## Acceptance Criteria
- [ ] Reasoning Depth section added with {THINKING_KEYWORD} placeholder
- [ ] TDD section significantly strengthened with 6-step workflow
- [ ] Context Management section with threshold table
- [ ] Git Checkpoint guidance in Completion Protocol
- [ ] Dual Review Pattern documented for high-risk steps
- [ ] Template remains well-structured and readable
- [ ] All sections flow logically

## Testing Requirements
**N/A - Reason**: Template documentation
**Manual Verification**:
- Read through updated template for coherence
- Verify placeholder {THINKING_KEYWORD} is present
- Check TDD section matches guide's 6-step workflow
- Verify context thresholds match guide
- Generate a test prompt to verify structure

## Verification Commands
```bash
# Verify new sections exist
grep -c "Reasoning Depth" .claude/commands/plan-prompts.md
grep -c "THINKING_KEYWORD" .claude/commands/plan-prompts.md
grep -c "TDD Approach" .claude/commands/plan-prompts.md
grep -c "Context Management" .claude/commands/plan-prompts.md
grep -c "Git Checkpoints" .claude/commands/plan-prompts.md
grep -c "Dual Review" .claude/commands/plan-prompts.md

# Verify TDD steps are present
grep -c "Write failing tests first" .claude/commands/plan-prompts.md
grep -c "Commit the tests" .claude/commands/plan-prompts.md

# Verify context thresholds
grep -c "70-84%" .claude/commands/plan-prompts.md
```

## Documentation Updates
- [ ] Update step notes in progress.json

## Error Recovery
If verification fails:
1. Identify missing section
2. Review source content from knowledge base
3. Add missing content
4. Re-run verification

## Do NOT
- Remove existing useful template sections
- Make template overly long (keep focused)
- Add sections that don't integrate with existing structure
- Hardcode thinking keywords (use placeholder)
