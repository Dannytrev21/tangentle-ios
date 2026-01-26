"""
Feedback Store - Persistent storage for feedback data.

This module provides the FeedbackStore class for reading and writing
feedback data to JSON files with atomic writes to prevent data corruption.

Storage Location: .claude/planning-data/
"""

import copy
import json
import os
import threading
from datetime import datetime
from pathlib import Path
from typing import Optional

from feedback_models import (
    ClassificationEntry,
    ImplementationAttempt,
    StepAttempts,
)


# Default empty structures for each file type
EMPTY_EFFECTIVENESS = {
    "version": "1.0.0",
    "lastUpdated": None,
    "byProblemType": {},
}

EMPTY_CLASSIFICATION = {
    "version": "1.0.0",
    "entries": [],
    "corrections": {},
}

EMPTY_ATTEMPTS = {
    "version": "1.0.0",
    "byStepId": {},
}

EMPTY_METRICS = {
    "version": "1.0.0",
    "totalPlans": 0,
    "totalSteps": 0,
    "completedPlans": 0,
    "completedSteps": 0,
    "averageStepsPerPlan": 0.0,
    "averageAttemptsPerStep": 0.0,
    "byCategory": {},
    "lastUpdated": None,
}


class FeedbackStore:
    """
    Manages persistent storage of feedback data.

    Uses atomic writes (temp file + rename) to prevent data corruption.
    Creates the storage directory lazily on first write operation.
    """

    PLANNING_DATA_DIR = ".claude/planning-data"

    FILES = {
        "effectiveness": "technique-effectiveness.json",
        "classification": "classification-history.json",
        "attempts": "implementation-attempts.json",
        "metrics": "plan-metrics.json",
    }

    DEFAULTS = {
        "effectiveness": EMPTY_EFFECTIVENESS,
        "classification": EMPTY_CLASSIFICATION,
        "attempts": EMPTY_ATTEMPTS,
        "metrics": EMPTY_METRICS,
    }

    def __init__(self, base_path: str = "."):
        """
        Initialize the feedback store.

        Args:
            base_path: Base path for the project (default: current directory)
        """
        self.base_path = Path(base_path)
        self._lock = threading.Lock()

    def _get_data_dir(self) -> Path:
        """Get the path to the planning-data directory."""
        return self.base_path / self.PLANNING_DATA_DIR

    def _get_file_path(self, file_type: str) -> Path:
        """Get the full path to a specific data file."""
        return self._get_data_dir() / self.FILES[file_type]

    def ensure_directory(self) -> None:
        """
        Create the planning-data directory if it doesn't exist.

        This is called automatically before any write operation.
        """
        data_dir = self._get_data_dir()
        data_dir.mkdir(parents=True, exist_ok=True)

    def _atomic_write(self, file_path: Path, data: dict) -> None:
        """
        Write data atomically to prevent corruption.

        Uses the temp file + rename pattern:
        1. Write to a temp file
        2. Sync to disk
        3. Rename over target (atomic on POSIX)

        Args:
            file_path: Target file path
            data: Dictionary to write as JSON
        """
        temp_path = file_path.with_suffix(".tmp")

        with open(temp_path, "w") as f:
            json.dump(data, f, indent=2)
            f.flush()
            os.fsync(f.fileno())

        # Atomic rename
        temp_path.rename(file_path)

    def _load_file(self, file_type: str) -> dict:
        """
        Load data from a file, returning default if file doesn't exist.

        Args:
            file_type: One of "effectiveness", "classification", "attempts", "metrics"

        Returns:
            Dictionary with file contents or default structure
        """
        file_path = self._get_file_path(file_type)

        if not file_path.exists():
            return copy.deepcopy(self.DEFAULTS[file_type])

        try:
            with open(file_path) as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError):
            # Return default on corrupted file
            return copy.deepcopy(self.DEFAULTS[file_type])

    def _save_file(self, file_type: str, data: dict) -> None:
        """
        Save data to a file using atomic writes.

        Args:
            file_type: One of "effectiveness", "classification", "attempts", "metrics"
            data: Dictionary to save
        """
        self.ensure_directory()
        file_path = self._get_file_path(file_type)
        self._atomic_write(file_path, data)

    # =========================================================================
    # Effectiveness Operations
    # =========================================================================

    def get_effectiveness_data(self) -> dict:
        """
        Get technique effectiveness data.

        Returns:
            Dictionary with effectiveness data structure
        """
        return self._load_file("effectiveness")

    def update_technique_stats(
        self, problem_type: str, technique: str, success: bool, attempts: int
    ) -> None:
        """
        Update statistics for a technique on a problem type.

        Args:
            problem_type: The problem type (e.g., "debug", "new-feature")
            technique: The technique name (e.g., "tdd", "reflexion")
            success: Whether this use was successful
            attempts: Number of attempts in this use
        """
        with self._lock:
            data = self._load_file("effectiveness")

            # Ensure nested structure exists
            if problem_type not in data["byProblemType"]:
                data["byProblemType"][problem_type] = {}

            if technique not in data["byProblemType"][problem_type]:
                data["byProblemType"][problem_type][technique] = {
                    "success": 0,
                    "failure": 0,
                    "total_attempts": 0,
                    "average_attempts_to_success": 0.0,
                    "last_used": None,
                }

            stats = data["byProblemType"][problem_type][technique]

            # Update counts
            if success:
                stats["success"] += 1
            else:
                stats["failure"] += 1

            stats["total_attempts"] += attempts
            stats["last_used"] = datetime.now().isoformat()

            # Recalculate average attempts to success
            if stats["success"] > 0:
                stats["average_attempts_to_success"] = (
                    stats["total_attempts"] / stats["success"]
                )

            data["lastUpdated"] = datetime.now().isoformat()

            self._save_file("effectiveness", data)

    # =========================================================================
    # Classification Operations
    # =========================================================================

    def get_classification_history(self) -> list:
        """
        Get list of classification entries.

        Returns:
            List of classification entry dictionaries
        """
        data = self._load_file("classification")
        return data.get("entries", [])

    def add_classification(self, entry: ClassificationEntry) -> None:
        """
        Add a new classification entry to history.

        Args:
            entry: ClassificationEntry to add
        """
        with self._lock:
            data = self._load_file("classification")

            data["entries"].append(entry.to_dict())

            self._save_file("classification", data)

    def record_correction(
        self, description_hash: str, original: str, corrected: str
    ) -> None:
        """
        Record a user correction for a classification.

        Args:
            description_hash: Hash of the description being corrected
            original: Original classification
            corrected: User-corrected classification
        """
        with self._lock:
            data = self._load_file("classification")

            if "corrections" not in data:
                data["corrections"] = {}

            data["corrections"][description_hash] = {
                "original": original,
                "corrected_to": corrected,
                "timestamp": datetime.now().isoformat(),
            }

            self._save_file("classification", data)

    # =========================================================================
    # Attempt Operations
    # =========================================================================

    def get_step_attempts(self, plan_id: str, step_id: int) -> Optional[StepAttempts]:
        """
        Get all attempts for a specific plan step.

        Args:
            plan_id: The plan identifier (e.g., "007")
            step_id: The step number within the plan

        Returns:
            StepAttempts object or None if no attempts recorded
        """
        data = self._load_file("attempts")
        key = f"{plan_id}:{step_id}"

        if key not in data.get("byStepId", {}):
            return None

        return StepAttempts.from_dict(data["byStepId"][key])

    def record_attempt(
        self,
        plan_id: str,
        step_id: int,
        attempt: ImplementationAttempt,
        problem_type: str = "",
    ) -> None:
        """
        Record a new attempt for a plan step.

        Args:
            plan_id: The plan identifier
            step_id: The step number
            attempt: The ImplementationAttempt to record
            problem_type: The problem type for this step
        """
        with self._lock:
            data = self._load_file("attempts")

            if "byStepId" not in data:
                data["byStepId"] = {}

            key = f"{plan_id}:{step_id}"

            if key not in data["byStepId"]:
                # Create new step entry
                data["byStepId"][key] = {
                    "plan_id": plan_id,
                    "step_id": step_id,
                    "problem_type": problem_type,
                    "attempts": [],
                    "total_attempts": 0,
                    "final_success": False,
                    "techniques_used": [],
                }

            step_data = data["byStepId"][key]

            # Add the attempt
            step_data["attempts"].append(attempt.to_dict())
            step_data["total_attempts"] = len(step_data["attempts"])

            # Update techniques used
            if attempt.technique not in step_data["techniques_used"]:
                step_data["techniques_used"].append(attempt.technique)

            # Update final success status
            if attempt.success:
                step_data["final_success"] = True

            self._save_file("attempts", data)

    # =========================================================================
    # Metrics Operations
    # =========================================================================

    def get_metrics(self) -> dict:
        """
        Get aggregate plan metrics.

        Returns:
            Dictionary with plan metrics
        """
        return self._load_file("metrics")

    def update_metrics(self, **kwargs) -> None:
        """
        Update plan metrics with provided values.

        Args:
            **kwargs: Metric key-value pairs to update
        """
        with self._lock:
            data = self._load_file("metrics")

            for key, value in kwargs.items():
                if key in data:
                    data[key] = value

            data["lastUpdated"] = datetime.now().isoformat()

            self._save_file("metrics", data)


# Convenience function for getting a store instance
def get_feedback_store(base_path: str = ".") -> FeedbackStore:
    """
    Get a FeedbackStore instance.

    Args:
        base_path: Base path for the project

    Returns:
        FeedbackStore instance
    """
    return FeedbackStore(base_path=base_path)
