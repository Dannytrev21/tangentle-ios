#!/usr/bin/env python3
"""
Self-Correction Engine for the Windsurf Planning System.

This module implements the Reflexion pattern with memory bank, failure analysis,
technique rotation, and graceful escalation for high-risk steps.

Uses standard library only - no pip dependencies.
"""

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Dict, List, Optional
import json
import sys

# Add the scripts directory to the path for imports
sys.path.insert(0, str(Path(__file__).parent))

from memory_bank import MemoryBank, MemoryBankEntry, create_entry


class RetryAction(Enum):
    """Actions the self-correction engine can recommend."""
    RETRY = "retry"          # Retry with same technique
    ROTATE = "rotate"        # Try alternative technique
    ESCALATE = "escalate"    # Give up, ask user


# Retry configurations per risk level
RETRY_CONFIG = {
    "low": {
        "max_same": 2,
        "max_alt": 1,
        "max_total": 3,
        "escalate_after": 2
    },
    "medium": {
        "max_same": 3,
        "max_alt": 2,
        "max_total": 5,
        "escalate_after": 3
    },
    "high": {
        "max_same": 3,
        "max_alt": 3,
        "max_total": 7,
        "escalate_after": 5
    },
    "critical": {
        "max_same": 5,
        "max_alt": 5,
        "max_total": 10,
        "escalate_after": 7
    }
}


# Failure patterns and their suggested alternative techniques
FAILURE_PATTERNS = {
    "test_failure": {
        "keywords": ["test", "assert", "expect", "fail", "xct"],
        "technique": "tdd"
    },
    "convergence": {
        "keywords": ["iteration", "loop", "infinite", "stuck", "not converging"],
        "technique": "self-consistency"
    },
    "architecture": {
        "keywords": ["design", "structure", "pattern", "coupling", "architecture"],
        "technique": "tot"
    },
    "async_timing": {
        "keywords": ["async", "await", "race", "timeout", "deadlock", "timing"],
        "technique": "react"
    },
    "repeated": {
        "keywords": ["same error", "again", "still failing", "repeated"],
        "technique": "reflexion"
    },
    "integration": {
        "keywords": ["connect", "api", "service", "external", "integration"],
        "technique": "chain-of-code"
    },
    "decomposition": {
        "keywords": ["complex", "breakdown", "step by step", "decompose"],
        "technique": "least-to-most"
    }
}


# Technique alternatives for rotation when primary fails
TECHNIQUE_ALTERNATIVES = {
    "tdd": ["reflexion", "self-refine"],
    "self-refine": ["reflexion", "tdd"],
    "reflexion": ["self-consistency", "tdd"],
    "chain-of-code": ["react", "least-to-most"],
    "tot": ["got", "ps-plus"],
    "ps-plus": ["tot", "react"],
    "react": ["ps-plus", "chain-of-code"],
    "self-consistency": ["reflexion", "self-refine"],
    "got": ["tot", "self-consistency"],
    "least-to-most": ["chain-of-code", "ps-plus"]
}


@dataclass
class EvaluationResult:
    """Result of evaluating a failure."""
    action: str              # "retry", "rotate", or "escalate"
    technique: str           # Technique to use (for retry/rotate)
    guidance: List[str]      # Lessons from memory bank
    rationale: str           # Why this action was chosen
    remaining_budget: int    # How many attempts left


