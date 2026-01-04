#!/usr/bin/env python3
"""
File tracking for commit staging.

This module provides safe file tracking and staging commands,
ensuring .windsurf/** is NEVER staged.

CRITICAL: The exclusion patterns in this file protect sensitive planning
files from being accidentally committed. Do not modify without review.
"""

import os
import re
import json
import hashlib
from pathlib import Path
from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional


# CRITICAL: These files must NEVER be staged
# Order matters for performance - most common exclusions first
EXCLUDED_PATTERNS = [
    r'^\.windsurf/',      # Planning system - MOST IMPORTANT
    r'^\.git/',           # Git internals
    r'__pycache__',       # Python bytecode directories
    r'\.pyc$',            # Python compiled files
    r'\.env$',            # Environment files (exact or ending with .env)
    r'\.secret$',         # Secret files
    r'\.log$',            # Log files
]


@dataclass
class FileOperation:
    """Represents a file operation."""
    path: str
    operation: str  # 'created', 'modified', 'deleted', 'renamed'
    old_path: Optional[str] = None  # For renames


@dataclass
class FileState:
    """State of a file at a point in time."""
    path: str
    exists: bool
    mtime: float = 0
    hash: str = ""


class FileTracker:
    """
    Track file operations during step execution.

    This class provides safe file tracking with built-in exclusion
    patterns to prevent .windsurf/** from ever being staged.

    Usage:
        tracker = FileTracker(repo_root='.')
        tracker.start_tracking()
        # ... execute step ...
        operations = tracker.get_operations()
        commands = tracker.get_staging_commands(operations)
    """

    def __init__(self, repo_root: str = '.'):
        """
        Initialize the file tracker.

        Args:
            repo_root: Root directory of the repository to track
        """
        self.repo_root = Path(repo_root).resolve()
        self.initial_state: Dict[str, FileState] = {}
        self.excluded_patterns = [re.compile(p) for p in EXCLUDED_PATTERNS]

    def _is_excluded(self, path: str) -> bool:
        """
        Check if path matches any exclusion pattern.

        Args:
            path: Relative file path to check

        Returns:
            True if the path should be excluded from staging
        """
        for pattern in self.excluded_patterns:
            if pattern.search(path):
                return True
        return False

    def _hash_file(self, path: Path) -> str:
        """
        Calculate MD5 hash of file contents.

        Args:
            path: Full path to the file

        Returns:
            MD5 hex digest or empty string on error
        """
        try:
            with open(path, 'rb') as f:
                return hashlib.md5(f.read()).hexdigest()
        except (IOError, OSError):
            return ""

    def _snapshot(self) -> Dict[str, FileState]:
        """
        Capture current state of tracked files.

        Excludes files matching EXCLUDED_PATTERNS.

        Returns:
            Dictionary mapping relative paths to FileState objects
        """
        state = {}
        for path in self.repo_root.rglob('*'):
            if path.is_file():
                try:
                    rel_path = str(path.relative_to(self.repo_root))
                    if not self._is_excluded(rel_path):
                        state[rel_path] = FileState(
                            path=rel_path,
                            exists=True,
                            mtime=path.stat().st_mtime,
                            hash=self._hash_file(path)
                        )
                except ValueError:
                    # path.relative_to failed - skip this file
                    pass
        return state

    def start_tracking(self) -> None:
        """
        Capture initial file state before step execution.

        Call this method before performing any file operations
        to establish a baseline for change detection.
        """
        self.initial_state = self._snapshot()

    def get_operations(self) -> Dict[str, List]:
        """
        Detect file operations since tracking started.

        Returns:
            Dictionary with keys 'created', 'modified', 'deleted', 'renamed'
            containing lists of affected file paths.

        Example:
            {
                'created': ['path/to/new.py', ...],
                'modified': ['path/to/changed.py', ...],
                'deleted': ['path/to/removed.py', ...],
                'renamed': [{'from': 'old.py', 'to': 'new.py'}, ...]
            }
        """
        current_state = self._snapshot()

        operations = {
            'created': [],
            'modified': [],
            'deleted': [],
            'renamed': []
        }

        # Find created and modified files
        for path, state in current_state.items():
            if path not in self.initial_state:
                operations['created'].append(path)
            elif state.hash != self.initial_state[path].hash:
                operations['modified'].append(path)

        # Find deleted files
        for path in self.initial_state:
            if path not in current_state:
                operations['deleted'].append(path)

        # Detect potential renames by matching hashes of deleted/created
        # Only if we have both deleted and created files
        if operations['deleted'] and operations['created']:
            deleted_hashes = {
                self.initial_state[p].hash: p
                for p in operations['deleted']
                if self.initial_state[p].hash
            }

            for new_path in list(operations['created']):
                new_hash = current_state[new_path].hash
                if new_hash and new_hash in deleted_hashes:
                    old_path = deleted_hashes[new_hash]
                    operations['renamed'].append({
                        'from': old_path,
                        'to': new_path
                    })
                    operations['created'].remove(new_path)
                    operations['deleted'].remove(old_path)
                    del deleted_hashes[new_hash]

        return operations

    def validate_files(self, files: List[str]) -> Tuple[List[str], List[str]]:
        """
        Validate files against exclusion patterns.

        CRITICAL: This method is the primary safety mechanism to prevent
        .windsurf/** files from being staged.

        Args:
            files: List of file paths to validate

        Returns:
            Tuple of (allowed, rejected) file path lists
        """
        allowed = []
        rejected = []

        for f in files:
            if self._is_excluded(f):
                rejected.append(f)
            else:
                allowed.append(f)

        return allowed, rejected

    def get_staging_commands(self, operations: Dict[str, List]) -> List[str]:
        """
        Generate git staging commands for operations.

        CRITICAL: All files are validated before staging - .windsurf/**
        will be rejected and a warning printed.

        Args:
            operations: Dictionary from get_operations()

        Returns:
            List of git commands to execute
        """
        commands = []

        # Stage created and modified files
        to_add = operations.get('created', []) + operations.get('modified', [])
        allowed, rejected = self.validate_files(to_add)

        if rejected:
            print(f"WARNING: Excluded from staging: {rejected}")

        if allowed:
            # Use separate git add for each file to handle special characters
            commands.append(f"git add {' '.join(allowed)}")

        # Handle deletions
        for f in operations.get('deleted', []):
            allowed_del, _ = self.validate_files([f])
            if allowed_del:
                commands.append(f"git rm {f}")

        # Handle renames
        for rename in operations.get('renamed', []):
            from_path = rename.get('from', '')
            to_path = rename.get('to', '')
            # Validate both paths
            allowed_from, _ = self.validate_files([from_path])
            allowed_to, _ = self.validate_files([to_path])
            if allowed_from and allowed_to:
                commands.append(f"git mv {from_path} {to_path}")

        return commands


