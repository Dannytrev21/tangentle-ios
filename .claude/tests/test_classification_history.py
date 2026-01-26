"""
Unit tests for ClassificationHistory service.

Tests cover:
- Adding classifications
- Recording corrections
- Finding similar descriptions
- Learned classification retrieval
- Confidence calculation with boost and decay
- Tokenization and similarity
"""

import sys
import tempfile
from pathlib import Path
from datetime import datetime, timedelta

# Add scripts directory to path for imports
scripts_dir = Path(__file__).parent.parent / "scripts"
sys.path.insert(0, str(scripts_dir))


class TestAddClassification:
    """Test adding classifications to history."""

    def test_add_classification_creates_entry(self):
        """Adding a classification should create an entry with all metadata."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            entry = history.add_classification(
                description="Add tests for auth module",
                classified_as="unit-test",
                confidence=0.9,
                source="semantic"
            )

            assert entry.id is not None
            assert entry.description == "Add tests for auth module"
            assert entry.classified_as == "unit-test"
            assert entry.confidence == 0.9
            assert entry.source == "semantic"
            assert entry.description_hash is not None

    def test_add_classification_generates_hash(self):
        """Adding a classification should generate a description hash."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            entry = history.add_classification(
                description="Fix the login bug",
                classified_as="debug",
                confidence=0.85
            )

            assert len(entry.description_hash) == 16  # First 16 chars of SHA256

    def test_add_classification_persists(self):
        """Classifications should persist to storage."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            history.add_classification(
                description="Refactor the auth service",
                classified_as="refactor",
                confidence=0.8
            )

            # Reload from storage
            entries = store.get_classification_history()
            assert len(entries) == 1
            assert entries[0]["classified_as"] == "refactor"


class TestRecordCorrection:
    """Test recording user corrections."""

    def test_record_correction_updates_entry(self):
        """Recording a correction should update the entry."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            entry = history.add_classification(
                description="Add tests for auth",
                classified_as="unit-test",
                confidence=0.9
            )

            history.record_correction(entry.id, "integration-test")

            # Check the correction was recorded
            entries = store.get_classification_history()
            corrected = [e for e in entries if e["id"] == entry.id]
            assert len(corrected) == 1
            assert corrected[0]["corrected_to"] == "integration-test"

    def test_record_correction_ignores_same_type(self):
        """Correction to the same type should not record."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            entry = history.add_classification(
                description="Add tests",
                classified_as="unit-test",
                confidence=0.9
            )

            # Correct to same type
            history.record_correction(entry.id, "unit-test")

            # Should not have a correction recorded
            entries = store.get_classification_history()
            corrected = [e for e in entries if e["id"] == entry.id]
            assert corrected[0].get("corrected_to") is None


class TestFindSimilar:
    """Test finding similar descriptions."""

    def test_find_similar_above_threshold(self):
        """Similar descriptions above threshold should match."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Add an entry
            history.add_classification(
                description="Add tests for authentication module",
                classified_as="unit-test",
                confidence=0.9
            )

            # Find similar
            similar = history.find_similar("Add tests for auth module")

            assert len(similar) > 0
            entry, similarity = similar[0]
            assert similarity >= 0.5  # Should have decent similarity

    def test_find_similar_below_threshold_empty(self):
        """Dissimilar descriptions should not match."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Add an entry
            history.add_classification(
                description="Add tests for authentication module",
                classified_as="unit-test",
                confidence=0.9
            )

            # Find with completely different description
            similar = history.find_similar("Fix the database connection error", min_similarity=0.8)

            assert len(similar) == 0

    def test_find_similar_empty_history(self):
        """Empty history should return empty list."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            similar = history.find_similar("Add tests for auth")

            assert similar == []


