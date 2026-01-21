"""
Unit tests for the Technique Selector.

Tests phase-based selection, context adjustment, cost estimation,
and technique composition.
"""

import os
import sys
from pathlib import Path

# Add the scripts directory to the path for imports
sys.path.insert(0, str(Path(__file__).parent))

from technique_selector import (
    TechniqueSelector,
    Phase,
    StepContext,
    TechniqueSelection,
    TechniqueMetadata
)


class TestTechniqueSelector:
    """Test suite for TechniqueSelector."""

    @classmethod
    def setup_class(cls):
        """Set up test fixtures."""
        cls.original_cwd = os.getcwd()
        # Navigate up from .claude/scripts to project root
        project_root = Path(__file__).parent.parent.parent
        os.chdir(project_root)
        cls.selector = TechniqueSelector()

    @classmethod
    def teardown_class(cls):
        """Clean up after tests."""
        os.chdir(cls.original_cwd)

    # ==================== Basic Selection Tests ====================

    def test_select_planning_technique_for_algorithm(self):
        """Test planning technique for algorithm problems."""
        result = self.selector.select_techniques('algorithm', Phase.PLANNING)
        assert result.primary == 'self-consistency', \
            f"Expected 'self-consistency' for algorithm planning, got '{result.primary}'"

    def test_select_implementation_technique_for_algorithm(self):
        """Test implementation technique for algorithm problems."""
        result = self.selector.select_techniques('algorithm', Phase.IMPLEMENTATION)
        assert result.primary == 'tdd', \
            f"Expected 'tdd' for algorithm implementation, got '{result.primary}'"

    def test_select_verification_technique_for_algorithm(self):
        """Test verification technique for algorithm problems."""
        result = self.selector.select_techniques('algorithm', Phase.VERIFICATION)
        assert result.primary == 'reflexion', \
            f"Expected 'reflexion' for algorithm verification, got '{result.primary}'"

    def test_select_implementation_technique_for_ui(self):
        """Test implementation technique for UI problems."""
        result = self.selector.select_techniques('ui', Phase.IMPLEMENTATION)
        assert result.primary == 'self-refine', \
            f"Expected 'self-refine' for UI implementation, got '{result.primary}'"

    def test_select_implementation_technique_for_debug(self):
        """Test implementation technique for debug problems."""
        result = self.selector.select_techniques('debug', Phase.IMPLEMENTATION)
        assert result.primary == 'reflexion', \
            f"Expected 'reflexion' for debug implementation, got '{result.primary}'"

    def test_select_planning_technique_for_system_design(self):
        """Test planning technique for system design problems."""
        result = self.selector.select_techniques('system-design', Phase.PLANNING)
        assert result.primary == 'tot', \
            f"Expected 'tot' for system-design planning, got '{result.primary}'"

    # ==================== Phase Selection Tests ====================

    def test_all_phases_return_valid_results(self):
        """Test that all phases return valid results."""
        for phase in Phase:
            result = self.selector.select_techniques('algorithm', phase)
            assert isinstance(result, TechniqueSelection)
            assert result.primary is not None
            assert isinstance(result.secondary, list)
            assert result.estimated_cost in ['low', 'medium', 'high']

    def test_different_phases_may_have_different_techniques(self):
        """Test that phases can have different techniques."""
        planning = self.selector.select_techniques('debug', Phase.PLANNING)
        impl = self.selector.select_techniques('debug', Phase.IMPLEMENTATION)
        verify = self.selector.select_techniques('debug', Phase.VERIFICATION)

        # Debug should use react for planning, reflexion for impl, self-refine for verify
        assert planning.primary == 'react', f"Got {planning.primary}"
        assert impl.primary == 'reflexion', f"Got {impl.primary}"
        assert verify.primary == 'self-refine', f"Got {verify.primary}"

    # ==================== Context Adjustment Tests ====================

    def test_context_adjustment_high_complexity(self):
        """Test that high complexity triggers ToT for planning."""
        context = StepContext(
            step_number=1,
            total_steps=5,
            complexity_score=0.8,
            risk_level='medium',
            previous_failures=0
        )
        result = self.selector.select_techniques('ui', Phase.PLANNING, context)
        assert result.primary == 'tot', \
            f"High complexity should trigger ToT, got '{result.primary}'"

    def test_context_adjustment_previous_failures(self):
        """Test that previous failures trigger Reflexion for verification."""
        context = StepContext(
            step_number=3,
            total_steps=5,
            complexity_score=0.3,
            risk_level='medium',
            previous_failures=2
        )
        result = self.selector.select_techniques('ui', Phase.VERIFICATION, context)
        assert result.primary == 'reflexion', \
            f"Previous failures should trigger reflexion, got '{result.primary}'"

    def test_context_adjustment_early_step(self):
        """Test that early steps get exploration techniques."""
        context = StepContext(
            step_number=1,
            total_steps=10,
            complexity_score=0.3,
            risk_level='low',
            previous_failures=0
        )
        # PS+ should be upgraded to ToT for early steps
        result = self.selector.select_techniques('configuration', Phase.PLANNING, context)
        # configuration uses react for planning, not ps-plus
        # Let's test with infrastructure which uses ps-plus
        result = self.selector.select_techniques('infrastructure', Phase.PLANNING, context)
        assert result.primary == 'tot', \
            f"Early step should upgrade ps-plus to tot, got '{result.primary}'"

    def test_context_adjustment_high_risk_verification(self):
        """Test that high risk adds reflexion to verification."""
        context = StepContext(
            step_number=5,
            total_steps=10,
            complexity_score=0.5,
            risk_level='high',
            previous_failures=0
        )
        result = self.selector.select_techniques('ui', Phase.VERIFICATION, context)
        # self-refine with reflexion added to secondary
        assert 'reflexion' in result.secondary or result.primary == 'reflexion', \
            f"High risk should add reflexion, got {result.primary} with {result.secondary}"

    def test_context_with_many_files_affected(self):
        """Test that many files adds TDD to implementation."""
        context = StepContext(
            step_number=5,
            total_steps=10,
            complexity_score=0.5,
            risk_level='medium',
            previous_failures=0,
            files_affected=['file' + str(i) + '.py' for i in range(15)]
        )
        result = self.selector.select_techniques('ui', Phase.IMPLEMENTATION, context)
        # Should add TDD to secondary
        assert 'tdd' in result.secondary or result.primary == 'tdd', \
            f"Many files should add tdd, got {result.primary} with {result.secondary}"

    # ==================== Unknown Problem Type Tests ====================

    def test_unknown_problem_type_uses_defaults(self):
        """Test that unknown problem types use default configuration."""
        result = self.selector.select_techniques('unknown-type-xyz', Phase.IMPLEMENTATION)
        assert result.primary is not None
        assert result.estimated_cost in ['low', 'medium', 'high']

    def test_unknown_problem_type_rationale_indicates_default(self):
        """Test that rationale mentions the unknown type."""
        result = self.selector.select_techniques('unknown-type-xyz', Phase.PLANNING)
        assert 'unknown-type-xyz' in result.rationale.lower() or result.rationale != ''

    # ==================== Cost Estimation Tests ====================

    def test_cost_estimation_low(self):
        """Test low cost estimation."""
        result = self.selector.select_techniques('documentation', Phase.PLANNING)
        assert result.estimated_cost == 'low', \
            f"Documentation planning should be low cost, got {result.estimated_cost}"

    def test_cost_estimation_high(self):
        """Test high cost estimation."""
        result = self.selector.select_techniques('system-design', Phase.PLANNING)
        # ToT is high cost
        assert result.estimated_cost == 'high', \
            f"System design planning should be high cost, got {result.estimated_cost}"

    def test_secondary_techniques_increase_cost(self):
        """Test that secondary techniques increase cost."""
        # Service-impl has tdd + self-refine for implementation
        result = self.selector.select_techniques('service-impl', Phase.IMPLEMENTATION)
        # With secondary techniques, cost should be medium or high
        assert result.estimated_cost in ['medium', 'high'], \
            f"Multiple techniques should increase cost, got {result.estimated_cost}"

    # ==================== Retry Budget Tests ====================

    def test_retry_budget_low_risk(self):
        """Test retry budget for low risk."""
        result = self.selector.select_techniques('documentation', Phase.IMPLEMENTATION)
        assert result.retry_budget == 3, \
            f"Low risk should have 3 retries, got {result.retry_budget}"

    def test_retry_budget_medium_risk(self):
        """Test retry budget for medium risk."""
        result = self.selector.select_techniques('algorithm', Phase.IMPLEMENTATION)
        assert result.retry_budget == 5, \
            f"Medium risk should have 5 retries, got {result.retry_budget}"

    def test_retry_budget_high_risk(self):
        """Test retry budget for high risk."""
        result = self.selector.select_techniques('migration', Phase.IMPLEMENTATION)
        assert result.retry_budget == 7, \
            f"High risk should have 7 retries, got {result.retry_budget}"

    # ==================== Prompt Template Tests ====================

    def test_get_technique_prompt_valid(self):
        """Test getting prompt template for valid technique."""
        prompt = self.selector.get_technique_prompt('tdd')
        assert prompt == '.claude/commands/tdd.md', \
            f"Expected '.claude/commands/tdd.md', got '{prompt}'"

    def test_get_technique_prompt_invalid_returns_default(self):
        """Test getting prompt template for invalid technique."""
        prompt = self.selector.get_technique_prompt('unknown-tech')
        assert 'unknown-tech.md' in prompt, \
            f"Expected default path, got '{prompt}'"

    # ==================== Metadata Tests ====================

    def test_get_technique_metadata_valid(self):
        """Test getting metadata for valid technique."""
        meta = self.selector.get_technique_metadata('tdd')
        assert meta is not None
        assert isinstance(meta, TechniqueMetadata)
        assert meta.name == 'Test-Driven Development'
        assert 'test' in meta.description.lower() or 'tdd' in meta.description.lower()

    def test_get_technique_metadata_invalid_returns_none(self):
        """Test getting metadata for invalid technique."""
        meta = self.selector.get_technique_metadata('unknown-tech')
        assert meta is None

    def test_metadata_has_best_for_list(self):
        """Test that metadata includes best_for list."""
        meta = self.selector.get_technique_metadata('tot')
        assert meta is not None
        assert isinstance(meta.best_for, list)
        assert len(meta.best_for) > 0

    # ==================== Composition Tests ====================

    def test_compose_techniques_single(self):
        """Test composing a single technique."""
        result = self.selector.compose_techniques(['tdd'], 'Test problem')
        assert 'Test-Driven Development' in result
        assert 'Test problem' in result

    def test_compose_techniques_multiple(self):
        """Test composing multiple techniques."""
        result = self.selector.compose_techniques(['tdd', 'self-refine'], 'Test problem')
        assert 'Test-Driven Development' in result
        assert 'Self-Refine' in result
        assert 'Supporting Techniques' in result

    def test_compose_techniques_empty_returns_empty(self):
        """Test composing empty list returns empty string."""
        result = self.selector.compose_techniques([], 'Test problem')
        assert result == ''

    # ==================== Utility Method Tests ====================

    def test_get_all_techniques(self):
        """Test getting all available techniques."""
        techniques = self.selector.get_all_techniques()
        assert isinstance(techniques, list)
        assert len(techniques) == 10  # We have 10 techniques
        assert 'tdd' in techniques
        assert 'tot' in techniques
        assert 'reflexion' in techniques

    def test_get_techniques_for_problem_type(self):
        """Test getting techniques for a specific problem type."""
        techniques = self.selector.get_techniques_for_problem_type('algorithm')
        assert 'planning' in techniques
        assert 'implementation' in techniques
        assert 'verification' in techniques
        assert techniques['implementation'] == ['tdd']

    def test_get_techniques_for_unknown_type_returns_defaults(self):
        """Test that unknown type returns defaults."""
        techniques = self.selector.get_techniques_for_problem_type('unknown-xyz')
        assert 'planning' in techniques
        assert 'implementation' in techniques
        assert 'verification' in techniques

    # ==================== Result Structure Tests ====================

    def test_selection_result_has_all_fields(self):
        """Test that TechniqueSelection has all required fields."""
        result = self.selector.select_techniques('algorithm', Phase.IMPLEMENTATION)

        assert hasattr(result, 'primary')
        assert hasattr(result, 'secondary')
        assert hasattr(result, 'prompt_template')
        assert hasattr(result, 'rationale')
        assert hasattr(result, 'estimated_cost')
        assert hasattr(result, 'retry_budget')

    def test_rationale_is_human_readable(self):
        """Test that rationale is human-readable."""
        result = self.selector.select_techniques('algorithm', Phase.IMPLEMENTATION)

        assert isinstance(result.rationale, str)
        assert len(result.rationale) > 20
        # Should mention the technique or phase
        assert 'tdd' in result.rationale.lower() or 'implementation' in result.rationale.lower()


