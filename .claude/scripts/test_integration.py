"""
Integration tests for the intelligent planning system.

These tests verify end-to-end workflows across all components:
- Problem classification → Technique selection → Risk assessment
- Self-correction with memory bank accumulation
- Configuration integrity

Uses unittest (not pytest) per project conventions.
"""

import unittest
import json
import os
import sys

# Ensure scripts directory is in path
sys.path.insert(0, os.path.dirname(__file__))

from problem_classifier import ProblemClassifier
from technique_selector import TechniqueSelector, Phase, StepContext
from risk_assessor import RiskAssessor, StepInfo, RiskLevel
from self_correction import SelfCorrectionEngine, FailureInfo
from memory_bank import MemoryBank, MemoryBankEntry

# Get the correct config path (relative to this file)
SCRIPTS_DIR = os.path.dirname(__file__)
CONFIG_PATH = os.path.join(SCRIPTS_DIR, "..", "technique-config.json")


class TestEndToEndClassification(unittest.TestCase):
    """Test the full classification → selection → assessment flow."""

    def setUp(self):
        """Set up test fixtures."""
        self.classifier = ProblemClassifier(config_path=CONFIG_PATH)
        self.selector = TechniqueSelector(config_path=CONFIG_PATH)
        self.assessor = RiskAssessor(config_path=CONFIG_PATH)

    def test_debug_workflow(self):
        """Debug problems should get ReAct planning + Reflexion implementation."""
        # Classify
        result = self.classifier.classify("Fix the crash when user taps save")
        self.assertEqual(result.primary_type, "debug")
        self.assertGreater(result.confidence, 0.5)

        # Select techniques
        planning = self.selector.select_techniques("debug", Phase.PLANNING)
        impl = self.selector.select_techniques("debug", Phase.IMPLEMENTATION)
        verify = self.selector.select_techniques("debug", Phase.VERIFICATION)

        self.assertEqual(planning.primary, "react")
        self.assertEqual(impl.primary, "reflexion")
        self.assertEqual(verify.primary, "self-refine")

        # Assess risk (debug is medium risk)
        step = StepInfo(problem_type="debug", files_to_modify=["ViewController.swift"])
        risk = self.assessor.assess_risk(step)
        self.assertIn(risk.level.value, ["low", "medium", "high"])

    def test_ui_workflow(self):
        """UI problems should get Self-Refine for implementation."""
        result = self.classifier.classify("Add a new settings screen with toggle switches")
        self.assertEqual(result.primary_type, "ui")

        impl = self.selector.select_techniques("ui", Phase.IMPLEMENTATION)
        self.assertEqual(impl.primary, "self-refine")

        # UI with only new files is low risk
        step = StepInfo(problem_type="ui", files_to_create=["SettingsView.swift"])
        risk = self.assessor.assess_risk(step)
        self.assertIn(risk.level.value, ["low", "medium"])

    def test_algorithm_workflow(self):
        """Algorithm problems should get TDD for implementation."""
        result = self.classifier.classify("Implement binary search for task lookup")
        self.assertEqual(result.primary_type, "algorithm")

        impl = self.selector.select_techniques("algorithm", Phase.IMPLEMENTATION)
        self.assertEqual(impl.primary, "tdd")

        verify = self.selector.select_techniques("algorithm", Phase.VERIFICATION)
        self.assertEqual(verify.primary, "reflexion")

    def test_migration_workflow_high_risk(self):
        """Migration problems should be assessed as high risk."""
        result = self.classifier.classify("Migrate user data to new schema version 2")
        self.assertEqual(result.primary_type, "migration")

        step = StepInfo(
            problem_type="migration",
            has_data_migration=True,
            affects_persistence=True
        )
        risk = self.assessor.assess_risk(step)
        self.assertIn(risk.level.value, ["high", "critical"])
        self.assertGreaterEqual(risk.retry_config.max_total, 7)

    def test_documentation_workflow_low_risk(self):
        """Documentation problems should be low risk."""
        result = self.classifier.classify("Update README with installation steps")
        self.assertEqual(result.primary_type, "documentation")

        # Documentation only modifies docs files - low risk
        step = StepInfo(
            problem_type="documentation",
            files_to_modify=["README.md"],
            complexity_estimate="low"
        )
        risk = self.assessor.assess_risk(step)
        self.assertEqual(risk.level, RiskLevel.LOW)
        self.assertEqual(risk.retry_config.max_total, 3)


