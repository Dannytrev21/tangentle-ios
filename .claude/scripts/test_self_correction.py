"""
Unit tests for the Self-Correction Engine.

Tests cover:
- Memory bank operations
- Failure analysis
- Technique rotation
- Retry decisions
- Escalation logic
- State persistence
"""

import unittest
import json
from datetime import datetime

from memory_bank import MemoryBank, MemoryBankEntry, create_entry_from_failure
from self_correction import (
    SelfCorrectionEngine,
    FailureInfo,
    RetryDecision,
    TECHNIQUE_ALTERNATIVES,
    FAILURE_PATTERN_TECHNIQUES
)
from risk_assessor import StepInfo, RiskLevel


class TestMemoryBankEntry(unittest.TestCase):
    """Tests for MemoryBankEntry dataclass."""

    def test_create_entry(self):
        """Test creating a basic entry."""
        entry = MemoryBankEntry(
            timestamp="2026-01-01T10:00:00",
            failure_summary="Test failure",
            root_cause="Bad logic",
            lesson_learned="Fix the logic",
            technique_used="tdd",
            applicable_to=["general"]
        )
        self.assertEqual(entry.failure_summary, "Test failure")
        self.assertEqual(entry.technique_used, "tdd")
        self.assertIn("general", entry.applicable_to)

    def test_to_dict(self):
        """Test serialization to dictionary."""
        entry = MemoryBankEntry(
            timestamp="2026-01-01T10:00:00",
            failure_summary="Test",
            root_cause="Cause",
            lesson_learned="Lesson",
            technique_used="reflexion",
            applicable_to=["data-access"]
        )
        d = entry.to_dict()
        self.assertEqual(d["timestamp"], "2026-01-01T10:00:00")
        self.assertEqual(d["technique_used"], "reflexion")
        self.assertEqual(d["applicable_to"], ["data-access"])

    def test_from_dict(self):
        """Test deserialization from dictionary."""
        d = {
            "timestamp": "2026-01-01T10:00:00",
            "failure_summary": "Summary",
            "root_cause": "Cause",
            "lesson_learned": "Lesson",
            "technique_used": "tdd",
            "applicable_to": ["unit-test"]
        }
        entry = MemoryBankEntry.from_dict(d)
        self.assertEqual(entry.failure_summary, "Summary")
        self.assertEqual(entry.technique_used, "tdd")


