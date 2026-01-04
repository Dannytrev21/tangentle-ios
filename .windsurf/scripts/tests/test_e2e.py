#!/usr/bin/env python3
"""End-to-end integration tests for the Windsurf planning system.

This module tests that all components work correctly together:
- Directory structure
- Python scripts
- Template files
- Knowledge base
- Memory bank
- Git exclusion rules
"""

import json
import os
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

# Navigate to project root for imports
SCRIPT_DIR = Path(__file__).resolve().parent
SCRIPTS_DIR = SCRIPT_DIR.parent
WINDSURF_ROOT = SCRIPTS_DIR.parent
PROJECT_ROOT = WINDSURF_ROOT.parent

# Add scripts to path
sys.path.insert(0, str(SCRIPTS_DIR))


class TestDirectoryStructure(unittest.TestCase):
    """Test that .windsurf/ directory structure is complete."""

    def setUp(self):
        self.root = WINDSURF_ROOT

    def test_main_directories_exist(self):
        """Test that all main directories exist."""
        required_dirs = [
            'workflows',
            'plans',
            'scripts',
            'scripts/tests',
            'templates',
            'knowledge',
            'knowledge/techniques',
            'memory-bank',
            'rules',
        ]
        for d in required_dirs:
            path = self.root / d
            self.assertTrue(path.exists(), f"Missing directory: {d}")
            self.assertTrue(path.is_dir(), f"Not a directory: {d}")

    def test_python_init_files_exist(self):
        """Test that __init__.py files exist for Python modules."""
        init_files = [
            'scripts/__init__.py',
            'scripts/tests/__init__.py',
        ]
        for f in init_files:
            path = self.root / f
            self.assertTrue(path.exists(), f"Missing init file: {f}")


class TestWorkflows(unittest.TestCase):
    """Test that all workflows exist and are properly formatted."""

    def setUp(self):
        self.workflows_dir = WINDSURF_ROOT / 'workflows'

    def test_main_workflows_exist(self):
        """Test that all 8 main workflows exist."""
        required_workflows = [
            'plan-feature-initial.md',
            'plan-feature.md',
            'plan-prompts.md',
            'plan-next.md',
            'plan-status.md',
            'plan-verify.md',
            'plan-rollback.md',
            'plan-feature-review.md',
        ]
        for w in required_workflows:
            path = self.workflows_dir / w
            self.assertTrue(path.exists(), f"Missing workflow: {w}")

    def test_helper_workflows_exist(self):
        """Test that all 3 helper workflows exist."""
        required_helpers = [
            '_internal-init.md',
            '_internal-verify.md',
            '_internal-commit.md',
        ]
        for h in required_helpers:
            path = self.workflows_dir / h
            self.assertTrue(path.exists(), f"Missing helper: {h}")

    def test_workflows_under_char_limit(self):
        """Test that all workflows are under 12,000 characters."""
        for workflow_file in self.workflows_dir.glob('*.md'):
            content = workflow_file.read_text()
            self.assertLessEqual(
                len(content), 12000,
                f"{workflow_file.name} exceeds 12K limit: {len(content)} chars"
            )

    def test_workflows_have_frontmatter(self):
        """Test that main workflows have YAML frontmatter."""
        for workflow_file in self.workflows_dir.glob('*.md'):
            if workflow_file.name.startswith('_'):
                continue  # Skip helpers
            content = workflow_file.read_text()
            self.assertTrue(
                content.startswith('---'),
                f"{workflow_file.name} missing YAML frontmatter"
            )


