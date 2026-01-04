"""
Unit Tests for Prompt Composer

Tests prompt composition, placeholder substitution, multi-technique
handling, and prompt length management.
"""

import unittest
import tempfile
import os
from pathlib import Path

from prompt_composer import (
    compose_prompt,
    substitute_placeholders,
    truncate_with_summary,
    validate_techniques,
    compose_from_step_file,
    get_technique_names,
    StepInfo,
    PlanInfo,
    MAX_PROMPT_LENGTH,
    _parse_step_file,
    _extract_techniques,
    _extract_acceptance_criteria,
    _extract_requirements,
    _normalize_technique_name,
)
from template_parser import load_all_templates, TechniqueTemplate


class TestStepInfo(unittest.TestCase):
    """Tests for StepInfo dataclass."""

    def test_step_info_defaults(self):
        """Test StepInfo with minimal required fields."""
        step = StepInfo(
            id=1,
            title="Test",
            goal="Test goal",
            context="Test context",
            problem_type="algorithm",
            techniques={"planning": "tot"},
            acceptance_criteria=["Test passes"]
        )
        self.assertEqual(step.files_to_create, [])
        self.assertEqual(step.files_to_modify, [])

    def test_step_info_with_files(self):
        """Test StepInfo with file lists."""
        step = StepInfo(
            id="8b",
            title="Test",
            goal="Test goal",
            context="Test context",
            problem_type="algorithm",
            techniques={"planning": "tot"},
            acceptance_criteria=["Test passes"],
            files_to_create=["file1.py"],
            files_to_modify=["file2.py"]
        )
        self.assertEqual(step.files_to_create, ["file1.py"])
        self.assertEqual(step.id, "8b")


class TestPlanInfo(unittest.TestCase):
    """Tests for PlanInfo dataclass."""

    def test_plan_info_defaults(self):
        """Test PlanInfo with minimal required fields."""
        plan = PlanInfo(
            id="004",
            name="test",
            title="Test Plan",
            total_steps=5,
            plan_dir=".claude/plans/004-test"
        )
        self.assertEqual(plan.description, "")


class TestComposeSingleTechnique(unittest.TestCase):
    """Tests for single-technique prompt composition."""

    def setUp(self):
        """Set up test fixtures."""
        self.templates = load_all_templates()
        self.step = StepInfo(
            id=1,
            title="Test Step",
            goal="Implement test functionality",
            context="Testing prompt composition",
            problem_type="algorithm",
            techniques={
                "planning": "ps-plus",
                "implementation": ["self-refine"],
                "verification": "tdd"
            },
            acceptance_criteria=["Code compiles", "Tests pass"]
        )
        self.plan = PlanInfo(
            id="004",
            name="test-plan",
            title="Test Plan",
            total_steps=5,
            plan_dir=".claude/plans/004-test",
            description="A test plan"
        )

    def test_compose_single_technique_prompt(self):
        """Test composing a prompt with single technique per phase."""
        prompt = compose_prompt(
            self.step,
            self.plan,
            self.templates,
            "Write a sort function"
        )

        # Check structure
        self.assertIn("# Prompt: Step 1 - Test Step", prompt)
        self.assertIn("## Mission", prompt)
        self.assertIn("## Context", prompt)
        self.assertIn("## Acceptance Criteria", prompt)
        self.assertIn("## Completion Protocol", prompt)

    def test_prompt_contains_technique_methodology(self):
        """Test that prompt includes technique methodology sections."""
        prompt = compose_prompt(
            self.step,
            self.plan,
            self.templates,
            "Write a sort function"
        )

        # Should have methodology sections
        self.assertIn("Planning Methodology: PS-PLUS", prompt)
        self.assertIn("Implementation Methodology: SELF-REFINE", prompt)
        self.assertIn("Verification Methodology: TDD", prompt)

    def test_prompt_contains_acceptance_criteria(self):
        """Test that acceptance criteria are included."""
        prompt = compose_prompt(
            self.step,
            self.plan,
            self.templates,
            "Write a sort function"
        )

        self.assertIn("Code compiles", prompt)
        self.assertIn("Tests pass", prompt)
        self.assertIn("- [ ] **AC1**", prompt)
        self.assertIn("- [ ] **AC2**", prompt)

    def test_prompt_contains_plan_info(self):
        """Test that plan information is included."""
        prompt = compose_prompt(
            self.step,
            self.plan,
            self.templates,
            "Write a sort function"
        )

        self.assertIn("Test Plan", prompt)
        self.assertIn("step 1 of 5", prompt)