class TestGetLearnedClassification:
    """Test getting learned classifications from history."""

    def test_get_learned_classification_from_correction(self):
        """Should return the corrected type for similar descriptions."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Add and correct - use description that will have high similarity
            entry = history.add_classification(
                description="Add unit tests for authentication module",
                classified_as="unit-test",
                confidence=0.9
            )
            history.record_correction(entry.id, "integration-test")

            # Get learned for similar description (shares: add, unit, tests, authentication, module)
            result = history.get_learned_classification("Add unit tests for authentication module service")

            assert result is not None
            learned_type, confidence, rationale = result
            assert learned_type == "integration-test"
            assert confidence > 0.0
            assert "similar" in rationale.lower() or "learned" in rationale.lower()

    def test_get_learned_classification_no_match(self):
        """Should return None for dissimilar descriptions."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Add an entry
            history.add_classification(
                description="Add tests for auth",
                classified_as="unit-test",
                confidence=0.9
            )

            # Try completely different description
            result = history.get_learned_classification("Fix the database migration")

            assert result is None

    def test_get_learned_classification_empty_description(self):
        """Should return None for empty description."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            result = history.get_learned_classification("")

            assert result is None


class TestConfidenceCalculation:
    """Test confidence calculation with boost and decay."""

    def test_confidence_boost_from_corrections(self):
        """Corrections should boost confidence."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            base_confidence = 0.5
            days_since = 10  # Recent, no decay

            # No corrections
            conf0 = history.calculate_learned_confidence(base_confidence, 0, days_since)

            # 1 correction
            conf1 = history.calculate_learned_confidence(base_confidence, 1, days_since)

            # 2 corrections
            conf2 = history.calculate_learned_confidence(base_confidence, 2, days_since)

            assert conf1 > conf0  # 1 correction should boost
            assert conf2 > conf1  # 2 corrections should boost more

    def test_confidence_decay_after_threshold(self):
        """Confidence should decay after DECAY_DAYS."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Use lower base and fewer corrections to avoid hitting MAX_CONFIDENCE cap
            base_confidence = 0.4
            correction_count = 1  # Only +0.3 boost, so total is 0.7

            # Within threshold
            conf_recent = history.calculate_learned_confidence(
                base_confidence, correction_count, days_since_last=30
            )

            # After threshold (120 days, 30 over the 90-day threshold = 1 decay period)
            conf_old = history.calculate_learned_confidence(
                base_confidence, correction_count, days_since_last=120
            )

            # Even older (180 days, 90 over threshold = 3 decay periods)
            conf_very_old = history.calculate_learned_confidence(
                base_confidence, correction_count, days_since_last=180
            )

            assert conf_old < conf_recent  # Should decay
            assert conf_very_old < conf_old  # Should decay more

    def test_confidence_capped_at_max(self):
        """Confidence should not exceed MAX_CONFIDENCE."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # High base + multiple corrections
            confidence = history.calculate_learned_confidence(
                base_confidence=0.9,
                correction_count=5,  # More than max boost
                days_since_last=10
            )

            assert confidence <= history.MAX_CONFIDENCE

    def test_confidence_not_negative(self):
        """Confidence should not go below 0."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Very old entry with low base
            confidence = history.calculate_learned_confidence(
                base_confidence=0.1,
                correction_count=0,
                days_since_last=365  # Very old
            )

            assert confidence >= 0.0


class TestTokenization:
    """Test tokenization and similarity functions."""

    def test_tokenization_removes_stopwords(self):
        """Tokenization should remove common stopwords."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            tokens = history._tokenize("Add the tests for the auth module")

            # Stopwords like "the", "for" should be removed
            assert "the" not in tokens
            assert "for" not in tokens
            # Content words should remain
            assert "add" in tokens
            assert "tests" in tokens
            assert "auth" in tokens
            assert "module" in tokens

    def test_tokenization_lowercase(self):
        """Tokenization should lowercase all words."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            tokens = history._tokenize("Add Tests For AUTH")

            assert "add" in tokens
            assert "tests" in tokens
            assert "auth" in tokens
            assert "Add" not in tokens  # Should be lowercase

    def test_similarity_identical_strings(self):
        """Identical strings should have similarity 1.0."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            similarity = history._calculate_similarity(
                "Add tests for auth module",
                "Add tests for auth module"
            )

            assert similarity == 1.0

    def test_similarity_different_strings(self):
        """Completely different strings should have low similarity."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            similarity = history._calculate_similarity(
                "Add tests for auth module",
                "Fix database connection error"
            )

            assert similarity < 0.3  # Low similarity

    def test_similarity_partial_overlap(self):
        """Partially overlapping strings should have moderate similarity."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            similarity = history._calculate_similarity(
                "Add tests for auth module",
                "Add tests for authentication service"
            )

            assert 0.3 < similarity < 0.9  # Moderate similarity


class TestCorrectionCount:
    """Test correction count tracking."""

    def test_get_correction_count_no_corrections(self):
        """Should return 0 for entries without corrections."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            entry = history.add_classification(
                description="Add tests",
                classified_as="unit-test",
                confidence=0.9
            )

            count = history.get_correction_count(entry.description_hash)

            assert count == 0

    def test_get_correction_count_with_corrections(self):
        """Should track correction count."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            entry = history.add_classification(
                description="Add tests",
                classified_as="unit-test",
                confidence=0.9
            )

            # Add a correction
            history.record_correction(entry.id, "integration-test")

            count = history.get_correction_count(entry.description_hash)

            assert count >= 1


class TestClearOldEntries:
    """Test clearing old entries."""

    def test_clear_old_entries(self):
        """Should remove entries older than threshold."""
        from feedback_store import FeedbackStore
        from classification_history import ClassificationHistory

        with tempfile.TemporaryDirectory() as tmpdir:
            store = FeedbackStore(base_path=tmpdir)
            store.ensure_directory()
            history = ClassificationHistory(store)

            # Add an entry (will be "recent")
            history.add_classification(
                description="Recent entry",
                classified_as="unit-test",
                confidence=0.9
            )

            # Clear entries older than 1 day (recent entry should remain)
            removed = history.clear_old_entries(days_old=1)

            # Since entry is just created, nothing should be removed
            assert removed == 0


# Test runner for execution without pytest
if __name__ == "__main__":
    import traceback

    test_classes = [
        TestAddClassification,
        TestRecordCorrection,
        TestFindSimilar,
        TestGetLearnedClassification,
        TestConfidenceCalculation,
        TestTokenization,
        TestCorrectionCount,
        TestClearOldEntries,
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
