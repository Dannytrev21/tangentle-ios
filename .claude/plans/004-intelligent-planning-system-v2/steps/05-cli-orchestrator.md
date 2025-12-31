# Step 5: CLI Orchestrator

## Context
With the core logic in place (classifier, selector, assessor), we need a unified CLI tool that orchestrates these components. This tool provides an alternative interface to the markdown commands and enables automation.

## Goal
Create a Python CLI tool (`tangentle-plan`) that provides a streamlined interface for plan management, integrating all the intelligent planning components.

## Problem Type
`infrastructure`

## Technique Selection
- **Planning**: PS+ (clear CLI design benefits from structured planning)
- **Implementation**: Least-to-Most (build up from subcommands)
- **Verification**: Self-Refine (iterate on UX)

## Risk Level
**Medium** - Integration point for multiple components

## Prerequisites
- Step 1 completed (technique-config.json)
- Step 2 completed (problem_classifier.py)
- Step 3 completed (technique_selector.py)
- Step 4 completed (risk_assessor.py)

## High-Level Steps
1. Design CLI interface and subcommands
2. Implement core orchestration logic
3. Add plan creation subcommand
4. Add plan execution subcommand
5. Add status and info subcommands
6. Implement interactive mode
7. Add logging and output formatting
8. Write integration tests

## Detailed Requirements

### CLI Interface
```bash
# Create a new plan with auto-classification
tangentle-plan create "Add user authentication with OAuth"

# Create with explicit type
tangentle-plan create "Fix login crash" --type=debug

# Generate prompts for a plan
tangentle-plan prompts 004

# Execute next step
tangentle-plan next 004

# Check status
tangentle-plan status 004

# Verify current step
tangentle-plan verify 004

# Rollback current step
tangentle-plan rollback 004

# Review plan
tangentle-plan review 004

# Interactive mode
tangentle-plan interactive 004

# Show technique selection for a description
tangentle-plan classify "Implement binary search"

# List all plans
tangentle-plan list
```

### Architecture
```python
# .claude/scripts/tangentle_plan.py

import argparse
from problem_classifier import ProblemClassifier
from technique_selector import TechniqueSelector, Phase
from risk_assessor import RiskAssessor

class PlanOrchestrator:
    def __init__(self):
        self.classifier = ProblemClassifier()
        self.selector = TechniqueSelector()
        self.assessor = RiskAssessor()

    def create_plan(
        self,
        description: str,
        problem_type: str = None,
        confirm: bool = True
    ) -> PlanResult:
        """Create a new plan with intelligent technique selection."""
        # 1. Classify if not provided
        if not problem_type:
            classification = self.classifier.classify(description)
            if confirm:
                problem_type = self._confirm_classification(classification)
            else:
                problem_type = classification.primary_type

        # 2. Generate plan structure
        plan = self._generate_plan_structure(description, problem_type)

        # 3. For each step, select techniques and assess risk
        for step in plan.steps:
            step.techniques = {
                phase: self.selector.select_techniques(
                    step.problem_type,
                    phase
                )
                for phase in Phase
            }
            step.risk = self.assessor.assess_risk(step)

        # 4. Write plan files
        self._write_plan_files(plan)

        return plan

    def execute_next(self, plan_id: str) -> ExecutionResult:
        """Execute the next step with technique-aware prompts."""
        plan = self._load_plan(plan_id)
        step = self._get_current_step(plan)

        # Get the technique for implementation phase
        technique = step.techniques[Phase.IMPLEMENTATION]

        # Load and merge the technique prompt with step requirements
        prompt = self._merge_prompt(step, technique)

        # Execute (this will be done by Claude, we just prepare)
        return ExecutionResult(
            step=step,
            prompt=prompt,
            technique=technique,
            risk=step.risk
        )

def main():
    parser = argparse.ArgumentParser(
        description="Intelligent planning system for Claude Code"
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Create subcommand
    create_parser = subparsers.add_parser("create", help="Create a new plan")
    create_parser.add_argument("description", help="Feature description")
    create_parser.add_argument("--type", help="Explicit problem type")
    create_parser.add_argument("--no-confirm", action="store_true")

    # Prompts subcommand
    prompts_parser = subparsers.add_parser("prompts", help="Generate prompts")
    prompts_parser.add_argument("plan_id", help="Plan identifier")

    # Next subcommand
    next_parser = subparsers.add_parser("next", help="Execute next step")
    next_parser.add_argument("plan_id", help="Plan identifier")

    # Status subcommand
    status_parser = subparsers.add_parser("status", help="Show plan status")
    status_parser.add_argument("plan_id", help="Plan identifier")

    # Verify subcommand
    verify_parser = subparsers.add_parser("verify", help="Verify current step")
    verify_parser.add_argument("plan_id", help="Plan identifier")

    # Rollback subcommand
    rollback_parser = subparsers.add_parser("rollback", help="Rollback current step")
    rollback_parser.add_argument("plan_id", help="Plan identifier")

    # Review subcommand
    review_parser = subparsers.add_parser("review", help="Review plan")
    review_parser.add_argument("plan_id", help="Plan identifier")

    # Classify subcommand
    classify_parser = subparsers.add_parser("classify", help="Classify a description")
    classify_parser.add_argument("description", help="Problem description")

    # List subcommand
    subparsers.add_parser("list", help="List all plans")

    args = parser.parse_args()
    orchestrator = PlanOrchestrator()

    # Dispatch to appropriate handler
    if args.command == "create":
        result = orchestrator.create_plan(
            args.description,
            problem_type=args.type,
            confirm=not args.no_confirm
        )
        print(f"Created plan: {result.plan_id}")
    elif args.command == "classify":
        result = orchestrator.classifier.classify(args.description)
        print(f"Type: {result.primary_type}")
        print(f"Confidence: {result.confidence:.2f}")
        print(f"Reasoning: {result.reasoning}")
    # ... etc

if __name__ == "__main__":
    main()
```

