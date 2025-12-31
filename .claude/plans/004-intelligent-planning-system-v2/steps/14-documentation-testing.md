# Step 14: Documentation & Testing

## Context
With all components implemented, we need comprehensive documentation and integration testing to ensure the system works as designed.

## Goal
Create complete documentation for the intelligent planning system and write integration tests that verify end-to-end workflows.

## Problem Type
`documentation`

## Technique Selection
- **Planning**: PS+ (structured documentation planning)
- **Implementation**: Self-Refine (iterate on doc quality)
- **Verification**: GoT (review and aggregate)

## Risk Level
**Low** - Documentation doesn't affect runtime behavior

## Prerequisites
- Steps 1-13 completed (all components implemented)

## High-Level Steps
1. Update CLAUDE.md with new planning system
2. Create .claude/scripts/README.md
3. Write integration tests
4. Create quick reference guide
5. Add examples for each problem type
6. Final system verification

## Detailed Requirements

### CLAUDE.md Updates

Add new section after "Automated Planning System":

```markdown
## Intelligent Planning System v2

The planning system automatically selects optimal prompt engineering techniques based on problem type and workflow phase.

### Problem Type Taxonomy

| Category | Problem Types |
|----------|--------------|
| FOUNDATION | infrastructure, scaffolding, configuration |
| DATA | data-modeling, data-access, migration, state-mgmt |
| ARCHITECTURE | system-design, protocol-design, di-setup, service-impl, refactor |
| UI/UX | ui, component-lib, design-tokens, animation, gesture, accessibility, polish |
| TESTING | test-setup, unit-test, integration-test, snapshot-test, e2e-test, performance-test |
| LOGIC | algorithm, validation, api-integration, debug |
| DOCUMENTATION | documentation, changelog |

### Prompt Engineering Techniques

| Technique | Best For | Cost |
|-----------|----------|------|
| ToT (Tree of Thoughts) | Complex decisions, exploration | High |
| GoT (Graph of Thoughts) | Merging ideas, refinement | High |
| Reflexion | Learning from failures | Medium-High |
| Self-Consistency | Algorithm verification | High |
| Self-Refine | Iterative improvement | Medium |
| TDD | Implementation with tests | Medium |
| ReAct | Interactive problem-solving | Medium |
| PS+ (Plan-and-Solve Plus) | Structured planning | Low |
| Chain-of-Code | Mixed logic/semantic | Medium |
| Least-to-Most | Decomposition | Low |

### Commands (Updated)

| Command | Description | Techniques Used |
|---------|-------------|-----------------|
| `/plan-feature-initial` | Gather requirements | Auto-detects problem type |
| `/plan-feature` | Create full plan | Assigns techniques per step |
| `/plan-prompts` | Generate prompts | Embeds technique methodology |
| `/plan-next` | Execute next step | Phase-based technique execution |
| `/plan-verify` | Re-verify step | Technique-aware verification |
| `/plan-rollback` | Rollback step | Preserves memory bank |
| `/plan-feature-review` | Review plan | Validates technique selection |

### CLI Tool

```bash
# Classify a problem
python3 .claude/scripts/tangentle_plan.py classify "Fix the login bug"

# Create a plan with auto-classification
python3 .claude/scripts/tangentle_plan.py create "Add OAuth support"

# Check plan status
python3 .claude/scripts/tangentle_plan.py status 004
```

### Configuration

Technique mappings can be customized in `.claude/technique-config.json`:

```json
{
  "problemTypes": {
    "LOGIC": {
      "subtypes": {
        "debug": {
          "techniques": {
            "planning": "react",
            "implementation": "reflexion",
            "verification": "self-refine"
          }
        }
      }
    }
  }
}
```

### Self-Correction

High-risk steps use Reflexion for automatic self-correction:

| Risk Level | Same Technique Retries | Alternative Retries | Total |
|------------|------------------------|---------------------|-------|
| Low | 2 | 1 | 3 |
| Medium | 3 | 2 | 5 |
| High | 3 | 3 | 7 |
| Critical | 5 | 5 | 10 |

The memory bank preserves lessons across retries.
```

