"""
Unit tests for feedback data models.

Tests the dataclasses used for tracking technique effectiveness,
classification history, and implementation attempts.

Run from .claude directory:
    python3 -m pytest tests/test_feedback_models.py -v

Or run directly:
    python3 tests/test_feedback_models.py
"""

import sys
from pathlib import Path

# Add scripts directory to path for direct imports
scripts_dir = Path(__file__).parent.parent / "scripts"
sys.path.insert(0, str(scripts_dir))

from feedback_models import (
    TechniqueStats,
    ClassificationEntry,
    ImplementationAttempt,
    StepAttempts,
    generate_description_hash,
)


class TestTechniqueStats:
    """Tests for TechniqueStats dataclass."""

    def test_create_technique_stats(self):
        """Test creating a TechniqueStats instance."""
        stats = TechniqueStats(
            success=10,
            failure=5,
            total_attempts=20,
            average_attempts_to_success=1.5,
            last_used="2025-01-26T12:00:00Z"
        )
        assert stats.success == 10
        assert stats.failure == 5
        assert stats.total_attempts == 20
        assert stats.average_attempts_to_success == 1.5
        assert stats.last_used == "2025-01-26T12:00:00Z"

    def test_technique_stats_to_dict(self):
        """Test serializing TechniqueStats to dictionary."""
        stats = TechniqueStats(
            success=10,
            failure=5,
            total_attempts=20,
            average_attempts_to_success=1.5,
            last_used="2025-01-26T12:00:00Z"
        )
        d = stats.to_dict()

        assert d["success"] == 10
        assert d["failure"] == 5
        assert d["total_attempts"] == 20
        assert d["average_attempts_to_success"] == 1.5
        assert d["last_used"] == "2025-01-26T12:00:00Z"

    def test_technique_stats_from_dict(self):
        """Test deserializing TechniqueStats from dictionary."""
        data = {
            "success": 10,
            "failure": 5,
            "total_attempts": 20,
            "average_attempts_to_success": 1.5,
            "last_used": "2025-01-26T12:00:00Z"
        }
        stats = TechniqueStats.from_dict(data)

        assert stats.success == 10
        assert stats.failure == 5
        assert stats.total_attempts == 20
        assert stats.average_attempts_to_success == 1.5
        assert stats.last_used == "2025-01-26T12:00:00Z"

    def test_technique_stats_round_trip(self):
        """Test serialization round-trip preserves data."""
        original = TechniqueStats(
            success=10,
            failure=5,
            total_attempts=20,
            average_attempts_to_success=1.5,
            last_used="2025-01-26T12:00:00Z"
        )
        restored = TechniqueStats.from_dict(original.to_dict())
        assert original == restored

    def test_technique_stats_from_dict_missing_keys(self):
        """Test from_dict handles missing keys with defaults."""
        stats = TechniqueStats.from_dict({})

        assert stats.success == 0
        assert stats.failure == 0
        assert stats.total_attempts == 0
        assert stats.average_attempts_to_success == 0.0
        assert stats.last_used == ""


