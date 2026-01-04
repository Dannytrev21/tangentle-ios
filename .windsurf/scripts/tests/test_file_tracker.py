#!/usr/bin/env python3
"""
Unit tests for file_tracker.py.

Tests file tracking and commit staging with emphasis on .windsurf exclusion.
"""

import unittest
import tempfile
import os
import json
import time
from pathlib import Path

# Add the scripts directory to the path for imports
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))

from file_tracker import FileTracker, FileOperation, FileState, save_operations_to_progress


class TestExclusionPatterns(unittest.TestCase):
    """Tests for file exclusion patterns."""

    def setUp(self):
        self.tracker = FileTracker()

    def test_excludes_windsurf_files(self):
        """CRITICAL: .windsurf/** must NEVER be staged."""
        allowed, rejected = self.tracker.validate_files([
            '.windsurf/plans/001/plan.md',
            '.windsurf/scripts/utils.py',
            '.windsurf/workflows/plan-next.md',
            'src/main.py'
        ])
        self.assertEqual(allowed, ['src/main.py'])
        self.assertEqual(len(rejected), 3)
        self.assertIn('.windsurf/plans/001/plan.md', rejected)
        self.assertIn('.windsurf/scripts/utils.py', rejected)
        self.assertIn('.windsurf/workflows/plan-next.md', rejected)

    def test_excludes_git_directory(self):
        """.git/** must never be staged."""
        allowed, rejected = self.tracker.validate_files([
            '.git/config',
            '.git/hooks/pre-commit',
            'src/main.py'
        ])
        self.assertEqual(allowed, ['src/main.py'])
        self.assertIn('.git/config', rejected)

    def test_excludes_pycache(self):
        """__pycache__ directories must be excluded."""
        allowed, rejected = self.tracker.validate_files([
            'src/__pycache__/utils.cpython-312.pyc',
            'tests/__pycache__/test_utils.cpython-312.pyc',
            'src/main.py'
        ])
        self.assertEqual(allowed, ['src/main.py'])
        self.assertEqual(len(rejected), 2)

    def test_excludes_pyc_files(self):
        """*.pyc files must be excluded."""
        allowed, rejected = self.tracker.validate_files([
            'utils.pyc',
            'src/service.pyc',
            'src/main.py'
        ])
        self.assertEqual(allowed, ['src/main.py'])
        self.assertEqual(len(rejected), 2)

    def test_excludes_env_files(self):
        """.env files must be excluded."""
        allowed, rejected = self.tracker.validate_files([
            '.env',
            'config.env',  # This should NOT be excluded (not exactly .env)
            'src/main.py'
        ])
        self.assertIn('src/main.py', allowed)
        self.assertIn('.env', rejected)
        # config.env doesn't match the pattern \.env$ since it needs to end with .env
        # Actually config.env DOES end with .env, so it should be rejected
        self.assertIn('config.env', rejected)

    def test_excludes_secret_files(self):
        """.secret files must be excluded."""
        allowed, rejected = self.tracker.validate_files([
            'api.secret',
            'credentials.secret',
            'src/main.py'
        ])
        self.assertEqual(allowed, ['src/main.py'])
        self.assertEqual(len(rejected), 2)

    def test_excludes_log_files(self):
        """*.log files must be excluded."""
        allowed, rejected = self.tracker.validate_files([
            'debug.log',
            'logs/app.log',
            'src/main.py'
        ])
        self.assertEqual(allowed, ['src/main.py'])
        self.assertEqual(len(rejected), 2)

    def test_allows_source_files(self):
        """Regular source files should be allowed."""
        allowed, rejected = self.tracker.validate_files([
            'src/service.py',
            'src/models/user.py',
            'Tests/UnitTests/TaskTests.swift',
            'Tangentle/Core/Services/TaskService.swift'
        ])
        self.assertEqual(len(allowed), 4)
        self.assertEqual(rejected, [])

    def test_allows_test_files(self):
        """Test files should be allowed (not .windsurf tests)."""
        allowed, rejected = self.tracker.validate_files([
            'Tests/TaskTests.swift',
            'TangentleTests/ServiceTests.swift',
            'tests/test_utils.py'
        ])
        self.assertEqual(len(allowed), 3)
        self.assertEqual(rejected, [])


