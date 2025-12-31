# Step 9: Update plan-next

## Context
The `/plan-next` command executes implementation steps. With technique-aware prompts, we need to update execution to respect phase transitions, track technique usage, and handle technique-specific verification.

## Goal
Update the `/plan-next` command to execute steps with technique-aware phases, track technique usage in progress, and apply appropriate verification based on the selected technique.

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: PS+ (structured execution flow)
- **Implementation**: Chain-of-Code (mix logic with semantic execution)
- **Verification**: Reflexion (self-correct execution issues)

## Risk Level
**High** - Core execution command modification

## Prerequisites
- Steps 1-8 completed (prompts are technique-embedded)

## High-Level Steps
1. Analyze current plan-next.md
2. Add phase-aware execution
3. Implement technique tracking
4. Add technique-specific verification
5. Integrate self-correction with retry config
6. Update progress tracking
7. Add technique transition logging
8. Test execution with various techniques

## Detailed Requirements

### Current Execution Flow
1. Load plan and current step
2. Load prompt
3. Execute prompt
4. Verify acceptance criteria
5. Handle success/failure
6. Update progress

### New Execution Flow
1. Load plan with technique metadata
2. Load current step with technique assignments
3. **Display technique information**
4. **Execute PLANNING phase with planning technique**
5. **Execute IMPLEMENTATION phase with implementation technique**
6. **Execute VERIFICATION phase with verification technique**
7. Apply technique-aware acceptance criteria
8. **Handle self-correction with retry config**
9. Update progress with technique usage

### Changes to plan-next.md

#### New Section: Technique Display

```markdown
### Step 5.5: Display Technique Information (NEW)

Before starting implementation:

\`\`\`
═══════════════════════════════════════════════════════════════
  STEP EXECUTION: {N} of {Total} - {Step Name}
═══════════════════════════════════════════════════════════════

  Problem Type: {step_type}
  Risk Level: {risk_level}

  Techniques:
  ┌─────────────────┬────────────────────────────────────────┐
  │ Planning        │ {planning_technique}                   │
  │ Implementation  │ {impl_technique(s)}                    │
  │ Verification    │ {verify_technique}                     │
  └─────────────────┴────────────────────────────────────────┘

  Retry Budget:
  - Same technique: {n} attempts
  - Alternative: {n} attempts
  - Total remaining: {n}

═══════════════════════════════════════════════════════════════
\`\`\`
```

#### New Section: Phase Execution

```markdown
### Step 6: Execute with Technique Phases (UPDATED)

#### Phase A: Planning
If the prompt includes a planning technique section:

1. Read the planning methodology (ToT, PS+, etc.)
2. Execute the planning steps
3. Document planning decisions
4. **Log**: "Planning phase complete using {technique}"

#### Phase B: Implementation
The core implementation using the assigned technique(s):

1. Load implementation methodology section
2. For multi-technique steps, execute in sequence:
   - Primary technique first
   - Then secondary refinements
3. Track which techniques were used
4. **Log**: "Implementation using {technique(s)}"

#### Phase C: Verification
Apply the verification technique:

1. Load verification methodology section
2. If Reflexion: Set up memory bank, prepare for retries
3. If Self-Consistency: Generate multiple verifications
4. If TDD: Run test suite
5. **Log**: "Verification using {technique}"
```

#### Updated Self-Correction

```markdown
### Step 7: Handle Verification with Self-Correction (UPDATED)

Based on retry configuration from risk assessment:

#### If Verification Fails - Attempt 1
\`\`\`
Current: Attempt 1 of {max_same_technique}
Technique: {current_technique}
\`\`\`

1. Read error/failure details
2. Apply technique-specific recovery:
   - **Reflexion**: Add to memory bank, consult lessons
   - **TDD**: Check test expectations, fix implementation
   - **Self-Refine**: Generate feedback, apply refinement

3. Retry with same technique

#### If Verification Fails - Attempt N (same technique exhausted)
\`\`\`
Switching technique: {current} → {alternative}
Attempt 1 of {max_alternative}
\`\`\`

1. Load alternative technique from rotation
2. Regenerate approach using new technique
3. Retry implementation

#### If All Retries Exhausted
\`\`\`
⚠️ ESCALATION REQUIRED
All {max_total} attempts exhausted.
Techniques tried: {list}
\`\`\`

1. Document all attempts and failures
2. Save partial progress
3. Request user intervention
```