### Scripts README

Create `.claude/scripts/README.md`:

```markdown
# Tangentle Planning Scripts

Python scripts for the intelligent planning system.

## Setup

```bash
cd .claude/scripts
pip install -r requirements.txt  # if needed
```

## Scripts

| Script | Purpose |
|--------|---------|
| `problem_classifier.py` | Classifies problem descriptions |
| `technique_selector.py` | Selects techniques for phases |
| `risk_assessor.py` | Assesses step risk levels |
| `tangentle_plan.py` | CLI orchestrator |
| `self_correction.py` | Reflexion self-correction |
| `memory_bank.py` | Memory bank for lessons |
| `utils.py` | Shared utilities |

## Usage Examples

### Classify a Problem
```python
from problem_classifier import ProblemClassifier

classifier = ProblemClassifier()
result = classifier.classify("Fix the crash when saving tasks")

print(f"Type: {result.primary_type}")
print(f"Confidence: {result.confidence:.0%}")
```

### Select Techniques
```python
from technique_selector import TechniqueSelector, Phase

selector = TechniqueSelector()
selection = selector.select_techniques("debug", Phase.IMPLEMENTATION)

print(f"Technique: {selection.primary}")
print(f"Rationale: {selection.rationale}")
```

### Assess Risk
```python
from risk_assessor import RiskAssessor, StepInfo

assessor = RiskAssessor()
step = StepInfo(
    problem_type="migration",
    has_data_migration=True
)
assessment = assessor.assess_risk(step)

print(f"Risk: {assessment.level.value}")
print(f"Retry budget: {assessment.retry_config.max_total}")
```

## Testing

```bash
# Run all tests
python3 -m pytest . -v

# Run specific test file
python3 -m pytest test_problem_classifier.py -v
```

## Configuration

Scripts read from `.claude/technique-config.json`.

To override, set environment variable:
```bash
TECHNIQUE_CONFIG=./custom-config.json python3 tangentle_plan.py ...
```
```

### Integration Tests

Create `.claude/scripts/test_integration.py`:

