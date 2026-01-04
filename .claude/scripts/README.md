# Tangentle Planning Scripts

Python scripts for the intelligent planning system. These scripts power the automated problem classification, technique selection, risk assessment, and self-correction features.

## Setup

No external dependencies required. All scripts use Python 3 standard library with the `unittest` module for testing.

```bash
cd .claude/scripts

# Run all tests
python3 -m unittest discover -v

# Or run a specific test file
python3 -m unittest test_problem_classifier -v
```

## Scripts Overview

| Script | Purpose | Lines |
|--------|---------|-------|
| `problem_classifier.py` | Classifies problem descriptions into 33 types | ~200 |
| `technique_selector.py` | Selects techniques for planning/implementation/verification phases | ~250 |
| `risk_assessor.py` | Assesses step risk and calculates retry budgets | ~300 |
| `tangentle_plan.py` | CLI orchestrator for all planning operations | ~350 |
| `memory_bank.py` | Persistent storage for lessons learned | ~120 |
| `self_correction.py` | Reflexion-based retry and technique rotation | ~500 |
| `template_parser.py` | Parses technique markdown files into structured data | ~200 |
| `prompt_composer.py` | Composes technique-embedded prompts for steps | ~300 |
| `utils.py` | Shared utilities (plan finding, formatting) | ~150 |

## Usage Examples

### Classify a Problem

```python
from problem_classifier import ProblemClassifier

classifier = ProblemClassifier()
result = classifier.classify("Fix the crash when saving tasks")

print(f"Type: {result.primary_type}")       # "debug"
print(f"Category: {result.category}")       # "LOGIC"
print(f"Confidence: {result.confidence:.0%}")  # "85%"
print(f"Alternatives: {result.alternatives}")  # ["validation", "data-access"]
```

### Select Techniques for a Step

```python
from technique_selector import TechniqueSelector, Phase

selector = TechniqueSelector()

# Basic selection
impl = selector.select_techniques("debug", Phase.IMPLEMENTATION)
print(f"Primary: {impl.primary}")      # "reflexion"
print(f"Secondary: {impl.secondary}")  # ["self-refine"]
print(f"Rationale: {impl.rationale}")  # "Debug benefits from..."

# Context-aware selection (adjusts based on step context)
from technique_selector import StepContext

context = StepContext(
    step_number=1,
    total_steps=10,
    has_failures=True,
    complexity_score=0.8,
    files_affected=5
)
adjusted = selector.select_with_context("algorithm", Phase.IMPLEMENTATION, context)
# High complexity + failures → switches to Reflexion
```

### Assess Risk

```python
from risk_assessor import RiskAssessor, StepInfo, RiskLevel

assessor = RiskAssessor()

step = StepInfo(
    problem_type="migration",
    has_data_migration=True,
    affects_persistence=True,
    files_to_modify=["Database.swift", "Migration.swift"]
)
assessment = assessor.assess_risk(step)

print(f"Level: {assessment.level.value}")          # "high"
print(f"Score: {assessment.score:.2f}")            # 0.75
print(f"Retry budget: {assessment.retry_config.max_total}")  # 7
print(f"Factors: {assessment.factors}")            # ["data_migration", "affects_persistence"]
print(f"Explanation: {assessment.explanation}")
print(f"Mitigations: {assessment.mitigations}")
```

### Use Self-Correction

```python
from self_correction import SelfCorrectionEngine, FailureInfo
from risk_assessor import StepInfo

engine = SelfCorrectionEngine()

step = StepInfo(problem_type="service-impl", risk_level="medium")

failure = FailureInfo(
    failure_type="test_failure",
    details="XCTAssertEqual failed: expected 5, got 4",
    acceptance_criteria={"AC1": True, "AC2": False, "AC3": True},
    attempt_number=1,
    technique_used="tdd",
    phase="verification"
)

# Record failure and get retry decision
entry = engine.record_failure(step, failure)
decision = engine.should_retry(step, failure)

if decision.should_retry:
    print(f"Action: {decision.action}")           # "retry_same" or "retry_alternative"
    print(f"Technique: {decision.technique}")     # "tdd" or rotated alternative
    print(f"Guidance: {decision.guidance}")       # Specific retry instructions
    print(f"Remaining: {decision.remaining_budget}")  # 4
else:
    print("Escalate to user - budget exhausted")

# Access memory bank lessons
bank = engine.get_memory_bank(step.id)
lessons = bank.get_relevant_lessons("service-impl")
print(f"Lessons: {lessons}")
```