class TestStagingCommands(unittest.TestCase):
    """Tests for staging command generation."""

    def setUp(self):
        self.tracker = FileTracker()

    def test_staging_commands_for_created_files(self):
        """Created files should use git add."""
        operations = {
            'created': ['src/new.py', 'src/feature/handler.py'],
            'modified': [],
            'deleted': [],
            'renamed': []
        }
        commands = self.tracker.get_staging_commands(operations)
        self.assertEqual(len(commands), 1)
        self.assertIn('git add', commands[0])
        self.assertIn('src/new.py', commands[0])
        self.assertIn('src/feature/handler.py', commands[0])

    def test_staging_commands_for_modified_files(self):
        """Modified files should use git add."""
        operations = {
            'created': [],
            'modified': ['src/existing.py'],
            'deleted': [],
            'renamed': []
        }
        commands = self.tracker.get_staging_commands(operations)
        self.assertEqual(len(commands), 1)
        self.assertIn('git add', commands[0])
        self.assertIn('src/existing.py', commands[0])

    def test_staging_commands_for_deleted_files(self):
        """Deleted files should use git rm."""
        operations = {
            'created': [],
            'modified': [],
            'deleted': ['src/old.py'],
            'renamed': []
        }
        commands = self.tracker.get_staging_commands(operations)
        self.assertEqual(len(commands), 1)
        self.assertIn('git rm', commands[0])
        self.assertIn('src/old.py', commands[0])

    def test_windsurf_never_in_staging(self):
        """CRITICAL: .windsurf files must NEVER appear in staging commands."""
        operations = {
            'created': ['.windsurf/test.md', 'src/main.py'],
            'modified': ['.windsurf/progress.json'],
            'deleted': ['.windsurf/old.md'],
            'renamed': []
        }
        commands = self.tracker.get_staging_commands(operations)
        for cmd in commands:
            self.assertNotIn('.windsurf', cmd)

    def test_git_never_in_staging(self):
        """.git files must never appear in staging commands."""
        operations = {
            'created': ['.git/test', 'src/main.py'],
            'modified': [],
            'deleted': [],
            'renamed': []
        }
        commands = self.tracker.get_staging_commands(operations)
        for cmd in commands:
            self.assertNotIn('.git/', cmd)

    def test_empty_operations_no_commands(self):
        """Empty operations should produce no commands."""
        operations = {
            'created': [],
            'modified': [],
            'deleted': [],
            'renamed': []
        }
        commands = self.tracker.get_staging_commands(operations)
        self.assertEqual(commands, [])

    def test_mixed_operations(self):
        """Mixed operations should produce correct commands."""
        operations = {
            'created': ['src/new.py'],
            'modified': ['src/existing.py'],
            'deleted': ['src/old.py'],
            'renamed': []
        }
        commands = self.tracker.get_staging_commands(operations)
        # Should have git add for created+modified, git rm for deleted
        add_cmd = next((c for c in commands if 'git add' in c), None)
        rm_cmd = next((c for c in commands if 'git rm' in c), None)
        self.assertIsNotNone(add_cmd)
        self.assertIsNotNone(rm_cmd)
        self.assertIn('src/new.py', add_cmd)
        self.assertIn('src/existing.py', add_cmd)
        self.assertIn('src/old.py', rm_cmd)


class TestFileTracking(unittest.TestCase):
    """Tests for file tracking during execution."""

    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.tracker = FileTracker(repo_root=self.temp_dir)
        # Create initial file
        self.initial_file = Path(self.temp_dir) / "existing.txt"
        self.initial_file.write_text("initial content")

    def tearDown(self):
        import shutil
        shutil.rmtree(self.temp_dir)

    def test_detects_created_files(self):
        """Should detect newly created files."""
        self.tracker.start_tracking()

        # Create a new file
        new_file = Path(self.temp_dir) / "new.txt"
        new_file.write_text("new content")

        operations = self.tracker.get_operations()
        self.assertIn("new.txt", operations['created'])

    def test_detects_modified_files(self):
        """Should detect modified files based on content hash."""
        self.tracker.start_tracking()
        time.sleep(0.1)  # Ensure different mtime

        # Modify existing file
        self.initial_file.write_text("modified content")

        operations = self.tracker.get_operations()
        self.assertIn("existing.txt", operations['modified'])

    def test_detects_deleted_files(self):
        """Should detect deleted files."""
        self.tracker.start_tracking()

        # Delete existing file
        self.initial_file.unlink()

        operations = self.tracker.get_operations()
        self.assertIn("existing.txt", operations['deleted'])

    def test_ignores_windsurf_in_tracking(self):
        """Should not track .windsurf files."""
        # Create .windsurf directory
        windsurf_dir = Path(self.temp_dir) / ".windsurf"
        windsurf_dir.mkdir()
        (windsurf_dir / "plan.md").write_text("plan content")

        self.tracker.start_tracking()

        # Create more .windsurf files
        (windsurf_dir / "progress.json").write_text("{}")

        operations = self.tracker.get_operations()
        # Should not contain .windsurf files
        all_files = (
            operations['created'] +
            operations['modified'] +
            operations['deleted']
        )
        for f in all_files:
            self.assertNotIn('.windsurf', f)

    def test_no_changes_returns_empty(self):
        """Should return empty operations when nothing changes."""
        self.tracker.start_tracking()
        operations = self.tracker.get_operations()
        self.assertEqual(operations['created'], [])
        self.assertEqual(operations['modified'], [])
        self.assertEqual(operations['deleted'], [])