class TestClassificationEntry:
    """Tests for ClassificationEntry dataclass."""

    def test_create_classification_entry(self):
        """Test creating a ClassificationEntry instance."""
        entry = ClassificationEntry(
            id="abc123",
            description="Add unit tests for auth module",
            description_hash="hash123",
            classified_as="unit-test",
            confidence=0.9,
            corrected_to=None,
            correction_confidence=0.0,
            timestamp="2025-01-26T12:00:00Z",
            source="semantic"
        )
        assert entry.id == "abc123"
        assert entry.description == "Add unit tests for auth module"
        assert entry.classified_as == "unit-test"
        assert entry.confidence == 0.9
        assert entry.corrected_to is None
        assert entry.source == "semantic"

    def test_classification_entry_to_dict(self):
        """Test serializing ClassificationEntry to dictionary."""
        entry = ClassificationEntry(
            id="abc123",
            description="Add unit tests for auth module",
            description_hash="hash123",
            classified_as="unit-test",
            confidence=0.9,
            corrected_to="integration-test",
            correction_confidence=0.95,
            timestamp="2025-01-26T12:00:00Z",
            source="semantic"
        )
        d = entry.to_dict()

        assert d["id"] == "abc123"
        assert d["description"] == "Add unit tests for auth module"
        assert d["description_hash"] == "hash123"
        assert d["classified_as"] == "unit-test"
        assert d["confidence"] == 0.9
        assert d["corrected_to"] == "integration-test"
        assert d["correction_confidence"] == 0.95
        assert d["timestamp"] == "2025-01-26T12:00:00Z"
        assert d["source"] == "semantic"

    def test_classification_entry_from_dict(self):
        """Test deserializing ClassificationEntry from dictionary."""
        data = {
            "id": "abc123",
            "description": "Add unit tests for auth module",
            "description_hash": "hash123",
            "classified_as": "unit-test",
            "confidence": 0.9,
            "corrected_to": None,
            "correction_confidence": 0.0,
            "timestamp": "2025-01-26T12:00:00Z",
            "source": "semantic"
        }
        entry = ClassificationEntry.from_dict(data)

        assert entry.id == "abc123"
        assert entry.description == "Add unit tests for auth module"
        assert entry.corrected_to is None

    def test_classification_entry_round_trip(self):
        """Test serialization round-trip preserves data."""
        original = ClassificationEntry(
            id="abc123",
            description="Add unit tests for auth module",
            description_hash="hash123",
            classified_as="unit-test",
            confidence=0.9,
            corrected_to=None,
            correction_confidence=0.0,
            timestamp="2025-01-26T12:00:00Z",
            source="semantic"
        )
        restored = ClassificationEntry.from_dict(original.to_dict())
        assert original == restored

    def test_classification_entry_with_correction(self):
        """Test entry with correction applied."""
        entry = ClassificationEntry(
            id="abc123",
            description="Add tests",
            description_hash="hash123",
            classified_as="unit-test",
            confidence=0.9,
            corrected_to="integration-test",
            correction_confidence=1.0,
            timestamp="2025-01-26T12:00:00Z",
            source="user"
        )
        d = entry.to_dict()
        restored = ClassificationEntry.from_dict(d)

        assert restored.corrected_to == "integration-test"
        assert restored.correction_confidence == 1.0

    def test_classification_entry_from_dict_missing_keys(self):
        """Test from_dict handles missing keys with defaults."""
        entry = ClassificationEntry.from_dict({"id": "test"})

        assert entry.id == "test"
        assert entry.description == ""
        assert entry.description_hash == ""
        assert entry.classified_as == ""
        assert entry.confidence == 0.0
        assert entry.corrected_to is None
        assert entry.correction_confidence == 0.0
        assert entry.timestamp == ""
        assert entry.source == "unknown"


class TestImplementationAttempt:
    """Tests for ImplementationAttempt dataclass."""

    def test_create_implementation_attempt(self):
        """Test creating an ImplementationAttempt instance."""
        attempt = ImplementationAttempt(
            attempt_number=1,
            technique="tdd",
            method="Write failing test first",
            started_at="2025-01-26T12:00:00Z",
            ended_at="2025-01-26T12:30:00Z",
            duration_seconds=1800,
            error_summary=None,
            success=True
        )
        assert attempt.attempt_number == 1
        assert attempt.technique == "tdd"
        assert attempt.method == "Write failing test first"
        assert attempt.duration_seconds == 1800
        assert attempt.success is True
        assert attempt.error_summary is None

    def test_implementation_attempt_to_dict(self):
        """Test serializing ImplementationAttempt to dictionary."""
        attempt = ImplementationAttempt(
            attempt_number=1,
            technique="tdd",
            method="Write failing test first",
            started_at="2025-01-26T12:00:00Z",
            ended_at="2025-01-26T12:30:00Z",
            duration_seconds=1800,
            error_summary="Test failed",
            success=False
        )
        d = attempt.to_dict()

        assert d["attempt_number"] == 1
        assert d["technique"] == "tdd"
        assert d["error_summary"] == "Test failed"
        assert d["success"] is False

    def test_implementation_attempt_from_dict(self):
        """Test deserializing ImplementationAttempt from dictionary."""
        data = {
            "attempt_number": 1,
            "technique": "tdd",
            "method": "Write failing test first",
            "started_at": "2025-01-26T12:00:00Z",
            "ended_at": "2025-01-26T12:30:00Z",
            "duration_seconds": 1800,
            "error_summary": None,
            "success": True
        }
        attempt = ImplementationAttempt.from_dict(data)

        assert attempt.attempt_number == 1
        assert attempt.technique == "tdd"
        assert attempt.success is True

    def test_implementation_attempt_round_trip(self):
        """Test serialization round-trip preserves data."""
        original = ImplementationAttempt(
            attempt_number=1,
            technique="tdd",
            method="Write failing test first",
            started_at="2025-01-26T12:00:00Z",
            ended_at="2025-01-26T12:30:00Z",
            duration_seconds=1800,
            error_summary=None,
            success=True
        )
        restored = ImplementationAttempt.from_dict(original.to_dict())
        assert original == restored

    def test_implementation_attempt_from_dict_missing_keys(self):
        """Test from_dict handles missing keys with defaults."""
        attempt = ImplementationAttempt.from_dict({})

        assert attempt.attempt_number == 0
        assert attempt.technique == ""
        assert attempt.method == ""
        assert attempt.started_at == ""
        assert attempt.ended_at == ""
        assert attempt.duration_seconds == 0
        assert attempt.error_summary is None
        assert attempt.success is False


