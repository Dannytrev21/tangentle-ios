"""
Problem Classifier for the Windsurf Planning System.

This module provides automatic classification of problem descriptions into
problem types, enabling intelligent technique selection downstream.

Uses standard library only - no pip dependencies.
"""

from dataclasses import dataclass
from pathlib import Path
from typing import Optional
import json
import re


@dataclass
class ClassificationResult:
    """Result of classifying a problem description."""
    primary_type: str           # Best match (e.g., "debug")
    primary_category: str       # Parent category (e.g., "LOGIC")
    confidence: float           # 0.0 to 1.0
    alternatives: list[tuple[str, float]]  # [(type, confidence), ...]
    reasoning: str              # Explanation for selection
    keywords_matched: list[str] # Which keywords triggered this


# 33 problem types across 8 categories
PROBLEM_TYPES = {
    "FOUNDATION": {
        "subtypes": {
            "infrastructure": {
                "keywords": ["setup", "environment", "install", "configure", "init", "scaffold", "directory", "structure"],
                "riskLevel": "low"
            },
            "scaffolding": {
                "keywords": ["scaffold", "template", "boilerplate", "skeleton", "starter"],
                "riskLevel": "low"
            },
            "configuration": {
                "keywords": ["config", "configure", "settings", "options", "environment", "env"],
                "riskLevel": "low"
            }
        }
    },
    "DATA": {
        "subtypes": {
            "data-modeling": {
                "keywords": ["model", "entity", "schema", "data model", "core data", "struct", "class"],
                "riskLevel": "medium"
            },
            "data-access": {
                "keywords": ["repository", "dao", "fetch", "query", "database", "persistence", "storage"],
                "riskLevel": "medium"
            },
            "migration": {
                "keywords": ["migrate", "migration", "upgrade", "version", "schema change", "data migration"],
                "riskLevel": "high"
            },
            "state-mgmt": {
                "keywords": ["state", "store", "redux", "observable", "binding", "viewmodel"],
                "riskLevel": "medium"
            }
        }
    },
    "ARCHITECTURE": {
        "subtypes": {
            "system-design": {
                "keywords": ["architecture", "design", "system", "structure", "pattern", "layer"],
                "riskLevel": "high"
            },
            "protocol-design": {
                "keywords": ["protocol", "interface", "contract", "abstraction", "api design"],
                "riskLevel": "medium"
            },
            "di-setup": {
                "keywords": ["dependency injection", "di", "container", "inject", "resolve"],
                "riskLevel": "medium"
            },
            "service-impl": {
                "keywords": ["service", "manager", "handler", "controller", "interactor", "usecase"],
                "riskLevel": "high"
            },
            "refactor": {
                "keywords": ["refactor", "restructure", "reorganize", "cleanup", "improve", "simplify"],
                "riskLevel": "medium"
            }
        }
    },
    "UI_UX": {
        "subtypes": {
            "ui": {
                "keywords": ["ui", "view", "screen", "page", "component", "swiftui", "uikit", "layout"],
                "riskLevel": "medium"
            },
            "component-lib": {
                "keywords": ["component", "library", "design system", "reusable", "widget"],
                "riskLevel": "medium"
            },
            "design-tokens": {
                "keywords": ["token", "theme", "color", "typography", "spacing", "style"],
                "riskLevel": "low"
            },
            "animation": {
                "keywords": ["animation", "transition", "animate", "motion", "keyframe"],
                "riskLevel": "medium"
            },
            "gesture": {
                "keywords": ["gesture", "tap", "swipe", "drag", "pan", "pinch", "touch"],
                "riskLevel": "medium"
            },
            "accessibility": {
                "keywords": ["accessibility", "a11y", "voiceover", "accessible", "dynamic type"],
                "riskLevel": "medium"
            },
            "polish": {
                "keywords": ["polish", "finish", "tweak", "adjust", "fine-tune"],
                "riskLevel": "low"
            }
        }
    },
    "TESTING": {
        "subtypes": {
            "test-setup": {
                "keywords": ["test setup", "testing infrastructure", "test config", "test framework"],
                "riskLevel": "low"
            },
            "unit-test": {
                "keywords": ["unit test", "unit tests", "test function", "test method"],
                "riskLevel": "low"
            },
            "integration-test": {
                "keywords": ["integration test", "integration tests", "test integration"],
                "riskLevel": "medium"
            },
            "snapshot-test": {
                "keywords": ["snapshot", "snapshot test", "visual test", "screenshot"],
                "riskLevel": "low"
            },
            "e2e-test": {
                "keywords": ["e2e", "end-to-end", "ui test", "xcuitest", "automation"],
                "riskLevel": "medium"
            },
            "performance-test": {
                "keywords": ["performance", "benchmark", "profile", "speed", "memory test"],
                "riskLevel": "medium"
            }
        }
    },
    "LOGIC": {
        "subtypes": {
            "algorithm": {
                "keywords": ["algorithm", "sort", "search", "calculate", "compute", "logic"],
                "riskLevel": "medium"
            },
            "validation": {
                "keywords": ["validate", "validation", "verify", "check", "sanitize", "parse"],
                "riskLevel": "medium"
            },
            "api-integration": {
                "keywords": ["api", "rest", "http", "network", "request", "response", "endpoint"],
                "riskLevel": "high"
            },
            "debug": {
                "keywords": ["bug", "fix", "crash", "error", "debug", "issue", "problem", "broken"],
                "riskLevel": "medium"
            }
        }
    },
    "DOCUMENTATION": {
        "subtypes": {
            "documentation": {
                "keywords": ["doc", "document", "readme", "guide", "comment", "explain"],
                "riskLevel": "low"
            },
            "changelog": {
                "keywords": ["changelog", "release notes", "version history", "changes"],
                "riskLevel": "low"
            }
        }
    },
    "META": {
        "subtypes": {
            "ideation": {
                "keywords": ["idea", "brainstorm", "explore", "research", "investigate"],
                "riskLevel": "low"
            },
            "new-feature": {
                "keywords": ["feature", "new", "add", "create", "implement", "build"],
                "riskLevel": "medium"
            }
        }
    }
}

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


