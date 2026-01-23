# Prompt: Step 6 - Integration Testing

## Mission
Create and run integration tests that verify all components work together correctly.

## Context
You are implementing step 6 of 6 in the "Dynamic ToT/GoT Selection & Windsurf Rules Integration" plan.

**Plan Summary**: Enable dynamic selection between Tree of Thoughts (ToT) and Graph of Thoughts (GoT) reasoning techniques based on problem characteristics.

**This Step**: Final verification that all components integrate correctly: Python selector, workflows, rules, and knowledge base.

**Dependencies**:
- Requires: Steps 1-5 all completed
- Enables: Plan completion

## Pre-Implementation Checklist
Before writing any tests, complete these steps:

### 1. Verify All Prerequisites Complete
```bash
# Step 1: Python selector exists
python3 .windsurf/scripts/windsurf_plan.py reasoning debug LOGIC

# Step 2: plan-feature-initial updated
grep -c "ToT\|GoT" .windsurf/workflows/plan-feature-initial.md

# Step 3: plan-feature updated
grep -c "ToT\|GoT" .windsurf/workflows/plan-feature.md

# Step 4: Rules created
ls .windsurf/rules/*.md

# Step 5: Knowledge base updated
ls .windsurf/knowledge/techniques/reasoning-selection.md
```

### 2. Read Required Files
Read these files to understand testing patterns:

| File | Why | Focus On |
|------|-----|----------|
| `.windsurf/scripts/tests/test_e2e.py` | Existing E2E test pattern | Test structure, imports |
| `.windsurf/scripts/tests/test_technique_selector.py` | Unit test pattern | Assertion patterns |

### 3. Understand Current State
```bash
cat .windsurf/plans/001-dynamic-tot-got-selection/context.md
cat .windsurf/plans/001-dynamic-tot-got-selection/progress.json | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'Steps completed: {sum(1 for s in d[\"steps\"] if s[\"status\"]==\"completed\")}/{d[\"totalSteps\"]}')"
```

## Specification

### Goal
Create integration tests that verify:
1. Python selector returns correct techniques for various inputs
2. CLI reasoning command works correctly
3. Classifier → selector pipeline works
4. Workflows stay under character limits
5. Rules exist and are properly formatted
6. End-to-end manual scenarios work

### Requirements
1. Create test file: `.windsurf/scripts/tests/test_reasoning_integration.py`
2. Include tests for all category defaults
3. Include tests for characteristic overrides
4. Include tests for CLI command
5. Include tests for character limits
6. Include tests for rules format
7. Document manual testing results

### Test Categories

#### TestReasoningIntegration
- All 8 category defaults
- Characteristic overrides (synthesis, exploration, etc.)
- CLI command functionality
- Classifier → selector pipeline

#### TestWorkflowCharacterLimits
- plan-feature-initial.md < 12K
- plan-feature.md < 12K

#### TestRulesFormat
- All 3 rules exist
- Each rule < 6K chars
- Total rules < 12K chars
- All have valid frontmatter

## Implementation Guide

### Step-by-Step Instructions