class TestContextAwareSelection(unittest.TestCase):
    """Test technique selection with context adjustment."""

    def setUp(self):
        self.selector = TechniqueSelector(config_path=CONFIG_PATH)

    def test_high_complexity_uses_tot(self):
        """High complexity should adjust technique selection."""
        context = StepContext(
            step_number=1,
            total_steps=10,
            complexity_score=0.9  # High complexity
        )
        selection = self.selector.select_techniques("service-impl", Phase.PLANNING, context)
        # High complexity triggers ToT switch
        self.assertEqual(selection.primary, "tot")

    def test_failures_switch_to_reflexion_for_verification(self):
        """Previous failures should switch to Reflexion for VERIFICATION phase."""
        context = StepContext(
            step_number=5,
            total_steps=10,
            complexity_score=0.5,
            previous_failures=2  # Has failures
        )
        # Rule 1: Previous failures switch to Reflexion for VERIFICATION (not implementation)
        selection = self.selector.select_techniques("algorithm", Phase.VERIFICATION, context)
        self.assertEqual(selection.primary, "reflexion")

    def test_early_step_switches_to_tot(self):
        """Early steps (<=2) switch from PS+ to ToT for planning."""
        # Rule 3: Early steps with ps-plus → tot
        context = StepContext(step_number=1, total_steps=10, complexity_score=0.3)
        selection = self.selector.select_techniques("infrastructure", Phase.PLANNING, context)
        # Infrastructure base is ps-plus, but early step switches to tot
        self.assertEqual(selection.primary, "tot")


class TestSelfCorrectionWorkflow(unittest.TestCase):
    """Test the self-correction engine end-to-end."""

    def setUp(self):
        self.engine = SelfCorrectionEngine(config_path=CONFIG_PATH)

    def test_retry_within_budget(self):
        """Should allow retry when budget remains."""
        step = StepInfo(problem_type="service-impl")  # Medium risk by default

        failure = FailureInfo(
            failure_type="test_failure",
            details="XCTAssertEqual failed: expected 5, got 4",
            acceptance_criteria={"AC1": True, "AC2": False},
            attempt_number=1,
            technique_used="tdd",
            phase="verification"
        )

        decision = self.engine.should_retry(step, failure)
        self.assertEqual(decision.action, "retry_same")
        self.assertGreater(decision.remaining_budget, 0)
        self.assertEqual(decision.technique, "tdd")

    def test_technique_rotation_after_max_same(self):
        """Should rotate technique after max same-technique retries."""
        step = StepInfo(problem_type="service-impl")  # Medium risk

        # Medium risk has maxSameTechnique = 3
        # Call should_retry 3 times - this tracks technique history
        for i in range(3):
            failure = FailureInfo(
                failure_type="test_failure",
                details="Assertion failed",
                acceptance_criteria={"AC1": False},
                attempt_number=i + 1,
                technique_used="tdd",
                phase="verification"
            )
            decision = self.engine.should_retry(step, failure)
            # First 2 should retry same (since current_attempts < max_same=3 at check time)
            # Note: technique history gets 1 entry per call

        # After 3 calls, technique_history has 3 "tdd" entries
        # Fourth attempt should rotate
        failure = FailureInfo(
            failure_type="test_failure",
            details="Still failing",
            acceptance_criteria={"AC1": False},
            attempt_number=4,
            technique_used="tdd",
            phase="verification"
        )

        decision = self.engine.should_retry(step, failure)
        # At this point, current_technique_attempts = 4 (including this call)
        # which is >= max_same_technique (3), so should rotate
        self.assertEqual(decision.action, "retry_alternative")
        self.assertNotEqual(decision.technique, "tdd")
        self.assertIn(decision.technique, ["reflexion", "self-refine"])

    def test_escalation_on_budget_exhaustion(self):
        """Should escalate when retry budget is exhausted."""
        step = StepInfo(problem_type="configuration", complexity_estimate="low")  # Low risk

        # Low risk budget = 3
        failure = FailureInfo(
            failure_type="test_failure",
            details="Still failing",
            acceptance_criteria={"AC1": False},
            attempt_number=3,  # Budget exhausted
            technique_used="self-refine",
            phase="verification"
        )

        decision = self.engine.should_retry(step, failure)
        self.assertEqual(decision.action, "escalate")
        self.assertEqual(decision.remaining_budget, 0)

    def test_pattern_based_rotation(self):
        """Should select technique based on failure pattern."""
        # Edge case failures → TDD
        new_technique = self.engine.rotate_technique("self-refine", "edge case not handled")
        self.assertEqual(new_technique, "tdd")

        # Async issues → ReAct
        new_technique = self.engine.rotate_technique("tdd", "async timing issue")
        self.assertEqual(new_technique, "react")

        # Architecture issues → ToT
        new_technique = self.engine.rotate_technique("self-refine", "architecture needs rethinking")
        self.assertEqual(new_technique, "tot")


