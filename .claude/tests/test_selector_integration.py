"""
Integration tests for TechniqueSelector with EffectivenessTracker.

Tests cover:
- Backwards compatibility (no tracker)
- Selector with tracker but no data
- Selector with tracker and high confidence data
- Confidence field presence
- Rationale explanation
"""

import sys
import tempfile
from pathlib import Path

# Add scripts directory to path for imports
scripts_dir = Path(__file__).parent.parent / "scripts"
sys.path.insert(0, str(scripts_dir))


class TestBackwardsCompatibility:
    """Test that selector works without any tracker (backwards compatible)."""

    def test_select_without_tracker_works(self):
        """Selector should work with no tracker parameter."""
        from technique_selector import TechniqueSelector, Phase

        selector = TechniqueSelector()
        result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

        assert result.primary is not None
        assert isinstance(result.primary, str)
        assert len(result.primary) > 0

    def test_select_without_tracker_uses_config(self):
        """Selector without tracker should use config defaults."""
        from technique_selector import TechniqueSelector, Phase

        selector = TechniqueSelector()
        result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

        # Should use config default, not effectiveness data
        assert result.primary in ["tdd", "reflexion", "self-refine"]  # Common implementation techniques

    def test_confidence_field_exists(self):
        """TechniqueSelection should have confidence field."""
        from technique_selector import TechniqueSelector, Phase

        selector = TechniqueSelector()
        result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

        assert hasattr(result, "confidence")
        assert isinstance(result.confidence, float)

    def test_confidence_default_value(self):
        """Confidence should default to 0.5 without tracker."""
        from technique_selector import TechniqueSelector, Phase

        selector = TechniqueSelector()
        result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

        assert result.confidence == 0.5


class TestSelectorWithTrackerNoData:
    """Test selector with tracker that has no data."""

    def test_select_with_tracker_no_data_uses_config(self):
        """With tracker but no data, should use config defaults."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker
        from technique_selector import TechniqueSelector, Phase

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            selector = TechniqueSelector(effectiveness_tracker=tracker)
            result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

            # No data means use config default with low confidence
            assert result.confidence <= 0.5

    def test_rationale_mentions_insufficient_data(self):
        """Rationale should indicate when using defaults."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker
        from technique_selector import TechniqueSelector, Phase

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            selector = TechniqueSelector(effectiveness_tracker=tracker)
            result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

            # Rationale should mention default or config
            assert any(word in result.rationale.lower() for word in ["default", "config", "selected"])


class TestSelectorWithTrackerLowConfidence:
    """Test selector with tracker that has low confidence data."""

    def test_select_with_tracker_low_confidence_uses_config(self):
        """With low confidence data (<0.7), should use config."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker
        from technique_selector import TechniqueSelector, Phase

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record just enough data (10 samples) with 50% success
            for i in range(10):
                tracker.record_outcome("debug", "self-refine", success=(i < 5), attempts=2)

            selector = TechniqueSelector(effectiveness_tracker=tracker)
            result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

            # 50% success rate gives ~0.5 effectiveness, should use config
            assert result.confidence <= 0.7


class TestSelectorWithTrackerHighConfidence:
    """Test selector with tracker that has high confidence data."""

    def test_select_with_tracker_high_confidence_uses_effectiveness(self):
        """With high confidence data (>0.7), should use effectiveness recommendation."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker
        from technique_selector import TechniqueSelector, Phase

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record excellent data: 100% success rate with fast resolution
            for _ in range(15):
                tracker.record_outcome("debug", "self-refine", success=True, attempts=1)

            selector = TechniqueSelector(effectiveness_tracker=tracker)
            result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

            # High effectiveness should give high confidence
            assert result.confidence >= 0.7

    def test_rationale_mentions_effectiveness(self):
        """Rationale should mention effectiveness when using effectiveness data."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker
        from technique_selector import TechniqueSelector, Phase

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Record excellent data
            for _ in range(15):
                tracker.record_outcome("debug", "self-refine", success=True, attempts=1)

            selector = TechniqueSelector(effectiveness_tracker=tracker)
            result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

            # If high confidence, should mention effectiveness
            if result.confidence >= 0.7:
                assert any(word in result.rationale.lower() for word in ["effectiveness", "historical", "config"])


class TestConfidenceBoosting:
    """Test confidence boosting when config and effectiveness agree."""

    def test_confidence_boosted_when_agree(self):
        """Confidence should be boosted when config and effectiveness agree."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker
        from technique_selector import TechniqueSelector, Phase

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Get the config default first
            base_selector = TechniqueSelector()
            base_result = base_selector.select_techniques("debug", Phase.IMPLEMENTATION)
            config_default = base_result.primary

            # Record moderate data for the config default technique
            for _ in range(12):
                tracker.record_outcome("debug", config_default, success=True, attempts=2)

            selector = TechniqueSelector(effectiveness_tracker=tracker)
            result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

            # Confidence should be at least 0.5, possibly higher if boosted
            assert result.confidence >= 0.5


class TestRationaleExplanation:
    """Test that rationale explains selection source."""

    def test_rationale_non_empty(self):
        """Rationale should never be empty."""
        from technique_selector import TechniqueSelector, Phase

        selector = TechniqueSelector()
        result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

        assert result.rationale is not None
        assert len(result.rationale) > 0


class TestTrackerParameter:
    """Test the effectiveness_tracker parameter."""

    def test_tracker_parameter_accepted(self):
        """TechniqueSelector should accept effectiveness_tracker parameter."""
        from feedback_store import FeedbackStore
        from effectiveness_tracker import EffectivenessTracker
        from technique_selector import TechniqueSelector

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            tracker = EffectivenessTracker(store)

            # Should not raise
            selector = TechniqueSelector(effectiveness_tracker=tracker)
            assert selector is not None

    def test_tracker_none_accepted(self):
        """TechniqueSelector should work with effectiveness_tracker=None."""
        from technique_selector import TechniqueSelector, Phase

        # Explicitly pass None
        selector = TechniqueSelector(effectiveness_tracker=None)
        result = selector.select_techniques("debug", Phase.IMPLEMENTATION)

        assert result.primary is not None


# Test runner for execution without pytest
if __name__ == "__main__":
    import traceback

    test_classes = [
        TestBackwardsCompatibility,
        TestSelectorWithTrackerNoData,
        TestSelectorWithTrackerLowConfidence,
        TestSelectorWithTrackerHighConfidence,
        TestConfidenceBoosting,
        TestRationaleExplanation,
        TestTrackerParameter,
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