class TestThinkingKeywords:
    """Test suite for thinking keyword functionality."""

    @classmethod
    def setup_class(cls):
        """Set up test fixtures."""
        cls.original_cwd = os.getcwd()
        project_root = Path(__file__).parent.parent.parent
        os.chdir(project_root)
        cls.selector = TechniqueSelector()

    @classmethod
    def teardown_class(cls):
        """Clean up after tests."""
        os.chdir(cls.original_cwd)

    # ==================== get_thinking_keyword Tests ====================

    def test_get_thinking_keyword_low(self):
        """Test thinking keyword for low risk level."""
        result = self.selector.get_thinking_keyword("low")
        assert result == "Think about", \
            f"Expected 'Think about' for low, got '{result}'"

    def test_get_thinking_keyword_medium(self):
        """Test thinking keyword for medium risk level."""
        result = self.selector.get_thinking_keyword("medium")
        assert result == "Think hard about", \
            f"Expected 'Think hard about' for medium, got '{result}'"

    def test_get_thinking_keyword_high(self):
        """Test thinking keyword for high risk level."""
        result = self.selector.get_thinking_keyword("high")
        assert result == "Ultrathink about", \
            f"Expected 'Ultrathink about' for high, got '{result}'"

    def test_get_thinking_keyword_critical(self):
        """Test thinking keyword for critical risk level."""
        result = self.selector.get_thinking_keyword("critical")
        assert result == "Ultrathink about", \
            f"Expected 'Ultrathink about' for critical, got '{result}'"

    def test_get_thinking_keyword_case_insensitive(self):
        """Test that thinking keyword lookup is case insensitive."""
        assert self.selector.get_thinking_keyword("LOW") == "Think about"
        assert self.selector.get_thinking_keyword("Medium") == "Think hard about"
        assert self.selector.get_thinking_keyword("HIGH") == "Ultrathink about"
        assert self.selector.get_thinking_keyword("CRITICAL") == "Ultrathink about"

    def test_get_thinking_keyword_unknown_returns_default(self):
        """Test that unknown risk level returns default (Think hard about)."""
        result = self.selector.get_thinking_keyword("unknown")
        assert result == "Think hard about", \
            f"Expected 'Think hard about' for unknown, got '{result}'"

    def test_get_thinking_keyword_empty_returns_default(self):
        """Test that empty risk level returns default."""
        result = self.selector.get_thinking_keyword("")
        assert result == "Think hard about", \
            f"Expected 'Think hard about' for empty, got '{result}'"

    # ==================== get_thinking_keyword_for_step Tests ====================

    def test_get_thinking_keyword_for_step_low_risk(self):
        """Test getting thinking keyword from step info with low risk."""
        step_info = {"riskLevel": "low", "name": "documentation"}
        result = self.selector.get_thinking_keyword_for_step(step_info)
        assert result == "Think about", \
            f"Expected 'Think about' for low risk step, got '{result}'"

    def test_get_thinking_keyword_for_step_high_risk(self):
        """Test getting thinking keyword from step info with high risk."""
        step_info = {"riskLevel": "high", "name": "migration"}
        result = self.selector.get_thinking_keyword_for_step(step_info)
        assert result == "Ultrathink about", \
            f"Expected 'Ultrathink about' for high risk step, got '{result}'"

    def test_get_thinking_keyword_for_step_missing_risk_level(self):
        """Test that missing riskLevel defaults to medium."""
        step_info = {"name": "some-step"}
        result = self.selector.get_thinking_keyword_for_step(step_info)
        assert result == "Think hard about", \
            f"Expected 'Think hard about' for missing risk level, got '{result}'"

    def test_get_thinking_keyword_for_step_empty_dict(self):
        """Test empty step info defaults to medium."""
        result = self.selector.get_thinking_keyword_for_step({})
        assert result == "Think hard about", \
            f"Expected 'Think hard about' for empty dict, got '{result}'"

    # ==================== get_risk_for_problem_type Tests ====================

    def test_get_risk_for_problem_type_low_risk(self):
        """Test risk level for low risk problem types."""
        result = self.selector.get_risk_for_problem_type("documentation")
        assert result == "low", \
            f"Expected 'low' for documentation, got '{result}'"

    def test_get_risk_for_problem_type_medium_risk(self):
        """Test risk level for medium risk problem types."""
        result = self.selector.get_risk_for_problem_type("algorithm")
        assert result == "medium", \
            f"Expected 'medium' for algorithm, got '{result}'"

    def test_get_risk_for_problem_type_high_risk(self):
        """Test risk level for high risk problem types."""
        result = self.selector.get_risk_for_problem_type("migration")
        assert result == "high", \
            f"Expected 'high' for migration, got '{result}'"

    def test_get_risk_for_problem_type_unknown_returns_default(self):
        """Test that unknown problem type returns default risk level."""
        result = self.selector.get_risk_for_problem_type("unknown-xyz")
        assert result == "medium", \
            f"Expected 'medium' for unknown type, got '{result}'"


