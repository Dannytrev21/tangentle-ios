# Prompt: Step 3 - Update plan-feature Workflow

## Mission
Update the `/plan-feature` workflow to dynamically select between ToT and GoT reasoning techniques for plan creation while staying under 12K character limit.

## Context
You are implementing step 3 of 6 in the "Dynamic ToT/GoT Selection & Windsurf Rules Integration" plan.

**Plan Summary**: Enable dynamic selection between Tree of Thoughts (ToT) and Graph of Thoughts (GoT) reasoning techniques based on problem characteristics.

**This Step**: Updates the plan creation workflow to use the Python selector and include both ToT and GoT analysis sections for major decisions.

**Dependencies**:
- Requires: Step 1 (Python reasoning selector), Step 4 (Windsurf rules for content offload)
- Enables: Step 6 (integration testing)

## Pre-Implementation Checklist
Before making any changes, complete these steps:

### 1. Read Required Files
Read these files to understand existing patterns:

| File | Why | Focus On |
|------|-----|----------|
| `.windsurf/workflows/plan-feature.md` | File to modify | Current structure (7,960 chars) |
| `.windsurf/workflows/plan-feature-initial.md` | Pattern from Step 2 | Selection logic pattern |
| `.windsurf/rules/plan-conventions.md` | Content offloaded here | Risk levels, quality standards |

### 2. Verify Prerequisites
```bash
# Verify Step 1 complete (reasoning command exists)
python3 .windsurf/scripts/windsurf_plan.py reasoning debug LOGIC

# Verify Step 4 complete (rules exist)
ls -la .windsurf/rules/plan-conventions.md

# Check current character count
wc -c .windsurf/workflows/plan-feature.md
# Should be ~7,960 chars currently
```

### 3. Understand Current State
```bash
cat .windsurf/plans/001-dynamic-tot-got-selection/context.md
```

## Specification

### Goal
Modify plan-feature.md to:
1. Call Python selector after reading project context
2. Display selected technique with rationale
3. Modify Step 4 to have both ToT and GoT analysis sections
4. Reference rules for offloaded content
5. Stay under 12,000 characters total

### Requirements
1. Add "Step 3.5: Select Reasoning Technique" after reading context
2. Modify Step 4 to be technique-aware (ToT or GoT)
3. Add fallback to ToT if selector fails
4. Remove content that's now in plan-conventions.md rule
5. Preserve YAML frontmatter
6. Maintain artifact generation (plan.md, adr.md, steps/, etc.)

### Character Budget
| Component | Before | After | Delta |
|-----------|--------|-------|-------|
| Total | 7,960 | ~9,500 | +1,540 |
| Selection logic | 0 | +500 | +500 |
| GoT section | 0 | +1,200 | +1,200 |
| Offloaded content | ~1,000 | 0 | -1,000 |
| **Headroom** | 4,040 | ~2,500 | - |

## Implementation Guide

### Step-by-Step Instructions

1. **Read current workflow**
   ```bash
   cat .windsurf/workflows/plan-feature.md
   ```

2. **Add selection logic after Step 3 (Read Project Context)**
   Insert:
   ```markdown
   ### Step 3.5: Select Reasoning Technique

   Determine optimal technique for analyzing this feature:

   ```bash
   # Classify the feature
   python3 .windsurf/scripts/windsurf_plan.py classify "{feature description}"

   # Select reasoning technique
   python3 .windsurf/scripts/windsurf_plan.py reasoning {type} {category}
   ```

   Display:
   ```
   Feature Analysis Technique: {ToT|GoT}
   Rationale: {rationale}
   ```

   **Fallback**: If selector fails or returns error, default to ToT.
   ```

3. **Modify Step 4 to be technique-aware**
   Replace current Step 4 with:
   ```markdown
   ### Step 4: Apply Reasoning Technique

   #### If ToT Selected: Tree of Thought Analysis
   For each major decision, document:

   | Option | Description | Pros | Cons |
   |--------|-------------|------|------|
   | A | {approach} | {benefits} | {tradeoffs} |
   | B | {approach} | {benefits} | {tradeoffs} |
   | C | {approach} | {benefits} | {tradeoffs} |

   **Selected: Option {X}** - {Rationale}

   Consider at minimum:
   - Data storage approach
   - API design
   - UI/UX approach
   - Testing strategy

   #### If GoT Selected: Graph of Thoughts Synthesis
   For each major decision, use aggregation:

   **Initial Nodes**:
   - T1: Requirement analysis
   - T2: Technical constraints
   - T3: Existing patterns

   **Aggregation**:
   - T4: Merge T1 + T2 for feasible requirements
   - T5: Merge T4 + T3 for pattern-compliant approach

   **Refinement**:
   - T6: Final decision with rationale

   Consider at minimum:
   - How to integrate with existing patterns
   - How to synthesize requirements
   - How to aggregate test coverage
   ```

4. **Remove content now in rules**
   The following is now in `.windsurf/rules/plan-conventions.md`:
   - Risk Levels table
   - Error Recovery section (Plan Number Detection, Template Fill)

   Replace with:
   ```markdown
   See plan-conventions rule for risk levels and error recovery.
   ```

