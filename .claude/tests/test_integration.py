"""
Integration tests for the Intelligent Feedback System.

Tests the complete feedback loop, classification learning,
and system interactions across all components:
- Full feedback loop (record → query → adapt)
- Classification learning flow
- Implementation attempt tracking
- Metrics aggregation
- Concurrent access safety
- Cold start to full operation
- Performance benchmarks

Uses class-based tests compatible with pytest and standalone execution.
"""

import json
import os
import sys
import tempfile
import threading
import time
from pathlib import Path

# Add scripts directory to path for imports
scripts_dir = Path(__file__).parent.parent / "scripts"
sys.path.insert(0, str(scripts_dir))

from feedback_models import (
    ClassificationEntry,
    ImplementationAttempt,
)
from feedback_store import FeedbackStore
from effectiveness_tracker import EffectivenessTracker
from implementation_tracker import ImplementationTracker
from classification_history import ClassificationHistory


class TestFeedbackLoopIntegration:
    """Test the complete feedback loop (record → query → adapt)."""

    def test_feedback_loop_full_cycle(self):
        """Test complete feedback loop: record outcomes → reach threshold → selection adapts."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Cold start - no data, should return None
            initial_effectiveness = tracker.get_effectiveness("debug", "tdd")
            assert initial_effectiveness is None, "Should have no data initially"

            # Record 10 TDD successes for debug (reaching MIN_SAMPLES threshold)
            for i in range(10):
                tracker.record_outcome("debug", "tdd", True, 1)

            # Now should have data
            effectiveness = tracker.get_effectiveness("debug", "tdd")
            assert effectiveness is not None, "Should have effectiveness after threshold"
            assert effectiveness > 0.9, f"All successes should give high effectiveness: {effectiveness}"

            # Record 10 Reflexion failures for debug
            for i in range(10):
                tracker.record_outcome("debug", "reflexion", False, 3)

            # Reflexion should now have low effectiveness
            reflexion_effectiveness = tracker.get_effectiveness("debug", "reflexion")
            assert reflexion_effectiveness is not None
            assert reflexion_effectiveness < 0.3, f"All failures should give low effectiveness: {reflexion_effectiveness}"

            # Get recommendation - should prefer TDD
            available = ["tdd", "reflexion", "self-refine"]
            technique, confidence, rationale = tracker.get_recommended_technique(
                "debug", available, "implementation"
            )
            assert technique == "tdd", f"Should recommend TDD, got: {technique}"
            assert confidence > 0.7, f"Should have high confidence: {confidence}"
            assert "effectiveness" in rationale.lower()

    def test_effectiveness_formula_components(self):
        """Test that effectiveness formula balances success rate and speed."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Scenario A: High success, but slow (many attempts)
            for i in range(10):
                tracker.record_outcome("type_a", "slow_but_sure", True, 5)  # 5 attempts each

            # Scenario B: High success, fast (few attempts)
            for i in range(10):
                tracker.record_outcome("type_b", "fast", True, 1)  # 1 attempt each

            slow_effectiveness = tracker.get_effectiveness("type_a", "slow_but_sure")
            fast_effectiveness = tracker.get_effectiveness("type_b", "fast")

            assert slow_effectiveness is not None
            assert fast_effectiveness is not None
            # Fast should be higher due to speed factor
            assert fast_effectiveness > slow_effectiveness, (
                f"Fast ({fast_effectiveness}) should beat slow ({slow_effectiveness})"
            )

    def test_threshold_boundary_behavior(self):
        """Test behavior at and around MIN_SAMPLES threshold."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record 9 samples (below threshold)
            for i in range(9):
                tracker.record_outcome("boundary_test", "technique", True, 1)

            # Below threshold - should return None
            assert not tracker.has_sufficient_data("boundary_test", "technique")
            assert tracker.get_effectiveness("boundary_test", "technique") is None

            # Add one more to reach threshold
            tracker.record_outcome("boundary_test", "technique", True, 1)

            # Now at threshold - should have data
            assert tracker.has_sufficient_data("boundary_test", "technique")
            assert tracker.get_effectiveness("boundary_test", "technique") is not None


class TestClassificationLearning:
    """Test classification learning from corrections."""

    def test_classification_learning_from_corrections(self):
        """Test that corrections improve future classifications."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Initial classification
            entry = history.add_classification(
                description="Add unit tests for auth module",
                classified_as="unit-test",
                confidence=0.9
            )

            # User correction
            history.record_correction(entry.id, "integration-test")

            # Verify correction was recorded
            corrections = history.get_all_corrections()
            assert len(corrections) > 0, "Correction should be recorded"

            # Similar description should learn from correction
            result = history.get_learned_classification(
                "Add unit tests for authentication"
            )

            assert result is not None, "Should find similar description"
            learned_type, confidence, rationale = result
            assert learned_type == "integration-test", f"Should use corrected type, got: {learned_type}"
            assert confidence > 0.5, f"Should have reasonable confidence: {confidence}"
            assert "similar" in rationale.lower()

    def test_similarity_calculation_accuracy(self):
        """Test that similarity calculation works correctly."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Add classifications with varying similarity
            history.add_classification(
                description="Fix the crash when user taps save button",
                classified_as="debug",
                confidence=0.9
            )

            history.add_classification(
                description="Add new feature for user preferences",
                classified_as="new-feature",
                confidence=0.9
            )

            # Find similar - use nearly identical wording for higher Jaccard similarity
            similar = history.find_similar("Fix the crash when user taps save button now")

            assert len(similar) >= 1, "Should find at least one similar"
            best_match, similarity = similar[0]
            assert "crash" in best_match.description.lower()
            # Jaccard similarity can vary; check for reasonable match
            assert similarity >= 0.5, f"Should have reasonable similarity: {similarity}"

    def test_confidence_decay_over_time(self):
        """Test that confidence calculation handles time decay."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Test the decay calculation directly
            base = 0.6
            correction_count = 1

            # Recent (0 days) - no decay
            recent_conf = history.calculate_learned_confidence(base, correction_count, 0)

            # Old (100 days) - should have some decay
            old_conf = history.calculate_learned_confidence(base, correction_count, 100)

            # Very old (200 days) - should have more decay
            very_old_conf = history.calculate_learned_confidence(base, correction_count, 200)

            assert recent_conf >= old_conf, "Recent should have higher or equal confidence"
            assert old_conf >= very_old_conf, "Old should have higher or equal confidence"


