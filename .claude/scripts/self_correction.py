"""
Self-Correction Engine for the Intelligent Planning System.

This module implements the Reflexion pattern with memory bank, failure analysis,
technique rotation, and graceful escalation for high-risk steps.
"""

from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional
import json
import re

from memory_bank import MemoryBank, MemoryBankEntry, create_entry_from_failure
from risk_assessor import RiskAssessor, StepInfo, RiskLevel, RetryConfig


@dataclass
class FailureInfo:
    """Information about a failure for analysis."""
    failure_type: str  # "test_failure", "verification_failed", "runtime_error", "build_error"
    details: str  # Specific error message/output
    acceptance_criteria: dict  # Which criteria passed/failed {"AC1": True, "AC2": False}
    attempt_number: int
    technique_used: str
    phase: str  # "planning", "implementation", "verification"

    def get_failed_criteria(self) -> list[str]:
        """Get list of failed acceptance criteria."""
        return [k for k, v in self.acceptance_criteria.items() if not v]

    def get_passed_criteria(self) -> list[str]:
        """Get list of passed acceptance criteria."""
        return [k for k, v in self.acceptance_criteria.items() if v]


@dataclass
class RetryDecision:
    """Decision about how to proceed after a failure."""
    action: str  # "retry_same", "retry_alternative", "escalate"
    technique: str  # Technique to use for retry
    guidance: str  # Specific guidance for the retry
    memory_context: str  # Lessons to include in retry
    remaining_budget: int  # Remaining retry attempts

    @property
    def should_retry(self) -> bool:
        """Return True if the decision is to retry."""
        return self.action in ("retry_same", "retry_alternative")

    @property
    def should_escalate(self) -> bool:
        """Return True if the decision is to escalate."""
        return self.action == "escalate"


