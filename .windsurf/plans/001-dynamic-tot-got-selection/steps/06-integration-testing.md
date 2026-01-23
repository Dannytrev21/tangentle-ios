# Step 6: Integration Testing

## Problem Type
`integration-test`

## Technique Selection
- **Planning**: PS+ - Structured test plan
- **Implementation**: TDD - Write tests for integration scenarios
- **Verification**: Reflexion - Learn from any failures

## Risk Level
**Medium** - Testing complex interactions between components

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
All components have been implemented:
1. Python reasoning selector (Step 1)
2. Updated plan-feature-initial workflow (Step 2)
3. Updated plan-feature workflow (Step 3)
4. Windsurf rules (Step 4)
5. Knowledge base documentation (Step 5)

This step verifies everything works together correctly.

## Goal
Create and run integration tests that verify:
1. Python selector returns correct techniques for various inputs
2. Workflows correctly call selector and use results
3. Rules load and activate correctly
4. End-to-end flow produces correct plans

## Prerequisites
- Steps 1-5 completed

## High-Level Steps
1. Create integration test file
2. Test Python selector with all categories
3. Test characteristic overrides
4. Verify workflow character counts
5. Verify rules format and loading
6. Manual end-to-end testing
7. Document test results

## Detailed Requirements

### Integration Test File
Create `.windsurf/scripts/tests/test_reasoning_integration.py`:

```python
"""Integration tests for ToT/GoT reasoning selection."""
import unittest
import subprocess
import sys
from pathlib import Path

# Add scripts directory to path for imports
# Tests are in .windsurf/scripts/tests/, modules are in .windsurf/scripts/
SCRIPTS_DIR = Path(__file__).parent.parent
sys.path.insert(0, str(SCRIPTS_DIR))

from technique_selector import TechniqueSelector, select_reasoning_technique
from problem_classifier import ProblemClassifier


class TestReasoningIntegration(unittest.TestCase):
    """Integration tests for reasoning technique selection."""

    def setUp(self):
        self.classifier = ProblemClassifier()

    def test_architecture_category_selects_tot(self):
        """ARCHITECTURE category should default to ToT."""
        result = select_reasoning_technique("system-design", "ARCHITECTURE")
        self.assertEqual(result.technique, "tot")

    def test_testing_category_selects_got(self):
        """TESTING category should default to GoT."""
        result = select_reasoning_technique("unit-test", "TESTING")
        self.assertEqual(result.technique, "got")

    def test_documentation_category_selects_got(self):
        """DOCUMENTATION category should default to GoT."""
        result = select_reasoning_technique("documentation", "DOCUMENTATION")
        self.assertEqual(result.technique, "got")

    def test_synthesis_characteristic_overrides_to_got(self):
        """requires_synthesis should override to GoT."""
        result = select_reasoning_technique(
            "refactor", "ARCHITECTURE",
            {"requires_synthesis": True}
        )
        self.assertEqual(result.technique, "got")
        self.assertIn("requires_synthesis", result.characteristics_matched)

    def test_exploration_characteristic_overrides_to_tot(self):
        """exploration_needed should override to ToT."""
        result = select_reasoning_technique(
            "documentation", "DOCUMENTATION",
            {"exploration_needed": True}
        )
        self.assertEqual(result.technique, "tot")
        self.assertIn("exploration_needed", result.characteristics_matched)

    def test_cli_reasoning_command(self):
        """CLI reasoning command should work."""
        result = subprocess.run(
            ["python3", ".windsurf/scripts/windsurf_plan.py",
             "reasoning", "debug", "LOGIC"],
            capture_output=True, text=True, cwd=Path(__file__).parent.parent.parent.parent
        )
        self.assertEqual(result.returncode, 0)
        self.assertIn("tot", result.stdout.lower())

    def test_classify_to_reasoning_pipeline(self):
        """Full pipeline: classify → reasoning selection."""
        # Classify a problem
        classification = self.classifier.classify("Add REST API for users")

        # Select reasoning technique
        result = select_reasoning_technique(
            classification.primary_type,
            classification.primary_category
        )

        # Architecture problems should use ToT
        self.assertEqual(result.technique, "tot")

    def test_classify_review_task_uses_got(self):
        """Review tasks should use GoT."""
        classification = self.classifier.classify("Review code for issues")

        result = select_reasoning_technique(
            classification.primary_type,
            classification.primary_category,
            {"review_task": True}
        )

        self.assertEqual(result.technique, "got")


class TestWorkflowCharacterLimits(unittest.TestCase):
    """Test that workflows stay under character limits."""

    def test_plan_feature_initial_under_limit(self):
        """plan-feature-initial.md must be under 12K chars."""
        path = Path(".windsurf/workflows/plan-feature-initial.md")
        size = path.stat().st_size
        self.assertLess(size, 12000, f"plan-feature-initial.md is {size} chars (limit: 12000)")

    def test_plan_feature_under_limit(self):
        """plan-feature.md must be under 12K chars."""
        path = Path(".windsurf/workflows/plan-feature.md")
        size = path.stat().st_size
        self.assertLess(size, 12000, f"plan-feature.md is {size} chars (limit: 12000)")


class TestRulesFormat(unittest.TestCase):
    """Test that rules are properly formatted."""

    def setUp(self):
        self.rules_dir = Path(".windsurf/rules")

    def test_plan_conventions_exists(self):
        """plan-conventions.md should exist."""
        self.assertTrue((self.rules_dir / "plan-conventions.md").exists())

    def test_technique_selection_exists(self):
        """technique-selection.md should exist."""
        self.assertTrue((self.rules_dir / "technique-selection.md").exists())

    def test_no_staging_exists(self):
        """no-staging.md should exist."""
        self.assertTrue((self.rules_dir / "no-staging.md").exists())

    def test_each_rule_under_limit(self):
        """Each rule must be under 6K chars."""
        for rule in self.rules_dir.glob("*.md"):
            size = rule.stat().st_size
            self.assertLess(size, 6000, f"{rule.name} is {size} chars (limit: 6000)")

    def test_total_rules_under_limit(self):
        """Total rules must be under 12K chars."""
        total = sum(r.stat().st_size for r in self.rules_dir.glob("*.md"))
        self.assertLess(total, 12000, f"Total rules are {total} chars (limit: 12000)")

    def test_rules_have_frontmatter(self):
        """Each rule must have YAML frontmatter."""
        for rule in self.rules_dir.glob("*.md"):
            content = rule.read_text()
            self.assertTrue(content.startswith("---"), f"{rule.name} missing frontmatter")
            # Find closing ---
            lines = content.split("\n")
            self.assertIn("---", lines[1:10], f"{rule.name} missing frontmatter closing")


if __name__ == "__main__":
    unittest.main()
```

