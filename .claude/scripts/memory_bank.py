"""
Memory Bank for the Self-Correction Engine.

This module provides persistent storage for lessons learned from failures,
enabling the Reflexion pattern to accumulate wisdom across retry attempts.
"""

from dataclasses import dataclass, field
from datetime import datetime
from typing import Optional
import json


@dataclass
class MemoryBankEntry:
    """A single lesson learned from a failure."""
    timestamp: str
    failure_summary: str
    root_cause: str
    lesson_learned: str
    technique_used: str
    applicable_to: list[str] = field(default_factory=list)

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization."""
        return {
            "timestamp": self.timestamp,
            "failure_summary": self.failure_summary,
            "root_cause": self.root_cause,
            "lesson_learned": self.lesson_learned,
            "technique_used": self.technique_used,
            "applicable_to": self.applicable_to
        }

    @classmethod
    def from_dict(cls, data: dict) -> "MemoryBankEntry":
        """Create from dictionary."""
        return cls(
            timestamp=data.get("timestamp", ""),
            failure_summary=data.get("failure_summary", ""),
            root_cause=data.get("root_cause", ""),
            lesson_learned=data.get("lesson_learned", ""),
            technique_used=data.get("technique_used", ""),
            applicable_to=data.get("applicable_to", [])
        )


class MemoryBank:
    """
    Stores lessons learned from failures for use in subsequent attempts.

    Implements FIFO eviction when max_size is exceeded, keeping the most
    recent lessons available for the Reflexion pattern.
    """

    def __init__(self, max_size: int = 10):
        """
        Initialize the memory bank.

        Args:
            max_size: Maximum number of entries to retain (default 10)
        """
        self.entries: list[MemoryBankEntry] = []
        self.max_size = max_size

    def add_entry(self, entry: MemoryBankEntry) -> None:
        """
        Add a new lesson to the memory bank.

        Args:
            entry: The lesson to add
        """
        self.entries.append(entry)
        # Evict oldest entry if over capacity
        if len(self.entries) > self.max_size:
            self.entries.pop(0)

    def get_relevant_lessons(self, step_type: str) -> list[str]:
        """
        Get lessons relevant to a specific step type.

        Args:
            step_type: The problem type of the current step

        Returns:
            List of lesson strings that apply to this step type
        """
        lessons = []
        for entry in self.entries:
            if step_type in entry.applicable_to or "general" in entry.applicable_to:
                lessons.append(entry.lesson_learned)
        return lessons

    def get_all_lessons(self) -> list[str]:
        """Get all lessons regardless of applicability."""
        return [entry.lesson_learned for entry in self.entries]

    def to_prompt_context(self, max_entries: int = 5) -> str:
        """
        Format memory bank contents for inclusion in a prompt.

        Args:
            max_entries: Maximum number of entries to include (default 5)

        Returns:
            Formatted string for prompt injection
        """
        if not self.entries:
            return "No previous lessons recorded."

        lines = ["## Memory Bank - Lessons from Previous Attempts\n"]
        # Take the most recent entries
        recent_entries = self.entries[-max_entries:]

        for i, entry in enumerate(recent_entries, 1):
            lines.append(f"### Lesson {i}")
            lines.append(f"- **Failure**: {entry.failure_summary}")
            lines.append(f"- **Root Cause**: {entry.root_cause}")
            lines.append(f"- **Lesson**: {entry.lesson_learned}")
            lines.append(f"- **Technique**: {entry.technique_used}")
            lines.append("")

        return "\n".join(lines)

    def to_json(self) -> dict:
        """
        Serialize memory bank to JSON-compatible dict.

        Returns:
            Dictionary representation for JSON serialization
        """
        return {
            "max_size": self.max_size,
            "entries": [e.to_dict() for e in self.entries]
        }

    @classmethod
    def from_json(cls, data: dict) -> "MemoryBank":
        """
        Deserialize memory bank from JSON dict.

        Args:
            data: Dictionary from JSON deserialization

        Returns:
            New MemoryBank instance with restored state
        """
        max_size = data.get("max_size", 10)
        bank = cls(max_size=max_size)

        for entry_data in data.get("entries", []):
            bank.add_entry(MemoryBankEntry.from_dict(entry_data))

        return bank

    def clear(self) -> None:
        """Clear all entries from the memory bank."""
        self.entries.clear()

    def __len__(self) -> int:
        """Return the number of entries in the memory bank."""
        return len(self.entries)

    def __bool__(self) -> bool:
        """Return True if the memory bank has any entries."""
        return len(self.entries) > 0


# Convenience function for creating entries from failure analysis
def create_entry_from_failure(
    failure_summary: str,
    root_cause: str,
    lesson: str,
    technique: str,
    applicable_to: Optional[list[str]] = None
) -> MemoryBankEntry:
    """
    Create a memory bank entry with current timestamp.

    Args:
        failure_summary: Brief description of what failed
        root_cause: Why it failed
        lesson: What to do differently
        technique: Which technique was being used
        applicable_to: List of problem types this applies to

    Returns:
        New MemoryBankEntry with current timestamp
    """
    return MemoryBankEntry(
        timestamp=datetime.now().isoformat(),
        failure_summary=failure_summary,
        root_cause=root_cause,
        lesson_learned=lesson,
        technique_used=technique,
        applicable_to=applicable_to or ["general"]
    )
