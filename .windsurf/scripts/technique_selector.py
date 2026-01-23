"""
Technique Selector for the Windsurf Planning System.

This module provides phase-based technique selection with context-aware
adjustment for optimal prompt engineering technique assignment.

Uses standard library only - no pip dependencies.
"""

from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Optional
import json


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


@dataclass
class TechniqueMetadata:
    """Metadata about a technique."""
    name: str
    description: str
    prompt_template: str
    cost_level: str
    best_for: list[str]


@dataclass
class ReasoningSelection:
    """Result of selecting ToT vs GoT reasoning technique."""
    technique: str                    # "tot" or "got"
    rationale: str                    # Why this technique was selected
    characteristics_matched: list[str]  # Which characteristics influenced decision


# 10 prompt engineering techniques
TECHNIQUES = {
    "tdd": {
        "name": "Test-Driven Development",
        "description": "Write tests first, then implementation",
        "costLevel": "medium",
        "bestFor": ["implementation", "verification"],
        "promptTemplate": ".windsurf/knowledge/techniques/tdd.md"
    },
    "tot": {
        "name": "Tree of Thoughts",
        "description": "Explore multiple solution paths and evaluate each",
        "costLevel": "high",
        "bestFor": ["planning", "complex decisions"],
        "promptTemplate": ".windsurf/knowledge/techniques/tot.md"
    },
    "got": {
        "name": "Graph of Thoughts",
        "description": "Aggregate findings from multiple paths",
        "costLevel": "high",
        "bestFor": ["verification", "merging"],
        "promptTemplate": ".windsurf/knowledge/techniques/got.md"
    },
    "reflexion": {
        "name": "Reflexion",
        "description": "Learn from failures with memory bank",
        "costLevel": "medium-high",
        "bestFor": ["verification", "learning"],
        "promptTemplate": ".windsurf/knowledge/techniques/reflexion.md"
    },
    "self-refine": {
        "name": "Self-Refine",
        "description": "Generate, evaluate, and iterate",
        "costLevel": "medium",
        "bestFor": ["implementation", "iteration"],
        "promptTemplate": ".windsurf/knowledge/techniques/self-refine.md"
    },
    "self-consistency": {
        "name": "Self-Consistency",
        "description": "Multiple independent solutions, majority vote",
        "costLevel": "high",
        "bestFor": ["verification", "algorithms"],
        "promptTemplate": ".windsurf/knowledge/techniques/self-consistency.md"
    },
    "react": {
        "name": "ReAct",
        "description": "Reason and act iteratively",
        "costLevel": "medium",
        "bestFor": ["planning", "interactive"],
        "promptTemplate": ".windsurf/knowledge/techniques/react.md"
    },
    "ps-plus": {
        "name": "Plan-and-Solve Plus",
        "description": "Structured planning with verification",
        "costLevel": "low",
        "bestFor": ["planning", "structured"],
        "promptTemplate": ".windsurf/knowledge/techniques/ps-plus.md"
    },
    "chain-of-code": {
        "name": "Chain of Code",
        "description": "Interleave executable logic with semantic reasoning",
        "costLevel": "medium",
        "bestFor": ["implementation", "mixed"],
        "promptTemplate": ".windsurf/knowledge/techniques/chain-of-code.md"
    },
    "least-to-most": {
        "name": "Least-to-Most",
        "description": "Decompose into simpler subproblems",
        "costLevel": "low",
        "bestFor": ["planning", "decomposition"],
        "promptTemplate": ".windsurf/knowledge/techniques/least-to-most.md"
    }
}

