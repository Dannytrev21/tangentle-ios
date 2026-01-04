#!/usr/bin/env python3
"""
Unit tests for the Memory Bank module.

Tests cover:
- Entry creation and serialization
- FIFO eviction behavior
- Persistence to/from disk
- Query methods (by step, by failure type)
- Prompt context generation
"""

import json
import os
import shutil
import tempfile
import unittest
from pathlib import Path
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from memory_bank import MemoryBank, MemoryBankEntry, create_entry


class TestMemoryBankEntry(unittest.TestCase):
    """Tests for MemoryBankEntry dataclass."""

    def test_create_entry_with_timestamp(self):
        """Entry should have current timestamp when created via helper."""
        entry = create_entry(
            step_id=1,
            failure_type="test_failure",
            context="Test failed",
            technique="tdd"
        )

        self.assertEqual(entry.stepId, 1)
        self.assertEqual(entry.failureType, "test_failure")
        self.assertEqual(entry.context, "Test failed")
        self.assertEqual(entry.techniqueUsed, "tdd")
        self.assertIsNotNone(entry.timestamp)
        self.assertTrue(len(entry.timestamp) > 0)

    def test_entry_to_dict(self):
        """Entry should serialize to dictionary correctly."""
        entry = MemoryBankEntry(
            timestamp="2026-01-02T10:00:00",
            stepId=2,
            failureType="logic_error",
            context="Logic was wrong",
            lesson="Check edge cases",
            techniqueUsed="reflexion",
            resolution="Added nil check"
        )

        d = entry.to_dict()

        self.assertEqual(d["timestamp"], "2026-01-02T10:00:00")
        self.assertEqual(d["stepId"], 2)
        self.assertEqual(d["failureType"], "logic_error")
        self.assertEqual(d["context"], "Logic was wrong")
        self.assertEqual(d["lesson"], "Check edge cases")
        self.assertEqual(d["techniqueUsed"], "reflexion")
        self.assertEqual(d["resolution"], "Added nil check")

    def test_entry_from_dict(self):
        """Entry should deserialize from dictionary correctly."""
        d = {
            "timestamp": "2026-01-02T10:00:00",
            "stepId": 3,
            "failureType": "build_error",
            "context": "Build failed",
            "lesson": "Check imports",
            "techniqueUsed": "ps-plus",
            "resolution": "Fixed import"
        }

        entry = MemoryBankEntry.from_dict(d)

        self.assertEqual(entry.timestamp, "2026-01-02T10:00:00")
        self.assertEqual(entry.stepId, 3)
        self.assertEqual(entry.failureType, "build_error")
        self.assertEqual(entry.context, "Build failed")
        self.assertEqual(entry.lesson, "Check imports")
        self.assertEqual(entry.techniqueUsed, "ps-plus")
        self.assertEqual(entry.resolution, "Fixed import")

    def test_entry_from_dict_with_missing_fields(self):
        """Entry should handle missing fields with defaults."""
        d = {"stepId": 1}

        entry = MemoryBankEntry.from_dict(d)

        self.assertEqual(entry.stepId, 1)
        self.assertEqual(entry.timestamp, "")
        self.assertEqual(entry.failureType, "")
        self.assertEqual(entry.lesson, "")
        self.assertEqual(entry.resolution, "")