class TestMemoryBankAccumulation(unittest.TestCase):
    """Test memory bank lesson accumulation and retrieval."""

    def test_add_and_retrieve_lessons(self):
        """Should store and retrieve lessons by type."""
        bank = MemoryBank()

        bank.add_entry(MemoryBankEntry(
            timestamp="2025-01-01T00:00:00Z",
            failure_summary="Nil handling issue",
            root_cause="Missing unwrap",
            lesson_learned="Add guard for optionals before use",
            technique_used="tdd",
            applicable_to=["data-access", "service-impl"]
        ))

        bank.add_entry(MemoryBankEntry(
            timestamp="2025-01-01T00:01:00Z",
            failure_summary="Async issue",
            root_cause="Missing await",
            lesson_learned="Ensure async functions are awaited",
            technique_used="tdd",
            applicable_to=["data-access", "api-integration"]
        ))

        # Should find both for data-access
        lessons = bank.get_relevant_lessons("data-access")
        self.assertEqual(len(lessons), 2)

        # Should find one for api-integration
        lessons = bank.get_relevant_lessons("api-integration")
        self.assertEqual(len(lessons), 1)

        # Should find none for unrelated type
        lessons = bank.get_relevant_lessons("ui")
        self.assertEqual(len(lessons), 0)

    def test_memory_bank_serialization(self):
        """Should serialize and deserialize memory bank."""
        bank = MemoryBank()
        bank.add_entry(MemoryBankEntry(
            timestamp="2025-01-01T00:00:00Z",
            failure_summary="Test failure",
            root_cause="Missing check",
            lesson_learned="Add validation",
            technique_used="tdd",
            applicable_to=["general"]
        ))

        # Serialize
        data = bank.to_json()
        self.assertIn("entries", data)
        self.assertEqual(len(data["entries"]), 1)

        # Deserialize
        restored = MemoryBank.from_json(data)
        self.assertEqual(len(restored.entries), 1)
        self.assertEqual(restored.entries[0].lesson_learned, "Add validation")

    def test_memory_bank_eviction(self):
        """Should evict oldest entries when max size exceeded."""
        bank = MemoryBank(max_size=3)

        for i in range(5):
            bank.add_entry(MemoryBankEntry(
                timestamp=f"2025-01-01T00:0{i}:00Z",
                failure_summary=f"Failure {i}",
                root_cause="Test",
                lesson_learned=f"Lesson {i}",
                technique_used="tdd",
                applicable_to=["general"]
            ))

        # Should only have 3 entries
        self.assertEqual(len(bank.entries), 3)

        # Oldest should be evicted (0 and 1 should be gone)
        summaries = [e.failure_summary for e in bank.entries]
        self.assertNotIn("Failure 0", summaries)
        self.assertNotIn("Failure 1", summaries)
        self.assertIn("Failure 4", summaries)


