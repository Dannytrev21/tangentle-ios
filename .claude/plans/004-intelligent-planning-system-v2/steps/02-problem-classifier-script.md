# Step 2: Problem Classifier Script

## Context
With the technique configuration in place, we need a way to automatically classify incoming problem descriptions into the appropriate problem type. This classifier is the first step in the intelligent technique selection pipeline.

## Goal
Create a Python script that analyzes problem descriptions and returns the most likely problem type(s) with confidence scores.

## Problem Type
`algorithm`

## Technique Selection
- **Planning**: Self-Consistency (explore multiple classification approaches)
- **Implementation**: TDD (test-driven with classification examples)
- **Verification**: Reflexion (learn from misclassifications)

## Risk Level
**Medium** - Classification accuracy affects downstream quality

## Prerequisites
- Step 1 completed (technique-config.json exists)

## High-Level Steps
1. Design the classifier interface
2. Implement keyword-based initial classification
3. Add context-aware refinement logic
4. Implement confidence scoring
5. Add fallback to LLM-based classification
6. Create classification result caching
7. Write comprehensive tests

## Detailed Requirements

### Interface
```python
class ProblemClassifier:
    def __init__(self, config_path: str = ".claude/technique-config.json"):
        """Initialize with technique configuration."""

    def classify(
        self,
        description: str,
        context: dict = None
    ) -> ClassificationResult:
        """
        Classify a problem description.

        Args:
            description: The problem description text
            context: Optional context (codebase info, previous steps, etc.)

        Returns:
            ClassificationResult with top matches and confidence scores
        """

    def get_keywords(self, problem_type: str) -> list[str]:
        """Get detection keywords for a problem type."""

    def validate_classification(
        self,
        description: str,
        proposed_type: str
    ) -> bool:
        """Check if a proposed classification is reasonable."""

@dataclass
class ClassificationResult:
    primary_type: str           # Best match
    primary_category: str       # Parent category
    confidence: float           # 0.0 to 1.0
    alternatives: list[tuple[str, float]]  # [(type, confidence), ...]
    reasoning: str              # Explanation for selection
    keywords_matched: list[str] # Which keywords triggered this
```

### Classification Algorithm
```
1. KEYWORD MATCHING
   - Scan description for known keywords
   - Weight exact matches higher than partial
   - Score = sum(keyword_weights)

2. CONTEXT ENRICHMENT
   - If step context provided, use dependencies
   - If in testing plan, bias toward test types
   - If in UI plan, bias toward UI types

3. CATEGORY INFERENCE
   - Determine parent category first
   - Then narrow to subtype
   - Reduces false positives

4. CONFIDENCE CALCULATION
   confidence = min(1.0, (
       keyword_score * 0.4 +
       context_score * 0.3 +
       category_clarity * 0.3
   ))

5. FALLBACK
   - If confidence < 0.5, suggest LLM classification
   - Return top 3 alternatives for user confirmation
```

### Keyword Examples
```python
KEYWORDS = {
    "debug": ["fix", "bug", "error", "crash", "issue", "broken", "not working"],
    "refactor": ["refactor", "clean up", "reorganize", "restructure", "simplify"],
    "ui": ["view", "screen", "button", "layout", "display", "show", "render"],
    "test-setup": ["test infrastructure", "testing framework", "test setup"],
    "unit-test": ["unit test", "test case", "test function"],
    "algorithm": ["algorithm", "sort", "search", "optimize", "calculate"],
    # ... etc
}
```

## Files to Create
- `.claude/scripts/problem_classifier.py`: Main classifier implementation
- `.claude/scripts/test_problem_classifier.py`: Unit tests

## Files to Modify
- `.claude/scripts/__init__.py`: Export classifier

## Patterns to Follow
Follow Python best practices:
- Type hints throughout
- Dataclasses for structured data
- Comprehensive docstrings
- Logging for debugging

## Acceptance Criteria
- [ ] Classifier correctly identifies 90%+ of common problem types
- [ ] Confidence scores are calibrated (high confidence = likely correct)
- [ ] Fallback mechanism works for ambiguous cases
- [ ] Classification reasoning is human-readable
- [ ] Performance: <100ms for typical descriptions
- [ ] All unit tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/scripts/test_problem_classifier.py`
- [ ] Test cases:
  - `test_classify_debug_description()`
  - `test_classify_ui_description()`
  - `test_classify_algorithm_description()`
  - `test_classify_ambiguous_returns_low_confidence()`
  - `test_classify_with_context_improves_accuracy()`
  - `test_get_keywords_returns_valid_list()`
  - `test_validate_classification_catches_mismatches()`

### Test Data
```python
TEST_CASES = [
    ("Fix the crash when user taps the save button", "debug", 0.8),
    ("Add a new screen for user profile settings", "ui", 0.7),
    ("Implement binary search for task lookup", "algorithm", 0.9),
    ("Write unit tests for TaskRepository", "unit-test", 0.9),
    ("Reorganize the service layer for better testability", "refactor", 0.8),
]
```

## Verification Commands
```bash
# Run classifier tests
cd .claude/scripts && python3 -m pytest test_problem_classifier.py -v

# Test classification interactively
python3 -c "
from problem_classifier import ProblemClassifier
c = ProblemClassifier()
result = c.classify('Fix the bug where tasks disappear')
print(f'Type: {result.primary_type}, Confidence: {result.confidence:.2f}')
print(f'Reasoning: {result.reasoning}')
"
```

## Documentation Updates
- [ ] Add classifier usage to CLAUDE.md

## Error Recovery
If classification accuracy is low:
1. Review keyword lists for gaps
2. Add more context-aware rules
3. Consider adding ML-based classification

## Do NOT
- Hard-code specific project patterns (keep generic)
- Require external API calls for basic classification
- Return random guesses when uncertain (use fallback instead)