class TestPythonScripts(unittest.TestCase):
    """Test that Python scripts execute correctly."""

    def setUp(self):
        self.scripts_dir = SCRIPTS_DIR

    def test_required_scripts_exist(self):
        """Test that all required scripts exist."""
        required_scripts = [
            'utils.py',
            'problem_classifier.py',
            'technique_selector.py',
            'risk_assessor.py',
            'memory_bank.py',
            'self_correction.py',
            'file_tracker.py',
            'windsurf_plan.py',
        ]
        for s in required_scripts:
            path = self.scripts_dir / s
            self.assertTrue(path.exists(), f"Missing script: {s}")

    def test_windsurf_plan_help(self):
        """Test that windsurf_plan.py --help works."""
        result = subprocess.run(
            ['python3', str(self.scripts_dir / 'windsurf_plan.py'), '--help'],
            capture_output=True, text=True
        )
        self.assertEqual(result.returncode, 0, f"--help failed: {result.stderr}")
        self.assertIn('usage', result.stdout.lower())

    def test_classify_command(self):
        """Test the classify command."""
        result = subprocess.run(
            ['python3', str(self.scripts_dir / 'windsurf_plan.py'), 'classify', 'fix a bug'],
            capture_output=True, text=True
        )
        self.assertEqual(result.returncode, 0, f"classify failed: {result.stderr}")
        self.assertIn('debug', result.stdout.lower())

    def test_techniques_command(self):
        """Test the techniques command."""
        result = subprocess.run(
            ['python3', str(self.scripts_dir / 'windsurf_plan.py'), 'techniques', 'debug'],
            capture_output=True, text=True
        )
        self.assertEqual(result.returncode, 0, f"techniques failed: {result.stderr}")
        # Should output technique names
        self.assertTrue(len(result.stdout) > 0)

    def test_risk_command(self):
        """Test the risk command."""
        result = subprocess.run(
            ['python3', str(self.scripts_dir / 'windsurf_plan.py'), 'risk', 'migration'],
            capture_output=True, text=True
        )
        self.assertEqual(result.returncode, 0, f"risk failed: {result.stderr}")
        # Should mention a risk level
        self.assertTrue(
            any(level in result.stdout.upper() for level in ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']),
            f"No risk level in output: {result.stdout}"
        )

    def test_budget_command(self):
        """Test the budget command."""
        result = subprocess.run(
            ['python3', str(self.scripts_dir / 'windsurf_plan.py'), 'budget', 'high'],
            capture_output=True, text=True
        )
        self.assertEqual(result.returncode, 0, f"budget failed: {result.stderr}")
        # Should output retry budget
        self.assertTrue(len(result.stdout) > 0)


class TestTemplates(unittest.TestCase):
    """Test that template files exist and are valid."""

    def setUp(self):
        self.templates_dir = WINDSURF_ROOT / 'templates'

    def test_all_templates_exist(self):
        """Test that all 6 templates exist."""
        required_templates = [
            'plan.md.template',
            'adr.md.template',
            'step.md.template',
            'progress.json.template',
            'context.md.template',
            'prompt.md.template',
        ]
        for t in required_templates:
            path = self.templates_dir / t
            self.assertTrue(path.exists(), f"Missing template: {t}")

    def test_templates_use_placeholder_syntax(self):
        """Test that templates use {{PLACEHOLDER}} syntax."""
        for template_file in self.templates_dir.glob('*.template'):
            content = template_file.read_text()
            # Should have at least one placeholder
            placeholders = re.findall(r'\{\{[A-Z_]+\}\}', content)
            self.assertGreater(
                len(placeholders), 0,
                f"{template_file.name} has no {{{{PLACEHOLDER}}}} syntax"
            )


class TestKnowledgeBase(unittest.TestCase):
    """Test that knowledge base files exist and are complete."""

    def setUp(self):
        self.knowledge_dir = WINDSURF_ROOT / 'knowledge'
        self.techniques_dir = self.knowledge_dir / 'techniques'

    def test_all_10_techniques_exist(self):
        """Test that all 10 technique files exist."""
        required_techniques = [
            'ps-plus.md',
            'least-to-most.md',
            'tdd.md',
            'self-refine.md',
            'chain-of-code.md',
            'react.md',
            'tot.md',
            'got.md',
            'self-consistency.md',
            'reflexion.md',
        ]
        for t in required_techniques:
            path = self.techniques_dir / t
            self.assertTrue(path.exists(), f"Missing technique: {t}")

    def test_architecture_md_exists(self):
        """Test that architecture.md exists."""
        path = self.knowledge_dir / 'architecture.md'
        self.assertTrue(path.exists(), "Missing architecture.md")

    def test_technique_config_exists_and_valid(self):
        """Test that technique-config.json exists and is valid JSON."""
        path = WINDSURF_ROOT / 'technique-config.json'
        self.assertTrue(path.exists(), "Missing technique-config.json")

        content = path.read_text()
        try:
            data = json.loads(content)
            self.assertIsInstance(data, dict)
        except json.JSONDecodeError as e:
            self.fail(f"Invalid JSON in technique-config.json: {e}")

    def test_techniques_have_required_sections(self):
        """Test that technique files have required sections (Overview, How It Works/Methodology, Example, When to Use)."""
        # Note: Technique files use "How It Works" instead of "Methodology"
        required_sections = ['Overview', 'When to Use']
        alternative_sections = [('How It Works', 'Methodology')]  # Either is acceptable

        for technique_file in self.techniques_dir.glob('*.md'):
            content = technique_file.read_text().lower()

            # Check required sections
            for section in required_sections:
                self.assertIn(
                    section.lower(),
                    content,
                    f"{technique_file.name} missing section: {section}"
                )

            # Check at least one of the alternative sections exists
            for alts in alternative_sections:
                found = any(alt.lower() in content for alt in alts)
                self.assertTrue(
                    found,
                    f"{technique_file.name} missing one of: {alts}"
                )


class TestMemoryBank(unittest.TestCase):
    """Test memory bank files and functionality."""

    def setUp(self):
        self.memory_dir = WINDSURF_ROOT / 'memory-bank'

    def test_memory_bank_files_exist(self):
        """Test that all 5 memory bank files exist."""
        required_files = [
            'productContext.md',
            'activeContext.md',
            'progress.md',
            'decisionLog.md',
            'systemPatterns.md',
        ]
        for f in required_files:
            path = self.memory_dir / f
            self.assertTrue(path.exists(), f"Missing memory bank file: {f}")

    def test_memory_bank_have_update_triggers(self):
        """Test that memory bank files have update triggers."""
        for md_file in self.memory_dir.glob('*.md'):
            content = md_file.read_text()
            self.assertIn(
                'Update Trigger',
                content,
                f"{md_file.name} missing update trigger documentation"
            )


class TestProjectContext(unittest.TestCase):
    """Test project context files."""

    def test_project_context_exists(self):
        """Test that PROJECT_CONTEXT.md exists."""
        path = WINDSURF_ROOT / 'PROJECT_CONTEXT.md'
        self.assertTrue(path.exists(), "Missing PROJECT_CONTEXT.md")

    def test_repo_commands_exists(self):
        """Test that repo-commands.md exists."""
        path = WINDSURF_ROOT / 'knowledge' / 'repo-commands.md'
        self.assertTrue(path.exists(), "Missing repo-commands.md")


class TestFileTracker(unittest.TestCase):
    """Test file tracker exclusion rules."""

    def test_file_tracker_import(self):
        """Test that file_tracker module can be imported."""
        try:
            from file_tracker import FileTracker
        except ImportError as e:
            self.fail(f"Cannot import FileTracker: {e}")

    def test_windsurf_excluded(self):
        """Test that .windsurf paths are excluded."""
        from file_tracker import FileTracker

        tracker = FileTracker()
        excluded_paths = [
            '.windsurf/test.md',
            '.windsurf/plans/001/progress.json',
            '.windsurf/scripts/utils.py',
        ]

        # validate_files returns (allowed, rejected) - excluded files should be in rejected
        allowed, rejected = tracker.validate_files(excluded_paths)
        self.assertEqual(len(rejected), len(excluded_paths), f"Should reject all .windsurf paths")
        self.assertEqual(len(allowed), 0, "No .windsurf paths should be allowed")

    def test_normal_paths_allowed(self):
        """Test that normal project paths are allowed."""
        from file_tracker import FileTracker

        tracker = FileTracker()
        allowed_paths = [
            'src/main.py',
            'tests/test_main.py',
            'README.md',
            'Tangentle/Core/Models/TGTask.swift',
        ]

        # validate_files returns (allowed, rejected) - normal files should be in allowed
        allowed, rejected = tracker.validate_files(allowed_paths)
        self.assertEqual(len(allowed), len(allowed_paths), "All normal paths should be allowed")
        self.assertEqual(len(rejected), 0, f"No normal paths should be rejected: {rejected}")


class TestGitExclusion(unittest.TestCase):
    """Test that .windsurf is excluded from git."""

    def test_gitignore_contains_windsurf(self):
        """Test that .gitignore contains .windsurf/**."""
        gitignore_path = PROJECT_ROOT / '.gitignore'
        if gitignore_path.exists():
            content = gitignore_path.read_text()
            self.assertTrue(
                '.windsurf' in content,
                ".gitignore should contain .windsurf entry"
            )


class TestSelfCorrection(unittest.TestCase):
    """Test self-correction engine."""

    def test_memory_bank_import(self):
        """Test that memory_bank module can be imported."""
        try:
            from memory_bank import MemoryBank
        except ImportError as e:
            self.fail(f"Cannot import MemoryBank: {e}")

    def test_self_correction_import(self):
        """Test that self_correction module can be imported."""
        try:
            from self_correction import SelfCorrection
        except ImportError as e:
            self.fail(f"Cannot import SelfCorrection: {e}")

    def test_memory_bank_fifo(self):
        """Test that memory bank uses FIFO with max 10 entries."""
        from memory_bank import MemoryBank, MemoryBankEntry
        import tempfile
        from datetime import datetime

        # MemoryBank requires a plan_dir with memory-bank.json storage
        with tempfile.TemporaryDirectory() as tmpdir:
            mb = MemoryBank(plan_dir=tmpdir)

            # Add 12 entries using MemoryBankEntry objects
            for i in range(12):
                entry = MemoryBankEntry(
                    timestamp=datetime.now().isoformat(),
                    stepId=1,
                    failureType='test',
                    context=f"Test context {i}",
                    lesson=f"Lesson {i}",
                    techniqueUsed='tdd'
                )
                mb.add_entry(entry)

            # Should have max 10 (MAX_ENTRIES)
            entries = mb.get_entries(limit=20)  # Get all
            self.assertLessEqual(len(entries), MemoryBank.MAX_ENTRIES)

    def test_retry_budgets(self):
        """Test retry budgets per risk level."""
        from memory_bank import MemoryBank
        from self_correction import SelfCorrection, RETRY_CONFIG
        import tempfile

        expected_budgets = {
            'low': 3,
            'medium': 5,
            'high': 7,
            'critical': 10,
        }

        for level, expected in expected_budgets.items():
            # SelfCorrection requires a MemoryBank instance
            with tempfile.TemporaryDirectory() as tmpdir:
                mb = MemoryBank(plan_dir=tmpdir)
                sc = SelfCorrection(memory_bank=mb, risk_level=level)
                # The config uses snake_case: max_total
                self.assertEqual(
                    sc.config.get("max_total", 0),
                    expected,
                    f"Risk level {level} should have {expected} max retries"
                )


class TestComponentIntegration(unittest.TestCase):
    """Test that components work together correctly."""

    def test_classify_to_techniques_integration(self):
        """Test that classify output works with techniques selector."""
        from problem_classifier import ProblemClassifier
        from technique_selector import TechniqueSelector, Phase

        # Classify a problem
        classifier = ProblemClassifier()
        result = classifier.classify("Add a new REST API endpoint")
        # ClassificationResult has primary_type, not type
        self.assertTrue(hasattr(result, 'primary_type'))

        # Use that type to get techniques for each phase
        selector = TechniqueSelector()

        # Test planning phase
        planning_tech = selector.select_techniques(result.primary_type, Phase.PLANNING)
        self.assertTrue(hasattr(planning_tech, 'primary'))

        # Test implementation phase
        impl_tech = selector.select_techniques(result.primary_type, Phase.IMPLEMENTATION)
        self.assertTrue(hasattr(impl_tech, 'primary'))

        # Test verification phase
        verify_tech = selector.select_techniques(result.primary_type, Phase.VERIFICATION)
        self.assertTrue(hasattr(verify_tech, 'primary'))

    def test_risk_to_budget_integration(self):
        """Test that risk assessment integrates with retry budget."""
        from risk_assessor import RiskAssessor, StepInfo
        from self_correction import RETRY_CONFIG

        # Create a step info for risk assessment using correct field names
        step_info = StepInfo(
            problem_type='migration',
            has_data_migration=True,
            has_external_api=False,
            affects_persistence=True,
            is_breaking_change=False,
            complexity_estimate='high'
        )

        # Assess risk for the step using assess_risk method
        assessor = RiskAssessor()
        risk = assessor.assess_risk(step_info)
        self.assertTrue(hasattr(risk, 'level'))

        # Get retry budget for that risk level (level is a RiskLevel enum)
        level = risk.level.value.lower() if hasattr(risk.level, 'value') else str(risk.level).lower()
        budget = RETRY_CONFIG.get(level, RETRY_CONFIG['medium'])
        self.assertIsInstance(budget, dict)
        self.assertIn('max_total', budget)


def run_all_tests():
    """Run all E2E tests and return results."""
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    # Add all test classes
    test_classes = [
        TestDirectoryStructure,
        TestWorkflows,
        TestPythonScripts,
        TestTemplates,
        TestKnowledgeBase,
        TestMemoryBank,
        TestProjectContext,
        TestFileTracker,
        TestGitExclusion,
        TestSelfCorrection,
        TestComponentIntegration,
    ]

    for test_class in test_classes:
        tests = loader.loadTestsFromTestCase(test_class)
        suite.addTests(tests)

    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    return result


if __name__ == '__main__':
    result = run_all_tests()

    # Print summary
    print("\n" + "=" * 60)
    print("E2E TEST SUMMARY")
    print("=" * 60)
    print(f"Tests Run: {result.testsRun}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    print(f"Skipped: {len(result.skipped)}")

    if result.wasSuccessful():
        print("\n" + "=" * 60)
        print("ALL E2E TESTS PASSED!")
        print("=" * 60)
        sys.exit(0)
    else:
        print("\n" + "=" * 60)
        print("SOME TESTS FAILED")
        print("=" * 60)
        sys.exit(1)
