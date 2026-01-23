# Prompt: Step 1 - Python Reasoning Technique Selector

## Mission
Add `select_reasoning_technique()` function to technique_selector.py and create the `reasoning` CLI command in windsurf_plan.py.

## Context
You are implementing step 1 of 6 in the "Dynamic ToT/GoT Selection & Windsurf Rules Integration" plan.

**Plan Summary**: Enable dynamic selection between Tree of Thoughts (ToT) and Graph of Thoughts (GoT) reasoning techniques based on problem characteristics.

**This Step**: Creates the core Python function and CLI command that workflows will use to determine which reasoning technique to apply.

**Dependencies**:
- Requires: None (first step)
- Enables: Steps 2, 3, 6 (workflow updates and integration testing)

## Pre-Implementation Checklist
Before writing any code, complete these steps:

### 1. Read Required Files
Read these files to understand existing patterns:

| File | Why | Focus On |
|------|-----|----------|
| `.windsurf/scripts/technique_selector.py` | Existing module to extend | Lines 24-45: TechniqueSelection dataclass pattern |
| `.windsurf/scripts/windsurf_plan.py` | Add CLI command here | Lines 563-630: Existing subparser patterns |
| `.windsurf/scripts/tests/test_technique_selector.py` | Test patterns | All: unittest structure |

### 2. Verify Prerequisites
```bash
# Verify files exist
ls -la .windsurf/scripts/technique_selector.py
ls -la .windsurf/scripts/windsurf_plan.py
ls -la .windsurf/scripts/tests/test_technique_selector.py

# Check current CLI commands (reasoning should NOT exist yet)
python3 .windsurf/scripts/windsurf_plan.py --help
```

### 3. Understand Current State
```bash
cat .windsurf/plans/001-dynamic-tot-got-selection/context.md
cat .windsurf/plans/001-dynamic-tot-got-selection/progress.json | python3 -c "import json,sys; print(json.dumps(json.load(sys.stdin)['context'], indent=2))"
```

## Specification

### Goal
Add a function and CLI command to select between ToT and GoT reasoning techniques.

### Requirements
1. Create `ReasoningSelection` dataclass with fields: technique, rationale, characteristics_matched
2. Create `select_reasoning_technique()` function with signature:
   - Args: problem_type (str), category (str), characteristics (dict[str, bool] | None)
   - Returns: ReasoningSelection
3. Implement category defaults (TESTING/DOCUMENTATION → GoT, others → ToT)
4. Implement characteristic overrides (priority: requires_synthesis > exploration_needed > multiple_approaches > review_task > new_design)
5. Add `reasoning` CLI subcommand to windsurf_plan.py
6. Write unit tests for all selection criteria

### Code Structure
```
.windsurf/scripts/
├── technique_selector.py  # Add ReasoningSelection, select_reasoning_technique(), CATEGORY_DEFAULTS
├── windsurf_plan.py       # Add handle_reasoning(), add_parser("reasoning")
└── tests/
    └── test_technique_selector.py  # Add 10+ test cases
```

### API/Interface
```python
@dataclass
class ReasoningSelection:
    technique: str           # "tot" or "got"
    rationale: str           # Why this technique was selected
    characteristics_matched: list[str]  # Which characteristics influenced decision

def select_reasoning_technique(
    problem_type: str,
    category: str,
    characteristics: dict[str, bool] | None = None
) -> ReasoningSelection:
    """Select ToT or GoT based on problem characteristics."""

# Category defaults
CATEGORY_DEFAULTS = {
    "FOUNDATION": "tot", "DATA": "tot", "ARCHITECTURE": "tot",
    "UI_UX": "tot", "TESTING": "got", "LOGIC": "tot",
    "DOCUMENTATION": "got", "META": "tot"
}
```

## Implementation Guide

### Step-by-Step Instructions

1. **Add CATEGORY_DEFAULTS to technique_selector.py**
   - Add after RETRY_BUDGETS dict (around line 196)
   - 8 categories mapping to "tot" or "got"

2. **Add ReasoningSelection dataclass**
   - Add after TechniqueMetadata (around line 54)
   - 3 fields: technique, rationale, characteristics_matched

