# Step 5: Technique Selector Enhancement

## Problem Type
`refactor`

## Technique Selection
- **Planning**: tot - Multiple integration approaches to consider
- **Implementation**: tdd + self-refine - Test integration, iterate on design
- **Verification**: reflexion - Learn from any regressions

## Risk Level
**medium** - Modifying core technique selection logic

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
This step integrates the EffectivenessTracker (Step 3) into the existing TechniqueSelector. The selector will now query historical effectiveness data before making recommendations, while still respecting the minimum sample threshold.

## Goal
Enhance TechniqueSelector to:
1. Optionally use effectiveness data
2. Blend historical effectiveness with config defaults
3. Provide confidence scores with rationale
4. Fall back gracefully when data insufficient

## Prerequisites
- Step 3 (Effectiveness Tracker) completed

## High-Level Steps
1. Add EffectivenessTracker integration
2. Implement effectiveness-weighted selection
3. Add confidence scoring
4. Update rationale generation
5. Ensure backwards compatibility
6. Write integration tests

## Detailed Requirements

### Modified TechniqueSelector

```python
class TechniqueSelector:
    """
    Selects optimal prompt engineering techniques.

    Now enhanced with effectiveness-based selection that learns
    from historical outcomes while respecting minimum thresholds.
    """

    def __init__(
        self,
        config_path: str = ".claude/technique-config.json",
        effectiveness_tracker: Optional[EffectivenessTracker] = None
    ):
        """
        Initialize selector with optional effectiveness tracking.

        Args:
            config_path: Path to technique configuration
            effectiveness_tracker: Optional tracker for adaptive selection
        """
        self.config_path = Path(config_path)
        self._load_config()
        self.effectiveness_tracker = effectiveness_tracker

    def select_techniques(
        self,
        problem_type: str,
        phase: Phase,
        context: Optional[StepContext] = None
    ) -> TechniqueSelection:
        """
        Select techniques for a workflow phase.

        Now considers:
        1. Historical effectiveness (if sufficient data)
        2. Configuration defaults
        3. Context adjustments

        Returns TechniqueSelection with confidence score.
        """
        # 1. Get config default
        config_tech = self._get_configured_technique(problem_type, phase)

        # 2. Check effectiveness data (if tracker available)
        effectiveness_tech = None
        effectiveness_confidence = 0.0
        effectiveness_rationale = ""

        if self.effectiveness_tracker:
            available = self._get_available_techniques(phase)
            effectiveness_tech, effectiveness_confidence, effectiveness_rationale = (
                self.effectiveness_tracker.get_recommended_technique(
                    problem_type,
                    available,
                    phase.value
                )
            )

        # 3. Decide which to use
        if effectiveness_confidence > 0.7 and effectiveness_tech:
            # Trust effectiveness data
            primary = effectiveness_tech
            rationale = f"Effectiveness-based: {effectiveness_rationale}"
            confidence = effectiveness_confidence
        else:
            # Use config default
            primary = config_tech
            rationale = "Configuration default"
            confidence = 0.5

        # 4. Apply context adjustments (existing logic)
        if context:
            primary, secondary = self._adjust_for_context(
                primary, [], context, phase
            )
        else:
            secondary = []

        # 5. Build result
        return TechniqueSelection(
            primary=primary,
            secondary=secondary,
            prompt_template=self.get_technique_prompt(primary),
            rationale=self._generate_rationale(
                problem_type, phase, primary, secondary, context,
                effectiveness_rationale
            ),
            estimated_cost=self._estimate_cost(primary, secondary),
            retry_budget=self._get_retry_budget(
                self._get_risk_level(problem_type)
            ),
            confidence=confidence  # NEW FIELD
        )
```

### Updated TechniqueSelection Dataclass

```python
@dataclass
class TechniqueSelection:
    """Result of technique selection for a phase."""
    primary: str
    secondary: list[str]
    prompt_template: str
    rationale: str
    estimated_cost: str
    retry_budget: int
    confidence: float = 0.5  # NEW: 0.0-1.0 confidence in selection
```