class TestComposeMultiTechnique(unittest.TestCase):
    """Tests for multi-technique prompt composition."""

    def setUp(self):
        """Set up test fixtures."""
        self.templates = load_all_templates()
        self.plan = PlanInfo(
            id="004",
            name="test-plan",
            title="Test Plan",
            total_steps=5,
            plan_dir=".claude/plans/004-test"
        )

    def test_compose_multi_technique_prompt(self):
        """Test composing a prompt with multiple implementation techniques."""
        step = StepInfo(
            id=2,
            title="Complex Step",
            goal="Implement complex functionality",
            context="Testing multi-technique",
            problem_type="algorithm",
            techniques={
                "planning": "tot",
                "implementation": ["tdd", "self-refine"],
                "verification": "reflexion"
            },
            acceptance_criteria=["Works correctly"]
        )

        prompt = compose_prompt(
            step,
            self.plan,
            self.templates,
            "Build a complex system"
        )

        # Should have combined implementation header
        self.assertIn("Implementation Methodology: TDD + SELF-REFINE", prompt)

        # Should have phase labels
        self.assertIn("### Phase 1: TDD", prompt)
        self.assertIn("### Phase 2: SELF-REFINE", prompt)

    def test_multi_technique_preserves_order(self):
        """Test that techniques are applied in specified order."""
        step = StepInfo(
            id=3,
            title="Ordered Step",
            goal="Test ordering",
            context="Testing technique order",
            problem_type="algorithm",
            techniques={
                "planning": "ps-plus",
                "implementation": ["reflexion", "tdd"],
                "verification": "self-refine"
            },
            acceptance_criteria=["Order preserved"]
        )

        prompt = compose_prompt(
            step,
            self.plan,
            self.templates,
            "Test ordering"
        )

        # Find positions
        phase1_pos = prompt.find("### Phase 1: REFLEXION")
        phase2_pos = prompt.find("### Phase 2: TDD")

        self.assertGreater(phase1_pos, 0)
        self.assertGreater(phase2_pos, phase1_pos)


class TestPlaceholderSubstitution(unittest.TestCase):
    """Tests for placeholder substitution."""

    def setUp(self):
        """Set up test fixtures."""
        self.step = StepInfo(
            id=5,
            title="My Step",
            goal="Do something",
            context="Testing placeholders",
            problem_type="ui",
            techniques={
                "planning": "tot",
                "implementation": ["tdd"],
                "verification": "reflexion"
            },
            acceptance_criteria=["Done"]
        )
        self.plan = PlanInfo(
            id="007",
            name="placeholder-test",
            title="Placeholder Test Plan",
            total_steps=10,
            plan_dir=".claude/plans/007-placeholder-test"
        )

    def test_placeholder_substitution(self):
        """Test that all placeholders are substituted."""
        template = """
        Step {step_number}: {step_name}
        Plan: {plan_name} ({plan_id})
        Dir: {plan_dir}
        Total: {total_steps}
        Type: {problem_type}
        """

        result = substitute_placeholders(
            template,
            self.step,
            self.plan,
            "requirements"
        )

        self.assertIn("Step 5: My Step", result)
        self.assertIn("Plan: Placeholder Test Plan (007)", result)
        self.assertIn("Dir: .claude/plans/007-placeholder-test", result)
        self.assertIn("Total: 10", result)
        self.assertIn("Type: ui", result)

    def test_no_unsubstituted_placeholders_in_output(self):
        """Test that composed prompts have no remaining placeholders."""
        templates = load_all_templates()

        prompt = compose_prompt(
            self.step,
            self.plan,
            templates,
            "Build something"
        )

        # Check for common placeholder patterns
        import re
        unsubstituted = re.findall(r'\{[a-z_]+\}', prompt)
        # Filter out legitimate uses like JSON examples
        real_placeholders = [p for p in unsubstituted
                           if p not in ['{date}', '{files}']]

        self.assertEqual(
            len(real_placeholders), 0,
            f"Found unsubstituted placeholders: {real_placeholders}"
        )

    def test_technique_placeholders(self):
        """Test technique-specific placeholders."""
        template = "Planning: {technique_planning}, Impl: {technique_impl}, Verify: {technique_verify}"

        result = substitute_placeholders(
            template,
            self.step,
            self.plan,
            ""
        )

        self.assertIn("Planning: tot", result)
        self.assertIn("Impl: tdd", result)
        self.assertIn("Verify: reflexion", result)