# Technique alternatives for rotation
# Maps each technique to alternatives ordered by preference
TECHNIQUE_ALTERNATIVES: dict[str, list[str]] = {
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

# Failure patterns and their preferred techniques
FAILURE_PATTERN_TECHNIQUES: dict[str, str] = {
    "not converging": "self-consistency",
    "iteration": "self-consistency",
    "edge case": "tdd",
    "missing case": "tdd",
    "complex": "tot",
    "architecture": "tot",
    "async": "react",
    "timing": "react",
    "decomposition": "least-to-most",
    "step by step": "least-to-most",
    "memory": "reflexion",
    "repeat": "reflexion",
}


class SelfCorrectionEngine:
    """
    Manages retry loops with memory bank, technique rotation, and escalation.

    Implements the Reflexion pattern to learn from failures and make intelligent
    decisions about how to proceed.
    """

    def __init__(self, config_path: str = ".claude/technique-config.json"):
        """
        Initialize the self-correction engine.

        Args:
            config_path: Path to the technique configuration file
        """
        self.assessor = RiskAssessor(config_path)
        self.memory_banks: dict[str, MemoryBank] = {}  # step_id -> bank
        self.technique_history: dict[str, list[str]] = {}  # step_id -> techniques used

    def get_memory_bank(self, step_id: str) -> MemoryBank:
        """
        Get or create a memory bank for a step.

        Args:
            step_id: Unique identifier for the step

        Returns:
            MemoryBank instance for this step
        """
        if step_id not in self.memory_banks:
            self.memory_banks[step_id] = MemoryBank()
        return self.memory_banks[step_id]

    def load_memory_bank(self, step_id: str, data: dict) -> MemoryBank:
        """
        Load a memory bank from persisted JSON data.

        Args:
            step_id: Unique identifier for the step
            data: JSON dict containing memory bank state

        Returns:
            Restored MemoryBank instance
        """
        bank = MemoryBank.from_json(data)
        self.memory_banks[step_id] = bank
        return bank

    def should_retry(
        self,
        step: StepInfo,
        failure: FailureInfo
    ) -> RetryDecision:
        """
        Decide whether to retry and how.

        Args:
            step: Information about the current step
            failure: Information about the failure

        Returns:
            RetryDecision with action, technique, and guidance
        """
        # Get risk assessment and retry config
        risk = self.assessor.assess_risk(step)
        config = risk.retry_config
        step_id = str(getattr(step, 'id', 'unknown'))
        bank = self.get_memory_bank(step_id)

        # Calculate remaining budget
        remaining = config.max_total - failure.attempt_number

        # Check if budget exhausted
        if remaining <= 0:
            return RetryDecision(
                action="escalate",
                technique=failure.technique_used,
                guidance="All retry attempts exhausted. User intervention required.",
                memory_context=bank.to_prompt_context(),
                remaining_budget=0
            )

        # Check for critical failure patterns
        if self._is_critical_failure(failure):
            return RetryDecision(
                action="escalate",
                technique=failure.technique_used,
                guidance=f"Critical failure detected: {failure.details[:100]}. User intervention required.",
                memory_context=bank.to_prompt_context(),
                remaining_budget=remaining
            )

        # Track technique history
        if step_id not in self.technique_history:
            self.technique_history[step_id] = []
        self.technique_history[step_id].append(failure.technique_used)

        # Count attempts with current technique
        current_technique_attempts = sum(
            1 for t in self.technique_history.get(step_id, [])
            if t == failure.technique_used
        )

        # Decide retry strategy
        if current_technique_attempts < config.max_same_technique:
            # Retry with same technique
            return RetryDecision(
                action="retry_same",
                technique=failure.technique_used,
                guidance=self._generate_guidance(failure, bank),
                memory_context=bank.to_prompt_context(),
                remaining_budget=remaining
            )
        else:
            # Rotate to alternative technique
            new_technique = self.rotate_technique(
                failure.technique_used,
                failure.details
            )
            return RetryDecision(
                action="retry_alternative",
                technique=new_technique,
                guidance=f"Switching to {new_technique.upper()} due to repeated failures with {failure.technique_used.upper()}.\n\n{self._generate_guidance(failure, bank)}",
                memory_context=bank.to_prompt_context(),
                remaining_budget=remaining
            )

    def _is_critical_failure(self, failure: FailureInfo) -> bool:
        """Check if failure is critical and requires immediate escalation."""
        details_lower = failure.details.lower()
        critical_patterns = [
            "data corruption",
            "data loss",
            "security vulnerability",
            "infinite loop",
            "memory leak",
            "fatal error",
            "unrecoverable"
        ]
        return any(pattern in details_lower for pattern in critical_patterns)

    def record_failure(
        self,
        step: StepInfo,
        failure: FailureInfo
    ) -> MemoryBankEntry:
        """
        Record a failure in the memory bank.

        Args:
            step: Information about the current step
            failure: Information about the failure

        Returns:
            The created MemoryBankEntry
        """
        entry = self._analyze_failure(failure)
        step_id = str(getattr(step, 'id', 'unknown'))
        bank = self.get_memory_bank(step_id)
        bank.add_entry(entry)
        return entry

    def _analyze_failure(self, failure: FailureInfo) -> MemoryBankEntry:
        """
        Analyze a failure and create a memory bank entry.

        Uses pattern matching to identify common failure types and generate
        specific, actionable lessons.

        Args:
            failure: The failure to analyze

        Returns:
            MemoryBankEntry with failure analysis
        """
        details_lower = failure.details.lower()

        # Swift/iOS specific patterns
        if "nil" in details_lower or "optional" in details_lower or "unwrap" in details_lower:
            return create_entry_from_failure(
                failure_summary="Nil/optional handling issue",
                root_cause="Missing unwrapping or nil check",
                lesson="Add guard/if-let for optional values before use",
                technique=failure.technique_used,
                applicable_to=["data-access", "service-impl", "validation", "api-integration"]
            )

        if "async" in details_lower or "await" in details_lower or "concurrency" in details_lower:
            return create_entry_from_failure(
                failure_summary="Async/await issue",
                root_cause="Missing await or incorrect async context",
                lesson="Ensure async functions are awaited properly and MainActor is used for UI updates",
                technique=failure.technique_used,
                applicable_to=["api-integration", "data-access", "service-impl", "ui"]
            )

        if "core data" in details_lower or "nsmanagedobject" in details_lower or "context" in details_lower:
            return create_entry_from_failure(
                failure_summary="Core Data context issue",
                root_cause="Wrong context or threading issue with Core Data",
                lesson="Use context.perform for thread safety, ensure objects belong to correct context",
                technique=failure.technique_used,
                applicable_to=["data-access", "data-modeling", "migration"]
            )

        # Test-related patterns (including XCT assertions)
        if ("test" in details_lower or "xct" in details_lower) and ("fail" in details_lower or "assert" in details_lower):
            failed_criteria = failure.get_failed_criteria()
            return create_entry_from_failure(
                failure_summary=f"Test failure in {', '.join(failed_criteria) if failed_criteria else 'tests'}",
                root_cause="Implementation doesn't match test expectation",
                lesson="Review test assertions carefully - the test is the spec. Check expected vs actual values.",
                technique=failure.technique_used,
                applicable_to=["unit-test", "integration-test", "tdd", "general"]
            )

        # Build/compilation patterns
        if "build" in details_lower or "compile" in details_lower or "syntax" in details_lower:
            return create_entry_from_failure(
                failure_summary="Build/compilation error",
                root_cause="Syntax error or type mismatch",
                lesson="Check syntax, ensure types match, verify imports are correct",
                technique=failure.technique_used,
                applicable_to=["general"]
            )

        # Import/dependency patterns
        if "import" in details_lower or "module" in details_lower or "no such module" in details_lower:
            return create_entry_from_failure(
                failure_summary="Import/dependency issue",
                root_cause="Missing import or incorrect module reference",
                lesson="Verify module exists, check spelling, ensure target membership is correct",
                technique=failure.technique_used,
                applicable_to=["infrastructure", "service-impl", "general"]
            )

        # UI-related patterns
        if "view" in details_lower or "swiftui" in details_lower or "layout" in details_lower:
            return create_entry_from_failure(
                failure_summary="UI/SwiftUI issue",
                root_cause="View body or layout problem",
                lesson="Check view body is valid, ensure modifiers are correctly ordered, verify state management",
                technique=failure.technique_used,
                applicable_to=["ui", "component-lib", "animation"]
            )

        # Timeout patterns
        if "timeout" in details_lower or "timed out" in details_lower:
            return create_entry_from_failure(
                failure_summary="Timeout issue",
                root_cause="Operation took too long or deadlock occurred",
                lesson="Check for infinite loops, verify async operations complete, add timeout handling",
                technique=failure.technique_used,
                applicable_to=["api-integration", "integration-test", "e2e-test"]
            )

        # Generic fallback
        return create_entry_from_failure(
            failure_summary=failure.details[:100] if failure.details else "Unknown failure",
            root_cause="Unknown - requires manual analysis",
            lesson="Review error details carefully before retrying. Check logs and stack traces.",
            technique=failure.technique_used,
            applicable_to=["general"]
        )

    def rotate_technique(
        self,
        current_technique: str,
        failure_pattern: str
    ) -> str:
        """
        Select an alternative technique based on failure pattern.

        Args:
            current_technique: The technique that failed
            failure_pattern: Description of the failure

        Returns:
            Name of the alternative technique to try
        """
        failure_lower = failure_pattern.lower()

        # Pattern-based selection
        for pattern, technique in FAILURE_PATTERN_TECHNIQUES.items():
            if pattern in failure_lower and technique != current_technique:
                return technique

        # Fall back to alternatives list
        alternatives = TECHNIQUE_ALTERNATIVES.get(current_technique, ["ps-plus"])

        # Find first alternative not recently used
        for alt in alternatives:
            if alt != current_technique:
                return alt

        # Last resort fallback
        return "ps-plus"

    def _generate_guidance(self, failure: FailureInfo, bank: MemoryBank) -> str:
        """
        Generate specific guidance for a retry attempt.

        Args:
            failure: The failure information
            bank: Memory bank with lessons

        Returns:
            Formatted guidance string
        """
        guidance_parts = [
            f"Retry attempt {failure.attempt_number + 1}.",
            ""
        ]

        # Add failure details
        if failure.details:
            guidance_parts.append("**Previous Failure**:")
            guidance_parts.append(failure.details[:300])
            guidance_parts.append("")

        # Add failed criteria
        failed = failure.get_failed_criteria()
        if failed:
            guidance_parts.append("**Failed Acceptance Criteria**:")
            for criteria in failed:
                guidance_parts.append(f"- {criteria}")
            guidance_parts.append("")

        # Add lessons from memory bank
        lessons = bank.get_relevant_lessons("general")
        if lessons:
            guidance_parts.append("**Lessons from Previous Attempts**:")
            for lesson in lessons[-3:]:  # Last 3 lessons
                guidance_parts.append(f"- {lesson}")
            guidance_parts.append("")

        guidance_parts.append("**Instructions**:")
        guidance_parts.append("Apply the lessons above. Do NOT repeat the same mistakes.")

        return "\n".join(guidance_parts)

    def get_recovery_prompt(
        self,
        step: StepInfo,
        technique: str
    ) -> str:
        """
        Generate a recovery prompt with memory bank context.

        Args:
            step: Information about the current step
            technique: The technique to use for recovery

        Returns:
            Formatted recovery prompt
        """
        step_id = str(getattr(step, 'id', 'unknown'))
        bank = self.get_memory_bank(step_id)
        context = bank.to_prompt_context()

        problem_type = getattr(step, 'problem_type', 'unknown')
        specific_lessons = bank.get_relevant_lessons(problem_type)

        prompt_parts = [
            "## Recovery Attempt",
            "",
            context,
            "",
            "### Instructions",
            f"Apply the lessons above while implementing this step.",
            f"Use **{technique.upper()}** methodology for this attempt.",
            "",
            "Do NOT repeat the same mistakes. Specifically address:"
        ]

        if specific_lessons:
            for lesson in specific_lessons:
                prompt_parts.append(f"- {lesson}")
        else:
            prompt_parts.append("- Review all error details carefully before proceeding")

        return "\n".join(prompt_parts)

    def get_technique_history(self, step_id: str) -> list[str]:
        """Get the history of techniques used for a step."""
        return self.technique_history.get(step_id, [])

    def reset_step(self, step_id: str, preserve_lessons: bool = False) -> None:
        """
        Reset the state for a step.

        Args:
            step_id: The step to reset
            preserve_lessons: If True, keep memory bank lessons
        """
        if not preserve_lessons and step_id in self.memory_banks:
            del self.memory_banks[step_id]
        if step_id in self.technique_history:
            del self.technique_history[step_id]

    def export_state(self, step_id: str) -> dict:
        """
        Export the state for a step for persistence.

        Args:
            step_id: The step to export

        Returns:
            Dictionary with memory bank and technique history
        """
        return {
            "memory_bank": self.get_memory_bank(step_id).to_json(),
            "technique_history": self.technique_history.get(step_id, [])
        }

    def import_state(self, step_id: str, state: dict) -> None:
        """
        Import previously exported state.

        Args:
            step_id: The step to restore
            state: Dictionary from export_state
        """
        if "memory_bank" in state:
            self.memory_banks[step_id] = MemoryBank.from_json(state["memory_bank"])
        if "technique_history" in state:
            self.technique_history[step_id] = state["technique_history"]
