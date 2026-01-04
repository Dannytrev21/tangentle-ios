#!/usr/bin/env python3
"""
Unit tests for the Self-Correction Engine module.

Tests cover:
- Retry budget calculation per risk level
- Technique rotation based on failure patterns
- Failure evaluation and action recommendations
- Memory bank integration
- Escalation logic
"""

import shutil
import tempfile
import unittest
from pathlib import Path
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from self_correction import (
    SelfCorrection,
    RetryAction,
    EvaluationResult,
    RETRY_CONFIG,
    FAILURE_PATTERNS,
    TECHNIQUE_ALTERNATIVES,
    get_retry_config
)
from memory_bank import MemoryBank, create_entry


class TestRetryConfig(unittest.TestCase):
    """Tests for retry configuration."""

    def test_low_risk_budget(self):
        """Low risk should have smallest budget."""
        config = get_retry_config("low")

        self.assertEqual(config["max_same"], 2)
        self.assertEqual(config["max_alt"], 1)
        self.assertEqual(config["max_total"], 3)
        self.assertEqual(config["escalate_after"], 2)

    def test_medium_risk_budget(self):
        """Medium risk should have moderate budget."""
        config = get_retry_config("medium")

        self.assertEqual(config["max_same"], 3)
        self.assertEqual(config["max_alt"], 2)
        self.assertEqual(config["max_total"], 5)
        self.assertEqual(config["escalate_after"], 3)

    def test_high_risk_budget(self):
        """High risk should have larger budget."""
        config = get_retry_config("high")

        self.assertEqual(config["max_same"], 3)
        self.assertEqual(config["max_alt"], 3)
        self.assertEqual(config["max_total"], 7)
        self.assertEqual(config["escalate_after"], 5)

    def test_critical_risk_budget(self):
        """Critical risk should have largest budget."""
        config = get_retry_config("critical")

        self.assertEqual(config["max_same"], 5)
        self.assertEqual(config["max_alt"], 5)
        self.assertEqual(config["max_total"], 10)
        self.assertEqual(config["escalate_after"], 7)

    def test_budget_matches_risk_level(self):
        """Budgets should increase with risk level."""
        low = get_retry_config("low")
        medium = get_retry_config("medium")
        high = get_retry_config("high")
        critical = get_retry_config("critical")

        self.assertLess(low["max_total"], medium["max_total"])
        self.assertLess(medium["max_total"], high["max_total"])
        self.assertLess(high["max_total"], critical["max_total"])

    def test_unknown_risk_defaults_to_medium(self):
        """Unknown risk level should default to medium."""
        config = get_retry_config("unknown")
        medium = get_retry_config("medium")

        self.assertEqual(config["max_total"], medium["max_total"])

    def test_case_insensitive_risk_level(self):
        """Risk level lookup should be case insensitive."""
        config_lower = get_retry_config("high")
        config_upper = get_retry_config("HIGH")
        config_mixed = get_retry_config("High")

        self.assertEqual(config_lower, config_upper)
        self.assertEqual(config_lower, config_mixed)


