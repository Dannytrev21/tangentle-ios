# Prompt: Step 5 - Update Knowledge Base

## Mission
Create a reasoning-selection.md guide in the knowledge base that documents when to use ToT vs GoT.

## Context
You are implementing step 5 of 6 in the "Dynamic ToT/GoT Selection & Windsurf Rules Integration" plan.

**Plan Summary**: Enable dynamic selection between Tree of Thoughts (ToT) and Graph of Thoughts (GoT) reasoning techniques based on problem characteristics.

**This Step**: Creates documentation that explains the selection criteria, provides a decision flowchart, and shows examples.

**Dependencies**:
- Requires: None (can run in parallel with Steps 2-3)
- Enables: Step 6 (integration testing references this)

## Pre-Implementation Checklist
Before creating any files, complete these steps:

### 1. Read Required Files
Read these files to understand existing patterns:

| File | Why | Focus On |
|------|-----|----------|
| `.windsurf/knowledge/techniques/tot.md` | Existing technique doc | Structure and formatting |
| `.windsurf/knowledge/techniques/got.md` | Existing technique doc | Structure and formatting |

### 2. Verify Prerequisites
```bash
# Verify knowledge directory exists
ls -la .windsurf/knowledge/techniques/

# Confirm tot.md and got.md exist
ls .windsurf/knowledge/techniques/tot.md .windsurf/knowledge/techniques/got.md
```

### 3. Understand Current State
```bash
cat .windsurf/plans/001-dynamic-tot-got-selection/context.md
```

## Specification

### Goal
Create `.windsurf/knowledge/techniques/reasoning-selection.md` that:
1. Documents ToT vs GoT selection criteria
2. Provides a decision flowchart
3. Shows category defaults and characteristic overrides
4. Includes examples for common problem types
5. References the Python selector

