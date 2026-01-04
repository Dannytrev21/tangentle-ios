#!/usr/bin/env python3
"""
Memory Bank for the Self-Correction Engine.

This module provides persistent storage for lessons learned from failures,
enabling the Reflexion pattern to accumulate wisdom across retry attempts.

Uses standard library only - no pip dependencies.
"""

from dataclasses import dataclass, asdict, field
from datetime import datetime
from pathlib import Path
from typing import List, Optional
import json


@dataclass
class MemoryBankEntry:
    """A single lesson learned from a failure."""
    timestamp: str
    stepId: int
    failureType: str
    context: str
    lesson: str
    techniqueUsed: str
    resolution: str = ""

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization."""
        return asdict(self)

    @classmethod
    def from_dict(cls, data: dict) -> "MemoryBankEntry":
        """Create from dictionary."""
        return cls(
            timestamp=data.get("timestamp", ""),
            stepId=data.get("stepId", 0),
            failureType=data.get("failureType", ""),
            context=data.get("context", ""),
            lesson=data.get("lesson", ""),
            techniqueUsed=data.get("techniqueUsed", ""),
            resolution=data.get("resolution", "")
        )


class MemoryBank:
    """
    Stores lessons learned from failures for use in subsequent attempts.

    Implements FIFO eviction when max entries is exceeded, keeping the most
    recent lessons available for the Reflexion pattern.

    Storage: .windsurf/plans/{NNN}-{slug}/memory-bank.json
    """

    MAX_ENTRIES = 10

    def __init__(self, plan_dir: str):
        """
        Initialize the memory bank for a plan.

        Args:
            plan_dir: Path to the plan directory
        """
        self.plan_dir = Path(plan_dir)
        self.file_path = self.plan_dir / "memory-bank.json"
        self._ensure_file()

    def _ensure_file(self) -> None:
        """Create the memory bank file if it doesn't exist."""
        if not self.file_path.exists():
            self._save({
                "maxEntries": self.MAX_ENTRIES,
                "entries": []
            })

    def _load(self) -> dict:
        """Load the memory bank from disk."""
        try:
            with open(self.file_path, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, FileNotFoundError):
            return {"maxEntries": self.MAX_ENTRIES, "entries": []}

    def _save(self, data: dict) -> None:
        """Save the memory bank to disk."""
        self.file_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.file_path, 'w') as f:
            json.dump(data, f, indent=2)

    def add_entry(self, entry: MemoryBankEntry) -> None:
        """
        Add a new lesson to the memory bank.

        Implements FIFO eviction - oldest entries are removed when
        the bank exceeds MAX_ENTRIES.

        Args:
            entry: The lesson to add
        """
        data = self._load()
        data["entries"].append(entry.to_dict())

        # FIFO: remove oldest entries if over max
        while len(data["entries"]) > self.MAX_ENTRIES:
            data["entries"].pop(0)

        self._save(data)

    def get_entries(self, limit: int = 5) -> List[MemoryBankEntry]:
        """
        Get the most recent entries.

        Args:
            limit: Maximum number of entries to return

        Returns:
            List of most recent entries
        """
        data = self._load()
        entries = data["entries"][-limit:]
        return [MemoryBankEntry.from_dict(e) for e in entries]

    def get_by_step(self, step_id: int) -> List[MemoryBankEntry]:
        """
        Get entries for a specific step.

        Args:
            step_id: The step ID to filter by

        Returns:
            List of entries for this step
        """
        data = self._load()
        return [
            MemoryBankEntry.from_dict(e)
            for e in data["entries"]
            if e.get("stepId") == step_id
        ]

    def get_lessons_for_failure(self, failure_type: str) -> List[str]:
        """
        Get lessons matching a failure type.

        Args:
            failure_type: The failure type to match

        Returns:
            List of lesson strings
        """
        data = self._load()
        lessons = []
        for entry in data["entries"]:
            if entry.get("failureType") == failure_type and entry.get("lesson"):
                lessons.append(entry["lesson"])
        return lessons

    def get_all_lessons(self) -> List[str]:
        """Get all lessons regardless of type."""
        data = self._load()
        return [e.get("lesson", "") for e in data["entries"] if e.get("lesson")]

    def update_last_resolution(self, lesson: str, resolution: str) -> bool:
        """
        Update the last entry with resolution information.

        Args:
            lesson: What was learned
            resolution: How it was resolved

        Returns:
            True if an entry was updated, False if no entries exist
        """
        data = self._load()
        if not data["entries"]:
            return False

        data["entries"][-1]["lesson"] = lesson
        data["entries"][-1]["resolution"] = resolution
        self._save(data)
        return True

    def to_prompt_context(self, max_entries: int = 5) -> str:
        """
        Format memory bank contents for inclusion in a prompt.

        Args:
            max_entries: Maximum number of entries to include

        Returns:
            Formatted string for prompt injection
        """
        entries = self.get_entries(max_entries)

        if not entries:
            return "No previous lessons recorded."

        lines = ["## Memory Bank - Lessons from Previous Attempts\n"]

        for i, entry in enumerate(entries, 1):
            lines.append(f"### Lesson {i}")
            lines.append(f"- **Failure**: {entry.failureType}")
            lines.append(f"- **Context**: {entry.context}")
            lines.append(f"- **Lesson**: {entry.lesson}")
            lines.append(f"- **Technique**: {entry.techniqueUsed}")
            if entry.resolution:
                lines.append(f"- **Resolution**: {entry.resolution}")
            lines.append("")

        return "\n".join(lines)

    def clear(self) -> None:
        """Clear all entries from the memory bank."""
        self._save({
            "maxEntries": self.MAX_ENTRIES,
            "entries": []
        })

    def __len__(self) -> int:
        """Return the number of entries in the memory bank."""
        data = self._load()
        return len(data["entries"])

    def __bool__(self) -> bool:
        """Return True if the memory bank has any entries."""
        return len(self) > 0


