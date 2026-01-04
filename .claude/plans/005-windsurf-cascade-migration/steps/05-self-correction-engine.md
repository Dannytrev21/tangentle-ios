# Step 5: Self-Correction Engine

## Problem Type
`migration`

## Technique Selection
- **Planning**: least-to-most - Build from memory bank up to full engine
- **Implementation**: chain-of-code - Complex logic with state management
- **Verification**: reflexion - Use the engine to verify itself (meta!)

## Risk Level
**medium** - Complex stateful logic; needs thorough testing

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
The self-correction engine is the sophisticated retry system that enables learning from failures. It maintains a memory bank of lessons learned, tracks retry attempts, and rotates to alternative techniques when the primary approach fails repeatedly.

## Goal
Port the self-correction engine to `.windsurf/scripts/` with full memory bank support, retry budgets, and technique rotation logic.

## Prerequisites
- Step 2 completed (Python foundation with risk_assessor.py)
- Step 4 completed (technique knowledge files for rotation)

## High-Level Steps
1. Port `memory_bank.py` with FIFO entry management
2. Port `self_correction.py` with retry logic
3. Create technique rotation algorithm
4. Integrate with progress.json state tracking
5. Create unit tests for all components
6. Test failure → retry → rotation → escalation flow

## Detailed Requirements

### Memory Bank Structure
```python
class MemoryBankEntry:
    timestamp: str         # ISO datetime
    step_id: int          # Which step
    failure_type: str     # What failed
    context: str          # What was attempted
    lesson: str           # What was learned
    technique_used: str   # Which technique was active
    resolution: str       # How it was resolved (or "escalated")
```

### Memory Bank File Format
`.windsurf/plans/{NNN}/memory-bank.json`:
```json
{
  "maxEntries": 10,
  "entries": [
    {
      "timestamp": "2026-01-02T10:30:00Z",
      "stepId": 3,
      "failureType": "test_failure",
      "context": "Unit test for TaskRepository.create() failed",
      "lesson": "Need to mock Core Data context in tests",
      "techniqueUsed": "tdd",
      "resolution": "Added in-memory persistent container"
    }
  ]
}
```

### Retry Budget by Risk Level
| Risk | Same Technique | Alternative | Total | Escalation |
|------|----------------|-------------|-------|------------|
| Low | 2 | 1 | 3 | After 3 |
| Medium | 3 | 2 | 5 | After 5 |
| High | 3 | 3 | 7 | After 5 |
| Critical | 5 | 5 | 10 | After 7 |

### Technique Rotation Logic
When same-technique retries exhausted, rotate based on failure pattern:

| Failure Pattern | Keywords | Suggested Technique |
|-----------------|----------|---------------------|
| Test failure | test, assert, expect | TDD |
| Not converging | iteration, loop, infinite | Self-Consistency |
| Architecture issue | design, structure, pattern | ToT |
| Async/timing | async, await, race, timeout | ReAct |
| Repeated mistakes | same error, again, still | Reflexion |
| Integration issue | connect, API, service | Chain-of-Code |

### Self-Correction Flow
```
1. Verification fails
   ↓
2. Record failure in memory bank
   ↓
3. Check retry budget (from progress.json step.retryConfig)
   ↓
4. Same technique retries remaining?
   ├─ YES: Increment attempts, provide guidance from memory bank
   │       Return: {"action": "retry", "technique": current, "guidance": lessons}
   │
   └─ NO: Alternative retries remaining?
       ├─ YES: Select alternative technique based on failure pattern
       │       Return: {"action": "rotate", "technique": new, "rationale": why}
       │
       └─ NO: Escalate to user
           Return: {"action": "escalate", "summary": failure_history}
```

## Files to Create
- `.windsurf/scripts/memory_bank.py`
- `.windsurf/scripts/self_correction.py`
- `.windsurf/scripts/tests/test_memory_bank.py`
- `.windsurf/scripts/tests/test_self_correction.py`

## Files to Modify
- `.windsurf/scripts/windsurf_plan.py` - Add `retry` and `memory` subcommands

## Patterns to Follow
Reference: `.claude/scripts/memory_bank.py` for FIFO logic
Reference: `.claude/scripts/self_correction.py` for retry algorithm

## Acceptance Criteria
- [ ] `memory_bank.py` created with add/get/prune methods
- [ ] `self_correction.py` created with retry/rotate/escalate logic
- [ ] Memory bank FIFO works (max 10 entries)
- [ ] Retry budget respected per risk level
- [ ] Technique rotation selects based on failure patterns
- [ ] Escalation triggered when budget exhausted
- [ ] All unit tests pass
- [ ] `python3 .windsurf/scripts/windsurf_plan.py retry --help` works

## Testing Requirements

### Unit Tests
- [ ] Test file: `.windsurf/scripts/tests/test_memory_bank.py`
  - `test_add_entry_creates_file()` - First entry creates JSON file
  - `test_add_entry_appends()` - Subsequent entries append
  - `test_fifo_prunes_oldest()` - 11th entry removes 1st
  - `test_get_recent_returns_last_n()` - Get last N entries
  - `test_get_by_step()` - Filter by step ID

- [ ] Test file: `.windsurf/scripts/tests/test_self_correction.py`
  - `test_retry_within_budget()` - Returns retry action
  - `test_retry_exhausted_triggers_rotation()` - Returns rotate action
  - `test_rotation_selects_correct_technique()` - Pattern matching works
  - `test_all_retries_exhausted_escalates()` - Returns escalate action
  - `test_guidance_includes_lessons()` - Memory bank lessons in guidance
  - `test_budget_matches_risk_level()` - Low/medium/high/critical

## Verification Commands
```bash
# Run unit tests
cd .windsurf/scripts && python3 -m unittest discover tests -v -k "memory_bank\|self_correction"

# Test memory bank CLI
python3 .windsurf/scripts/windsurf_plan.py memory add --plan 001 \
  --step 1 --type test_failure --lesson "Mock the database"

python3 .windsurf/scripts/windsurf_plan.py memory list --plan 001

# Test retry CLI
python3 .windsurf/scripts/windsurf_plan.py retry --plan 001 --step 1 \
  --failure "test assertion failed"
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check memory bank file permissions
2. Verify JSON structure matches specification
3. Trace retry logic with print statements
4. Compare failure pattern matching with expected results

## Do NOT
- Exceed memory bank limit of 10 entries
- Skip pattern-based technique rotation
- Modify retry budgets from specification
- Create entries without timestamps
