# Plan Verify Command

You are re-running verification for the current step of an implementation plan. This is useful when:
- Previous verification failed and you want to retry
- You made manual fixes and want to check them
- You want to ensure nothing regressed

## Dual Claude Review Pattern

For high-risk or complex steps, use the dual review pattern:

### The Pattern
1. **Claude A** implements the code
2. **Fresh context**: Use `/clear` or new terminal
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

### Review Checklist for Claude B
- [ ] Does the code follow project conventions?
- [ ] Are there any obvious bugs or edge cases missed?
- [ ] Is error handling appropriate?
- [ ] Are there security concerns?
- [ ] Is the code testable and tested?
- [ ] Does it match the step specification?

### When to Use
- High-risk steps (data migrations, security code)
- Complex algorithms with many edge cases
- Steps that have failed verification before
- Code that will be difficult to change later
- Core infrastructure changes

## Systematic Verification Protocol

Follow this order for comprehensive verification. Start with fastest checks to catch obvious issues quickly.

### 1. Syntax Verification (Fastest)
```bash
# Build without running
xcodebuild -scheme Tangentle -sdk iphonesimulator build
```
**Expect**: No compilation errors, no new warnings (unless documented)

### 2. Unit Test Verification
```bash
# Run tests for changed files
xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```
**Expect**: All existing tests pass, new tests pass, coverage meets targets

### 3. Lint Verification
```bash
# Run linter (if configured)
swiftlint lint --path {changed files}
```
**Expect**: No lint errors, style consistent

### 4. Integration Verification
- Verify component interactions work
- Check for circular dependencies
- Test with real (or mock) data
- Verify API contracts match

### 5. Manual Verification (Slowest)
- Visual inspection of UI changes
- User flow testing
- Edge case scenarios
- Performance spot-checks

### Verification Order Rationale
| Order | Check | Time | Catch |
|-------|-------|------|-------|
| 1 | Syntax | Seconds | Typos, import errors |
| 2 | Unit Tests | Minutes | Logic errors, regressions |
| 3 | Lint | Seconds | Style violations |
| 4 | Integration | Minutes | Contract violations |
| 5 | Manual | Variable | UX issues, visual bugs |

Start with fastest checks to fail fast on obvious issues.

## Subagent Verification (Phase 2)

> **Note**: Custom subagents are planned for Phase 2 of this integration.

The guide recommends using subagents for specialized verification:

### Planned Subagents
| Agent | Purpose | Use Case |
|-------|---------|----------|
| `code-reviewer` | Expert code review | After implementation |
| `test-writer` | Test creation | Coverage gaps |
| `security-checker` | Security audit | Sensitive code |

### Future Usage Pattern
```
Use the code-reviewer subagent to check my recent changes.
```

### Current Alternative
Until subagents are available, use:
- **Dual Claude Review pattern** (above)
- **Fresh context review**: `/clear` then ask for review
- **Manual checklist**: Use review checklist provided

## Input
Plan identifier: $ARGUMENTS

## Process

### Step 1: Locate Plan and Current Step
```bash
PLAN_DIR=$(ls -d .claude/plans/$ARGUMENTS* 2>/dev/null | head -1)
cat $PLAN_DIR/progress.json
```

Get the `currentStep` value and load that step's prompt.

### Step 2: Load Verification Section
From the prompt file, extract only the verification section:
- Acceptance Criteria
- Verification Commands

### Step 3: Run Each Verification
For each acceptance criterion:

```
═══════════════════════════════════════════════════════════════
  VERIFICATION: Step {N} - {Step Name}
═══════════════════════════════════════════════════════════════

## AC1: {Description}
Command: {command}
Expected: {expected}

Running...

Result: {actual output}
Status: ✅ PASS / ❌ FAIL

---

## AC2: {Description}
...
```

### Step 3.5: Apply Technique-Specific Verification

If the step has technique metadata in progress.json, apply technique-specific verification. Otherwise, use the standard flow above.

Check the step's verification technique:
```javascript
const step = progress.steps[currentStep - 1];
const verificationTechnique = step.techniques?.verification || 'standard';
```

Based on the verification technique used for this step:

#### If TDD Verification
```
═══════════════════════════════════════════════════════════════
  Verification Mode: TDD
  Expected: All tests pass
═══════════════════════════════════════════════════════════════
```

- Run test suite: `xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests 2>&1 | tail -30`
- Report: X/Y tests passing
- For failures: Show test name, expected vs actual

#### If Reflexion Verification
```
═══════════════════════════════════════════════════════════════
  Verification Mode: Reflexion
  Memory Bank: {lessons from previous attempts}
═══════════════════════════════════════════════════════════════
```

- Run criteria verification
- Consult memory bank from `step.selfCorrectionNotes` for known issues
- Suggest fixes based on past lessons

#### If Self-Consistency Verification
```
═══════════════════════════════════════════════════════════════
  Verification Mode: Self-Consistency
  Runs: 3 independent verifications
  Threshold: 2/3 agreement required
═══════════════════════════════════════════════════════════════
```

