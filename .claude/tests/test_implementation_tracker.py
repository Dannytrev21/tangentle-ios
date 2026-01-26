"""
Unit tests for the ImplementationTracker service.

Tests cover:
- Start/end attempt lifecycle
- Time tracking
- Methods to avoid identification
- Technique suggestions
- Summary generation
"""

import sys
import tempfile
import time
from pathlib import Path

# Add scripts directory to path for imports
scripts_dir = Path(__file__).parent.parent / "scripts"
sys.path.insert(0, str(scripts_dir))


class TestStartAttempt:
    """Test starting implementation attempts."""

    def test_start_attempt_returns_attempt_number(self):
        """First attempt should return 1."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            attempt_num = tracker.start_attempt(
                "007", 1, "debug", "tdd", "Write failing test first"
            )

            assert attempt_num == 1

    def test_start_multiple_attempts_increments(self):
        """Each attempt should increment the number."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            num1 = tracker.start_attempt("007", 1, "debug", "tdd", "Method 1")
            tracker.end_attempt("007", 1, False, "Failed")

            num2 = tracker.start_attempt("007", 1, "debug", "tdd", "Method 2")
            tracker.end_attempt("007", 1, False, "Failed again")

            num3 = tracker.start_attempt("007", 1, "debug", "reflexion", "Method 3")

            assert num1 == 1
            assert num2 == 2
            assert num3 == 3


class TestEndAttempt:
    """Test ending implementation attempts."""

    def test_end_attempt_records_duration(self):
        """Duration should be calculated from start to end."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Test first")
            time.sleep(1)  # Wait 1 second
            attempt = tracker.end_attempt("007", 1, True)

            assert attempt is not None
            assert attempt.duration_seconds >= 1

    def test_end_attempt_records_error_on_failure(self):
        """Error summary should be recorded on failure."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Test first")
            attempt = tracker.end_attempt("007", 1, False, "Test framework issue")

            assert attempt.success is False
            assert attempt.error_summary == "Test framework issue"

    def test_end_attempt_returns_none_if_not_started(self):
        """Should return None if no active attempt."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            attempt = tracker.end_attempt("007", 1, True)

            assert attempt is None


class TestGetAttempts:
    """Test retrieving attempts."""

    def test_get_attempts_returns_all(self):
        """Should return all recorded attempts."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Method 1")
            tracker.end_attempt("007", 1, False, "Error 1")

            tracker.start_attempt("007", 1, "debug", "reflexion", "Method 2")
            tracker.end_attempt("007", 1, True)

            attempts = tracker.get_attempts("007", 1)

            assert len(attempts) == 2
            assert attempts[0].technique == "tdd"
            assert attempts[1].technique == "reflexion"

    def test_get_attempts_empty_for_unknown(self):
        """Should return empty list for unknown step."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            attempts = tracker.get_attempts("007", 99)

            assert attempts == []


class TestGetTechniquesUsed:
    """Test tracking techniques used."""

    def test_get_techniques_used_returns_unique(self):
        """Should return unique techniques used."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Method 1")
            tracker.end_attempt("007", 1, False, "Error")

            tracker.start_attempt("007", 1, "debug", "tdd", "Method 2")
            tracker.end_attempt("007", 1, False, "Error")

            tracker.start_attempt("007", 1, "debug", "reflexion", "Method 3")
            tracker.end_attempt("007", 1, True)

            techniques = tracker.get_techniques_used("007", 1)

            # Should be unique, preserving order
            assert "tdd" in techniques
            assert "reflexion" in techniques
            assert len(techniques) == 2


class TestGetFailedTechniques:
    """Test identifying failed techniques."""

    def test_get_failed_techniques_only_failures(self):
        """Should return only techniques that failed."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Method 1")
            tracker.end_attempt("007", 1, False, "Error")

            tracker.start_attempt("007", 1, "debug", "reflexion", "Method 2")
            tracker.end_attempt("007", 1, True)

            failed = tracker.get_failed_techniques("007", 1)

            assert "tdd" in failed
            assert "reflexion" not in failed

    def test_get_failed_techniques_only_if_all_attempts_failed(self):
        """Technique not failed if any attempt succeeded."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            # TDD fails first, then succeeds
            tracker.start_attempt("007", 1, "debug", "tdd", "Method 1")
            tracker.end_attempt("007", 1, False, "Error")

            tracker.start_attempt("007", 1, "debug", "tdd", "Method 2")
            tracker.end_attempt("007", 1, True)

            failed = tracker.get_failed_techniques("007", 1)

            assert "tdd" not in failed