### Output Formatting
```
╔════════════════════════════════════════════════════════════════╗
║  TANGENTLE PLAN: 004-intelligent-planning-system               ║
╠════════════════════════════════════════════════════════════════╣
║  Status: In Progress (Step 5/14)                               ║
║  Problem Type: infrastructure                                   ║
║  Risk Level: MEDIUM                                            ║
╠════════════════════════════════════════════════════════════════╣
║  Current Step: CLI Orchestrator                                ║
║  Technique: Least-to-Most (implementation)                     ║
║  Retry Budget: 5 attempts remaining                            ║
╚════════════════════════════════════════════════════════════════╝
```

## Files to Create
- `.claude/scripts/tangentle_plan.py`: Main CLI tool
- `.claude/scripts/test_tangentle_plan.py`: Integration tests
- `.claude/scripts/utils.py`: Shared utilities (if not exists)

## Files to Modify
- `.claude/scripts/__init__.py`: Export orchestrator

## Patterns to Follow
Reference: Standard Python argparse CLI patterns

## Acceptance Criteria
- [ ] All subcommands work correctly
- [ ] Classification with confirmation works
- [ ] Technique selection is integrated
- [ ] Risk assessment is integrated
- [ ] Output is formatted and readable
- [ ] Interactive mode works
- [ ] All tests pass

## Testing Requirements

### Integration Tests
- [ ] Test file: `.claude/scripts/test_tangentle_plan.py`
- [ ] Test cases:
  - `test_create_plan_auto_classification()`
  - `test_create_plan_explicit_type()`
  - `test_classify_returns_result()`
  - `test_status_shows_correct_info()`
  - `test_next_returns_prompt()`
  - `test_list_shows_all_plans()`

## Verification Commands
```bash
# Test CLI help
python3 .claude/scripts/tangentle_plan.py --help

# Test classify subcommand
python3 .claude/scripts/tangentle_plan.py classify "Fix the login bug"

# Test list subcommand
python3 .claude/scripts/tangentle_plan.py list

# Run integration tests
cd .claude/scripts && python3 -m pytest test_tangentle_plan.py -v
```

## Documentation Updates
- [ ] Add CLI usage to CLAUDE.md
- [ ] Create `.claude/scripts/README.md`

## Error Recovery
If CLI fails:
1. Check Python dependencies
2. Verify all component scripts exist
3. Check plan directory structure

## Do NOT
- Execute commands destructively without confirmation
- Ignore errors from component scripts
- Break compatibility with existing plan structure
