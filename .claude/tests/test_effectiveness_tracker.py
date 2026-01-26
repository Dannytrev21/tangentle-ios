"""
Unit tests for the EffectivenessTracker service.

Tests cover:
- Effectiveness formula calculation
- Minimum sample threshold enforcement
- Cold start handling
- Technique recommendations
- Speed factor impact on scores
"""

import sys
import tempfile
from pathlib import Path

# Add scripts directory to path for imports
scripts_dir = Path(__file__).parent.parent / "scripts"
sys.path.insert(0, str(scripts_dir))


class TestRecordOutcome:
    """Test recording outcomes updates stats correctly."""

    def test_record_outcome_updates_stats(self):
        """Recording an outcome should update the store."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            tracker.record_outcome("debug", "tdd", success=True, attempts=2)

            # Verify store was updated
            data = store.get_effectiveness_data()
            assert "debug" in data["byProblemType"]
            assert "tdd" in data["byProblemType"]["debug"]
            assert data["byProblemType"]["debug"]["tdd"]["success"] == 1

    def test_record_multiple_outcomes(self):
        """Should handle multiple outcome recordings."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            tracker.record_outcome("debug", "tdd", success=True, attempts=2)
            tracker.record_outcome("debug", "tdd", success=False, attempts=3)
            tracker.record_outcome("debug", "tdd", success=True, attempts=1)

            data = store.get_effectiveness_data()
            stats = data["byProblemType"]["debug"]["tdd"]
            assert stats["success"] == 2
            assert stats["failure"] == 1
            assert stats["total_attempts"] == 6


class TestEffectivenessCalculation:
    """Test the effectiveness formula calculation."""

    def test_effectiveness_calculation_success_only(self):
        """100% success rate should give high score."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record 10 successes with optimal speed (2 attempts each)
            for _ in range(10):
                tracker.record_outcome("debug", "tdd", success=True, attempts=2)

            effectiveness = tracker.get_effectiveness("debug", "tdd")

            # 100% success rate, optimal speed: should be close to 1.0
            assert effectiveness is not None
            assert effectiveness >= 0.95, f"Expected >= 0.95, got {effectiveness}"

    def test_effectiveness_calculation_mixed(self):
        """Mixed results should give moderate score."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record mixed results: 5 success, 5 failure
            for _ in range(5):
                tracker.record_outcome("debug", "tdd", success=True, attempts=2)
            for _ in range(5):
                tracker.record_outcome("debug", "tdd", success=False, attempts=2)

            effectiveness = tracker.get_effectiveness("debug", "tdd")

            # 50% success rate: score should be around 0.5
            assert effectiveness is not None
            assert 0.3 <= effectiveness <= 0.7, f"Expected 0.3-0.7, got {effectiveness}"

    def test_effectiveness_calculation_all_failures(self):
        """All failures should give low score."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record 10 failures
            for _ in range(10):
                tracker.record_outcome("debug", "tdd", success=False, attempts=2)

            effectiveness = tracker.get_effectiveness("debug", "tdd")

            # 0% success rate: should be close to 0
            assert effectiveness is not None
            assert effectiveness <= 0.1, f"Expected <= 0.1, got {effectiveness}"


class TestMinimumSampleThreshold:
    """Test MIN_SAMPLES threshold enforcement."""

    def test_get_effectiveness_returns_none_below_threshold(self):
        """Should return None when < 10 samples."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record 9 outcomes (below threshold)
            for _ in range(9):
                tracker.record_outcome("debug", "tdd", success=True, attempts=2)

            effectiveness = tracker.get_effectiveness("debug", "tdd")

            assert effectiveness is None, "Should return None for < 10 samples"

    def test_get_effectiveness_returns_score_at_threshold(self):
        """Should return score when exactly 10 samples."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record exactly 10 outcomes
            for _ in range(10):
                tracker.record_outcome("debug", "tdd", success=True, attempts=2)

            effectiveness = tracker.get_effectiveness("debug", "tdd")

            assert effectiveness is not None, "Should return score at 10 samples"

    def test_has_sufficient_data_below_threshold(self):
        """has_sufficient_data should return False below threshold."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            for _ in range(9):
                tracker.record_outcome("debug", "tdd", success=True, attempts=2)

            assert not tracker.has_sufficient_data("debug", "tdd")

    def test_has_sufficient_data_at_threshold(self):
        """has_sufficient_data should return True at threshold."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            for _ in range(10):
                tracker.record_outcome("debug", "tdd", success=True, attempts=2)

            assert tracker.has_sufficient_data("debug", "tdd")


class TestColdStart:
    """Test cold start handling (no historical data)."""

    def test_recommended_technique_cold_start(self):
        """Should return default with explanation when no data."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            technique, confidence, rationale = tracker.get_recommended_technique(
                "debug", ["tdd", "reflexion"], "implementation"
            )

            # Should return first available with neutral confidence
            assert technique in ["tdd", "reflexion"]
            assert confidence == 0.5
            assert "default" in rationale.lower() or "insufficient" in rationale.lower()

    def test_get_effectiveness_unknown_problem_type(self):
        """Should return None for unknown problem type."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            effectiveness = tracker.get_effectiveness("unknown_type", "tdd")

            assert effectiveness is None


class TestRecommendations:
    """Test technique recommendations with data."""

    def test_recommended_technique_with_data(self):
        """Should recommend technique with highest effectiveness."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # TDD: 60% success (6/10)
            for i in range(10):
                tracker.record_outcome("debug", "tdd", success=(i < 6), attempts=2)

            # Reflexion: 80% success (8/10)
            for i in range(10):
                tracker.record_outcome("debug", "reflexion", success=(i < 8), attempts=2)

            technique, confidence, rationale = tracker.get_recommended_technique(
                "debug", ["tdd", "reflexion"], "implementation"
            )

            # Should recommend reflexion (higher success rate)
            assert technique == "reflexion"
            assert confidence > 0.5
            assert "effectiveness" in rationale.lower() or "historical" in rationale.lower()

    def test_recommended_filters_unavailable_techniques(self):
        """Should only consider available techniques."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Reflexion: 90% success
            for _ in range(10):
                tracker.record_outcome("debug", "reflexion", success=True, attempts=2)

            # TDD: 50% success
            for i in range(10):
                tracker.record_outcome("debug", "tdd", success=(i < 5), attempts=2)

            # Only tdd is available
            technique, _, _ = tracker.get_recommended_technique(
                "debug", ["tdd"], "implementation"
            )

            assert technique == "tdd"


class TestSpeedFactor:
    """Test that speed factor impacts effectiveness score."""

    def test_speed_factor_impacts_score(self):
        """Faster success should give higher score."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Fast technique: 100% success with 1 attempt each
            for _ in range(10):
                tracker.record_outcome("debug", "fast", success=True, attempts=1)

            # Slow technique: 100% success with 4 attempts each
            for _ in range(10):
                tracker.record_outcome("debug", "slow", success=True, attempts=4)

            fast_score = tracker.get_effectiveness("debug", "fast")
            slow_score = tracker.get_effectiveness("debug", "slow")

            assert fast_score is not None
            assert slow_score is not None
            assert fast_score > slow_score, f"Fast ({fast_score}) should beat slow ({slow_score})"


