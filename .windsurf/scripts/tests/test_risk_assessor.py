"""Unit tests for risk_assessor.py."""

import unittest
from pathlib import Path
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from risk_assessor import (
    RiskAssessor,
    RiskLevel,
    StepInfo,
    RiskAssessment,
    RetryConfig,
    EscalationDecision,
    RISK_FACTORS,
    RETRY_CONFIGS,
)


class TestRiskAssessor(unittest.TestCase):
    """Tests for RiskAssessor class."""

    def setUp(self):
        """Set up test fixtures."""
        self.assessor = RiskAssessor()

    def test_assess_low_risk(self):
        """Test assessing a low-risk step."""
        step = StepInfo(
            problem_type="documentation",
            files_to_create=["README.md"],
        )
        result = self.assessor.assess_risk(step)
        self.assertEqual(result.level, RiskLevel.LOW)

    def test_assess_high_risk(self):
        """Test assessing a high-risk step."""
        step = StepInfo(
            problem_type="migration",
            has_data_migration=True,
            affects_persistence=True,
        )
        result = self.assessor.assess_risk(step)
        self.assertIn(result.level, [RiskLevel.HIGH, RiskLevel.CRITICAL])

    def test_assessment_structure(self):
        """Test that assessment has correct structure."""
        step = StepInfo(problem_type="debug")
        result = self.assessor.assess_risk(step)

        self.assertIsInstance(result, RiskAssessment)
        self.assertIsInstance(result.level, RiskLevel)
        self.assertIsInstance(result.score, float)
        self.assertIsInstance(result.factors, list)
        self.assertIsInstance(result.retry_config, RetryConfig)
        self.assertIsInstance(result.explanation, str)
        self.assertIsInstance(result.mitigations, list)

    def test_score_range(self):
        """Test that score is between 0 and 1."""
        step = StepInfo(problem_type="debug")
        result = self.assessor.assess_risk(step)
        self.assertGreaterEqual(result.score, 0.0)
        self.assertLessEqual(result.score, 1.0)

    def test_factors_increase_risk(self):
        """Test that risk factors increase the score."""
        base_step = StepInfo(problem_type="service-impl")
        base_result = self.assessor.assess_risk(base_step)

        risky_step = StepInfo(
            problem_type="service-impl",
            has_data_migration=True,
            is_breaking_change=True,
        )
        risky_result = self.assessor.assess_risk(risky_step)

        self.assertGreater(risky_result.score, base_result.score)

    def test_factors_decrease_risk(self):
        """Test that some factors decrease the score."""
        base_step = StepInfo(
            problem_type="documentation",
            files_to_create=["file.md"],
        )
        result = self.assessor.assess_risk(base_step)

        # Documentation-only and new-files-only should reduce risk
        present_factors = [f for f in result.factors if f.present and f.weight < 0]
        self.assertGreater(len(present_factors), 0)

    def test_retry_config_low_risk(self):
        """Test retry config for low risk."""
        step = StepInfo(problem_type="documentation")
        result = self.assessor.assess_risk(step)
        self.assertEqual(result.retry_config.max_total, 3)

    def test_retry_config_high_risk(self):
        """Test retry config for high risk."""
        step = StepInfo(
            problem_type="migration",
            has_data_migration=True,
        )
        result = self.assessor.assess_risk(step)
        self.assertGreater(result.retry_config.max_total, 3)

    def test_mitigations_for_risky_step(self):
        """Test that mitigations are suggested for risky steps."""
        step = StepInfo(
            problem_type="migration",
            has_data_migration=True,
        )
        result = self.assessor.assess_risk(step)
        self.assertGreater(len(result.mitigations), 0)

    def test_get_retry_config(self):
        """Test getting retry config for risk level."""
        config = self.assessor.get_retry_config(RiskLevel.LOW)
        self.assertEqual(config.max_total, 3)

        config = self.assessor.get_retry_config(RiskLevel.CRITICAL)
        self.assertEqual(config.max_total, 10)

    def test_should_escalate_exhausted(self):
        """Test escalation when attempts exhausted."""
        decision = self.assessor.should_escalate(
            current_attempt=10,
            risk_level=RiskLevel.CRITICAL,
        )
        self.assertTrue(decision.should_escalate)
        self.assertEqual(decision.recommended_action, "user_intervention")

    def test_should_escalate_within_budget(self):
        """Test no escalation when within budget."""
        decision = self.assessor.should_escalate(
            current_attempt=1,
            risk_level=RiskLevel.LOW,
        )
        self.assertFalse(decision.should_escalate)
        self.assertEqual(decision.recommended_action, "retry")

    def test_should_escalate_critical_pattern(self):
        """Test escalation on critical failure pattern."""
        decision = self.assessor.should_escalate(
            current_attempt=1,
            risk_level=RiskLevel.LOW,
            failure_pattern="Critical: data corruption detected"
        )
        self.assertTrue(decision.should_escalate)

    def test_calculate_step_risk_score(self):
        """Test convenience method for calculating risk score."""
        score = self.assessor.calculate_step_risk_score(
            problem_type="migration",
            files_modified=10,
            has_migration=True,
        )
        self.assertIsInstance(score, float)
        self.assertGreaterEqual(score, 0.0)
        self.assertLessEqual(score, 1.0)


