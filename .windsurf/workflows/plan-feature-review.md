---
name: plan-feature-review
description: Review plan quality with agentic reasoning across 6 dimensions
---

# Plan Feature Review

Review and improve plan quality using Tree of Thoughts per dimension and Graph of Thoughts for synthesis.

## Instructions

### Step 1: Load Plan Artifacts

```bash
PLAN_DIR=$(ls -d .windsurf/plans/$ARGS* 2>/dev/null | head -1)
```

Read all plan files:
- `$PLAN_DIR/plan.md`
- `$PLAN_DIR/adr.md`
- `$PLAN_DIR/progress.json`
- `$PLAN_DIR/context.md`
- `$PLAN_DIR/steps/*.md` (all step files)

Also read project context (CLAUDE.md or similar) for conventions.

### Step 2: Tree of Thoughts Analysis

For each of 6 dimensions, create 4-branch analysis:

```
Dimension: {name}
├── Branch 1: Current State
│   └── {What exists in the plan}
├── Branch 2: Ideal State
│   └── {What best practice looks like}
├── Branch 3: Gaps
│   └── {Delta between current and ideal}
└── Branch 4: Improvements
    └── {Specific actions to close gaps}
```

#### The 6 Review Dimensions

| Dimension | Weight | What to Evaluate |
|-----------|--------|------------------|
| Completeness | 20% | Coverage, edge cases, error handling, tests |
| Sequencing | 15% | Dependencies, order, parallelization |
| Granularity | 20% | Step sizes (30-90min target), decomposition |
| Technical Quality | 20% | Patterns, best practices, architecture |
| Risk Assessment | 15% | Risk identification, retry budgets, rollback |
| Technique Fit | 10% | Problem type accuracy, technique selection |

#### ToT Analysis Template

For each dimension:
```markdown
### {Dimension} (Weight: {X}%)

**Current State**: {What the plan has}

**Ideal State**: {What excellence looks like}

**Gaps**:
- {gap 1}
- {gap 2}

**Improvements**:
- {specific action 1}
- {specific action 2}

**Evaluation**:
- Feasibility: {sure/maybe}
- Severity: {critical/important/minor}

**Score**: {1-10}/10
```

### Step 3: Score Each Dimension

After ToT analysis, assign scores:

| Score | Meaning |
|-------|---------|
| 1-3 | Critical issues, major rework needed |
| 4-5 | Significant gaps, needs improvement |
| 6-7 | Acceptable, minor improvements possible |
| 8-9 | Good quality, minimal issues |
| 10 | Excellent, no improvements needed |

Calculate weighted average:
```
overall = (completeness × 0.20) + (sequencing × 0.15) +
          (granularity × 0.20) + (technical × 0.20) +
          (risk × 0.15) + (technique × 0.10)
```

### Step 4: Graph of Thoughts Merging

Combine dimension findings using GoT:

#### 4a. Create Thought Nodes
For each dimension finding that scored < 8:
```
T{N}: {Dimension} - {Issue}
  Score: {X}/10
  Connections: → related findings
```

#### 4b. Apply Transformations

**Aggregation** - Merge related findings:
```
T{X} + T{Y} → T{Z}
  Combined insight: {synthesized recommendation}
  Score: {higher than individual}
```

**Conflict Resolution** - When recommendations conflict:
```
Conflict: T{A} vs T{B}
  T{A}: {recommendation 1}
  T{B}: {recommendation 2}
  Resolution: {which wins and why}
```

#### 4c. Prioritize by Impact

| Priority | Criteria |
|----------|----------|
| HIGH | Blocks progress, affects multiple steps |
| MEDIUM | Improves quality, single step impact |
| LOW | Nice to have, minimal impact |

### Step 5: Generate Recommendations

Output prioritized improvement list:

```markdown
### Improvement Recommendations

| Priority | Dimension | Issue | Recommendation |
|----------|-----------|-------|----------------|
| HIGH | {dim} | {issue} | {action} |
| MEDIUM | {dim} | {issue} | {action} |
| LOW | {dim} | {issue} | {action} |
```