5. **Verify artifact generation preserved**
   Ensure these sections remain intact:
   - Step 7: Create Directory Structure
   - Step 8: Generate Artifacts (8.1-8.5)
   - Step 9: Update .gitignore
   - Step 10: Output Summary

6. **Verify character count**
   ```bash
   wc -c .windsurf/workflows/plan-feature.md
   # Must be < 12000
   ```

### Patterns to Follow
Follow Step 2 pattern for selection logic:
```markdown
### Step X.5: Select Reasoning Technique
...
**Fallback**: If selector fails or returns error, default to ToT.
```

Keep existing frontmatter:
```yaml
---
name: plan-feature
description: Create implementation plan for a feature with technique-aware step decomposition
---
```

## Acceptance Criteria
All must pass before marking complete:

- [ ] **AC1**: Workflow calls Python selector after reading context
  - Verify: `grep -n "windsurf_plan.py reasoning" .windsurf/workflows/plan-feature.md`

- [ ] **AC2**: Displays selected technique with rationale
  - Verify: `grep -n "Feature Analysis Technique:" .windsurf/workflows/plan-feature.md`

- [ ] **AC3**: Step 4 has both ToT and GoT sections
  - Verify: `grep -c "If ToT Selected\|If GoT Selected" .windsurf/workflows/plan-feature.md` (should be 2)

- [ ] **AC4**: Fallback to ToT documented
  - Verify: `grep -n "Fallback\|default to ToT" .windsurf/workflows/plan-feature.md`

- [ ] **AC5**: Artifact generation preserved (plan.md, adr.md, steps/, etc.)
  - Verify: `grep -c "plan.md\|adr.md\|steps/" .windsurf/workflows/plan-feature.md`

- [ ] **AC6**: Character count under 12K
  - Verify: `wc -c .windsurf/workflows/plan-feature.md` (must show < 12000)

- [ ] **AC7**: YAML frontmatter preserved
  - Verify: `head -5 .windsurf/workflows/plan-feature.md`

## Verification Protocol

### 1. Character Count Check
```bash
wc -c .windsurf/workflows/plan-feature.md
```
Expected: Less than 12000

### 2. Structure Check
```bash
grep -E "^### Step" .windsurf/workflows/plan-feature.md
```
Expected: Step 1-10 with Step 3.5 and Step 4 with technique sections

### 3. Artifact Generation Check
```bash
grep -c "8.1 plan.md\|8.2 adr.md\|8.3 Step Files\|8.4 progress.json\|8.5 context.md" .windsurf/workflows/plan-feature.md
```
Expected: 5 matches

### 4. Integration Test
```bash
# Test classifier
python3 .windsurf/scripts/windsurf_plan.py classify "Add user authentication"

# Test reasoning selector
python3 .windsurf/scripts/windsurf_plan.py reasoning service-impl ARCHITECTURE
```
Expected: Both commands succeed

## Error Recovery

### If Character Count Exceeds 12K
1. Trim verbose examples
2. Check if more content can reference rules
3. Consolidate similar instructions
4. Reduce artifact template verbosity (not functionality)

### If Artifact Generation Broken
1. Verify all 8.x sections remain
2. Check progress.json schema preserved
3. Ensure step file generation template intact

### If Syntax Errors
1. Check YAML frontmatter
2. Verify markdown code blocks closed
3. Check table formatting

## Completion Protocol

After ALL acceptance criteria pass:

### 1. Update Progress
Update `.windsurf/plans/001-dynamic-tot-got-selection/progress.json`:
```json
{
  "steps[2]": {
    "status": "completed",
    "completedAt": "{ISO date}",
    "verificationPassed": true,
    "notes": "Added ToT/GoT selection to plan-feature workflow"
  }
}
```

### 2. Update Context
Add to `.windsurf/plans/001-dynamic-tot-got-selection/context.md`:
```markdown
## Step 3 Complete - {date}

### What Was Done
- Added Step 3.5: Select Reasoning Technique
- Modified Step 4 with conditional ToT/GoT analysis
- Added fallback to ToT behavior
- Removed content offloaded to plan-conventions rule
- Final character count: {count}

### Files Modified
- `.windsurf/workflows/plan-feature.md`

### Key Decisions
- Selection happens after reading project context (Step 3)
- Artifact generation unchanged (Steps 7-10)
```

## Do NOT
- Do NOT exceed 12,000 characters
- Do NOT remove artifact generation logic (plan.md, adr.md, steps/, etc.)
- Do NOT change progress.json schema
- Do NOT break step file generation
- Do NOT hardcode technique selection

## Quality Checklist
Before marking complete, verify:
- [ ] Character count < 12,000
- [ ] Frontmatter intact
- [ ] Both ToT and GoT analysis sections
- [ ] Artifact generation works
- [ ] Selector command with correct path
- [ ] Fallback behavior documented
- [ ] progress.json updated
- [ ] context.md updated
