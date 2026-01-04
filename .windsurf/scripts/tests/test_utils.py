"""Unit tests for utils.py."""

import unittest
import tempfile
import json
from pathlib import Path
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from utils import (
    format_box,
    format_progress_bar,
    format_risk_level,
    format_status,
    format_json,
    get_step_by_number,
    get_current_step,
    WINDSURF_ROOT,
    PLANS_DIR,
)


class TestFormatBox(unittest.TestCase):
    """Tests for format_box function."""

    def test_basic_box(self):
        """Test creating a basic box."""
        result = format_box("TITLE", ["Line 1", "Line 2"])
        self.assertIn("TITLE", result)
        self.assertIn("Line 1", result)
        self.assertIn("Line 2", result)
        # Check box borders
        lines = result.split("\n")
        self.assertTrue(lines[0].startswith("="))
        self.assertTrue(lines[-1].startswith("="))

    def test_empty_content(self):
        """Test box with empty content."""
        result = format_box("TITLE", [])
        self.assertIn("TITLE", result)


class TestFormatProgressBar(unittest.TestCase):
    """Tests for format_progress_bar function."""

    def test_full_progress(self):
        """Test 100% progress."""
        result = format_progress_bar(10, 10, width=10)
        self.assertEqual(result, "██████████")

    def test_empty_progress(self):
        """Test 0% progress."""
        result = format_progress_bar(0, 10, width=10)
        self.assertEqual(result, "░░░░░░░░░░")

    def test_half_progress(self):
        """Test 50% progress."""
        result = format_progress_bar(5, 10, width=10)
        self.assertEqual(result, "█████░░░░░")

    def test_zero_total(self):
        """Test with zero total (should return empty bar)."""
        result = format_progress_bar(0, 0, width=10)
        self.assertEqual(result, "░░░░░░░░░░")


class TestFormatRiskLevel(unittest.TestCase):
    """Tests for format_risk_level function."""

    def test_low_risk(self):
        """Test low risk formatting."""
        result = format_risk_level("low")
        self.assertEqual(result, "LOW")

    def test_high_risk(self):
        """Test high risk formatting."""
        result = format_risk_level("high")
        self.assertEqual(result, "HIGH")

    def test_unknown_risk(self):
        """Test unknown risk level."""
        result = format_risk_level("unknown")
        self.assertEqual(result, "UNKNOWN")

    def test_case_insensitive(self):
        """Test case insensitivity."""
        self.assertEqual(format_risk_level("LOW"), "LOW")
        self.assertEqual(format_risk_level("Medium"), "MEDIUM")


class TestFormatStatus(unittest.TestCase):
    """Tests for format_status function."""

    def test_completed_status(self):
        """Test completed status formatting."""
        result = format_status("completed")
        self.assertIn("COMPLETED", result)
        self.assertIn("[DONE]", result)

    def test_pending_status(self):
        """Test pending status formatting."""
        result = format_status("pending")
        self.assertIn("PENDING", result)

    def test_in_progress_status(self):
        """Test in_progress status formatting."""
        result = format_status("in_progress")
        self.assertIn("IN_PROGRESS", result)


class TestFormatJson(unittest.TestCase):
    """Tests for format_json function."""

    def test_simple_dict(self):
        """Test formatting a simple dictionary."""
        data = {"key": "value"}
        result = format_json(data)
        self.assertIn('"key"', result)
        self.assertIn('"value"', result)

    def test_nested_dict(self):
        """Test formatting a nested dictionary."""
        data = {"outer": {"inner": "value"}}
        result = format_json(data)
        self.assertIn('"outer"', result)
        self.assertIn('"inner"', result)


class TestGetStepByNumber(unittest.TestCase):
    """Tests for get_step_by_number function."""

    def test_valid_step(self):
        """Test getting a valid step."""
        progress = {
            "steps": [
                {"id": 1, "name": "step1"},
                {"id": 2, "name": "step2"},
                {"id": 3, "name": "step3"},
            ]
        }
        step = get_step_by_number(progress, 2)
        self.assertIsNotNone(step)
        self.assertEqual(step["name"], "step2")

    def test_invalid_step_number(self):
        """Test getting an invalid step number."""
        progress = {"steps": [{"id": 1, "name": "step1"}]}
        step = get_step_by_number(progress, 5)
        self.assertIsNone(step)

    def test_zero_step_number(self):
        """Test step number 0 (invalid)."""
        progress = {"steps": [{"id": 1, "name": "step1"}]}
        step = get_step_by_number(progress, 0)
        self.assertIsNone(step)


class TestGetCurrentStep(unittest.TestCase):
    """Tests for get_current_step function."""

    def test_current_step(self):
        """Test getting current step."""
        progress = {
            "currentStep": 2,
            "steps": [
                {"id": 1, "name": "step1"},
                {"id": 2, "name": "step2"},
            ]
        }
        step = get_current_step(progress)
        self.assertIsNotNone(step)
        self.assertEqual(step["name"], "step2")

    def test_no_current_step(self):
        """Test when currentStep is 0."""
        progress = {
            "currentStep": 0,
            "steps": [{"id": 1, "name": "step1"}]
        }
        step = get_current_step(progress)
        self.assertIsNone(step)


class TestPaths(unittest.TestCase):
    """Tests for path constants."""

    def test_windsurf_root(self):
        """Test WINDSURF_ROOT path."""
        self.assertEqual(WINDSURF_ROOT, Path(".windsurf"))

    def test_plans_dir(self):
        """Test PLANS_DIR path."""
        self.assertEqual(PLANS_DIR, Path(".windsurf/plans"))


if __name__ == "__main__":
    unittest.main()
