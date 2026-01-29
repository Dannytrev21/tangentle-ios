# Step 3: Effectiveness Tracker

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Clear calculation requirements
- **Implementation**: tdd - Test effectiveness formulas first
- **Verification**: reflexion - Learn from any edge case failures

## Risk Level
**medium** - Business logic that affects technique selection

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
This step implements the core logic that calculates technique effectiveness and provides recommendations. It uses the persistence layer from Step 2 to query historical data.

## Goal
Create an EffectivenessTracker that:
1. Calculates success rates per technique per problem type
2. Respects minimum sample threshold (10 samples)
3. Provides effectiveness-weighted technique recommendations
4. Handles cold start (no data) gracefully

## Prerequisites
- Step 1 (Data Models) completed
- Step 2 (Persistence Layer) completed

## High-Level Steps
1. Define effectiveness calculation formula
2. Implement EffectivenessTracker class
3. Add recommendation logic with thresholds
4. Handle cold start and insufficient data
5. Write comprehensive tests

## Detailed Requirements

### Effectiveness Formula

```
effectiveness = (success_rate * 0.7) + (speed_factor * 0.3)

where:
  success_rate = success / (success + failure)
  speed_factor = 1 / (average_attempts_to_success / baseline_attempts)
  baseline_attempts = 2 (expected attempts for a technique)
```

Interpretation:
- 70% weight on success rate
- 30% weight on how quickly it succeeds
- Higher score = better technique for this problem type

### EffectivenessTracker Class

```python
class EffectivenessTracker:
    """
    Tracks and calculates technique effectiveness.

    Uses historical data to determine which techniques work
    best for each problem type, with minimum sample thresholds
    to prevent overfitting.
    """

    MIN_SAMPLES = 10  # Minimum samples before using data
    BASELINE_ATTEMPTS = 2  # Expected attempts for neutral score

    def __init__(self, store: FeedbackStore):
        """Initialize with feedback store."""
        self.store = store

    def record_outcome(
        self,
        problem_type: str,
        technique: str,
        success: bool,
        attempts: int
    ) -> None:
        """
        Record the outcome of using a technique.

        Args:
            problem_type: The problem type being solved
            technique: The technique used
            success: Whether it ultimately succeeded
            attempts: Number of attempts before success/failure
        """

    def get_effectiveness(
        self,
        problem_type: str,
        technique: str
    ) -> Optional[float]:
        """
        Get effectiveness score for a technique on a problem type.

        Returns None if insufficient data (< MIN_SAMPLES).
        Returns float 0.0-1.0 if enough data.
        """

    def get_all_effectiveness(
        self,
        problem_type: str
    ) -> dict[str, float]:
        """
        Get effectiveness scores for all techniques on a problem type.

        Only includes techniques with sufficient data.
        """

    def get_recommended_technique(
        self,
        problem_type: str,
        available_techniques: list[str],
        phase: str  # "planning" | "implementation" | "verification"
    ) -> tuple[str, float, str]:
        """
        Get recommended technique based on effectiveness.

        Returns:
            (technique, confidence, rationale)

        If insufficient data, returns the default from config
        with confidence 0.5 and rationale explaining why.
        """

    def get_technique_ranking(
        self,
        problem_type: str
    ) -> list[tuple[str, float, int]]:
        """
        Get all techniques ranked by effectiveness.

        Returns:
            List of (technique, effectiveness, sample_count)
        """

    def has_sufficient_data(
        self,
        problem_type: str,
        technique: str
    ) -> bool:
        """Check if we have enough samples to trust effectiveness."""

    def get_sample_count(
        self,
        problem_type: str,
        technique: str
    ) -> int:
        """Get number of samples for technique on problem type."""
```

### Cold Start Handling

When data is insufficient:

```python
def get_recommended_technique(self, problem_type, available_techniques, phase):
    effectiveness_scores = self.get_all_effectiveness(problem_type)

    if not effectiveness_scores:
        # Cold start: use config defaults
        return (
            self._get_default_technique(problem_type, phase),
            0.5,  # Neutral confidence
            "Using default (insufficient historical data)"
        )

    # Filter to available techniques
    available_scores = {
        t: s for t, s in effectiveness_scores.items()
        if t in available_techniques
    }

    if not available_scores:
        return (
            available_techniques[0],
            0.5,
            "No effectiveness data for available techniques"
        )

    best = max(available_scores.items(), key=lambda x: x[1])
    return (
        best[0],
        min(0.95, best[1]),  # Cap confidence at 95%
        f"Historical effectiveness: {best[1]:.0%}"
    )
```

### Integration with Existing System

The tracker should be usable from `TechniqueSelector`:

```python
# In technique_selector.py (modified in Step 5)
def select_techniques(self, problem_type, phase, context=None):
    # Get default from config
    default = self._get_configured_technique(problem_type, phase)

    # Check effectiveness data
    if self.effectiveness_tracker:
        recommended, confidence, rationale = (
            self.effectiveness_tracker.get_recommended_technique(
                problem_type,
                self._get_available_techniques(phase),
                phase.value
            )
        )
        if confidence > 0.7:  # Trust if confident
            return self._build_selection(recommended, rationale)

    return self._build_selection(default, "Using configured default")
```

## Files to Create
- `.claude/scripts/effectiveness_tracker.py`: Tracker implementation

## Files to Modify
- None (integration in Step 5)

## Patterns to Follow
Reference: `.claude/scripts/risk_assessor.py` for scoring pattern

## Acceptance Criteria
- [ ] Effectiveness formula correctly calculates scores
- [ ] MIN_SAMPLES threshold is respected
- [ ] Cold start returns defaults with explanation
- [ ] Recommendations are sensible (not obviously wrong)
- [ ] All tests pass with good coverage

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/tests/test_effectiveness_tracker.py`
- [ ] Test cases:
  - `test_record_outcome_updates_stats()`
  - `test_effectiveness_calculation_success_only()`
  - `test_effectiveness_calculation_mixed()`
  - `test_effectiveness_calculation_failure_only()`
  - `test_get_effectiveness_returns_none_below_threshold()`
  - `test_get_effectiveness_returns_score_above_threshold()`
  - `test_recommended_technique_cold_start()`
  - `test_recommended_technique_with_data()`
  - `test_recommended_technique_filters_available()`
  - `test_technique_ranking_sorted_correctly()`
  - `test_speed_factor_impacts_score()`

### What to Test
- Formula edge cases (all success, all failure, mixed)
- Threshold boundary (9 samples vs 10 samples)
- Ranking with ties
- Empty available techniques list
- Unknown problem types

## Verification Commands
```bash
# Run tests
cd .claude && python3 -m pytest tests/test_effectiveness_tracker.py -v

# Manual verification
python3 -c "
from scripts.feedback_store import FeedbackStore
from scripts.effectiveness_tracker import EffectivenessTracker

store = FeedbackStore()
tracker = EffectivenessTracker(store)

# Simulate 10 outcomes
for i in range(10):
    tracker.record_outcome('debug', 'tdd', i % 3 != 0, 2)  # 67% success
    tracker.record_outcome('debug', 'reflexion', i % 4 != 0, 3)  # 75% success

print('TDD effectiveness:', tracker.get_effectiveness('debug', 'tdd'))
print('Reflexion effectiveness:', tracker.get_effectiveness('debug', 'reflexion'))
print('Recommended:', tracker.get_recommended_technique('debug', ['tdd', 'reflexion'], 'implementation'))
"
```

## Documentation Updates
- [ ] Add effectiveness formula to knowledge docs

## Error Recovery
If verification fails:
1. Check formula implementation for edge cases
2. Verify threshold logic
3. Test with mock store for isolation

## Do NOT
- Modify TechniqueSelector yet (that's Step 5)
- Add complex ML algorithms
- Ignore the minimum sample threshold