class TestPromptTruncation(unittest.TestCase):
    """Tests for prompt length management."""

    def test_prompt_under_limit_unchanged(self):
        """Test that prompts under the limit are not modified."""
        short_prompt = "This is a short prompt."
        result = truncate_with_summary(short_prompt)
        self.assertEqual(result, short_prompt)

    def test_prompt_truncation(self):
        """Test that long prompts are truncated."""
        # Create a very long prompt
        long_methodology = "Methodology content. " * 5000
        long_prompt = f"""# Prompt

## Mission
Do something.

## Planning Methodology: TEST
{long_methodology}

## Implementation Methodology: TEST
{long_methodology}

## Acceptance Criteria
- Criterion 1
"""

        self.assertGreater(len(long_prompt), MAX_PROMPT_LENGTH)

        result = truncate_with_summary(long_prompt)

        # Should be shortened
        self.assertLess(len(result), len(long_prompt))

        # Should preserve structure
        self.assertIn("# Prompt", result)
        self.assertIn("## Mission", result)
        self.assertIn("## Acceptance Criteria", result)

        # Should have truncation note
        self.assertIn("summarized", result.lower())

    def test_truncation_preserves_critical_sections(self):
        """Test that truncation keeps mission and criteria."""
        long_content = "Content " * 10000
        long_prompt = f"""# Prompt

## Mission
CRITICAL MISSION TEXT

## Planning Methodology: TEST
{long_content}

## Implementation Methodology: TEST
{long_content}

## Acceptance Criteria
- CRITICAL CRITERION 1
- CRITICAL CRITERION 2
"""

        result = truncate_with_summary(long_prompt)

        self.assertIn("CRITICAL MISSION TEXT", result)
        self.assertIn("CRITICAL CRITERION 1", result)
        self.assertIn("CRITICAL CRITERION 2", result)


class TestValidateTechniques(unittest.TestCase):
    """Tests for technique validation."""

    def setUp(self):
        """Set up test fixtures."""
        self.templates = load_all_templates()

    def test_validate_valid_techniques(self):
        """Test validation passes for valid techniques."""
        techniques = {
            "planning": "tot",
            "implementation": ["tdd", "self-refine"],
            "verification": "reflexion"
        }

        is_valid, missing = validate_techniques(techniques, self.templates)

        self.assertTrue(is_valid)
        self.assertEqual(missing, [])

    def test_validate_missing_technique(self):
        """Test validation fails for missing techniques."""
        techniques = {
            "planning": "nonexistent",
            "implementation": ["tdd"],
            "verification": "reflexion"
        }

        is_valid, missing = validate_techniques(techniques, self.templates)

        self.assertFalse(is_valid)
        self.assertEqual(len(missing), 1)
        self.assertIn("planning: nonexistent", missing)

    def test_validate_multiple_missing(self):
        """Test validation reports all missing techniques."""
        techniques = {
            "planning": "fake1",
            "implementation": ["fake2", "tdd"],
            "verification": "fake3"
        }

        is_valid, missing = validate_techniques(techniques, self.templates)

        self.assertFalse(is_valid)
        self.assertEqual(len(missing), 3)