def save_operations_to_progress(
    plan_path: str,
    step_id: int,
    operations: Dict[str, List]
) -> None:
    """
    Save file operations to progress.json for a step.

    Args:
        plan_path: Path to the plan directory
        step_id: The step ID to update
        operations: Dictionary of file operations
    """
    progress_file = Path(plan_path) / 'progress.json'

    try:
        with open(progress_file, 'r') as f:
            progress = json.load(f)
    except (IOError, json.JSONDecodeError):
        return

    # Find step and update files
    for step in progress.get('steps', []):
        if step.get('id') == step_id:
            step['files'] = {
                'created': operations.get('created', []),
                'modified': operations.get('modified', []),
                'deleted': operations.get('deleted', []),
                'renamed': operations.get('renamed', [])
            }
            break

    try:
        with open(progress_file, 'w') as f:
            json.dump(progress, f, indent=2)
    except IOError:
        pass


def load_operations_from_progress(plan_path: str, step_id: int) -> Dict[str, List]:
    """
    Load file operations from progress.json for a step.

    Args:
        plan_path: Path to the plan directory
        step_id: The step ID to load

    Returns:
        Dictionary of file operations or empty dict on error
    """
    progress_file = Path(plan_path) / 'progress.json'

    try:
        with open(progress_file, 'r') as f:
            progress = json.load(f)
    except (IOError, json.JSONDecodeError):
        return {'created': [], 'modified': [], 'deleted': [], 'renamed': []}

    for step in progress.get('steps', []):
        if step.get('id') == step_id:
            return step.get('files', {
                'created': [],
                'modified': [],
                'deleted': [],
                'renamed': []
            })

    return {'created': [], 'modified': [], 'deleted': [], 'renamed': []}


# CLI usage helper
def get_staging_commands_for_step(plan_path: str, step_id: int) -> List[str]:
    """
    Get staging commands for a specific step.

    Args:
        plan_path: Path to the plan directory
        step_id: The step ID

    Returns:
        List of git commands to execute
    """
    operations = load_operations_from_progress(plan_path, step_id)
    tracker = FileTracker()
    return tracker.get_staging_commands(operations)
