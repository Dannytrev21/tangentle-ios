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
    CATEGORY_DEFAULTS,
    CHARACTERISTIC_OVERRIDES,
    select_reasoning_technique,
    ReasoningSelection,
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


class TestReasoningSelection(unittest.TestCase):
    """Tests for select_reasoning_technique function."""

    # Category default tests (8 tests for 8 categories)
    def test_foundation_defaults_to_tot(self):
        """FOUNDATION category should default to ToT."""
        result = select_reasoning_technique("infrastructure", "FOUNDATION")
        self.assertEqual(result.technique, "tot")
        self.assertIn("FOUNDATION", result.rationale)

    def test_data_defaults_to_tot(self):
        """DATA category should default to ToT."""
        result = select_reasoning_technique("data-modeling", "DATA")
        self.assertEqual(result.technique, "tot")

    def test_architecture_defaults_to_tot(self):
        """ARCHITECTURE category should default to ToT."""
        result = select_reasoning_technique("system-design", "ARCHITECTURE")
        self.assertEqual(result.technique, "tot")

    def test_ui_ux_defaults_to_tot(self):
        """UI_UX category should default to ToT."""
        result = select_reasoning_technique("ui", "UI_UX")
        self.assertEqual(result.technique, "tot")

    def test_testing_defaults_to_got(self):
        """TESTING category should default to GoT."""
        result = select_reasoning_technique("unit-test", "TESTING")
        self.assertEqual(result.technique, "got")
        self.assertIn("synthesis", result.rationale.lower())

    def test_logic_defaults_to_tot(self):
        """LOGIC category should default to ToT."""
        result = select_reasoning_technique("algorithm", "LOGIC")
        self.assertEqual(result.technique, "tot")

    def test_documentation_defaults_to_got(self):
        """DOCUMENTATION category should default to GoT."""
        result = select_reasoning_technique("documentation", "DOCUMENTATION")
        self.assertEqual(result.technique, "got")

    def test_meta_defaults_to_tot(self):
        """META category should default to ToT."""
        result = select_reasoning_technique("ideation", "META")
        self.assertEqual(result.technique, "tot")

    # Characteristic override tests
    def test_requires_synthesis_overrides_to_got(self):
        """requires_synthesis characteristic should override to GoT."""
        result = select_reasoning_technique(
            "refactor", "ARCHITECTURE",
            {"requires_synthesis": True}
        )
        self.assertEqual(result.technique, "got")
        self.assertIn("requires_synthesis", result.characteristics_matched)

    def test_exploration_needed_overrides_to_tot(self):
        """exploration_needed characteristic should override to ToT."""
        result = select_reasoning_technique(
            "documentation", "DOCUMENTATION",
            {"exploration_needed": True}
        )
        self.assertEqual(result.technique, "tot")
        self.assertIn("exploration_needed", result.characteristics_matched)

    def test_multiple_approaches_overrides_to_tot(self):
        """multiple_approaches characteristic should override to ToT."""
        result = select_reasoning_technique(
            "unit-test", "TESTING",
            {"multiple_approaches": True}
        )
        self.assertEqual(result.technique, "tot")
        self.assertIn("multiple_approaches", result.characteristics_matched)

    def test_review_task_overrides_to_got(self):
        """review_task characteristic should override to GoT."""
        result = select_reasoning_technique(
            "refactor", "ARCHITECTURE",
            {"review_task": True}
        )
        self.assertEqual(result.technique, "got")
        self.assertIn("review_task", result.characteristics_matched)

    def test_new_design_overrides_to_tot(self):
        """new_design characteristic should override to ToT."""
        result = select_reasoning_technique(
            "documentation", "DOCUMENTATION",
            {"new_design": True}
        )
        self.assertEqual(result.technique, "tot")
        self.assertIn("new_design", result.characteristics_matched)

    # Priority tests
    def test_synthesis_takes_priority_over_exploration(self):
        """requires_synthesis should take priority over exploration_needed."""
        result = select_reasoning_technique(
            "refactor", "ARCHITECTURE",
            {"requires_synthesis": True, "exploration_needed": True}
        )
        self.assertEqual(result.technique, "got")  # synthesis wins
        self.assertIn("requires_synthesis", result.characteristics_matched)

    # Edge case tests
    def test_unknown_category_defaults_to_tot(self):
        """Unknown category should default to ToT."""
        result = select_reasoning_technique("test", "UNKNOWN_CATEGORY")
        self.assertEqual(result.technique, "tot")

    def test_no_characteristics_uses_category_default(self):
        """No characteristics should use category default."""
        result = select_reasoning_technique("unit-test", "TESTING", None)
        self.assertEqual(result.technique, "got")  # TESTING defaults to got
        self.assertEqual(result.characteristics_matched, [])

    def test_empty_characteristics_uses_category_default(self):
        """Empty characteristics dict should use category default."""
        result = select_reasoning_technique("unit-test", "TESTING", {})
        self.assertEqual(result.technique, "got")
        self.assertEqual(result.characteristics_matched, [])

    def test_false_characteristics_uses_category_default(self):
        """Characteristics set to False should not trigger override."""
        result = select_reasoning_technique(
            "unit-test", "TESTING",
            {"exploration_needed": False, "multiple_approaches": False}
        )
        self.assertEqual(result.technique, "got")  # TESTING default
        self.assertEqual(result.characteristics_matched, [])

    def test_lowercase_category_works(self):
        """Category should be case-insensitive."""
        result = select_reasoning_technique("debug", "logic")
        self.assertEqual(result.technique, "tot")

    def test_result_has_correct_type(self):
        """Result should be a ReasoningSelection dataclass."""
        result = select_reasoning_technique("debug", "LOGIC")
        self.assertIsInstance(result, ReasoningSelection)
        self.assertIsInstance(result.technique, str)
        self.assertIsInstance(result.rationale, str)
        self.assertIsInstance(result.characteristics_matched, list)