# Default technique mappings per problem type
DEFAULT_TECHNIQUES = {
    # FOUNDATION
    "infrastructure": {"planning": "ps-plus", "implementation": ["least-to-most"], "verification": "self-refine"},
    "scaffolding": {"planning": "ps-plus", "implementation": ["chain-of-code"], "verification": "self-refine"},
    "configuration": {"planning": "ps-plus", "implementation": ["least-to-most"], "verification": "self-refine"},
    # DATA
    "data-modeling": {"planning": "tot", "implementation": ["tdd"], "verification": "reflexion"},
    "data-access": {"planning": "ps-plus", "implementation": ["tdd"], "verification": "reflexion"},
    "migration": {"planning": "tot", "implementation": ["tdd", "reflexion"], "verification": "reflexion"},
    "state-mgmt": {"planning": "tot", "implementation": ["tdd"], "verification": "reflexion"},
    # ARCHITECTURE
    "system-design": {"planning": "tot", "implementation": ["chain-of-code"], "verification": "got"},
    "protocol-design": {"planning": "tot", "implementation": ["tdd"], "verification": "self-refine"},
    "di-setup": {"planning": "ps-plus", "implementation": ["tdd"], "verification": "self-refine"},
    "service-impl": {"planning": "ps-plus", "implementation": ["tdd"], "verification": "reflexion"},
    "refactor": {"planning": "tot", "implementation": ["self-refine"], "verification": "got"},
    # UI_UX
    "ui": {"planning": "ps-plus", "implementation": ["chain-of-code"], "verification": "self-refine"},
    "component-lib": {"planning": "least-to-most", "implementation": ["tdd"], "verification": "self-refine"},
    "design-tokens": {"planning": "ps-plus", "implementation": ["chain-of-code"], "verification": "self-refine"},
    "animation": {"planning": "ps-plus", "implementation": ["chain-of-code"], "verification": "self-refine"},
    "gesture": {"planning": "react", "implementation": ["tdd"], "verification": "reflexion"},
    "accessibility": {"planning": "ps-plus", "implementation": ["tdd"], "verification": "self-refine"},
    "polish": {"planning": "ps-plus", "implementation": ["self-refine"], "verification": "self-refine"},
    # TESTING
    "test-setup": {"planning": "ps-plus", "implementation": ["least-to-most"], "verification": "self-refine"},
    "unit-test": {"planning": "ps-plus", "implementation": ["tdd"], "verification": "self-consistency"},
    "integration-test": {"planning": "ps-plus", "implementation": ["tdd"], "verification": "reflexion"},
    "snapshot-test": {"planning": "ps-plus", "implementation": ["least-to-most"], "verification": "self-refine"},
    "e2e-test": {"planning": "react", "implementation": ["tdd"], "verification": "reflexion"},
    "performance-test": {"planning": "ps-plus", "implementation": ["tdd"], "verification": "self-consistency"},
    # LOGIC
    "algorithm": {"planning": "tot", "implementation": ["tdd"], "verification": "self-consistency"},
    "validation": {"planning": "ps-plus", "implementation": ["tdd"], "verification": "self-consistency"},
    "api-integration": {"planning": "react", "implementation": ["tdd"], "verification": "reflexion"},
    "debug": {"planning": "react", "implementation": ["reflexion"], "verification": "self-refine"},
    # DOCUMENTATION
    "documentation": {"planning": "ps-plus", "implementation": ["self-refine"], "verification": "got"},
    "changelog": {"planning": "ps-plus", "implementation": ["self-refine"], "verification": "self-refine"},
    # META
    "ideation": {"planning": "tot", "implementation": ["chain-of-code"], "verification": "got"},
    "new-feature": {"planning": "tot", "implementation": ["self-refine"], "verification": "reflexion"}
}

# Cost levels for techniques (1=low, 2=medium, 3=high)
COST_LEVELS = {
    "tot": 3,
    "got": 3,
    "self-consistency": 3,
    "reflexion": 2,
    "self-refine": 2,
    "tdd": 2,
    "react": 2,
    "chain-of-code": 2,
    "ps-plus": 1,
    "least-to-most": 1,
}

# Retry budgets by risk level
RETRY_BUDGETS = {
    "low": 3,
    "medium": 5,
    "high": 7,
    "critical": 10,
}

