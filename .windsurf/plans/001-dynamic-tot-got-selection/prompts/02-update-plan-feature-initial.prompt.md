# Prompt: Step 2 - Update plan-feature-initial Workflow

## Mission
Update the `/plan-feature-initial` workflow to dynamically select between ToT and GoT reasoning techniques while staying under 12K character limit.

## Context
You are implementing step 2 of 6 in the "Dynamic ToT/GoT Selection & Windsurf Rules Integration" plan.

**Plan Summary**: Enable dynamic selection between Tree of Thoughts (ToT) and Graph of Thoughts (GoT) reasoning techniques based on problem characteristics.

**This Step**: Updates the requirements gathering workflow to use the Python selector and include both ToT and GoT analysis sections.

**Dependencies**:
- Requires: Step 1 (Python reasoning selector), Step 4 (Windsurf rules for content offload)
- Enables: Step 6 (integration testing)

## Pre-Implementation Checklist
Before making any changes, complete these steps:

### 1. Read Required Files
Read these files to understand existing patterns:

| File | Why | Focus On |
|------|-----|----------|
| `.windsurf/workflows/plan-feature-initial.md` | File to modify | Current structure and character count |
| `.windsurf/rules/plan-conventions.md` | Content offloaded here | What's available in rules |
| `.windsurf/workflows/plan-feature.md` | Pattern reference | Workflow structure |

### 2. Verify Prerequisites
```bash
# Verify Step 1 complete (reasoning command exists)
python3 .windsurf/scripts/windsurf_plan.py reasoning debug LOGIC

# Verify Step 4 complete (rules exist)
ls -la .windsurf/rules/plan-conventions.md

# Check current character count
wc -c .windsurf/workflows/plan-feature-initial.md
# Should be ~6,709 chars currently
```

### 3. Understand Current State
```bash
cat .windsurf/plans/001-dynamic-tot-got-selection/context.md
cat .windsurf/plans/001-dynamic-tot-got-selection/progress.json | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'Current step: {d[\"currentStep\"]}, Status: {d[\"status\"]}')"
```

## Specification

### Goal
Modify plan-feature-initial.md to:
1. Call Python selector after problem classification
2. Display selected technique (ToT or GoT) with rationale
3. Include both ToT analysis section (existing) and GoT synthesis section (new)
4. Reference rules for offloaded content
5. Stay under 12,000 characters total

### Requirements
1. Add "Step 1.5: Select Reasoning Technique" after classification
2. Keep existing Tree of Thought Analysis (5 branches) for ToT selection
3. Add new Graph of Thoughts Synthesis section for GoT selection
4. Add fallback to ToT if selector fails
5. Remove content that's now in plan-conventions.md rule
6. Preserve YAML frontmatter
7. Maintain output format compatibility with /plan-feature

### Character Budget
| Component | Before | After | Delta |
|-----------|--------|-------|-------|
| Total | 6,709 | ~8,500 | +1,791 |
| Selection logic | 0 | +1,200 | +1,200 |
| GoT section | 0 | +800 | +800 |
| Offloaded content | ~1,200 | 0 | -1,200 |
| **Headroom** | 5,291 | ~3,500 | - |

## Implementation Guide

### Step-by-Step Instructions

1. **Read current workflow**
   ```bash
   cat .windsurf/workflows/plan-feature-initial.md
   ```

2. **Add selection logic after Step 1**
   Insert after Problem Classification step:
   ```markdown
   ### Step 1.5: Select Reasoning Technique

   Based on classification, select the optimal reasoning technique:

   ```bash
   python3 .windsurf/scripts/windsurf_plan.py reasoning {problem_type} {category}
   ```

   Display selection:
   ```
   Reasoning Technique: {ToT|GoT}
   Rationale: {rationale from selector}
   ```

   **Fallback**: If selector fails or returns error, default to ToT.

   - If ToT selected → Use Tree of Thought Analysis (Step 2)
   - If GoT selected → Use Graph of Thoughts Synthesis (Step 2-GoT)
   ```

3. **Keep existing ToT section, mark as conditional**
   - Rename "Step 2: Tree of Thought Analysis" to "Step 2 (ToT): Tree of Thought Analysis"
   - Add note: "Use this section when ToT is selected"

4. **Add GoT section after ToT**
   ```markdown
   ### Step 2 (GoT): Graph of Thoughts Synthesis

   Analyze using aggregation approach:

   #### Initial Nodes
   Create thought nodes for:
   - T1: Functional requirements
   - T2: Technical constraints
   - T3: User experience needs
   - T4: Integration points

   #### Aggregation
   Merge compatible nodes:
   - T5: Combined requirements (T1 + T2)
   - T6: User-technical balance (T3 + T4)

   #### Synthesis
   - T7: Final specification (T5 + T6)

   For each node, categorize:
   - **Explicit**: Clearly stated by user
   - **Implicit**: Inferred from context
   - **Missing**: Gaps to fill
   ```

5. **Remove content now in rules**
   The following content is now in `.windsurf/rules/plan-conventions.md`:
   - Question Categories section (Scope, UX, Data, Technical, etc.)
   - Quality Standards section

   Replace with brief reference:
   ```markdown
   See plan-conventions rule for question categories and quality standards.
   ```

