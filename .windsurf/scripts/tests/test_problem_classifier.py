"""Unit tests for problem_classifier.py."""

import unittest
from pathlib import Path
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from problem_classifier import ProblemClassifier, ClassificationResult, PROBLEM_TYPES


class TestProblemClassifier(unittest.TestCase):
    """Tests for ProblemClassifier class."""

    def setUp(self):
        """Set up test fixtures."""
        self.classifier = ProblemClassifier()

    def test_classify_debug(self):
        """Test classifying a debug problem."""
        result = self.classifier.classify("Fix the login crash")
        self.assertEqual(result.primary_type, "debug")
        self.assertEqual(result.primary_category, "LOGIC")

    def test_classify_ui(self):
        """Test classifying a UI problem."""
        result = self.classifier.classify("Create a new screen for user profile")
        self.assertIn(result.primary_type, ["ui", "new-feature"])

    def test_classify_migration(self):
        """Test classifying a migration problem."""
        result = self.classifier.classify("Migrate the database schema")
        self.assertEqual(result.primary_type, "migration")
        self.assertEqual(result.primary_category, "DATA")

    def test_classify_test(self):
        """Test classifying a testing problem."""
        result = self.classifier.classify("Write unit tests for the service")
        self.assertIn(result.primary_type, ["unit-test", "test-setup"])

    def test_classify_refactor(self):
        """Test classifying a refactoring problem."""
        result = self.classifier.classify("Refactor the authentication module")
        self.assertIn(result.primary_type, ["refactor", "service-impl"])

    def test_classify_empty_description(self):
        """Test classifying empty description (fallback)."""
        result = self.classifier.classify("")
        self.assertEqual(result.primary_type, "new-feature")
        self.assertLess(result.confidence, 0.5)

    def test_classification_result_structure(self):
        """Test that classification result has correct structure."""
        result = self.classifier.classify("Fix a bug")
        self.assertIsInstance(result, ClassificationResult)
        self.assertIsInstance(result.primary_type, str)
        self.assertIsInstance(result.primary_category, str)
        self.assertIsInstance(result.confidence, float)
        self.assertIsInstance(result.alternatives, list)
        self.assertIsInstance(result.reasoning, str)
        self.assertIsInstance(result.keywords_matched, list)

    def test_confidence_range(self):
        """Test that confidence is between 0 and 1."""
        result = self.classifier.classify("Fix the crash bug in login")
        self.assertGreaterEqual(result.confidence, 0.0)
        self.assertLessEqual(result.confidence, 1.0)

    def test_get_keywords(self):
        """Test getting keywords for a problem type."""
        keywords = self.classifier.get_keywords("debug")
        self.assertIsInstance(keywords, list)
        self.assertIn("bug", keywords)
        self.assertIn("fix", keywords)

    def test_get_all_types(self):
        """Test getting all problem types."""
        types = self.classifier.get_all_types()
        self.assertIsInstance(types, list)
        self.assertIn("debug", types)
        self.assertIn("ui", types)
        self.assertIn("migration", types)

    def test_get_type_info(self):
        """Test getting type info."""
        info = self.classifier.get_type_info("debug")
        self.assertIsNotNone(info)
        self.assertEqual(info["type"], "debug")
        self.assertEqual(info["category"], "LOGIC")
        self.assertIn("keywords", info)

    def test_get_type_info_unknown(self):
        """Test getting info for unknown type."""
        info = self.classifier.get_type_info("nonexistent")
        self.assertIsNone(info)


class TestProblemTypes(unittest.TestCase):
    """Tests for PROBLEM_TYPES constant."""

    def test_all_categories_present(self):
        """Test that all expected categories are present."""
        expected_categories = [
            "FOUNDATION", "DATA", "ARCHITECTURE", "UI_UX",
            "TESTING", "LOGIC", "DOCUMENTATION", "META"
        ]
        for category in expected_categories:
            self.assertIn(category, PROBLEM_TYPES)

    def test_subtypes_have_keywords(self):
        """Test that all subtypes have keywords."""
        for category, cat_data in PROBLEM_TYPES.items():
            for subtype, sub_data in cat_data.get("subtypes", {}).items():
                self.assertIn("keywords", sub_data, f"{subtype} missing keywords")
                self.assertIsInstance(sub_data["keywords"], list)
                self.assertGreater(len(sub_data["keywords"]), 0)

    def test_subtypes_have_risk_level(self):
        """Test that all subtypes have risk level."""
        for category, cat_data in PROBLEM_TYPES.items():
            for subtype, sub_data in cat_data.get("subtypes", {}).items():
                self.assertIn("riskLevel", sub_data, f"{subtype} missing riskLevel")
                self.assertIn(sub_data["riskLevel"], ["low", "medium", "high"])

    def test_33_problem_types(self):
        """Test that there are 33 problem types."""
        count = 0
        for cat_data in PROBLEM_TYPES.values():
            count += len(cat_data.get("subtypes", {}))
        self.assertEqual(count, 33)


if __name__ == "__main__":
    unittest.main()