class TestMemoryBank(unittest.TestCase):
    """Tests for MemoryBank class."""

    def setUp(self):
        """Create a temporary directory for each test."""
        self.test_dir = tempfile.mkdtemp()
        self.plan_dir = Path(self.test_dir) / "005-test-plan"
        self.plan_dir.mkdir(parents=True)
        self.bank = MemoryBank(str(self.plan_dir))

    def tearDown(self):
        """Clean up temporary directory."""
        shutil.rmtree(self.test_dir, ignore_errors=True)

    def test_init_creates_file(self):
        """Initialization should create the memory bank file."""
        self.assertTrue(self.bank.file_path.exists())

    def test_init_file_structure(self):
        """File should have correct structure."""
        with open(self.bank.file_path, 'r') as f:
            data = json.load(f)

        self.assertEqual(data["maxEntries"], 10)
        self.assertEqual(data["entries"], [])

    def test_add_single_entry(self):
        """Adding an entry should persist it."""
        entry = create_entry(1, "test_failure", "Test failed", "tdd")
        self.bank.add_entry(entry)

        entries = self.bank.get_entries()
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0].stepId, 1)
        self.assertEqual(entries[0].failureType, "test_failure")

    def test_add_multiple_entries(self):
        """Adding multiple entries should preserve order."""
        for i in range(5):
            entry = create_entry(i, f"type_{i}", f"Context {i}", "tdd")
            self.bank.add_entry(entry)

        entries = self.bank.get_entries(10)
        self.assertEqual(len(entries), 5)
        self.assertEqual(entries[0].stepId, 0)
        self.assertEqual(entries[4].stepId, 4)

    def test_fifo_prunes_oldest(self):
        """FIFO should remove oldest entries when exceeding max."""
        # Add 15 entries (max is 10)
        for i in range(15):
            entry = create_entry(i, "test", f"Entry {i}", "tdd")
            self.bank.add_entry(entry)

        entries = self.bank.get_entries(20)

        # Should only have 10 entries
        self.assertEqual(len(entries), 10)

        # Oldest should be entry 5 (entries 0-4 were pruned)
        self.assertEqual(entries[0].stepId, 5)
        self.assertEqual(entries[0].context, "Entry 5")

        # Newest should be entry 14
        self.assertEqual(entries[-1].stepId, 14)
        self.assertEqual(entries[-1].context, "Entry 14")

    def test_get_entries_with_limit(self):
        """get_entries should respect limit parameter."""
        for i in range(5):
            entry = create_entry(i, "test", f"Entry {i}", "tdd")
            self.bank.add_entry(entry)

        entries = self.bank.get_entries(3)
        self.assertEqual(len(entries), 3)

        # Should get the 3 most recent
        self.assertEqual(entries[0].stepId, 2)
        self.assertEqual(entries[2].stepId, 4)

    def test_get_by_step(self):
        """get_by_step should filter by step ID."""
        self.bank.add_entry(create_entry(1, "type_a", "Step 1 first", "tdd"))
        self.bank.add_entry(create_entry(2, "type_b", "Step 2 only", "tdd"))
        self.bank.add_entry(create_entry(1, "type_c", "Step 1 second", "tdd"))
        self.bank.add_entry(create_entry(3, "type_d", "Step 3 only", "tdd"))
        self.bank.add_entry(create_entry(1, "type_e", "Step 1 third", "tdd"))

        step_1_entries = self.bank.get_by_step(1)
        step_2_entries = self.bank.get_by_step(2)
        step_4_entries = self.bank.get_by_step(4)

        self.assertEqual(len(step_1_entries), 3)
        self.assertEqual(len(step_2_entries), 1)
        self.assertEqual(len(step_4_entries), 0)

        self.assertEqual(step_1_entries[0].context, "Step 1 first")
        self.assertEqual(step_1_entries[2].context, "Step 1 third")

    def test_get_lessons_for_failure(self):
        """get_lessons_for_failure should return matching lessons."""
        self.bank.add_entry(create_entry(1, "test_failure", "Test 1", "tdd", "Lesson A"))
        self.bank.add_entry(create_entry(2, "logic_error", "Logic 1", "tdd", "Lesson B"))
        self.bank.add_entry(create_entry(3, "test_failure", "Test 2", "tdd", "Lesson C"))

        lessons = self.bank.get_lessons_for_failure("test_failure")

        self.assertEqual(len(lessons), 2)
        self.assertIn("Lesson A", lessons)
        self.assertIn("Lesson C", lessons)
        self.assertNotIn("Lesson B", lessons)

    def test_get_all_lessons(self):
        """get_all_lessons should return all lessons with content."""
        self.bank.add_entry(create_entry(1, "type_a", "Entry 1", "tdd", "Lesson 1"))
        self.bank.add_entry(create_entry(2, "type_b", "Entry 2", "tdd", "Lesson 2"))
        self.bank.add_entry(create_entry(3, "type_c", "Entry 3", "tdd", ""))  # No lesson

        lessons = self.bank.get_all_lessons()

        self.assertEqual(len(lessons), 2)  # Excludes empty lesson
        self.assertIn("Lesson 1", lessons)
        self.assertIn("Lesson 2", lessons)

    def test_update_last_resolution(self):
        """update_last_resolution should update the most recent entry."""
        self.bank.add_entry(create_entry(1, "test", "Entry 1", "tdd"))
        self.bank.add_entry(create_entry(2, "test", "Entry 2", "tdd"))

        result = self.bank.update_last_resolution("New lesson", "Fixed it")

        self.assertTrue(result)

        entries = self.bank.get_entries(10)
        self.assertEqual(entries[-1].lesson, "New lesson")
        self.assertEqual(entries[-1].resolution, "Fixed it")

        # First entry should be unchanged
        self.assertEqual(entries[0].lesson, "")

    def test_update_last_resolution_empty_bank(self):
        """update_last_resolution should return False if bank is empty."""
        result = self.bank.update_last_resolution("Lesson", "Resolution")
        self.assertFalse(result)

    def test_to_prompt_context_empty(self):
        """to_prompt_context should handle empty bank."""
        context = self.bank.to_prompt_context()
        self.assertEqual(context, "No previous lessons recorded.")

    def test_to_prompt_context_with_entries(self):
        """to_prompt_context should format entries for prompt."""
        self.bank.add_entry(create_entry(1, "test_failure", "Test failed", "tdd", "Check mocks"))
        self.bank.add_entry(create_entry(2, "logic_error", "Logic wrong", "reflexion", "Edge case"))

        context = self.bank.to_prompt_context()

        self.assertIn("Memory Bank", context)
        self.assertIn("Lesson 1", context)
        self.assertIn("Lesson 2", context)
        self.assertIn("test_failure", context)
        self.assertIn("logic_error", context)
        self.assertIn("Check mocks", context)
        self.assertIn("Edge case", context)

    def test_clear(self):
        """clear should remove all entries."""
        for i in range(5):
            self.bank.add_entry(create_entry(i, "test", f"Entry {i}", "tdd"))

        self.assertEqual(len(self.bank), 5)

        self.bank.clear()

        self.assertEqual(len(self.bank), 0)
        self.assertFalse(bool(self.bank))

    def test_len(self):
        """__len__ should return entry count."""
        self.assertEqual(len(self.bank), 0)

        for i in range(3):
            self.bank.add_entry(create_entry(i, "test", f"Entry {i}", "tdd"))

        self.assertEqual(len(self.bank), 3)

    def test_bool(self):
        """__bool__ should return True if entries exist."""
        self.assertFalse(bool(self.bank))

        self.bank.add_entry(create_entry(1, "test", "Entry", "tdd"))

        self.assertTrue(bool(self.bank))

    def test_persistence_across_instances(self):
        """Data should persist when creating new MemoryBank instance."""
        self.bank.add_entry(create_entry(1, "test", "Entry 1", "tdd", "Lesson 1"))
        self.bank.add_entry(create_entry(2, "test", "Entry 2", "tdd", "Lesson 2"))

        # Create new instance pointing to same directory
        new_bank = MemoryBank(str(self.plan_dir))

        entries = new_bank.get_entries(10)
        self.assertEqual(len(entries), 2)
        self.assertEqual(entries[0].stepId, 1)
        self.assertEqual(entries[1].stepId, 2)