class TestProgressIntegration(unittest.TestCase):
    """Tests for progress.json integration."""

    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.plan_dir = Path(self.temp_dir) / "plans" / "001-test"
        self.plan_dir.mkdir(parents=True)

        # Create minimal progress.json
        self.progress_file = self.plan_dir / "progress.json"
        self.progress_file.write_text(json.dumps({
            "planId": "001",
            "steps": [
                {"id": 1, "name": "test-step", "files": {}}
            ]
        }))

    def tearDown(self):
        import shutil
        shutil.rmtree(self.temp_dir)

    def test_saves_operations_to_progress(self):
        """Should save file operations to progress.json."""
        operations = {
            'created': ['src/new.py'],
            'modified': ['src/existing.py'],
            'deleted': ['src/old.py'],
            'renamed': []
        }

        save_operations_to_progress(str(self.plan_dir), 1, operations)

        # Read back progress
        with open(self.progress_file) as f:
            progress = json.load(f)

        step = progress['steps'][0]
        self.assertEqual(step['files']['created'], ['src/new.py'])
        self.assertEqual(step['files']['modified'], ['src/existing.py'])
        self.assertEqual(step['files']['deleted'], ['src/old.py'])

    def test_handles_missing_step(self):
        """Should handle gracefully when step doesn't exist."""
        operations = {'created': [], 'modified': [], 'deleted': [], 'renamed': []}
        # This should not raise - step 99 doesn't exist
        save_operations_to_progress(str(self.plan_dir), 99, operations)


class TestFileState(unittest.TestCase):
    """Tests for FileState dataclass."""

    def test_file_state_creation(self):
        """Should create FileState with correct values."""
        state = FileState(
            path="src/main.py",
            exists=True,
            mtime=12345.0,
            hash="abc123"
        )
        self.assertEqual(state.path, "src/main.py")
        self.assertTrue(state.exists)
        self.assertEqual(state.mtime, 12345.0)
        self.assertEqual(state.hash, "abc123")


class TestFileOperation(unittest.TestCase):
    """Tests for FileOperation dataclass."""

    def test_file_operation_creation(self):
        """Should create FileOperation with correct values."""
        op = FileOperation(
            path="src/main.py",
            operation="created"
        )
        self.assertEqual(op.path, "src/main.py")
        self.assertEqual(op.operation, "created")
        self.assertIsNone(op.old_path)

    def test_file_operation_rename(self):
        """Should handle rename operations with old_path."""
        op = FileOperation(
            path="src/new_name.py",
            operation="renamed",
            old_path="src/old_name.py"
        )
        self.assertEqual(op.path, "src/new_name.py")
        self.assertEqual(op.old_path, "src/old_name.py")


class TestEdgeCases(unittest.TestCase):
    """Tests for edge cases and boundary conditions."""

    def setUp(self):
        self.tracker = FileTracker()

    def test_empty_file_list(self):
        """Should handle empty file list."""
        allowed, rejected = self.tracker.validate_files([])
        self.assertEqual(allowed, [])
        self.assertEqual(rejected, [])

    def test_all_files_excluded(self):
        """Should handle when all files are excluded."""
        allowed, rejected = self.tracker.validate_files([
            '.windsurf/plan.md',
            '.git/config',
            'debug.log'
        ])
        self.assertEqual(allowed, [])
        self.assertEqual(len(rejected), 3)

    def test_special_characters_in_paths(self):
        """Should handle paths with special characters."""
        allowed, rejected = self.tracker.validate_files([
            'src/feature (new)/handler.py',
            "src/service's_file.py",
            'src/日本語.py'
        ])
        self.assertEqual(len(allowed), 3)

    def test_deeply_nested_windsurf(self):
        """Should exclude deeply nested .windsurf files."""
        allowed, rejected = self.tracker.validate_files([
            '.windsurf/plans/001-feature/steps/01-setup.md',
            '.windsurf/memory-bank/lessons.json'
        ])
        self.assertEqual(allowed, [])
        self.assertEqual(len(rejected), 2)


if __name__ == '__main__':
    unittest.main(verbosity=2)
