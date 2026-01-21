# Step 10: Plan-Verify Enhancement

## Problem Type
`refactor`

## Technique Selection
- **Planning**: ps-plus - Structured enhancement approach
- **Implementation**: self-refine - Iteratively improve verification
- **Verification**: self-refine - Verify all guide patterns included

## Risk Level
**low** - Adding documentation to existing command

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Reasoning Depth
**Think about** verification best practices from the guide.

## Context
The guide describes verification patterns including dual Claude review and systematic verification. This step enhances plan-verify.md with these patterns.

## Goal
Update plan-verify.md with enhanced verification protocols from the Claude Code CLI guide.

## Prerequisites
- Step 1 completed (knowledge base for reference)

## High-Level Steps
1. Read current plan-verify.md
2. Add Dual Claude Review pattern
3. Add systematic verification protocol
4. Add subagent verification guidance (reference for Phase 2)
5. Verify all patterns documented

## Detailed Requirements

### Dual Claude Review Pattern
Add section:
```markdown
## Dual Claude Review Pattern

For high-risk or complex steps, use the dual review pattern:

### The Pattern
1. **Claude A** implements the code
2. **Fresh context** - Use `/clear` or new terminal
3. **Claude B** reviews the implementation
4. **Address feedback** from review
5. **Final verification** and commit

### How to Execute
```
# After implementation is "complete"
/clear

# In fresh context:
Review the changes in {file paths} for:
1. Code quality and readability
2. Security vulnerabilities
3. Performance implications
4. Test coverage gaps
5. Adherence to project patterns

Provide specific feedback on issues found.
```

### When to Use
- High-risk steps (data migrations, security code)
- Complex algorithms
- Steps that have failed verification before
- Code that will be difficult to change later
```

### Systematic Verification Protocol
Add section:
```markdown
## Systematic Verification Protocol

Follow this order for comprehensive verification:

### 1. Syntax Verification
```bash
# Build without running
xcodebuild -scheme Tangentle -sdk iphonesimulator build
```
- No compilation errors
- No new warnings (unless documented)

### 2. Test Verification
```bash
# Run tests for changed files
xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```
- All existing tests pass
- New tests pass
- Coverage meets targets

### 3. Lint Verification
```bash
# Run linter (if configured)
swiftlint lint --path {changed files}
```
- No lint errors
- Style consistent

### 4. Integration Verification
- Verify component interactions work
- Check for circular dependencies
- Test with real (or mock) data

### 5. Manual Verification
- Visual inspection of UI changes
- User flow testing
- Edge case scenarios

### Verification Order Rationale
Start with fastest checks (syntax) to catch obvious issues quickly.
Progress to slower, more comprehensive checks.
Manual verification last as it's most time-consuming.
```

### Subagent Verification Reference
Add section (for future Phase 2):
```markdown
## Subagent Verification (Future)

> Note: Custom subagents are planned for Phase 2 of this integration.

The guide recommends using subagents for specialized verification:

### Planned Subagents
- **code-reviewer**: Expert code review specialist
- **test-writer**: Test creation and coverage verification

### Usage Pattern (When Available)
```
Use the code-reviewer subagent to check my recent changes.
```

### Current Alternative
Until subagents are available, use the Dual Claude Review pattern above.
```

### Enhanced Failure Analysis
Add to existing failure handling:
```markdown
## Verification Failure Analysis

When verification fails, systematically diagnose:

### 1. Identify Failure Type
| Failure | Likely Cause | Action |
|---------|--------------|--------|
| Build fails | Syntax/import error | Fix specific error |
| Tests fail | Logic error or spec mismatch | Debug test output |
| Lint fails | Style violation | Auto-fix or manual |
| Integration fails | Interface mismatch | Check contracts |
| Manual fails | Logic/UX issue | Review requirements |

### 2. Apply Technique Rotation
If same failure persists:
- First retry: Same technique, different approach
- Second retry: Alternative technique
- Third retry: Escalate to user

### 3. Update Memory Bank
Record failure and resolution in context.md:
```markdown
## Learnings
- {Failure description}: {What fixed it}
```
```

## Files to Create
- None

## Files to Modify
- `.claude/commands/plan-verify.md`: Add enhanced verification protocols

## Patterns to Follow
Reference: Guide's verification patterns
Reference: Existing plan-verify.md structure

## Acceptance Criteria
- [ ] Dual Claude Review pattern documented
- [ ] Systematic verification protocol (5 steps) added
- [ ] Subagent reference for Phase 2 included
- [ ] Failure analysis section enhanced
- [ ] Verification order rationale explained
- [ ] Command remains functional

## Testing Requirements
**N/A - Reason**: Command documentation enhancement
**Manual Verification**:
- Read through updated command
- Verify patterns are comprehensive
- Check guidance is actionable

## Verification Commands
```bash
# Verify new sections
grep -c "Dual Claude Review" .claude/commands/plan-verify.md
grep -c "Systematic Verification Protocol" .claude/commands/plan-verify.md
grep -c "Subagent Verification" .claude/commands/plan-verify.md
grep -c "Failure Analysis" .claude/commands/plan-verify.md

# Verify verification steps
grep -c "Syntax Verification" .claude/commands/plan-verify.md
grep -c "Test Verification" .claude/commands/plan-verify.md
grep -c "Integration Verification" .claude/commands/plan-verify.md
```

## Documentation Updates
- [ ] Update step notes in progress.json

## Error Recovery
If verification fails:
1. Identify missing pattern
2. Review guide for reference
3. Add missing documentation
4. Re-run verification

## Do NOT
- Remove existing verification logic
- Implement subagents (Phase 2)
- Skip the dual review documentation
- Make verification overly complex
