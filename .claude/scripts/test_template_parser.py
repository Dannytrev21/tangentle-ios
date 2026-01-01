"""
Unit tests for Template Parser

Tests the extraction of structured templates from technique markdown files.
"""

import sys
import tempfile
from pathlib import Path
import unittest

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from template_parser import (
    TechniqueTemplate,
    parse_technique_template,
    load_all_templates,
    get_template_section,
    template_has_section,
    _extract_title,
    _extract_description,
    _extract_placeholders,
)


class TestTechniqueTemplate(unittest.TestCase):
    """Test TechniqueTemplate dataclass."""

    def test_create_template_with_defaults(self):
        """Test creating template with default empty values."""
        template = TechniqueTemplate(
            id="test",
            name="Test Template",
            description="A test template"
        )
        self.assertEqual(template.id, "test")
        self.assertEqual(template.planning_section, "")
        self.assertEqual(template.implementation_section, "")
        self.assertEqual(template.verification_section, "")
        self.assertEqual(template.error_recovery_section, "")
        self.assertEqual(template.placeholders, [])

    def test_create_template_with_all_sections(self):
        """Test creating template with all sections populated."""
        template = TechniqueTemplate(
            id="full",
            name="Full Template",
            description="Complete template",
            planning_section="## Planning\nPlan content",
            implementation_section="## Implementation\nImpl content",
            verification_section="## Verification\nVerify content",
            error_recovery_section="## Error Recovery\nRecovery content",
            placeholders=["task", "context", "ARGUMENTS"]
        )
        self.assertEqual(template.planning_section, "## Planning\nPlan content")
        self.assertEqual(len(template.placeholders), 3)


class TestParseMarkedTemplate(unittest.TestCase):
    """Test parsing templates with section markers."""

    def setUp(self):
        """Create a temporary marked template file."""
        self.temp_dir = tempfile.mkdtemp()
        self.marked_content = '''# Test Technique

## Task: $ARGUMENTS

## Instructions

A test technique for testing.

---

<!-- SECTION:PLANNING -->
## Planning Phase

- Understand requirements
- Identify edge cases
- Plan approach
<!-- /SECTION:PLANNING -->

---

<!-- SECTION:IMPLEMENTATION -->
## Implementation Phase

1. Write the code
2. Handle errors
3. Document
<!-- /SECTION:IMPLEMENTATION -->

---

<!-- SECTION:VERIFICATION -->
## Verification Phase

- Run tests
- Check coverage
- Review output
<!-- /SECTION:VERIFICATION -->

<!-- SECTION:ERROR_RECOVERY -->
## Error Recovery

If something fails:
1. Check logs
2. Retry
3. Escalate
<!-- /SECTION:ERROR_RECOVERY -->
'''
        self.marked_file = Path(self.temp_dir) / "test-technique.md"
        self.marked_file.write_text(self.marked_content)

    def test_parse_marked_template_extracts_sections(self):
        """Test that marked sections are extracted correctly."""
        template = parse_technique_template(str(self.marked_file))

        self.assertEqual(template.id, "test-technique")
        self.assertEqual(template.name, "Test Technique")
        self.assertIn("Planning Phase", template.planning_section)
        self.assertIn("Implementation Phase", template.implementation_section)
        self.assertIn("Verification Phase", template.verification_section)
        self.assertIn("Error Recovery", template.error_recovery_section)

    def test_parse_marked_template_extracts_placeholders(self):
        """Test that placeholders are extracted."""
        template = parse_technique_template(str(self.marked_file))
        self.assertIn("ARGUMENTS", template.placeholders)

    def test_parse_marked_template_extracts_description(self):
        """Test that description is extracted."""
        template = parse_technique_template(str(self.marked_file))
        self.assertIn("test technique", template.description.lower())


class TestParseLegacyTemplate(unittest.TestCase):
    """Test parsing templates without section markers."""

    def setUp(self):
        """Create a temporary legacy template file."""
        self.temp_dir = tempfile.mkdtemp()
        self.legacy_content = '''# Legacy Technique

## Task: $ARGUMENTS

## Instructions

An older technique without markers.

---

## Planning Steps

First, understand the problem.
Then identify the approach.

---

## Implementation

Write the code here.

---

## Verification

Check that it works.

---

## Summary

All done.
'''
        self.legacy_file = Path(self.temp_dir) / "legacy.md"
        self.legacy_file.write_text(self.legacy_content)

    def test_parse_legacy_template_uses_heuristics(self):
        """Test that legacy templates are parsed with heuristics."""
        template = parse_technique_template(str(self.legacy_file))

        self.assertEqual(template.id, "legacy")
        self.assertEqual(template.name, "Legacy Technique")
        # Should have found some implementation content
        self.assertTrue(len(template.implementation_section) > 0)


class TestMissingSections(unittest.TestCase):
    """Test handling of templates with missing sections."""

    def setUp(self):
        """Create a template with only some sections."""
        self.temp_dir = tempfile.mkdtemp()
        self.partial_content = '''# Partial Technique

## Instructions

Only has planning section.

<!-- SECTION:PLANNING -->
## Planning

Plan content here.
<!-- /SECTION:PLANNING -->
'''
        self.partial_file = Path(self.temp_dir) / "partial.md"
        self.partial_file.write_text(self.partial_content)

    def test_missing_section_returns_empty_string(self):
        """Test that missing sections return empty string."""
        template = parse_technique_template(str(self.partial_file))

        self.assertIn("Planning", template.planning_section)
        self.assertEqual(template.verification_section, "")
        self.assertEqual(template.error_recovery_section, "")


