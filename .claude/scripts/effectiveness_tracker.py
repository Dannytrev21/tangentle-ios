"""
Effectiveness Tracker for the Intelligent Planning System.

This module calculates technique effectiveness based on historical data
and provides recommendations for technique selection.

Effectiveness Formula:
    effectiveness = (success_rate * 0.7) + (speed_factor * 0.3)

    where:
      success_rate = success / (success + failure)
      speed_factor = min(1.0, baseline_attempts / average_attempts_to_success)
      baseline_attempts = 2 (expected attempts for a technique)
"""

from typing import Optional

from feedback_store import FeedbackStore


class EffectivenessTracker:
    """
    Tracks and calculates technique effectiveness based on historical data.

    Uses a minimum sample threshold before making recommendations to prevent
    overfitting to small sample sizes.
    """

    MIN_SAMPLES = 10
    BASELINE_ATTEMPTS = 2

    # Weights for effectiveness formula
    SUCCESS_WEIGHT = 0.7
    SPEED_WEIGHT = 0.3

    def __init__(self, store: FeedbackStore):
        """
        Initialize the effectiveness tracker.

        Args:
            store: FeedbackStore instance for data access
        """
        self.store = store

    def record_outcome(
        self, problem_type: str, technique: str, success: bool, attempts: int
    ) -> None:
        """
        Record the outcome of using a technique.

        Args:
            problem_type: The problem type (e.g., "debug", "new-feature")
            technique: The technique used (e.g., "tdd", "reflexion")
            success: Whether the technique succeeded
            attempts: Number of attempts before resolution
        """
        self.store.update_technique_stats(problem_type, technique, success, attempts)

    def get_sample_count(self, problem_type: str, technique: str) -> int:
        """
        Get the number of samples (success + failure) for a technique.

        Args:
            problem_type: The problem type
            technique: The technique name

        Returns:
            Number of samples recorded
        """
        data = self.store.get_effectiveness_data()
        techniques = data.get("byProblemType", {}).get(problem_type, {})

        if technique not in techniques:
            return 0

        stats = techniques[technique]
        return stats.get("success", 0) + stats.get("failure", 0)

    def has_sufficient_data(self, problem_type: str, technique: str) -> bool:
        """
        Check if there's enough data to calculate effectiveness.

        Args:
            problem_type: The problem type
            technique: The technique name

        Returns:
            True if sample count >= MIN_SAMPLES
        """
        return self.get_sample_count(problem_type, technique) >= self.MIN_SAMPLES

    def get_effectiveness(self, problem_type: str, technique: str) -> Optional[float]:
        """
        Calculate effectiveness score for a technique on a problem type.

        Formula: (success_rate * 0.7) + (speed_factor * 0.3)

        Args:
            problem_type: The problem type
            technique: The technique name

        Returns:
            Effectiveness score (0.0 to 1.0) or None if insufficient data
        """
        data = self.store.get_effectiveness_data()
        techniques = data.get("byProblemType", {}).get(problem_type, {})

        if technique not in techniques:
            return None

        stats = techniques[technique]
        success = stats.get("success", 0)
        failure = stats.get("failure", 0)
        total_samples = success + failure

        # Check minimum threshold
        if total_samples < self.MIN_SAMPLES:
            return None

        # Calculate success rate
        success_rate = success / total_samples if total_samples > 0 else 0.0

        # Calculate speed factor
        if success > 0:
            total_attempts = stats.get("total_attempts", 0)
            avg_attempts = total_attempts / success if success > 0 else self.BASELINE_ATTEMPTS
            speed_factor = min(1.0, self.BASELINE_ATTEMPTS / avg_attempts)
        else:
            # All failures - speed factor doesn't apply meaningfully
            speed_factor = 0.0

        # Calculate effectiveness
        effectiveness = (success_rate * self.SUCCESS_WEIGHT) + (speed_factor * self.SPEED_WEIGHT)

        return min(1.0, effectiveness)  # Cap at 1.0

    def get_all_effectiveness(self, problem_type: str) -> dict[str, float]:
        """
        Get effectiveness scores for all techniques with sufficient data.

        Args:
            problem_type: The problem type

        Returns:
            Dictionary mapping technique name to effectiveness score
        """
        data = self.store.get_effectiveness_data()
        techniques = data.get("byProblemType", {}).get(problem_type, {})

        scores = {}
        for technique in techniques:
            effectiveness = self.get_effectiveness(problem_type, technique)
            if effectiveness is not None:
                scores[technique] = effectiveness

        return scores

    def get_recommended_technique(
        self,
        problem_type: str,
        available_techniques: list[str],
        phase: str,
    ) -> tuple[str, float, str]:
        """
        Get the recommended technique based on historical effectiveness.

        Args:
            problem_type: The problem type
            available_techniques: List of techniques to choose from
            phase: The phase (e.g., "planning", "implementation", "verification")

        Returns:
            Tuple of (technique_name, confidence, rationale)
        """
        if not available_techniques:
            return ("", 0.0, "No techniques available")

        effectiveness_scores = self.get_all_effectiveness(problem_type)

        if not effectiveness_scores:
            # Cold start: no historical data
            return (
                available_techniques[0],
                0.5,
                "Using default (insufficient historical data)",
            )

        # Filter to available techniques
        available_scores = {
            t: s for t, s in effectiveness_scores.items() if t in available_techniques
        }

        if not available_scores:
            return (
                available_techniques[0],
                0.5,
                "No effectiveness data for available techniques",
            )

        # Find best technique
        best_technique = max(available_scores.items(), key=lambda x: x[1])

        return (
            best_technique[0],
            min(0.95, best_technique[1]),  # Cap confidence at 95%
            f"Historical effectiveness: {best_technique[1]:.0%}",
        )

    def get_technique_ranking(
        self, problem_type: str
    ) -> list[tuple[str, float, int]]:
        """
        Get all techniques ranked by effectiveness.

        Args:
            problem_type: The problem type

        Returns:
            List of (technique, effectiveness, sample_count) sorted by effectiveness desc
        """
        data = self.store.get_effectiveness_data()
        techniques = data.get("byProblemType", {}).get(problem_type, {})

        rankings = []
        for technique in techniques:
            effectiveness = self.get_effectiveness(problem_type, technique)
            if effectiveness is not None:
                sample_count = self.get_sample_count(problem_type, technique)
                rankings.append((technique, effectiveness, sample_count))

        # Sort by effectiveness descending
        rankings.sort(key=lambda x: x[1], reverse=True)

        return rankings


# Convenience function
def get_effectiveness_tracker(store: FeedbackStore) -> EffectivenessTracker:
    """
    Get an EffectivenessTracker instance.

    Args:
        store: FeedbackStore instance

    Returns:
        EffectivenessTracker instance
    """
    return EffectivenessTracker(store)
