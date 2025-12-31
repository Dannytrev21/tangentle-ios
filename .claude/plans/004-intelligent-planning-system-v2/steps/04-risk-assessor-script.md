# Step 4: Risk Assessor Script

## Context
Different steps carry different levels of risk. A data migration is riskier than adding documentation. The risk level determines the self-correction depth: high-risk steps get full Reflexion loops while low-risk steps get quick retries.

## Goal
Create a Python script that assesses the risk level of a step based on multiple factors, enabling appropriate self-correction strategies.

## Problem Type
`algorithm`

## Technique Selection
- **Planning**: ToT (explore multiple risk assessment approaches)
- **Implementation**: TDD (test-driven with risk scenarios)
- **Verification**: Self-Consistency (validate assessments with multiple runs)

## Risk Level
**Medium** - Affects retry behavior but not critical path

## Prerequisites
- Step 1 completed (technique-config.json for default risk levels)
- Step 2 completed (problem classifier for type-based risk)

## High-Level Steps
1. Design the risk assessment interface
2. Identify risk factors (file count, dependencies, etc.)
3. Implement scoring algorithm
4. Add step-context risk modifiers
5. Implement retry budget calculation
6. Create risk explanation generation
7. Write comprehensive tests

## Detailed Requirements

### Interface
```python
class RiskAssessor:
    def __init__(self, config_path: str = ".claude/technique-config.json"):
        """Initialize with technique configuration."""

    def assess_risk(
        self,
        step: StepInfo,
        context: PlanContext = None
    ) -> RiskAssessment:
        """
        Assess the risk level of a step.

        Args:
            step: Information about the step
            context: Optional plan-level context

        Returns:
            RiskAssessment with level, factors, and retry config
        """

    def get_retry_config(
        self,
        risk_level: RiskLevel
    ) -> RetryConfig:
        """Get retry configuration for a risk level."""

    def should_escalate(
        self,
        current_attempt: int,
        risk_level: RiskLevel,
        failure_pattern: str
    ) -> EscalationDecision:
        """Determine if escalation is needed."""

class RiskLevel(Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

@dataclass
class StepInfo:
    problem_type: str
    files_to_create: list[str]
    files_to_modify: list[str]
    dependencies: list[str]
    has_data_migration: bool
    has_external_api: bool
    affects_persistence: bool
    is_breaking_change: bool
    complexity_estimate: str  # low/medium/high

@dataclass
class RiskAssessment:
    level: RiskLevel
    score: float              # 0.0 to 1.0
    factors: list[RiskFactor]
    retry_config: RetryConfig
    explanation: str
    mitigations: list[str]

@dataclass
class RiskFactor:
    name: str
    weight: float
    present: bool
    contribution: float

@dataclass
class RetryConfig:
    max_same_technique: int
    max_alternative_technique: int
    max_total: int
    escalation_threshold: int
    techniques_rotation: list[str]

@dataclass
class EscalationDecision:
    should_escalate: bool
    reason: str
    recommended_action: str  # "retry", "switch_technique", "user_intervention"
```

### Risk Factors
```python
RISK_FACTORS = {
    # High-weight factors (0.2-0.3)
    "data_migration": {
        "weight": 0.3,
        "description": "Modifies persistent data structures"
    },
    "breaking_change": {
        "weight": 0.25,
        "description": "Changes that may break existing code"
    },
    "external_api": {
        "weight": 0.2,
        "description": "Depends on external services"
    },

    # Medium-weight factors (0.1-0.2)
    "many_file_modifications": {
        "weight": 0.15,
        "description": "Modifies more than 5 files",
        "threshold": 5
    },
    "affects_core_data": {
        "weight": 0.15,
        "description": "Modifies Core Data entities"
    },
    "complex_dependencies": {
        "weight": 0.1,
        "description": "Has more than 3 step dependencies",
        "threshold": 3
    },

    # Low-weight factors (0.05-0.1)
    "new_files_only": {
        "weight": -0.1,  # Reduces risk
        "description": "Only creates new files"
    },
    "documentation_only": {
        "weight": -0.2,  # Reduces risk
        "description": "Only documentation changes"
    },
    "has_tests": {
        "weight": -0.1,  # Reduces risk
        "description": "Step includes test creation"
    },
}
```

### Risk Assessment Algorithm
```
1. START WITH BASE RISK
   - Get default risk from problem type in config
   - Convert to numeric score (low=0.2, medium=0.5, high=0.8)

2. APPLY RISK FACTORS
   - For each factor:
     - Check if present in step
     - Add/subtract weighted contribution
   - Clamp to [0.0, 1.0]

3. CONTEXT ADJUSTMENT
   - If step is on critical path: +0.1
   - If step has completed prerequisites: -0.05
   - If similar step succeeded before: -0.1
   - If similar step failed before: +0.2

4. DETERMINE RISK LEVEL
   - score < 0.3: LOW
   - score < 0.5: MEDIUM
   - score < 0.7: HIGH
   - score >= 0.7: CRITICAL

5. CALCULATE RETRY CONFIG
   - LOW: 2 same, 1 alternative, 3 total
   - MEDIUM: 3 same, 2 alternative, 5 total
   - HIGH: 3 same, 3 alternative, 7 total (Reflexion)
   - CRITICAL: Full Reflexion loop, 10 total
```

## Files to Create
- `.claude/scripts/risk_assessor.py`: Main assessor implementation
- `.claude/scripts/test_risk_assessor.py`: Unit tests

## Files to Modify
- `.claude/scripts/__init__.py`: Export assessor

## Patterns to Follow
Reference: Existing step files for understanding risk factors

## Acceptance Criteria
- [ ] Risk assessment considers all relevant factors
- [ ] Retry configs match the specification
- [ ] Escalation logic works correctly
- [ ] Risk explanations are human-readable
- [ ] All unit tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/scripts/test_risk_assessor.py`
- [ ] Test cases:
  - `test_assess_low_risk_documentation()`
  - `test_assess_high_risk_migration()`
  - `test_assess_medium_risk_service()`
  - `test_retry_config_for_low_risk()`
  - `test_retry_config_for_high_risk()`
  - `test_should_escalate_after_max_retries()`
  - `test_risk_factors_applied_correctly()`

### Test Data
```python
TEST_CASES = [
    (StepInfo(problem_type="documentation", files_to_create=["README.md"]), RiskLevel.LOW),
    (StepInfo(problem_type="migration", has_data_migration=True), RiskLevel.HIGH),
    (StepInfo(problem_type="ui", files_to_modify=["View.swift"]), RiskLevel.MEDIUM),
]
```

## Verification Commands
```bash
# Run assessor tests
cd .claude/scripts && python3 -m pytest test_risk_assessor.py -v

# Test assessment interactively
python3 -c "
from risk_assessor import RiskAssessor, StepInfo
a = RiskAssessor()
step = StepInfo(problem_type='migration', has_data_migration=True, files_to_modify=['Model.swift'])
result = a.assess_risk(step)
print(f'Level: {result.level.value}')
print(f'Score: {result.score:.2f}')
print(f'Explanation: {result.explanation}')
"
```

## Documentation Updates
- [ ] Add risk assessment section to CLAUDE.md

## Error Recovery
If assessment seems wrong:
1. Check factor weights
2. Review base risk for problem type
3. Adjust thresholds

## Do NOT
- Assess all steps as high-risk (wastes resources)
- Ignore data migration risk factors
- Allow negative retry counts