- Run verification multiple times (3 runs)
- Compare outputs for consistency
- Report agreement/disagreement level

#### If Self-Refine Verification
```
═══════════════════════════════════════════════════════════════
  Verification Mode: Self-Refine
  Current Iteration: {n}
  Quality Threshold: 90%
═══════════════════════════════════════════════════════════════
```

- Generate quality feedback against acceptance criteria
- Score against threshold (90% for production code)
- Suggest refinements if below threshold

#### If GoT (Graph of Thoughts) Verification
```
═══════════════════════════════════════════════════════════════
  Verification Mode: GoT
  Aggregation: Multiple verification paths
═══════════════════════════════════════════════════════════════
```

- Run multiple verification approaches
- Aggregate findings from different paths
- Report consolidated results

#### Standard Verification (Legacy Plans)
For steps without technique metadata, use the standard verification flow from Step 3 above.

### Step 4: Summary Report

#### All Pass
```
═══════════════════════════════════════════════════════════════
  ✅ VERIFICATION PASSED
═══════════════════════════════════════════════════════════════

All {N} acceptance criteria passed.

## Results
✓ AC1: {description}
✓ AC2: {description}
✓ AC3: {description}

## Next Action
If this was a retry after fixes, run:
`/plan-next $ARGUMENTS`

This will:
1. Mark step as complete
2. Update progress tracking
3. Advance to next step
═══════════════════════════════════════════════════════════════
```

#### Some Fail
```
═══════════════════════════════════════════════════════════════
  ⚠️ VERIFICATION PARTIAL
═══════════════════════════════════════════════════════════════

{X} of {N} acceptance criteria passed.

## Results
✓ AC1: {description}
✗ AC2: {description}
  Error: {error details}
✓ AC3: {description}

## Failed Criterion Details
### AC2: {description}
**Command**: {command}
**Expected**: {expected}
**Actual**: {actual}

**Possible Causes**:
1. {cause 1}
2. {cause 2}

**Suggested Fixes**:
1. {fix 1}
2. {fix 2}

## Next Actions
1. Review the failed criterion
2. Apply suggested fix
3. Run `/plan-verify $ARGUMENTS` again
═══════════════════════════════════════════════════════════════
```

#### All Fail
```
═══════════════════════════════════════════════════════════════
  ❌ VERIFICATION FAILED
═══════════════════════════════════════════════════════════════

All {N} acceptance criteria failed.

## Results
✗ AC1: {description} - {error}
✗ AC2: {description} - {error}
✗ AC3: {description} - {error}

## Analysis
This likely indicates:
- Prerequisites not met
- Fundamental implementation issue
- Environment problem

## Recommended Actions
1. Check prerequisites:
   {prerequisite check commands}

2. Verify environment:
   {environment check commands}

3. Review implementation against spec:
   {relevant file paths}

4. Consider rollback if changes broke things:
   `/plan-rollback $ARGUMENTS`
═══════════════════════════════════════════════════════════════
```

### Step 4.5: Technique-Specific Failure Analysis

When verification fails and the step has technique metadata, provide technique-aware guidance:

#### TDD Failures
```
═══════════════════════════════════════════════════════════════
  TDD VERIFICATION FAILED
═══════════════════════════════════════════════════════════════

  Tests: {passed}/{total} passing

  Failing Tests:
  ✗ {testName}
    Expected: {expected}
    Actual: {actual}

  TDD Recovery Steps:
  1. Read the failing test assertions carefully
  2. Check implementation against test expectations
  3. The test is the spec - fix implementation, not test
  4. Run tests after each fix

═══════════════════════════════════════════════════════════════
```

#### Reflexion Failures
```
═══════════════════════════════════════════════════════════════
  REFLEXION VERIFICATION FAILED
═══════════════════════════════════════════════════════════════

  Memory Bank (from previous attempts):
  - Lesson 1: {lesson from selfCorrectionNotes[0]}
  - Lesson 2: {lesson from selfCorrectionNotes[1]}

  Current Failure:
  ✗ {AC}: {description}

  Analysis: {NEW failure / REPEAT failure (in memory bank)}

  Recommended:
  1. Add this failure to memory bank (if new)
  2. Consult memory bank for similar past failures
  3. Identify root cause
  4. Apply fix informed by lessons learned
  5. Re-verify

═══════════════════════════════════════════════════════════════
```

#### Self-Consistency Failures
```
═══════════════════════════════════════════════════════════════
  SELF-CONSISTENCY VERIFICATION FAILED
═══════════════════════════════════════════════════════════════

  Verification Runs:
  - Run 1: {PASS/FAIL} {details}
  - Run 2: {PASS/FAIL} {details}
  - Run 3: {PASS/FAIL} {details}

  Agreement: {n}/3 (below 2/3 threshold)

  Inconsistency Analysis:
  {AC} fails intermittently, suggesting:
  - Race condition
  - Non-deterministic behavior
  - State leakage between runs

  Recommended:
  1. Check for async/timing issues
  2. Mock external dependencies for determinism
  3. Add deterministic seeding where randomness used
  4. Isolate test state between runs

═══════════════════════════════════════════════════════════════
```