class TestMemoryBank(unittest.TestCase):
    """Tests for MemoryBank class."""

    def test_empty_bank(self):
        """Test empty memory bank."""
        bank = MemoryBank()
        self.assertEqual(len(bank), 0)
        self.assertFalse(bank)
        self.assertEqual(bank.get_all_lessons(), [])

    def test_add_entry(self):
        """Test adding entries."""
        bank = MemoryBank()
        entry = MemoryBankEntry(
            timestamp="2026-01-01",
            failure_summary="Fail",
            root_cause="Cause",
            lesson_learned="Lesson 1",
            technique_used="tdd",
            applicable_to=["general"]
        )
        bank.add_entry(entry)
        self.assertEqual(len(bank), 1)
        self.assertTrue(bank)

    def test_max_size_eviction(self):
        """Test FIFO eviction when max size exceeded."""
        bank = MemoryBank(max_size=3)

        for i in range(5):
            entry = MemoryBankEntry(
                timestamp=f"2026-01-0{i+1}",
                failure_summary=f"Fail {i+1}",
                root_cause="Cause",
                lesson_learned=f"Lesson {i+1}",
                technique_used="tdd",
                applicable_to=["general"]
            )
            bank.add_entry(entry)

        # Should only have last 3 entries
        self.assertEqual(len(bank), 3)
        lessons = bank.get_all_lessons()
        self.assertEqual(lessons, ["Lesson 3", "Lesson 4", "Lesson 5"])

    def test_get_relevant_lessons(self):
        """Test filtering lessons by step type."""
        bank = MemoryBank()

        bank.add_entry(MemoryBankEntry(
            timestamp="2026-01-01",
            failure_summary="Fail 1",
            root_cause="Cause",
            lesson_learned="General lesson",
            technique_used="tdd",
            applicable_to=["general"]
        ))
        bank.add_entry(MemoryBankEntry(
            timestamp="2026-01-02",
            failure_summary="Fail 2",
            root_cause="Cause",
            lesson_learned="Data lesson",
            technique_used="tdd",
            applicable_to=["data-access"]
        ))
        bank.add_entry(MemoryBankEntry(
            timestamp="2026-01-03",
            failure_summary="Fail 3",
            root_cause="Cause",
            lesson_learned="UI lesson",
            technique_used="tdd",
            applicable_to=["ui"]
        ))

        # Should get general + data-access lessons
        data_lessons = bank.get_relevant_lessons("data-access")
        self.assertIn("General lesson", data_lessons)
        self.assertIn("Data lesson", data_lessons)
        self.assertNotIn("UI lesson", data_lessons)

    def test_to_prompt_context(self):
        """Test formatting for prompt injection."""
        bank = MemoryBank()
        bank.add_entry(MemoryBankEntry(
            timestamp="2026-01-01",
            failure_summary="Test failed",
            root_cause="Logic error",
            lesson_learned="Check assertions",
            technique_used="tdd",
            applicable_to=["general"]
        ))

        context = bank.to_prompt_context()
        self.assertIn("Memory Bank", context)
        self.assertIn("Lesson 1", context)
        self.assertIn("Test failed", context)
        self.assertIn("Check assertions", context)

    def test_to_prompt_context_empty(self):
        """Test prompt context for empty bank."""
        bank = MemoryBank()
        context = bank.to_prompt_context()
        self.assertIn("No previous lessons", context)

    def test_json_serialization(self):
        """Test JSON round-trip serialization."""
        bank = MemoryBank(max_size=5)
        bank.add_entry(MemoryBankEntry(
            timestamp="2026-01-01",
            failure_summary="Fail",
            root_cause="Cause",
            lesson_learned="Lesson",
            technique_used="reflexion",
            applicable_to=["api-integration"]
        ))

        # Serialize
        data = bank.to_json()
        self.assertEqual(data["max_size"], 5)
        self.assertEqual(len(data["entries"]), 1)

        # Deserialize
        restored = MemoryBank.from_json(data)
        self.assertEqual(len(restored), 1)
        self.assertEqual(restored.entries[0].lesson_learned, "Lesson")

    def test_clear(self):
        """Test clearing the bank."""
        bank = MemoryBank()
        bank.add_entry(MemoryBankEntry(
            timestamp="2026-01-01",
            failure_summary="Fail",
            root_cause="Cause",
            lesson_learned="Lesson",
            technique_used="tdd",
            applicable_to=["general"]
        ))
        self.assertEqual(len(bank), 1)

        bank.clear()
        self.assertEqual(len(bank), 0)


class TestCreateEntryFromFailure(unittest.TestCase):
    """Tests for the convenience function."""

    def test_create_with_defaults(self):
        """Test creating entry with default applicable_to."""
        entry = create_entry_from_failure(
            failure_summary="Fail",
            root_cause="Cause",
            lesson="Lesson",
            technique="tdd"
        )
        self.assertEqual(entry.applicable_to, ["general"])
        self.assertTrue(entry.timestamp)  # Should have timestamp

    def test_create_with_applicable_to(self):
        """Test creating entry with custom applicable_to."""
        entry = create_entry_from_failure(
            failure_summary="Fail",
            root_cause="Cause",
            lesson="Lesson",
            technique="tdd",
            applicable_to=["data-access", "api-integration"]
        )
        self.assertEqual(entry.applicable_to, ["data-access", "api-integration"])


class TestFailureInfo(unittest.TestCase):
    """Tests for FailureInfo dataclass."""

    def test_get_failed_criteria(self):
        """Test getting failed criteria."""
        failure = FailureInfo(
            failure_type="test_failure",
            details="Test details",
            acceptance_criteria={"AC1": True, "AC2": False, "AC3": False},
            attempt_number=1,
            technique_used="tdd",
            phase="verification"
        )
        failed = failure.get_failed_criteria()
        self.assertEqual(set(failed), {"AC2", "AC3"})

    def test_get_passed_criteria(self):
        """Test getting passed criteria."""
        failure = FailureInfo(
            failure_type="test_failure",
            details="Test details",
            acceptance_criteria={"AC1": True, "AC2": False, "AC3": True},
            attempt_number=1,
            technique_used="tdd",
            phase="verification"
        )
        passed = failure.get_passed_criteria()
        self.assertEqual(set(passed), {"AC1", "AC3"})