class TestIntegration:
    """Integration tests for the selector."""

    @classmethod
    def setup_class(cls):
        """Set up test fixtures."""
        cls.original_cwd = os.getcwd()
        project_root = Path(__file__).parent.parent.parent
        os.chdir(project_root)
        cls.selector = TechniqueSelector()

    @classmethod
    def teardown_class(cls):
        """Clean up after tests."""
        os.chdir(cls.original_cwd)

    def test_integration_all_problem_types_selectable(self):
        """Test that all problem types can have techniques selected."""
        problem_types = [
            'infrastructure', 'scaffolding', 'configuration',
            'data-modeling', 'data-access', 'migration', 'state-mgmt',
            'system-design', 'protocol-design', 'di-setup', 'service-impl', 'refactor',
            'ui', 'component-lib', 'design-tokens', 'animation', 'gesture', 'accessibility', 'polish',
            'test-setup', 'unit-test', 'integration-test', 'snapshot-test', 'e2e-test', 'performance-test',
            'algorithm', 'validation', 'api-integration', 'debug',
            'documentation', 'changelog',
            'ideation', 'new-feature'
        ]

        for problem_type in problem_types:
            for phase in Phase:
                result = self.selector.select_techniques(problem_type, phase)
                assert result.primary is not None, \
                    f"Failed for {problem_type}/{phase.value}"
                assert result.estimated_cost in ['low', 'medium', 'high'], \
                    f"Invalid cost for {problem_type}/{phase.value}"

    def test_integration_expected_selections(self):
        """Test multiple specific selections match expectations."""
        test_cases = [
            ('algorithm', Phase.IMPLEMENTATION, 'tdd'),
            ('ui', Phase.IMPLEMENTATION, 'self-refine'),
            ('debug', Phase.IMPLEMENTATION, 'reflexion'),
            ('system-design', Phase.PLANNING, 'tot'),
        ]

        passed = 0
        for ptype, phase, expected in test_cases:
            result = self.selector.select_techniques(ptype, phase)
            if result.primary == expected:
                passed += 1

        assert passed == len(test_cases), \
            f"Only {passed}/{len(test_cases)} selections matched expectations"


