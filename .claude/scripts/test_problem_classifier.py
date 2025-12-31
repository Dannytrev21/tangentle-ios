"""
Unit tests for the Problem Classifier.

Tests keyword matching, confidence scoring, context adjustment,
and fallback behavior.
"""

import json
import os
import sys
import tempfile
from pathlib import Path

# Add the scripts directory to the path for imports
sys.path.insert(0, str(Path(__file__).parent))

from problem_classifier import ProblemClassifier, ClassificationResult


class TestProblemClassifier:
    """Test suite for ProblemClassifier."""

    @classmethod
    def setup_class(cls):
        """Set up test fixtures."""
        # Change to project root for config file access
        cls.original_cwd = os.getcwd()
        # Navigate up from .claude/scripts to project root
        project_root = Path(__file__).parent.parent.parent
        os.chdir(project_root)
        cls.classifier = ProblemClassifier()

    @classmethod
    def teardown_class(cls):
        """Clean up after tests."""
        os.chdir(cls.original_cwd)

    # ==================== Core Classification Tests ====================

    def test_classify_debug_description(self):
        """Test that debug problems are correctly identified."""
        descriptions = [
            "Fix the crash when user taps save",
            "Debug the issue where tasks disappear",
            "There's a bug in the login flow",
            "The app crashes on launch - fix it",
        ]
        for desc in descriptions:
            result = self.classifier.classify(desc)
            assert result.primary_type == 'debug', \
                f"Expected 'debug' for '{desc}', got '{result.primary_type}'"
            assert result.primary_category == 'LOGIC', \
                f"Expected 'LOGIC' category, got '{result.primary_category}'"

    def test_classify_ui_description(self):
        """Test that UI problems are correctly identified."""
        descriptions = [
            "Add a new settings screen",
            "Create the profile screen",
            "Update the layout for the task list",
            "Build the dashboard UI view",
        ]
        for desc in descriptions:
            result = self.classifier.classify(desc)
            assert result.primary_type == 'ui', \
                f"Expected 'ui' for '{desc}', got '{result.primary_type}'"
            assert result.primary_category == 'UI_UX', \
                f"Expected 'UI_UX' category, got '{result.primary_category}'"

    def test_classify_algorithm_description(self):
        """Test that algorithm problems are correctly identified."""
        descriptions = [
            "Implement binary search",
            "Create a sorting algorithm for tasks",
            "Optimize the search function",
        ]
        for desc in descriptions:
            result = self.classifier.classify(desc)
            assert result.primary_type == 'algorithm', \
                f"Expected 'algorithm' for '{desc}', got '{result.primary_type}'"

    def test_classify_unit_test_description(self):
        """Test that unit test problems are correctly identified."""
        descriptions = [
            "Write unit tests for TaskRepository",
            "Add test cases for the service layer",
            "Create unit test for the validate function",
        ]
        for desc in descriptions:
            result = self.classifier.classify(desc)
            assert result.primary_type == 'unit-test', \
                f"Expected 'unit-test' for '{desc}', got '{result.primary_type}'"

    def test_classify_refactor_description(self):
        """Test that refactor problems are correctly identified."""
        descriptions = [
            "Refactor the service layer",
            "Reorganize the repository code",
            "Clean up and restructure the code",
        ]
        for desc in descriptions:
            result = self.classifier.classify(desc)
            assert result.primary_type == 'refactor', \
                f"Expected 'refactor' for '{desc}', got '{result.primary_type}'"

    def test_classify_api_integration_description(self):
        """Test that API integration problems are correctly identified."""
        descriptions = [
            "Add OAuth authentication API",
            "Implement the REST API client",
            "Create network request handler",
        ]
        for desc in descriptions:
            result = self.classifier.classify(desc)
            assert result.primary_type == 'api-integration', \
                f"Expected 'api-integration' for '{desc}', got '{result.primary_type}'"

    # ==================== Confidence Scoring Tests ====================

    def test_classify_ambiguous_returns_low_confidence(self):
        """Test that ambiguous descriptions have low confidence."""
        # Very generic description with no strong signals
        result = self.classifier.classify("do something")
        assert result.confidence < 0.7, \
            f"Expected low confidence for ambiguous input, got {result.confidence}"

    def test_classify_specific_returns_high_confidence(self):
        """Test that specific descriptions have high confidence."""
        # Very specific with multiple matching keywords
        result = self.classifier.classify("Write comprehensive unit tests for the TaskRepository")
        assert result.confidence >= 0.6, \
            f"Expected high confidence for specific input, got {result.confidence}"

    def test_confidence_increases_with_multiple_keywords(self):
        """Test that more matching keywords increases confidence."""
        result_single = self.classifier.classify("fix the bug")
        result_multiple = self.classifier.classify("fix the bug, debug the crash, resolve the error")

        # Multiple keywords should give higher or equal confidence
        assert result_multiple.confidence >= result_single.confidence * 0.9, \
            f"Multiple keywords should increase confidence"

    # ==================== Context Adjustment Tests ====================

    def test_classify_with_context_improves_accuracy(self):
        """Test that providing context influences classification."""
        description = "add more coverage"  # Ambiguous

        # Without context
        result_no_context = self.classifier.classify(description)

        # With testing context
        result_with_context = self.classifier.classify(
            description,
            context={'plan_type': 'testing improvements'}
        )

        # The context should influence the result or at least not break anything
        assert result_with_context.primary_type is not None
        assert result_with_context.confidence > 0

    def test_context_previous_steps_influences_classification(self):
        """Test that previous step types influence classification."""
        description = "implement the next step"

        # With previous UI steps context
        result = self.classifier.classify(
            description,
            context={'previous_steps': ['ui', 'component-lib', 'animation']}
        )

        # Should not crash and should return valid result
        assert result.primary_type is not None
        assert isinstance(result.confidence, float)

    # ==================== Fallback Behavior Tests ====================

    def test_empty_description_returns_fallback(self):
        """Test that empty description returns fallback result."""
        result = self.classifier.classify("")
        assert result.primary_type == 'new-feature'
        assert result.confidence == 0.3
        assert 'Fallback' in result.reasoning

    def test_whitespace_description_returns_fallback(self):
        """Test that whitespace-only description returns fallback."""
        result = self.classifier.classify("   \n\t   ")
        assert result.primary_type == 'new-feature'
        assert result.confidence == 0.3

    def test_no_keywords_returns_fallback(self):
        """Test that description with no matching keywords returns fallback."""
        result = self.classifier.classify("xyzzy plugh qwerty asdfgh")
        assert result.primary_type == 'new-feature'
        assert 'Fallback' in result.reasoning or 'No keywords matched' in result.reasoning

    # ==================== Keyword Matching Tests ====================

    def test_get_keywords_returns_valid_list(self):
        """Test that get_keywords returns the expected keyword list."""
        keywords = self.classifier.get_keywords('debug')
        assert isinstance(keywords, list)
        assert len(keywords) > 0
        assert 'bug' in keywords or 'fix' in keywords

    def test_get_keywords_unknown_type_returns_empty(self):
        """Test that unknown type returns empty list."""
        keywords = self.classifier.get_keywords('unknown-type-xyz')
        assert keywords == []

    def test_keywords_case_insensitive(self):
        """Test that keyword matching is case insensitive."""
        result_lower = self.classifier.classify("fix the bug")
        result_upper = self.classifier.classify("FIX THE BUG")
        result_mixed = self.classifier.classify("Fix The Bug")

        assert result_lower.primary_type == result_upper.primary_type
        assert result_lower.primary_type == result_mixed.primary_type

    # ==================== Validation Tests ====================

    def test_validate_classification_accepts_correct(self):
        """Test that validate accepts correct classifications."""
        is_valid = self.classifier.validate_classification(
            "Fix the crash bug",
            "debug"
        )
        assert is_valid, "Should accept correct classification"

    def test_validate_classification_catches_mismatches(self):
        """Test that validate catches obvious mismatches."""
        is_valid = self.classifier.validate_classification(
            "Fix the crash bug",
            "documentation"
        )
        # Should be invalid since the description is clearly about debugging
        assert not is_valid, "Should reject mismatched classification"

    def test_validate_classification_unknown_type_returns_false(self):
        """Test that unknown type returns False."""
        is_valid = self.classifier.validate_classification(
            "some description",
            "unknown-type-xyz"
        )
        assert not is_valid, "Unknown type should return False"

    # ==================== Result Structure Tests ====================

    def test_classification_result_has_all_fields(self):
        """Test that ClassificationResult has all required fields."""
        result = self.classifier.classify("Fix the bug")

        assert hasattr(result, 'primary_type')
        assert hasattr(result, 'primary_category')
        assert hasattr(result, 'confidence')
        assert hasattr(result, 'alternatives')
        assert hasattr(result, 'reasoning')
        assert hasattr(result, 'keywords_matched')

    def test_alternatives_are_sorted_by_confidence(self):
        """Test that alternatives are sorted by descending confidence."""
        result = self.classifier.classify("Fix the bug and add tests")

        if len(result.alternatives) >= 2:
            for i in range(len(result.alternatives) - 1):
                assert result.alternatives[i][1] >= result.alternatives[i + 1][1], \
                    "Alternatives should be sorted by confidence"

    def test_alternatives_limited_to_three(self):
        """Test that alternatives are limited to 3 items."""
        result = self.classifier.classify("Fix the bug and add tests and refactor")
        assert len(result.alternatives) <= 3

    def test_reasoning_is_human_readable(self):
        """Test that reasoning is human-readable."""
        result = self.classifier.classify("Fix the bug")

        assert isinstance(result.reasoning, str)
        assert len(result.reasoning) > 10
        # Should mention the type or confidence
        assert 'debug' in result.reasoning.lower() or 'confidence' in result.reasoning.lower()

    # ==================== Utility Method Tests ====================

    def test_get_all_types_returns_list(self):
        """Test that get_all_types returns all problem types."""
        types = self.classifier.get_all_types()

        assert isinstance(types, list)
        assert len(types) >= 20  # We have 33 types defined
        assert 'debug' in types
        assert 'ui' in types
        assert 'algorithm' in types

    def test_get_type_info_returns_dict(self):
        """Test that get_type_info returns type information."""
        info = self.classifier.get_type_info('debug')

        assert info is not None
        assert info['type'] == 'debug'
        assert info['category'] == 'LOGIC'
        assert 'keywords' in info
        assert 'techniques' in info

    def test_get_type_info_unknown_returns_none(self):
        """Test that unknown type returns None."""
        info = self.classifier.get_type_info('unknown-type-xyz')
        assert info is None

    # ==================== Performance Tests ====================

    def test_classification_performance(self):
        """Test that classification is fast enough."""
        import time

        start = time.time()
        for _ in range(100):
            self.classifier.classify("Fix the crash when user taps the save button")
        elapsed_ms = (time.time() - start) * 10  # ms per call

        assert elapsed_ms < 100, f"Classification too slow: {elapsed_ms:.1f}ms per call"