### Manual Test Scenarios

| Scenario | Input | Expected Technique | Verify |
|----------|-------|-------------------|--------|
| New API | "Add REST API" | ToT | Exploration needed |
| Code review | "Review PR" | GoT | Review task |
| Write tests | "Add unit tests" | GoT | TESTING category |
| Refactor | "Refactor auth" | ToT | ARCHITECTURE category |
| Docs update | "Update README" | GoT | DOCUMENTATION category |
| Data migration | "Migrate users" | ToT | DATA + exploration |

### Test Results Documentation
Create `.windsurf/plans/001-dynamic-tot-got-selection/reviews/integration-test-results.md`:

```markdown
# Integration Test Results

## Date: {date}

## Test Summary
| Category | Passed | Failed | Skipped |
|----------|--------|--------|---------|
| Reasoning Integration | X | 0 | 0 |
| Character Limits | X | 0 | 0 |
| Rules Format | X | 0 | 0 |

## Details
{test output}

## Manual Testing
| Scenario | Input | Expected | Actual | Status |
|----------|-------|----------|--------|--------|
| New API | "Add REST API" | ToT | ToT | PASS |
| ... | ... | ... | ... | ... |

## Issues Found
{any issues}

## Fixes Applied
{fixes made}
```

## Files to Create
- `.windsurf/scripts/tests/test_reasoning_integration.py`
- `.windsurf/plans/001-dynamic-tot-got-selection/reviews/integration-test-results.md`

## Files to Modify
- None

## Patterns to Follow
Reference: `.windsurf/scripts/tests/test_e2e.py` - Follow existing E2E test patterns

## Acceptance Criteria
- [ ] Integration test file created
- [ ] All category default tests pass
- [ ] All characteristic override tests pass
- [ ] CLI reasoning command test passes
- [ ] Classify → reasoning pipeline test passes
- [ ] Workflow character limit tests pass
- [ ] Rules format tests pass
- [ ] Manual test scenarios documented
- [ ] Test results file created

## Testing Requirements

### Unit Tests
Already covered in Step 1.

### Integration Tests
This step IS the integration tests.

### What to Test
- Python module integration (classifier → selector)
- CLI command functionality
- Workflow constraints (character limits)
- Rules format and structure
- End-to-end manual scenarios

## Verification Commands
```bash
# Run integration tests
python3 -m unittest .windsurf/scripts/tests/test_reasoning_integration.py -v

# Run all tests
python3 -m unittest discover -s .windsurf/scripts/tests -p 'test_*.py' -v

# Check character counts
wc -c .windsurf/workflows/plan-feature*.md

# Check rules
wc -c .windsurf/rules/*.md
```

## Documentation Updates
- [ ] Create test results document in reviews/

## Error Recovery
If verification fails:
1. Check specific test failure message
2. Verify all prerequisites completed (Steps 1-5)
3. Check file paths are correct
4. Verify imports work

## Do NOT
- Do NOT skip manual testing scenarios
- Do NOT mark complete without test results documentation
- Do NOT ignore character limit failures
