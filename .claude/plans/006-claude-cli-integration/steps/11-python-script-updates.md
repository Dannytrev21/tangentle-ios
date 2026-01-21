# Step 11: Thinking CLI Command & Integration

> **Scope Clarification**: Step 3 already implements thinking keywords (config, utils, TechniqueSelector). This step ONLY adds the CLI command and verifies full integration.

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Structured approach to code changes
- **Implementation**: tdd + self-refine - Write tests first, refine implementation
- **Verification**: reflexion - Learn from any test failures

## Risk Level
**medium** - Modifying core planning infrastructure code

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Reasoning Depth
**Think hard about** integration points and edge cases.

## Context
This step updates the Python scripts to support thinking keyword functionality. The thinking keyword utility created in Step 3 needs to be integrated into the technique selector and orchestrator.

## Goal
Update Python scripts to fully support thinking keyword selection based on risk level, with unit tests.

## Prerequisites
- Step 3 completed (thinking keyword config, utils, and TechniqueSelector methods exist)

## High-Level Steps
1. Verify Step 3 thinking keyword implementation exists
2. Update tangentle_plan.py CLI to add `thinking` command
3. Update cmd_techniques to show thinking keyword
4. Write integration tests for CLI command
5. Verify all tests pass (including Step 3 tests)

## Detailed Requirements

### Prerequisite Verification
First, verify Step 3 implementation exists:
```bash
# Verify thinking keywords in config
grep -A5 "thinkingKeywords" .claude/technique-config.json

# Verify utils.py has function
grep "get_thinking_keyword" .claude/scripts/utils.py

# Verify TechniqueSelector has method
grep "get_thinking_keyword" .claude/scripts/technique_selector.py
```

If any are missing, Step 3 is incomplete.

### tangentle_plan.py CLI Update
Update cmd_techniques to show thinking keyword:
```python
def cmd_techniques(args, orchestrator: PlanOrchestrator) -> int:
    """Handle techniques subcommand."""
    techniques = orchestrator.get_techniques(args.problem_type)

    # Get risk level for problem type
    risk_level = orchestrator.get_risk_for_type(args.problem_type)
    thinking_keyword = orchestrator.selector.get_thinking_keyword(risk_level)

    content = [
        f"Problem Type: {args.problem_type}",
        f"Thinking Keyword: {thinking_keyword}",
        "",
        # ... rest of existing content
    ]
```

Add new command for thinking keyword lookup:
```python
def cmd_thinking(args, orchestrator: PlanOrchestrator) -> int:
    """Handle thinking subcommand."""
    keyword = get_thinking_keyword(args.risk_level)
    description = get_thinking_keyword_description(keyword)

    content = [
        f"Risk Level: {args.risk_level}",
        f"Thinking Keyword: {keyword}",
        f"Description: {description}",
    ]

    print(format_box("THINKING KEYWORD", content))
    return 0
```

## Files to Create
- None (Step 3 created test file)

## Files to Modify
- `.claude/scripts/tangentle_plan.py`: Add thinking keyword CLI command only

## Patterns to Follow
Reference: Existing `technique_selector.py` patterns
Reference: Existing test patterns in `test_technique_selector.py`

## Acceptance Criteria
- [ ] Step 3 implementation verified complete
- [ ] CLI shows thinking keyword in `techniques` output
- [ ] New `thinking` CLI command works
- [ ] All unit tests pass (including Step 3 tests)
- [ ] CLI integration tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/scripts/test_thinking_keywords.py`
- [ ] Test cases:
  - `test_get_thinking_keyword_low()`
  - `test_get_thinking_keyword_medium()`
  - `test_get_thinking_keyword_high()`
  - `test_get_thinking_keyword_critical()`
  - `test_get_thinking_keyword_unknown_defaults()`
  - `test_get_thinking_keyword_case_insensitive()`
  - `test_format_reasoning_depth_section()`
  - `test_technique_selector_get_thinking_keyword()`

### What to Test
- All valid risk levels return correct keyword
- Unknown risk level returns default
- Case insensitivity
- Integration with TechniqueSelector
- CLI command output

## Verification Commands
```bash
# Run tests
cd .claude/scripts && python3 -m pytest test_thinking_keywords.py -v

# Or if added to existing test file
cd .claude/scripts && python3 -m pytest test_technique_selector.py -v -k thinking

# Test CLI command
cd /Users/dannytrevino/development/tangentle-ios && python3 .claude/scripts/tangentle_plan.py thinking low
cd /Users/dannytrevino/development/tangentle-ios && python3 .claude/scripts/tangentle_plan.py thinking high

# Test techniques output includes thinking
cd /Users/dannytrevino/development/tangentle-ios && python3 .claude/scripts/tangentle_plan.py techniques debug | grep -i thinking

# Verify config
python3 -c "import json; c=json.load(open('.claude/technique-config.json')); print(c.get('thinkingKeywords'))"
```

## Documentation Updates
- [ ] Update step notes in progress.json
- [ ] Update help text in tangentle_plan.py

## Error Recovery
If verification fails:
1. Check test output for specific failures
2. Verify JSON config is valid
3. Check function signatures
4. Re-run tests

## Do NOT
- Modify existing technique selection logic (only add to it)
- Change existing test behavior
- Skip unit tests
- Hardcode values instead of using config