# Category defaults for ToT vs GoT reasoning technique selection
# ToT (Tree of Thoughts): exploration, design decisions, multiple approaches
# GoT (Graph of Thoughts): synthesis, aggregation, review
CATEGORY_DEFAULTS = {
    "FOUNDATION": "tot",      # Infrastructure decisions need exploration
    "DATA": "tot",            # Data models benefit from approach exploration
    "ARCHITECTURE": "tot",    # Architecture requires evaluating alternatives
    "UI_UX": "tot",           # UI decisions have multiple valid approaches
    "TESTING": "got",         # Tests verify and synthesize requirements
    "LOGIC": "tot",           # Algorithms need exploration
    "DOCUMENTATION": "got",   # Docs synthesize and aggregate information
    "META": "tot",            # Meta-decisions need exploration
}

# Characteristic override priority (higher = more priority)
# When a characteristic is present, it overrides the category default
CHARACTERISTIC_OVERRIDES = {
    "requires_synthesis": ("got", 1),     # Highest priority
    "exploration_needed": ("tot", 2),
    "multiple_approaches": ("tot", 3),
    "review_task": ("got", 4),
    "new_design": ("tot", 5),             # Lowest priority
}


def select_reasoning_technique(
    problem_type: str,
    category: str,
    characteristics: Optional[dict[str, bool]] = None
) -> ReasoningSelection:
    """
    Select ToT or GoT reasoning technique based on problem characteristics.

    Args:
        problem_type: The problem type (e.g., "debug", "unit-test")
        category: The problem category (e.g., "LOGIC", "TESTING")
        characteristics: Optional dict of characteristic flags that can override
                        the category default

    Returns:
        ReasoningSelection with technique, rationale, and matched characteristics

    Examples:
        >>> select_reasoning_technique("debug", "LOGIC")
        ReasoningSelection(technique="tot", rationale="...", characteristics_matched=[])

        >>> select_reasoning_technique("refactor", "ARCHITECTURE", {"requires_synthesis": True})
        ReasoningSelection(technique="got", rationale="...", characteristics_matched=["requires_synthesis"])
    """
    matched_characteristics: list[str] = []

    # Check for characteristic overrides (sorted by priority)
    if characteristics:
        # Sort by priority (lower number = higher priority)
        sorted_overrides = sorted(
            CHARACTERISTIC_OVERRIDES.items(),
            key=lambda x: x[1][1]
        )

        for char_name, (technique, _) in sorted_overrides:
            if characteristics.get(char_name, False):
                matched_characteristics.append(char_name)
                rationale = (
                    f"GoT: {char_name} characteristic matched"
                    if technique == "got"
                    else f"ToT: {char_name} characteristic matched"
                )
                return ReasoningSelection(
                    technique=technique,
                    rationale=rationale,
                    characteristics_matched=matched_characteristics
                )

    # Use category default
    category_upper = category.upper()
    technique = CATEGORY_DEFAULTS.get(category_upper, "tot")

    # Generate rationale based on category
    if technique == "tot":
        rationale = f"ToT: Category {category_upper} defaults to exploration"
    else:
        rationale = f"GoT: Category {category_upper} defaults to synthesis"

    return ReasoningSelection(
        technique=technique,
        rationale=rationale,
        characteristics_matched=matched_characteristics
    )


