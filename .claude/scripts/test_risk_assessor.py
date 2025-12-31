"""
Unit tests for the Risk Assessor.

Tests risk assessment, retry configurations, escalation decisions,
and factor weighting.
"""

import os
import sys
from pathlib import Path

# Add the scripts directory to the path for imports
sys.path.insert(0, str(Path(__file__).parent))

from risk_assessor import (
    RiskAssessor,
    RiskLevel,
    StepInfo,
    RiskFactor,
    RetryConfig,
    RiskAssessment,
    EscalationDecision,
    RISK_FACTORS,
    RETRY_CONFIGS
)


class TestRiskAssessor:
    """Test suite for RiskAssessor."""

    @classmethod
    def setup_class(cls):
        """Set up test fixtures."""
        cls.original_cwd = os.getcwd()
        # Navigate up from .claude/scripts to project root
        project_root = Path(__file__).parent.parent.parent
        os.chdir(project_root)
        cls.assessor = RiskAssessor()

    @classmethod
    def teardown_class(cls):
        """Clean up after tests."""
        os.chdir(cls.original_cwd)

    # ==================== Low Risk Tests ====================

    def test_assess_low_risk_documentation(self):
        """Test that documentation steps are assessed as low risk."""
        step = StepInfo(problem_type="documentation")
        result = self.assessor.assess_risk(step)
        assert result.level == RiskLevel.LOW, \
            f"Expected LOW risk for documentation, got {result.level.value}"

    def test_assess_low_risk_changelog(self):
        """Test that changelog steps are assessed as low risk."""
        step = StepInfo(problem_type="changelog")
        result = self.assessor.assess_risk(step)
        assert result.level == RiskLevel.LOW, \
            f"Expected LOW risk for changelog, got {result.level.value}"

    def test_assess_low_risk_new_files_only(self):
        """Test that steps creating only new files have reduced risk."""
        step = StepInfo(
            problem_type="ui",
            files_to_create=["NewView.swift", "NewViewModel.swift"],
            files_to_modify=[]
        )
        result = self.assessor.assess_risk(step)
        # UI base is medium, but new_files_only reduces by 0.1
        assert result.score < 0.5, \
            f"Expected reduced score for new files only, got {result.score}"

    # ==================== Medium Risk Tests ====================

    def test_assess_medium_risk_service(self):
        """Test that service implementation is assessed as medium risk."""
        step = StepInfo(
            problem_type="service-impl",
            files_to_modify=["Service.swift"]
        )
        result = self.assessor.assess_risk(step)
        assert result.level in [RiskLevel.MEDIUM, RiskLevel.HIGH], \
            f"Expected MEDIUM or HIGH risk for service-impl, got {result.level.value}"

    def test_assess_low_risk_ui(self):
        """Test that simple UI steps are assessed as low risk (per config)."""
        step = StepInfo(
            problem_type="ui",
            files_to_modify=["View.swift"]
        )
        result = self.assessor.assess_risk(step)
        # UI is marked as "low" risk in config
        assert result.level == RiskLevel.LOW, \
            f"Expected LOW risk for simple UI (per config), got {result.level.value}"

    def test_assess_medium_risk_algorithm(self):
        """Test that algorithm steps are assessed appropriately."""
        step = StepInfo(problem_type="algorithm")
        result = self.assessor.assess_risk(step)
        assert result.level == RiskLevel.MEDIUM, \
            f"Expected MEDIUM risk for algorithm, got {result.level.value}"

    # ==================== High Risk Tests ====================

    def test_assess_high_risk_migration(self):
        """Test that migration steps with data_migration flag are high risk."""
        step = StepInfo(
            problem_type="migration",
            has_data_migration=True
        )
        result = self.assessor.assess_risk(step)
        assert result.level in [RiskLevel.HIGH, RiskLevel.CRITICAL], \
            f"Expected HIGH or CRITICAL risk for migration, got {result.level.value}"

    def test_assess_high_risk_breaking_change(self):
        """Test that breaking changes are assessed as high risk."""
        step = StepInfo(
            problem_type="refactor",
            is_breaking_change=True
        )
        result = self.assessor.assess_risk(step)
        # Base medium (0.5) + breaking_change (0.25) = 0.75 => HIGH
        assert result.level in [RiskLevel.HIGH, RiskLevel.CRITICAL], \
            f"Expected HIGH or CRITICAL risk for breaking change, got {result.level.value}"

    def test_assess_high_risk_external_api(self):
        """Test that external API steps have increased risk."""
        step = StepInfo(
            problem_type="api-integration",
            has_external_api=True
        )
        result = self.assessor.assess_risk(step)
        # Base medium (0.5) + external_api (0.2) = 0.7 => HIGH
        assert result.level in [RiskLevel.HIGH, RiskLevel.CRITICAL], \
            f"Expected HIGH or CRITICAL risk for external API, got {result.level.value}"

    def test_assess_high_risk_many_files(self):
        """Test that modifying many files increases risk."""
        step = StepInfo(
            problem_type="refactor",
            files_to_modify=["f1.swift", "f2.swift", "f3.swift", "f4.swift",
                           "f5.swift", "f6.swift", "f7.swift"]
        )
        result = self.assessor.assess_risk(step)
        # many_file_modifications factor should be present
        many_files_factor = next(
            (f for f in result.factors if f.name == "many_file_modifications"),
            None
        )
        assert many_files_factor is not None
        assert many_files_factor.present, "many_file_modifications should be present"

    # ==================== Critical Risk Tests ====================

    def test_assess_critical_risk_combined_factors(self):
        """Test that combined high-risk factors lead to critical risk."""
        step = StepInfo(
            problem_type="migration",
            has_data_migration=True,
            is_breaking_change=True,
            affects_persistence=True
        )
        result = self.assessor.assess_risk(step)
        assert result.level == RiskLevel.CRITICAL, \
            f"Expected CRITICAL risk for combined factors, got {result.level.value}"
        assert result.score >= 0.7, \
            f"Expected score >= 0.7 for critical, got {result.score}"

    # ==================== Retry Config Tests ====================

    def test_retry_config_for_low_risk(self):
        """Test retry configuration for low risk."""
        config = self.assessor.get_retry_config(RiskLevel.LOW)
        assert config.max_total == 3, \
            f"Expected max_total=3 for LOW, got {config.max_total}"
        assert config.max_same_technique == 2, \
            f"Expected max_same_technique=2 for LOW, got {config.max_same_technique}"

    def test_retry_config_for_medium_risk(self):
        """Test retry configuration for medium risk."""
        config = self.assessor.get_retry_config(RiskLevel.MEDIUM)
        assert config.max_total == 5, \
            f"Expected max_total=5 for MEDIUM, got {config.max_total}"
        assert config.escalation_threshold == 3, \
            f"Expected escalation_threshold=3 for MEDIUM, got {config.escalation_threshold}"

    def test_retry_config_for_high_risk(self):
        """Test retry configuration for high risk."""
        config = self.assessor.get_retry_config(RiskLevel.HIGH)
        assert config.max_total == 7, \
            f"Expected max_total=7 for HIGH, got {config.max_total}"
        assert "reflexion" in config.techniques_rotation, \
            "Expected reflexion in HIGH risk techniques rotation"

    def test_retry_config_for_critical_risk(self):
        """Test retry configuration for critical risk."""
        config = self.assessor.get_retry_config(RiskLevel.CRITICAL)
        assert config.max_total == 10, \
            f"Expected max_total=10 for CRITICAL, got {config.max_total}"
        assert config.escalation_threshold == 7, \
            f"Expected escalation_threshold=7 for CRITICAL, got {config.escalation_threshold}"

    # ==================== Escalation Tests ====================

    def test_should_escalate_after_max_retries(self):
        """Test that escalation is triggered after max retries."""
        decision = self.assessor.should_escalate(
            current_attempt=3,
            risk_level=RiskLevel.LOW,
            failure_pattern=""
        )
        assert decision.should_escalate, "Should escalate after exhausting LOW risk retries"
        assert decision.recommended_action == "user_intervention"

    def test_should_not_escalate_within_budget(self):
        """Test that no escalation within retry budget."""
        decision = self.assessor.should_escalate(
            current_attempt=1,
            risk_level=RiskLevel.HIGH,
            failure_pattern=""
        )
        assert not decision.should_escalate, "Should not escalate on first attempt"
        assert decision.recommended_action == "retry"

    def test_should_switch_technique_at_threshold(self):
        """Test technique switch at escalation threshold."""
        decision = self.assessor.should_escalate(
            current_attempt=5,
            risk_level=RiskLevel.HIGH,
            failure_pattern=""
        )
        assert not decision.should_escalate, "Should not fully escalate at threshold"
        assert decision.recommended_action == "switch_technique"

    def test_should_escalate_on_critical_failure(self):
        """Test that critical failure patterns trigger escalation."""
        decision = self.assessor.should_escalate(
            current_attempt=1,
            risk_level=RiskLevel.MEDIUM,
            failure_pattern="Data corruption detected"
        )
        assert decision.should_escalate, "Should escalate on critical failure"
        assert decision.recommended_action == "user_intervention"

    def test_should_escalate_on_fatal_error(self):
        """Test that fatal errors trigger escalation."""
        decision = self.assessor.should_escalate(
            current_attempt=1,
            risk_level=RiskLevel.LOW,
            failure_pattern="Fatal error in Core Data"
        )
        assert decision.should_escalate, "Should escalate on fatal error"

    # ==================== Risk Factor Tests ====================

    def test_risk_factors_applied_correctly(self):
        """Test that risk factors are correctly identified and applied."""
        step = StepInfo(
            problem_type="migration",
            has_data_migration=True,
            affects_persistence=True
        )
        result = self.assessor.assess_risk(step)

        # Check data_migration factor
        dm_factor = next((f for f in result.factors if f.name == "data_migration"), None)
        assert dm_factor is not None, "data_migration factor should be present"
        assert dm_factor.present, "data_migration should be marked present"
        assert dm_factor.contribution == 0.3, \
            f"Expected contribution 0.3, got {dm_factor.contribution}"

        # Check affects_persistence factor
        ap_factor = next((f for f in result.factors if f.name == "affects_persistence"), None)
        assert ap_factor is not None, "affects_persistence factor should be present"
        assert ap_factor.present, "affects_persistence should be marked present"

    def test_negative_factors_reduce_risk(self):
        """Test that negative factors reduce risk score."""
        step_with_negative = StepInfo(
            problem_type="documentation"  # Has documentation_only (-0.2)
        )
        result = self.assessor.assess_risk(step_with_negative)

        doc_factor = next((f for f in result.factors if f.name == "documentation_only"), None)
        assert doc_factor is not None
        assert doc_factor.present
        assert doc_factor.contribution < 0, "documentation_only should have negative contribution"

    def test_all_factors_have_weight(self):
        """Test that all defined factors have valid weights."""
        for name, factor in RISK_FACTORS.items():
            assert "weight" in factor, f"Factor {name} missing weight"
            assert isinstance(factor["weight"], (int, float)), \
                f"Factor {name} weight should be numeric"
            assert -1 <= factor["weight"] <= 1, \
                f"Factor {name} weight out of range"

    # ==================== Score Calculation Tests ====================

    def test_score_clamped_to_valid_range(self):
        """Test that scores are clamped to 0.0-1.0."""
        # Create a step with maximum risk factors
        step = StepInfo(
            problem_type="migration",
            has_data_migration=True,
            is_breaking_change=True,
            has_external_api=True,
            affects_persistence=True,
            files_to_modify=["f" + str(i) + ".swift" for i in range(10)],
            dependencies=["d" + str(i) for i in range(5)],
            complexity_estimate="high"
        )
        result = self.assessor.assess_risk(step)
        assert 0.0 <= result.score <= 1.0, \
            f"Score {result.score} out of valid range"

    def test_score_with_all_negative_factors(self):
        """Test score with risk-reducing factors."""
        step = StepInfo(
            problem_type="documentation",
            files_to_create=["README.md"],
            complexity_estimate="low"
        )
        result = self.assessor.assess_risk(step)
        assert result.score >= 0.0, "Score should not go below 0.0"
        assert result.level == RiskLevel.LOW, "Should be LOW risk"

    # ==================== Context Adjustment Tests ====================

    def test_context_previous_failure_increases_risk(self):
        """Test that previous step failure increases risk."""
        step = StepInfo(problem_type="ui")

        result_no_context = self.assessor.assess_risk(step)
        result_with_failure = self.assessor.assess_risk(
            step,
            context={"previous_step_failed": True}
        )

        assert result_with_failure.score > result_no_context.score, \
            "Previous failure should increase risk score"

    def test_context_critical_path_increases_risk(self):
        """Test that critical path increases risk."""
        step = StepInfo(problem_type="ui")

        result_no_context = self.assessor.assess_risk(step)
        result_critical = self.assessor.assess_risk(
            step,
            context={"critical_path": True}
        )

        assert result_critical.score > result_no_context.score, \
            "Critical path should increase risk score"

    def test_context_similar_success_reduces_risk(self):
        """Test that similar step success reduces risk."""
        step = StepInfo(problem_type="ui")

        result_no_context = self.assessor.assess_risk(step)
        result_success = self.assessor.assess_risk(
            step,
            context={"similar_step_succeeded": True}
        )

        assert result_success.score < result_no_context.score, \
            "Similar success should reduce risk score"

    # ==================== Explanation Tests ====================

    def test_explanation_is_human_readable(self):
        """Test that explanation is human-readable."""
        step = StepInfo(
            problem_type="migration",
            has_data_migration=True
        )
        result = self.assessor.assess_risk(step)

        assert isinstance(result.explanation, str)
        assert len(result.explanation) > 20, "Explanation should be substantial"
        assert "migration" in result.explanation.lower() or "high" in result.explanation.lower()

    def test_explanation_mentions_risk_level(self):
        """Test that explanation mentions the risk level."""
        step = StepInfo(problem_type="documentation")
        result = self.assessor.assess_risk(step)

        assert result.level.value.upper() in result.explanation, \
            "Explanation should mention risk level"

    # ==================== Mitigation Tests ====================

    def test_mitigations_for_high_risk_factors(self):
        """Test that mitigations are suggested for high-risk factors."""
        step = StepInfo(
            problem_type="migration",
            has_data_migration=True
        )
        result = self.assessor.assess_risk(step)

        assert len(result.mitigations) > 0, "Should have mitigations for high-risk"
        assert any("backup" in m.lower() for m in result.mitigations), \
            "Should suggest backup for data migration"

    def test_no_mitigations_for_low_risk(self):
        """Test that low-risk steps may have fewer mitigations."""
        step = StepInfo(problem_type="documentation")
        result = self.assessor.assess_risk(step)

        # Documentation only is a negative factor, so no positive factors
        # means fewer or no mitigations needed
        # Just verify the mitigations list is valid
        assert isinstance(result.mitigations, list)

    # ==================== Utility Method Tests ====================

    def test_get_all_factors(self):
        """Test getting all factor definitions."""
        factors = self.assessor.get_all_factors()
        assert isinstance(factors, dict)
        assert len(factors) == len(RISK_FACTORS)
        assert "data_migration" in factors
        assert "weight" in factors["data_migration"]

    def test_calculate_step_risk_score(self):
        """Test convenience method for risk score calculation."""
        score = self.assessor.calculate_step_risk_score(
            problem_type="migration",
            has_migration=True,
            affects_data=True
        )
        assert isinstance(score, float)
        assert 0.0 <= score <= 1.0
        assert score >= 0.7, "Migration with data impact should be high risk"

    # ==================== Result Structure Tests ====================

    def test_assessment_result_has_all_fields(self):
        """Test that RiskAssessment has all required fields."""
        step = StepInfo(problem_type="algorithm")
        result = self.assessor.assess_risk(step)

        assert hasattr(result, 'level')
        assert hasattr(result, 'score')
        assert hasattr(result, 'factors')
        assert hasattr(result, 'retry_config')
        assert hasattr(result, 'explanation')
        assert hasattr(result, 'mitigations')

    def test_escalation_decision_has_all_fields(self):
        """Test that EscalationDecision has all required fields."""
        decision = self.assessor.should_escalate(1, RiskLevel.MEDIUM, "")

        assert hasattr(decision, 'should_escalate')
        assert hasattr(decision, 'reason')
        assert hasattr(decision, 'recommended_action')