3. **Implement select_reasoning_technique() function**
   - Add as module-level function (after CATEGORY_DEFAULTS)
   - Handle characteristic overrides in priority order
   - Generate meaningful rationale strings
   - Return ReasoningSelection with matched characteristics

4. **Add handle_reasoning() to windsurf_plan.py**
   - Follow pattern of handle_classify() (around line 164)
   - Parse CLI flags into characteristics dict
   - Call select_reasoning_technique()
   - Print technique and rationale

5. **Add reasoning subparser in main()**
   - After existing subparsers (around line 620)
   - Add positional args: problem_type, category
   - Add optional flags: --synthesis, --exploration, --multiple, --review, --design

6. **Write unit tests**
   - Add to test_technique_selector.py
   - Test all 8 category defaults
   - Test all 5 characteristic overrides
   - Test edge cases (unknown category, conflicting characteristics)

### Patterns to Follow
From `technique_selector.py` (lines 37-45):
```python
@dataclass
class TechniqueSelection:
    """Result of technique selection for a phase."""
    primary: str
    secondary: list[str]
    prompt_template: str
    rationale: str
    estimated_cost: str
    retry_budget: int
```

Follow this dataclass pattern for ReasoningSelection.

From `windsurf_plan.py` (lines 566-569):
```python
p = subparsers.add_parser("classify", help="Classify a problem description")
p.add_argument("description", help="The problem description")
p.set_defaults(func=handle_classify)
```

Follow this subparser pattern for reasoning command.

### Edge Cases to Handle
- Unknown category: Default to "tot"
- No characteristics provided: Use category default
- Conflicting characteristics (e.g., both synthesis and exploration): First match wins (synthesis takes priority)
- Empty problem_type: Still works based on category

## Acceptance Criteria
All must pass before marking complete:

- [ ] **AC1**: `select_reasoning_technique()` function exists in technique_selector.py
  - Verify: `grep -n "def select_reasoning_technique" .windsurf/scripts/technique_selector.py`

- [ ] **AC2**: Function returns "tot" for ARCHITECTURE, DATA, LOGIC categories by default
  - Verify: `python3 -c "import sys; sys.path.insert(0,'.windsurf/scripts'); from technique_selector import select_reasoning_technique; print(select_reasoning_technique('test','ARCHITECTURE').technique)"`

- [ ] **AC3**: Function returns "got" for TESTING, DOCUMENTATION categories by default
  - Verify: `python3 -c "import sys; sys.path.insert(0,'.windsurf/scripts'); from technique_selector import select_reasoning_technique; print(select_reasoning_technique('test','TESTING').technique)"`

- [ ] **AC4**: Characteristic `requires_synthesis=True` overrides to "got"
  - Verify: `python3 -c "import sys; sys.path.insert(0,'.windsurf/scripts'); from technique_selector import select_reasoning_technique; print(select_reasoning_technique('test','ARCHITECTURE',{'requires_synthesis':True}).technique)"`

- [ ] **AC5**: CLI command `reasoning` exists and works
  - Verify: `python3 .windsurf/scripts/windsurf_plan.py reasoning debug LOGIC`

- [ ] **AC6**: All existing tests still pass
  - Verify: `python3 -m unittest .windsurf/scripts/tests/test_technique_selector.py -v`

- [ ] **AC7**: New tests cover all selection criteria (10+ test cases)
  - Verify: `grep -c "def test_" .windsurf/scripts/tests/test_technique_selector.py`

## Verification Protocol

### 1. Syntax Check
```bash
python3 -m py_compile .windsurf/scripts/technique_selector.py
python3 -m py_compile .windsurf/scripts/windsurf_plan.py
```
Expected: No output (success)

### 2. Unit Tests
```bash
python3 -m unittest .windsurf/scripts/tests/test_technique_selector.py -v
```
Expected: All tests pass