class TestSelfCorrection(unittest.TestCase):
    """Tests for SelfCorrection class."""

    def setUp(self):
        """Create a temporary directory and engine for each test."""
        self.test_dir = tempfile.mkdtemp()
        self.plan_dir = Path(self.test_dir) / "test-plan"
        self.plan_dir.mkdir(parents=True)
        self.bank = MemoryBank(str(self.plan_dir))
        self.engine = SelfCorrection(self.bank, risk_level="medium")

    def tearDown(self):
        """Clean up temporary directory."""
        shutil.rmtree(self.test_dir, ignore_errors=True)

    def test_evaluate_first_failure_returns_retry(self):
        """First failure should recommend retry with same technique."""
        result = self.engine.evaluate_failure(
            step_id=1,
            failure_type="test_failure",
            failure_message="Test assertion failed",
            current_technique="tdd",
            attempts={"same": 0, "alt": 0}
        )

        self.assertEqual(result.action, "retry")
        self.assertEqual(result.technique, "tdd")
        self.assertIn("1/3", result.rationale)  # 1 of 3 same-technique attempts

    def test_evaluate_returns_retry_within_same_budget(self):
        """Should continue retrying with same technique within budget."""
        result = self.engine.evaluate_failure(
            step_id=1,
            failure_type="test_failure",
            failure_message="Still failing",
            current_technique="tdd",
            attempts={"same": 2, "alt": 0}  # 2 of 3 used
        )

        self.assertEqual(result.action, "retry")
        self.assertEqual(result.technique, "tdd")

    def test_evaluate_returns_rotate_when_same_exhausted(self):
        """Should rotate technique when same-technique budget exhausted."""
        result = self.engine.evaluate_failure(
            step_id=1,
            failure_type="test_failure",
            failure_message="Test still failing",
            current_technique="tdd",
            attempts={"same": 3, "alt": 0}  # All 3 same-technique used
        )

        self.assertEqual(result.action, "rotate")
        self.assertNotEqual(result.technique, "tdd")  # Should be different
        self.assertIn("Rotating", result.rationale)

    def test_evaluate_returns_escalate_when_all_exhausted(self):
        """Should escalate when all retries exhausted."""
        result = self.engine.evaluate_failure(
            step_id=1,
            failure_type="test_failure",
            failure_message="Nothing works",
            current_technique="tdd",
            attempts={"same": 3, "alt": 2}  # Total = 5 = max for medium
        )

        self.assertEqual(result.action, "escalate")
        self.assertIn("exhausted", result.rationale)
        self.assertEqual(result.remaining_budget, 0)

    def test_remaining_budget_calculated_correctly(self):
        """Remaining budget should be calculated correctly."""
        # Medium risk has max_total = 5
        result = self.engine.evaluate_failure(
            step_id=1,
            failure_type="test",
            failure_message="Test",
            current_technique="tdd",
            attempts={"same": 1, "alt": 1}  # Used 2
        )

        self.assertEqual(result.remaining_budget, 3)  # 5 - 2 = 3


class TestTechniqueRotation(unittest.TestCase):
    """Tests for technique rotation logic."""

    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.plan_dir = Path(self.test_dir) / "test-plan"
        self.plan_dir.mkdir(parents=True)
        self.bank = MemoryBank(str(self.plan_dir))
        self.engine = SelfCorrection(self.bank)

    def tearDown(self):
        shutil.rmtree(self.test_dir, ignore_errors=True)

    def test_rotation_selects_correct_technique_for_test_failure(self):
        """Test failure pattern should suggest TDD."""
        alt = self.engine._select_alternative(
            "XCTAssertEqual test assertion failed",
            "self-refine"
        )
        self.assertEqual(alt, "tdd")

    def test_rotation_selects_correct_technique_for_convergence(self):
        """Convergence issues should suggest self-consistency."""
        alt = self.engine._select_alternative(
            "Not converging, stuck in iteration loop",
            "tdd"
        )
        self.assertEqual(alt, "self-consistency")

    def test_rotation_selects_correct_technique_for_architecture(self):
        """Architecture issues should suggest ToT."""
        alt = self.engine._select_alternative(
            "Architecture design pattern problem with coupling",
            "tdd"
        )
        self.assertEqual(alt, "tot")

    def test_rotation_selects_correct_technique_for_async(self):
        """Async issues should suggest ReAct."""
        alt = self.engine._select_alternative(
            "Async await race condition timeout",
            "tdd"
        )
        self.assertEqual(alt, "react")

    def test_rotation_selects_correct_technique_for_repeated(self):
        """Repeated mistakes should suggest Reflexion."""
        alt = self.engine._select_alternative(
            "Same error again, still failing with repeated issue",
            "tdd"
        )
        self.assertEqual(alt, "reflexion")

    def test_rotation_selects_correct_technique_for_integration(self):
        """Integration issues should suggest Chain-of-Code."""
        alt = self.engine._select_alternative(
            "API service connection integration failed",
            "tdd"
        )
        self.assertEqual(alt, "chain-of-code")

    def test_rotation_excludes_current_technique(self):
        """Rotation should never return the current technique."""
        # Even if pattern matches TDD, if current is TDD, should rotate away
        alt = self.engine._select_alternative(
            "test assertion failed",
            "tdd"
        )
        self.assertNotEqual(alt, "tdd")

    def test_rotation_falls_back_to_alternatives_list(self):
        """Should fall back to alternatives list when no pattern matches."""
        alt = self.engine._select_alternative(
            "some random error with no pattern",
            "ps-plus"
        )
        # Should get first alternative for ps-plus
        self.assertIn(alt, TECHNIQUE_ALTERNATIVES["ps-plus"])

    def test_all_techniques_have_alternatives(self):
        """Every technique should have at least one alternative."""
        for technique, alternatives in TECHNIQUE_ALTERNATIVES.items():
            self.assertGreater(len(alternatives), 0,
                f"Technique {technique} has no alternatives")


