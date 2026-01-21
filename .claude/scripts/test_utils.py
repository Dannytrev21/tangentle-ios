"""
Unit tests for utils.py thinking keyword functions.

Tests the get_thinking_keyword and get_thinking_keyword_description functions.
"""

import os
import sys
from pathlib import Path

# Add the scripts directory to the path for imports
sys.path.insert(0, str(Path(__file__).parent))

from utils import get_thinking_keyword, get_thinking_keyword_description


class TestGetThinkingKeyword:
    """Test suite for get_thinking_keyword function."""

    def test_low_risk_returns_think_about(self):
        """Test that low risk returns 'Think about'."""
        assert get_thinking_keyword("low") == "Think about"

    def test_medium_risk_returns_think_hard_about(self):
        """Test that medium risk returns 'Think hard about'."""
        assert get_thinking_keyword("medium") == "Think hard about"

    def test_high_risk_returns_ultrathink_about(self):
        """Test that high risk returns 'Ultrathink about'."""
        assert get_thinking_keyword("high") == "Ultrathink about"

    def test_critical_risk_returns_ultrathink_about(self):
        """Test that critical risk returns 'Ultrathink about'."""
        assert get_thinking_keyword("critical") == "Ultrathink about"

    def test_case_insensitive_low(self):
        """Test case insensitivity for LOW."""
        assert get_thinking_keyword("LOW") == "Think about"
        assert get_thinking_keyword("Low") == "Think about"

    def test_case_insensitive_medium(self):
        """Test case insensitivity for MEDIUM."""
        assert get_thinking_keyword("MEDIUM") == "Think hard about"
        assert get_thinking_keyword("Medium") == "Think hard about"

    def test_case_insensitive_high(self):
        """Test case insensitivity for HIGH."""
        assert get_thinking_keyword("HIGH") == "Ultrathink about"
        assert get_thinking_keyword("High") == "Ultrathink about"

    def test_case_insensitive_critical(self):
        """Test case insensitivity for CRITICAL."""
        assert get_thinking_keyword("CRITICAL") == "Ultrathink about"
        assert get_thinking_keyword("Critical") == "Ultrathink about"

    def test_unknown_returns_default(self):
        """Test that unknown risk level returns default."""
        assert get_thinking_keyword("unknown") == "Think hard about"
        assert get_thinking_keyword("xyz") == "Think hard about"
        assert get_thinking_keyword("invalid") == "Think hard about"

    def test_empty_string_returns_default(self):
        """Test that empty string returns default."""
        assert get_thinking_keyword("") == "Think hard about"

    def test_none_returns_default(self):
        """Test that None returns default."""
        assert get_thinking_keyword(None) == "Think hard about"


class TestGetThinkingKeywordDescription:
    """Test suite for get_thinking_keyword_description function."""

    def test_think_about_has_description(self):
        """Test description for 'Think about'."""
        result = get_thinking_keyword_description("Think about")
        assert "standard" in result.lower() or "routine" in result.lower()

    def test_think_hard_about_has_description(self):
        """Test description for 'Think hard about'."""
        result = get_thinking_keyword_description("Think hard about")
        assert "increased" in result.lower() or "moderate" in result.lower()

    def test_ultrathink_about_has_description(self):
        """Test description for 'Ultrathink about'."""
        result = get_thinking_keyword_description("Ultrathink about")
        assert "maximum" in result.lower() or "31,999" in result or "critical" in result.lower()

    def test_unknown_keyword_returns_empty(self):
        """Test that unknown keyword returns empty string."""
        assert get_thinking_keyword_description("Unknown keyword") == ""
        assert get_thinking_keyword_description("") == ""


# ==================== Run Tests ====================

def run_tests():
    """Run all tests and report results."""
    print("Running Utils Thinking Keyword Tests...")
    print("=" * 60)

    test_classes = [TestGetThinkingKeyword, TestGetThinkingKeywordDescription]
    total_passed = 0
    total_failed = 0
    failures = []

    for test_class in test_classes:
        print(f"\n{test_class.__name__}")
        print("-" * 40)

        instance = test_class()

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