class TestRetryDecision(unittest.TestCase):
    """Tests for RetryDecision dataclass."""

    def test_should_retry_same(self):
        """Test should_retry for retry_same action."""
        decision = RetryDecision(
            action="retry_same",
            technique="tdd",
            guidance="Try again",
            memory_context="",
            remaining_budget=5
        )
        self.assertTrue(decision.should_retry)
        self.assertFalse(decision.should_escalate)

    def test_should_retry_alternative(self):
        """Test should_retry for retry_alternative action."""
        decision = RetryDecision(
            action="retry_alternative",
            technique="reflexion",
            guidance="Switch technique",
            memory_context="",
            remaining_budget=3
        )
        self.assertTrue(decision.should_retry)
        self.assertFalse(decision.should_escalate)

    def test_should_escalate(self):
        """Test should_escalate for escalate action."""
        decision = RetryDecision(
            action="escalate",
            technique="tdd",
            guidance="User intervention needed",
            memory_context="",
            remaining_budget=0
        )
        self.assertFalse(decision.should_retry)
        self.assertTrue(decision.should_escalate)


class TestTechniqueRotation(unittest.TestCase):
    """Tests for technique rotation logic."""

    def test_alternatives_exist(self):
        """Test that all techniques have alternatives."""
        for technique in TECHNIQUE_ALTERNATIVES:
            self.assertGreater(len(TECHNIQUE_ALTERNATIVES[technique]), 0)

    def test_rotate_from_tdd(self):
        """Test rotation from TDD."""
        engine = SelfCorrectionEngine()
        new_technique = engine.rotate_technique("tdd", "generic failure")
        self.assertIn(new_technique, ["reflexion", "self-refine"])

    def test_rotate_pattern_based(self):
        """Test pattern-based technique selection."""
        engine = SelfCorrectionEngine()

        # Edge case pattern should suggest TDD
        new = engine.rotate_technique("reflexion", "missing edge case handling")
        self.assertEqual(new, "tdd")

        # Not converging should suggest self-consistency
        new = engine.rotate_technique("self-refine", "not converging after iterations")
        self.assertEqual(new, "self-consistency")

        # Complex architecture should suggest ToT
        new = engine.rotate_technique("ps-plus", "complex architecture issue")
        self.assertEqual(new, "tot")

    def test_pattern_techniques_mapping(self):
        """Test failure pattern to technique mapping."""
        self.assertEqual(FAILURE_PATTERN_TECHNIQUES["edge case"], "tdd")
        self.assertEqual(FAILURE_PATTERN_TECHNIQUES["not converging"], "self-consistency")
        self.assertEqual(FAILURE_PATTERN_TECHNIQUES["architecture"], "tot")


