"""
Integration tests for plan-next command feedback integration.

Tests verify that the feedback system correctly:
- Records implementation attempts at step start
- Records outcomes on success/failure
- Updates plan metrics
- Generates attempt summaries
"""

import sys
import tempfile
from pathlib import Path
from datetime import datetime

# Add scripts directory to path for imports
scripts_dir = Path(__file__).parent.parent / "scripts"
sys.path.insert(0, str(scripts_dir))


class TestAttemptRecording:
    """Test that implementation attempts are recorded correctly."""

    def test_start_attempt_creates_record(self):
        """Starting an attempt should create an in-memory record."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            attempt_num = tracker.start_attempt(
                plan_id="007",
                step_id=8,
                problem_type="refactor",
                technique="tdd",
                method_description="Write tests first for feedback integration"
            )

            assert attempt_num == 1
            # Active attempt should be tracked in memory
            key = tracker._step_key("007", 8)
            assert key in tracker._active_attempts

    def test_end_attempt_persists_record(self):
        """Ending an attempt should persist to storage."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            # Start and end an attempt
            tracker.start_attempt(
                plan_id="007",
                step_id=8,
                problem_type="refactor",
                technique="tdd",
                method_description="TDD integration test"
            )

            attempt = tracker.end_attempt(
                plan_id="007",
                step_id=8,
                success=True,
                error_summary=None
            )

            assert attempt is not None
            assert attempt.success is True
            assert attempt.technique == "tdd"

            # Verify persisted
            step_data = store.get_step_attempts("007", 8)
            assert step_data is not None
            assert step_data.total_attempts == 1

    def test_multiple_attempts_tracked(self):
        """Multiple attempts should be tracked and numbered correctly."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            # First attempt
            num1 = tracker.start_attempt("007", 8, "refactor", "tdd", "First try")
            tracker.end_attempt("007", 8, success=False, error_summary="Test failure")

            # Second attempt
            num2 = tracker.start_attempt("007", 8, "refactor", "self-refine", "Second try")
            tracker.end_attempt("007", 8, success=True, error_summary=None)

            assert num1 == 1
            assert num2 == 2

            step_data = store.get_step_attempts("007", 8)
            assert step_data.total_attempts == 2


class TestOutcomeRecording:
    """Test that outcomes are recorded to effectiveness tracker."""

    def test_success_recorded_to_effectiveness(self):
        """Successful outcome should be recorded to effectiveness tracker."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record a successful outcome
            tracker.record_outcome(
                problem_type="refactor",
                technique="tdd",
                success=True,
                attempts=1
            )

            # Verify recorded
            data = store.get_effectiveness_data()
            assert "refactor" in data["byProblemType"]
            assert "tdd" in data["byProblemType"]["refactor"]
            assert data["byProblemType"]["refactor"]["tdd"]["success"] == 1

    def test_failure_recorded_to_effectiveness(self):
        """Failed outcome should be recorded to effectiveness tracker."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record a failed outcome
            tracker.record_outcome(
                problem_type="debug",
                technique="reflexion",
                success=False,
                attempts=3
            )

            # Verify recorded
            data = store.get_effectiveness_data()
            assert data["byProblemType"]["debug"]["reflexion"]["failure"] == 1

    def test_attempts_count_tracked(self):
        """Number of attempts should be tracked for averaging."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record with 2 attempts
            tracker.record_outcome("new-feature", "tdd", success=True, attempts=2)

            data = store.get_effectiveness_data()
            stats = data["byProblemType"]["new-feature"]["tdd"]
            assert stats["total_attempts"] == 2


class TestMetricsUpdate:
    """Test that plan metrics are updated correctly."""

    def test_completed_steps_increment(self):
        """Completing a step should increment completedSteps."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            # Get initial value
            initial = store.get_metrics()
            initial_completed = initial.get("completedSteps", 0)

            # Update by incrementing
            store.update_metrics(completedSteps=initial_completed + 1)

            # Verify incremented
            updated = store.get_metrics()
            assert updated["completedSteps"] == initial_completed + 1

    def test_total_steps_update(self):
        """Total steps should be updateable."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            store.update_metrics(totalSteps=12)

            metrics = store.get_metrics()
            assert metrics["totalSteps"] == 12

    def test_last_updated_set(self):
        """lastUpdated should be set on any update."""
        from feedback_store import FeedbackStore

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            store.update_metrics(completedSteps=1)

            metrics = store.get_metrics()
            assert metrics["lastUpdated"] is not None


