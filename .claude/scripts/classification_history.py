"""
Classification History Service for the Intelligent Planning System.

This module provides the ClassificationHistory class which:
- Stores all classifications with metadata
- Learns from user corrections immediately
- Suggests classifications based on similar past descriptions
- Manages confidence over time (decay)

Key distinction from other tracking:
- FeedbackStore: Low-level CRUD operations
- ClassificationHistory: Higher-level learning logic
"""

import hashlib
import re
import uuid
from datetime import datetime
from typing import Optional

from feedback_models import ClassificationEntry
from feedback_store import FeedbackStore


class ClassificationHistory:
    """
    Manages classification history and learns from user corrections.

    Uses Jaccard similarity on word tokens to match similar descriptions,
    then applies corrections from past experiences to new classifications.
    """

    # Constants
    SIMILARITY_THRESHOLD = 0.8   # Similarity needed to match
    CORRECTION_BOOST = 0.3       # Confidence boost per correction
    MAX_CONFIDENCE = 0.95        # Cap on learned confidence
    DECAY_DAYS = 90              # Days before confidence decay starts

    # Stopwords to remove during tokenization
    STOPWORDS = {
        'the', 'a', 'an', 'to', 'for', 'of', 'and', 'in', 'on', 'with',
        'is', 'it', 'that', 'this', 'be', 'are', 'was', 'were', 'been',
        'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
        'should', 'may', 'might', 'must', 'can'
    }

    def __init__(self, store: FeedbackStore):
        """
        Initialize with a FeedbackStore instance.

        Args:
            store: FeedbackStore for persistence
        """
        self.store = store

    def add_classification(
        self,
        description: str,
        classified_as: str,
        confidence: float,
        source: str = "semantic"
    ) -> ClassificationEntry:
        """
        Add a new classification to history.

        Args:
            description: The problem description
            classified_as: The classification type
            confidence: Confidence level (0.0 to 1.0)
            source: Classification source ("semantic", "keyword", "user", "learned")

        Returns:
            The created ClassificationEntry
        """
        entry_id = str(uuid.uuid4())
        description_hash = hashlib.sha256(
            description.lower().strip().encode()
        ).hexdigest()[:16]

        entry = ClassificationEntry(
            id=entry_id,
            description=description,
            description_hash=description_hash,
            classified_as=classified_as,
            confidence=confidence,
            corrected_to=None,
            correction_confidence=0.0,
            timestamp=datetime.now().isoformat(),
            source=source
        )

        self.store.add_classification(entry)
        return entry

    def record_correction(self, entry_id: str, corrected_to: str) -> None:
        """
        Record a user correction for a classification.

        If corrected_to is the same as the original, no correction is recorded.

        Args:
            entry_id: ID of the entry to correct
            corrected_to: The corrected classification type
        """
        entries = self.store.get_classification_history()

        for entry_dict in entries:
            if entry_dict.get("id") == entry_id:
                # Don't record if correcting to same type
                if entry_dict.get("classified_as") == corrected_to:
                    return

                # Update the entry with correction
                entry_dict["corrected_to"] = corrected_to
                entry_dict["correction_confidence"] = 1.0

                # Also record in corrections index
                self.store.record_correction(
                    description_hash=entry_dict.get("description_hash", ""),
                    original=entry_dict.get("classified_as", ""),
                    corrected=corrected_to
                )

                # Save updated entry back
                self._update_entry(entry_id, entry_dict)
                return

    def _update_entry(self, entry_id: str, updated_dict: dict) -> None:
        """
        Update an entry in the classification history.

        Args:
            entry_id: ID of entry to update
            updated_dict: Updated entry dictionary
        """
        # Load current data
        data = self.store._load_file("classification")

        # Find and update the entry
        for i, entry in enumerate(data.get("entries", [])):
            if entry.get("id") == entry_id:
                data["entries"][i] = updated_dict
                break

        # Save back
        self.store._save_file("classification", data)

    def find_similar(
        self,
        description: str,
        min_similarity: float = 0.5
    ) -> list[tuple[ClassificationEntry, float]]:
        """
        Find similar descriptions in history.

        Args:
            description: Description to match
            min_similarity: Minimum similarity threshold

        Returns:
            List of (entry, similarity) tuples, sorted by similarity descending
        """
        if not description or not description.strip():
            return []

        entries = self.store.get_classification_history()
        if not entries:
            return []

        results: list[tuple[ClassificationEntry, float]] = []

        for entry_dict in entries:
            stored_desc = entry_dict.get("description", "")
            similarity = self._calculate_similarity(description, stored_desc)

            if similarity >= min_similarity:
                entry = ClassificationEntry.from_dict(entry_dict)
                results.append((entry, similarity))

        # Sort by similarity descending
        results.sort(key=lambda x: -x[1])
        return results

    def get_learned_classification(
        self,
        description: str
    ) -> Optional[tuple[str, float, str]]:
        """
        Get a learned classification for a description.

        Algorithm:
        1. Find similar past descriptions
        2. Check if any have corrections
        3. Weight by similarity and correction count
        4. Apply confidence decay
        5. Return if above threshold

        Args:
            description: Description to classify

        Returns:
            Tuple of (type, confidence, rationale) or None if no match
        """
        if not description or not description.strip():
            return None

        similar = self.find_similar(description)

        if not similar:
            return None

        # Find best match with correction
        for entry, similarity in similar:
            if entry.corrected_to:
                correction_count = self.get_correction_count(entry.description_hash)
                days_old = self._days_since(entry.timestamp)

                confidence = self.calculate_learned_confidence(
                    base_confidence=similarity * 0.8,
                    correction_count=correction_count,
                    days_since_last=days_old
                )

                if confidence > 0.5:
                    return (
                        entry.corrected_to,
                        confidence,
                        f"Learned from similar description (similarity: {similarity:.0%})"
                    )

        # No corrections found, use best match if confident enough
        best_entry, best_sim = similar[0]
        if best_sim > 0.9:
            return (
                best_entry.classified_as,
                best_sim * 0.7,
                f"Similar to previous classification (similarity: {best_sim:.0%})"
            )

        return None

    def get_correction_count(self, description_hash: str) -> int:
        """
        Get the number of corrections for a description hash.

        Args:
            description_hash: The description hash to look up

        Returns:
            Number of corrections recorded
        """
        data = self.store._load_file("classification")
        corrections = data.get("corrections", {})

        if description_hash in corrections:
            return 1  # Currently tracking presence, not count

        return 0

    def calculate_learned_confidence(
        self,
        base_confidence: float,
        correction_count: int,
        days_since_last: int
    ) -> float:
        """
        Calculate confidence with boost from corrections and decay over time.

        Formula:
        confidence = base + (CORRECTION_BOOST * min(3, corrections)) - decay
        where decay = 0 if < DECAY_DAYS, else 0.1 per 30 days over threshold

        Args:
            base_confidence: Starting confidence (0.0 to 1.0)
            correction_count: Number of user corrections
            days_since_last: Days since last activity

        Returns:
            Adjusted confidence (capped at MAX_CONFIDENCE, minimum 0.0)
        """
        # Boost from corrections (up to 3)
        boost = self.CORRECTION_BOOST * min(3, correction_count)

        # Decay after threshold
        decay = 0.0
        if days_since_last > self.DECAY_DAYS:
            extra_days = days_since_last - self.DECAY_DAYS
            decay = 0.1 * (extra_days // 30)

        confidence = base_confidence + boost - decay
        return max(0.0, min(self.MAX_CONFIDENCE, confidence))

    def get_all_corrections(self) -> dict[str, dict]:
        """
        Get all recorded corrections.

        Returns:
            Dictionary mapping description_hash to correction info
        """
        data = self.store._load_file("classification")
        return data.get("corrections", {})

    def clear_old_entries(self, days_old: int = 180) -> int:
        """
        Remove entries older than the specified number of days.

        Args:
            days_old: Remove entries older than this many days

        Returns:
            Number of entries removed
        """
        data = self.store._load_file("classification")
        entries = data.get("entries", [])

        now = datetime.now()
        original_count = len(entries)

        # Filter out old entries
        new_entries = []
        for entry in entries:
            timestamp_str = entry.get("timestamp", "")
            if timestamp_str:
                try:
                    timestamp = datetime.fromisoformat(timestamp_str)
                    age_days = (now - timestamp).days
                    if age_days < days_old:
                        new_entries.append(entry)
                except ValueError:
                    # Keep entries with invalid timestamps
                    new_entries.append(entry)
            else:
                new_entries.append(entry)

        removed = original_count - len(new_entries)

        if removed > 0:
            data["entries"] = new_entries
            self.store._save_file("classification", data)

        return removed

    def _tokenize(self, text: str) -> list[str]:
        """
        Tokenize text into normalized words.

        Removes stopwords and words shorter than 3 characters.

        Args:
            text: Text to tokenize

        Returns:
            List of normalized word tokens
        """
        words = re.findall(r'\w+', text.lower())
        return [w for w in words if w not in self.STOPWORDS and len(w) > 2]

    def _calculate_similarity(self, desc1: str, desc2: str) -> float:
        """
        Calculate Jaccard similarity between two descriptions.

        Args:
            desc1: First description
            desc2: Second description

        Returns:
            Similarity score (0.0 to 1.0)
        """
        tokens1 = set(self._tokenize(desc1))
        tokens2 = set(self._tokenize(desc2))

        if not tokens1 or not tokens2:
            return 0.0

        intersection = tokens1 & tokens2
        union = tokens1 | tokens2

        return len(intersection) / len(union)

    def _days_since(self, timestamp_str: str) -> int:
        """
        Calculate days since a timestamp.

        Args:
            timestamp_str: ISO-8601 timestamp string

        Returns:
            Number of days since the timestamp
        """
        if not timestamp_str:
            return 0

        try:
            timestamp = datetime.fromisoformat(timestamp_str)
            return (datetime.now() - timestamp).days
        except ValueError:
            return 0


# Convenience function
def get_classification_history(store: FeedbackStore) -> ClassificationHistory:
    """
    Get a ClassificationHistory instance.

    Args:
        store: FeedbackStore instance

    Returns:
        ClassificationHistory instance
    """
    return ClassificationHistory(store)