class TestLoadAllTemplates(unittest.TestCase):
    """Test loading all technique templates."""

    def test_load_all_templates_from_commands_dir(self):
        """Test that all 10 templates can be loaded."""
        # This test requires the actual .claude/commands directory
        try:
            templates = load_all_templates()
            self.assertGreaterEqual(len(templates), 10)

            expected_ids = [
                "tdd", "tot", "reflexion", "self-refine",
                "self-consistency", "react", "ps-plus",
                "chain-of-code", "got", "least-to-most"
            ]

            for tid in expected_ids:
                self.assertIn(tid, templates, f"Missing template: {tid}")
                template = templates[tid]
                self.assertIsInstance(template, TechniqueTemplate)
        except FileNotFoundError:
            self.skipTest(".claude/commands directory not found")

    def test_all_templates_have_implementation_section(self):
        """Test that all templates have implementation content."""
        try:
            templates = load_all_templates()
            for tid, template in templates.items():
                self.assertTrue(
                    len(template.implementation_section) > 0,
                    f"Template {tid} has empty implementation section"
                )
        except FileNotFoundError:
            self.skipTest(".claude/commands directory not found")

    def test_all_templates_parse_successfully(self):
        """Test that all templates parse without errors."""
        try:
            templates = load_all_templates()
            self.assertEqual(len(templates), 10)
            for tid, template in templates.items():
                self.assertIsNotNone(template.id)
                self.assertIsNotNone(template.name)
        except FileNotFoundError:
            self.skipTest(".claude/commands directory not found")


class TestHelperFunctions(unittest.TestCase):
    """Test helper functions."""

    def test_extract_title(self):
        """Test title extraction."""
        content = "# My Great Title\n\nSome content"
        self.assertEqual(_extract_title(content), "My Great Title")

    def test_extract_title_with_parentheses(self):
        """Test title extraction removes parenthetical."""
        content = "# Test-Driven Development (TDD)\n\nContent"
        self.assertEqual(_extract_title(content), "Test-Driven Development")

    def test_extract_title_no_title(self):
        """Test title extraction with no title."""
        content = "Some content without title"
        self.assertIsNone(_extract_title(content))

    def test_extract_description(self):
        """Test description extraction."""
        content = "# Title\n\n## Instructions\n\nFirst paragraph.\n\nSecond paragraph."
        desc = _extract_description(content)
        self.assertEqual(desc, "First paragraph.")

    def test_extract_placeholders(self):
        """Test placeholder extraction."""
        content = "Use {task} and {context} with $ARGUMENTS"
        placeholders = _extract_placeholders(content)
        self.assertIn("task", placeholders)
        self.assertIn("context", placeholders)
        self.assertIn("ARGUMENTS", placeholders)

    def test_extract_placeholders_filters_false_positives(self):
        """Test that common false positives are filtered."""
        content = "for {i} in range({n}): use {x} and {y}"
        placeholders = _extract_placeholders(content)
        self.assertNotIn("i", placeholders)
        self.assertNotIn("x", placeholders)
        self.assertNotIn("y", placeholders)

    def test_get_template_section(self):
        """Test getting specific section from template."""
        template = TechniqueTemplate(
            id="test",
            name="Test",
            description="",
            planning_section="Plan content",
            implementation_section="Impl content",
            verification_section="Verify content",
        )
        self.assertEqual(get_template_section(template, "planning"), "Plan content")
        self.assertEqual(get_template_section(template, "IMPLEMENTATION"), "Impl content")
        self.assertEqual(get_template_section(template, "verification"), "Verify content")
        self.assertEqual(get_template_section(template, "unknown"), "")

    def test_template_has_section(self):
        """Test checking if template has section."""
        template = TechniqueTemplate(
            id="test",
            name="Test",
            description="",
            planning_section="Plan content",
            implementation_section="",
        )
        self.assertTrue(template_has_section(template, "planning"))
        self.assertFalse(template_has_section(template, "implementation"))


class TestActualTemplates(unittest.TestCase):
    """Test parsing actual technique template files."""

    def test_parse_tdd_template(self):
        """Test parsing TDD template with markers."""
        try:
            template = parse_technique_template(".claude/commands/tdd.md")
            self.assertEqual(template.id, "tdd")
            self.assertIn("Test-Driven Development", template.name)
            self.assertIn("Phase 1", template.planning_section)
            self.assertIn("Phase 2", template.implementation_section)
            self.assertIn("Phase 4", template.verification_section)
        except FileNotFoundError:
            self.skipTest("tdd.md not found")

    def test_parse_reflexion_template(self):
        """Test parsing Reflexion template with markers."""
        try:
            template = parse_technique_template(".claude/commands/reflexion.md")
            self.assertEqual(template.id, "reflexion")
            self.assertIn("Memory Bank", template.planning_section)
            self.assertIn("Attempt", template.implementation_section)
            self.assertIn("Final Result", template.verification_section)
        except FileNotFoundError:
            self.skipTest("reflexion.md not found")

    def test_parse_tot_template(self):
        """Test parsing ToT template with markers."""
        try:
            template = parse_technique_template(".claude/commands/tot.md")
            self.assertEqual(template.id, "tot")
            self.assertIn("Root:", template.planning_section)
            self.assertIn("Level 2", template.implementation_section)
            self.assertIn("Convergence", template.verification_section)
        except FileNotFoundError:
            self.skipTest("tot.md not found")


class TestFileNotFound(unittest.TestCase):
    """Test error handling for missing files."""

    def test_parse_nonexistent_file_raises_error(self):
        """Test that parsing a nonexistent file raises FileNotFoundError."""
        with self.assertRaises(FileNotFoundError):
            parse_technique_template("/nonexistent/path/file.md")


if __name__ == "__main__":
    unittest.main()