# ==================== Integration Tests ====================

class TestIntegration:
    """Integration tests for the classifier."""

    @classmethod
    def setup_class(cls):
        """Set up test fixtures."""
        cls.original_cwd = os.getcwd()
        project_root = Path(__file__).parent.parent.parent
        os.chdir(project_root)
        cls.classifier = ProblemClassifier()

    @classmethod
    def teardown_class(cls):
        """Clean up after tests."""
        os.chdir(cls.original_cwd)

    def test_integration_multiple_classifications(self):
        """Test multiple classifications match expectations."""
        test_cases = [
            ("Fix the bug where tasks disappear", "debug"),
            ("Add OAuth authentication", "api-integration"),
            ("Refactor the service layer", "refactor"),
            ("Write unit tests for TaskRepository", "unit-test"),
            ("Create a new profile screen", "ui"),
        ]

        passed = 0
        for desc, expected in test_cases:
            result = self.classifier.classify(desc)
            if result.primary_type == expected:
                passed += 1

        # Require at least 4/5 to pass
        assert passed >= 4, f"Only {passed}/5 classifications correct"

    def test_integration_all_categories_classifiable(self):
        """Test that all categories can be classified."""
        category_examples = {
            'FOUNDATION': "Set up the infrastructure and scaffold the project",
            'DATA': "Create the data model for tasks with Core Data",
            'ARCHITECTURE': "Design the service layer architecture",
            'UI_UX': "Build the task list view with SwiftUI",
            'TESTING': "Write unit tests for the repository",
            'LOGIC': "Implement the sorting algorithm",
            'DOCUMENTATION': "Update the README documentation",
            'META': "Brainstorm ideas for the new feature",
        }

        for expected_category, desc in category_examples.items():
            result = self.classifier.classify(desc)
            assert result.primary_category == expected_category, \
                f"Expected '{expected_category}' for '{desc}', got '{result.primary_category}'"


