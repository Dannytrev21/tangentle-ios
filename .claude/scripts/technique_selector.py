"""
Technique Selector for the Intelligent Planning System.

This module provides phase-based technique selection with context-aware
adjustment for optimal prompt engineering technique assignment.
"""

from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Optional
import json
import logging

from utils import get_thinking_keyword

logger = logging.getLogger(__name__)


class Phase(Enum):
    """Workflow phases for technique selection."""
    PLANNING = "planning"
    IMPLEMENTATION = "implementation"
    VERIFICATION = "verification"


@dataclass
class StepContext:
    """Context information for a step to inform technique selection."""
    step_number: int
    total_steps: int
    complexity_score: float  # 0.0 to 1.0
    dependencies: list[str] = field(default_factory=list)
    risk_level: str = "medium"
    previous_failures: int = 0
    files_affected: list[str] = field(default_factory=list)


@dataclass
class TechniqueSelection:
    """Result of technique selection for a phase."""
    primary: str                    # Main technique (e.g., "tdd")
    secondary: list[str]            # Supporting techniques
    prompt_template: str            # Path to template
    rationale: str                  # Why these were selected
    estimated_cost: str             # "low", "medium", "high"
    retry_budget: int               # Max retries for this selection
    confidence: float = 0.5         # Confidence in selection (0.0 to 1.0)


@dataclass
class TechniqueMetadata:
    """Metadata about a technique."""
    name: str
    description: str
    prompt_template: str
    cost_level: str
    best_for: list[str]