#### Self-Refine Failures
```
═══════════════════════════════════════════════════════════════
  SELF-REFINE VERIFICATION FAILED
═══════════════════════════════════════════════════════════════

  Quality Score: {score}%
  Threshold: 90%
  Gap: {gap}%

  Quality Feedback:
  - {issue 1}
  - {issue 2}

  Refinement Suggestions:
  1. {suggestion 1}
  2. {suggestion 2}

  Next Iteration:
  Apply refinements and run verification again.
  Max iterations: 3

═══════════════════════════════════════════════════════════════
```

#### GoT Failures
```
═══════════════════════════════════════════════════════════════
  GoT VERIFICATION FAILED
═══════════════════════════════════════════════════════════════

  Aggregated Findings:
  - Path 1: {result}
  - Path 2: {result}
  - Path 3: {result}

  Consensus: {agreement level}

  Conflicting Results:
  - {where paths disagree}

  Recommended:
  1. Investigate conflicting verification paths
  2. Determine which path is authoritative
  3. Resolve ambiguity in acceptance criteria

═══════════════════════════════════════════════════════════════
```

#### Standard Failure Analysis (Legacy Plans)
For steps without technique metadata, use the standard failure analysis from Step 4 above.

### Step 5: Suggest Technique Switch

If current technique isn't working well after multiple failures, suggest alternatives:

```
═══════════════════════════════════════════════════════════════
  TECHNIQUE SWITCH SUGGESTION
═══════════════════════════════════════════════════════════════

  Current technique: {technique}
  Failures with this technique: {n}
  Pattern detected: {pattern}

  Suggested alternative: {alternative_technique}
  Reason: {why this might work better}

  To switch: Re-run /plan-next with self-correction
  Or: Let retry logic handle it automatically

═══════════════════════════════════════════════════════════════
```

**Patterns that trigger suggestions**:
| Pattern | Current | Suggested | Reason |
|---------|---------|-----------|--------|
| Async failures | TDD | ReAct | ReAct handles action-observation loops |
| Not converging | Self-Refine | Reflexion | Reflexion uses memory for persistent learning |
| Memory bank full | Reflexion | Self-Consistency | Fresh perspective via multiple runs |
| Inconsistent results | Standard | Self-Consistency | Identify non-determinism |
| Complex logic errors | TDD | Chain-of-Code | Mix executable with semantic reasoning |

### Step 6: Update Progress
After verification, update progress.json:

```json
{
  "steps[N-1].lastVerification": "{timestamp}",
  "steps[N-1].verificationPassed": {true/false},
  "steps[N-1].attempts": {increment},
  "steps[N-1].verificationTechnique": "{technique used}",
  "steps[N-1].techniquesSuggested": ["{any switch suggestions}"]
}
```

## Verification Failure Analysis

When verification fails, systematically diagnose:

### 1. Identify Failure Type
| Failure | Likely Cause | Action |
|---------|--------------|--------|
| Build fails | Syntax/import error | Fix specific error message |
| Tests fail | Logic error or spec mismatch | Debug test output |
| Lint fails | Style violation | Auto-fix or manual correction |
| Integration fails | Interface mismatch | Check contracts between components |
| Manual fails | Logic/UX issue | Review requirements |

### 2. Diagnose Root Cause
For each failure type:

**Build failures**:
- Read the exact error message
- Check import statements
- Verify type definitions
- Check for typos

**Test failures**:
- Read test output for expected vs actual
- Check if implementation matches spec
- Verify test expectations are correct
- Look for off-by-one errors, edge cases

**Integration failures**:
- Check that interfaces match
- Verify data formats
- Look for timing issues
- Check dependency injection

### 3. Apply Technique Rotation
If same failure persists after fix attempt:
- First retry: Same technique, different approach
- Second retry: Alternative technique
- Third retry: Escalate to user or try TDD if not already

### 4. Update Memory Bank
Record failure and resolution in context.md:
```markdown
## Learnings
- {Failure type}: {What caused it}
- {Diagnosis}: {How it was found}
- {Fix}: {What resolved it}
- {Prevention}: {How to avoid in future}
```

### 5. Consider CLAUDE.md Update
If failure reveals missing guidance:
- Add convention that was violated
- Add warning for common mistake
- Update testing requirements

## Verification Best Practices

### Command Verification
- Run exact command from prompt
- Capture both stdout and stderr
- Compare against expected output
- Consider timing for async operations

### State Verification
- Check file existence
- Verify file contents
- Test API endpoints
- Check database state (if applicable)

### Integration Verification
- Ensure new code works with existing
- Check for regressions
- Verify no circular dependencies
- Test error handling paths
