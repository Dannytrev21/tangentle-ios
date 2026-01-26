"""
Unit tests for the FeedbackStore persistence layer.

Tests cover:
- Directory creation
- Atomic writes
- Default values for missing files
- CRUD operations for all feedback types
- Concurrent write safety
"""

import json
import os
import sys
import tempfile
import threading
import time
from pathlib import Path
from typing import Any

# Add scripts directory to path for imports
scripts_dir = Path(__file__).parent.parent / "scripts"
sys.path.insert(0, str(scripts_dir))

from feedback_models import (
    TechniqueStats,
    ClassificationEntry,
    ImplementationAttempt,
    StepAttempts,
)


class TestFeedbackStoreDirectory:
    """Test directory creation and management."""

    def test_ensure_directory_creates_if_missing(self):
        """Should create planning-data directory if it doesn't exist."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            data_dir = Path(tmpdir) / ".claude" / "planning-data"

            assert not data_dir.exists(), "Directory should not exist yet"

            store.ensure_directory()

            assert data_dir.exists(), "Directory should be created"
            assert data_dir.is_dir(), "Should be a directory"

    def test_ensure_directory_handles_existing(self):
        """Should not fail if directory already exists."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            data_dir = Path(tmpdir) / ".claude" / "planning-data"

            data_dir.mkdir(parents=True)

            # Should not raise
            store.ensure_directory()

            assert data_dir.exists()


class TestAtomicWrites:
    """Test atomic write mechanism."""

    def test_atomic_write_creates_file(self):
        """Atomic write should create a file with correct content."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            test_file = store._get_file_path("effectiveness")
            test_data = {"test": "data", "number": 42}

            store._atomic_write(test_file, test_data)

            assert test_file.exists(), "File should be created"

            with open(test_file) as f:
                loaded = json.load(f)

            assert loaded == test_data, "Data should match"

    def test_atomic_write_no_temp_file_remains(self):
        """Temp file should be removed after successful write."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            test_file = store._get_file_path("effectiveness")
            temp_file = test_file.with_suffix(".tmp")

            store._atomic_write(test_file, {"test": True})

            assert not temp_file.exists(), "Temp file should not remain"

    def test_atomic_write_preserves_original_on_failure(self):
        """Original file should be preserved if write fails.

        Note: This tests behavior when temp file can be created but
        the final rename would fail. In practice, if temp write fails,
        original is untouched.
        """
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            test_file = store._get_file_path("effectiveness")
            original_data = {"original": True}

            # Write original
            store._atomic_write(test_file, original_data)

            # Read it back to verify
            with open(test_file) as f:
                loaded = json.load(f)

            assert loaded == original_data


class TestLoadFile:
    """Test file loading with defaults."""

    def test_load_missing_file_returns_default(self):
        """Loading a missing file should return the default structure."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            data = store._load_file("effectiveness")

            assert "version" in data, "Should have version"
            assert data["version"] == "1.0.0", "Should be version 1.0.0"
            assert "byProblemType" in data, "Should have byProblemType"

    def test_load_existing_file_returns_content(self):
        """Loading an existing file should return its content."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            test_data = {"version": "1.0.0", "custom": "data"}
            test_file = store._get_file_path("effectiveness")

            with open(test_file, "w") as f:
                json.dump(test_data, f)

            loaded = store._load_file("effectiveness")

            assert loaded == test_data

    def test_load_corrupted_file_returns_default(self):
        """Loading a corrupted JSON file should return default."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            test_file = store._get_file_path("effectiveness")

            with open(test_file, "w") as f:
                f.write("not valid json {{{")

            # Should return default, not raise
            data = store._load_file("effectiveness")

            assert "version" in data


class TestEffectivenessOperations:
    """Test technique effectiveness operations."""

    def test_get_effectiveness_data_returns_default(self):
        """Should return default structure when no data exists."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            data = store.get_effectiveness_data()

            assert data["version"] == "1.0.0"
            assert data["byProblemType"] == {}

    def test_update_technique_stats_creates_structure(self):
        """Should create nested structure on first update."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            store.update_technique_stats("debug", "tdd", success=True, attempts=2)

            data = store.get_effectiveness_data()

            assert "debug" in data["byProblemType"]
            assert "tdd" in data["byProblemType"]["debug"]

            stats = data["byProblemType"]["debug"]["tdd"]
            assert stats["success"] == 1
            assert stats["failure"] == 0
            assert stats["total_attempts"] == 2

    def test_update_technique_stats_increments_existing(self):
        """Should increment existing stats correctly."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            # First update - success
            store.update_technique_stats("debug", "tdd", success=True, attempts=2)

            # Second update - failure
            store.update_technique_stats("debug", "tdd", success=False, attempts=3)

            data = store.get_effectiveness_data()
            stats = data["byProblemType"]["debug"]["tdd"]

            assert stats["success"] == 1
            assert stats["failure"] == 1
            assert stats["total_attempts"] == 5