Group by action type:
- **Steps to Add**: New steps needed
- **Steps to Remove**: Unnecessary steps
- **Steps to Split**: Too large (>90 min)
- **Steps to Merge**: Too small
- **Steps to Reorder**: Wrong sequence
- **Steps to Enhance**: Missing details
- **Techniques to Adjust**: Wrong technique fit

### Step 6: User Confirmation

Before applying changes:

```
═══════════════════════════════════════
  REVIEW COMPLETE: Plan {NNN}
═══════════════════════════════════════

Overall Score: {X.X}/10

Dimension Scores:
| Dimension | Score | Weight | Weighted |
|-----------|-------|--------|----------|
{...rows...}

Proposed Changes:
- {N} steps to add
- {N} steps to modify
- {N} technique changes

Apply changes? (yes / no / selective)
═══════════════════════════════════════
```

If **selective**: Show each change for individual approval.

### Step 7: Apply Changes

If approved:

#### 7a. Update Plan Files
- `plan.md`: Revise step table, add revision history
- `adr.md`: Add/revise decisions
- `steps/*.md`: Create/update/renumber step files
- `progress.json`: Update steps array, totalSteps

#### 7b. Update Technique Assignments
For technique changes:
1. Update `steps[N].techniques` in progress.json
2. Set `steps[N].promptGenerated = false`

#### 7c. Update Context
Add to context.md:
```markdown
## Review Applied - {date}
- Overall score: {X}/10
- Changes: {summary}
- Techniques adjusted: {N} steps
```

### Step 8: Write Review Log

Create `$PLAN_DIR/reviews/review-{date}.md`:

```bash
mkdir -p $PLAN_DIR/reviews
```

```markdown
# Plan Review: {date}

## Overall Assessment
- **Score**: {X.X}/10
- **Recommendation**: Approve / Revise / Rework

## Dimension Scores
| Dimension | Score | Key Findings |
|-----------|-------|--------------|
{...rows...}

## Tree of Thoughts Analysis
{Summary of ToT findings per dimension}

## Graph of Thoughts Synthesis
{How findings were merged and prioritized}

## Changes Applied
{List of all changes made}

## Remaining Concerns
{Issues that couldn't be addressed}
```

### Step 9: Prompt Regeneration Warning

If techniques changed:

```
═══════════════════════════════════════
  ⚠️ TECHNIQUE CHANGES DETECTED
═══════════════════════════════════════

Steps with new techniques:
- Step {N}: {old} → {new}
- Step {M}: {old} → {new}

Run `/plan-prompts {NNN}` to regenerate affected prompts.
═══════════════════════════════════════
```

### Step 10: Output Summary

```
═══════════════════════════════════════
  ✅ PLAN REVIEW COMPLETE
═══════════════════════════════════════

## Plan: {NNN} - {Title}

### Scores
| Dimension | Score |
|-----------|-------|
| Completeness | {N}/10 |
| Sequencing | {N}/10 |
| Granularity | {N}/10 |
| Technical | {N}/10 |
| Risk | {N}/10 |
| Technique | {N}/10 |
| **Overall** | **{X.X}/10** |

### Changes Applied
- Steps added: {N}
- Steps modified: {N}
- Steps removed: {N}
- Techniques adjusted: {N}

### Review Log
Saved: reviews/review-{date}.md

### Next Commands
- `/plan-prompts {NNN}` - Regenerate prompts (if techniques changed)
- `/plan-status {NNN}` - View updated status
- `/plan-next {NNN}` - Begin implementation
═══════════════════════════════════════
```

## Technique Selection Guidelines

For evaluating Technique Fit dimension:

| Problem Type | Good Planning | Good Implementation | Good Verification |
|--------------|---------------|---------------------|-------------------|
| infrastructure | ps-plus | least-to-most | self-refine |
| migration | least-to-most | chain-of-code | reflexion |
| service-impl | ps-plus | tdd | reflexion |
| ui | ps-plus | self-refine | got |
| documentation | ps-plus | self-refine | got |
| debug | react | reflexion | self-refine |

## Do NOT

- Do NOT skip any dimension in ToT analysis
- Do NOT apply changes without user confirmation
- Do NOT forget prompt regeneration warning
- Do NOT use arbitrary scores (justify with ToT)
- Do NOT exceed 12,000 character limit