def create_entry(
    step_id: int,
    failure_type: str,
    context: str,
    technique: str,
    lesson: str = "",
    resolution: str = ""
) -> MemoryBankEntry:
    """
    Create a memory bank entry with current timestamp.

    Args:
        step_id: The step this failure occurred on
        failure_type: Category of failure (test_failure, logic_error, etc.)
        context: What was attempted
        technique: Which technique was being used
        lesson: What was learned (can be empty initially)
        resolution: How it was resolved (can be empty initially)

    Returns:
        New MemoryBankEntry with current timestamp
    """
    return MemoryBankEntry(
        timestamp=datetime.now().isoformat(),
        stepId=step_id,
        failureType=failure_type,
        context=context,
        lesson=lesson,
        techniqueUsed=technique,
        resolution=resolution
    )


# CLI entry point for testing
if __name__ == '__main__':
    import sys

    if len(sys.argv) < 3:
        print("Usage: python memory_bank.py <plan_dir> <command> [args]")
        print("Commands:")
        print("  list                       List all entries")
        print("  add <step> <type> <ctx>    Add an entry")
        print("  clear                      Clear all entries")
        sys.exit(1)

    plan_dir = sys.argv[1]
    command = sys.argv[2]
    bank = MemoryBank(plan_dir)

    if command == "list":
        entries = bank.get_entries(10)
        if not entries:
            print("No entries in memory bank")
        else:
            for i, e in enumerate(entries, 1):
                print(f"{i}. [{e.failureType}] Step {e.stepId}: {e.context[:50]}...")
                if e.lesson:
                    print(f"   Lesson: {e.lesson}")

    elif command == "add" and len(sys.argv) >= 6:
        step_id = int(sys.argv[3])
        failure_type = sys.argv[4]
        context = sys.argv[5]
        entry = create_entry(step_id, failure_type, context, "manual")
        bank.add_entry(entry)
        print(f"Added entry for step {step_id}")

    elif command == "clear":
        bank.clear()
        print("Memory bank cleared")

    else:
        print("Invalid command or missing arguments")
        sys.exit(1)
