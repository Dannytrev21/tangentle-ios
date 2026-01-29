# Step 4: Implementation Attempt Tracker

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Clear tracking requirements
- **Implementation**: tdd - Test tracking behavior first
- **Verification**: reflexion - Learn from edge cases

## Risk Level
**medium** - Tracks methods to avoid repetition during debugging

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
During implementation or debugging, the same methods might be tried repeatedly. This tracker maintains a log of what approaches have been attempted for each step, enabling the system to avoid repeating failed methods.

This is distinct from:
- **MemoryBank**: Per-step session memory (lessons within retries)
- **EffectivenessTracker**: Cross-plan aggregate statistics

This tracker provides **per-implementation detail** - what specific approaches were tried, what errors occurred, how long each took.

## Goal
Create an ImplementationTracker that:
1. Records each implementation attempt with details
2. Provides "what's been tried" for a step
3. Identifies methods to avoid (failed multiple times)
4. Calculates time spent on implementation

## Prerequisites
- Step 1 (Data Models) completed
- Step 2 (Persistence Layer) completed

## High-Level Steps
1. Implement ImplementationTracker class
2. Add attempt recording with full context
3. Add "methods to avoid" logic
4. Add time tracking
5. Write comprehensive tests

## Detailed Requirements

### ImplementationTracker Class

```python
class ImplementationTracker:
    """
    Tracks implementation attempts for steps.

    Unlike MemoryBank (session memory) or EffectivenessTracker (aggregate stats),
    this tracks the specific methods tried during implementation of a step,
    enabling the system to avoid repeating failed approaches.
    """

    def __init__(self, store: FeedbackStore):
        """Initialize with feedback store."""
        self.store = store
        self._active_attempts: dict[str, dict] = {}  # step_key -> current attempt

    def _step_key(self, plan_id: str, step_id: int) -> str:
        """Generate unique key for a step."""
        return f"{plan_id}_{step_id}"

    def start_attempt(
        self,
        plan_id: str,
        step_id: int,
        problem_type: str,
        technique: str,
        method_description: str
    ) -> int:
        """
        Start tracking a new implementation attempt.

        Args:
            plan_id: The plan being executed
            step_id: The step number
            problem_type: The problem type of the step
            technique: The technique being used
            method_description: Brief description of the approach

        Returns:
            attempt_number (1-indexed)
        """

    def end_attempt(
        self,
        plan_id: str,
        step_id: int,
        success: bool,
        error_summary: Optional[str] = None
    ) -> ImplementationAttempt:
        """
        End the current attempt and record the outcome.

        Args:
            plan_id: The plan being executed
            step_id: The step number
            success: Whether the attempt succeeded
            error_summary: If failed, brief error description

        Returns:
            The recorded ImplementationAttempt
        """

    def get_attempts(
        self,
        plan_id: str,
        step_id: int
    ) -> list[ImplementationAttempt]:
        """Get all attempts for a step."""

    def get_techniques_used(
        self,
        plan_id: str,
        step_id: int
    ) -> list[str]:
        """Get list of techniques already tried for this step."""

    def get_methods_used(
        self,
        plan_id: str,
        step_id: int
    ) -> list[str]:
        """Get list of method descriptions already tried."""

    def get_failed_techniques(
        self,
        plan_id: str,
        step_id: int
    ) -> list[str]:
        """Get techniques that have failed for this step."""

    def get_methods_to_avoid(
        self,
        plan_id: str,
        step_id: int
    ) -> list[tuple[str, str]]:
        """
        Get methods that should be avoided.

        Returns:
            List of (technique, method_description) that failed
        """

    def get_time_spent(
        self,
        plan_id: str,
        step_id: int
    ) -> int:
        """Get total seconds spent on implementation attempts."""

    def get_attempt_summary(
        self,
        plan_id: str,
        step_id: int
    ) -> str:
        """
        Generate a summary for inclusion in prompts.

        Returns formatted text like:
        "Previous attempts (3 total, 45 minutes):
        - Attempt 1: TDD - wrote failing tests first → Failed (test setup issue)
        - Attempt 2: TDD - fixed test setup → Failed (implementation bug)
        - Attempt 3: Self-Refine - iterative improvement → In Progress

        Methods to avoid:
        - TDD: test setup was problematic with async code"
        """

    def has_tried_technique(
        self,
        plan_id: str,
        step_id: int,
        technique: str
    ) -> bool:
        """Check if a technique has been tried for this step."""

    def suggest_next_technique(
        self,
        plan_id: str,
        step_id: int,
        available_techniques: list[str]
    ) -> Optional[str]:
        """
        Suggest next technique to try, avoiding failed ones.

        Returns None if all have been tried.
        """
```