class TestGetTechniqueNames(unittest.TestCase):
    """Tests for getting available technique names."""

    def test_get_technique_names(self):
        """Test getting list of technique names."""
        templates = load_all_templates()
        names = get_technique_names(templates)

        self.assertIn("tdd", names)
        self.assertIn("tot", names)
        self.assertIn("reflexion", names)
        self.assertIn("self-refine", names)
        self.assertEqual(len(names), 10)


class TestMissingTemplateHandling(unittest.TestCase):
    """Tests for handling missing templates gracefully."""

    def test_missing_template_uses_fallback(self):
        """Test that missing templates don't crash composition."""
        # Create minimal templates dict
        minimal_templates = {
            "ps-plus": TechniqueTemplate(
                id="ps-plus",
                name="PS+",
                description="Test",
                implementation_section="Do stuff"
            )
        }

        step = StepInfo(
            id=1,
            title="Test",
            goal="Test",
            context="Test",
            problem_type="test",
            techniques={
                "planning": "nonexistent",  # Missing
                "implementation": ["ps-plus"],  # Exists
                "verification": "also-missing"  # Missing
            },
            acceptance_criteria=["Done"]
        )

        plan = PlanInfo(
            id="001",
            name="test",
            title="Test",
            total_steps=1,
            plan_dir=".claude/plans/001-test"
        )

        # Should not raise
        prompt = compose_prompt(step, plan, minimal_templates, "requirements")

        # Should still have basic structure
        self.assertIn("# Prompt", prompt)
        self.assertIn("## Mission", prompt)


class TestParseStepFile(unittest.TestCase):
    """Tests for parsing step files."""

    def test_parse_step_file_content(self):
        """Test parsing step file content."""
        content = """# Step 5: Test Step Title

## Context
This is the context for the step.

## Goal
Accomplish something important.

## Problem Type
`algorithm`

## Technique Selection
- **Planning**: ToT (explore options)
- **Implementation**: TDD + Self-Refine
- **Verification**: Reflexion

## Acceptance Criteria
- [ ] First criterion
- [ ] Second criterion

## Files to Create
- `file1.py`
- `file2.py`

## Files to Modify
- `existing.py`
"""

        step = _parse_step_file(content, "05-test-step")

        self.assertEqual(step.id, "05")
        self.assertIn("Test Step", step.title)
        self.assertIn("context", step.context.lower())
        self.assertIn("important", step.goal.lower())
        self.assertEqual(step.problem_type, "algorithm")

    def test_extract_techniques(self):
        """Test extracting techniques from content."""
        content = """## Technique Selection
- **Planning**: ToT (explore options)
- **Implementation**: TDD, Self-Refine
- **Verification**: Reflexion
"""

        techniques = _extract_techniques(content)

        self.assertEqual(techniques["planning"], "tot")
        self.assertIn("tdd", techniques["implementation"])
        self.assertIn("self-refine", techniques["implementation"])
        self.assertEqual(techniques["verification"], "reflexion")

    def test_extract_acceptance_criteria(self):
        """Test extracting acceptance criteria."""
        content = """## Acceptance Criteria
- First thing works
- [ ] Second thing passes
- **Third** criterion met
"""

        criteria = _extract_acceptance_criteria(content)

        self.assertEqual(len(criteria), 3)
        self.assertIn("First thing works", criteria)