class TestMemoryBankIntegration(unittest.TestCase):
    """Tests for memory bank integration."""

    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.plan_dir = Path(self.test_dir) / "test-plan"
        self.plan_dir.mkdir(parents=True)
        self.bank = MemoryBank(str(self.plan_dir))
        self.engine = SelfCorrection(self.bank)

    def tearDown(self):
        shutil.rmtree(self.test_dir, ignore_errors=True)

    def test_record_failure_adds_to_memory_bank(self):
        """record_failure should add entry to memory bank."""
        entry = self.engine.record_failure(
            step_id=1,
            failure_type="test_failure",
            context="Test XYZ failed",
            technique_used="tdd"
        )

        self.assertEqual(entry.stepId, 1)
        self.assertEqual(entry.failureType, "test_failure")
        self.assertEqual(len(self.bank), 1)

    def test_record_resolution_updates_last_entry(self):
        """record_resolution should update the most recent entry."""
        self.engine.record_failure(
            step_id=1,
            failure_type="test_failure",
            context="Test failed",
            technique_used="tdd"
        )

        success = self.engine.record_resolution(
            lesson="Need to mock dependencies",
            resolution="Added mock for service"
        )

        self.assertTrue(success)
        entries = self.bank.get_entries()
        self.assertEqual(entries[-1].lesson, "Need to mock dependencies")
        self.assertEqual(entries[-1].resolution, "Added mock for service")

    def test_guidance_includes_step_lessons(self):
        """Guidance should include lessons from the same step."""
        # Add some history
        self.bank.add_entry(create_entry(
            1, "test_failure", "First failure", "tdd", "Check mocks"
        ))
        self.bank.add_entry(create_entry(
            1, "test_failure", "Second failure", "tdd", "Use in-memory DB"
        ))

        result = self.engine.evaluate_failure(
            step_id=1,
            failure_type="test_failure",
            failure_message="Third failure",
            current_technique="tdd",
            attempts={"same": 0, "alt": 0}
        )

        self.assertIn("Check mocks", result.guidance)
        self.assertIn("Use in-memory DB", result.guidance)

    def test_guidance_includes_failure_type_lessons(self):
        """Guidance should include lessons from same failure type."""
        self.bank.add_entry(create_entry(
            5, "test_failure", "Old failure", "tdd", "Always check assertions"
        ))

        result = self.engine.evaluate_failure(
            step_id=1,  # Different step
            failure_type="test_failure",  # Same failure type
            failure_message="New failure",
            current_technique="tdd",
            attempts={"same": 0, "alt": 0}
        )

        self.assertIn("Always check assertions", result.guidance)


