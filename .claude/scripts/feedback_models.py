"""
Feedback Data Models for the Intelligent Planning System.

This module defines dataclasses for tracking:
- Technique effectiveness (success/failure per technique per problem type)
- Classification history (semantic classification with correction tracking)
- Implementation attempts (detailed per-step attempt tracking)

All dataclasses support JSON serialization via to_dict() and from_dict() methods,
following the pattern established in memory_bank.py.
"""

from dataclasses import dataclass, field
from typing import Optional, List
import hashlib


def generate_description_hash(description: str) -> str:
    """
    Generate a SHA-256 hash of a normalized description.

    Normalization:
    - Converts to lowercase
    - Collapses whitespace
    - Strips leading/trailing whitespace

    Args:
        description: The description to hash

    Returns:
        64-character hex string (SHA-256)
    """
    # Normalize: lowercase, collapse whitespace, strip
    normalized = " ".join(description.lower().split())
    return hashlib.sha256(normalized.encode("utf-8")).hexdigest()


@dataclass
class TechniqueStats:
    """
    Statistics for a technique's effectiveness on a problem type.

    Tracks success/failure counts and timing information to enable
    learning which techniques work best for which problem types.
    """
    success: int
    failure: int
    total_attempts: int
    average_attempts_to_success: float
    last_used: str  # ISO-8601 timestamp

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization."""
        return {
            "success": self.success,
            "failure": self.failure,
            "total_attempts": self.total_attempts,
            "average_attempts_to_success": self.average_attempts_to_success,
            "last_used": self.last_used
        }

    @classmethod
    def from_dict(cls, data: dict) -> "TechniqueStats":
        """
        Create from dictionary.

        Handles missing keys with sensible defaults.
        """
        return cls(
            success=data.get("success", 0),
            failure=data.get("failure", 0),
            total_attempts=data.get("total_attempts", 0),
            average_attempts_to_success=data.get("average_attempts_to_success", 0.0),
            last_used=data.get("last_used", "")
        )


@dataclass
class ClassificationEntry:
    """
    A semantic classification entry with correction tracking.

    Stores the original classification and any user corrections,
    enabling the system to learn from user feedback.
    """
    id: str
    description: str
    description_hash: str
    classified_as: str
    confidence: float
    corrected_to: Optional[str]
    correction_confidence: float
    timestamp: str  # ISO-8601
    source: str  # "semantic" | "keyword" | "user" | "learned" | "unknown"

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization."""
        return {
            "id": self.id,
            "description": self.description,
            "description_hash": self.description_hash,
            "classified_as": self.classified_as,
            "confidence": self.confidence,
            "corrected_to": self.corrected_to,
            "correction_confidence": self.correction_confidence,
            "timestamp": self.timestamp,
            "source": self.source
        }

    @classmethod
    def from_dict(cls, data: dict) -> "ClassificationEntry":
        """
        Create from dictionary.

        Handles missing keys with sensible defaults.
        """
        return cls(
            id=data.get("id", ""),
            description=data.get("description", ""),
            description_hash=data.get("description_hash", ""),
            classified_as=data.get("classified_as", ""),
            confidence=data.get("confidence", 0.0),
            corrected_to=data.get("corrected_to"),  # None is valid
            correction_confidence=data.get("correction_confidence", 0.0),
            timestamp=data.get("timestamp", ""),
            source=data.get("source", "unknown")
        )


@dataclass
class ImplementationAttempt:
    """
    A single attempt to implement a step.

    Records the technique used, timing, and outcome for
    learning which approaches work best.
    """
    attempt_number: int
    technique: str
    method: str  # Specific approach within the technique
    started_at: str  # ISO-8601
    ended_at: str  # ISO-8601
    duration_seconds: int
    error_summary: Optional[str]
    success: bool

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization."""
        return {
            "attempt_number": self.attempt_number,
            "technique": self.technique,
            "method": self.method,
            "started_at": self.started_at,
            "ended_at": self.ended_at,
            "duration_seconds": self.duration_seconds,
            "error_summary": self.error_summary,
            "success": self.success
        }

    @classmethod
    def from_dict(cls, data: dict) -> "ImplementationAttempt":
        """
        Create from dictionary.

        Handles missing keys with sensible defaults.
        """
        return cls(
            attempt_number=data.get("attempt_number", 0),
            technique=data.get("technique", ""),
            method=data.get("method", ""),
            started_at=data.get("started_at", ""),
            ended_at=data.get("ended_at", ""),
            duration_seconds=data.get("duration_seconds", 0),
            error_summary=data.get("error_summary"),  # None is valid
            success=data.get("success", False)
        )


@dataclass
class StepAttempts:
    """
    All attempts for a single plan step.

    Aggregates individual attempts to provide a complete
    history of how a step was completed (or failed).
    """
    plan_id: str
    step_id: int
    problem_type: str
    attempts: List[ImplementationAttempt] = field(default_factory=list)
    total_attempts: int = 0
    final_success: bool = False
    techniques_used: List[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization."""
        return {
            "plan_id": self.plan_id,
            "step_id": self.step_id,
            "problem_type": self.problem_type,
            "attempts": [a.to_dict() for a in self.attempts],
            "total_attempts": self.total_attempts,
            "final_success": self.final_success,
            "techniques_used": self.techniques_used
        }

    @classmethod
    def from_dict(cls, data: dict) -> "StepAttempts":
        """
        Create from dictionary.

        Handles missing keys with sensible defaults.
        """
        attempts_data = data.get("attempts", [])
        attempts = [ImplementationAttempt.from_dict(a) for a in attempts_data]

        return cls(
            plan_id=data.get("plan_id", ""),
            step_id=data.get("step_id", 0),
            problem_type=data.get("problem_type", ""),
            attempts=attempts,
            total_attempts=data.get("total_attempts", 0),
            final_success=data.get("final_success", False),
            techniques_used=data.get("techniques_used", [])
        )


# Convenience aliases for schema compatibility
__all__ = [
    "TechniqueStats",
    "ClassificationEntry",
    "ImplementationAttempt",
    "StepAttempts",
    "generate_description_hash",
]