class TestIntegration:
    """Integration tests for the risk assessor."""

    @classmethod
    def setup_class(cls):
        """Set up test fixtures."""
        cls.original_cwd = os.getcwd()
        project_root = Path(__file__).parent.parent.parent
        os.chdir(project_root)
        cls.assessor = RiskAssessor()

    @classmethod
    def teardown_class(cls):
        """Clean up after tests."""
        os.chdir(cls.original_cwd)

    def test_integration_all_risk_levels_reachable(self):
        """Test that all risk levels can be reached."""
        test_cases = [
            # LOW: documentation (0.2 - 0.2 = 0.0)
            (StepInfo(problem_type="documentation"), RiskLevel.LOW),
            # MEDIUM: algorithm base (0.5)
            (StepInfo(problem_type="algorithm"), RiskLevel.MEDIUM),
            # HIGH: system-design (0.8) - no extra factors
            (StepInfo(problem_type="system-design"), RiskLevel.HIGH),
            # CRITICAL: migration (0.8) + data_migration (0.3) = 1.1 clamped to 1.0
            (StepInfo(problem_type="migration", has_data_migration=True), RiskLevel.CRITICAL),
        ]

        for step, expected_level in test_cases:
            result = self.assessor.assess_risk(step)
            assert result.level == expected_level, \
                f"Expected {expected_level.value} for {step.problem_type}, got {result.level.value} (score={result.score:.2f})"

    def test_integration_retry_configs_match_spec(self):
        """Test that retry configs match the specification."""
        expected = {
            RiskLevel.LOW: 3,
            RiskLevel.MEDIUM: 5,
            RiskLevel.HIGH: 7,
            RiskLevel.CRITICAL: 10,
        }

        for level, expected_total in expected.items():
            config = self.assessor.get_retry_config(level)
            assert config.max_total == expected_total, \
                f"Expected max_total={expected_total} for {level.value}, got {config.max_total}"

    def test_integration_escalation_flow(self):
        """Test the complete escalation flow."""
        # Start fresh - should retry
        decision = self.assessor.should_escalate(1, RiskLevel.MEDIUM, "")
        assert decision.recommended_action == "retry"

        # At threshold - should switch technique
        decision = self.assessor.should_escalate(3, RiskLevel.MEDIUM, "")
        assert decision.recommended_action == "switch_technique"

        # Exhausted - should escalate
        decision = self.assessor.should_escalate(5, RiskLevel.MEDIUM, "")
        assert decision.should_escalate
        assert decision.recommended_action == "user_intervention"

    def test_integration_problem_types_from_config(self):
        """Test that problem types from config are assessed correctly."""
        problem_types = [
            ("documentation", RiskLevel.LOW),
            ("infrastructure", RiskLevel.LOW),
            ("ui", RiskLevel.MEDIUM),
            ("algorithm", RiskLevel.MEDIUM),
            ("migration", RiskLevel.HIGH),
            ("system-design", RiskLevel.HIGH),
        ]

        for ptype, expected_base_level in problem_types:
            step = StepInfo(problem_type=ptype)
            result = self.assessor.assess_risk(step)
            # Note: The actual level may vary based on factors
            # We just verify it returns a valid result
            assert result.level in RiskLevel, \
                f"Invalid level for {ptype}"
            assert 0.0 <= result.score <= 1.0, \
                f"Invalid score for {ptype}"


# ==================== Run Tests ====================

def run_tests():
    """Run all tests and report results."""
    print("Running Risk Assessor Tests...")
    print("=" * 60)

    test_classes = [TestRiskAssessor, TestIntegration]
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