class TestComposeFromFile(unittest.TestCase):
    """Tests for composing prompts from step files."""

    def setUp(self):
        """Set up test fixtures with temp files."""
        self.temp_dir = tempfile.mkdtemp()
        self.plan_dir = os.path.join(self.temp_dir, "plan")
        os.makedirs(self.plan_dir)

        # Create progress.json
        progress = {
            "planId": "test",
            "name": "test-plan",
            "title": "Test Plan",
            "totalSteps": 3,
            "description": "A test plan"
        }

        import json
        with open(os.path.join(self.plan_dir, "progress.json"), "w") as f:
            json.dump(progress, f)

        # Create step file
        self.step_content = """# Step 1: First Step

## Context
Setting up the basics.

## Goal
Create initial structure.

## Problem Type
`infrastructure`

## Technique Selection
- **Planning**: PS+
- **Implementation**: Self-Refine
- **Verification**: TDD

## Detailed Requirements
Build the foundation:
1. Create directories
2. Set up config

## Acceptance Criteria
- [ ] Directories exist
- [ ] Config is valid
"""
        self.step_file = os.path.join(self.temp_dir, "01-first-step.md")
        with open(self.step_file, "w") as f:
            f.write(self.step_content)

    def tearDown(self):
        """Clean up temp files."""
        import shutil
        shutil.rmtree(self.temp_dir)

    def test_compose_from_step_file(self):
        """Test composing prompt from a step file."""
        templates = load_all_templates()
        plan = PlanInfo(
            id="test",
            name="test-plan",
            title="Test Plan",
            total_steps=3,
            plan_dir=self.plan_dir
        )

        prompt = compose_from_step_file(self.step_file, plan, templates)

        self.assertIn("# Prompt: Step 01 - First Step", prompt)
        self.assertIn("Create initial structure", prompt)
        self.assertIn("PS-PLUS", prompt)

    def test_compose_from_nonexistent_file(self):
        """Test error handling for missing file."""
        templates = load_all_templates()
        plan = PlanInfo(
            id="test",
            name="test-plan",
            title="Test Plan",
            total_steps=1,
            plan_dir=self.plan_dir
        )

        with self.assertRaises(FileNotFoundError):
            compose_from_step_file("/nonexistent/path.md", plan, templates)


class TestIntegration(unittest.TestCase):
    """Integration tests with real templates."""

    def test_full_prompt_generation(self):
        """Test generating a complete prompt with all features."""
        templates = load_all_templates()

        step = StepInfo(
            id="8b",
            title="Prompt Embedding",
            goal="Create the prompt composition system",
            context="Core prompt generation logic for technique embedding",
            problem_type="system-design",
            techniques={
                "planning": "tot",
                "implementation": ["self-refine"],
                "verification": "reflexion"
            },
            acceptance_criteria=[
                "Single-technique prompts generate correctly",
                "Multi-technique prompts compose without conflicts",
                "Placeholders are all substituted",
                "Prompt length is managed",
                "Unit tests pass"
            ],
            files_to_create=["prompt_composer.py", "test_prompt_composer.py"],
            files_to_modify=[]
        )

        plan = PlanInfo(
            id="004",
            name="intelligent-planning-system-v2",
            title="Intelligent Planning System v2",
            total_steps=15,
            plan_dir=".claude/plans/004-intelligent-planning-system-v2",
            description="Upgrade planning with automatic technique selection"
        )

        prompt = compose_prompt(
            step,
            plan,
            templates,
            """### Goal
Create a prompt composer for technique-embedded prompts.

### Requirements
1. Load technique templates
2. Compose prompts with methodology
3. Handle multi-technique phases
4. Substitute placeholders
5. Manage prompt length
"""
        )

        # Verify complete structure
        self.assertIn("# Prompt: Step 8b", prompt)
        self.assertIn("## Mission", prompt)
        self.assertIn("## Context", prompt)
        self.assertIn("## Planning Methodology: TOT", prompt)
        self.assertIn("## Implementation Methodology: SELF-REFINE", prompt)
        self.assertIn("## Verification Methodology: REFLEXION", prompt)
        self.assertIn("## Acceptance Criteria", prompt)
        self.assertIn("## Error Recovery", prompt)
        self.assertIn("## Completion Protocol", prompt)
        self.assertIn("## Do NOT", prompt)

        # Verify length is reasonable
        self.assertLess(len(prompt), MAX_PROMPT_LENGTH)

        # Verify all 5 ACs included
        self.assertIn("AC1", prompt)
        self.assertIn("AC5", prompt)


if __name__ == '__main__':
    unittest.main()