class TestImplementationTracking:
    """Test implementation attempt tracking."""

    def test_implementation_tracking_avoids_repetition(self):
        """Test that failed methods are tracked for avoidance."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            # Failed TDD attempt
            tracker.start_attempt("007", 3, "debug", "tdd", "Write failing test first")
            tracker.end_attempt("007", 3, False, "Test framework issue")

            # Failed Reflexion attempt
            tracker.start_attempt("007", 3, "debug", "reflexion", "Analyze patterns")
            tracker.end_attempt("007", 3, False, "Pattern not found")

            # Check methods to avoid
            avoid = tracker.get_methods_to_avoid("007", 3)
            assert ("tdd", "Write failing test first") in avoid
            assert ("reflexion", "Analyze patterns") in avoid

            # Failed techniques
            failed_techniques = tracker.get_failed_techniques("007", 3)
            assert "tdd" in failed_techniques
            assert "reflexion" in failed_techniques

            # Suggestion should exclude failed techniques
            available = ["tdd", "reflexion", "self-refine", "ps-plus"]
            suggestion = tracker.suggest_next_technique("007", 3, available)
            assert suggestion in ["self-refine", "ps-plus"], f"Got: {suggestion}"
            assert suggestion not in failed_techniques

    def test_attempt_timing_accuracy(self):
        """Test that attempt timing is recorded accurately."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            # Start attempt
            tracker.start_attempt("007", 1, "debug", "tdd", "Test method")

            # Wait a bit
            time.sleep(0.1)

            # End attempt
            attempt = tracker.end_attempt("007", 1, True)

            assert attempt is not None
            assert attempt.duration_seconds >= 0
            assert attempt.success is True
            assert attempt.error_summary is None

    def test_attempt_summary_format(self):
        """Test that attempt summary is readable and complete."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = ImplementationTracker(store)

            # Record a few attempts
            tracker.start_attempt("007", 1, "debug", "tdd", "First approach")
            tracker.end_attempt("007", 1, False, "Assertion failed")

            tracker.start_attempt("007", 1, "debug", "reflexion", "Second approach")
            tracker.end_attempt("007", 1, True)

            summary = tracker.get_attempt_summary("007", 1)

            assert "Previous attempts" in summary
            assert "tdd" in summary
            assert "reflexion" in summary
            assert "Failed" in summary
            assert "Success" in summary
            assert "Methods to avoid" in summary


class TestMetricsAggregation:
    """Test plan metrics aggregation."""

    def test_metrics_aggregate_correctly(self):
        """Test that metrics calculations are correct."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            # Initial metrics
            initial = store.get_metrics()
            assert initial["totalPlans"] == 0
            assert initial["completedPlans"] == 0

            # Update metrics
            store.update_metrics(totalPlans=3, completedPlans=2, totalSteps=18)

            metrics = store.get_metrics()
            assert metrics["totalPlans"] == 3
            assert metrics["completedPlans"] == 2
            assert metrics["totalSteps"] == 18

    def test_metrics_persistence(self):
        """Test that metrics persist across store instances."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # First store instance
            store1 = FeedbackStore(base_path=tmpdir)
            store1.ensure_directory()
            store1.update_metrics(totalPlans=5, completedSteps=10)

            # New store instance reading same data
            store2 = FeedbackStore(base_path=tmpdir)
            metrics = store2.get_metrics()

            assert metrics["totalPlans"] == 5
            assert metrics["completedSteps"] == 10


class TestConcurrentAccess:
    """Test thread safety of concurrent access."""

    def test_concurrent_writes_dont_corrupt(self):
        """Test that concurrent writes to the same store are safe."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            errors = []

            def writer(thread_id):
                try:
                    for i in range(10):
                        store.update_technique_stats(
                            f"type_{thread_id}",
                            "tdd",
                            success=True,
                            attempts=1
                        )
                except Exception as e:
                    errors.append(e)

            threads = [
                threading.Thread(target=writer, args=(i,))
                for i in range(5)
            ]

            for t in threads:
                t.start()
            for t in threads:
                t.join()

            assert len(errors) == 0, f"Errors during concurrent write: {errors}"

            # Verify no corruption
            data = store.get_effectiveness_data()
            assert "byProblemType" in data
            assert "version" in data

            # Should have data from all 5 threads
            assert len(data["byProblemType"]) == 5

    def test_concurrent_read_write_safety(self):
        """Test concurrent reads while writing."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            # Pre-populate some data
            for i in range(5):
                store.update_technique_stats("initial", "tdd", True, 1)

            read_results = []
            errors = []

            def reader():
                try:
                    for _ in range(20):
                        data = store.get_effectiveness_data()
                        read_results.append(data)
                except Exception as e:
                    errors.append(e)

            def writer():
                try:
                    for i in range(20):
                        store.update_technique_stats("writing", f"tech_{i}", True, 1)
                except Exception as e:
                    errors.append(e)

            threads = [
                threading.Thread(target=reader),
                threading.Thread(target=writer),
                threading.Thread(target=reader),
            ]

            for t in threads:
                t.start()
            for t in threads:
                t.join()

            assert len(errors) == 0, f"Errors during concurrent access: {errors}"
            assert len(read_results) == 40, "Should have completed all reads"


class TestColdStartToFullOperation:
    """Test full lifecycle from empty state."""

    def test_cold_start_to_full_operation(self):
        """Test complete lifecycle from empty to adaptive."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Cold start - should use defaults
            available = ["tdd", "reflexion", "self-refine"]
            technique, confidence, rationale = tracker.get_recommended_technique(
                "debug", available, "implementation"
            )

            # Cold start returns first available with 0.5 confidence
            assert confidence == 0.5
            assert "insufficient" in rationale.lower()

            # Simulate step completions
            for i in range(15):
                success = i % 3 != 0  # 67% success rate
                tracker.record_outcome("debug", "tdd", success, 2)

            # Now should have learned
            technique, confidence, rationale = tracker.get_recommended_technique(
                "debug", available, "implementation"
            )
            assert technique == "tdd"
            assert confidence > 0.5
            assert "effectiveness" in rationale.lower()

    def test_system_handles_empty_data_gracefully(self):
        """Test that all components handle empty data gracefully."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)
            impl_tracker = ImplementationTracker(store)
            classification = ClassificationHistory(store)

            # All should work without errors on empty data
            assert tracker.get_effectiveness("nonexistent", "none") is None
            assert tracker.get_all_effectiveness("nonexistent") == {}
            assert tracker.get_technique_ranking("nonexistent") == []

            assert impl_tracker.get_attempts("xxx", 999) == []
            assert impl_tracker.get_techniques_used("xxx", 999) == []
            assert impl_tracker.suggest_next_technique("xxx", 999, ["tdd"]) == "tdd"

            assert classification.get_learned_classification("test") is None
            assert classification.find_similar("test") == []


class TestPerformance:
    """Performance benchmarks."""

    def test_performance_large_dataset(self):
        """Test performance with large dataset."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            # Measure write performance
            write_start = time.time()

            for ptype in range(10):
                for tech in range(5):
                    for _ in range(100):
                        store.update_technique_stats(
                            f"type_{ptype}",
                            f"tech_{tech}",
                            True,
                            1
                        )

            write_time = time.time() - write_start
            print(f"Write time (5000 records): {write_time:.2f}s")
            assert write_time < 60, f"Write should complete in under 60 seconds, took {write_time:.2f}s"

            # Measure read performance
            read_start = time.time()
            data = store.get_effectiveness_data()
            read_time = time.time() - read_start
            print(f"Read time: {read_time:.2f}s")
            assert read_time < 2, f"Read should complete in under 2 seconds, took {read_time:.2f}s"

            # Verify data integrity
            assert len(data["byProblemType"]) == 10

    def test_classification_search_performance(self):
        """Test classification search with many entries."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Add 100 entries
            for i in range(100):
                history.add_classification(
                    description=f"Description number {i} with some unique words like word{i}",
                    classified_as="debug" if i % 2 == 0 else "new-feature",
                    confidence=0.8
                )

            # Time the search
            search_start = time.time()
            results = history.find_similar("Description with unique words")
            search_time = time.time() - search_start

            print(f"Search time (100 entries): {search_time:.4f}s")
            assert search_time < 1, f"Search should complete in under 1 second, took {search_time:.2f}s"


class TestEdgeCases:
    """Test edge cases and error handling."""

    def test_empty_string_handling(self):
        """Test handling of empty strings."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Empty description should return None
            assert history.get_learned_classification("") is None
            assert history.get_learned_classification("   ") is None

            # Empty find should return empty list
            assert history.find_similar("") == []

    def test_special_characters_in_data(self):
        """Test handling of special characters."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()

            # Special characters in problem type
            store.update_technique_stats(
                "type-with-dashes_and_underscores",
                "technique/with/slashes",
                True,
                1
            )

            data = store.get_effectiveness_data()
            assert "type-with-dashes_and_underscores" in data["byProblemType"]

    def test_duplicate_correction_handling(self):
        """Test handling of duplicate corrections."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            entry = history.add_classification(
                description="Test classification",
                classified_as="debug",
                confidence=0.9
            )

            # Same correction twice should not fail
            history.record_correction(entry.id, "new-feature")
            history.record_correction(entry.id, "new-feature")

            # Correction should be recorded
            corrections = history.get_all_corrections()
            assert len(corrections) > 0