class SelfCorrection:
    """
    Manages retry loops with memory bank, technique rotation, and escalation.

    Implements the Reflexion pattern to learn from failures and make intelligent
    decisions about how to proceed.
    """

    def __init__(self, memory_bank: MemoryBank, risk_level: str = "medium"):
        """
        Initialize the self-correction engine.

        Args:
            memory_bank: MemoryBank instance for this plan
            risk_level: Risk level for retry budget ("low", "medium", "high", "critical")
        """
        self.memory_bank = memory_bank
        self.risk_level = risk_level.lower()
        self.config = RETRY_CONFIG.get(self.risk_level, RETRY_CONFIG["medium"])

    def evaluate_failure(
        self,
        step_id: int,
        failure_type: str,
        failure_message: str,
        current_technique: str,
        attempts: Dict[str, int]
    ) -> EvaluationResult:
        """
        Evaluate a failure and recommend an action.

        Args:
            step_id: The step that failed
            failure_type: Category of failure
            failure_message: Detailed error message
            current_technique: The technique being used
            attempts: Dict with "same" and "alt" attempt counts

        Returns:
            EvaluationResult with recommended action
        """
        same_attempts = attempts.get("same", 0)
        alt_attempts = attempts.get("alt", 0)
        total_attempts = same_attempts + alt_attempts

        # Calculate remaining budget
        remaining = self.config["max_total"] - total_attempts

        # Get guidance from memory bank
        guidance = self._get_guidance(step_id, failure_type)

        # Check if we should escalate due to total budget exhaustion
        if remaining <= 0:
            return EvaluationResult(
                action="escalate",
                technique=current_technique,
                guidance=guidance,
                rationale=f"Retry budget exhausted ({self.config['max_total']} attempts)",
                remaining_budget=0
            )

        # Check if we should retry with same technique
        if same_attempts < self.config["max_same"]:
            return EvaluationResult(
                action="retry",
                technique=current_technique,
                guidance=guidance,
                rationale=f"Same-technique attempt {same_attempts + 1}/{self.config['max_same']}",
                remaining_budget=remaining
            )

        # Check if we should rotate to alternative technique
        if alt_attempts < self.config["max_alt"]:
            alt_technique = self._select_alternative(
                failure_message,
                current_technique
            )
            return EvaluationResult(
                action="rotate",
                technique=alt_technique,
                guidance=guidance,
                rationale=f"Rotating to {alt_technique} based on failure pattern",
                remaining_budget=remaining
            )

        # All options exhausted - escalate
        return EvaluationResult(
            action="escalate",
            technique=current_technique,
            guidance=guidance,
            rationale=f"All retry options exhausted after {total_attempts} attempts",
            remaining_budget=remaining
        )

    def _select_alternative(
        self,
        failure_message: str,
        exclude_technique: str
    ) -> str:
        """
        Select an alternative technique based on failure pattern.

        Args:
            failure_message: The failure message to analyze
            exclude_technique: Technique to exclude (current one)

        Returns:
            Name of the alternative technique
        """
        message_lower = failure_message.lower()

        # Pattern-based selection
        for pattern_name, pattern_data in FAILURE_PATTERNS.items():
            if any(kw in message_lower for kw in pattern_data["keywords"]):
                suggested = pattern_data["technique"]
                if suggested != exclude_technique:
                    return suggested

        # Fall back to alternatives list
        alternatives = TECHNIQUE_ALTERNATIVES.get(
            exclude_technique,
            ["ps-plus", "reflexion"]
        )

        for alt in alternatives:
            if alt != exclude_technique:
                return alt

        # Last resort fallback
        return "reflexion"

    def _get_guidance(self, step_id: int, failure_type: str) -> List[str]:
        """
        Get guidance from memory bank for this failure.

        Args:
            step_id: The step that failed
            failure_type: Type of failure

        Returns:
            List of relevant lessons
        """
        # Get step-specific lessons
        step_entries = self.memory_bank.get_by_step(step_id)
        step_lessons = [e.lesson for e in step_entries if e.lesson]

        # Get failure-type lessons
        type_lessons = self.memory_bank.get_lessons_for_failure(failure_type)

        # Combine and deduplicate, keeping most recent
        all_lessons = step_lessons + type_lessons
        seen = set()
        unique_lessons = []
        for lesson in reversed(all_lessons):
            if lesson not in seen:
                seen.add(lesson)
                unique_lessons.append(lesson)

        return list(reversed(unique_lessons))[-3:]  # Last 3 relevant lessons

    def record_failure(
        self,
        step_id: int,
        failure_type: str,
        context: str,
        technique_used: str
    ) -> MemoryBankEntry:
        """
        Record a failure to the memory bank.

        Args:
            step_id: The step that failed
            failure_type: Category of failure
            context: What was attempted
            technique_used: Which technique was active

        Returns:
            The created MemoryBankEntry
        """
        entry = create_entry(
            step_id=step_id,
            failure_type=failure_type,
            context=context,
            technique=technique_used
        )
        self.memory_bank.add_entry(entry)
        return entry

    def record_resolution(
        self,
        lesson: str,
        resolution: str
    ) -> bool:
        """
        Update the last failure entry with resolution.

        Args:
            lesson: What was learned
            resolution: How it was resolved

        Returns:
            True if successful, False if no entries to update
        """
        return self.memory_bank.update_last_resolution(lesson, resolution)

    def get_failure_summary(self, step_id: int) -> str:
        """
        Get a summary of failures for a step.

        Args:
            step_id: The step to summarize

        Returns:
            Formatted summary string
        """
        entries = self.memory_bank.get_by_step(step_id)

        if not entries:
            return "No failure history available"

        summary_lines = [f"{len(entries)} failures recorded:"]

        for entry in entries[-5:]:  # Last 5 entries
            context_preview = entry.context[:50] + "..." if len(entry.context) > 50 else entry.context
            summary_lines.append(f"- [{entry.failureType}] {context_preview}")

        return "\n".join(summary_lines)

    def get_retry_budget(self) -> Dict[str, int]:
        """Get the retry budget configuration."""
        return {
            "max_same_technique": self.config["max_same"],
            "max_alternative": self.config["max_alt"],
            "max_total": self.config["max_total"],
            "escalate_after": self.config["escalate_after"]
        }

    def format_escalation_message(
        self,
        step_id: int,
        step_name: str,
        total_attempts: int
    ) -> str:
        """
        Format a message for user escalation.

        Args:
            step_id: The step that failed
            step_name: Name of the step
            total_attempts: Number of attempts made

        Returns:
            Formatted escalation message
        """
        summary = self.get_failure_summary(step_id)
        guidance = self.memory_bank.to_prompt_context(3)

        return f"""
════════════════════════════════════════════════════════════════════
  ⚠️  ESCALATION REQUIRED
════════════════════════════════════════════════════════════════════

Step {step_id}: {step_name}
All {total_attempts} attempts exhausted.

{summary}

{guidance}

Options:
1. Review error details and provide guidance
2. Modify step requirements
3. Mark as blocked and continue with next step
4. Manual intervention needed

════════════════════════════════════════════════════════════════════
"""