1. **Create test file**
   Create `.windsurf/scripts/tests/test_reasoning_integration.py`:

   ```python
   """Integration tests for ToT/GoT reasoning selection."""
   import unittest
   import subprocess
   import sys
   from pathlib import Path

   # Add scripts directory to path for imports
   SCRIPTS_DIR = Path(__file__).parent.parent
   sys.path.insert(0, str(SCRIPTS_DIR))

   from technique_selector import select_reasoning_technique
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

       def test_data_category_selects_tot(self):
           """DATA category should default to ToT."""
           result = select_reasoning_technique("data-modeling", "DATA")
           self.assertEqual(result.technique, "tot")

       def test_logic_category_selects_tot(self):
           """LOGIC category should default to ToT."""
           result = select_reasoning_technique("algorithm", "LOGIC")
           self.assertEqual(result.technique, "tot")

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
           # Get project root (4 levels up from test file)
           project_root = Path(__file__).parent.parent.parent.parent
           result = subprocess.run(
               ["python3", ".windsurf/scripts/windsurf_plan.py",
                "reasoning", "debug", "LOGIC"],
               capture_output=True, text=True, cwd=project_root
           )
           self.assertEqual(result.returncode, 0, f"CLI failed: {result.stderr}")
           self.assertIn("tot", result.stdout.lower())

       def test_classify_to_reasoning_pipeline(self):
           """Full pipeline: classify → reasoning selection."""
           classification = self.classifier.classify("Add REST API for users")
           result = select_reasoning_technique(
               classification.primary_type,
               classification.primary_category
           )
           # Architecture/API problems should use ToT
           self.assertEqual(result.technique, "tot")

       def test_classify_review_task_uses_got(self):
           """Review tasks should use GoT with review_task characteristic."""
           result = select_reasoning_technique(
               "refactor", "ARCHITECTURE",
               {"review_task": True}
           )
           self.assertEqual(result.technique, "got")


   class TestWorkflowCharacterLimits(unittest.TestCase):
       """Test that workflows stay under character limits."""

       def setUp(self):
           self.project_root = Path(__file__).parent.parent.parent.parent

       def test_plan_feature_initial_under_limit(self):
           """plan-feature-initial.md must be under 12K chars."""
           path = self.project_root / ".windsurf/workflows/plan-feature-initial.md"
           self.assertTrue(path.exists(), "plan-feature-initial.md not found")
           size = path.stat().st_size
           self.assertLess(size, 12000, f"plan-feature-initial.md is {size} chars (limit: 12000)")

       def test_plan_feature_under_limit(self):
           """plan-feature.md must be under 12K chars."""
           path = self.project_root / ".windsurf/workflows/plan-feature.md"
           self.assertTrue(path.exists(), "plan-feature.md not found")
           size = path.stat().st_size
           self.assertLess(size, 12000, f"plan-feature.md is {size} chars (limit: 12000)")


   class TestRulesFormat(unittest.TestCase):
       """Test that rules are properly formatted."""

       def setUp(self):
           self.project_root = Path(__file__).parent.parent.parent.parent
           self.rules_dir = self.project_root / ".windsurf/rules"

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
               lines = content.split("\n")
               # Find closing --- within first 10 lines
               found_closing = any(line == "---" for line in lines[1:10])
               self.assertTrue(found_closing, f"{rule.name} missing frontmatter closing")


   if __name__ == "__main__":
       unittest.main()
   ```

2. **Run the integration tests**
   ```bash
   python3 -m unittest .windsurf/scripts/tests/test_reasoning_integration.py -v
   ```

3. **Run all tests to ensure nothing broke**
   ```bash
   python3 -m unittest discover -s .windsurf/scripts/tests -p 'test_*.py' -v
   ```

4. **Perform manual testing**
   Test these scenarios:
   | Scenario | Input | Expected | Actual | Status |
   |----------|-------|----------|--------|--------|
   | New API | "Add REST API" | ToT | | |
   | Code review | "Review PR" + --review flag | GoT | | |
   | Write tests | "Add unit tests" | GoT | | |
   | Refactor | "Refactor auth" | ToT | | |
   | Docs update | "Update README" | GoT | | |

   ```bash
   # Manual test commands
   python3 .windsurf/scripts/windsurf_plan.py reasoning api-integration ARCHITECTURE
   python3 .windsurf/scripts/windsurf_plan.py reasoning refactor ARCHITECTURE --review
   python3 .windsurf/scripts/windsurf_plan.py reasoning unit-test TESTING
   python3 .windsurf/scripts/windsurf_plan.py reasoning refactor ARCHITECTURE
   python3 .windsurf/scripts/windsurf_plan.py reasoning documentation DOCUMENTATION
   ```

5. **Create test results document**
   Create `.windsurf/plans/001-dynamic-tot-got-selection/reviews/integration-test-results.md`

## Acceptance Criteria
All must pass before marking complete:

- [ ] **AC1**: Integration test file created
  - Verify: `ls .windsurf/scripts/tests/test_reasoning_integration.py`

- [ ] **AC2**: All category default tests pass
  - Verify: Run tests, check TestReasoningIntegration class

- [ ] **AC3**: All characteristic override tests pass
  - Verify: Run tests, check override tests

- [ ] **AC4**: CLI reasoning command test passes
  - Verify: `python3 -m unittest .windsurf/scripts/tests/test_reasoning_integration.TestReasoningIntegration.test_cli_reasoning_command -v`

- [ ] **AC5**: Classify → reasoning pipeline test passes
  - Verify: Run test_classify_to_reasoning_pipeline

