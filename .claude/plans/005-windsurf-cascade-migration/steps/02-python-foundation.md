# Step 2: Python Foundation Scripts

## Problem Type
`infrastructure`

## Technique Selection
- **Planning**: ps-plus - Structured approach for porting multiple scripts
- **Implementation**: least-to-most - Start with utils, build up to complex scripts
- **Verification**: self-refine - Iteratively test and fix each script

## Risk Level
**low** - Porting existing logic with unit tests; low risk of breaking changes

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Context
The Claude Code planning system uses Python scripts for problem classification, technique selection, and risk assessment. These scripts need to be ported to `.windsurf/scripts/` with adaptations for Windsurf's invocation patterns.

## Goal
Port the core Python scripts from `.claude/scripts/` to `.windsurf/scripts/`, adapting paths and interfaces as needed while preserving the classification/selection algorithms.

## Prerequisites
- Step 1 completed (directory structure exists)
- Python 3.8+ available in environment

## High-Level Steps
1. Port `utils.py` - shared utilities
2. Port `problem_classifier.py` - 33 problem type classification
3. Port `technique_selector.py` - phase-based technique selection
4. Port `risk_assessor.py` - risk level and retry budget calculation
5. Create `windsurf_plan.py` - CLI orchestrator for Windsurf
6. Create unit tests for each script
7. Verify all tests pass

## Detailed Requirements

### Scripts to Port

#### utils.py
- Adapt path handling for `.windsurf/` instead of `.claude/`
- Keep JSON formatting utilities
- Keep plan finding/listing logic

#### problem_classifier.py
- Keep all 33 problem types and 8 categories
- Keep keyword-based classification logic
- Keep confidence scoring algorithm
- Update any path references

#### technique_selector.py
- Keep all 10 technique definitions
- Keep phase-based selection (Planning, Implementation, Verification)
- Keep technique cost metadata
- Keep secondary technique selection

#### risk_assessor.py
- Keep risk level calculation (low/medium/high/critical)
- Keep retry budget configuration per risk level
- Keep risk factor detection (data migration, breaking changes, etc.)

#### windsurf_plan.py (new)
- CLI entry point for Windsurf workflows
- Subcommands: `classify`, `techniques`, `risk`, `status`, `list`
- Output formatted for workflow consumption

### Adaptations for Windsurf
1. All paths use `.windsurf/` instead of `.claude/`
2. Plan storage in `.windsurf/plans/{NNN}-{slug}/`
3. CLI outputs structured text for workflow parsing
4. Error messages include remediation hints

## Files to Create
- `.windsurf/scripts/utils.py`
- `.windsurf/scripts/problem_classifier.py`
- `.windsurf/scripts/technique_selector.py`
- `.windsurf/scripts/risk_assessor.py`
- `.windsurf/scripts/windsurf_plan.py`
- `.windsurf/scripts/__init__.py` (empty, for module discovery)
- `.windsurf/scripts/tests/__init__.py` (empty, for test discovery)
- `.windsurf/scripts/tests/test_problem_classifier.py`
- `.windsurf/scripts/tests/test_technique_selector.py`
- `.windsurf/scripts/tests/test_risk_assessor.py`
- `.windsurf/scripts/tests/test_utils.py`

## Files to Modify
None - all new files.

## Patterns to Follow
Reference: `.claude/scripts/problem_classifier.py` for classification logic
Reference: `.claude/scripts/technique_selector.py` for selection logic
Reference: `.claude/scripts/risk_assessor.py` for risk calculation

## Acceptance Criteria
- [ ] All 5 Python scripts created in `.windsurf/scripts/`
- [ ] All unit tests created in `.windsurf/scripts/tests/`
- [ ] `python3 -m unittest discover .windsurf/scripts/tests -v` passes
- [ ] `python3 .windsurf/scripts/windsurf_plan.py classify "fix bug"` outputs correct classification
- [ ] `python3 .windsurf/scripts/windsurf_plan.py techniques debug` outputs correct technique matrix
- [ ] `python3 .windsurf/scripts/windsurf_plan.py risk migration` outputs HIGH with 7 retries

## Testing Requirements

### Unit Tests
- [ ] Test file: `.windsurf/scripts/tests/test_problem_classifier.py`
  - `test_classify_debug_keywords()` - fix, bug, crash → debug
  - `test_classify_ui_keywords()` - add view, create screen → ui
  - `test_classify_confidence_scoring()` - verify confidence calculation
  - `test_classify_unknown_falls_to_default()` - unknown → new-feature

- [ ] Test file: `.windsurf/scripts/tests/test_technique_selector.py`
  - `test_select_debug_techniques()` - debug → react/reflexion/self-refine
  - `test_select_ui_techniques()` - ui → ps-plus/self-refine/manual
  - `test_select_all_phases()` - verify all 3 phases return techniques
  - `test_select_retry_budget()` - verify budget matches risk level

- [ ] Test file: `.windsurf/scripts/tests/test_risk_assessor.py`
  - `test_assess_migration_high_risk()` - migration → HIGH
  - `test_assess_documentation_low_risk()` - documentation → LOW
  - `test_assess_with_breaking_change()` - adds 0.2 to risk
  - `test_retry_config_matches_risk()` - verify retry budgets

- [ ] Test file: `.windsurf/scripts/tests/test_utils.py`
  - `test_find_plans()` - finds plans in .windsurf/plans/
  - `test_get_latest_plan()` - returns highest updatedAt
  - `test_format_json()` - verify JSON formatting

## Verification Commands
```bash
# Run all unit tests
cd .windsurf/scripts && python3 -m unittest discover tests -v

# Test CLI classification
python3 .windsurf/scripts/windsurf_plan.py classify "fix the login crash"

# Test CLI technique selection
python3 .windsurf/scripts/windsurf_plan.py techniques debug

# Test CLI risk assessment
python3 .windsurf/scripts/windsurf_plan.py risk migration

# Check for syntax errors in all scripts
python3 -m py_compile .windsurf/scripts/*.py
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check Python version: `python3 --version` (need 3.8+)
2. Check import errors: `python3 -c "import .windsurf.scripts.utils"`
3. Compare with Claude Code scripts if logic differs
4. Run individual tests to isolate failures

## Do NOT
- Use any external pip dependencies (standard library only)
- Change the classification/selection algorithms (port as-is)
- Create workflow files yet (those are later steps)
- Hard-code any project-specific paths or conventions
