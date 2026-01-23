#!/usr/bin/env python3
"""Integration tests for ToT/GoT reasoning selection.

This module tests that the reasoning technique selection system works correctly:
- Python selector returns correct techniques for various inputs
- CLI reasoning command works correctly
- Classifier -> selector pipeline works
- Workflows stay under character limits
- Rules exist and are properly formatted
"""

import subprocess
import sys
import unittest
from pathlib import Path

# Navigate to project root for imports
SCRIPT_DIR = Path(__file__).resolve().parent
SCRIPTS_DIR = SCRIPT_DIR.parent
WINDSURF_ROOT = SCRIPTS_DIR.parent
PROJECT_ROOT = WINDSURF_ROOT.parent

# Add scripts to path
sys.path.insert(0, str(SCRIPTS_DIR))

from technique_selector import select_reasoning_technique
from problem_classifier import ProblemClassifier


class TestReasoningIntegration(unittest.TestCase):
    """Integration tests for reasoning technique selection."""

    def setUp(self):
        self.classifier = ProblemClassifier()

    # Category default tests
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

    def test_foundation_category_selects_tot(self):
        """FOUNDATION category should default to ToT."""
        result = select_reasoning_technique("infrastructure", "FOUNDATION")
        self.assertEqual(result.technique, "tot")

    def test_ui_ux_category_selects_tot(self):
        """UI_UX category should default to ToT."""
        result = select_reasoning_technique("ui", "UI_UX")
        self.assertEqual(result.technique, "tot")

    def test_meta_category_selects_tot(self):
        """META category should default to ToT."""
        result = select_reasoning_technique("ideation", "META")
        self.assertEqual(result.technique, "tot")

    # Characteristic override tests
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

    def test_multiple_approaches_overrides_to_tot(self):
        """multiple_approaches should override to ToT."""
        result = select_reasoning_technique(
            "unit-test", "TESTING",
            {"multiple_approaches": True}
        )
        self.assertEqual(result.technique, "tot")
        self.assertIn("multiple_approaches", result.characteristics_matched)

    def test_review_task_overrides_to_got(self):
        """review_task should override to GoT."""
        result = select_reasoning_technique(
            "refactor", "ARCHITECTURE",
            {"review_task": True}
        )
        self.assertEqual(result.technique, "got")
        self.assertIn("review_task", result.characteristics_matched)

    def test_new_design_overrides_to_tot(self):
        """new_design should override to ToT."""
        result = select_reasoning_technique(
            "documentation", "DOCUMENTATION",
            {"new_design": True}
        )
        self.assertEqual(result.technique, "tot")
        self.assertIn("new_design", result.characteristics_matched)

    # CLI tests
    def test_cli_reasoning_command(self):
        """CLI reasoning command should work."""
        result = subprocess.run(
            ["python3", ".windsurf/scripts/windsurf_plan.py",
             "reasoning", "debug", "LOGIC"],
            capture_output=True, text=True, cwd=PROJECT_ROOT
        )
        self.assertEqual(result.returncode, 0, f"CLI failed: {result.stderr}")
        self.assertIn("tot", result.stdout.lower())

    def test_cli_reasoning_with_synthesis_flag(self):
        """CLI reasoning command with --synthesis flag should work."""
        result = subprocess.run(
            ["python3", ".windsurf/scripts/windsurf_plan.py",
             "reasoning", "refactor", "ARCHITECTURE", "--synthesis"],
            capture_output=True, text=True, cwd=PROJECT_ROOT
        )
        self.assertEqual(result.returncode, 0, f"CLI failed: {result.stderr}")
        self.assertIn("got", result.stdout.lower())

    # Pipeline tests
    def test_classify_to_reasoning_pipeline(self):
        """Full pipeline: classify -> reasoning selection."""
        classification = self.classifier.classify("Add REST API for users")
        result = select_reasoning_technique(
            classification.primary_type,
            classification.primary_category
        )
        # API problems should use ToT (exploration)
        self.assertEqual(result.technique, "tot")

    def test_classify_test_task_uses_got(self):
        """Classify test task should use GoT."""
        classification = self.classifier.classify("Write unit tests for auth")
        result = select_reasoning_technique(
            classification.primary_type,
            classification.primary_category
        )
        # Testing category defaults to GoT
        self.assertEqual(result.technique, "got")


class TestWorkflowCharacterLimits(unittest.TestCase):
    """Test that workflows stay under character limits."""

    def setUp(self):
        self.workflows_dir = WINDSURF_ROOT / "workflows"

    def test_plan_feature_initial_under_limit(self):
        """plan-feature-initial.md must be under 12K chars."""
        path = self.workflows_dir / "plan-feature-initial.md"
        self.assertTrue(path.exists(), "plan-feature-initial.md not found")
        size = path.stat().st_size
        self.assertLess(size, 12000, f"plan-feature-initial.md is {size} chars (limit: 12000)")

    def test_plan_feature_under_limit(self):
        """plan-feature.md must be under 12K chars."""
        path = self.workflows_dir / "plan-feature.md"
        self.assertTrue(path.exists(), "plan-feature.md not found")
        size = path.stat().st_size
        self.assertLess(size, 12000, f"plan-feature.md is {size} chars (limit: 12000)")

    def test_plan_feature_initial_has_tot_got_selection(self):
        """plan-feature-initial.md should have ToT/GoT selection."""
        path = self.workflows_dir / "plan-feature-initial.md"
        content = path.read_text()
        self.assertIn("windsurf_plan.py reasoning", content)
        self.assertIn("ToT", content)
        self.assertIn("GoT", content)

    def test_plan_feature_has_tot_got_selection(self):
        """plan-feature.md should have ToT/GoT selection."""
        path = self.workflows_dir / "plan-feature.md"
        content = path.read_text()
        self.assertIn("windsurf_plan.py reasoning", content)
        self.assertIn("ToT", content)
        self.assertIn("GoT", content)


class TestRulesFormat(unittest.TestCase):
    """Test that rules are properly formatted."""

    def setUp(self):
        self.rules_dir = WINDSURF_ROOT / "rules"

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

    def test_plan_conventions_has_always_on_trigger(self):
        """plan-conventions.md should have always_on trigger."""
        content = (self.rules_dir / "plan-conventions.md").read_text()
        self.assertIn("trigger: always_on", content)

    def test_technique_selection_has_model_decision_trigger(self):
        """technique-selection.md should have model_decision trigger."""
        content = (self.rules_dir / "technique-selection.md").read_text()
        self.assertIn("trigger: model_decision", content)

    def test_no_staging_has_glob_trigger(self):
        """no-staging.md should have glob trigger."""
        content = (self.rules_dir / "no-staging.md").read_text()
        self.assertIn("trigger: glob", content)


class TestKnowledgeBase(unittest.TestCase):
    """Test that knowledge base documentation exists."""

    def setUp(self):
        self.knowledge_dir = WINDSURF_ROOT / "knowledge/techniques"

    def test_reasoning_selection_exists(self):
        """reasoning-selection.md should exist."""
        self.assertTrue((self.knowledge_dir / "reasoning-selection.md").exists())

    def test_reasoning_selection_has_required_sections(self):
        """reasoning-selection.md should have all required sections."""
        content = (self.knowledge_dir / "reasoning-selection.md").read_text()
        required_sections = [
            "Selection Criteria",
            "Decision Flowchart",
            "Category Defaults",
            "Characteristic Overrides",
            "Examples",
            "Python Selector",
        ]
        for section in required_sections:
            self.assertIn(section, content, f"Missing section: {section}")


if __name__ == "__main__":
    unittest.main()