class TechniqueSelector:
    """
    Selects optimal prompt engineering techniques based on problem type,
    workflow phase, and step context.
    """

    # Cost levels for techniques (1=low, 2=medium, 3=high)
    COST_LEVELS = {
        "tot": 3,           # Tree of Thoughts - expensive exploration
        "got": 3,           # Graph of Thoughts - expensive aggregation
        "self-consistency": 3,  # Multiple paths - expensive
        "reflexion": 2,     # Learning from failures - moderate
        "self-refine": 2,   # Iterative refinement - moderate
        "tdd": 2,           # Test-driven - moderate
        "react": 2,         # Reasoning + action - moderate
        "chain-of-code": 2, # Code interleaved - moderate
        "ps-plus": 1,       # Plan and solve - cheap
        "least-to-most": 1, # Decomposition - cheap
    }

    # Retry budgets by risk level
    RETRY_BUDGETS = {
        "low": 3,
        "medium": 5,
        "high": 7,
        "critical": 10,
    }

    def __init__(
        self,
        config_path: str = ".claude/technique-config.json",
        effectiveness_tracker: Optional["EffectivenessTracker"] = None
    ):
        """
        Initialize with technique configuration.

        Args:
            config_path: Path to the technique configuration JSON file
            effectiveness_tracker: Optional tracker for effectiveness-based selection
        """
        self.config_path = Path(config_path)
        self._load_config()
        self.effectiveness_tracker = effectiveness_tracker

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

        self.techniques = self.config.get("techniques", {})
        self.problem_types = self.config.get("problemTypes", {})
        self.risk_levels = self.config.get("riskLevels", {})
        self.defaults = self.config.get("defaults", {})

    def _find_problem_type(self, problem_type: str) -> tuple[Optional[str], Optional[dict]]:
        """
        Find problem type configuration.

        Args:
            problem_type: The problem type to look up

        Returns:
            Tuple of (category, subtype_config) or (None, None) if not found
        """
        for category, cat_data in self.problem_types.items():
            subtypes = cat_data.get("subtypes", {})
            if problem_type in subtypes:
                return category, subtypes[problem_type]
        return None, None

    def _get_default_subtype(self) -> dict:
        """Get default subtype configuration."""
        default_type = self.defaults.get("unknownProblemType", "new-feature")
        default_category = self.defaults.get("unknownCategory", "META")

        cat_data = self.problem_types.get(default_category, {})
        subtypes = cat_data.get("subtypes", {})
        return subtypes.get(default_type, {
            "techniques": self.defaults.get("defaultTechniques", {
                "planning": "tot",
                "implementation": ["self-refine"],
                "verification": "reflexion"
            }),
            "riskLevel": self.defaults.get("defaultRiskLevel", "medium")
        })

    def select_techniques(
        self,
        problem_type: str,
        phase: Phase,
        context: Optional[StepContext] = None
    ) -> TechniqueSelection:
        """
        Select techniques for a specific workflow phase.

        Args:
            problem_type: The classified problem type
            phase: The workflow phase (planning, implementation, verification)
            context: Optional step context for refinement

        Returns:
            TechniqueSelection with primary and optional secondary techniques
        """
        # 1. Lookup base techniques for problem type
        category, subtype = self._find_problem_type(problem_type)
        if not subtype:
            logger.warning(f"Unknown problem type '{problem_type}', using defaults")
            subtype = self._get_default_subtype()
            category = self.defaults.get("unknownCategory", "META")

        techniques_config = subtype.get("techniques", {})
        phase_tech = techniques_config.get(phase.value)

        # Normalize to list (implementation can have multiple)
        if isinstance(phase_tech, str):
            tech_list = [phase_tech]
        elif isinstance(phase_tech, list):
            tech_list = phase_tech if phase_tech else ["ps-plus"]
        else:
            tech_list = ["ps-plus"]

        config_primary = tech_list[0]
        secondary = tech_list[1:] if len(tech_list) > 1 else []

        # 2. Check effectiveness data (if tracker available)
        primary, confidence, rationale_source = self._decide_technique_with_effectiveness(
            config_primary, problem_type, phase
        )

        # 3. Context adjustment
        if context:
            primary, secondary = self._adjust_for_context(
                primary, secondary, context, phase
            )

        # 4. Get risk level and retry budget
        risk_level = subtype.get("riskLevel", "medium")
        retry_budget = self._get_retry_budget(risk_level)

        # 5. Build result with confidence
        rationale = self._generate_rationale(
            problem_type, phase, primary, secondary, context, rationale_source
        )

        return TechniqueSelection(
            primary=primary,
            secondary=secondary,
            prompt_template=self.get_technique_prompt(primary),
            rationale=rationale,
            estimated_cost=self._estimate_cost(primary, secondary),
            retry_budget=retry_budget,
            confidence=confidence
        )

    def _decide_technique_with_effectiveness(
        self,
        config_technique: str,
        problem_type: str,
        phase: Phase
    ) -> tuple[str, float, str]:
        """
        Decide technique using effectiveness data if available.

        Args:
            config_technique: The technique from configuration
            problem_type: The problem type
            phase: The workflow phase

        Returns:
            Tuple of (technique, confidence, rationale_source)
        """
        # If no tracker, use config defaults
        if not self.effectiveness_tracker:
            return (config_technique, 0.5, "Configuration default")

        # Get available techniques for this phase
        available = list(self.COST_LEVELS.keys())

        # Query effectiveness tracker
        effectiveness_tech, effectiveness_confidence, effectiveness_rationale = (
            self.effectiveness_tracker.get_recommended_technique(
                problem_type, available, phase.value
            )
        )

        # Decision logic
        if effectiveness_tech and effectiveness_confidence > 0.7:
            # High confidence from effectiveness data
            return (
                effectiveness_tech,
                effectiveness_confidence,
                f"Historical effectiveness: {effectiveness_confidence:.0%}"
            )

        if effectiveness_tech and effectiveness_confidence > 0.5:
            # Moderate confidence - check if it agrees with config
            if effectiveness_tech == config_technique:
                # Boost confidence when they agree
                boosted_confidence = min(0.8, effectiveness_confidence + 0.2)
                return (
                    config_technique,
                    boosted_confidence,
                    "Configuration default (confirmed by historical data)"
                )

        # Use config default with neutral confidence
        return (
            config_technique,
            0.5,
            "Configuration default (insufficient historical data)"
        )

    def _adjust_for_context(
        self,
        primary: str,
        secondary: list[str],
        context: StepContext,
        phase: Phase
    ) -> tuple[str, list[str]]:
        """
        Adjust technique selection based on step context.

        Args:
            primary: Current primary technique
            secondary: Current secondary techniques
            context: Step context
            phase: Workflow phase

        Returns:
            Adjusted (primary, secondary) tuple
        """
        adjusted_primary = primary
        adjusted_secondary = list(secondary)

        # Rule 1: If previous failures, prefer Reflexion for verification
        if context.previous_failures > 0 and phase == Phase.VERIFICATION:
            if adjusted_primary != "reflexion":
                # Move current primary to secondary
                adjusted_secondary = [adjusted_primary] + adjusted_secondary
                adjusted_primary = "reflexion"

        # Rule 2: If high complexity, prefer ToT for planning
        if context.complexity_score > 0.7 and phase == Phase.PLANNING:
            if adjusted_primary not in ["tot", "got"]:
                adjusted_secondary = [adjusted_primary] + adjusted_secondary
                adjusted_primary = "tot"

        # Rule 3: Early steps benefit from exploration
        if context.step_number <= 2 and phase == Phase.PLANNING:
            if adjusted_primary == "ps-plus":
                adjusted_primary = "tot"

        # Rule 4: Many files affected increases complexity
        if len(context.files_affected) > 10 and phase == Phase.IMPLEMENTATION:
            if adjusted_primary not in ["reflexion", "tdd"]:
                if "tdd" not in adjusted_secondary:
                    adjusted_secondary.append("tdd")

        # Rule 5: High risk requires extra verification
        if context.risk_level in ["high", "critical"] and phase == Phase.VERIFICATION:
            if adjusted_primary not in ["reflexion", "self-consistency"]:
                if "reflexion" not in adjusted_secondary:
                    adjusted_secondary.append("reflexion")

        # Limit secondary to 2 techniques
        adjusted_secondary = adjusted_secondary[:2]

        return adjusted_primary, adjusted_secondary

    def _get_retry_budget(self, risk_level: str) -> int:
        """Get retry budget based on risk level."""
        risk_config = self.risk_levels.get(risk_level, {})
        retry_config = risk_config.get("retryConfig", {})
        return retry_config.get("maxTotal", self.RETRY_BUDGETS.get(risk_level, 5))

    def _estimate_cost(self, primary: str, secondary: list[str]) -> str:
        """
        Estimate cost level for technique selection.

        Args:
            primary: Primary technique
            secondary: Secondary techniques

        Returns:
            "low", "medium", or "high"
        """
        total = self.COST_LEVELS.get(primary, 2)
        total += sum(self.COST_LEVELS.get(t, 1) for t in secondary) * 0.5

        if total < 1.5:
            return "low"
        if total < 2.5:
            return "medium"
        return "high"

    def _generate_rationale(
        self,
        problem_type: str,
        phase: Phase,
        primary: str,
        secondary: list[str],
        context: Optional[StepContext],
        rationale_source: str = "Configuration default"
    ) -> str:
        """Generate human-readable rationale for technique selection."""
        reasons = []

        # Base selection reason
        reasons.append(
            f"Selected {primary.upper()} for {phase.value} phase of '{problem_type}'"
        )

        # Selection source (effectiveness vs config)
        reasons.append(f"[{rationale_source}]")

        # Secondary techniques
        if secondary:
            reasons.append(f"with {', '.join(s.upper() for s in secondary)} as support")

        # Context adjustments
        if context:
            if context.previous_failures > 0:
                reasons.append(
                    f"(adjusted for {context.previous_failures} previous failure(s))"
                )
            if context.complexity_score > 0.7:
                reasons.append("(high complexity detected)")
            if context.step_number <= 2:
                reasons.append("(early step - exploration focus)")
            if context.risk_level in ["high", "critical"]:
                reasons.append(f"({context.risk_level} risk)")

        return " ".join(reasons) + "."

    def get_technique_prompt(self, technique_id: str) -> str:
        """
        Get the prompt template path for a technique.

        Args:
            technique_id: The technique identifier

        Returns:
            Path to the prompt template file
        """
        tech = self.techniques.get(technique_id, {})
        return tech.get("promptTemplate", f".claude/commands/{technique_id}.md")

    def get_technique_metadata(self, technique_id: str) -> Optional[TechniqueMetadata]:
        """
        Get metadata about a technique.

        Args:
            technique_id: The technique identifier

        Returns:
            TechniqueMetadata or None if technique not found
        """
        tech = self.techniques.get(technique_id)
        if not tech:
            return None

        return TechniqueMetadata(
            name=tech.get("name", technique_id),
            description=tech.get("description", ""),
            prompt_template=tech.get("promptTemplate", f".claude/commands/{technique_id}.md"),
            cost_level=tech.get("costLevel", "medium"),
            best_for=tech.get("bestFor", [])
        )

    def compose_techniques(
        self,
        techniques: list[str],
        problem_description: str
    ) -> str:
        """
        Compose multiple techniques into guidance text.

        Args:
            techniques: List of technique IDs to compose
            problem_description: Description of the problem being solved

        Returns:
            Composed guidance text
        """
        if not techniques:
            return ""

        sections = []

        # Primary technique gets full treatment
        primary = techniques[0]
        primary_meta = self.get_technique_metadata(primary)
        if primary_meta:
            sections.append(f"## Primary Approach: {primary_meta.name}")
            sections.append(f"{primary_meta.description}")
            sections.append(f"\nBest for: {', '.join(primary_meta.best_for)}")
            sections.append(f"Template: {primary_meta.prompt_template}")

        # Secondary techniques get modifier treatment
        if len(techniques) > 1:
            sections.append("\n## Supporting Techniques")
            for tech_id in techniques[1:]:
                meta = self.get_technique_metadata(tech_id)
                if meta:
                    sections.append(f"- **{meta.name}**: {meta.description}")

        # Problem context
        sections.append(f"\n## Problem Context")
        sections.append(problem_description)

        return "\n".join(sections)

    def get_all_techniques(self) -> list[str]:
        """Get all available technique IDs."""
        return list(self.techniques.keys())

    def get_techniques_for_problem_type(self, problem_type: str) -> dict[str, list[str]]:
        """
        Get all techniques configured for a problem type.

        Args:
            problem_type: The problem type to look up

        Returns:
            Dict mapping phase to technique list
        """
        _, subtype = self._find_problem_type(problem_type)
        if not subtype:
            subtype = self._get_default_subtype()

        techniques_config = subtype.get("techniques", {})
        result = {}

        for phase in Phase:
            phase_tech = techniques_config.get(phase.value)
            if isinstance(phase_tech, str):
                result[phase.value] = [phase_tech]
            elif isinstance(phase_tech, list):
                result[phase.value] = phase_tech
            else:
                result[phase.value] = ["ps-plus"]

        return result

    def get_thinking_keyword(self, risk_level: str) -> str:
        """
        Get thinking keyword for a risk level.

        Args:
            risk_level: One of "low", "medium", "high", "critical"

        Returns:
            Thinking keyword phrase for prompt embedding
        """
        return get_thinking_keyword(risk_level)

    def get_thinking_keyword_for_step(self, step_info: dict) -> str:
        """
        Get thinking keyword based on step's risk level.

        Args:
            step_info: Step information dictionary containing riskLevel

        Returns:
            Thinking keyword phrase for prompt embedding
        """
        risk_level = step_info.get("riskLevel", "medium")
        return self.get_thinking_keyword(risk_level)

    def get_risk_for_problem_type(self, problem_type: str) -> str:
        """
        Get risk level for a problem type.

        Args:
            problem_type: The problem type to look up

        Returns:
            Risk level string ("low", "medium", "high", "critical")
        """
        _, subtype = self._find_problem_type(problem_type)
        if not subtype:
            return self.defaults.get("defaultRiskLevel", "medium")
        return subtype.get("riskLevel", "medium")


# CLI entry point for testing
if __name__ == '__main__':
    import sys

    if len(sys.argv) < 3:
        print("Usage: python technique_selector.py <problem_type> <phase>")
        print("  phase: planning | implementation | verification")
        sys.exit(1)

    problem_type = sys.argv[1]
    phase_str = sys.argv[2]

    try:
        phase = Phase(phase_str)
    except ValueError:
        print(f"Invalid phase: {phase_str}")
        print("Valid phases: planning, implementation, verification")
        sys.exit(1)

    selector = TechniqueSelector()
    result = selector.select_techniques(problem_type, phase)

    print(f"Problem Type: {problem_type}")
    print(f"Phase: {phase.value}")
    print(f"Primary: {result.primary}")
    print(f"Secondary: {result.secondary}")
    print(f"Cost: {result.estimated_cost}")
    print(f"Retry Budget: {result.retry_budget}")
    print(f"Rationale: {result.rationale}")
    print(f"Template: {result.prompt_template}")
