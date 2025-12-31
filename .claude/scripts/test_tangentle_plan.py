"""
Integration tests for the Tangentle Plan CLI.

Tests the CLI tool and PlanOrchestrator integration with
classifier, selector, and assessor components.
"""

import os
import sys
from pathlib import Path
from io import StringIO
import contextlib

# Add the scripts directory to the path for imports
sys.path.insert(0, str(Path(__file__).parent))

from tangentle_plan import PlanOrchestrator, cmd_classify, cmd_status, cmd_list, cmd_techniques, cmd_risk
from utils import (
    find_plan,
    load_plan_progress,
    list_all_plans,
    format_box,
    format_progress_bar,
    format_risk_level,
    format_status
)


@contextlib.contextmanager
def capture_stdout():
    """Context manager to capture stdout."""
    old_stdout = sys.stdout
    sys.stdout = StringIO()
    try:
        yield sys.stdout
    finally:
        sys.stdout = old_stdout


class MockArgs:
    """Mock arguments for testing command handlers."""
    def __init__(self, **kwargs):
        for k, v in kwargs.items():
            setattr(self, k, v)


class TestPlanOrchestrator:
    """Test suite for PlanOrchestrator."""

    @classmethod
    def setup_class(cls):
        """Set up test fixtures."""
        cls.original_cwd = os.getcwd()
        # Navigate up from .claude/scripts to project root
        project_root = Path(__file__).parent.parent.parent
        os.chdir(project_root)
        cls.orchestrator = PlanOrchestrator()

    @classmethod
    def teardown_class(cls):
        """Clean up after tests."""
        os.chdir(cls.original_cwd)

    # ==================== Classification Tests ====================

    def test_classify_returns_result(self):
        """Test that classify returns a valid result."""
        result = self.orchestrator.classify("Fix the login bug")
        assert isinstance(result, dict)
        assert "type" in result
        assert "category" in result
        assert "confidence" in result
        assert 0 <= result["confidence"] <= 1

    def test_classify_debug_problem(self):
        """Test classification of debug problem."""
        result = self.orchestrator.classify("Debug the crash when saving")
        assert result["type"] == "debug", f"Expected 'debug', got '{result['type']}'"

    def test_classify_ui_problem(self):
        """Test classification of UI problem."""
        result = self.orchestrator.classify("Build the settings screen layout")
        assert result["type"] in ["ui", "component-lib", "new-feature"], \
            f"Expected UI-related type, got '{result['type']}'"

    def test_classify_returns_alternatives(self):
        """Test that classify returns alternatives."""
        result = self.orchestrator.classify("Add new user feature")
        assert "alternatives" in result
        assert isinstance(result["alternatives"], list)

    # ==================== Technique Selection Tests ====================

    def test_get_techniques_returns_all_phases(self):
        """Test that get_techniques returns all phases."""
        techniques = self.orchestrator.get_techniques("debug")
        assert "planning" in techniques
        assert "implementation" in techniques
        assert "verification" in techniques

    def test_get_techniques_returns_valid_selections(self):
        """Test that get_techniques returns valid TechniqueSelection objects."""
        techniques = self.orchestrator.get_techniques("algorithm")
        assert techniques["planning"].primary is not None
        assert techniques["implementation"].primary is not None
        assert techniques["verification"].primary is not None

    def test_get_techniques_for_ui(self):
        """Test technique selection for UI problems."""
        techniques = self.orchestrator.get_techniques("ui")
        # UI implementation should use self-refine
        assert techniques["implementation"].primary == "self-refine", \
            f"Expected 'self-refine' for UI, got '{techniques['implementation'].primary}'"

    def test_get_techniques_for_migration(self):
        """Test technique selection for migration problems."""
        techniques = self.orchestrator.get_techniques("migration")
        # Migration should have high retry budget
        assert techniques["planning"].retry_budget >= 5, \
            f"Expected retry_budget >= 5 for migration, got {techniques['planning'].retry_budget}"

    # ==================== Risk Assessment Tests ====================

    def test_assess_risk_returns_assessment(self):
        """Test that assess_risk returns a RiskAssessment."""
        result = self.orchestrator.assess_risk({
            "problem_type": "debug"
        })
        assert hasattr(result, "level")
        assert hasattr(result, "score")
        assert hasattr(result, "retry_config")

    def test_assess_risk_documentation_is_low(self):
        """Test that documentation has low risk."""
        result = self.orchestrator.assess_risk({
            "problem_type": "documentation"
        })
        assert result.level.value == "low", \
            f"Expected 'low' risk for documentation, got '{result.level.value}'"

    def test_assess_risk_migration_is_high(self):
        """Test that migration with data_migration flag is high risk."""
        result = self.orchestrator.assess_risk({
            "problem_type": "migration",
            "has_data_migration": True
        })
        assert result.level.value in ["high", "critical"], \
            f"Expected 'high' or 'critical' for migration, got '{result.level.value}'"

    def test_assess_risk_handles_missing_keys(self):
        """Test that assess_risk handles missing keys gracefully."""
        result = self.orchestrator.assess_risk({
            "problem_type": "ui"
        })
        # Should not raise an exception
        assert result is not None

    # ==================== Plan Status Tests ====================

    def test_get_plan_status_valid_plan(self):
        """Test getting status for a valid plan."""
        status = self.orchestrator.get_plan_status("004")
        assert status is not None, "Plan 004 should exist"
        assert "plan_id" in status
        assert "status" in status
        assert "current_step" in status

    def test_get_plan_status_invalid_plan(self):
        """Test getting status for an invalid plan."""
        status = self.orchestrator.get_plan_status("999")
        assert status is None

    def test_get_plan_status_includes_progress(self):
        """Test that plan status includes progress info."""
        status = self.orchestrator.get_plan_status("004")
        if status:
            assert "total_steps" in status
            assert "completed_steps" in status
            assert "progress_pct" in status