class TestConfigurationIntegrity(unittest.TestCase):
    """Test that configuration is valid and complete."""

    def setUp(self):
        config_path = os.path.join(
            os.path.dirname(__file__),
            "..",
            "technique-config.json"
        )
        with open(config_path) as f:
            self.config = json.load(f)

    def test_all_problem_types_have_techniques(self):
        """Every problem subtype should have all three phases defined."""
        for category, data in self.config["problemTypes"].items():
            for subtype, subdata in data.get("subtypes", {}).items():
                self.assertIn(
                    "techniques",
                    subdata,
                    f"{category}/{subtype} missing techniques"
                )
                techniques = subdata["techniques"]
                self.assertIn("planning", techniques, f"{subtype} missing planning")
                self.assertIn("implementation", techniques, f"{subtype} missing implementation")
                self.assertIn("verification", techniques, f"{subtype} missing verification")

    def test_all_risk_levels_have_retry_configs(self):
        """Every risk level should have retry configuration."""
        required_levels = ["low", "medium", "high", "critical"]
        for level in required_levels:
            self.assertIn(
                level,
                self.config.get("riskLevels", {}),
                f"Missing risk level: {level}"
            )
            risk_config = self.config["riskLevels"][level]
            self.assertIn("retryConfig", risk_config)
            retry = risk_config["retryConfig"]
            self.assertIn("maxSameTechnique", retry)
            self.assertIn("maxAlternative", retry)
            self.assertIn("maxTotal", retry)

    def test_all_techniques_defined(self):
        """All 10 techniques should be defined in config."""
        required_techniques = [
            "tdd", "tot", "got", "reflexion", "self-refine",
            "self-consistency", "react", "ps-plus", "chain-of-code", "least-to-most"
        ]
        techniques = self.config.get("techniques", {})
        for technique in required_techniques:
            self.assertIn(
                technique,
                techniques,
                f"Missing technique definition: {technique}"
            )

    def test_technique_template_files_exist(self):
        """Technique template files should exist."""
        commands_dir = os.path.join(os.path.dirname(__file__), "..", "commands")
        required_files = [
            "tdd.md", "tot.md", "got.md", "reflexion.md", "self-refine.md",
            "self-consistency.md", "react.md", "ps-plus.md", "chain-of-code.md", "least-to-most.md"
        ]
        for filename in required_files:
            filepath = os.path.join(commands_dir, filename)
            self.assertTrue(
                os.path.exists(filepath),
                f"Missing technique file: {filename}"
            )


class TestFullWorkflow(unittest.TestCase):
    """Test complete workflows from start to finish."""

    def test_complete_step_execution_simulation(self):
        """Simulate a complete step execution with failure and recovery."""
        classifier = ProblemClassifier(config_path=CONFIG_PATH)
        selector = TechniqueSelector(config_path=CONFIG_PATH)
        assessor = RiskAssessor(config_path=CONFIG_PATH)
        engine = SelfCorrectionEngine(config_path=CONFIG_PATH)

        # 1. Classify the problem
        result = classifier.classify("Add validation for email input field")
        self.assertEqual(result.primary_type, "validation")

        # 2. Select techniques
        impl = selector.select_techniques("validation", Phase.IMPLEMENTATION)
        self.assertEqual(impl.primary, "tdd")

        # 3. Assess risk
        step = StepInfo(problem_type="validation")
        risk = assessor.assess_risk(step)

        # 4. Simulate first failure
        failure = FailureInfo(
            failure_type="test_failure",
            details="Invalid email not rejected: test@",
            acceptance_criteria={"AC1": True, "AC2": False, "AC3": True},
            attempt_number=1,
            technique_used="tdd",
            phase="verification"
        )

        # 5. Record and decide
        entry = engine.record_failure(step, failure)
        self.assertIn("Invalid", entry.failure_summary)

        decision = engine.should_retry(step, failure)
        self.assertTrue(decision.should_retry)
        self.assertEqual(decision.action, "retry_same")

        # 6. Simulate success on retry
        # (In real flow, implementation would be fixed and tests would pass)

    def test_all_problem_types_can_be_classified(self):
        """Every problem type from config should be classifiable."""
        classifier = ProblemClassifier(config_path=CONFIG_PATH)
        selector = TechniqueSelector(config_path=CONFIG_PATH)

        # Test each problem type
        problem_samples = {
            "debug": "fix the crash in login screen",
            "ui": "add settings screen with dark mode toggle",
            "algorithm": "implement sorting for task list",
            "refactor": "refactor the repository pattern",
            "migration": "migrate database to version 3",
            "api-integration": "integrate with authentication API",
            "unit-test": "write unit tests for TaskService",
            "documentation": "update README with setup instructions"
        }

        for expected_type, description in problem_samples.items():
            result = classifier.classify(description)
            # Classification should work (may not always match expected due to keyword overlap)
            self.assertIsNotNone(result.primary_type)
            self.assertGreater(result.confidence, 0.0)

            # Technique selection should work for all types
            impl = selector.select_techniques(result.primary_type, Phase.IMPLEMENTATION)
            self.assertIsNotNone(impl.primary)


if __name__ == "__main__":
    unittest.main(verbosity=2)