class TestMethodsToAvoid:
    """Test identifying methods to avoid."""

    def test_get_methods_to_avoid_pairs_correctly(self):
        """Should return (technique, method) pairs that failed."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Write test first")
            tracker.end_attempt("007", 1, False, "Test framework issue")

            tracker.start_attempt("007", 1, "debug", "reflexion", "Analyze pattern")
            tracker.end_attempt("007", 1, True)

            to_avoid = tracker.get_methods_to_avoid("007", 1)

            assert ("tdd", "Write test first") in to_avoid
            assert len(to_avoid) == 1


class TestTimeSpent:
    """Test time tracking."""

    def test_get_time_spent_sums_correctly(self):
        """Should sum duration of all attempts."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Method 1")
            time.sleep(1)
            tracker.end_attempt("007", 1, False, "Error")

            tracker.start_attempt("007", 1, "debug", "reflexion", "Method 2")
            time.sleep(1)
            tracker.end_attempt("007", 1, True)

            total_time = tracker.get_time_spent("007", 1)

            # Should be at least 2 seconds
            assert total_time >= 2

    def test_get_time_spent_zero_for_unknown(self):
        """Should return 0 for unknown step."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            total_time = tracker.get_time_spent("007", 99)

            assert total_time == 0


class TestSuggestNextTechnique:
    """Test technique suggestions."""

    def test_suggest_next_technique_excludes_failed(self):
        """Should not suggest techniques that have failed."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Method 1")
            tracker.end_attempt("007", 1, False, "Error")

            suggestion = tracker.suggest_next_technique(
                "007", 1, ["tdd", "reflexion", "self-refine"]
            )

            assert suggestion != "tdd"
            assert suggestion in ["reflexion", "self-refine"]

    def test_suggest_next_technique_returns_none_all_tried(self):
        """Should return None when all techniques tried and failed."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Method 1")
            tracker.end_attempt("007", 1, False, "Error")

            tracker.start_attempt("007", 1, "debug", "reflexion", "Method 2")
            tracker.end_attempt("007", 1, False, "Error")

            suggestion = tracker.suggest_next_technique(
                "007", 1, ["tdd", "reflexion"]
            )

            assert suggestion is None

    def test_suggest_next_technique_prefers_untried(self):
        """Should prefer completely untried techniques."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Method 1")
            tracker.end_attempt("007", 1, False, "Error")

            suggestion = tracker.suggest_next_technique(
                "007", 1, ["tdd", "reflexion", "self-refine"]
            )

            # Should suggest one of the untried techniques
            assert suggestion in ["reflexion", "self-refine"]


class TestHasTriedTechnique:
    """Test checking if technique has been tried."""

    def test_has_tried_technique_true(self):
        """Should return True if technique was used."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Method 1")
            tracker.end_attempt("007", 1, False, "Error")

            assert tracker.has_tried_technique("007", 1, "tdd") is True

    def test_has_tried_technique_false(self):
        """Should return False if technique was not used."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Method 1")
            tracker.end_attempt("007", 1, True)

            assert tracker.has_tried_technique("007", 1, "reflexion") is False


class TestGetMethodsUsed:
    """Test retrieving methods used."""

    def test_get_methods_used(self):
        """Should return all methods used."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Write failing test")
            tracker.end_attempt("007", 1, False, "Error")

            tracker.start_attempt("007", 1, "debug", "tdd", "Fix test setup")
            tracker.end_attempt("007", 1, True)

            methods = tracker.get_methods_used("007", 1)

            assert "Write failing test" in methods
            assert "Fix test setup" in methods


class TestAttemptSummary:
    """Test summary generation."""

    def test_get_attempt_summary_readable(self):
        """Summary should be human-readable."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            tracker.start_attempt("007", 1, "debug", "tdd", "Write failing test")
            tracker.end_attempt("007", 1, False, "Test setup issue")

            tracker.start_attempt("007", 1, "debug", "reflexion", "Analyze pattern")
            tracker.end_attempt("007", 1, True)

            summary = tracker.get_attempt_summary("007", 1)

            # Should contain key information
            assert "2" in summary or "two" in summary.lower()  # 2 attempts
            assert "tdd" in summary.lower() or "TDD" in summary
            assert "Failed" in summary or "failed" in summary

    def test_get_attempt_summary_empty_for_unknown(self):
        """Should return empty/no-data message for unknown step."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            summary = tracker.get_attempt_summary("007", 99)

            assert "no" in summary.lower() or summary == ""


# Test runner for execution without pytest
if __name__ == "__main__":
    import traceback

    test_classes = [
        TestStartAttempt,
        TestEndAttempt,
        TestGetAttempts,
        TestGetTechniquesUsed,
        TestGetFailedTechniques,
        TestMethodsToAvoid,
        TestTimeSpent,
        TestSuggestNextTechnique,
        TestHasTriedTechnique,
        TestGetMethodsUsed,
        TestAttemptSummary,
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