class TestCliCommands:
    """Test suite for CLI command handlers."""

    @classmethod
    def setup_class(cls):
        """Set up test fixtures."""
        cls.original_cwd = os.getcwd()
        project_root = Path(__file__).parent.parent.parent
        os.chdir(project_root)
        cls.orchestrator = PlanOrchestrator()

    @classmethod
    def teardown_class(cls):
        """Clean up after tests."""
        os.chdir(cls.original_cwd)

    def test_cmd_classify_returns_zero(self):
        """Test that classify command returns 0 on success."""
        args = MockArgs(description="Fix the bug")
        with capture_stdout():
            result = cmd_classify(args, self.orchestrator)
        assert result == 0

    def test_cmd_classify_outputs_content(self):
        """Test that classify command outputs classification."""
        args = MockArgs(description="Fix the crash when saving")
        with capture_stdout() as output:
            cmd_classify(args, self.orchestrator)
        output_text = output.getvalue()
        assert "Type:" in output_text
        assert "Confidence:" in output_text

    def test_cmd_status_valid_plan(self):
        """Test status command for valid plan."""
        args = MockArgs(plan_id="004")
        with capture_stdout() as output:
            result = cmd_status(args, self.orchestrator)
        assert result == 0
        assert "Status:" in output.getvalue()

    def test_cmd_status_invalid_plan(self):
        """Test status command for invalid plan."""
        args = MockArgs(plan_id="999")
        with capture_stdout():
            result = cmd_status(args, self.orchestrator)
        assert result == 1

    def test_cmd_list_returns_zero(self):
        """Test that list command returns 0."""
        args = MockArgs()
        with capture_stdout():
            result = cmd_list(args, self.orchestrator)
        assert result == 0

    def test_cmd_list_shows_plans(self):
        """Test that list command shows plans."""
        args = MockArgs()
        with capture_stdout() as output:
            cmd_list(args, self.orchestrator)
        output_text = output.getvalue()
        # Should show at least plan 004
        assert "004" in output_text or "PLANS" in output_text

    def test_cmd_techniques_returns_zero(self):
        """Test that techniques command returns 0."""
        args = MockArgs(problem_type="debug")
        with capture_stdout():
            result = cmd_techniques(args, self.orchestrator)
        assert result == 0

    def test_cmd_techniques_shows_phases(self):
        """Test that techniques command shows all phases."""
        args = MockArgs(problem_type="algorithm")
        with capture_stdout() as output:
            cmd_techniques(args, self.orchestrator)
        output_text = output.getvalue()
        assert "Planning" in output_text
        assert "Implementation" in output_text
        assert "Verification" in output_text

    def test_cmd_risk_returns_zero(self):
        """Test that risk command returns 0."""
        args = MockArgs(
            type="migration",
            migration=True,
            api=False,
            breaking=False,
            persistence=True,
            complexity="high",
            files=None
        )
        with capture_stdout():
            result = cmd_risk(args, self.orchestrator)
        assert result == 0

    def test_cmd_risk_shows_level(self):
        """Test that risk command shows risk level."""
        args = MockArgs(
            type="documentation",
            migration=False,
            api=False,
            breaking=False,
            persistence=False,
            complexity="low",
            files=None
        )
        with capture_stdout() as output:
            cmd_risk(args, self.orchestrator)
        output_text = output.getvalue()
        assert "Risk Level:" in output_text or "LOW" in output_text


