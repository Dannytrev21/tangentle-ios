# Step 7: Classification History & Learning

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Clear learning algorithm requirements
- **Implementation**: tdd - Test learning behavior first
- **Verification**: self-refine - Iterate on learning effectiveness

## Risk Level
**medium** - Learning from corrections affects future classifications

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
This step implements the learning component that improves classification over time. When users correct classifications, the system learns from those corrections and applies them to similar future descriptions.

Key features:
- Immediate learning on correction
- Description similarity matching
- Confidence decay for old corrections
- Prevents oscillation

## Goal
Create a ClassificationHistory service that:
1. Stores all classifications with metadata
2. Learns from user corrections
3. Suggests classifications based on similar past descriptions
4. Manages confidence over time

## Prerequisites
- Step 2 (Persistence Layer) completed
- Step 6 (Classification Command) completed

## High-Level Steps
1. Implement ClassificationHistory class
2. Add similarity matching for descriptions
3. Implement learning from corrections
4. Add confidence decay logic
5. Write comprehensive tests

## Detailed Requirements

### ClassificationHistory Class

```python
class ClassificationHistory:
    """
    Manages classification history and learns from corrections.

    Implements immediate learning:
    - Stores all classifications with metadata
    - Tracks corrections and their frequency
    - Matches similar descriptions
    - Decays confidence over time
    """

    SIMILARITY_THRESHOLD = 0.8  # Similarity needed to match
    CORRECTION_BOOST = 0.3      # Confidence boost per correction
    MAX_CONFIDENCE = 0.95       # Cap on learned confidence
    DECAY_DAYS = 90             # Days before confidence decay starts

    def __init__(self, store: FeedbackStore):
        """Initialize with feedback store."""
        self.store = store

    def add_classification(
        self,
        description: str,
        classified_as: str,
        confidence: float,
        source: str = "semantic"
    ) -> ClassificationEntry:
        """
        Add a new classification entry.

        Args:
            description: The problem description
            classified_as: The assigned type
            confidence: Classification confidence
            source: "semantic", "keyword", or "user"
        """

    def record_correction(
        self,
        entry_id: str,
        corrected_to: str
    ) -> None:
        """
        Record a user correction.

        Updates the entry and adds to corrections index
        for future learning.
        """

    def find_similar(
        self,
        description: str,
        min_similarity: float = 0.8
    ) -> list[tuple[ClassificationEntry, float]]:
        """
        Find similar past classifications.

        Returns:
            List of (entry, similarity_score) above threshold
        """

    def get_learned_classification(
        self,
        description: str
    ) -> Optional[tuple[str, float, str]]:
        """
        Get classification based on learned corrections.

        Returns:
            (type, confidence, rationale) or None if no match
        """

    def get_correction_count(
        self,
        description_hash: str
    ) -> int:
        """Get number of times this description was corrected."""

    def calculate_learned_confidence(
        self,
        base_confidence: float,
        correction_count: int,
        days_since_last: int
    ) -> float:
        """
        Calculate confidence for learned classification.

        Factors:
        - Base confidence from original classification
        - Boost from correction count
        - Decay from time since last correction
        """

    def get_all_corrections(self) -> dict[str, dict]:
        """Get all correction records for debugging."""

    def clear_old_entries(self, days_old: int = 180) -> int:
        """Remove entries older than N days. Returns count removed."""
```

### Similarity Matching

Use simple token-based similarity for now (can upgrade later):

```python
def _calculate_similarity(self, desc1: str, desc2: str) -> float:
    """
    Calculate similarity between two descriptions.

    Uses Jaccard similarity on word tokens.
    """
    tokens1 = set(self._tokenize(desc1))
    tokens2 = set(self._tokenize(desc2))

    if not tokens1 or not tokens2:
        return 0.0

    intersection = tokens1 & tokens2
    union = tokens1 | tokens2

    return len(intersection) / len(union)

def _tokenize(self, text: str) -> list[str]:
    """Tokenize text into normalized words."""
    import re
    # Lowercase, split on non-alphanumeric
    words = re.findall(r'\w+', text.lower())
    # Remove very common words
    stopwords = {'the', 'a', 'an', 'to', 'for', 'of', 'and', 'in', 'on', 'with'}
    return [w for w in words if w not in stopwords and len(w) > 2]
```

### Learning Algorithm

```python
def get_learned_classification(self, description: str):
    """
    Get classification based on learned corrections.

    Algorithm:
    1. Find similar past descriptions
    2. Check if any have corrections
    3. Weight by similarity and correction count
    4. Apply confidence decay
    5. Return if above threshold
    """
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

            if confidence > 0.5:  # Minimum threshold
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
```

### Confidence Decay

```python
def calculate_learned_confidence(
    self,
    base_confidence: float,
    correction_count: int,
    days_since_last: int
) -> float:
    """
    Calculate confidence with boosts and decay.

    Formula:
    confidence = base + (correction_boost * min(3, corrections)) - decay

    Where decay = 0 if < DECAY_DAYS, else 0.1 per 30 days over
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
```

### Integration with /classify

The `/classify` command should use this service:

```python
# In classify.md processing
history = ClassificationHistory(store)

# Check learned classification first
learned = history.get_learned_classification(description)
if learned:
    learned_type, learned_conf, learned_rationale = learned
    # Include in classification output
    # "Based on similar past description: {learned_rationale}"
```

## Files to Create
- `.claude/scripts/classification_history.py`: Learning service

## Files to Modify
- `.claude/commands/classify.md`: Integrate learned classifications

## Patterns to Follow
Reference: `.claude/scripts/memory_bank.py` for entry management

## Acceptance Criteria
- [ ] Classifications stored with full metadata
- [ ] Corrections recorded and tracked
- [ ] Similar descriptions matched correctly
- [ ] Learned confidence calculated correctly
- [ ] Old entries decay appropriately
- [ ] All tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/tests/test_classification_history.py`
- [ ] Test cases:
  - `test_add_classification_creates_entry()`
  - `test_record_correction_updates_entry()`
  - `test_find_similar_above_threshold()`
  - `test_find_similar_below_threshold_empty()`
  - `test_get_learned_classification_from_correction()`
  - `test_get_learned_classification_no_match()`
  - `test_confidence_boost_from_corrections()`
  - `test_confidence_decay_after_threshold()`
  - `test_confidence_capped_at_max()`
  - `test_clear_old_entries()`
  - `test_tokenization_removes_stopwords()`
  - `test_similarity_identical_strings()`
  - `test_similarity_different_strings()`

### What to Test
- Similarity algorithm edge cases
- Confidence calculation boundaries
- Decay timing
- Multiple corrections of same description

## Verification Commands
```bash
# Run tests
cd .claude && python3 -m pytest tests/test_classification_history.py -v

# Manual verification
python3 -c "
from scripts.feedback_store import FeedbackStore
from scripts.classification_history import ClassificationHistory

store = FeedbackStore()
history = ClassificationHistory(store)

# Add and correct
entry = history.add_classification('Add tests for auth module', 'unit-test', 0.9)
history.record_correction(entry.id, 'integration-test')

# Check learning
result = history.get_learned_classification('Add tests for authentication')
print('Learned:', result)
"
```

## Documentation Updates
- [ ] Document learning algorithm in knowledge docs

## Error Recovery
If verification fails:
1. Check similarity threshold
2. Verify confidence calculation
3. Test tokenization edge cases

## Do NOT
- Use complex ML libraries
- Store more than needed
- Skip confidence decay
