# Step 10: Update plan-verify

## Context
The `/plan-verify` command re-runs verification for a step. With techniques now tracked, verification needs to be aware of which technique was used and apply appropriate verification strategies.

## Goal
Update the `/plan-verify` command to apply technique-aware verification and provide technique-specific guidance for failures.

## Problem Type
`refactor`

## Technique Selection
- **Planning**: PS+ (structured verification updates)
- **Implementation**: Self-Refine (iterate on verification quality)
- **Verification**: TDD (test verification behavior)

## Risk Level
**Medium** - Verification accuracy matters but isolated

## Prerequisites
- Steps 1-9 completed (execution tracks techniques)

## High-Level Steps
1. Analyze current plan-verify.md
2. Add technique-aware verification logic
3. Implement technique-specific failure analysis
4. Update verification reporting
5. Add technique switching suggestions
6. Test with various techniques

## Detailed Requirements

### Current Verification Flow
1. Load plan and step
2. Extract acceptance criteria
3. Run verification commands
4. Report results

### New Verification Flow
1. Load plan with technique metadata
2. Load current step with technique used
3. **Apply technique-appropriate verification**
4. Run verification commands
5. **If fails: provide technique-specific guidance**
6. **Suggest technique switch if pattern detected**
7. Report results with technique context

### Changes to plan-verify.md

#### New Section: Technique-Aware Verification

```markdown
### Step 3.5: Apply Technique-Specific Verification (NEW)

Based on the verification technique used:

#### If TDD Verification
\`\`\`
Verification Mode: TDD
Expected: All tests pass
Command: xcodebuild test -scheme Tangentle ...
\`\`\`

- Run test suite
- Report: X/Y tests passing
- For failures: Show test name and assertion

#### If Reflexion Verification
\`\`\`
Verification Mode: Reflexion
Memory Bank: {lessons from previous attempts}
Command: [verification commands from prompt]
\`\`\`

- Run criteria verification
- Consult memory bank for known issues
- Suggest fixes based on past lessons

#### If Self-Consistency Verification
\`\`\`
Verification Mode: Self-Consistency
Runs: 3 independent verifications
Threshold: 2/3 agreement required
\`\`\`

- Run verification multiple times
- Compare outputs
- Report agreement/disagreement

#### If Self-Refine Verification
\`\`\`
Verification Mode: Self-Refine
Current Iteration: {n}
Quality Threshold: {threshold}
\`\`\`

- Generate quality feedback
- Score against threshold
- Suggest refinements if below threshold
```

#### Updated Failure Analysis

```markdown
### Step 4.5: Technique-Specific Failure Analysis (NEW)

When verification fails, provide technique-aware guidance:

#### TDD Failures
\`\`\`
═══════════════════════════════════════════════════════════════
  TDD VERIFICATION FAILED
═══════════════════════════════════════════════════════════════

  Tests: 5/7 passing

  Failing Tests:
  ✗ testCreateTask_whenTitleEmpty_shouldFail
    Expected: Error thrown
    Actual: No error, task created

  ✗ testFetchTasks_whenEmpty_shouldReturnEmptyArray
    Expected: []
    Actual: nil

  TDD Recovery Steps:
  1. Read the failing test assertions carefully
  2. Check implementation against test expectations
  3. The test is the spec - fix implementation, not test
  4. Run tests after each fix

═══════════════════════════════════════════════════════════════
\`\`\`

#### Reflexion Failures
\`\`\`
═══════════════════════════════════════════════════════════════
  REFLEXION VERIFICATION FAILED
═══════════════════════════════════════════════════════════════

  Memory Bank (from previous attempts):
  - Lesson 1: Edge case X needs nil check
  - Lesson 2: Method Y expects unwrapped optional

  Current Failure:
  ✗ AC2: Handle empty state

  Analysis:
  This is a NEW failure (not in memory bank).

  Recommended:
  1. Add this failure to memory bank
  2. Identify root cause
  3. Apply fix
  4. Re-verify

═══════════════════════════════════════════════════════════════
\`\`\`

#### Self-Consistency Failures
\`\`\`
═══════════════════════════════════════════════════════════════
  SELF-CONSISTENCY VERIFICATION FAILED
═══════════════════════════════════════════════════════════════

  Verification Runs:
  - Run 1: PASS
  - Run 2: FAIL (AC2)
  - Run 3: FAIL (AC2)

  Agreement: 1/3 (below 2/3 threshold)

  Inconsistency Analysis:
  AC2 fails intermittently, suggesting:
  - Race condition
  - Non-deterministic behavior
  - External dependency variability

  Recommended:
  1. Check for async/timing issues
  2. Mock external dependencies
  3. Add deterministic seeding

═══════════════════════════════════════════════════════════════
\`\`\`
```

#### Technique Switch Suggestion

```markdown
### Step 5: Suggest Technique Switch (NEW)

If current technique isn't working well, suggest alternatives:

\`\`\`
═══════════════════════════════════════════════════════════════
  TECHNIQUE SWITCH SUGGESTION
═══════════════════════════════════════════════════════════════

  Current technique: {technique}
  Failures with this technique: {n}
  Pattern detected: {pattern}

  Suggested alternative: {alternative_technique}
  Reason: {why this might work better}

  To switch: Re-run /plan-next with --technique={alternative}
  Or: Let self-correction handle it (if retries remain)

═══════════════════════════════════════════════════════════════
\`\`\`

Patterns that trigger suggestions:
- TDD failing on async code → suggest ReAct
- Self-Refine not converging → suggest Reflexion
- Reflexion memory bank full but still failing → suggest Self-Consistency
```

## Files to Create
- None (modifying existing)

## Files to Modify
- `.claude/commands/plan-verify.md`: Add technique-aware verification

## Patterns to Follow
Reference: Current plan-verify.md structure (lines 1-174)

## Acceptance Criteria
- [ ] Verification applies technique-appropriate methods
- [ ] Failure analysis is technique-specific
- [ ] Technique switch suggestions work
- [ ] Memory bank is consulted for Reflexion
- [ ] Self-Consistency runs multiple times

## Testing Requirements

### Manual Testing
- [ ] Verify step with TDD technique
- [ ] Verify step with Reflexion technique
- [ ] Trigger technique switch suggestion

## Verification Commands
```bash
# Check technique-aware sections
grep -q "Technique-Specific Verification" .claude/commands/plan-verify.md

# Check failure analysis
grep -q "TDD VERIFICATION FAILED" .claude/commands/plan-verify.md
```

## Documentation Updates
- [ ] Update verification docs in CLAUDE.md

## Error Recovery
If technique-specific verification fails to run:
1. Fall back to generic verification
2. Log the issue

## Do NOT
- Require technique for basic verification to work
- Lose verification results