class TestStepAttempts:
    """Tests for StepAttempts dataclass."""

    def test_create_step_attempts(self):
        """Test creating a StepAttempts instance."""
        attempt = ImplementationAttempt(
            attempt_number=1,
            technique="tdd",
            method="Test first",
            started_at="2025-01-26T12:00:00Z",
            ended_at="2025-01-26T12:30:00Z",
            duration_seconds=1800,
            error_summary=None,
            success=True
        )
        step = StepAttempts(
            plan_id="007",
            step_id=1,
            problem_type="infrastructure",
            attempts=[attempt],
            total_attempts=1,
            final_success=True,
            techniques_used=["tdd"]
        )
        assert step.plan_id == "007"
        assert step.step_id == 1
        assert step.problem_type == "infrastructure"
        assert len(step.attempts) == 1
        assert step.final_success is True
        assert "tdd" in step.techniques_used

    def test_step_attempts_to_dict(self):
        """Test serializing StepAttempts to dictionary."""
        attempt = ImplementationAttempt(
            attempt_number=1,
            technique="tdd",
            method="Test first",
            started_at="2025-01-26T12:00:00Z",
            ended_at="2025-01-26T12:30:00Z",
            duration_seconds=1800,
            error_summary=None,
            success=True
        )
        step = StepAttempts(
            plan_id="007",
            step_id=1,
            problem_type="infrastructure",
            attempts=[attempt],
            total_attempts=1,
            final_success=True,
            techniques_used=["tdd"]
        )
        d = step.to_dict()

        assert d["plan_id"] == "007"
        assert d["step_id"] == 1
        assert d["problem_type"] == "infrastructure"
        assert len(d["attempts"]) == 1
        assert d["attempts"][0]["technique"] == "tdd"
        assert d["final_success"] is True
        assert d["techniques_used"] == ["tdd"]

    def test_step_attempts_from_dict(self):
        """Test deserializing StepAttempts from dictionary."""
        data = {
            "plan_id": "007",
            "step_id": 1,
            "problem_type": "infrastructure",
            "attempts": [{
                "attempt_number": 1,
                "technique": "tdd",
                "method": "Test first",
                "started_at": "2025-01-26T12:00:00Z",
                "ended_at": "2025-01-26T12:30:00Z",
                "duration_seconds": 1800,
                "error_summary": None,
                "success": True
            }],
            "total_attempts": 1,
            "final_success": True,
            "techniques_used": ["tdd"]
        }
        step = StepAttempts.from_dict(data)

        assert step.plan_id == "007"
        assert step.step_id == 1
        assert len(step.attempts) == 1
        assert step.attempts[0].technique == "tdd"

    def test_step_attempts_round_trip(self):
        """Test serialization round-trip preserves data."""
        attempt = ImplementationAttempt(
            attempt_number=1,
            technique="tdd",
            method="Test first",
            started_at="2025-01-26T12:00:00Z",
            ended_at="2025-01-26T12:30:00Z",
            duration_seconds=1800,
            error_summary=None,
            success=True
        )
        original = StepAttempts(
            plan_id="007",
            step_id=1,
            problem_type="infrastructure",
            attempts=[attempt],
            total_attempts=1,
            final_success=True,
            techniques_used=["tdd"]
        )
        restored = StepAttempts.from_dict(original.to_dict())

        assert original.plan_id == restored.plan_id
        assert original.step_id == restored.step_id
        assert original.problem_type == restored.problem_type
        assert original.total_attempts == restored.total_attempts
        assert original.final_success == restored.final_success
        assert original.techniques_used == restored.techniques_used
        assert len(original.attempts) == len(restored.attempts)

    def test_step_attempts_multiple_attempts(self):
        """Test step with multiple attempts."""
        attempts = [
            ImplementationAttempt(
                attempt_number=1,
                technique="tdd",
                method="Test first",
                started_at="2025-01-26T12:00:00Z",
                ended_at="2025-01-26T12:30:00Z",
                duration_seconds=1800,
                error_summary="Test failed",
                success=False
            ),
            ImplementationAttempt(
                attempt_number=2,
                technique="reflexion",
                method="Learn from failure",
                started_at="2025-01-26T12:30:00Z",
                ended_at="2025-01-26T13:00:00Z",
                duration_seconds=1800,
                error_summary=None,
                success=True
            )
        ]
        step = StepAttempts(
            plan_id="007",
            step_id=1,
            problem_type="debug",
            attempts=attempts,
            total_attempts=2,
            final_success=True,
            techniques_used=["tdd", "reflexion"]
        )

        d = step.to_dict()
        assert len(d["attempts"]) == 2
        assert d["attempts"][0]["success"] is False
        assert d["attempts"][1]["success"] is True

        restored = StepAttempts.from_dict(d)
        assert len(restored.attempts) == 2
        assert restored.techniques_used == ["tdd", "reflexion"]

    def test_step_attempts_from_dict_missing_keys(self):
        """Test from_dict handles missing keys with defaults."""
        step = StepAttempts.from_dict({"plan_id": "007"})

        assert step.plan_id == "007"
        assert step.step_id == 0
        assert step.problem_type == ""
        assert step.attempts == []
        assert step.total_attempts == 0
        assert step.final_success is False
        assert step.techniques_used == []


