# Step 12: Git Workflow Guidance

## Problem Type
`documentation`

## Technique Selection
- **Planning**: ps-plus - Structured approach to documentation
- **Implementation**: self-refine - Iteratively improve guidance
- **Verification**: self-refine - Verify comprehensive coverage

## Risk Level
**low** - Adding documentation, no code changes

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Reasoning Depth
**Think about** git patterns from the guide.

## Context
The guide emphasizes "Commit frequently - Git is your safety net" and describes git worktree patterns for parallel work. This step adds comprehensive git workflow guidance to prompts.

## Goal
Add git workflow guidance to prompt templates and commands, emphasizing frequent commits and checkpoint patterns.

## Prerequisites
- Step 4 completed (prompt template has checkpoint section)

## High-Level Steps
1. Review guide's git patterns
2. Create git workflow guidance section for prompts
3. Add worktree guidance for parallel work
4. Update plan-prompts template with git patterns
5. Verify guidance is comprehensive

## Detailed Requirements

### Git Checkpoint Pattern Documentation
Add to prompt template (if not already from Step 4):
```markdown
## Git Workflow

### Commit Frequently
Git is your safety net. The robot REALLLLLY wants to commit - let it.

**Checkpoint Strategy**:
```bash
# Before risky changes
git add -A && git commit -m "checkpoint: before {description}"

# After meaningful progress
git add -A && git commit -m "progress: {what was completed}"

# After acceptance criterion passes
git add -A && git commit -m "AC passed: {criterion description}"

# After step completion
git add -A && git commit -m "step {N} complete: {step name}"
```

### Commit Message Patterns
| Prefix | Use Case |
|--------|----------|
| checkpoint: | Before risky operations |
| progress: | Partial completion |
| feat: | New feature/functionality |
| fix: | Bug fix |
| refactor: | Code restructuring |
| test: | Adding tests |
| docs: | Documentation changes |

### Recovery from Bad Commits
```bash
# Undo last commit, keep changes
git reset --soft HEAD~1

# Undo last commit, discard changes
git reset --hard HEAD~1

# Restore specific file from commit
git checkout {commit} -- {file}
```
```

### Git Worktree Guidance
Add new section for parallel work:
```markdown
## Parallel Work with Git Worktrees

For complex plans or when multiple streams of work are needed:

### Creating Worktrees
```bash
# Create worktree for a feature branch
git worktree add ../project-feature-auth feature-auth
git worktree add ../project-feature-dashboard feature-dashboard
```

### Parallel Claude Sessions
Each worktree can have its own Claude session:
```bash
# Terminal 1
cd ../project-feature-auth && claude

# Terminal 2
cd ../project-feature-dashboard && claude
```

### Use Cases
- Frontend and backend development simultaneously
- Complex refactoring alongside feature work
- One Claude writes code while another reviews

### Cleanup
```bash
# Remove worktree when done
git worktree remove ../project-feature-auth
```
```

### Pre-Commit Hook Recommendation
Add to prompt template:
```markdown
### Pre-Commit Verification
Consider pre-commit hooks to catch issues early:

```bash
# Example pre-commit hook runs:
# - Lint check
# - Type check
# - Unit tests for changed files
```

"The robot REALLLLLY wants to commit" - hooks catch errors before they propagate.

If pre-commit hooks fail:
1. Read the error output
2. Fix the specific issue
3. Stage the fix
4. Retry commit
```

### Integrate into Knowledge Base
Add to `.claude/knowledge/claude-code-mastery.md` if not already present:
```markdown
## Git Patterns

### Commit Frequently
- Git is your safety net
- Create checkpoints before risky operations
- The robot wants to commit - let it

### Pre-Commit Hooks
- Use hooks to enforce quality
- Catches errors before they propagate
- Works well with Claude's commit enthusiasm

### Worktrees for Parallel Work
- Multiple Claude sessions on different branches
- Useful for complex plans
- Each worktree is isolated
```

## Files to Create
- None

## Files to Modify
- `.claude/commands/plan-prompts.md`: Ensure git workflow section complete
- `.claude/knowledge/claude-code-mastery.md`: Add git patterns section

## Patterns to Follow
Reference: Guide's git section
Reference: Step 4's checkpoint additions

## Acceptance Criteria
- [ ] Commit checkpoint patterns documented
- [ ] Commit message patterns listed
- [ ] Recovery commands documented
- [ ] Worktree guidance added
- [ ] Pre-commit hook recommendation included
- [ ] Knowledge base has git section
- [ ] Guidance is practical and actionable

## Testing Requirements
**N/A - Reason**: Documentation only
**Manual Verification**:
- Read through git guidance for completeness
- Verify commands are correct
- Check worktree guidance is accurate

## Verification Commands
```bash
# Verify git sections in prompts
grep -c "Git Workflow" .claude/commands/plan-prompts.md
grep -c "Commit Frequently" .claude/commands/plan-prompts.md
grep -c "checkpoint:" .claude/commands/plan-prompts.md

# Verify worktree guidance
grep -c "worktree" .claude/commands/plan-prompts.md

# Verify knowledge base
grep -c "Git Patterns" .claude/knowledge/claude-code-mastery.md
```

## Documentation Updates
- [ ] Update step notes in progress.json

## Error Recovery
If verification fails:
1. Identify missing git pattern
2. Review guide for reference
3. Add missing documentation
4. Re-run verification

## Do NOT
- Add CI/CD GitHub Actions content (excluded per decision)
- Make git guidance overly complex
- Skip the worktree documentation
- Forget recovery commands