### 3. CLI Integration Check
```bash
# Test category defaults
python3 .windsurf/scripts/windsurf_plan.py reasoning debug LOGIC
python3 .windsurf/scripts/windsurf_plan.py reasoning unit-test TESTING
python3 .windsurf/scripts/windsurf_plan.py reasoning docs DOCUMENTATION

# Test characteristic overrides
python3 .windsurf/scripts/windsurf_plan.py reasoning refactor ARCHITECTURE --synthesis
python3 .windsurf/scripts/windsurf_plan.py reasoning docs DOCUMENTATION --exploration
```
Expected: LOGIC→tot, TESTING→got, DOCUMENTATION→got, --synthesis→got, --exploration→tot

### 4. Existing Tests Still Pass
```bash
python3 -m unittest discover -s .windsurf/scripts/tests -p 'test_*.py' -v 2>&1 | tail -5
```
Expected: No failures in existing tests

## Error Recovery

### If Syntax Check Fails
1. Read the error message for line number
2. Check for:
   - Missing imports (dataclass, etc.)
   - Typos in function/variable names
   - Unclosed parentheses or quotes
3. Fix and re-run

### If Tests Fail
1. Read test output to identify failing test
2. Check CATEGORY_DEFAULTS dict values
3. Verify characteristic override priority order
4. Ensure ReasoningSelection fields match test expectations
5. Fix implementation and re-run

### If CLI Fails
1. Check that handle_reasoning is connected to subparser
2. Verify argument names match what handle_reasoning expects
3. Check import of select_reasoning_technique in windsurf_plan.py
4. Ensure set_defaults(func=handle_reasoning) is called

## Completion Protocol

After ALL acceptance criteria pass:

### 1. Update Progress
Update `.windsurf/plans/001-dynamic-tot-got-selection/progress.json`:
```json
{
  "steps[0]": {
    "status": "completed",
    "completedAt": "{ISO date}",
    "verificationPassed": true,
    "testsPassed": true,
    "notes": "Added select_reasoning_technique() and reasoning CLI command"
  },
  "currentStep": 2,
  "status": "in_progress",
  "context.filesModified": [
    ".windsurf/scripts/technique_selector.py",
    ".windsurf/scripts/windsurf_plan.py",
    ".windsurf/scripts/tests/test_technique_selector.py"
  ]
}
```

### 2. Update Context
Add to `.windsurf/plans/001-dynamic-tot-got-selection/context.md`:
```markdown
## Step 1 Complete - {date}

### What Was Done
- Added ReasoningSelection dataclass to technique_selector.py
- Added CATEGORY_DEFAULTS dict with 8 category→technique mappings
- Implemented select_reasoning_technique() with characteristic override logic
- Added reasoning CLI subcommand to windsurf_plan.py
- Added 10+ unit tests for selection logic

### Files Modified
- `.windsurf/scripts/technique_selector.py`: Added ~60 lines
- `.windsurf/scripts/windsurf_plan.py`: Added ~40 lines
- `.windsurf/scripts/tests/test_technique_selector.py`: Added ~50 lines

### Key Decisions
- Characteristic priority: synthesis > exploration > multiple > review > design
- Unknown category defaults to "tot" (exploration is safer default)

### Learnings
{any insights from implementation}
```

### 3. Commit Changes (if requested)
```bash
git add .windsurf/scripts/technique_selector.py .windsurf/scripts/windsurf_plan.py .windsurf/scripts/tests/test_technique_selector.py
git commit -m "feat(planning): Add ToT/GoT reasoning technique selector

- Add select_reasoning_technique() function
- Add reasoning CLI command with characteristic flags
- Add unit tests for all selection criteria

Part of Plan 001: Dynamic ToT/GoT Selection"
```

## Do NOT
- Do NOT modify existing select_techniques() function behavior
- Do NOT change the Phase enum or existing technique mappings
- Do NOT add external pip dependencies
- Do NOT skip writing tests
- Do NOT forget to update progress.json when complete
- Do NOT leave print() debugging statements

## Quality Checklist
Before marking complete, verify:
- [ ] All acceptance criteria pass
- [ ] Code follows existing patterns in technique_selector.py
- [ ] No print() debugging statements left
- [ ] Rationale strings are meaningful and informative
- [ ] Tests cover both happy path and edge cases
- [ ] progress.json is updated
- [ ] context.md is updated