class TestSelfCorrectionEngine(unittest.TestCase):
    """Tests for SelfCorrectionEngine class."""

    def setUp(self):
        """Set up test fixtures."""
        self.engine = SelfCorrectionEngine()
        self.step = StepInfo(problem_type="service-impl")

    def test_get_memory_bank(self):
        """Test memory bank creation and retrieval."""
        bank1 = self.engine.get_memory_bank("step-1")
        bank2 = self.engine.get_memory_bank("step-1")
        self.assertIs(bank1, bank2)  # Same instance

        bank3 = self.engine.get_memory_bank("step-2")
        self.assertIsNot(bank1, bank3)  # Different instance

    def test_record_failure_nil_handling(self):
        """Test failure analysis for nil/optional issues."""
        failure = FailureInfo(
            failure_type="runtime_error",
            details="Fatal error: Unexpectedly found nil while unwrapping an Optional value",
            acceptance_criteria={"AC1": False},
            attempt_number=1,
            technique_used="tdd",
            phase="verification"
        )
        entry = self.engine.record_failure(self.step, failure)
        self.assertIn("nil", entry.failure_summary.lower())
        self.assertIn("guard", entry.lesson_learned.lower())

    def test_record_failure_async(self):
        """Test failure analysis for async issues."""
        failure = FailureInfo(
            failure_type="runtime_error",
            details="Expression is 'async' but is not marked with 'await'",
            acceptance_criteria={"AC1": False},
            attempt_number=1,
            technique_used="chain-of-code",
            phase="implementation"
        )
        entry = self.engine.record_failure(self.step, failure)
        self.assertIn("async", entry.failure_summary.lower())
        self.assertIn("await", entry.lesson_learned.lower())

    def test_record_failure_test(self):
        """Test failure analysis for test failures."""
        failure = FailureInfo(
            failure_type="test_failure",
            details="XCTAssertEqual failed: expected 5, got 10",
            acceptance_criteria={"AC1": True, "AC2": False},
            attempt_number=1,
            technique_used="tdd",
            phase="verification"
        )
        entry = self.engine.record_failure(self.step, failure)
        self.assertIn("test", entry.failure_summary.lower())
        self.assertIn("spec", entry.lesson_learned.lower())

    def test_record_failure_generic(self):
        """Test failure analysis fallback for unknown patterns."""
        failure = FailureInfo(
            failure_type="unknown",
            details="Something went wrong",
            acceptance_criteria={"AC1": False},
            attempt_number=1,
            technique_used="ps-plus",
            phase="planning"
        )
        entry = self.engine.record_failure(self.step, failure)
        self.assertIn("general", entry.applicable_to)

    def test_should_retry_first_attempt(self):
        """Test retry decision on first attempt."""
        failure = FailureInfo(
            failure_type="test_failure",
            details="Test failed",
            acceptance_criteria={"AC1": False},
            attempt_number=1,
            technique_used="tdd",
            phase="verification"
        )
        decision = self.engine.should_retry(self.step, failure)
        self.assertEqual(decision.action, "retry_same")
        self.assertEqual(decision.technique, "tdd")
        self.assertGreater(decision.remaining_budget, 0)

    def test_should_retry_escalate_on_budget_exhausted(self):
        """Test escalation when budget is exhausted."""
        failure = FailureInfo(
            failure_type="test_failure",
            details="Test failed",
            acceptance_criteria={"AC1": False},
            attempt_number=10,  # Exceeds typical budget
            technique_used="tdd",
            phase="verification"
        )
        decision = self.engine.should_retry(self.step, failure)
        self.assertEqual(decision.action, "escalate")
        self.assertEqual(decision.remaining_budget, 0)

    def test_should_retry_escalate_on_critical_failure(self):
        """Test escalation on critical failure patterns."""
        failure = FailureInfo(
            failure_type="runtime_error",
            details="Data corruption detected in Core Data store",
            acceptance_criteria={"AC1": False},
            attempt_number=1,
            technique_used="tdd",
            phase="implementation"
        )
        decision = self.engine.should_retry(self.step, failure)
        self.assertEqual(decision.action, "escalate")
        self.assertIn("Critical", decision.guidance)

    def test_get_recovery_prompt(self):
        """Test recovery prompt generation."""
        # Add a lesson to the memory bank first
        bank = self.engine.get_memory_bank("test-step")
        bank.add_entry(MemoryBankEntry(
            timestamp="2026-01-01",
            failure_summary="Previous failure",
            root_cause="Root cause",
            lesson_learned="Important lesson",
            technique_used="tdd",
            applicable_to=["general", "service-impl"]
        ))

        step = StepInfo(problem_type="service-impl")
        step.id = "test-step"

        prompt = self.engine.get_recovery_prompt(step, "reflexion")
        self.assertIn("Recovery Attempt", prompt)
        self.assertIn("REFLEXION", prompt)
        self.assertIn("Important lesson", prompt)

    def test_technique_history_tracking(self):
        """Test that technique history is tracked."""
        step = StepInfo(problem_type="algorithm")
        step.id = "history-test"

        failure = FailureInfo(
            failure_type="test_failure",
            details="Test failed",
            acceptance_criteria={"AC1": False},
            attempt_number=1,
            technique_used="tdd",
            phase="verification"
        )

        self.engine.should_retry(step, failure)
        history = self.engine.get_technique_history("history-test")
        self.assertEqual(history, ["tdd"])

    def test_reset_step(self):
        """Test resetting step state."""
        step_id = "reset-test"
        bank = self.engine.get_memory_bank(step_id)
        bank.add_entry(MemoryBankEntry(
            timestamp="2026-01-01",
            failure_summary="Fail",
            root_cause="Cause",
            lesson_learned="Lesson",
            technique_used="tdd",
            applicable_to=["general"]
        ))
        self.engine.technique_history[step_id] = ["tdd", "reflexion"]

        self.engine.reset_step(step_id)

        # Memory bank should be gone
        new_bank = self.engine.get_memory_bank(step_id)
        self.assertEqual(len(new_bank), 0)
        # History should be gone
        self.assertEqual(self.engine.get_technique_history(step_id), [])

    def test_reset_step_preserve_lessons(self):
        """Test resetting step state while preserving lessons."""
        step_id = "preserve-test"
        bank = self.engine.get_memory_bank(step_id)
        bank.add_entry(MemoryBankEntry(
            timestamp="2026-01-01",
            failure_summary="Fail",
            root_cause="Cause",
            lesson_learned="Lesson",
            technique_used="tdd",
            applicable_to=["general"]
        ))
        self.engine.technique_history[step_id] = ["tdd"]

        self.engine.reset_step(step_id, preserve_lessons=True)

        # Memory bank should still exist
        bank = self.engine.get_memory_bank(step_id)
        self.assertEqual(len(bank), 1)
        # History should be gone
        self.assertEqual(self.engine.get_technique_history(step_id), [])

    def test_export_import_state(self):
        """Test state export and import."""
        step_id = "export-test"
        bank = self.engine.get_memory_bank(step_id)
        bank.add_entry(MemoryBankEntry(
            timestamp="2026-01-01",
            failure_summary="Fail",
            root_cause="Cause",
            lesson_learned="Exported lesson",
            technique_used="tdd",
            applicable_to=["general"]
        ))
        self.engine.technique_history[step_id] = ["tdd", "reflexion"]

        # Export
        state = self.engine.export_state(step_id)
        self.assertIn("memory_bank", state)
        self.assertIn("technique_history", state)

        # Create new engine and import
        new_engine = SelfCorrectionEngine()
        new_engine.import_state(step_id, state)

        # Verify imported state
        restored_bank = new_engine.get_memory_bank(step_id)
        self.assertEqual(len(restored_bank), 1)
        self.assertEqual(restored_bank.entries[0].lesson_learned, "Exported lesson")
        self.assertEqual(new_engine.get_technique_history(step_id), ["tdd", "reflexion"])