class TestUtils:
    """Test suite for utility functions."""

    @classmethod
    def setup_class(cls):
        """Set up test fixtures."""
        cls.original_cwd = os.getcwd()
        project_root = Path(__file__).parent.parent.parent
        os.chdir(project_root)

    @classmethod
    def teardown_class(cls):
        """Clean up after tests."""
        os.chdir(cls.original_cwd)

    def test_find_plan_existing(self):
        """Test finding an existing plan."""
        plan_dir = find_plan("004")
        assert plan_dir is not None
        assert plan_dir.exists()

    def test_find_plan_nonexistent(self):
        """Test finding a non-existent plan."""
        plan_dir = find_plan("999")
        assert plan_dir is None

    def test_load_plan_progress(self):
        """Test loading plan progress."""
        plan_dir = find_plan("004")
        if plan_dir:
            progress = load_plan_progress(plan_dir)
            assert progress is not None
            assert "planId" in progress
            assert "steps" in progress

    def test_list_all_plans(self):
        """Test listing all plans."""
        plans = list_all_plans()
        assert isinstance(plans, list)
        # Should have at least plan 004
        plan_ids = [p["id"] for p in plans]
        assert "004" in plan_ids

    def test_format_box(self):
        """Test box formatting."""
        result = format_box("TITLE", ["Line 1", "Line 2"])
        assert "TITLE" in result
        assert "Line 1" in result
        assert "=" in result

    def test_format_progress_bar(self):
        """Test progress bar formatting."""
        bar = format_progress_bar(5, 10, width=10)
        assert len(bar) == 10
        assert "█" in bar
        assert "░" in bar

    def test_format_progress_bar_empty(self):
        """Test progress bar with zero total."""
        bar = format_progress_bar(0, 0, width=10)
        assert len(bar) == 10
        assert bar == "░" * 10

    def test_format_risk_level(self):
        """Test risk level formatting."""
        assert "LOW" in format_risk_level("low")
        assert "HIGH" in format_risk_level("high")
        assert "CRITICAL" in format_risk_level("critical")

    def test_format_status(self):
        """Test status formatting."""
        assert "COMPLETED" in format_status("completed")
        assert "PENDING" in format_status("pending")


class TestIntegration:
    """Integration tests for the full system."""

    @classmethod
    def setup_class(cls):
        """Set up test fixtures."""
        cls.original_cwd = os.getcwd()
        project_root = Path(__file__).parent.parent.parent
        os.chdir(project_root)
        cls.orchestrator = PlanOrchestrator()

    @classmethod
    def teardown_class(cls):
        """Clean up after tests."""
        os.chdir(cls.original_cwd)

    def test_full_workflow_classify_to_techniques(self):
        """Test full workflow from classification to technique selection."""
        # 1. Classify
        classification = self.orchestrator.classify("Fix the authentication bug")

        # 2. Get techniques based on classification
        techniques = self.orchestrator.get_techniques(classification["type"])

        # 3. Assess risk
        risk = self.orchestrator.assess_risk({
            "problem_type": classification["type"]
        })

        # All should complete without error
        assert classification["type"] is not None
        assert techniques["planning"].primary is not None
        assert risk.level is not None

    def test_all_problem_types_work(self):
        """Test that all major problem types work through the pipeline."""
        problem_types = [
            "debug", "ui", "algorithm", "migration",
            "documentation", "refactor", "api-integration"
        ]

        for ptype in problem_types:
            techniques = self.orchestrator.get_techniques(ptype)
            risk = self.orchestrator.assess_risk({"problem_type": ptype})

            assert techniques["planning"].primary is not None, \
                f"Failed for {ptype}"
            assert risk.level is not None, \
                f"Failed risk for {ptype}"


# ==================== Run Tests ====================

def run_tests():
    """Run all tests and report results."""
    print("Running Tangentle Plan CLI Tests...")
    print("=" * 60)

    test_classes = [
        TestPlanOrchestrator,
        TestCliCommands,
        TestUtils,
        TestIntegration
    ]
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
