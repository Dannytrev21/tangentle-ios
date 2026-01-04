"""Unit tests for technique_selector.py."""

import unittest
from pathlib import Path
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from technique_selector import (
    TechniqueSelector,
    Phase,
    TechniqueSelection,
    StepContext,
    TECHNIQUES,
    DEFAULT_TECHNIQUES,
)


class TestTechniqueSelector(unittest.TestCase):
    """Tests for TechniqueSelector class."""

    def setUp(self):
        """Set up test fixtures."""
        self.selector = TechniqueSelector()

    def test_select_techniques_debug(self):
        """Test selecting techniques for debug type."""
        result = self.selector.select_techniques("debug", Phase.PLANNING)
        self.assertIsInstance(result, TechniqueSelection)
        self.assertIsInstance(result.primary, str)
        self.assertEqual(result.primary, "react")

    def test_select_techniques_migration(self):
        """Test selecting techniques for migration type."""
        result = self.selector.select_techniques("migration", Phase.IMPLEMENTATION)
        self.assertIsInstance(result, TechniqueSelection)
        # Migration should use TDD for implementation
        self.assertIn("tdd", [result.primary] + result.secondary)

    def test_select_techniques_all_phases(self):
        """Test selecting techniques for all phases."""
        for phase in Phase:
            result = self.selector.select_techniques("debug", phase)
            self.assertIsInstance(result, TechniqueSelection)
            self.assertIsNotNone(result.primary)

    def test_technique_selection_structure(self):
        """Test that selection has correct structure."""
        result = self.selector.select_techniques("ui", Phase.PLANNING)
        self.assertIsInstance(result.primary, str)
        self.assertIsInstance(result.secondary, list)
        self.assertIsInstance(result.prompt_template, str)
        self.assertIsInstance(result.rationale, str)
        self.assertIsInstance(result.estimated_cost, str)
        self.assertIsInstance(result.retry_budget, int)

    def test_cost_levels(self):
        """Test that cost is low, medium, or high."""
        result = self.selector.select_techniques("debug", Phase.PLANNING)
        self.assertIn(result.estimated_cost, ["low", "medium", "high"])

    def test_retry_budget_positive(self):
        """Test that retry budget is positive."""
        result = self.selector.select_techniques("debug", Phase.PLANNING)
        self.assertGreater(result.retry_budget, 0)

    def test_context_adjustment_failures(self):
        """Test context adjustment for previous failures."""
        context = StepContext(
            step_number=3,
            total_steps=10,
            complexity_score=0.5,
            previous_failures=2
        )
        result = self.selector.select_techniques(
            "debug", Phase.VERIFICATION, context
        )
        # Should prefer reflexion for verification after failures
        self.assertIn("reflexion", [result.primary] + result.secondary)

    def test_context_adjustment_high_complexity(self):
        """Test context adjustment for high complexity."""
        context = StepContext(
            step_number=1,
            total_steps=10,
            complexity_score=0.9
        )
        result = self.selector.select_techniques(
            "debug", Phase.PLANNING, context
        )
        # Should prefer ToT for complex planning
        self.assertEqual(result.primary, "tot")

    def test_get_technique_prompt(self):
        """Test getting technique prompt path."""
        path = self.selector.get_technique_prompt("tdd")
        self.assertIn("tdd", path)
        self.assertTrue(path.endswith(".md"))

    def test_get_technique_metadata(self):
        """Test getting technique metadata."""
        meta = self.selector.get_technique_metadata("tdd")
        self.assertIsNotNone(meta)
        self.assertEqual(meta.name, "Test-Driven Development")
        self.assertIn("implementation", meta.best_for)

    def test_get_technique_metadata_unknown(self):
        """Test getting metadata for unknown technique."""
        meta = self.selector.get_technique_metadata("nonexistent")
        self.assertIsNone(meta)

    def test_get_all_techniques(self):
        """Test getting all technique IDs."""
        techniques = self.selector.get_all_techniques()
        self.assertIsInstance(techniques, list)
        self.assertIn("tdd", techniques)
        self.assertIn("tot", techniques)
        self.assertIn("reflexion", techniques)

    def test_get_techniques_for_problem_type(self):
        """Test getting all techniques for a problem type."""
        techniques = self.selector.get_techniques_for_problem_type("debug")
        self.assertIn("planning", techniques)
        self.assertIn("implementation", techniques)
        self.assertIn("verification", techniques)


class TestTechniques(unittest.TestCase):
    """Tests for TECHNIQUES constant."""

    def test_10_techniques(self):
        """Test that there are 10 techniques."""
        self.assertEqual(len(TECHNIQUES), 10)

    def test_technique_has_required_fields(self):
        """Test that all techniques have required fields."""
        required_fields = ["name", "description", "costLevel", "bestFor"]
        for tech_id, tech_data in TECHNIQUES.items():
            for field in required_fields:
                self.assertIn(field, tech_data, f"{tech_id} missing {field}")

    def test_technique_cost_levels(self):
        """Test that cost levels are valid."""
        valid_costs = ["low", "medium", "medium-high", "high"]
        for tech_id, tech_data in TECHNIQUES.items():
            self.assertIn(
                tech_data["costLevel"],
                valid_costs,
                f"{tech_id} has invalid cost level"
            )


class TestDefaultTechniques(unittest.TestCase):
    """Tests for DEFAULT_TECHNIQUES mapping."""

    def test_all_phases_covered(self):
        """Test that all problem types have all phases."""
        for ptype, techniques in DEFAULT_TECHNIQUES.items():
            self.assertIn("planning", techniques, f"{ptype} missing planning")
            self.assertIn("implementation", techniques, f"{ptype} missing implementation")
            self.assertIn("verification", techniques, f"{ptype} missing verification")


if __name__ == "__main__":
    unittest.main()