class TestRiskLevels(unittest.TestCase):
    """Tests for RiskLevel enum."""

    def test_four_risk_levels(self):
        """Test that there are 4 risk levels."""
        self.assertEqual(len(RiskLevel), 4)

    def test_level_values(self):
        """Test risk level values."""
        self.assertEqual(RiskLevel.LOW.value, "low")
        self.assertEqual(RiskLevel.MEDIUM.value, "medium")
        self.assertEqual(RiskLevel.HIGH.value, "high")
        self.assertEqual(RiskLevel.CRITICAL.value, "critical")


class TestRetryConfigs(unittest.TestCase):
    """Tests for RETRY_CONFIGS constant."""

    def test_all_levels_have_config(self):
        """Test that all risk levels have retry config."""
        for level in RiskLevel:
            self.assertIn(level, RETRY_CONFIGS)

    def test_config_structure(self):
        """Test retry config structure."""
        for level, config in RETRY_CONFIGS.items():
            self.assertIsInstance(config.max_same_technique, int)
            self.assertIsInstance(config.max_alternative_technique, int)
            self.assertIsInstance(config.max_total, int)
            self.assertIsInstance(config.escalation_threshold, int)
            self.assertIsInstance(config.techniques_rotation, list)

    def test_config_values_increase_with_risk(self):
        """Test that retry budgets increase with risk level."""
        low = RETRY_CONFIGS[RiskLevel.LOW]
        medium = RETRY_CONFIGS[RiskLevel.MEDIUM]
        high = RETRY_CONFIGS[RiskLevel.HIGH]
        critical = RETRY_CONFIGS[RiskLevel.CRITICAL]

        self.assertLess(low.max_total, medium.max_total)
        self.assertLess(medium.max_total, high.max_total)
        self.assertLessEqual(high.max_total, critical.max_total)


class TestRiskFactors(unittest.TestCase):
    """Tests for RISK_FACTORS constant."""

    def test_factors_have_required_fields(self):
        """Test that all factors have required fields."""
        for name, factor in RISK_FACTORS.items():
            self.assertIn("weight", factor)
            self.assertIn("description", factor)
            self.assertIsInstance(factor["weight"], (int, float))
            self.assertIsInstance(factor["description"], str)

    def test_positive_and_negative_factors(self):
        """Test that there are both positive and negative factors."""
        positive = [f for f in RISK_FACTORS.values() if f["weight"] > 0]
        negative = [f for f in RISK_FACTORS.values() if f["weight"] < 0]

        self.assertGreater(len(positive), 0)
        self.assertGreater(len(negative), 0)


if __name__ == "__main__":
    unittest.main()