### Integration with Prompts

The attempt summary should be injected into step prompts:

```markdown
## Previous Implementation Attempts

{tracker.get_attempt_summary(plan_id, step_id)}

**DO NOT repeat these failed approaches:**
{list of methods to avoid}
```

### Session State Management

Track active attempts in memory for timing:

```python
def start_attempt(self, plan_id, step_id, ...):
    key = self._step_key(plan_id, step_id)

    # Get or create step record
    step_record = self.store.get_step_attempts(plan_id, step_id)
    if not step_record:
        step_record = StepAttempts(
            plan_id=plan_id,
            step_id=step_id,
            problem_type=problem_type,
            attempts=[],
            total_attempts=0,
            final_success=False,
            techniques_used=[]
        )

    attempt_number = step_record.total_attempts + 1

    # Track active attempt (in memory for timing)
    self._active_attempts[key] = {
        "attempt_number": attempt_number,
        "technique": technique,
        "method": method_description,
        "started_at": datetime.now().isoformat()
    }

    return attempt_number
```

## Files to Create
- `.claude/scripts/implementation_tracker.py`: Tracker implementation

## Files to Modify
- None (integration in Step 8)

## Patterns to Follow
Reference: `.claude/scripts/self_correction.py` for similar tracking patterns

## Acceptance Criteria
- [ ] Attempts are recorded with full context
- [ ] "Methods to avoid" correctly identifies failed approaches
- [ ] Time tracking works across start/end
- [ ] Summary generation is clear and useful
- [ ] Suggestions exclude failed techniques
- [ ] All tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/tests/test_implementation_tracker.py`
- [ ] Test cases:
  - `test_start_attempt_returns_correct_number()`
  - `test_end_attempt_records_duration()`
  - `test_get_attempts_returns_all()`
  - `test_get_techniques_used_no_duplicates()`
  - `test_get_failed_techniques_only_failures()`
  - `test_get_methods_to_avoid_pairs_correctly()`
  - `test_get_time_spent_sums_correctly()`
  - `test_get_attempt_summary_formats_nicely()`
  - `test_has_tried_technique_checks_correctly()`
  - `test_suggest_next_technique_excludes_failed()`
  - `test_suggest_next_technique_returns_none_all_tried()`

### What to Test
- Multiple attempts on same step
- Mixed success/failure scenarios
- Timing calculations
- Summary formatting
- Suggestion logic edge cases

## Verification Commands
```bash
# Run tests
cd .claude && python3 -m pytest tests/test_implementation_tracker.py -v

# Manual verification
python3 -c "
import time
from scripts.feedback_store import FeedbackStore
from scripts.implementation_tracker import ImplementationTracker

store = FeedbackStore()
tracker = ImplementationTracker(store)

# Simulate implementation attempts
tracker.start_attempt('007', 3, 'debug', 'tdd', 'Write failing test first')
time.sleep(1)
tracker.end_attempt('007', 3, False, 'Test framework issue')

tracker.start_attempt('007', 3, 'debug', 'reflexion', 'Analyze error pattern')
time.sleep(1)
tracker.end_attempt('007', 3, True)

print('Summary:')
print(tracker.get_attempt_summary('007', 3))
print('Methods to avoid:', tracker.get_methods_to_avoid('007', 3))
"
```

## Documentation Updates
- [ ] Document attempt tracking in context.md template

## Error Recovery
If verification fails:
1. Check datetime parsing/formatting
2. Verify step_key generation
3. Test with mock timings

## Do NOT
- Modify existing self_correction.py
- Store excessive detail (keep methods brief)
- Skip the timing tracking
