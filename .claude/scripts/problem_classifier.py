"""
Problem Classifier for the Intelligent Planning System.

This module provides automatic classification of problem descriptions into
problem types, enabling intelligent technique selection downstream.
"""

from dataclasses import dataclass
from pathlib import Path
from typing import Optional
import json
import logging
import re

logger = logging.getLogger(__name__)


@dataclass
class ClassificationResult:
    """Result of classifying a problem description."""
    primary_type: str           # Best match (e.g., "debug")
    primary_category: str       # Parent category (e.g., "LOGIC")
    confidence: float           # 0.0 to 1.0
    alternatives: list[tuple[str, float]]  # [(type, confidence), ...]
    reasoning: str              # Explanation for selection
    keywords_matched: list[str] # Which keywords triggered this


class ProblemClassifier:
    """
    Classifies problem descriptions into predefined problem types.

    Uses keyword matching with weighted scoring, context-aware refinement,
    and confidence calibration to determine the best problem type match.
    """

    # Calibration factor for confidence scores
    # Tuned to make confidence scores meaningful (high confidence = likely correct)
    CALIBRATION_FACTOR = 0.85

    # Minimum confidence threshold before suggesting alternatives
    LOW_CONFIDENCE_THRESHOLD = 0.5

    # Generic keywords that appear in many descriptions - penalize these
    GENERIC_KEYWORDS = {'add', 'new', 'create', 'build', 'implement', 'feature'}

    # Domain-specific keywords that should get extra weight
    SPECIFIC_KEYWORDS = {
        'screen', 'view', 'ui', 'layout', 'button',  # UI
        'api', 'oauth', 'rest', 'http', 'network', 'authentication',  # API
        'refactor', 'restructure', 'reorganize', 'cleanup',  # Refactor
        'bug', 'fix', 'crash', 'error', 'debug',  # Debug
        'test', 'unit test', 'assert', 'mock',  # Testing
        'algorithm', 'sort', 'search', 'optimize',  # Algorithm
    }

    def __init__(self, config_path: str = ".claude/technique-config.json"):
        """
        Initialize with technique configuration.

        Args:
            config_path: Path to the technique configuration JSON file
        """
        self.config_path = Path(config_path)
        self._load_config()
        self._build_keyword_index()

    def _load_config(self) -> None:
        """Load and parse the technique configuration file."""
        try:
            with open(self.config_path, 'r') as f:
                self.config = json.load(f)
        except FileNotFoundError:
            raise FileNotFoundError(
                f"Technique config not found at {self.config_path}. "
                "Run Step 1 to create it."
            )
        except json.JSONDecodeError as e:
            raise ValueError(f"Invalid JSON in config file: {e}")

    def _build_keyword_index(self) -> None:
        """Build index mapping keywords to problem types for fast lookup."""
        self.keyword_index: dict[str, list[str]] = {}
        self.type_to_category: dict[str, str] = {}

        for category, cat_data in self.config.get('problemTypes', {}).items():
            for subtype, sub_data in cat_data.get('subtypes', {}).items():
                keywords = sub_data.get('keywords', [])
                self.keyword_index[subtype] = [kw.lower() for kw in keywords]
                self.type_to_category[subtype] = category

    def classify(
        self,
        description: str,
        context: Optional[dict] = None
    ) -> ClassificationResult:
        """
        Classify a problem description into a problem type.

        Args:
            description: The problem description text
            context: Optional context dict with keys like:
                - plan_type: The overall plan category
                - previous_steps: List of completed step types
                - codebase_type: The type of codebase (ios, web, etc.)

        Returns:
            ClassificationResult with top matches and confidence scores
        """
        if not description or not description.strip():
            return self._fallback_result(description, "Empty description provided")

        # Normalize input
        desc_lower = description.lower()

        # Step 1: Keyword matching
        scores, matched_keywords = self._score_keywords(desc_lower)

        # Step 2: Category inference (boost types in detected categories)
        scores = self._apply_category_inference(scores, desc_lower)

        # Step 3: Context adjustment
        if context:
            scores = self._apply_context(scores, context)

        # Step 4: Handle no matches
        if not scores:
            return self._fallback_result(description, "No keywords matched")

        # Step 5: Normalize scores to confidence values
        max_score = max(scores.values())
        normalized = {k: min(1.0, (v / max_score) * self.CALIBRATION_FACTOR)
                      for k, v in scores.items()}

        # Step 6: Build result
        sorted_types = sorted(normalized.items(), key=lambda x: -x[1])
        primary = sorted_types[0][0]
        primary_confidence = sorted_types[0][1]

        # Get alternatives (exclude primary, top 3)
        alternatives = [(t, c) for t, c in sorted_types[1:4]]

        # Generate reasoning
        reasoning = self._generate_reasoning(
            primary,
            matched_keywords.get(primary, []),
            primary_confidence
        )

        return ClassificationResult(
            primary_type=primary,
            primary_category=self._get_category(primary),
            confidence=primary_confidence,
            alternatives=alternatives,
            reasoning=reasoning,
            keywords_matched=matched_keywords.get(primary, [])
        )

    def _score_keywords(
        self,
        desc_lower: str
    ) -> tuple[dict[str, float], dict[str, list[str]]]:
        """
        Score each problem type based on keyword matches.

        Returns:
            Tuple of (scores dict, matched_keywords dict)
        """
        scores: dict[str, float] = {}
        matched_keywords: dict[str, list[str]] = {}

        for problem_type, keywords in self.keyword_index.items():
            score = 0.0
            matches: list[str] = []

            for kw in keywords:
                # Check for keyword match
                # Use word boundary matching for short keywords
                if len(kw) <= 3:
                    # Short keywords need word boundaries
                    pattern = r'\b' + re.escape(kw) + r'\b'
                    if re.search(pattern, desc_lower):
                        weight = self._get_keyword_weight(kw, len(keywords))
                        score += weight
                        matches.append(kw)
                else:
                    # Longer keywords can use substring match
                    if kw in desc_lower:
                        weight = self._get_keyword_weight(kw, len(keywords))
                        score += weight
                        matches.append(kw)

            if score > 0:
                scores[problem_type] = score
                matched_keywords[problem_type] = matches

        return scores, matched_keywords

    def _get_keyword_weight(self, keyword: str, total_keywords: int) -> float:
        """
        Calculate weight for a keyword match.

        Longer keywords are weighted higher (more specific).
        Types with fewer keywords get boosted (more selective).
        Generic keywords get penalized.
        Domain-specific keywords get boosted.

        Args:
            keyword: The matched keyword
            total_keywords: Total keywords for this problem type

        Returns:
            Weight value for this keyword match
        """
        # Base weight increases with keyword length (specificity)
        base_weight = 1.0 + (len(keyword) / 20)

        # Normalize by total keywords (fewer keywords = more selective)
        normalized = base_weight / (total_keywords ** 0.5)

        # Multi-word keywords get extra boost (more specific phrases)
        if ' ' in keyword:
            normalized *= 1.8

        # Penalize generic keywords that appear in many descriptions
        if keyword in self.GENERIC_KEYWORDS:
            normalized *= 0.3  # Heavy penalty

        # Boost domain-specific keywords
        if keyword in self.SPECIFIC_KEYWORDS:
            normalized *= 1.5

        return normalized

    def _apply_category_inference(
        self,
        scores: dict[str, float],
        desc_lower: str
    ) -> dict[str, float]:
        """
        Apply category-level signals to boost related types.

        If we detect strong category signals (e.g., "test"), boost all
        types in that category slightly.
        """
        # Category signal keywords
        category_signals = {
            'TESTING': ['test', 'tests', 'testing', 'spec', 'specs'],
            'UI_UX': ['ui', 'view', 'screen', 'button', 'layout', 'animation'],
            'DATA': ['data', 'model', 'entity', 'database', 'repository'],
            'LOGIC': ['algorithm', 'logic', 'calculation', 'bug', 'fix'],
            'DOCUMENTATION': ['doc', 'document', 'readme', 'guide'],
            'ARCHITECTURE': ['architecture', 'service', 'protocol', 'refactor'],
        }

        # Find categories with signals in description
        boosted_categories: set[str] = set()
        for category, signals in category_signals.items():
            for signal in signals:
                if signal in desc_lower:
                    boosted_categories.add(category)
                    break

        # Apply slight boost to types in detected categories
        if boosted_categories:
            boosted_scores = scores.copy()
            for problem_type, score in scores.items():
                category = self.type_to_category.get(problem_type, '')
                if category in boosted_categories:
                    boosted_scores[problem_type] = score * 1.1
            return boosted_scores

        return scores

    def _apply_context(
        self,
        scores: dict[str, float],
        context: dict
    ) -> dict[str, float]:
        """
        Apply context-aware adjustments to scores.

        Args:
            scores: Current scores dict
            context: Context dict with plan_type, previous_steps, etc.

        Returns:
            Adjusted scores dict
        """
        adjusted = scores.copy()

        # If in a testing plan, boost test types
        plan_type = context.get('plan_type', '').lower()
        if 'test' in plan_type:
            test_types = ['unit-test', 'integration-test', 'e2e-test',
                         'snapshot-test', 'performance-test', 'test-setup']
            for t in test_types:
                if t in adjusted:
                    adjusted[t] *= 1.2

        # If in a UI plan, boost UI types
        if any(x in plan_type for x in ['ui', 'view', 'screen']):
            ui_types = ['ui', 'component-lib', 'design-tokens',
                       'animation', 'gesture', 'accessibility', 'polish']
            for t in ui_types:
                if t in adjusted:
                    adjusted[t] *= 1.2

        # Boost types similar to previous steps (continuity)
        previous_steps = context.get('previous_steps', [])
        if previous_steps:
            for prev_type in previous_steps[-3:]:  # Last 3 steps
                prev_category = self.type_to_category.get(prev_type, '')
                for problem_type in adjusted:
                    if self.type_to_category.get(problem_type) == prev_category:
                        adjusted[problem_type] *= 1.05

        return adjusted

    def _get_category(self, problem_type: str) -> str:
        """Get the parent category for a problem type."""
        return self.type_to_category.get(problem_type,
                                         self.config.get('defaults', {}).get('unknownCategory', 'META'))

    def _generate_reasoning(
        self,
        problem_type: str,
        keywords: list[str],
        confidence: float
    ) -> str:
        """Generate human-readable reasoning for the classification."""
        if not keywords:
            return f"Classified as '{problem_type}' based on general context analysis."

        kw_list = ', '.join(f"'{kw}'" for kw in keywords[:5])
        confidence_desc = (
            "high" if confidence >= 0.7 else
            "medium" if confidence >= 0.5 else
            "low"
        )

        return (
            f"Classified as '{problem_type}' with {confidence_desc} confidence "
            f"({confidence:.0%}). Matched keywords: {kw_list}."
        )

    def _fallback_result(
        self,
        description: str,
        reason: str
    ) -> ClassificationResult:
        """Return a low-confidence fallback classification."""
        default_type = self.config.get('defaults', {}).get('unknownProblemType', 'new-feature')
        default_category = self.config.get('defaults', {}).get('unknownCategory', 'META')

        return ClassificationResult(
            primary_type=default_type,
            primary_category=default_category,
            confidence=0.3,
            alternatives=[],
            reasoning=f"Fallback classification: {reason}. "
                      f"Defaulting to '{default_type}'. Consider manual classification.",
            keywords_matched=[]
        )

    def get_keywords(self, problem_type: str) -> list[str]:
        """
        Get detection keywords for a problem type.

        Args:
            problem_type: The problem type to get keywords for

        Returns:
            List of keywords, or empty list if type not found
        """
        return self.keyword_index.get(problem_type, [])

    def validate_classification(
        self,
        description: str,
        proposed_type: str
    ) -> bool:
        """
        Check if a proposed classification is reasonable for a description.

        Useful for validating user-provided classifications or
        checking LLM-suggested types.

        Args:
            description: The problem description
            proposed_type: The proposed problem type

        Returns:
            True if the classification seems reasonable
        """
        if proposed_type not in self.keyword_index:
            return False

        result = self.classify(description)

        # Accept if proposed type matches primary or is in alternatives
        if result.primary_type == proposed_type:
            return True

        for alt_type, _ in result.alternatives:
            if alt_type == proposed_type:
                return True

        # Also accept if proposed type's keywords have any matches
        keywords = self.get_keywords(proposed_type)
        desc_lower = description.lower()
        for kw in keywords:
            if kw in desc_lower:
                return True

        return False

    def get_all_types(self) -> list[str]:
        """Get all available problem types."""
        return list(self.keyword_index.keys())

    def get_type_info(self, problem_type: str) -> Optional[dict]:
        """
        Get full info for a problem type including description and techniques.

        Args:
            problem_type: The problem type to look up

        Returns:
            Dict with type info, or None if not found
        """
        category = self.type_to_category.get(problem_type)
        if not category:
            return None

        cat_data = self.config.get('problemTypes', {}).get(category, {})
        type_data = cat_data.get('subtypes', {}).get(problem_type)

        if type_data:
            return {
                'type': problem_type,
                'category': category,
                **type_data
            }
        return None


# CLI entry point for testing
if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        print("Usage: python problem_classifier.py 'description to classify'")
        sys.exit(1)

    description = ' '.join(sys.argv[1:])
    classifier = ProblemClassifier()
    result = classifier.classify(description)

    print(f"Type: {result.primary_type}")
    print(f"Category: {result.primary_category}")
    print(f"Confidence: {result.confidence:.0%}")
    print(f"Reasoning: {result.reasoning}")
    if result.alternatives:
        print(f"Alternatives: {', '.join(f'{t} ({c:.0%})' for t, c in result.alternatives)}")