class TestEscalation(unittest.TestCase):
    """Tests for escalation behavior."""

    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.plan_dir = Path(self.test_dir) / "test-plan"
        self.plan_dir.mkdir(parents=True)
        self.bank = MemoryBank(str(self.plan_dir))

    def tearDown(self):
        shutil.rmtree(self.test_dir, ignore_errors=True)

    def test_escalation_at_budget_limit(self):
        """Should escalate when budget is exhausted."""
        engine = SelfCorrection(self.bank, risk_level="low")  # max_total = 3

        result = engine.evaluate_failure(
            step_id=1,
            failure_type="test",
            failure_message="Still failing",
            current_technique="tdd",
            attempts={"same": 2, "alt": 1}  # Total = 3 = max for low
        )

        self.assertEqual(result.action, "escalate")

    def test_no_escalation_before_budget(self):
        """Should not escalate before budget is exhausted."""
        engine = SelfCorrection(self.bank, risk_level="critical")  # max_total = 10

        result = engine.evaluate_failure(
            step_id=1,
            failure_type="test",
            failure_message="Failing",
            current_technique="tdd",
            attempts={"same": 4, "alt": 4}  # Total = 8 < 10
        )

        self.assertNotEqual(result.action, "escalate")

    def test_get_failure_summary(self):
        """get_failure_summary should summarize step failures."""
        engine = SelfCorrection(self.bank)

        engine.record_failure(1, "test_failure", "First test failed", "tdd")
        engine.record_failure(1, "logic_error", "Logic was wrong", "tdd")
        engine.record_failure(1, "test_failure", "Second test failed", "tdd")

        summary = engine.get_failure_summary(1)

        self.assertIn("3 failures", summary)
        self.assertIn("test_failure", summary)
        self.assertIn("logic_error", summary)

    def test_format_escalation_message(self):
        """format_escalation_message should produce readable output."""
        engine = SelfCorrection(self.bank)

        engine.record_failure(1, "test_failure", "Failed miserably", "tdd")

        message = engine.format_escalation_message(
            step_id=1,
            step_name="Test Step",
            total_attempts=5
        )

        self.assertIn("ESCALATION", message)
        self.assertIn("Step 1", message)
        self.assertIn("Test Step", message)
        self.assertIn("5 attempts", message)


class TestRiskLevelIntegration(unittest.TestCase):
    """Tests for risk level integration with self-correction."""

    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.plan_dir = Path(self.test_dir) / "test-plan"
        self.plan_dir.mkdir(parents=True)
        self.bank = MemoryBank(str(self.plan_dir))

    def tearDown(self):
        shutil.rmtree(self.test_dir, ignore_errors=True)

    def test_low_risk_escalates_quickly(self):
        """Low risk should escalate after fewer attempts."""
        engine = SelfCorrection(self.bank, risk_level="low")

        # Low risk: 2 same + 1 alt = 3 total
        result = engine.evaluate_failure(
            step_id=1,
            failure_type="test",
            failure_message="Failed",
            current_technique="tdd",
            attempts={"same": 2, "alt": 1}
        )

        self.assertEqual(result.action, "escalate")

    def test_critical_risk_retries_longer(self):
        """Critical risk should retry many more times."""
        engine = SelfCorrection(self.bank, risk_level="critical")

        # Critical: 5 same + 5 alt = 10 total
        # After 5 same attempts, should rotate
        result = engine.evaluate_failure(
            step_id=1,
            failure_type="test",
            failure_message="Failed",
            current_technique="tdd",
            attempts={"same": 5, "alt": 0}
        )

        self.assertEqual(result.action, "rotate")  # Not escalate yet

        # After 5 same + 4 alt, should still rotate
        result = engine.evaluate_failure(
            step_id=1,
            failure_type="test",
            failure_message="Failed",
            current_technique="reflexion",
            attempts={"same": 5, "alt": 4}
        )

        self.assertEqual(result.action, "rotate")

        # After 5 same + 5 alt = 10, should escalate
        result = engine.evaluate_failure(
            step_id=1,
            failure_type="test",
            failure_message="Failed",
            current_technique="reflexion",
            attempts={"same": 5, "alt": 5}
        )

        self.assertEqual(result.action, "escalate")

    def test_get_retry_budget(self):
        """get_retry_budget should return correct configuration."""
        engine = SelfCorrection(self.bank, risk_level="high")
        budget = engine.get_retry_budget()

        self.assertEqual(budget["max_same_technique"], 3)
        self.assertEqual(budget["max_alternative"], 3)
        self.assertEqual(budget["max_total"], 7)
        self.assertEqual(budget["escalate_after"], 5)


if __name__ == '__main__':
    unittest.main()