#### Updated Progress Tracking

```markdown
### Step 8: Update Progress with Technique Data (UPDATED)

Update progress.json:

\`\`\`json
{
  "steps[N-1]": {
    "status": "completed",
    "completedAt": "{ISO date}",
    "techniquesUsed": [
      {"technique": "tdd", "phase": "implementation", "attempts": 1},
      {"technique": "reflexion", "phase": "verification", "attempts": 2}
    ],
    "finalAttempt": 2,
    "techniqueRotations": 0,
    "selfCorrectionNotes": [
      "Attempt 1 failed: Missing edge case",
      "Attempt 2 succeeded: Added nil check"
    ]
  }
}
\`\`\`

Update context.md with technique log:

\`\`\`markdown
## Step {N} Complete - {timestamp}

### Technique Execution Log
- Planning: {technique} - success on attempt 1
- Implementation: {technique} - success on attempt 1
- Verification: {technique} - success on attempt 2
  - Attempt 1: Failed due to {reason}
  - Lesson learned: {lesson}
  - Attempt 2: Applied {fix}, succeeded

### Files Created/Modified
...
\`\`\`
```

### Technique-Specific Verification

Different techniques require different verification approaches:

```python
VERIFICATION_HANDLERS = {
    "tdd": {
        "command": "xcodebuild test ...",
        "success_criteria": "All tests pass",
        "failure_action": "Review failing test, fix implementation"
    },
    "reflexion": {
        "command": "Run verification, capture output",
        "success_criteria": "All criteria met",
        "failure_action": "Add to memory bank, consult lessons, retry"
    },
    "self-consistency": {
        "command": "Run multiple times, compare outputs",
        "success_criteria": "Majority agreement",
        "failure_action": "Analyze disagreements, refine"
    },
    "self-refine": {
        "command": "Generate feedback, apply refinement",
        "success_criteria": "Quality score > threshold",
        "failure_action": "Generate new feedback, iterate"
    }
}
```

## Files to Create
- None (modifying existing)

## Files to Modify
- `.claude/commands/plan-next.md`: Complete technique-aware execution

## Patterns to Follow
Reference: Current plan-next.md structure (lines 1-449)

## Acceptance Criteria
- [ ] Technique information is displayed before execution
- [ ] Phases execute with their assigned techniques
- [ ] Self-correction respects retry configuration
- [ ] Technique rotation works when same technique fails
- [ ] Progress tracks all technique usage
- [ ] Context.md logs technique execution details
- [ ] Escalation works correctly when all retries exhausted

## Testing Requirements

### Manual Testing
- [ ] Execute step with TDD technique
- [ ] Execute step where verification fails, triggers self-correction
- [ ] Execute step where technique rotation occurs
- [ ] Verify progress.json has techniquesUsed

### Integration Test
```bash
# Verify technique tracking in progress
python3 -c "
import json
progress = json.load(open('.claude/plans/NNN/progress.json'))
step = progress['steps'][0]
assert 'techniquesUsed' in step
print('Technique tracking verified')
"
```

## Verification Commands
```bash
# Check technique display added
grep -q "Techniques:" .claude/commands/plan-next.md && echo "Display added"

# Check phase execution
grep -q "Phase A: Planning" .claude/commands/plan-next.md && echo "Phases added"

# Check technique tracking
grep -q "techniquesUsed" .claude/commands/plan-next.md && echo "Tracking added"
```

## Documentation Updates
- [ ] Update execution documentation in CLAUDE.md

## Error Recovery
If technique execution fails:
1. Log the failure with technique context
2. Fall back to generic execution
3. Mark step with technique-execution issue

## Do NOT
- Skip planning phase even if empty
- Ignore retry configuration
- Lose track of technique attempts