- [ ] **AC6**: Workflow character limit tests pass
  - Verify: Run TestWorkflowCharacterLimits

- [ ] **AC7**: Rules format tests pass
  - Verify: Run TestRulesFormat

- [ ] **AC8**: Manual test scenarios documented
  - Verify: `ls .windsurf/plans/001-dynamic-tot-got-selection/reviews/integration-test-results.md`

- [ ] **AC9**: Test results file created
  - Verify: Check file has results

## Verification Protocol

### 1. Run Integration Tests
```bash
python3 -m unittest .windsurf/scripts/tests/test_reasoning_integration.py -v
```
Expected: All tests pass

### 2. Run All Tests
```bash
python3 -m unittest discover -s .windsurf/scripts/tests -p 'test_*.py' -v 2>&1 | tail -10
```
Expected: No failures

### 3. Check Character Counts
```bash
wc -c .windsurf/workflows/plan-feature*.md
wc -c .windsurf/rules/*.md
```
Expected: Workflows < 12K each, rules < 6K each

### 4. Manual Verification
```bash
# Run each manual test scenario
python3 .windsurf/scripts/windsurf_plan.py reasoning api-integration ARCHITECTURE
# Expected: tot

python3 .windsurf/scripts/windsurf_plan.py reasoning unit-test TESTING
# Expected: got
```

## Error Recovery

### If Tests Fail
1. Read specific failure message
2. Check if prerequisite step was completed
3. Verify import paths are correct
4. Fix issue and re-run

### If Character Limits Exceeded
1. Go back to Steps 2/3 and trim content
2. Move more content to rules
3. Re-run character limit tests

### If CLI Fails
1. Check Step 1 was completed
2. Verify reasoning command exists
3. Check command path

## Completion Protocol

After ALL acceptance criteria pass:

### 1. Update Progress
Update `.windsurf/plans/001-dynamic-tot-got-selection/progress.json`:
```json
{
  "steps[5]": {
    "status": "completed",
    "completedAt": "{ISO date}",
    "verificationPassed": true,
    "testsPassed": true,
    "notes": "All integration tests pass"
  },
  "currentStep": 6,
  "status": "completed"
}
```

### 2. Update Context
Add to `.windsurf/plans/001-dynamic-tot-got-selection/context.md`:
```markdown
## Step 6 Complete - {date}

### What Was Done
- Created test_reasoning_integration.py with 15+ tests
- All automated tests pass
- Manual scenarios verified
- Test results documented

### Files Created
- `.windsurf/scripts/tests/test_reasoning_integration.py`
- `.windsurf/plans/001-dynamic-tot-got-selection/reviews/integration-test-results.md`

### Test Summary
- Reasoning Integration: X passed
- Workflow Limits: 2 passed
- Rules Format: 6 passed
- Manual Scenarios: 5/5 passed

## PLAN COMPLETE
All 6 steps implemented and verified.
```

### 3. Create Test Results Document
```markdown
# Integration Test Results

## Date: {date}

## Test Summary
| Category | Passed | Failed | Skipped |
|----------|--------|--------|---------|
| Reasoning Integration | X | 0 | 0 |
| Character Limits | 2 | 0 | 0 |
| Rules Format | 6 | 0 | 0 |

## Details
{paste test output}

## Manual Testing
| Scenario | Input | Expected | Actual | Status |
|----------|-------|----------|--------|--------|
| New API | api-integration ARCHITECTURE | ToT | tot | PASS |
| Code review | refactor ARCHITECTURE --review | GoT | got | PASS |
| Write tests | unit-test TESTING | GoT | got | PASS |
| Refactor | refactor ARCHITECTURE | ToT | tot | PASS |
| Docs update | documentation DOCUMENTATION | GoT | got | PASS |

## Issues Found
{any issues}

## Fixes Applied
{fixes made}
```

## Do NOT
- Do NOT skip manual testing scenarios
- Do NOT mark complete without test results documentation
- Do NOT ignore character limit failures
- Do NOT leave failing tests

## Quality Checklist
Before marking complete, verify:
- [ ] All automated tests pass
- [ ] All manual scenarios verified
- [ ] Test results documented
- [ ] Character limits verified
- [ ] Rules format verified
- [ ] progress.json shows plan completed
- [ ] context.md has completion summary
