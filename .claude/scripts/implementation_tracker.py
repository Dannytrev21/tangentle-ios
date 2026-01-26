"""
Implementation Attempt Tracker for the Intelligent Planning System.

This module tracks methods used during step implementation to avoid
repeating failed approaches. It works at a per-step granularity,
tracking individual attempts with timing and outcomes.

Key distinction from other tracking:
- MemoryBank: Per-step session memory (lessons within retries)
- EffectivenessTracker: Cross-plan aggregate statistics
- ImplementationTracker: Per-implementation detail (methods tried, errors, timing)
"""

from datetime import datetime
from typing import Optional

from feedback_models import ImplementationAttempt, StepAttempts
from feedback_store import FeedbackStore


class ImplementationTracker:
    """
    Tracks implementation attempts for plan steps.

    Provides methods to:
    - Record attempt starts/ends with timing
    - Identify failed approaches to avoid
    - Suggest alternative techniques
    - Generate human-readable summaries
    """

    def __init__(self, store: FeedbackStore):
        """
        Initialize the implementation tracker.

        Args:
            store: FeedbackStore instance for persistence
        """
        self.store = store
        self._active_attempts: dict[str, dict] = {}  # step_key -> current attempt

    def _step_key(self, plan_id: str, step_id: int) -> str:
        """Generate a unique key for a plan step."""
        return f"{plan_id}_{step_id}"

    def start_attempt(
        self,
        plan_id: str,
        step_id: int,
        problem_type: str,
        technique: str,
        method_description: str,
    ) -> int:
        """
        Start tracking a new implementation attempt.

        Args:
            plan_id: The plan identifier (e.g., "007")
            step_id: The step number within the plan
            problem_type: The problem type (e.g., "debug", "new-feature")
            technique: The technique being used (e.g., "tdd", "reflexion")
            method_description: Brief description of the approach

        Returns:
            The attempt number (1, 2, 3, etc.)
        """
        key = self._step_key(plan_id, step_id)

        # Get current step record to determine attempt number
        step_record = self.store.get_step_attempts(plan_id, step_id)
        if step_record:
            attempt_number = step_record.total_attempts + 1
        else:
            attempt_number = 1

        # Track active attempt in memory for timing
        self._active_attempts[key] = {
            "attempt_number": attempt_number,
            "technique": technique,
            "method": method_description,
            "problem_type": problem_type,
            "started_at": datetime.now().isoformat(),
        }

        return attempt_number

    def end_attempt(
        self,
        plan_id: str,
        step_id: int,
        success: bool,
        error_summary: Optional[str] = None,
    ) -> Optional[ImplementationAttempt]:
        """
        End and record the current implementation attempt.

        Args:
            plan_id: The plan identifier
            step_id: The step number
            success: Whether the attempt was successful
            error_summary: Error description if unsuccessful

        Returns:
            The recorded ImplementationAttempt, or None if no active attempt
        """
        key = self._step_key(plan_id, step_id)

        if key not in self._active_attempts:
            return None

        active = self._active_attempts.pop(key)
        ended_at = datetime.now()
        started_at = datetime.fromisoformat(active["started_at"])
        duration = int((ended_at - started_at).total_seconds())

        # Create the attempt record
        attempt = ImplementationAttempt(
            attempt_number=active["attempt_number"],
            technique=active["technique"],
            method=active["method"],
            started_at=active["started_at"],
            ended_at=ended_at.isoformat(),
            duration_seconds=duration,
            error_summary=error_summary if not success else None,
            success=success,
        )

        # Persist via store
        self.store.record_attempt(
            plan_id=plan_id,
            step_id=step_id,
            attempt=attempt,
            problem_type=active["problem_type"],
        )

        return attempt

    def get_attempts(self, plan_id: str, step_id: int) -> list[ImplementationAttempt]:
        """
        Get all attempts for a specific step.

        Args:
            plan_id: The plan identifier
            step_id: The step number

        Returns:
            List of ImplementationAttempt objects
        """
        step_record = self.store.get_step_attempts(plan_id, step_id)
        if not step_record:
            return []
        return step_record.attempts

    def get_techniques_used(self, plan_id: str, step_id: int) -> list[str]:
        """
        Get unique techniques used for a step.

        Args:
            plan_id: The plan identifier
            step_id: The step number

        Returns:
            List of technique names (unique, preserving order)
        """
        step_record = self.store.get_step_attempts(plan_id, step_id)
        if not step_record:
            return []
        return step_record.techniques_used

    def get_methods_used(self, plan_id: str, step_id: int) -> list[str]:
        """
        Get all methods/approaches used for a step.

        Args:
            plan_id: The plan identifier
            step_id: The step number

        Returns:
            List of method descriptions
        """
        attempts = self.get_attempts(plan_id, step_id)
        return [a.method for a in attempts]

    def get_failed_techniques(self, plan_id: str, step_id: int) -> list[str]:
        """
        Get techniques that have failed consistently.

        A technique is considered "failed" only if ALL attempts with that
        technique failed (i.e., none succeeded).

        Args:
            plan_id: The plan identifier
            step_id: The step number

        Returns:
            List of technique names that have only failures
        """
        attempts = self.get_attempts(plan_id, step_id)
        if not attempts:
            return []

        # Group attempts by technique
        technique_results: dict[str, list[bool]] = {}
        for attempt in attempts:
            if attempt.technique not in technique_results:
                technique_results[attempt.technique] = []
            technique_results[attempt.technique].append(attempt.success)

        # Return techniques where all attempts failed
        failed = []
        for technique, results in technique_results.items():
            if not any(results):  # All False
                failed.append(technique)

        return failed

    def get_methods_to_avoid(
        self, plan_id: str, step_id: int
    ) -> list[tuple[str, str]]:
        """
        Get (technique, method) pairs that failed.

        Args:
            plan_id: The plan identifier
            step_id: The step number

        Returns:
            List of (technique, method) tuples for failed attempts
        """
        attempts = self.get_attempts(plan_id, step_id)
        return [
            (a.technique, a.method)
            for a in attempts
            if not a.success
        ]

    def get_time_spent(self, plan_id: str, step_id: int) -> int:
        """
        Get total time spent on all attempts for a step.

        Args:
            plan_id: The plan identifier
            step_id: The step number

        Returns:
            Total seconds spent across all attempts
        """
        attempts = self.get_attempts(plan_id, step_id)
        return sum(a.duration_seconds for a in attempts)

    def has_tried_technique(
        self, plan_id: str, step_id: int, technique: str
    ) -> bool:
        """
        Check if a technique has been used for a step.

        Args:
            plan_id: The plan identifier
            step_id: The step number
            technique: The technique name to check

        Returns:
            True if technique has been tried
        """
        techniques_used = self.get_techniques_used(plan_id, step_id)
        return technique in techniques_used

    def suggest_next_technique(
        self, plan_id: str, step_id: int, available_techniques: list[str]
    ) -> Optional[str]:
        """
        Suggest the next technique to try.

        Prefers untried techniques first, then excludes failed ones.

        Args:
            plan_id: The plan identifier
            step_id: The step number
            available_techniques: List of techniques to choose from

        Returns:
            Suggested technique name, or None if all have failed
        """
        failed = set(self.get_failed_techniques(plan_id, step_id))
        tried = set(self.get_techniques_used(plan_id, step_id))

        # First preference: untried techniques
        untried = [t for t in available_techniques if t not in tried]
        if untried:
            return untried[0]

        # Second preference: tried but not failed
        for technique in available_techniques:
            if technique not in failed:
                return technique

        # All available techniques have failed
        return None

    def get_attempt_summary(self, plan_id: str, step_id: int) -> str:
        """
        Generate a human-readable summary of attempts.

        Args:
            plan_id: The plan identifier
            step_id: The step number

        Returns:
            Formatted summary string
        """
        attempts = self.get_attempts(plan_id, step_id)
        if not attempts:
            return "No previous attempts recorded."

        total_time = self.get_time_spent(plan_id, step_id)
        minutes = total_time // 60
        time_str = f"{minutes} minutes" if minutes > 0 else f"{total_time} seconds"

        lines = [f"Previous attempts ({len(attempts)} total, {time_str}):"]

        for attempt in attempts:
            status = "Success" if attempt.success else f"Failed ({attempt.error_summary})"
            lines.append(
                f"- Attempt {attempt.attempt_number}: {attempt.technique} - "
                f"{attempt.method} → {status}"
            )

        methods_to_avoid = self.get_methods_to_avoid(plan_id, step_id)
        if methods_to_avoid:
            lines.append("\nMethods to avoid:")
            for technique, method in methods_to_avoid:
                lines.append(f"- {technique}: {method}")

        return "\n".join(lines)


# Convenience function
def get_implementation_tracker(store: FeedbackStore) -> ImplementationTracker:
    """
    Get an ImplementationTracker instance.

    Args:
        store: FeedbackStore instance

    Returns:
        ImplementationTracker instance
    """
    return ImplementationTracker(store)