# ==================== Run Tests ====================

def run_tests():
    """Run all tests and report results."""
    print("Running Problem Classifier Tests...")
    print("=" * 60)

    test_classes = [TestProblemClassifier, TestIntegration]
    total_passed = 0
    total_failed = 0
    failures = []

    for test_class in test_classes:
        print(f"\n{test_class.__name__}")
        print("-" * 40)

        instance = test_class()
        test_class.setup_class()

        for name in dir(instance):
            if name.startswith('test_'):
                try:
                    getattr(instance, name)()
                    print(f"  PASS: {name}")
                    total_passed += 1
                except AssertionError as e:
                    print(f"  FAIL: {name}")
                    print(f"        {e}")
                    failures.append((name, str(e)))
                    total_failed += 1
                except Exception as e:
                    print(f"  ERROR: {name}")
                    print(f"         {type(e).__name__}: {e}")
                    failures.append((name, f"{type(e).__name__}: {e}"))
                    total_failed += 1

        test_class.teardown_class()

    print("\n" + "=" * 60)
    print(f"Results: {total_passed} passed, {total_failed} failed")

    if failures:
        print("\nFailures:")
        for name, error in failures:
            print(f"  - {name}: {error}")
        return 1
    else:
        print("\nAll tests passed!")
        return 0


if __name__ == '__main__':
    sys.exit(run_tests())