class TestFIFOBehavior(unittest.TestCase):
    """Additional tests specifically for FIFO eviction."""

    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.plan_dir = Path(self.test_dir) / "test-plan"
        self.plan_dir.mkdir(parents=True)
        self.bank = MemoryBank(str(self.plan_dir))

    def tearDown(self):
        shutil.rmtree(self.test_dir, ignore_errors=True)

    def test_fifo_preserves_order(self):
        """FIFO should preserve chronological order."""
        # Add entries with distinct contexts
        for i in range(12):
            entry = create_entry(i, "test", f"Entry_{i:02d}", "tdd")
            self.bank.add_entry(entry)

        entries = self.bank.get_entries(20)

        # Should have exactly 10 entries
        self.assertEqual(len(entries), 10)

        # Entries should be in order (oldest first)
        for i, entry in enumerate(entries):
            expected_id = i + 2  # Entries 0 and 1 were evicted
            self.assertEqual(entry.stepId, expected_id)

    def test_fifo_one_at_a_time(self):
        """FIFO should evict one entry at a time when at capacity."""
        # Fill to capacity
        for i in range(10):
            self.bank.add_entry(create_entry(i, "test", f"Entry {i}", "tdd"))

        self.assertEqual(len(self.bank), 10)

        # Add one more
        self.bank.add_entry(create_entry(100, "test", "New entry", "tdd"))

        self.assertEqual(len(self.bank), 10)
        entries = self.bank.get_entries(10)

        # Entry 0 should be evicted, Entry 1 should be first
        self.assertEqual(entries[0].stepId, 1)
        # Entry 100 should be last
        self.assertEqual(entries[-1].stepId, 100)


if __name__ == '__main__':
    unittest.main()
