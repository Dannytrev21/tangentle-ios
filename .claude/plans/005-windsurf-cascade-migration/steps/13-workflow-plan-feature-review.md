# Step 13: Workflow - /plan-feature-review

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Structure review methodology
- **Implementation**: tdd - Test review accuracy
- **Verification**: reflexion - Learn from review gaps

## Risk Level
**high** - Review quality affects plan quality

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 3 attempts
- Escalation: After 5 total failures

## Context
`/plan-feature-review` provides deep quality assessment of existing plans using full agentic reasoning (Tree of Thoughts + Graph of Thoughts). It identifies gaps, improves step quality, adjusts techniques, and writes detailed review logs.

## Goal
Create the `/plan-feature-review` workflow with full agentic reasoning across 6 quality dimensions.

## Prerequisites
- Step 7 completed (plans to review exist)
- Step 4 completed (technique knowledge for evaluation)

## High-Level Steps
1. Load plan and all artifacts
2. Apply Tree of Thoughts analysis per dimension
3. Apply Graph of Thoughts to merge findings
4. Score each dimension (1-10)
5. Generate improvement recommendations
6. Update plan artifacts if improvements found
7. Write review log
8. Update progress.json

## Detailed Requirements

### Review Dimensions

#### 1. Completeness (Weight: 20%)
- Are all requirements covered?
- Are edge cases addressed?
- Is error handling included?
- Are tests specified for all new code?

#### 2. Sequencing (Weight: 15%)
- Are dependencies correctly ordered?
- Can steps be parallelized?
- Are there circular dependencies?
- Is the critical path clear?

#### 3. Granularity (Weight: 20%)
- Are steps appropriately sized (30-90 min)?
- Are large steps decomposed?
- Are tiny steps consolidated?
- Is effort balanced across steps?

#### 4. Technical Quality (Weight: 20%)
- Do patterns match codebase conventions?
- Are best practices followed?
- Is architecture sound?
- Are security concerns addressed?

#### 5. Risk Assessment (Weight: 15%)
- Are high-risk steps identified?
- Are retry budgets appropriate?
- Is escalation defined?
- Are rollback plans clear?

#### 6. Technique Appropriateness (Weight: 10%)
- Does problem type match classification?
- Are techniques well-suited to step types?
- Are phase assignments correct?
- Are verification techniques adequate?

### Tree of Thoughts Analysis
For each dimension, explore:
```
Dimension: {name}
├── Branch 1: Current State
│   └── {assessment of current plan}
├── Branch 2: Ideal State
│   └── {what perfect would look like}
├── Branch 3: Gaps
│   └── {differences between current and ideal}
└── Branch 4: Improvements
    └── {specific actions to close gaps}
```

### Graph of Thoughts Merging
After all dimensions analyzed:
1. Identify cross-dimension conflicts
2. Prioritize improvements by impact
3. Merge related recommendations
4. Resolve technique conflicts
5. Produce unified improvement plan

### Scoring System
Each dimension scored 1-10:
- 1-3: Critical issues, needs major rework
- 4-5: Significant gaps, needs improvement
- 6-7: Acceptable, minor improvements possible
- 8-9: Good quality, minimal issues
- 10: Excellent, no improvements needed

Overall score = weighted average

### Review Output

```markdown
## Plan Review: {NNN} - {Plan Title}

### Review Date: {date}

### Executive Summary
**Overall Score**: {score}/10
**Recommendation**: {Approve / Revise / Rework}

### Dimension Scores
| Dimension | Score | Weight | Weighted |
|-----------|-------|--------|----------|
| Completeness | 8 | 20% | 1.6 |
| Sequencing | 7 | 15% | 1.05 |
| Granularity | 6 | 20% | 1.2 |
| Technical Quality | 8 | 20% | 1.6 |
| Risk Assessment | 7 | 15% | 1.05 |
| Technique Appropriateness | 9 | 10% | 0.9 |
| **Total** | | | **7.4** |

### Detailed Analysis

#### Completeness (8/10)
{Tree of Thoughts analysis}

#### Sequencing (7/10)
{Tree of Thoughts analysis}

{...other dimensions...}

### Cross-Dimension Findings (Graph of Thoughts)
{merged insights and conflicts}

### Improvement Recommendations
| Priority | Dimension | Issue | Recommendation |
|----------|-----------|-------|----------------|
| HIGH | Granularity | Step 5 too large | Split into 5a, 5b |
| MEDIUM | Risk | Step 3 underestimated | Increase to HIGH |
| LOW | Technique | Step 7 could use TDD | Change from self-refine |

### Changes Made
{list of changes applied to plan artifacts}

### Prompt Regeneration
{warning if technique changes require /plan-prompts rerun}
```

### Artifact Updates
If improvements identified:
1. Update `plan.md` with revised steps/techniques
2. Update `steps/*.md` with changes
3. Update `progress.json` with technique changes
4. Update `context.md` with review notes
5. Write `reviews/review-{date}.md`

### Prompt Regeneration Warning
If techniques changed:
```markdown
⚠️ **Technique Changes Detected**

The following steps have updated technique assignments:
- Step 3: self-refine → tdd
- Step 7: reflexion → self-consistency

Run `/plan-prompts {NNN}` to regenerate prompts with new techniques.
```

## Files to Create
- `.windsurf/workflows/plan-feature-review.md`

## Files to Modify
- Plan's `plan.md` (improvements)
- Plan's `steps/*.md` (step changes)
- Plan's `progress.json` (technique updates, updatedAt)
- Plan's `context.md` (review notes)
- Plan's `reviews/review-{date}.md` (new review log)

## Patterns to Follow
Reference: `.claude/commands/plan-feature-review.md` for structure

## Acceptance Criteria
- [ ] Workflow file under 12,000 characters
- [ ] Analyzes all 6 dimensions
- [ ] Applies Tree of Thoughts per dimension
- [ ] Applies Graph of Thoughts for merging
- [ ] Scores each dimension 1-10
- [ ] Generates prioritized recommendations
- [ ] Updates plan artifacts with improvements
- [ ] Writes review log to reviews/
- [ ] Warns about prompt regeneration when needed
- [ ] Updates progress.json timestamp

## Testing Requirements

### Unit Tests
**N/A** - Workflow tested via execution.

### Integration Tests
- [ ] Create plan with known issues
- [ ] Run `/plan-feature-review {plan}`
- [ ] Verify all 6 dimensions analyzed
- [ ] Verify scores generated
- [ ] Verify recommendations listed
- [ ] Verify review log created
- [ ] Verify plan artifacts updated

### Manual Verification
- [ ] ToT analysis is thorough
- [ ] GoT merging identifies conflicts
- [ ] Recommendations are actionable
- [ ] Prompt regen warning appears when needed

## Verification Commands
```bash
# Check review log created
ls -la .windsurf/plans/{NNN}-xxx/reviews/

# Check progress updated
python3 -c "
import json
with open('.windsurf/plans/{NNN}-xxx/progress.json') as f:
    print(f\"Updated: {json.load(f)['updatedAt']}\")
"

# Check for technique changes
grep "techniques" .windsurf/plans/{NNN}-xxx/progress.json
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check dimension analysis completeness
2. Verify scoring calculations
3. Check file write permissions
4. Validate JSON updates

## Do NOT
- Skip any dimension
- Apply changes without showing recommendations
- Forget prompt regeneration warning
- Use arbitrary scores (must be justified)