class TestDescriptionHash:
    """Tests for description hash generation."""

    def test_generate_hash_deterministic(self):
        """Test that hash generation is deterministic."""
        desc = "Add unit tests for auth module"
        hash1 = generate_description_hash(desc)
        hash2 = generate_description_hash(desc)
        assert hash1 == hash2

    def test_generate_hash_different_for_different_inputs(self):
        """Test that different descriptions produce different hashes."""
        hash1 = generate_description_hash("Add unit tests")
        hash2 = generate_description_hash("Fix login bug")
        assert hash1 != hash2

    def test_generate_hash_normalized(self):
        """Test that hash normalizes whitespace and case."""
        # These should produce the same hash
        hash1 = generate_description_hash("add unit tests")
        hash2 = generate_description_hash("ADD  UNIT  TESTS")
        hash3 = generate_description_hash("  add   unit   tests  ")

        assert hash1 == hash2
        assert hash2 == hash3

    def test_generate_hash_is_hex_string(self):
        """Test that hash is a valid hex string."""
        h = generate_description_hash("test description")
        # Should be a hex string (SHA-256 = 64 hex chars)
        assert len(h) == 64
        assert all(c in "0123456789abcdef" for c in h)


if __name__ == "__main__":
    """Run tests when executed directly."""
    import unittest

    # Discover and run tests
    loader = unittest.TestLoader()

    # Create test suites from test classes
    suite = unittest.TestSuite()
    suite.addTests(loader.loadTestsFromTestCase(type(
        'TestTechniqueStatsUnit', (unittest.TestCase,),
        {f"test_{name}": method for name, method in vars(TestTechniqueStats).items() if name.startswith('test_')}
    )))

    # Run a simpler approach - just run each test class
    print("Running feedback_models tests...\n")

    all_passed = True
    test_classes = [
        TestTechniqueStats,
        TestClassificationEntry,
        TestImplementationAttempt,
        TestStepAttempts,
        TestDescriptionHash
    ]

    for test_class in test_classes:
        print(f"\n{test_class.__name__}:")
        instance = test_class()
        for method_name in dir(instance):
            if method_name.startswith('test_'):
                try:
                    getattr(instance, method_name)()
                    print(f"  ✓ {method_name}")
                except AssertionError as e:
                    print(f"  ✗ {method_name}: {e}")
                    all_passed = False
                except Exception as e:
                    print(f"  ✗ {method_name}: {type(e).__name__}: {e}")
                    all_passed = False

    print("\n" + "="*50)
    if all_passed:
        print("All tests passed!")
        exit(0)
    else:
        print("Some tests failed!")
        exit(1)
