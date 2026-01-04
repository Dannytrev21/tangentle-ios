# Step 1: Python Reasoning Technique Selector

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: PS+ - Break down the function requirements systematically
- **Implementation**: TDD - Write tests first for selection logic
- **Verification**: Reflexion - Learn from test failures

## Risk Level
**Medium** - Adds new function to existing module; must not break existing functionality

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
The Windsurf planning system needs to dynamically choose between Tree of Thoughts (ToT) and Graph of Thoughts (GoT) based on problem characteristics. This step adds the core selection function that workflows will call.

## Goal
Add `select_reasoning_technique()` function to technique_selector.py that returns "tot" or "got" based on problem type, category, and characteristics.

## Prerequisites
- None (first step)

## High-Level Steps
1. Read existing technique_selector.py to understand current structure
2. Write unit tests for select_reasoning_technique()
3. Implement the function with category defaults and characteristic overrides
4. Add CLI command to windsurf_plan.py for workflow access
5. Run tests and verify

## Detailed Requirements

### Function Signature
```python
@dataclass
class ReasoningSelection:
    """Result of reasoning technique selection."""
    technique: str           # "tot" or "got"
    rationale: str           # Why this technique was selected
    characteristics_matched: list[str]  # Which characteristics influenced decision

def select_reasoning_technique(
    problem_type: str,
    category: str,
    characteristics: dict[str, bool] | None = None
) -> ReasoningSelection:
    """
    Select ToT or GoT based on problem characteristics.

    Args:
        problem_type: The classified problem type (e.g., "debug", "ui")
        category: The category (e.g., "ARCHITECTURE", "TESTING")
        characteristics: Optional dict of characteristic flags:
            - exploration_needed: Problem requires exploring multiple approaches
            - multiple_approaches: Multiple valid solutions exist
            - requires_synthesis: Need to merge/aggregate findings
            - review_task: This is a review/verification task
            - new_design: Making new design decisions

    Returns:
        ReasoningSelection with technique and rationale
    """
```

### Selection Logic
```python
# Category defaults
CATEGORY_DEFAULTS = {
    "FOUNDATION": "tot",
    "DATA": "tot",
    "ARCHITECTURE": "tot",
    "UI_UX": "tot",
    "TESTING": "got",
    "LOGIC": "tot",
    "DOCUMENTATION": "got",
    "META": "tot"
}

# Characteristic overrides (order matters - first match wins)
# If requires_synthesis → got
# If exploration_needed → tot
# If multiple_approaches → tot
# If review_task → got
# If new_design → tot
# Else → category default
```

### CLI Command
Add to windsurf_plan.py:
```bash
python3 windsurf_plan.py reasoning debug LOGIC
# Output: tot (ToT selected: Category LOGIC defaults to exploration)

python3 windsurf_plan.py reasoning unit-test TESTING --synthesis
# Output: got (GoT selected: requires_synthesis characteristic matched)
```

## Files to Create
- None (modifying existing)

## Files to Modify
- `.windsurf/scripts/technique_selector.py`: Add select_reasoning_technique()
- `.windsurf/scripts/windsurf_plan.py`: Add reasoning CLI command
- `.windsurf/scripts/tests/test_technique_selector.py`: Add tests

## Patterns to Follow
Reference: `.windsurf/scripts/technique_selector.py` - Follow existing TechniqueSelection dataclass pattern

## Acceptance Criteria
- [ ] `select_reasoning_technique()` function exists in technique_selector.py
- [ ] Function returns "tot" for ARCHITECTURE, DATA, LOGIC categories by default
- [ ] Function returns "got" for TESTING, DOCUMENTATION categories by default
- [ ] Characteristic `requires_synthesis=True` overrides to "got"
- [ ] Characteristic `exploration_needed=True` overrides to "tot"
- [ ] CLI command `reasoning` works and returns correct technique
- [ ] All existing tests still pass
- [ ] New tests cover all selection criteria

## Testing Requirements

### Unit Tests
- [ ] Test file: `.windsurf/scripts/tests/test_technique_selector.py`
- [ ] Test cases:
  - `test_select_reasoning_architecture_defaults_to_tot()`
  - `test_select_reasoning_testing_defaults_to_got()`
  - `test_select_reasoning_documentation_defaults_to_got()`
  - `test_select_reasoning_synthesis_overrides_to_got()`
  - `test_select_reasoning_exploration_overrides_to_tot()`
  - `test_select_reasoning_multiple_approaches_overrides_to_tot()`
  - `test_select_reasoning_review_task_overrides_to_got()`
  - `test_select_reasoning_unknown_category_defaults_to_tot()`
  - `test_select_reasoning_returns_rationale()`
  - `test_select_reasoning_returns_matched_characteristics()`

### What to Test
- Category default behavior for all 8 categories
- Characteristic override priority (synthesis > exploration)
- Edge cases: unknown category, no characteristics, conflicting characteristics
- Rationale generation includes category and characteristic info

## Verification Commands
```bash
# Run unit tests for technique selector
python3 -m unittest .windsurf/scripts/tests/test_technique_selector.py -v

# Test CLI command
python3 .windsurf/scripts/windsurf_plan.py reasoning debug LOGIC
python3 .windsurf/scripts/windsurf_plan.py reasoning unit-test TESTING
python3 .windsurf/scripts/windsurf_plan.py reasoning refactor ARCHITECTURE --synthesis
```

## Documentation Updates
- [ ] Update README.md CLI reference with new `reasoning` command

## Error Recovery
If verification fails:
1. Check test output for specific failure
2. Verify CATEGORY_DEFAULTS dict matches expected values
3. Check characteristic override priority order
4. Ensure dataclass fields match expected output

## Do NOT
- Do NOT modify existing select_techniques() function behavior
- Do NOT change the Phase enum or existing technique mappings
- Do NOT add external dependencies
