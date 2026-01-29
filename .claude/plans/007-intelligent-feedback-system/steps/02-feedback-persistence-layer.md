# Step 2: Feedback Persistence Layer

## Problem Type
`infrastructure`

## Technique Selection
- **Planning**: ps-plus - Clear CRUD requirements
- **Implementation**: tdd - Test file operations first
- **Verification**: self-refine - Iterate until robust

## Risk Level
**low** - File operations with atomic writes

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Context
Building on the data models from Step 1, this step creates the persistence layer that handles reading/writing feedback data to JSON files. This is the foundation for all feedback operations.

## Goal
Create a robust persistence layer that:
1. Handles atomic file writes (no corruption)
2. Creates files on first access
3. Validates data against schemas
4. Provides clean CRUD operations

## Prerequisites
- Step 1 (Feedback Data Models) completed

## High-Level Steps
1. Create FeedbackStore class with file management
2. Implement atomic write with temp file + rename
3. Add lazy initialization (create on first write)
4. Add schema validation on load
5. Write comprehensive tests

## Detailed Requirements

### FeedbackStore Class

```python
class FeedbackStore:
    """
    Manages persistent storage of feedback data.

    Handles:
    - Atomic writes (temp file + rename)
    - Lazy file creation
    - Schema validation
    - CRUD operations for each data type
    """

    PLANNING_DATA_DIR = ".claude/planning-data"

    FILES = {
        "effectiveness": "technique-effectiveness.json",
        "classification": "classification-history.json",
        "attempts": "implementation-attempts.json",
        "metrics": "plan-metrics.json"
    }

    def __init__(self, base_path: str = "."):
        """Initialize with project root path."""

    def ensure_directory(self) -> None:
        """Create planning-data directory if needed."""

    def _atomic_write(self, file_path: Path, data: dict) -> None:
        """Write data atomically using temp file + rename."""

    def _load_file(self, file_type: str) -> dict:
        """Load a file, returning empty structure if not exists."""

    def _save_file(self, file_type: str, data: dict) -> None:
        """Save data to file atomically."""

    # Effectiveness operations
    def get_effectiveness_data(self) -> dict:
        """Get all technique effectiveness data."""

    def update_technique_stats(
        self,
        problem_type: str,
        technique: str,
        success: bool,
        attempts: int
    ) -> None:
        """Update stats for a technique usage."""

    # Classification operations
    def get_classification_history(self) -> list:
        """Get all classification entries."""

    def add_classification(self, entry: ClassificationEntry) -> None:
        """Add a new classification entry."""

    def record_correction(
        self,
        description_hash: str,
        original: str,
        corrected: str
    ) -> None:
        """Record a user correction for learning."""

    # Attempt operations
    def get_step_attempts(self, plan_id: str, step_id: int) -> Optional[StepAttempts]:
        """Get attempts for a specific step."""

    def record_attempt(
        self,
        plan_id: str,
        step_id: int,
        attempt: ImplementationAttempt
    ) -> None:
        """Record an implementation attempt."""

    # Metrics operations
    def get_metrics(self) -> dict:
        """Get aggregate plan metrics."""

    def update_metrics(self, **kwargs) -> None:
        """Update plan metrics."""
```

### Empty File Templates

When a file doesn't exist, return these defaults:

```python
EMPTY_EFFECTIVENESS = {
    "version": "1.0.0",
    "lastUpdated": None,
    "byProblemType": {}
}

EMPTY_CLASSIFICATION = {
    "version": "1.0.0",
    "entries": [],
    "corrections": {}
}

EMPTY_ATTEMPTS = {
    "version": "1.0.0",
    "byStepId": {}
}

EMPTY_METRICS = {
    "version": "1.0.0",
    "totalPlans": 0,
    "totalSteps": 0,
    "completedPlans": 0,
    "completedSteps": 0,
    "averageStepsPerPlan": 0.0,
    "averageAttemptsPerStep": 0.0,
    "byCategory": {},
    "lastUpdated": None
}
```

### Atomic Write Implementation

```python
def _atomic_write(self, file_path: Path, data: dict) -> None:
    """
    Write data atomically to prevent corruption.

    1. Write to temp file
    2. Sync to disk
    3. Rename over target (atomic on POSIX)
    """
    temp_path = file_path.with_suffix('.tmp')

    with open(temp_path, 'w') as f:
        json.dump(data, f, indent=2)
        f.flush()
        os.fsync(f.fileno())

    # Atomic rename
    temp_path.rename(file_path)
```

## Files to Create
- `.claude/scripts/feedback_store.py`: Persistence layer
- `.claude/planning-data/.gitkeep`: Placeholder for directory

## Files to Modify
- None

## Patterns to Follow
Reference: `.claude/scripts/utils.py` for file operation patterns

## Acceptance Criteria
- [ ] FeedbackStore creates directory on first access
- [ ] Atomic writes prevent file corruption
- [ ] Empty files return correct defaults
- [ ] All CRUD operations work correctly
- [ ] Concurrent access doesn't corrupt data
- [ ] All tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/tests/test_feedback_store.py`
- [ ] Test cases:
  - `test_ensure_directory_creates_if_missing()`
  - `test_atomic_write_creates_file()`
  - `test_atomic_write_survives_interrupt()` (mock)
  - `test_load_missing_file_returns_default()`
  - `test_update_technique_stats_creates_structure()`
  - `test_update_technique_stats_updates_existing()`
  - `test_add_classification_appends()`
  - `test_record_correction_updates_count()`
  - `test_record_attempt_creates_step_entry()`
  - `test_record_attempt_appends_to_existing()`
  - `test_concurrent_writes_dont_corrupt()` (threading)

### What to Test
- File creation scenarios
- Update existing vs. create new
- Concurrent access safety
- Edge cases: empty data, missing keys
- Error handling: permission denied, disk full (mocked)

## Verification Commands
```bash
# Run tests
cd .claude && python3 -m pytest tests/test_feedback_store.py -v

# Manual verification - create and read
python3 -c "
from scripts.feedback_store import FeedbackStore
store = FeedbackStore()
store.update_technique_stats('debug', 'tdd', True, 2)
print(store.get_effectiveness_data())
"
```

## Documentation Updates
- [ ] Add docstrings to all public methods

## Error Recovery
If verification fails:
1. Check file permissions in planning-data/
2. Verify JSON serialization of all data types
3. Test atomic write with simulated interrupts

## Do NOT
- Use SQLite or other databases
- Add complex caching (keep it simple)
- Skip atomic writes (data integrity is critical)
