"""
Shared utilities for the Intelligent Planning System.

This module provides common utilities for file operations, output formatting,
and plan management.
"""

import json
import os
from pathlib import Path
from typing import Optional, Any


# Default paths
PLANS_DIR = Path(".claude/plans")
SCRIPTS_DIR = Path(".claude/scripts")
COMMANDS_DIR = Path(".claude/commands")
CONFIG_PATH = Path(".claude/technique-config.json")


def find_plan(plan_id: str, base_dir: Optional[Path] = None) -> Optional[Path]:
    """
    Find plan directory by ID prefix.

    Args:
        plan_id: Plan identifier (e.g., "004")
        base_dir: Optional base directory (defaults to PLANS_DIR)

    Returns:
        Path to plan directory or None if not found
    """
    plans_dir = base_dir or PLANS_DIR

    if not plans_dir.exists():
        return None

    # Try exact match first
    for p in plans_dir.iterdir():
        if p.is_dir():
            # Match by prefix (e.g., "004" matches "004-intelligent-planning-system-v2")
            if p.name.startswith(plan_id):
                return p
            # Also check planId in progress.json
            progress_file = p / "progress.json"
            if progress_file.exists():
                try:
                    with open(progress_file) as f:
                        progress = json.load(f)
                        if progress.get("planId") == plan_id:
                            return p
                except (json.JSONDecodeError, IOError):
                    pass

    return None


def load_plan_progress(plan_dir: Path) -> Optional[dict]:
    """
    Load progress.json from plan directory.

    Args:
        plan_dir: Path to the plan directory

    Returns:
        Progress dictionary or None if not found/invalid
    """
    progress_file = plan_dir / "progress.json"
    if not progress_file.exists():
        return None

    try:
        with open(progress_file) as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError):
        return None


def save_plan_progress(plan_dir: Path, progress: dict) -> bool:
    """
    Save progress.json to plan directory.

    Args:
        plan_dir: Path to the plan directory
        progress: Progress dictionary to save

    Returns:
        True if successful, False otherwise
    """
    progress_file = plan_dir / "progress.json"
    try:
        with open(progress_file, 'w') as f:
            json.dump(progress, f, indent=2)
        return True
    except IOError:
        return False


def load_plan_context(plan_dir: Path) -> Optional[str]:
    """
    Load context.md from plan directory.

    Args:
        plan_dir: Path to the plan directory

    Returns:
        Context string or None if not found
    """
    context_file = plan_dir / "context.md"
    if not context_file.exists():
        return None

    try:
        with open(context_file) as f:
            return f.read()
    except IOError:
        return None


def list_all_plans(base_dir: Optional[Path] = None) -> list[dict]:
    """
    List all plans with their status.

    Args:
        base_dir: Optional base directory (defaults to PLANS_DIR)

    Returns:
        List of plan info dictionaries
    """
    plans_dir = base_dir or PLANS_DIR
    if not plans_dir.exists():
        return []

    plans = []
    for p in sorted(plans_dir.iterdir()):
        if p.is_dir() and (p / "progress.json").exists():
            progress = load_plan_progress(p)
            if progress:
                current = progress.get("currentStep", 0)
                total = progress.get("totalSteps", 0)
                completed = sum(
                    1 for s in progress.get("steps", [])
                    if s.get("status") == "completed"
                )
                plans.append({
                    "id": progress.get("planId", p.name[:3]),
                    "name": progress.get("name", p.name),
                    "title": progress.get("title", p.name),
                    "status": progress.get("status", "unknown"),
                    "current_step": current,
                    "total_steps": total,
                    "completed_steps": completed,
                    "progress_pct": (completed / total * 100) if total > 0 else 0,
                    "path": p,
                })

    return plans


def format_box(title: str, content: list[str], width: int = 60) -> str:
    """
    Create a formatted box for output.

    Args:
        title: Box title
        content: List of content lines
        width: Box width

    Returns:
        Formatted box string
    """
    lines = []
    lines.append("=" * width)
    lines.append(f"  {title}")
    lines.append("=" * width)
    for line in content:
        lines.append(f"  {line}")
    lines.append("=" * width)
    return "\n".join(lines)


def format_progress_bar(completed: int, total: int, width: int = 30) -> str:
    """
    Create a text progress bar.

    Args:
        completed: Number of completed items
        total: Total number of items
        width: Bar width in characters

    Returns:
        Progress bar string (e.g., "████████░░░░░░░░░░░░░░░░░░░░░░")
    """
    if total == 0:
        return "░" * width

    filled = int(width * completed / total)
    empty = width - filled
    return "█" * filled + "░" * empty


def format_risk_level(level: str) -> str:
    """
    Format risk level with visual indicator.

    Args:
        level: Risk level string

    Returns:
        Formatted risk level
    """
    indicators = {
        "low": "🟢 LOW",
        "medium": "🟡 MEDIUM",
        "high": "🟠 HIGH",
        "critical": "🔴 CRITICAL",
    }
    return indicators.get(level.lower(), level.upper())


def format_status(status: str) -> str:
    """
    Format status with visual indicator.

    Args:
        status: Status string

    Returns:
        Formatted status
    """
    indicators = {
        "completed": "✅",
        "in_progress": "🔄",
        "pending": "⏳",
        "blocked": "🚫",
        "failed": "❌",
    }
    indicator = indicators.get(status.lower(), "")
    return f"{indicator} {status.upper()}"


def get_step_by_number(progress: dict, step_num: int) -> Optional[dict]:
    """
    Get a step by its number (1-based).

    Args:
        progress: Progress dictionary
        step_num: Step number (1-based)

    Returns:
        Step dictionary or None if not found
    """
    steps = progress.get("steps", [])
    if 0 < step_num <= len(steps):
        return steps[step_num - 1]
    return None


def get_current_step(progress: dict) -> Optional[dict]:
    """
    Get the current step from progress.

    Args:
        progress: Progress dictionary

    Returns:
        Current step dictionary or None
    """
    current = progress.get("currentStep", 0)
    return get_step_by_number(progress, current)


def ensure_directory(path: Path) -> bool:
    """
    Ensure a directory exists, creating it if necessary.

    Args:
        path: Directory path

    Returns:
        True if directory exists or was created
    """
    try:
        path.mkdir(parents=True, exist_ok=True)
        return True
    except OSError:
        return False


def read_json_file(path: Path) -> Optional[Any]:
    """
    Read and parse a JSON file.

    Args:
        path: Path to JSON file

    Returns:
        Parsed JSON data or None if error
    """
    if not path.exists():
        return None
    try:
        with open(path) as f:
            return json.load(f)
    except (json.JSONDecodeError, IOError):
        return None


def write_json_file(path: Path, data: Any, indent: int = 2) -> bool:
    """
    Write data to a JSON file.

    Args:
        path: Path to JSON file
        data: Data to write
        indent: Indentation level

    Returns:
        True if successful
    """
    try:
        with open(path, 'w') as f:
            json.dump(data, f, indent=indent)
        return True
    except IOError:
        return False