class ProblemClassifier:
    """
    Classifies problem descriptions into predefined problem types.

    Uses keyword matching with weighted scoring, context-aware refinement,
    and confidence calibration to determine the best problem type match.
    """

    # Calibration factor for confidence scores
    CALIBRATION_FACTOR = 0.85

    # Minimum confidence threshold before suggesting alternatives
    LOW_CONFIDENCE_THRESHOLD = 0.5

    def __init__(self, config_path: Optional[str] = None):
        """
        Initialize the classifier.

        Args:
            config_path: Optional path to technique configuration file.
                        If provided and exists, will use config keywords.
                        Otherwise uses built-in PROBLEM_TYPES.
        """
        self.config_path = Path(config_path) if config_path else None
        self._load_config()
        self._build_keyword_index()

    def _load_config(self) -> None:
        """Load and parse the technique configuration file if it exists."""
        self.config = {"problemTypes": PROBLEM_TYPES}

        if self.config_path and self.config_path.exists():
            try:
                with open(self.config_path, 'r') as f:
                    loaded = json.load(f)
                    if "problemTypes" in loaded:
                        self.config = loaded
            except (json.JSONDecodeError, IOError):
                pass  # Use defaults

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
        if keyword in GENERIC_KEYWORDS:
            normalized *= 0.3  # Heavy penalty

        # Boost domain-specific keywords
        if keyword in SPECIFIC_KEYWORDS:
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
        return self.type_to_category.get(problem_type, "META")

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
        return ClassificationResult(
            primary_type="new-feature",
            primary_category="META",
            confidence=0.3,
            alternatives=[],
            reasoning=f"Fallback classification: {reason}. "
                      f"Defaulting to 'new-feature'. Consider manual classification.",
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

    def get_all_types(self) -> list[str]:
        """Get all available problem types."""
        return list(self.keyword_index.keys())

    def get_type_info(self, problem_type: str) -> Optional[dict]:
        """
        Get full info for a problem type including description and risk.

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