```python
"""
Integration tests for the intelligent planning system.

These tests verify end-to-end workflows.
"""

import pytest
import json
import os
import tempfile
import shutil

from problem_classifier import ProblemClassifier
from technique_selector import TechniqueSelector, Phase
from risk_assessor import RiskAssessor, StepInfo
from self_correction import SelfCorrectionEngine


class TestEndToEndClassification:
    """Test the full classification → selection → assessment flow."""

    def test_debug_workflow(self):
        """Debug problems should get ReAct + Reflexion."""
        classifier = ProblemClassifier()
        selector = TechniqueSelector()
        assessor = RiskAssessor()

        # Classify
        result = classifier.classify("Fix the crash when user taps save")
        assert result.primary_type == "debug"
        assert result.confidence > 0.7

        # Select techniques
        impl_technique = selector.select_techniques("debug", Phase.IMPLEMENTATION)
        assert impl_technique.primary == "reflexion"

        # Assess risk
        step = StepInfo(problem_type="debug", files_to_modify=["ViewController.swift"])
        risk = assessor.assess_risk(step)
        assert risk.level.value in ["medium", "high"]

    def test_ui_workflow(self):
        """UI problems should get Self-Refine."""
        classifier = ProblemClassifier()
        selector = TechniqueSelector()

        result = classifier.classify("Add a new settings screen")
        assert result.primary_type == "ui"

        impl_technique = selector.select_techniques("ui", Phase.IMPLEMENTATION)
        assert impl_technique.primary == "self-refine"

    def test_algorithm_workflow(self):
        """Algorithm problems should get TDD."""
        classifier = ProblemClassifier()
        selector = TechniqueSelector()

        result = classifier.classify("Implement binary search for task lookup")
        assert result.primary_type == "algorithm"

        impl_technique = selector.select_techniques("algorithm", Phase.IMPLEMENTATION)
        assert impl_technique.primary == "tdd"


class TestSelfCorrectionWorkflow:
    """Test the self-correction engine."""

    def test_retry_within_budget(self):
        engine = SelfCorrectionEngine()
        step = StepInfo(
            problem_type="service-impl",
            risk_level="medium"
        )

        # Simulate first failure
        from self_correction import FailureInfo
        failure = FailureInfo(
            failure_type="test_failure",
            details="Assertion failed: expected 5, got 4",
            attempt_number=1,
            technique_used="tdd",
            phase="verification"
        )

        decision = engine.should_retry(step, failure)
        assert decision.action == "retry_same"
        assert decision.remaining_budget > 0

    def test_technique_rotation(self):
        engine = SelfCorrectionEngine()

        new_technique = engine.rotate_technique(
            current_technique="tdd",
            failure_pattern="test approach not working"
        )
        assert new_technique in ["reflexion", "self-refine"]

    def test_memory_bank_accumulation(self):
        from memory_bank import MemoryBank, MemoryBankEntry

        bank = MemoryBank()

        bank.add_entry(MemoryBankEntry(
            timestamp="2025-01-01T00:00:00Z",
            failure_summary="Nil handling",
            root_cause="Missing unwrap",
            lesson_learned="Add guard for optionals",
            technique_used="tdd",
            applicable_to=["data-access"]
        ))

        bank.add_entry(MemoryBankEntry(
            timestamp="2025-01-01T00:01:00Z",
            failure_summary="Async issue",
            root_cause="Missing await",
            lesson_learned="Ensure async is awaited",
            technique_used="tdd",
            applicable_to=["data-access", "api-integration"]
        ))

        step = StepInfo(problem_type="data-access")
        lessons = bank.get_relevant_lessons(step)
        assert len(lessons) == 2


class TestConfigurationIntegrity:
    """Test that configuration is valid and complete."""

    def test_all_problem_types_have_techniques(self):
        with open(".claude/technique-config.json") as f:
            config = json.load(f)

        for category, data in config["problemTypes"].items():
            for subtype, subdata in data.get("subtypes", {}).items():
                assert "techniques" in subdata, f"{category}/{subtype} missing techniques"
                techniques = subdata["techniques"]
                assert "planning" in techniques
                assert "implementation" in techniques
                assert "verification" in techniques

    def test_all_techniques_have_templates(self):
        with open(".claude/technique-config.json") as f:
            config = json.load(f)

        for technique_id, data in config["techniques"].items():
            template_path = data.get("promptTemplate")
            if template_path:
                assert os.path.exists(template_path), f"Template missing: {template_path}"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
```

## Files to Create
- `.claude/scripts/README.md`: Scripts documentation
- `.claude/scripts/test_integration.py`: Integration tests
- `.claude/scripts/requirements.txt`: Python dependencies

## Files to Modify
- `CLAUDE.md`: Add intelligent planning section

## Patterns to Follow
Reference existing documentation in CLAUDE.md for style

## Acceptance Criteria
- [ ] CLAUDE.md updated with complete planning system docs
- [ ] Scripts README is comprehensive
- [ ] Integration tests cover main workflows
- [ ] All tests pass
- [ ] Quick reference is useful

## Testing Requirements

### Integration Tests
- [ ] Test file: `.claude/scripts/test_integration.py`
- [ ] Coverage: Classification → Selection → Assessment → Correction

### Full System Test
```bash
# Run all Python tests
cd .claude/scripts && python3 -m pytest . -v

# Verify docs are updated
grep -q "Intelligent Planning System v2" CLAUDE.md
```

## Verification Commands
```bash
# Check CLAUDE.md updated
grep -c "Technique" CLAUDE.md | xargs test 5 -lt && echo "Technique docs added"

# Check scripts README
test -f .claude/scripts/README.md && echo "Scripts README exists"

# Run integration tests
cd .claude/scripts && python3 -m pytest test_integration.py -v
```

## Documentation Updates
- [ ] CLAUDE.md - comprehensive section
- [ ] Scripts README - usage examples
- [ ] Inline docstrings in all scripts

## Error Recovery
N/A - documentation step

## Do NOT
- Leave outdated documentation
- Skip examples
- Forget to test examples work