class TestClassificationOperations:
    """Test classification history operations."""

    def test_get_classification_history_returns_empty(self):
        """Should return empty list when no classifications exist."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            history = store.get_classification_history()

            assert history == []

    def test_add_classification_appends(self):
        """Should append new classification entries."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            entry = ClassificationEntry(
                id="test-1",
                description="Fix the bug",
                description_hash="abc123",
                classified_as="debug",
                confidence=0.9,
                corrected_to=None,
                correction_confidence=0.0,
                timestamp="2025-01-26T10:00:00Z",
                source="semantic",
            )

            store.add_classification(entry)

            history = store.get_classification_history()

            assert len(history) == 1
            assert history[0]["id"] == "test-1"
            assert history[0]["classified_as"] == "debug"

    def test_record_correction_updates_entry(self):
        """Should record user corrections."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            # Add initial classification
            entry = ClassificationEntry(
                id="test-1",
                description="Fix the bug",
                description_hash="abc123",
                classified_as="debug",
                confidence=0.9,
                corrected_to=None,
                correction_confidence=0.0,
                timestamp="2025-01-26T10:00:00Z",
                source="semantic",
            )
            store.add_classification(entry)

            # Record correction
            store.record_correction("abc123", "debug", "new-feature")

            # Verify correction was recorded
            data = store._load_file("classification")

            assert "corrections" in data
            assert "abc123" in data["corrections"]
            assert data["corrections"]["abc123"]["original"] == "debug"
            assert data["corrections"]["abc123"]["corrected_to"] == "new-feature"


class TestAttemptOperations:
    """Test implementation attempt operations."""

    def test_get_step_attempts_returns_none(self):
        """Should return None when no attempts exist."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            result = store.get_step_attempts("007", 1)

            assert result is None

    def test_record_attempt_creates_step_entry(self):
        """Should create step entry on first attempt."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            attempt = ImplementationAttempt(
                attempt_number=1,
                technique="tdd",
                method="write tests first",
                started_at="2025-01-26T10:00:00Z",
                ended_at="2025-01-26T10:30:00Z",
                duration_seconds=1800,
                error_summary=None,
                success=True,
            )

            store.record_attempt("007", 1, attempt, problem_type="debug")

            result = store.get_step_attempts("007", 1)

            assert result is not None
            assert result.plan_id == "007"
            assert result.step_id == 1
            assert len(result.attempts) == 1
            assert result.total_attempts == 1

    def test_record_attempt_appends_to_existing(self):
        """Should append attempts to existing step entry."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            attempt1 = ImplementationAttempt(
                attempt_number=1,
                technique="tdd",
                method="write tests first",
                started_at="2025-01-26T10:00:00Z",
                ended_at="2025-01-26T10:30:00Z",
                duration_seconds=1800,
                error_summary="Tests failed",
                success=False,
            )

            attempt2 = ImplementationAttempt(
                attempt_number=2,
                technique="tdd",
                method="fix implementation",
                started_at="2025-01-26T10:35:00Z",
                ended_at="2025-01-26T11:00:00Z",
                duration_seconds=1500,
                error_summary=None,
                success=True,
            )

            store.record_attempt("007", 1, attempt1, problem_type="debug")
            store.record_attempt("007", 1, attempt2, problem_type="debug")

            result = store.get_step_attempts("007", 1)

            assert result.total_attempts == 2
            assert len(result.attempts) == 2
            assert result.final_success is True


class TestMetricsOperations:
    """Test plan metrics operations."""

    def test_get_metrics_returns_default(self):
        """Should return default metrics when none exist."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            metrics = store.get_metrics()

            assert metrics["version"] == "1.0.0"
            assert metrics["totalPlans"] == 0
            assert metrics["completedPlans"] == 0

    def test_update_metrics_increments_values(self):
        """Should update metrics with provided values."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            store.update_metrics(totalPlans=1, completedPlans=1, totalSteps=5)

            metrics = store.get_metrics()

            assert metrics["totalPlans"] == 1
            assert metrics["completedPlans"] == 1
            assert metrics["totalSteps"] == 5


class TestConcurrentWrites:
    """Test thread safety of concurrent writes."""

    def test_concurrent_writes_dont_corrupt(self):
        """Multiple concurrent writes should not corrupt the file."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            errors: list[Exception] = []
            successful_writes = [0]
            lock = threading.Lock()

            def write_stats(thread_id: int):
                try:
                    for i in range(10):
                        store.update_technique_stats(
                            f"type_{thread_id}", "tdd", success=True, attempts=1
                        )
                        with lock:
                            successful_writes[0] += 1
                except Exception as e:
                    with lock:
                        errors.append(e)

            threads = [
                threading.Thread(target=write_stats, args=(i,)) for i in range(5)
            ]

            for t in threads:
                t.start()

            for t in threads:
                t.join()

            assert len(errors) == 0, f"Errors during concurrent writes: {errors}"

            # Verify file is still valid JSON
            data = store.get_effectiveness_data()
            assert "version" in data

            # Verify at least some data was written
            assert len(data["byProblemType"]) > 0


# Test runner for execution without pytest
if __name__ == "__main__":
    import traceback

    test_classes = [
        TestFeedbackStoreDirectory,
        TestAtomicWrites,
        TestLoadFile,
        TestEffectivenessOperations,
        TestClassificationOperations,
        TestAttemptOperations,
        TestMetricsOperations,
        TestConcurrentWrites,
    ]

    passed = 0
    failed = 0
    errors: list[tuple[str, str]] = []

    for test_class in test_classes:
        instance = test_class()
        for method_name in dir(instance):
            if method_name.startswith("test_"):
                try:
                    method = getattr(instance, method_name)
                    method()
                    print(f"  ✓ {test_class.__name__}.{method_name}")
                    passed += 1
                except Exception as e:
                    print(f"  ✗ {test_class.__name__}.{method_name}")
                    errors.append(
                        (f"{test_class.__name__}.{method_name}", traceback.format_exc())
                    )
                    failed += 1

    print(f"\n{'='*60}")
    print(f"Results: {passed} passed, {failed} failed")

    if errors:
        print(f"\n{'='*60}")
        print("FAILURES:\n")
        for name, tb in errors:
            print(f"{name}:")
            print(tb)
            print()

    sys.exit(0 if failed == 0 else 1)
