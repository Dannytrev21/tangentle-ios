# Step 13: Integration Verification

## Problem Type
`integration-test`

## Technique Selection
- **Planning**: least-to-most - Start simple, build to complex tests
- **Implementation**: tdd - Write test scenarios first
- **Verification**: reflexion - Learn from any failures

## Risk Level
**medium** - Testing all integrated changes

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Reasoning Depth
**Ultrathink about** comprehensive verification of all integration points.

## Context
This final step verifies that all components work together correctly. It tests the full workflow from plan creation to prompt generation to execution.

## Goal
Verify all enhanced commands work together and produce expected outputs with all guide principles embedded.

## Prerequisites
- All previous steps (1-12) completed

## High-Level Steps
1. Create test plan using enhanced plan-feature-initial
2. Generate prompts with plan-prompts
3. Verify prompts contain all expected sections
4. Test plan-next execution flow
5. Test recovery patterns
6. Document integration test results

## Detailed Requirements

### Test Scenario 1: Plan Creation Flow
```bash
# Create a test plan (or use plan 006)
/plan-feature-initial "Test feature for integration verification"
```

Verify:
- [ ] Explore phase is prompted
- [ ] Problem type classification occurs
- [ ] Thinking keyword question addressed (if applicable)

### Test Scenario 2: Prompt Generation
```bash
# Generate prompts for plan 006
/plan-prompts 006
```

Verify each generated prompt contains:
- [ ] Reasoning Depth section with appropriate thinking keyword
- [ ] TDD workflow in Implementation Guide
- [ ] Context Management section
- [ ] Git Checkpoint guidance
- [ ] No {THINKING_KEYWORD} placeholder remaining
- [ ] Verification Protocol section

### Test Scenario 3: Risk-Based Thinking Keywords
Check prompts for steps with different risk levels:

| Step | Risk | Expected Keyword |
|------|------|------------------|
| 1 (knowledge-base) | low | "Think about" |
| 2 (claude-md) | medium | "Think hard about" |
| 13 (integration) | medium | "Think hard about" |

Verify:
```bash
grep "Think about" .claude/plans/006-claude-cli-integration/prompts/01-*.md
grep "Think hard about" .claude/plans/006-claude-cli-integration/prompts/02-*.md
```

### Test Scenario 4: Python Script Verification
```bash
# Test thinking keyword CLI
python3 .claude/scripts/tangentle_plan.py thinking low
python3 .claude/scripts/tangentle_plan.py thinking medium
python3 .claude/scripts/tangentle_plan.py thinking high

# Test techniques shows thinking keyword
python3 .claude/scripts/tangentle_plan.py techniques debug | grep -i think

# Run all Python tests
cd .claude/scripts && python3 -m pytest -v
```

### Test Scenario 5: CLAUDE.md Verification
```bash
# Verify line count
wc -l CLAUDE.md  # Should be ~250 lines

# Verify @imports exist
grep "@.claude/knowledge" CLAUDE.md

# Verify knowledge files exist and are referenced
ls .claude/knowledge/*.md
```

### Test Scenario 6: Command Verification
Test each enhanced command:

```bash
# plan-feature-initial - should show explore phase
/plan-feature-initial "Test exploration"

# plan-next - should show context guidance
/plan-next 006

# plan-rollback - should show recovery patterns
/plan-rollback 006

# plan-verify - should show dual review option
/plan-verify 006
```

### Test Scenario 7: Knowledge Base Verification
```bash
# Verify all knowledge files exist
ls -la .claude/knowledge/

# Verify content is present
grep -c "explore, plan, code, commit" .claude/knowledge/claude-code-mastery.md
grep -c "ultrathink" .claude/knowledge/thinking-keywords.md
grep -c "/compact" .claude/knowledge/context-management.md
grep -c "TDD" .claude/knowledge/tdd-patterns.md
```

### Integration Test Checklist
Create `.claude/plans/006-claude-cli-integration/reviews/integration-test-results.md`:

```markdown
# Integration Test Results - Plan 006

**Date**: {date}
**Tester**: {who}

## Test Results

### Plan Creation Flow
- [ ] Explore phase prompted
- [ ] Classification works
- [ ] Progress.json created correctly

### Prompt Generation
- [ ] All prompts generated
- [ ] Thinking keywords correct
- [ ] TDD section present
- [ ] Context guidance present
- [ ] Git checkpoints present
- [ ] No placeholders remaining

### Python Scripts
- [ ] All tests pass
- [ ] CLI commands work
- [ ] Thinking keyword lookup works

### CLAUDE.md
- [ ] Line count acceptable (~250)
- [ ] @imports work
- [ ] Essential content preserved

### Knowledge Base
- [ ] All 5 files exist
- [ ] README provides index
- [ ] Content is accurate

### Commands
- [ ] plan-feature-initial enhanced
- [ ] plan-feature enhanced
- [ ] plan-prompts enhanced
- [ ] plan-next enhanced
- [ ] plan-rollback enhanced
- [ ] plan-verify enhanced

## Issues Found
{List any issues}

## Recommendations
{List any recommendations}

## Sign-Off
All integration tests pass: [ ] Yes / [ ] No

Notes:
{Additional notes}
```

## Files to Create
- `.claude/plans/006-claude-cli-integration/reviews/integration-test-results.md`

## Files to Modify
- None (verification only)

## Patterns to Follow
Reference: All previous step acceptance criteria

## Acceptance Criteria
- [ ] Plan creation flow works with explore phase
- [ ] Prompts generated with correct thinking keywords
- [ ] No placeholder text in any generated prompt
- [ ] Python tests all pass
- [ ] CLAUDE.md is appropriately sized with working imports
- [ ] All knowledge base files exist and have content
- [ ] All enhanced commands execute without errors
- [ ] Integration test results documented

## Testing Requirements

### Integration Tests
- [ ] Test file: `.claude/plans/006-claude-cli-integration/reviews/integration-test-results.md`
- [ ] All test scenarios executed
- [ ] Results documented

### What to Test
- Full workflow from initial to prompts to next
- Each command individually
- Python script functionality
- Knowledge base accessibility
- CLAUDE.md imports

## Verification Commands
```bash
# Full verification script
echo "=== CLAUDE.md Verification ==="
wc -l CLAUDE.md
grep -c "@.claude/knowledge" CLAUDE.md

echo "=== Knowledge Base ==="
ls -la .claude/knowledge/

echo "=== Python Tests ==="
cd .claude/scripts && python3 -m pytest -v

echo "=== Thinking Keywords ==="
python3 .claude/scripts/tangentle_plan.py thinking low
python3 .claude/scripts/tangentle_plan.py thinking medium
python3 .claude/scripts/tangentle_plan.py thinking high

echo "=== Generated Prompts Check ==="
ls .claude/plans/006-claude-cli-integration/prompts/
grep -r "THINKING_KEYWORD" .claude/plans/006-claude-cli-integration/prompts/ || echo "No placeholders found - GOOD"
```

## Documentation Updates
- [ ] Update progress.json to mark plan complete
- [ ] Update context.md with final summary

## Error Recovery
If verification fails:
1. Identify which component failed
2. Review the relevant step
3. Fix the specific issue
4. Re-run that step's verification
5. Continue integration testing

## Do NOT
- Skip any test scenario
- Mark complete without documentation
- Ignore failing tests
- Skip the integration test results file

## Post-Completion
After all tests pass:
1. Mark plan 006 as complete in progress.json
2. Update context.md with final summary
3. Commit all changes
4. Consider announcing completion

```bash
git add -A && git commit -m "Plan 006 complete: Claude CLI System Full Integration"
```