class TestCategoryDefaults(unittest.TestCase):
    """Tests for CATEGORY_DEFAULTS constant."""

    def test_8_categories(self):
        """Test that there are 8 category defaults."""
        self.assertEqual(len(CATEGORY_DEFAULTS), 8)

    def test_all_values_valid(self):
        """Test that all values are 'tot' or 'got'."""
        for category, technique in CATEGORY_DEFAULTS.items():
            self.assertIn(
                technique, ["tot", "got"],
                f"{category} has invalid technique: {technique}"
            )

    def test_testing_is_got(self):
        """TESTING should default to GoT."""
        self.assertEqual(CATEGORY_DEFAULTS["TESTING"], "got")

    def test_documentation_is_got(self):
        """DOCUMENTATION should default to GoT."""
        self.assertEqual(CATEGORY_DEFAULTS["DOCUMENTATION"], "got")


class TestCharacteristicOverrides(unittest.TestCase):
    """Tests for CHARACTERISTIC_OVERRIDES constant."""

    def test_5_overrides(self):
        """Test that there are 5 characteristic overrides."""
        self.assertEqual(len(CHARACTERISTIC_OVERRIDES), 5)

    def test_override_structure(self):
        """Test that overrides have correct structure (technique, priority)."""
        for char, (technique, priority) in CHARACTERISTIC_OVERRIDES.items():
            self.assertIn(technique, ["tot", "got"], f"{char} has invalid technique")
            self.assertIsInstance(priority, int, f"{char} has invalid priority")

    def test_requires_synthesis_highest_priority(self):
        """requires_synthesis should have priority 1 (highest)."""
        technique, priority = CHARACTERISTIC_OVERRIDES["requires_synthesis"]
        self.assertEqual(priority, 1)
        self.assertEqual(technique, "got")


if __name__ == "__main__":
    unittest.main()