class TestAttemptSummary:
    """Test attempt summary generation."""

    def test_empty_summary_for_no_attempts(self):
        """Should return appropriate message when no attempts exist."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            summary = tracker.get_attempt_summary("007", 8)

            assert "No previous attempts" in summary

    def test_summary_includes_attempt_details(self):
        """Summary should include technique and method for each attempt."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            # Record an attempt
            tracker.start_attempt("007", 8, "refactor", "tdd", "Write tests first")
            tracker.end_attempt("007", 8, success=False, error_summary="Missing edge case")

            summary = tracker.get_attempt_summary("007", 8)

            assert "tdd" in summary
            assert "Write tests first" in summary
            assert "Missing edge case" in summary or "Failed" in summary

    def test_summary_includes_methods_to_avoid(self):
        """Summary should list failed methods to avoid."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            # Record a failed attempt
            tracker.start_attempt("007", 8, "refactor", "tdd", "Direct implementation")
            tracker.end_attempt("007", 8, success=False, error_summary="Tests fail")

            summary = tracker.get_attempt_summary("007", 8)

            assert "avoid" in summary.lower()


class TestTechniqueSuggestion:
    """Test technique suggestion based on history."""

    def test_suggest_untried_technique_first(self):
        """Should suggest untried techniques before retrying failed ones."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            # Record a failed TDD attempt
            tracker.start_attempt("007", 8, "refactor", "tdd", "TDD approach")
            tracker.end_attempt("007", 8, success=False, error_summary="Complex logic")

            # Suggest from available techniques
            suggestion = tracker.suggest_next_technique(
                "007", 8,
                available_techniques=["tdd", "self-refine", "reflexion"]
            )

            # Should suggest self-refine or reflexion (untried), not tdd
            assert suggestion in ["self-refine", "reflexion"]

    def test_suggest_none_when_all_failed(self):
        """Should return None when all available techniques have failed."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            # Record failed attempts for both techniques
            tracker.start_attempt("007", 8, "refactor", "tdd", "TDD try")
            tracker.end_attempt("007", 8, success=False, error_summary="Failed")

            tracker.start_attempt("007", 8, "refactor", "self-refine", "SR try")
            tracker.end_attempt("007", 8, success=False, error_summary="Failed")

            # Suggest from only those techniques
            suggestion = tracker.suggest_next_technique(
                "007", 8,
                available_techniques=["tdd", "self-refine"]
            )

            assert suggestion is None


class TestFullFlow:
    """Test the complete flow as it would occur in plan-next."""

    def test_complete_step_flow(self):
        """Test the full flow of recording and completing a step."""
        from feedback_store import FeedbackStore
        from implementation_tracker import ImplementationTracker
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            impl_tracker = ImplementationTracker(store)
            eff_tracker = EffectivenessTracker(store)

            # 1. Start attempt (simulates step 6 start)
            attempt_num = impl_tracker.start_attempt(
                plan_id="007",
                step_id=8,
                problem_type="refactor",
                technique="tdd",
                method_description="TDD + self-refine integration"
            )
            assert attempt_num == 1

            # 2. End attempt with success (simulates step 7 verification pass)
            attempt = impl_tracker.end_attempt(
                plan_id="007",
                step_id=8,
                success=True,
                error_summary=None
            )
            assert attempt.success is True

            # 3. Record to effectiveness (simulates post-verification)
            eff_tracker.record_outcome(
                problem_type="refactor",
                technique="tdd",
                success=True,
                attempts=1
            )

            # 4. Update metrics
            metrics = store.get_metrics()
            store.update_metrics(completedSteps=metrics["completedSteps"] + 1)

            # Verify all data persisted
            step_data = store.get_step_attempts("007", 8)
            assert step_data.total_attempts == 1
            assert step_data.attempts[0].success is True

            eff_data = store.get_effectiveness_data()
            assert eff_data["byProblemType"]["refactor"]["tdd"]["success"] == 1

            final_metrics = store.get_metrics()
            assert final_metrics["completedSteps"] == 1


# Test runner for execution without pytest
if __name__ == "__main__":
    import traceback

    test_classes = [
        TestAttemptRecording,
        TestOutcomeRecording,
        TestMetricsUpdate,
        TestAttemptSummary,
        TestTechniqueSuggestion,
        TestFullFlow,
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
                    print(f"  \u2713 {test_class.__name__}.{method_name}")
                    passed += 1
                except Exception as e:
                    print(f"  \u2717 {test_class.__name__}.{method_name}")
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