class TechniqueSelector:
    """
    Selects optimal prompt engineering techniques based on problem type,
    workflow phase, and step context.
    """

    def __init__(self, config_path: Optional[str] = None):
        """
        Initialize with optional technique configuration.

        Args:
            config_path: Optional path to the technique configuration JSON file
        """
        self.config_path = Path(config_path) if config_path else None
        self._load_config()

    def _load_config(self) -> None:
        """Load and parse the technique configuration file if it exists."""
        self.techniques = TECHNIQUES.copy()
        self.problem_types = {}
        self.risk_levels = {}
        self.defaults = {}

        if self.config_path and self.config_path.exists():
            try:
                with open(self.config_path, 'r') as f:
                    config = json.load(f)
                    if "techniques" in config:
                        self.techniques.update(config["techniques"])
                    self.problem_types = config.get("problemTypes", {})
                    self.risk_levels = config.get("riskLevels", {})
                    self.defaults = config.get("defaults", {})
            except (json.JSONDecodeError, IOError):
                pass  # Use defaults

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

    def _get_techniques_for_type(self, problem_type: str) -> dict:
        """Get technique configuration for a problem type."""
        # First check loaded config
        _, subtype = self._find_problem_type(problem_type)
        if subtype and "techniques" in subtype:
            return subtype["techniques"]

        # Fall back to defaults
        return DEFAULT_TECHNIQUES.get(problem_type, {
            "planning": "ps-plus",
            "implementation": ["self-refine"],
            "verification": "reflexion"
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
        techniques_config = self._get_techniques_for_type(problem_type)
        phase_tech = techniques_config.get(phase.value)

        # Normalize to list (implementation can have multiple)
        if isinstance(phase_tech, str):
            tech_list = [phase_tech]
        elif isinstance(phase_tech, list):
            tech_list = phase_tech if phase_tech else ["ps-plus"]
        else:
            tech_list = ["ps-plus"]

        primary = tech_list[0]
        secondary = tech_list[1:] if len(tech_list) > 1 else []

        # 2. Context adjustment
        if context:
            primary, secondary = self._adjust_for_context(
                primary, secondary, context, phase
            )

        # 3. Get risk level and retry budget
        risk_level = self._get_risk_level(problem_type)
        retry_budget = RETRY_BUDGETS.get(risk_level, 5)

        # 4. Build result
        return TechniqueSelection(
            primary=primary,
            secondary=secondary,
            prompt_template=self.get_technique_prompt(primary),
            rationale=self._generate_rationale(problem_type, phase, primary, secondary, context),
            estimated_cost=self._estimate_cost(primary, secondary),
            retry_budget=retry_budget
        )

    def _get_risk_level(self, problem_type: str) -> str:
        """Get risk level for a problem type."""
        _, subtype = self._find_problem_type(problem_type)
        if subtype:
            return subtype.get("riskLevel", "medium")

        # Use built-in risk levels from problem_classifier
        from problem_classifier import PROBLEM_TYPES
        for cat_data in PROBLEM_TYPES.values():
            for ptype, data in cat_data.get("subtypes", {}).items():
                if ptype == problem_type:
                    return data.get("riskLevel", "medium")

        return "medium"

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

    def _estimate_cost(self, primary: str, secondary: list[str]) -> str:
        """
        Estimate cost level for technique selection.

        Args:
            primary: Primary technique
            secondary: Secondary techniques

        Returns:
            "low", "medium", or "high"
        """
        total = COST_LEVELS.get(primary, 2)
        total += sum(COST_LEVELS.get(t, 1) for t in secondary) * 0.5

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
        context: Optional[StepContext]
    ) -> str:
        """Generate human-readable rationale for technique selection."""
        reasons = []

        # Base selection reason
        reasons.append(
            f"Selected {primary.upper()} for {phase.value} phase of '{problem_type}'"
        )

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
        return tech.get("promptTemplate", f".windsurf/knowledge/techniques/{technique_id}.md")

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
            prompt_template=tech.get("promptTemplate", f".windsurf/knowledge/techniques/{technique_id}.md"),
            cost_level=tech.get("costLevel", "medium"),
            best_for=tech.get("bestFor", [])
        )

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
        techniques_config = self._get_techniques_for_type(problem_type)
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


# CLI entry point for testing
if __name__ == '__main__':
    import sys

    if len(sys.argv) < 2:
        print("Usage: python technique_selector.py <problem_type> [phase]")
        print("  phase: planning | implementation | verification")
        sys.exit(1)

    problem_type = sys.argv[1]
    phase_str = sys.argv[2] if len(sys.argv) > 2 else "planning"

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