class TestIntegration(unittest.TestCase):
    """Integration tests for the self-correction system."""

    def test_full_retry_workflow(self):
        """Test a complete retry workflow."""
        engine = SelfCorrectionEngine()
        step = StepInfo(problem_type="api-integration")
        step.id = "integration-test"

        # First failure
        failure1 = FailureInfo(
            failure_type="runtime_error",
            details="async/await issue - not awaited",
            acceptance_criteria={"AC1": False, "AC2": True},
            attempt_number=1,
            technique_used="chain-of-code",
            phase="implementation"
        )

        # Record failure and decide
        engine.record_failure(step, failure1)
        decision1 = engine.should_retry(step, failure1)

        self.assertEqual(decision1.action, "retry_same")
        self.assertEqual(decision1.technique, "chain-of-code")
        self.assertGreater(decision1.remaining_budget, 0)

        # Second failure with same technique
        failure2 = FailureInfo(
            failure_type="runtime_error",
            details="async/await still not working",
            acceptance_criteria={"AC1": False, "AC2": True},
            attempt_number=2,
            technique_used="chain-of-code",
            phase="implementation"
        )

        engine.record_failure(step, failure2)
        decision2 = engine.should_retry(step, failure2)

        # Should still be retry_same (within max_same_technique)
        self.assertIn(decision2.action, ["retry_same", "retry_alternative"])

        # Check memory bank has lessons
        bank = engine.get_memory_bank("integration-test")
        self.assertEqual(len(bank), 2)
        lessons = bank.get_relevant_lessons("api-integration")
        self.assertGreater(len(lessons), 0)

    def test_memory_bank_persistence_workflow(self):
        """Test memory bank persists across engine instances."""
        step_id = "persist-test"

        # First engine adds lessons
        engine1 = SelfCorrectionEngine()
        bank1 = engine1.get_memory_bank(step_id)
        bank1.add_entry(MemoryBankEntry(
            timestamp="2026-01-01",
            failure_summary="Fail 1",
            root_cause="Cause 1",
            lesson_learned="Lesson 1",
            technique_used="tdd",
            applicable_to=["general"]
        ))

        # Export state
        state = engine1.export_state(step_id)

        # Second engine imports state
        engine2 = SelfCorrectionEngine()
        engine2.import_state(step_id, state)

        # Second engine adds more lessons
        bank2 = engine2.get_memory_bank(step_id)
        bank2.add_entry(MemoryBankEntry(
            timestamp="2026-01-02",
            failure_summary="Fail 2",
            root_cause="Cause 2",
            lesson_learned="Lesson 2",
            technique_used="reflexion",
            applicable_to=["general"]
        ))

        # Verify both lessons exist
        self.assertEqual(len(bank2), 2)
        lessons = bank2.get_all_lessons()
        self.assertIn("Lesson 1", lessons)
        self.assertIn("Lesson 2", lessons)


if __name__ == '__main__':
    unittest.main()