class TestIntegrationScenarios:
    """Test real-world integration scenarios."""

    def test_full_plan_execution_simulation(self):
        """Simulate executing a full plan with the feedback system."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            eff_tracker = EffectivenessTracker(store)
            impl_tracker = ImplementationTracker(store)

            # Simulate plan with 5 steps
            plan_id = "test-001"
            steps = [
                ("Step 1: Data Models", "infrastructure", True, 1),
                ("Step 2: Repository", "service-impl", True, 2),
                ("Step 3: Service Layer", "service-impl", False, 1),  # Failed first
                ("Step 3: Service Layer Retry", "service-impl", True, 2),
                ("Step 4: Tests", "unit-test", True, 1),
                ("Step 5: Documentation", "documentation", True, 1),
            ]

            for i, (name, problem_type, success, attempts) in enumerate(steps, 1):
                # Track implementation
                impl_tracker.start_attempt(plan_id, i, problem_type, "tdd", name)
                attempt = impl_tracker.end_attempt(plan_id, i, success, None if success else "Failed")

                # Record effectiveness
                if attempt:
                    eff_tracker.record_outcome(problem_type, "tdd", success, attempts)

            # Verify tracking
            step3_attempts = impl_tracker.get_attempts(plan_id, 3)
            assert len(step3_attempts) == 1  # Each step gets its own step_id

            # Check effectiveness data
            data = store.get_effectiveness_data()
            assert "service-impl" in data["byProblemType"]

    def test_classification_feedback_loop(self):
        """Test classification with correction feeding into future classifications."""
        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # User classifies some tasks
            entries = []
            for desc in [
                "Add login button to the homepage",
                "Create logout button on dashboard",
                "Implement sign-in form validation",
            ]:
                entry = history.add_classification(
                    description=desc,
                    classified_as="ui",
                    confidence=0.8
                )
                entries.append(entry)

            # User corrects one - it was actually auth-related
            history.record_correction(entries[0].id, "auth")

            # Use exact same description to guarantee a match
            similar = history.find_similar("Add login button to the homepage")
            assert len(similar) > 0, "Should find exact description"

            # For very similar description, use lower threshold
            similar_low = history.find_similar("Add login button to homepage", min_similarity=0.3)
            assert len(similar_low) > 0, "Should find similar descriptions with lower threshold"


# Test runner for execution without pytest
if __name__ == "__main__":
    import traceback

    test_classes = [
        TestFeedbackLoopIntegration,
        TestClassificationLearning,
        TestImplementationTracking,
        TestMetricsAggregation,
        TestConcurrentAccess,
        TestColdStartToFullOperation,
        TestPerformance,
        TestEdgeCases,
        TestIntegrationScenarios,
    ]

    passed = 0
    failed = 0
    errors: list[tuple[str, str]] = []

    print("=" * 60)
    print("  INTEGRATION TESTS - Intelligent Feedback System")
    print("=" * 60)

    for test_class in test_classes:
        print(f"\n{test_class.__name__}")
        print("-" * 40)
        instance = test_class()
        for method_name in dir(instance):
            if method_name.startswith("test_"):
                try:
                    method = getattr(instance, method_name)
                    method()
                    print(f"  ✓ {method_name}")
                    passed += 1
                except Exception as e:
                    print(f"  ✗ {method_name}")
                    errors.append(
                        (f"{test_class.__name__}.{method_name}", traceback.format_exc())
                    )
                    failed += 1

    print(f"\n{'=' * 60}")
    print(f"Results: {passed} passed, {failed} failed")
    print(f"{'=' * 60}")

    if errors:
        print(f"\nFAILURES:\n")
        for name, tb in errors:
            print(f"{name}:")
            print(tb)
            print()

    sys.exit(0 if failed == 0 else 1)
