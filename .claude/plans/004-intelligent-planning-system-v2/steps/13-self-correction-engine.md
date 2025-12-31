# Step 13: Self-Correction Engine

## Context
This step implements the full Reflexion-based self-correction engine that handles high-risk steps. When a step fails verification, this engine manages the retry loop with memory bank, technique rotation, and escalation.

## Goal
Create a self-correction engine that implements full Reflexion for high-risk steps, with memory bank, intelligent retries, and graceful escalation.

## Problem Type
`algorithm`

## Technique Selection
- **Planning**: ToT (explore correction strategies)
- **Implementation**: Reflexion (meta - use Reflexion to build Reflexion)
- **Verification**: Self-Consistency (validate correction behavior)

## Risk Level
**High** - Core self-correction logic affects all high-risk steps

## Prerequisites
- Steps 1-9 completed (technique execution tracks attempts)
- Step 10 completed (verification provides failure details)

## High-Level Steps
1. Design the self-correction interface
2. Implement memory bank storage
3. Create failure analysis logic
4. Implement technique rotation
5. Add escalation decision logic
6. Create recovery prompt generation
7. Integrate with plan-next
8. Write comprehensive tests

## Detailed Requirements

### Interface
```python
class SelfCorrectionEngine:
    def __init__(self, config_path: str = ".claude/technique-config.json"):
        """Initialize with configuration."""

    def should_retry(
        self,
        step: StepInfo,
        failure: FailureInfo
    ) -> RetryDecision:
        """
        Determine if and how to retry a failed step.

        Args:
            step: Step information with technique and risk
            failure: Details about the failure

        Returns:
            RetryDecision with action and guidance
        """

    def record_failure(
        self,
        step: StepInfo,
        failure: FailureInfo
    ) -> MemoryBankEntry:
        """
        Record a failure in the memory bank.

        Returns the lesson learned.
        """

    def get_recovery_prompt(
        self,
        step: StepInfo,
        memory_bank: MemoryBank,
        technique: str
    ) -> str:
        """
        Generate a recovery prompt incorporating lessons learned.
        """

    def rotate_technique(
        self,
        current_technique: str,
        failure_pattern: str
    ) -> str:
        """
        Select an alternative technique based on failure pattern.
        """

@dataclass
class FailureInfo:
    failure_type: str          # "test_failure", "verification_failed", "runtime_error"
    details: str               # Specific error message/output
    acceptance_criteria: dict  # Which criteria passed/failed
    attempt_number: int
    technique_used: str
    phase: str                 # "planning", "implementation", "verification"

@dataclass
class RetryDecision:
    action: str                # "retry_same", "retry_alternative", "escalate"
    technique: str             # Technique to use
    guidance: str              # Specific guidance for retry
    memory_context: str        # Lessons to include
    remaining_budget: int

@dataclass
class MemoryBankEntry:
    timestamp: str
    failure_summary: str
    root_cause: str
    lesson_learned: str
    technique_used: str
    applicable_to: list[str]   # Future steps this might apply to

class MemoryBank:
    entries: list[MemoryBankEntry]
    max_size: int = 10

    def add_entry(self, entry: MemoryBankEntry) -> None:
        """Add entry, maintaining max size."""

    def get_relevant_lessons(self, step: StepInfo) -> list[str]:
        """Get lessons applicable to current step."""

    def to_prompt_context(self) -> str:
        """Format for inclusion in prompts."""
```

### Self-Correction Algorithm

```python
def self_correction_loop(step: StepInfo, max_attempts: int = 5):
    """
    Full Reflexion self-correction loop.

    Phase 1: Attempt with primary technique
    Phase 2: If failed, add to memory, retry with lessons
    Phase 3: If failed again, rotate technique
    Phase 4: If exhausted, escalate

    Memory bank accumulates lessons across all attempts.
    """

    memory_bank = MemoryBank()
    attempt = 0
    current_technique = step.techniques["implementation"]

    while attempt < max_attempts:
        attempt += 1
        print(f"Attempt {attempt}/{max_attempts} using {current_technique}")

        # 1. Generate prompt with memory context
        prompt = generate_recovery_prompt(
            step=step,
            technique=current_technique,
            memory_bank=memory_bank
        )

        # 2. Execute step (this would be Claude execution)
        result = execute_step(prompt)

        # 3. Verify
        verification = verify_step(step, result)

        if verification.passed:
            return Success(
                attempt=attempt,
                technique=current_technique,
                lessons=memory_bank.entries
            )

        # 4. Record failure and learn
        failure = FailureInfo(
            failure_type=verification.failure_type,
            details=verification.details,
            attempt_number=attempt,
            technique_used=current_technique
        )

        lesson = analyze_failure(failure)
        memory_bank.add_entry(lesson)

        # 5. Decide next action
        if attempt < step.retry_config.max_same_technique:
            # Retry with same technique
            continue
        elif attempt < step.retry_config.max_total - 1:
            # Rotate technique
            current_technique = rotate_technique(
                current=current_technique,
                failure_pattern=lesson.root_cause
            )
        else:
            # Final attempt with best alternative
            current_technique = get_best_alternative(memory_bank)

    # Exhausted all attempts
    return Escalation(
        attempts=attempt,
        techniques_tried=[...],
        memory_bank=memory_bank,
        recommendation="User intervention required"
    )
```

### Failure Analysis