### Parse Technique Templates

```python
from template_parser import load_all_templates, get_template_section

templates = load_all_templates()
print(f"Loaded: {list(templates.keys())}")  # All 10 techniques

# Get specific section from a template
tdd = templates["tdd"]
print(f"Planning section:\n{tdd.planning_section[:200]}...")
print(f"Implementation section:\n{tdd.implementation_section[:200]}...")

# Or use the helper
planning = get_template_section("tdd", "planning")
```

### Compose Prompts

```python
from prompt_composer import compose_prompt, StepInfo, PlanInfo
from template_parser import load_all_templates

templates = load_all_templates()

step = StepInfo(
    name="Create User Repository",
    objective="Implement CRUD operations for users",
    acceptance_criteria=["Create user works", "Fetch user returns data"],
    planning_techniques=["ps-plus"],
    implementation_techniques=["tdd", "self-refine"],
    verification_techniques=["tdd"],
    requirements="Must follow repository pattern"
)

plan = PlanInfo(
    name="User Management",
    plan_id="005",
    overall_type="data-access"
)

prompt = compose_prompt(step, plan, templates, "See requirements above")
print(f"Prompt length: {len(prompt)} chars")
# Full prompt with embedded methodology sections
```

## CLI Tool

The `tangentle_plan.py` script provides a command-line interface:

```bash
# Classify a problem
python3 tangentle_plan.py classify "Fix the login crash"
# Output: debug (LOGIC) - 85% confidence
#         Techniques: react → reflexion → self-refine

# Show techniques for a problem type
python3 tangentle_plan.py techniques algorithm
# Output: Planning: self-consistency
#         Implementation: tdd
#         Verification: reflexion

# Assess risk for a step type
python3 tangentle_plan.py risk migration
# Output: Risk: HIGH (0.65)
#         Retry budget: 7 attempts
#         Factors: data_migration

# Check plan status
python3 tangentle_plan.py status 004
# Output: Plan 004: Intelligent Planning System v2
#         Progress: ████████████████░░░░ 14/15 (93%)
#         Current: Step 14 - Documentation & Testing

# List all plans
python3 tangentle_plan.py list
# Output: 001 - iOS Foundation Setup [pending]
#         004 - Intelligent Planning System v2 [in_progress] ← current
```

## Testing

Each script has a corresponding test file with comprehensive coverage:

| Test File | Tests | Focus Areas |
|-----------|-------|-------------|
| `test_problem_classifier.py` | 30 | Classification, confidence, keywords |
| `test_technique_selector.py` | 36 | Phase selection, context adjustment |
| `test_risk_assessor.py` | 40 | Risk factors, retry config, escalation |
| `test_tangentle_plan.py` | 36 | CLI commands, orchestration |
| `test_template_parser.py` | 22 | Section extraction, legacy parsing |
| `test_prompt_composer.py` | 26 | Prompt composition, placeholders |
| `test_self_correction.py` | 37 | Memory bank, technique rotation |
| `test_technique_config.py` | 10 | Configuration validation |
| `test_integration.py` | 10+ | End-to-end workflows |

Run all tests:
```bash
python3 -m unittest discover -v
```

## Configuration

Scripts read from `.claude/technique-config.json` by default.

To override:
```bash
TECHNIQUE_CONFIG=./custom-config.json python3 tangentle_plan.py classify "..."
```

Or in Python:
```python
classifier = ProblemClassifier(config_path="./custom-config.json")
```

## Architecture

```
User Request
    ↓
ProblemClassifier.classify()
    ↓ (type, confidence)
TechniqueSelector.select_techniques()
    ↓ (techniques per phase)
RiskAssessor.assess_risk()
    ↓ (risk level, retry budget)
PromptComposer.compose_prompt()
    ↓ (technique-embedded prompt)
[Execution]
    ↓
[If failure]
    ↓
SelfCorrectionEngine.should_retry()
    ├─→ retry_same (same technique, new guidance)
    ├─→ retry_alternative (rotate technique)
    └─→ escalate (user intervention)
```

## Key Design Decisions

1. **No external dependencies**: All scripts use Python standard library only
2. **JSON configuration**: Technique mappings in `.claude/technique-config.json`
3. **Dataclass-heavy**: Structured data using Python dataclasses
4. **Pattern-based rotation**: Technique alternatives based on failure patterns
5. **FIFO memory bank**: Max 10 entries, oldest evicted first
6. **Phase-based composition**: Different techniques for plan/implement/verify