# ==================== Run Tests ====================

def run_tests():
    """Run all tests and report results."""
    print("Running Technique Selector Tests...")
    print("=" * 60)

    test_classes = [TestTechniqueSelector, TestThinkingKeywords, TestIntegration]
    total_passed = 0
    total_failed = 0
    failures = []

    for test_class in test_classes:
        print(f"\n{test_class.__name__}")
        print("-" * 40)

        instance = test_class()
        test_class.setup_class()

        for name in dir(instance):
            if name.startswith('test_'):
                try:
                    getattr(instance, name)()
                    print(f"  PASS: {name}")
                    total_passed += 1
                except AssertionError as e:
                    print(f"  FAIL: {name}")
                    print(f"        {e}")
                    failures.append((name, str(e)))
                    total_failed += 1
                except Exception as e:
                    print(f"  ERROR: {name}")
                    print(f"         {type(e).__name__}: {e}")
                    failures.append((name, f"{type(e).__name__}: {e}"))
                    total_failed += 1

        test_class.teardown_class()

    print("\n" + "=" * 60)
    print(f"Results: {total_passed} passed, {total_failed} failed")

    if failures:
        print("\nFailures:")
        for name, error in failures:
            print(f"  - {name}: {error}")
        return 1
    else:
        print("\nAll tests passed!")
        return 0


if __name__ == '__main__':
    sys.exit(run_tests())