### Selection Decision Logic

```python
def _decide_technique(
    self,
    config_tech: str,
    effectiveness_tech: Optional[str],
    effectiveness_confidence: float,
    problem_type: str,
    phase: Phase
) -> tuple[str, float, str]:
    """
    Decide which technique to use.

    Decision tree:
    1. If effectiveness confidence > 0.7 and data exists: use effectiveness
    2. If effectiveness confidence > 0.5 and matches config: boost confidence
    3. Otherwise: use config default with 0.5 confidence
    """
    if effectiveness_tech and effectiveness_confidence > 0.7:
        return (
            effectiveness_tech,
            effectiveness_confidence,
            f"Historical effectiveness: {effectiveness_confidence:.0%}"
        )

    if effectiveness_tech and effectiveness_confidence > 0.5:
        if effectiveness_tech == config_tech:
            # Config and effectiveness agree - boost confidence
            return (
                config_tech,
                min(0.8, effectiveness_confidence + 0.2),
                "Config default (confirmed by historical data)"
            )

    return (
        config_tech,
        0.5,
        "Configuration default (insufficient historical data)"
    )
```

### Backwards Compatibility

The enhancement must not break existing usage:

```python
# This must still work exactly as before:
selector = TechniqueSelector()
result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

# Enhanced usage (optional):
from scripts.feedback_store import FeedbackStore
from scripts.effectiveness_tracker import EffectivenessTracker

store = FeedbackStore()
tracker = EffectivenessTracker(store)
selector = TechniqueSelector(effectiveness_tracker=tracker)
result = selector.select_techniques("debug", Phase.IMPLEMENTATION)
```

## Files to Create
- None

## Files to Modify
- `.claude/scripts/technique_selector.py`: Add effectiveness integration

## Patterns to Follow
Reference: Existing `_adjust_for_context` method for pattern

## Acceptance Criteria
- [ ] Selector works without effectiveness tracker (backwards compatible)
- [ ] Selector uses effectiveness data when available and confident
- [ ] Confidence field added to TechniqueSelection
- [ ] Rationale explains selection source
- [ ] Existing tests still pass
- [ ] New integration tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: Update `.claude/tests/test_technique_selector.py`
- [ ] New test cases:
  - `test_select_without_tracker_uses_config()`
  - `test_select_with_tracker_no_data_uses_config()`
  - `test_select_with_tracker_low_confidence_uses_config()`
  - `test_select_with_tracker_high_confidence_uses_effectiveness()`
  - `test_select_confidence_boosted_when_agree()`
  - `test_confidence_field_present()`
  - `test_rationale_mentions_source()`
  - `test_backwards_compatibility()`

### Integration Tests
- [ ] Test file: `.claude/tests/test_selector_integration.py`
- [ ] Test cases:
  - `test_full_flow_record_and_select()`
  - `test_selection_changes_after_threshold()`

### What to Test
- All backwards compatibility scenarios
- Decision tree branches
- Confidence calculation
- Rationale generation

## Verification Commands
```bash
# Run existing tests (must pass)
cd .claude && python3 -m pytest tests/test_technique_selector.py -v

# Run new integration tests
cd .claude && python3 -m pytest tests/test_selector_integration.py -v

# Manual verification
python3 -c "
from scripts.technique_selector import TechniqueSelector, Phase

# Without tracker (backwards compatible)
selector = TechniqueSelector()
result = selector.select_techniques('debug', Phase.IMPLEMENTATION)
print('Without tracker:')
print(f'  Primary: {result.primary}')
print(f'  Confidence: {result.confidence}')
print(f'  Rationale: {result.rationale}')
"
```

## Documentation Updates
- [ ] Update technique_selector.py docstrings
- [ ] Add effectiveness integration to knowledge docs

## Error Recovery
If verification fails:
1. Check existing tests first (must not regress)
2. Verify optional parameter handling
3. Test decision tree logic

## Do NOT
- Break backwards compatibility
- Remove existing functionality
- Make effectiveness tracker required