### Requirements
1. Follow similar structure to existing technique docs
2. Include decision flowchart in ASCII/markdown
3. Include at least 5 examples
4. Reference tot.md and got.md (don't duplicate their content)
5. Include CLI command usage examples

## Implementation Guide

### Step-by-Step Instructions

1. **Read existing technique docs for style**
   ```bash
   head -50 .windsurf/knowledge/techniques/tot.md
   head -50 .windsurf/knowledge/techniques/got.md
   ```

2. **Create reasoning-selection.md**
   Create `.windsurf/knowledge/techniques/reasoning-selection.md` with:

   ```markdown
   # Reasoning Technique Selection

   ## Overview
   The planning system uses two primary reasoning techniques:
   - **Tree of Thoughts (ToT)**: Exploration and decision-making
   - **Graph of Thoughts (GoT)**: Synthesis and aggregation

   This guide helps select the optimal technique for a given problem.

   ## Selection Criteria

   ### Use ToT When
   - Problem requires exploring multiple approaches
   - Making architecture or design decisions
   - Multiple valid solutions exist
   - Requirements are uncertain or evolving
   - The problem space needs exploration

   ### Use GoT When
   - Synthesizing information from multiple sources
   - Aggregating findings or feedback
   - Reviewing and verifying work
   - Merging perspectives into unified output
   - Task is about combination, not exploration

   ## Decision Flowchart

   ```
   Start
     │
     ▼
   Is this a synthesis/aggregation task?
     │
     ├── Yes ──▶ Use GoT
     │
     No
     │
     ▼
   Does it require exploring multiple approaches?
     │
     ├── Yes ──▶ Use ToT
     │
     No
     │
     ▼
   Is it a review/verification task?
     │
     ├── Yes ──▶ Use GoT
     │
     No
     │
     ▼
   Is it a new design decision?
     │
     ├── Yes ──▶ Use ToT
     │
     No
     │
     ▼
   Use category default
     │
     ├── TESTING, DOCUMENTATION ──▶ GoT
     │
     └── All others ──▶ ToT
   ```

   ## Category Defaults

   | Category | Default | Rationale |
   |----------|---------|-----------|
   | FOUNDATION | ToT | Infrastructure decisions need exploration |
   | DATA | ToT | Data models benefit from approach exploration |
   | ARCHITECTURE | ToT | Architecture requires evaluating alternatives |
   | UI_UX | ToT | UI decisions have multiple valid approaches |
   | TESTING | GoT | Tests verify and synthesize requirements |
   | LOGIC | ToT | Algorithms need exploration |
   | DOCUMENTATION | GoT | Docs synthesize and aggregate information |
   | META | ToT | Meta-decisions need exploration |

   ## Characteristic Overrides

   Characteristics can override category defaults:

   | Characteristic | Override To | Priority |
   |----------------|-------------|----------|
   | requires_synthesis | GoT | 1 (highest) |
   | exploration_needed | ToT | 2 |
   | multiple_approaches | ToT | 3 |
   | review_task | GoT | 4 |
   | new_design | ToT | 5 (lowest) |

   ## Examples

   ### Example 1: API Design (ToT)
   **Problem**: "Design a REST API for user management"
   **Category**: ARCHITECTURE
   **Selected**: ToT
   **Why**: Needs exploration of endpoints, authentication approaches, versioning

   ### Example 2: Test Coverage (GoT)
   **Problem**: "Review test coverage and identify gaps"
   **Category**: TESTING
   **Selected**: GoT
   **Why**: Aggregating findings from multiple test files, synthesizing recommendations

   ### Example 3: Documentation Update (GoT)
   **Problem**: "Update API documentation with new endpoints"
   **Category**: DOCUMENTATION
   **Selected**: GoT
   **Why**: Synthesizing existing docs with new endpoint information

   ### Example 4: Data Migration (ToT)
   **Problem**: "Migrate user data to new schema"
   **Category**: DATA
   **Selected**: ToT
   **Why**: Multiple migration approaches exist, need to evaluate tradeoffs

   ### Example 5: Code Review (GoT)
   **Problem**: "Review PR for code quality issues"
   **Category**: ARCHITECTURE (but review_task characteristic)
   **Selected**: GoT (override)
   **Why**: Review task overrides to GoT for synthesis

   ## Python Selector

   Use the CLI to get technique selection:

   ```bash
   # Basic usage
   python3 .windsurf/scripts/windsurf_plan.py reasoning {problem_type} {category}

   # Examples
   python3 .windsurf/scripts/windsurf_plan.py reasoning api-integration ARCHITECTURE
   # Output: tot (ToT: Category ARCHITECTURE defaults to exploration)

   python3 .windsurf/scripts/windsurf_plan.py reasoning unit-test TESTING
   # Output: got (GoT: Category TESTING defaults to synthesis)

   # With characteristic override
   python3 .windsurf/scripts/windsurf_plan.py reasoning refactor ARCHITECTURE --synthesis
   # Output: got (GoT: requires_synthesis characteristic matched)
   ```

   ## See Also
   - [Tree of Thoughts (tot.md)](tot.md)
   - [Graph of Thoughts (got.md)](got.md)
   - [Technique Selector Python Module](../../scripts/technique_selector.py)
   ```

3. **Verify file was created correctly**
   ```bash
   ls -la .windsurf/knowledge/techniques/reasoning-selection.md
   wc -l .windsurf/knowledge/techniques/reasoning-selection.md
   ```

## Acceptance Criteria
All must pass before marking complete:

- [ ] **AC1**: reasoning-selection.md exists in knowledge/techniques/
  - Verify: `ls .windsurf/knowledge/techniques/reasoning-selection.md`

- [ ] **AC2**: Contains selection criteria for ToT and GoT
  - Verify: `grep -c "Use ToT When\|Use GoT When" .windsurf/knowledge/techniques/reasoning-selection.md` (should be 2)

- [ ] **AC3**: Contains decision flowchart
  - Verify: `grep -c "Decision Flowchart" .windsurf/knowledge/techniques/reasoning-selection.md`

- [ ] **AC4**: Contains category defaults table
  - Verify: `grep -c "Category Defaults" .windsurf/knowledge/techniques/reasoning-selection.md`

- [ ] **AC5**: Contains characteristic overrides table
  - Verify: `grep -c "Characteristic Overrides" .windsurf/knowledge/techniques/reasoning-selection.md`

- [ ] **AC6**: Contains at least 5 examples
  - Verify: `grep -c "### Example" .windsurf/knowledge/techniques/reasoning-selection.md` (should be 5+)

- [ ] **AC7**: References Python selector with usage examples
  - Verify: `grep -c "windsurf_plan.py reasoning" .windsurf/knowledge/techniques/reasoning-selection.md` (should be 3+)

- [ ] **AC8**: Links to tot.md and got.md
  - Verify: `grep -c "tot.md\|got.md" .windsurf/knowledge/techniques/reasoning-selection.md` (should be 2+)

## Verification Protocol

### 1. File Existence Check
```bash
ls -la .windsurf/knowledge/techniques/reasoning-selection.md
```
Expected: File exists

### 2. Content Check
```bash
grep -E "^## " .windsurf/knowledge/techniques/reasoning-selection.md
```
Expected: Overview, Selection Criteria, Decision Flowchart, Category Defaults, Characteristic Overrides, Examples, Python Selector, See Also

### 3. Links Check
```bash
ls .windsurf/knowledge/techniques/tot.md .windsurf/knowledge/techniques/got.md
```
Expected: Both files exist (links will work)

### 4. Examples Check
```bash
grep "### Example" .windsurf/knowledge/techniques/reasoning-selection.md
```
Expected: 5 example headers

## Error Recovery

### If File Not Created
1. Check directory exists: `ls -la .windsurf/knowledge/techniques/`
2. Check write permissions
3. Try creating manually

### If Content Missing
1. Verify all sections are present
2. Check markdown formatting
3. Ensure code blocks are properly closed

## Completion Protocol

After ALL acceptance criteria pass:

### 1. Update Progress
Update `.windsurf/plans/001-dynamic-tot-got-selection/progress.json`:
```json
{
  "steps[4]": {
    "status": "completed",
    "completedAt": "{ISO date}",
    "verificationPassed": true,
    "notes": "Created reasoning-selection.md knowledge base doc"
  },
  "context.filesCreated": [
    ".windsurf/knowledge/techniques/reasoning-selection.md"
  ]
}
```

### 2. Update Context
Add to `.windsurf/plans/001-dynamic-tot-got-selection/context.md`:
```markdown
## Step 5 Complete - {date}

### What Was Done
- Created reasoning-selection.md with:
  - Selection criteria (ToT vs GoT)
  - ASCII decision flowchart
  - Category defaults table
  - Characteristic overrides table
  - 5 practical examples
  - Python selector usage

### Files Created
- `.windsurf/knowledge/techniques/reasoning-selection.md`

### Key Decisions
- Focused on selection, not technique details (those are in tot.md/got.md)
- Examples cover common scenarios
```

## Do NOT
- Do NOT duplicate content from tot.md or got.md (reference instead)
- Do NOT make this file too long (keep focused on selection)
- Do NOT add code that should be in Python module
- Do NOT forget to link to related docs

## Quality Checklist
Before marking complete, verify:
- [ ] File exists in correct location
- [ ] All required sections present
- [ ] Decision flowchart readable
- [ ] 5+ examples included
- [ ] Links to tot.md and got.md
- [ ] CLI examples correct
- [ ] progress.json updated
- [ ] context.md updated