6. **Verify character count**
   ```bash
   wc -c .windsurf/workflows/plan-feature-initial.md
   # Must be < 12000
   ```

### Patterns to Follow
Keep existing frontmatter format:
```yaml
---
name: plan-feature-initial
description: Requirements analysis for new features with AI-based problem classification
---
```

### Edge Cases to Handle
- Selector command fails: Default to ToT
- Unknown problem type: Still works (selector handles it)
- User cancels mid-workflow: Normal abort behavior preserved

## Acceptance Criteria
All must pass before marking complete:

- [ ] **AC1**: Workflow calls Python selector after classification
  - Verify: `grep -n "windsurf_plan.py reasoning" .windsurf/workflows/plan-feature-initial.md`

- [ ] **AC2**: Displays selected technique with rationale
  - Verify: `grep -n "Reasoning Technique:" .windsurf/workflows/plan-feature-initial.md`

- [ ] **AC3**: ToT analysis section retained and marked conditional
  - Verify: `grep -n "Step 2 (ToT)" .windsurf/workflows/plan-feature-initial.md`

- [ ] **AC4**: GoT synthesis section added
  - Verify: `grep -n "Step 2 (GoT)" .windsurf/workflows/plan-feature-initial.md`

- [ ] **AC5**: Fallback to ToT documented
  - Verify: `grep -n "Fallback\|default to ToT" .windsurf/workflows/plan-feature-initial.md`

- [ ] **AC6**: Character count under 12K
  - Verify: `wc -c .windsurf/workflows/plan-feature-initial.md` (must show < 12000)

- [ ] **AC7**: YAML frontmatter preserved
  - Verify: `head -5 .windsurf/workflows/plan-feature-initial.md`

- [ ] **AC8**: Output format still produces valid /plan-feature input
  - Verify: Manual inspection of output structure

## Verification Protocol

### 1. Character Count Check
```bash
wc -c .windsurf/workflows/plan-feature-initial.md
```
Expected: Less than 12000

### 2. Structure Check
```bash
grep -E "^### Step" .windsurf/workflows/plan-feature-initial.md
```
Expected: Step 1, Step 1.5, Step 2 (ToT), Step 2 (GoT), Step 3, etc.

### 3. Frontmatter Check
```bash
head -5 .windsurf/workflows/plan-feature-initial.md
```
Expected: Valid YAML frontmatter with --- delimiters

### 4. Selection Logic Check
```bash
grep -c "ToT\|GoT" .windsurf/workflows/plan-feature-initial.md
```
Expected: Multiple matches (both sections present)

### 5. Integration Test
```bash
# Test classifier still works
python3 .windsurf/scripts/windsurf_plan.py classify "Add REST API"

# Test reasoning selector
python3 .windsurf/scripts/windsurf_plan.py reasoning api-integration ARCHITECTURE
```
Expected: Both commands succeed

## Error Recovery

### If Character Count Exceeds 12K
1. Identify verbose sections to trim
2. Check if more content can be offloaded to rules
3. Reduce example verbosity
4. Consider consolidating similar instructions

### If Syntax Check Fails
1. Check YAML frontmatter has matching `---` delimiters
2. Verify markdown code blocks are properly closed
3. Check for unescaped special characters

### If Integration Fails
1. Verify selector command path is correct
2. Check that Step 1 was completed successfully
3. Run selector manually to confirm it works

## Completion Protocol

After ALL acceptance criteria pass:

### 1. Update Progress
Update `.windsurf/plans/001-dynamic-tot-got-selection/progress.json`:
```json
{
  "steps[1]": {
    "status": "completed",
    "completedAt": "{ISO date}",
    "verificationPassed": true,
    "notes": "Added ToT/GoT selection to plan-feature-initial workflow"
  }
}
```

### 2. Update Context
Add to `.windsurf/plans/001-dynamic-tot-got-selection/context.md`:
```markdown
## Step 2 Complete - {date}

### What Was Done
- Added Step 1.5: Select Reasoning Technique
- Added conditional ToT/GoT analysis sections
- Added fallback to ToT behavior
- Removed content offloaded to plan-conventions rule
- Final character count: {count}

### Files Modified
- `.windsurf/workflows/plan-feature-initial.md`

### Key Decisions
- Fallback defaults to ToT (exploration is safer)
- Both analysis sections included (workflow chooses at runtime)
```

## Do NOT
- Do NOT exceed 12,000 characters
- Do NOT remove YAML frontmatter
- Do NOT change the output format (must still produce /plan-feature input)
- Do NOT hardcode technique selection (must use Python selector)
- Do NOT remove the ToT section entirely (keep for ToT selection)

## Quality Checklist
Before marking complete, verify:
- [ ] Character count < 12,000
- [ ] Frontmatter intact
- [ ] Both ToT and GoT sections present
- [ ] Selector command with correct path
- [ ] Fallback behavior documented
- [ ] Output format unchanged
- [ ] progress.json updated
- [ ] context.md updated
