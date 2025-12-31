"""
Risk Assessor for the Intelligent Planning System.

This module provides risk assessment based on multiple weighted factors
and returns appropriate retry configurations for step execution.
"""

from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Optional, Callable
import json
import logging

logger = logging.getLogger(__name__)


class RiskLevel(Enum):
    """Risk levels for step assessment."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


@dataclass
class StepInfo:
    """Information about a step for risk assessment."""
    problem_type: str
    files_to_create: list[str] = field(default_factory=list)
    files_to_modify: list[str] = field(default_factory=list)
    dependencies: list[str] = field(default_factory=list)
    has_data_migration: bool = False
    has_external_api: bool = False
    affects_persistence: bool = False
    is_breaking_change: bool = False
    complexity_estimate: str = "medium"  # low/medium/high


@dataclass
class RiskFactor:
    """A single risk factor with its contribution."""
    name: str
    weight: float
    present: bool
    contribution: float
    description: str = ""


@dataclass
class RetryConfig:
    """Configuration for retry behavior based on risk level."""
    max_same_technique: int
    max_alternative_technique: int
    max_total: int
    escalation_threshold: int
    techniques_rotation: list[str] = field(default_factory=list)


@dataclass
class RiskAssessment:
    """Result of risk assessment."""
    level: RiskLevel
    score: float  # 0.0 to 1.0
    factors: list[RiskFactor]
    retry_config: RetryConfig
    explanation: str
    mitigations: list[str] = field(default_factory=list)


@dataclass
class EscalationDecision:
    """Decision about whether to escalate."""
    should_escalate: bool
    reason: str
    recommended_action: str  # "retry", "switch_technique", "user_intervention"


# Risk factor definitions with weights and checks
RISK_FACTORS: dict[str, dict] = {
    # High-weight factors (0.2-0.3) - increase risk
    "data_migration": {
        "weight": 0.3,
        "description": "Modifies persistent data structures",
        "check": lambda s: s.has_data_migration
    },
    "breaking_change": {
        "weight": 0.25,
        "description": "Changes that may break existing code",
        "check": lambda s: s.is_breaking_change
    },
    "external_api": {
        "weight": 0.2,
        "description": "Depends on external services",
        "check": lambda s: s.has_external_api
    },

    # Medium-weight factors (0.1-0.2) - increase risk
    "many_file_modifications": {
        "weight": 0.15,
        "description": "Modifies more than 5 files",
        "check": lambda s: len(s.files_to_modify) > 5
    },
    "affects_persistence": {
        "weight": 0.15,
        "description": "Modifies Core Data or persistence layer",
        "check": lambda s: s.affects_persistence
    },
    "complex_dependencies": {
        "weight": 0.1,
        "description": "Has more than 3 step dependencies",
        "check": lambda s: len(s.dependencies) > 3
    },
    "high_complexity": {
        "weight": 0.1,
        "description": "Estimated complexity is high",
        "check": lambda s: s.complexity_estimate == "high"
    },

    # Negative factors (reduce risk)
    "new_files_only": {
        "weight": -0.1,
        "description": "Only creates new files, no modifications",
        "check": lambda s: len(s.files_to_create) > 0 and len(s.files_to_modify) == 0
    },
    "documentation_only": {
        "weight": -0.2,
        "description": "Only documentation changes",
        "check": lambda s: s.problem_type in ["documentation", "changelog"]
    },
    "low_complexity": {
        "weight": -0.05,
        "description": "Estimated complexity is low",
        "check": lambda s: s.complexity_estimate == "low"
    },
}


# Retry configurations per risk level
RETRY_CONFIGS: dict[RiskLevel, RetryConfig] = {
    RiskLevel.LOW: RetryConfig(
        max_same_technique=2,
        max_alternative_technique=1,
        max_total=3,
        escalation_threshold=2,
        techniques_rotation=["ps-plus", "self-refine"]
    ),
    RiskLevel.MEDIUM: RetryConfig(
        max_same_technique=3,
        max_alternative_technique=2,
        max_total=5,
        escalation_threshold=3,
        techniques_rotation=["self-refine", "tdd", "reflexion"]
    ),
    RiskLevel.HIGH: RetryConfig(
        max_same_technique=3,
        max_alternative_technique=3,
        max_total=7,
        escalation_threshold=5,
        techniques_rotation=["reflexion", "tdd", "self-consistency"]
    ),
    RiskLevel.CRITICAL: RetryConfig(
        max_same_technique=5,
        max_alternative_technique=5,
        max_total=10,
        escalation_threshold=7,
        techniques_rotation=["reflexion", "self-consistency", "tot"]
    ),
}


# Mitigation suggestions per factor
MITIGATION_SUGGESTIONS: dict[str, list[str]] = {
    "data_migration": [
        "Create a backup before migration",
        "Test with sample data first",
        "Implement rollback mechanism"
    ],
    "breaking_change": [
        "Review all dependent code",
        "Add deprecation warnings first",
        "Create migration guide"
    ],
    "external_api": [
        "Add timeout handling",
        "Implement retry logic",
        "Add fallback behavior"
    ],
    "many_file_modifications": [
        "Break into smaller commits",
        "Review each file change individually",
        "Add integration tests"
    ],
    "affects_persistence": [
        "Verify data integrity after changes",
        "Test CRUD operations",
        "Check CloudKit compatibility"
    ],
    "complex_dependencies": [
        "Verify all dependencies are complete",
        "Test dependencies in isolation",
        "Document dependency chain"
    ],
    "high_complexity": [
        "Break into smaller steps if possible",
        "Add extra verification checks",
        "Consider pair programming"
    ],
}


class RiskAssessor:
    """
    Assesses risk level of steps based on multiple weighted factors
    and returns appropriate retry configurations.
    """

    # Base risk scores for levels
    BASE_RISK_SCORES = {
        "low": 0.2,
        "medium": 0.5,
        "high": 0.8,
        "critical": 0.9,
    }

    def __init__(self, config_path: str = ".claude/technique-config.json"):
        """
        Initialize with technique configuration.

        Args:
            config_path: Path to the technique configuration JSON file
        """
        self.config_path = Path(config_path)
        self._load_config()

    def _load_config(self) -> None:
        """Load and parse the technique configuration file."""
        try:
            with open(self.config_path, 'r') as f:
                self.config = json.load(f)
        except FileNotFoundError:
            logger.warning(f"Config not found at {self.config_path}, using defaults")
            self.config = {}
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON in config file: {e}")
            self.config = {}

        self.problem_types = self.config.get("problemTypes", {})
        self.risk_levels = self.config.get("riskLevels", {})

    def _get_base_risk(self, problem_type: str) -> str:
        """
        Get base risk level from problem type configuration.

        Args:
            problem_type: The problem type to look up

        Returns:
            Risk level string ("low", "medium", "high", or "critical")
        """
        # Search through categories for the problem type
        for category, cat_data in self.problem_types.items():
            subtypes = cat_data.get("subtypes", {})
            if problem_type in subtypes:
                return subtypes[problem_type].get("riskLevel", "medium")

        # Default to medium if not found
        return "medium"

    def assess_risk(
        self,
        step: StepInfo,
        context: Optional[dict] = None
    ) -> RiskAssessment:
        """
        Assess the risk level of a step.

        Args:
            step: Information about the step
            context: Optional plan-level context for adjustments

        Returns:
            RiskAssessment with level, factors, and retry config
        """
        # 1. Get base risk from problem type
        base_risk = self._get_base_risk(step.problem_type)
        base_score = self.BASE_RISK_SCORES.get(base_risk, 0.5)

        # 2. Apply risk factors
        factors: list[RiskFactor] = []
        total_adjustment = 0.0

        for name, factor_def in RISK_FACTORS.items():
            present = factor_def["check"](step)
            contribution = factor_def["weight"] if present else 0.0
            total_adjustment += contribution

            factors.append(RiskFactor(
                name=name,
                weight=factor_def["weight"],
                present=present,
                contribution=contribution,
                description=factor_def["description"]
            ))

        # 3. Calculate score (clamped to 0.0-1.0)
        score = base_score + total_adjustment
        score = max(0.0, min(1.0, score))

        # 4. Apply context adjustments
        if context:
            if context.get("previous_step_failed"):
                score = min(1.0, score + 0.1)
            if context.get("critical_path"):
                score = min(1.0, score + 0.1)
            if context.get("similar_step_succeeded"):
                score = max(0.0, score - 0.1)
            if context.get("similar_step_failed"):
                score = min(1.0, score + 0.2)

        # 5. Determine risk level from score
        level = self._score_to_level(score)

        # 6. Get retry configuration
        retry_config = self.get_retry_config(level)

        # 7. Generate explanation
        present_factors = [f for f in factors if f.present]
        explanation = self._generate_explanation(step, level, score, present_factors)

        # 8. Suggest mitigations
        mitigations = self._suggest_mitigations(present_factors)

        return RiskAssessment(
            level=level,
            score=score,
            factors=factors,
            retry_config=retry_config,
            explanation=explanation,
            mitigations=mitigations
        )

    def _score_to_level(self, score: float) -> RiskLevel:
        """
        Convert a risk score to a risk level.

        Thresholds aligned with base scores:
        - LOW: < 0.35 (covers low base 0.2 with minor adjustments)
        - MEDIUM: < 0.6 (covers medium base 0.5 with minor adjustments)
        - HIGH: < 0.85 (covers high base 0.8 with minor adjustments)
        - CRITICAL: >= 0.85 (requires multiple high-risk factors)

        Args:
            score: Risk score from 0.0 to 1.0

        Returns:
            Corresponding RiskLevel
        """
        if score < 0.35:
            return RiskLevel.LOW
        elif score < 0.6:
            return RiskLevel.MEDIUM
        elif score < 0.85:
            return RiskLevel.HIGH
        else:
            return RiskLevel.CRITICAL

    def _generate_explanation(
        self,
        step: StepInfo,
        level: RiskLevel,
        score: float,
        present_factors: list[RiskFactor]
    ) -> str:
        """
        Generate a human-readable explanation of the risk assessment.

        Args:
            step: The step being assessed
            level: The assessed risk level
            score: The calculated risk score
            present_factors: List of factors that are present

        Returns:
            Human-readable explanation string
        """
        parts = [
            f"Risk level {level.value.upper()} (score: {score:.2f}) for '{step.problem_type}' step."
        ]

        if present_factors:
            positive_factors = [f for f in present_factors if f.weight > 0]
            negative_factors = [f for f in present_factors if f.weight < 0]

            if positive_factors:
                factor_names = [f.name.replace("_", " ") for f in positive_factors]
                parts.append(f"Risk increased by: {', '.join(factor_names)}.")

            if negative_factors:
                factor_names = [f.name.replace("_", " ") for f in negative_factors]
                parts.append(f"Risk reduced by: {', '.join(factor_names)}.")
        else:
            parts.append("No additional risk factors detected.")

        return " ".join(parts)

    def _suggest_mitigations(self, present_factors: list[RiskFactor]) -> list[str]:
        """
        Suggest mitigations based on present risk factors.

        Args:
            present_factors: List of factors that are present

        Returns:
            List of mitigation suggestions
        """
        mitigations = []

        for factor in present_factors:
            if factor.weight > 0:  # Only suggest for risk-increasing factors
                suggestions = MITIGATION_SUGGESTIONS.get(factor.name, [])
                mitigations.extend(suggestions)

        # Remove duplicates while preserving order
        seen = set()
        unique_mitigations = []
        for m in mitigations:
            if m not in seen:
                seen.add(m)
                unique_mitigations.append(m)

        return unique_mitigations

    def get_retry_config(self, risk_level: RiskLevel) -> RetryConfig:
        """
        Get retry configuration for a risk level.

        Args:
            risk_level: The risk level to get config for

        Returns:
            RetryConfig with appropriate settings
        """
        return RETRY_CONFIGS.get(risk_level, RETRY_CONFIGS[RiskLevel.MEDIUM])

    def should_escalate(
        self,
        current_attempt: int,
        risk_level: RiskLevel,
        failure_pattern: str = ""
    ) -> EscalationDecision:
        """
        Determine if escalation is needed based on attempts and failure pattern.

        Args:
            current_attempt: The current attempt number (1-based)
            risk_level: The risk level of the step
            failure_pattern: Description of the failure pattern

        Returns:
            EscalationDecision with recommendation
        """
        config = self.get_retry_config(risk_level)

        # Check if all attempts exhausted
        if current_attempt >= config.max_total:
            return EscalationDecision(
                should_escalate=True,
                reason=f"Exhausted all {config.max_total} retry attempts",
                recommended_action="user_intervention"
            )

        # Check for critical failure patterns
        if failure_pattern:
            failure_lower = failure_pattern.lower()
            critical_patterns = ["critical", "fatal", "corruption", "data loss", "security"]
            if any(p in failure_lower for p in critical_patterns):
                return EscalationDecision(
                    should_escalate=True,
                    reason=f"Critical failure pattern detected: {failure_pattern}",
                    recommended_action="user_intervention"
                )

        # Check if at escalation threshold
        if current_attempt >= config.escalation_threshold:
            return EscalationDecision(
                should_escalate=False,
                reason=f"At escalation threshold ({config.escalation_threshold}), but not critical",
                recommended_action="switch_technique"
            )

        # Within retry budget
        return EscalationDecision(
            should_escalate=False,
            reason=f"Attempt {current_attempt} of {config.max_total}, within retry budget",
            recommended_action="retry"
        )

    def get_all_factors(self) -> dict[str, dict]:
        """
        Get all risk factor definitions.

        Returns:
            Dictionary of factor definitions
        """
        return {
            name: {
                "weight": factor["weight"],
                "description": factor["description"]
            }
            for name, factor in RISK_FACTORS.items()
        }

    def calculate_step_risk_score(
        self,
        problem_type: str,
        files_modified: int = 0,
        dependencies: int = 0,
        has_migration: bool = False,
        has_api: bool = False,
        affects_data: bool = False,
        is_breaking: bool = False,
        complexity: str = "medium"
    ) -> float:
        """
        Convenience method to calculate risk score from simple parameters.

        Args:
            problem_type: The problem type
            files_modified: Number of files to modify
            dependencies: Number of dependencies
            has_migration: Whether step involves data migration
            has_api: Whether step uses external API
            affects_data: Whether step affects persistence
            is_breaking: Whether step is a breaking change
            complexity: Complexity estimate (low/medium/high)

        Returns:
            Risk score from 0.0 to 1.0
        """
        step = StepInfo(
            problem_type=problem_type,
            files_to_modify=["file"] * files_modified,
            dependencies=["dep"] * dependencies,
            has_data_migration=has_migration,
            has_external_api=has_api,
            affects_persistence=affects_data,
            is_breaking_change=is_breaking,
            complexity_estimate=complexity
        )

        assessment = self.assess_risk(step)
        return assessment.score


# CLI entry point for testing
if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        print("Usage: python risk_assessor.py <problem_type> [--migration] [--api] [--breaking]")
        sys.exit(1)

    problem_type = sys.argv[1]
    has_migration = "--migration" in sys.argv
    has_api = "--api" in sys.argv
    is_breaking = "--breaking" in sys.argv

    step = StepInfo(
        problem_type=problem_type,
        has_data_migration=has_migration,
        has_external_api=has_api,
        is_breaking_change=is_breaking
    )

    assessor = RiskAssessor()
    result = assessor.assess_risk(step)

    print(f"Problem Type: {problem_type}")
    print(f"Risk Level: {result.level.value}")
    print(f"Risk Score: {result.score:.2f}")
    print(f"Explanation: {result.explanation}")
    print(f"Retry Budget: {result.retry_config.max_total}")
    print(f"Escalation Threshold: {result.retry_config.escalation_threshold}")

    if result.mitigations:
        print("\nSuggested Mitigations:")
        for m in result.mitigations:
            print(f"  - {m}")