class TestTechniqueRanking:
    """Test technique ranking functionality."""

    def test_get_technique_ranking(self):
        """Should return techniques sorted by effectiveness."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Different success rates
            for _ in range(10):
                tracker.record_outcome("debug", "low", success=False, attempts=2)
            for i in range(10):
                tracker.record_outcome("debug", "mid", success=(i < 5), attempts=2)
            for _ in range(10):
                tracker.record_outcome("debug", "high", success=True, attempts=2)

            ranking = tracker.get_technique_ranking("debug")

            # Should be sorted by effectiveness (highest first)
            assert len(ranking) == 3
            assert ranking[0][0] == "high"
            assert ranking[2][0] == "low"

    def test_get_technique_ranking_empty(self):
        """Should return empty list when no data."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            ranking = tracker.get_technique_ranking("debug")

            assert ranking == []


class TestSampleCount:
    """Test sample count retrieval."""

    def test_get_sample_count(self):
        """Should return correct sample count."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            for _ in range(7):
                tracker.record_outcome("debug", "tdd", success=True, attempts=2)

            count = tracker.get_sample_count("debug", "tdd")

            assert count == 7

    def test_get_sample_count_unknown(self):
        """Should return 0 for unknown technique."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            count = tracker.get_sample_count("debug", "unknown")

            assert count == 0


class TestGetAllEffectiveness:
    """Test getting all effectiveness scores for a problem type."""

    def test_get_all_effectiveness(self):
        """Should return scores for all techniques with sufficient data."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Sufficient data for tdd
            for _ in range(10):
                tracker.record_outcome("debug", "tdd", success=True, attempts=2)

            # Insufficient data for reflexion
            for _ in range(5):
                tracker.record_outcome("debug", "reflexion", success=True, attempts=2)

            all_scores = tracker.get_all_effectiveness("debug")

            # Only tdd should be included (reflexion has < 10 samples)
            assert "tdd" in all_scores
            assert "reflexion" not in all_scores

    def test_get_all_effectiveness_empty(self):
        """Should return empty dict when no data."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            all_scores = tracker.get_all_effectiveness("debug")

            assert all_scores == {}


# Test runner for execution without pytest
if __name__ == "__main__":
    import traceback

    test_classes = [
        TestRecordOutcome,
        TestEffectivenessCalculation,
        TestMinimumSampleThreshold,
        TestColdStart,
        TestRecommendations,
        TestSpeedFactor,
        TestTechniqueRanking,
        TestSampleCount,
        TestGetAllEffectiveness,
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
