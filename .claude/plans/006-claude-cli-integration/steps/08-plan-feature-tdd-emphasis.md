# Step 8: Plan-Feature TDD Emphasis

## Problem Type
`refactor`

## Technique Selection
- **Planning**: ps-plus - Structured approach to enhancing TDD guidance
- **Implementation**: self-refine - Iteratively strengthen TDD sections
- **Verification**: tdd - Verify TDD is prominently featured

## Risk Level
**medium** - Modifying core plan creation command

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Reasoning Depth
**Think hard about** how to make TDD the default rather than an option.

## Context
The guide emphasizes "The robots LOVE TDD" and recommends test-driven development as the primary approach. This step strengthens TDD emphasis in plan-feature.md so that generated plans prioritize TDD.

## Goal
Update plan-feature.md to make TDD the default implementation technique and strengthen testing requirements throughout.

## Prerequisites
- Step 1 completed (knowledge base with tdd-patterns.md)

## High-Level Steps
1. Read current plan-feature.md
2. Add TDD First Principle section
3. Update technique matrix to prefer TDD
4. Strengthen testing requirements section
5. Add TDD workflow reference
6. Verify TDD is prominently featured

## Detailed Requirements

### Add TDD First Principle
Add near the top after Process section intro:
```markdown
## Core Principle: Test-Driven Development
**The robots LOVE TDD.** Make it the default approach.

Every implementation step should follow TDD unless there's a specific reason not to:
1. Write failing tests that define expected behavior
2. Confirm tests fail for the right reason
3. Commit the tests (specification locked in)
4. Implement minimum code to pass
5. Refactor while tests stay green
6. Commit implementation

Benefits:
- Provides Claude with verifiable objectives
- Eliminates ambiguity about success criteria
- Reduces hallucination significantly
- Creates documentation via tests
```

### Update Technique Selection Guidance
Modify Step 6.5 technique selection:
```markdown
#### Implementation Technique Selection
When selecting implementation techniques, prefer TDD:

| Scenario | Primary Technique | Rationale |
|----------|------------------|-----------|
| Any code creation | TDD | Tests define success criteria |
| Algorithm/logic | TDD + Self-Consistency | Verify correctness |
| Service implementation | TDD + Self-Refine | Quality iteration |
| UI components | Self-Refine + Manual | Visual verification needed |
| Documentation only | Self-Refine | No testable code |

**Default to TDD** unless the step creates no testable code.
```

### Strengthen Testing Requirements
Update the testing section:
```markdown
### Testing Requirements (Mandatory)
**No step is complete without tests.** This is non-negotiable.

Every step that creates or modifies code MUST include:

1. **Test File Location**
   - Unit: `TangentleTests/Unit/{Feature}Tests.swift`
   - Integration: `TangentleTests/Integration/{Feature}IntegrationTests.swift`
   - UI: `TangentleUITests/{Feature}UITests.swift`

2. **Test Cases Required**
   - Happy path: Normal expected behavior
   - Edge cases: Boundary conditions
   - Error cases: Invalid input, failure scenarios
   - Integration: Component interactions (if applicable)

3. **TDD Workflow**
   ```
   Tests FIRST → Fail → Commit Tests → Implement → Pass → Commit Code
   ```

4. **Test Quality Standards**
   - Naming: `test{What}_when{Condition}_should{Expected}()`
   - Isolation: Each test independent
   - Speed: Unit tests under 100ms each
   - Coverage targets:
     - Services: 80%+
     - ViewModels: 70%+
     - Repositories: 60%+
```

### Add TDD Reference in Technique Matrix
Update the technique matrix header:
```markdown
## Technique Matrix

**Default Implementation Technique: TDD** (unless noted otherwise)

| Step | Problem Type | Planning | Implementation | Verification | Risk |
|------|--------------|----------|----------------|--------------|------|
```

### Pre-Commit Hook Recommendation
Add to quality standards:
```markdown
### Pre-Commit Verification
Consider using pre-commit hooks to enforce quality:

```bash
# Before every commit, automatically run:
# - Lint check
# - Type check (if applicable)
# - Unit tests for changed files
```

"The robot REALLLLLY wants to commit" - hooks catch errors before they propagate.
```

## Files to Create
- None

## Files to Modify
- `.claude/commands/plan-feature.md`: Strengthen TDD throughout

## Patterns to Follow
Reference: `.claude/knowledge/tdd-patterns.md` for workflow
Reference: Guide's TDD section

## Acceptance Criteria
- [ ] TDD First Principle section added prominently
- [ ] Technique matrix notes TDD as default
- [ ] Testing requirements section strengthened
- [ ] TDD workflow (6 steps) documented
- [ ] Coverage targets specified
- [ ] Pre-commit recommendation added
- [ ] "The robots LOVE TDD" quote included

## Testing Requirements
**N/A - Reason**: Command documentation enhancement
**Manual Verification**:
- Run `/plan-feature` on test description
- Verify generated plan emphasizes TDD
- Check technique matrix shows TDD preference

## Verification Commands
```bash
# Verify TDD sections
grep -c "robots LOVE TDD" .claude/commands/plan-feature.md
grep -c "Test-Driven Development" .claude/commands/plan-feature.md
grep -c "Tests FIRST" .claude/commands/plan-feature.md

# Verify technique guidance
grep -c "Default to TDD" .claude/commands/plan-feature.md
grep -c "Default Implementation Technique: TDD" .claude/commands/plan-feature.md

# Verify coverage targets
grep -c "80%+" .claude/commands/plan-feature.md
grep -c "70%+" .claude/commands/plan-feature.md
```

## Documentation Updates
- [ ] Update step notes in progress.json

## Error Recovery
If verification fails:
1. Identify missing TDD content
2. Review tdd-patterns.md for reference
3. Add missing sections
4. Re-run verification

## Do NOT
- Remove existing testing requirements (strengthen them)
- Make TDD optional (it's the default)
- Skip coverage target documentation
- Ignore the TDD workflow steps