def get_retry_config(risk_level: str) -> Dict[str, int]:
    """
    Get retry configuration for a risk level.

    Args:
        risk_level: "low", "medium", "high", or "critical"

    Returns:
        Configuration dict with retry limits
    """
    return RETRY_CONFIG.get(risk_level.lower(), RETRY_CONFIG["medium"])


# CLI entry point for testing
if __name__ == '__main__':
    import sys
    from pathlib import Path

    if len(sys.argv) < 4:
        print("Usage: python self_correction.py <plan_dir> <command> [args]")
        print("Commands:")
        print("  evaluate <step> <type> <technique> <same> <alt>")
        print("  budget <risk_level>")
        print("  alternative <technique> <message>")
        sys.exit(1)

    plan_dir = sys.argv[1]
    command = sys.argv[2]

    if command == "budget":
        risk_level = sys.argv[3] if len(sys.argv) > 3 else "medium"
        config = get_retry_config(risk_level)
        print(f"Risk Level: {risk_level.upper()}")
        print(f"  Same technique: {config['max_same']} attempts")
        print(f"  Alternative: {config['max_alt']} attempts")
        print(f"  Total budget: {config['max_total']}")
        print(f"  Escalate after: {config['escalate_after']}")

    elif command == "evaluate" and len(sys.argv) >= 8:
        step_id = int(sys.argv[3])
        failure_type = sys.argv[4]
        technique = sys.argv[5]
        same = int(sys.argv[6])
        alt = int(sys.argv[7])

        bank = MemoryBank(plan_dir)
        engine = SelfCorrection(bank)
        result = engine.evaluate_failure(
            step_id=step_id,
            failure_type=failure_type,
            failure_message=failure_type,
            current_technique=technique,
            attempts={"same": same, "alt": alt}
        )

        print(f"Action: {result.action}")
        print(f"Technique: {result.technique}")
        print(f"Rationale: {result.rationale}")
        print(f"Remaining: {result.remaining_budget}")
        if result.guidance:
            print("Guidance:")
            for g in result.guidance:
                print(f"  - {g}")

    elif command == "alternative" and len(sys.argv) >= 5:
        technique = sys.argv[3]
        message = sys.argv[4]

        bank = MemoryBank(plan_dir)
        engine = SelfCorrection(bank)
        alt = engine._select_alternative(message, technique)
        print(f"Alternative for {technique}: {alt}")

    else:
        print("Invalid command or missing arguments")
        sys.exit(1)