```python
def analyze_failure(failure: FailureInfo) -> MemoryBankEntry:
    """
    Analyze a failure to extract lessons learned.

    Uses pattern matching and heuristics to identify:
    - Root cause category
    - Applicable lesson
    - Future applicability
    """

    # Pattern matching for common failures
    if "nil" in failure.details or "optional" in failure.details:
        return MemoryBankEntry(
            failure_summary="Nil/optional handling issue",
            root_cause="Missing unwrapping or nil check",
            lesson_learned="Add guard/if-let for optional values",
            applicable_to=["data-access", "service-impl", "validation"]
        )

    if "async" in failure.details or "await" in failure.details:
        return MemoryBankEntry(
            failure_summary="Async/await issue",
            root_cause="Missing await or incorrect async context",
            lesson_learned="Ensure async functions are awaited properly",
            applicable_to=["api-integration", "data-access", "service-impl"]
        )

    if "test" in failure.details and "fail" in failure.details:
        return MemoryBankEntry(
            failure_summary="Test failure",
            root_cause="Implementation doesn't match test expectation",
            lesson_learned="Review test assertions, implementation should match spec",
            applicable_to=["unit-test", "integration-test", "tdd"]
        )

    # Generic fallback
    return MemoryBankEntry(
        failure_summary=failure.details[:100],
        root_cause="Unknown - requires manual analysis",
        lesson_learned="Review error details carefully",
        applicable_to=["general"]
    )
```

### Technique Rotation

```python
TECHNIQUE_ALTERNATIVES = {
    "tdd": ["reflexion", "self-refine"],
    "self-refine": ["reflexion", "tdd"],
    "reflexion": ["self-consistency", "tdd"],
    "chain-of-code": ["react", "least-to-most"],
    "tot": ["got", "ps-plus"],
    "ps-plus": ["tot", "react"],
    "react": ["ps-plus", "chain-of-code"],
    "self-consistency": ["reflexion", "self-refine"],
    "got": ["tot", "self-consistency"],
    "least-to-most": ["chain-of-code", "ps-plus"]
}

def rotate_technique(current: str, failure_pattern: str) -> str:
    """
    Select next technique based on failure pattern.

    Heuristics:
    - If pattern is "iteration not converging" → try Self-Consistency
    - If pattern is "missing edge cases" → try TDD
    - If pattern is "complex logic" → try ToT
    """
    alternatives = TECHNIQUE_ALTERNATIVES.get(current, ["ps-plus"])

    # Pattern-based selection
    if "not converging" in failure_pattern:
        return "self-consistency"
    if "edge case" in failure_pattern:
        return "tdd"
    if "complex" in failure_pattern:
        return "tot"

    # Default to first alternative
    return alternatives[0]
```

## Files to Create
- `.claude/scripts/self_correction.py`: Main self-correction engine
- `.claude/scripts/memory_bank.py`: Memory bank implementation
- `.claude/scripts/test_self_correction.py`: Unit tests

## Files to Modify
- `.claude/scripts/__init__.py`: Export new modules
- `.claude/commands/plan-next.md`: Integrate self-correction (already planned in step 9)

## Patterns to Follow
Reference: `.claude/commands/reflexion.md` for the Reflexion pattern

## Acceptance Criteria
- [ ] Memory bank stores and retrieves lessons
- [ ] Failure analysis produces useful lessons
- [ ] Technique rotation follows intelligent heuristics
- [ ] Recovery prompts incorporate lessons
- [ ] Escalation happens after budget exhaustion
- [ ] All unit tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/scripts/test_self_correction.py`
- [ ] Test cases:
  - `test_should_retry_within_budget()`
  - `test_should_escalate_after_budget()`
  - `test_memory_bank_stores_lessons()`
  - `test_memory_bank_retrieves_relevant()`
  - `test_failure_analysis_identifies_patterns()`
  - `test_technique_rotation_selects_alternative()`
  - `test_recovery_prompt_includes_lessons()`

### Integration Test
```python
def test_full_correction_loop():
    engine = SelfCorrectionEngine()
    step = create_test_step(risk_level="high")

    # Simulate failures
    for i in range(3):
        failure = simulate_failure(f"Failure {i}")
        decision = engine.should_retry(step, failure)

        if i < 2:
            assert decision.action == "retry_same"
        else:
            assert decision.action == "retry_alternative"
```

## Verification Commands
```bash
# Run self-correction tests
cd .claude/scripts && python3 -m pytest test_self_correction.py -v

# Test memory bank
python3 -c "
from self_correction import SelfCorrectionEngine, FailureInfo
from memory_bank import MemoryBank

engine = SelfCorrectionEngine()
bank = MemoryBank()

failure = FailureInfo(
    failure_type='test_failure',
    details='Optional unwrapping failed',
    attempt_number=1,
    technique_used='tdd',
    phase='implementation'
)

lesson = engine.record_failure(None, failure)
bank.add_entry(lesson)

print(f'Lesson: {lesson.lesson_learned}')
print(f'Applicable to: {lesson.applicable_to}')
"
```

## Documentation Updates
- [ ] Add self-correction section to CLAUDE.md
- [ ] Document memory bank usage

## Error Recovery
If self-correction engine fails:
1. Fall back to simple retry
2. Log the failure
3. Escalate immediately

## Do NOT
- Infinite retry loops
- Lose memory bank on restart
- Ignore escalation triggers
