# Step 12: Update plan-feature-review

## Context
The `/plan-feature-review` command critiques plans for quality. Per user requirements, the review should also validate technique selections.

## Goal
Update the `/plan-feature-review` command to review both plan quality AND technique selection appropriateness.

## Problem Type
`refactor`

## Technique Selection
- **Planning**: ToT (explore multiple review dimensions)
- **Implementation**: Self-Refine (iterate on review quality)
- **Verification**: GoT (aggregate review findings)

## Risk Level
**Medium** - Review quality affects plan quality

## Prerequisites
- Steps 1-7 completed (plans have technique metadata)

## High-Level Steps
1. Analyze current plan-feature-review.md
2. Add technique review dimension
3. Create technique appropriateness criteria
4. Implement technique change suggestions
5. Update review scoring
6. Test with various plans

## Detailed Requirements

### Current Review Dimensions
1. Completeness
2. Sequencing & Dependencies
3. Granularity
4. Technical Quality
5. Risk & Robustness

### New Review Dimensions
1. Completeness
2. Sequencing & Dependencies
3. Granularity
4. Technical Quality
5. Risk & Robustness
6. **NEW: Technique Appropriateness**

### Changes to plan-feature-review.md

#### New Dimension: Technique Appropriateness

```markdown
### Branch 6: TECHNIQUE APPROPRIATENESS (NEW)

Evaluate the technique selections for each step:

\`\`\`
┌─────────────────────────────────────────────────────────────────┐
│  Branch 6: TECHNIQUE APPROPRIATENESS                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  6.1 Problem Type Alignment                                     │
│  ├── Does the classified problem type fit the step?            │
│  ├── Would a different type be more accurate?                  │
│  └── Are subtypes used when appropriate?                       │
│                                                                  │
│  6.2 Technique Selection Quality                                │
│  ├── Is the planning technique appropriate?                    │
│  ├── Is the implementation technique appropriate?              │
│  ├── Is the verification technique appropriate?                │
│  └── Are expensive techniques justified by risk?               │
│                                                                  │
│  6.3 Technique Composition                                      │
│  ├── Do multi-technique steps make sense?                      │
│  ├── Is there technique redundancy?                            │
│  └── Are techniques compatible with each other?                │
│                                                                  │
│  6.4 Risk-Technique Alignment                                   │
│  ├── Do high-risk steps have appropriate retry budgets?        │
│  ├── Are low-risk steps over-engineered?                       │
│  └── Is Reflexion used for genuinely risky steps?              │
│                                                                  │
│  6.5 Technique Coverage                                         │
│  ├── Are any steps missing technique assignments?              │
│  ├── Are default techniques overused?                          │
│  └── Is there variety where appropriate?                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
\`\`\`
```

#### Technique Review Scoring

```markdown
### Technique Appropriateness Scoring

| Criterion | Weight | Scoring Guide |
|-----------|--------|---------------|
| Problem type accuracy | 20% | Correct=10, Close=7, Wrong=3 |
| Planning technique fit | 15% | Optimal=10, Reasonable=7, Poor=4 |
| Implementation technique fit | 25% | Optimal=10, Reasonable=7, Poor=4 |
| Verification technique fit | 15% | Optimal=10, Reasonable=7, Poor=4 |
| Risk alignment | 15% | Matched=10, Over-eng=6, Under-eng=3 |
| Composition quality | 10% | Clean=10, Redundant=5, Conflicting=2 |

**Score Interpretation**:
- 9-10: Excellent technique selection
- 7-8: Good, minor improvements possible
- 5-6: Adequate, some misalignments
- 3-4: Poor, significant issues
- 1-2: Critical, complete mismatch
```

#### Technique Review Findings Format

```markdown
### 6. Technique Appropriateness: {score}/10

| Step | Issue | Severity | Recommendation |
|------|-------|----------|----------------|
| 3 | ToT overkill for simple config | 🟡 | Use PS+ instead |
| 5 | No Reflexion for data migration | 🔴 | Add Reflexion verification |
| 8 | TDD + Self-Refine redundant | 🟢 | Consider just TDD |

#### Technique Changes Recommended

**Steps to Adjust Techniques**:
| Step | Current | Recommended | Phase | Reason |
|------|---------|-------------|-------|--------|
| 3 | ToT | PS+ | Planning | Over-complex for config task |
| 5 | Self-Refine | Reflexion | Verification | Data migration needs retry |

**Overall Assessment**:
- {X}% of steps have optimal technique selection
- {Y}% have reasonable but improvable selection
- {Z}% have problematic selection (need change)
```

#### Apply Technique Changes

```markdown
### Step 5: Apply Changes (UPDATED)

When applying technique changes:

1. **Update step files**
   - Replace technique sections
   - Update technique rationale

2. **Update progress.json**
   - Change technique assignments
   - Reset technique state for affected steps

3. **Regenerate prompts**
   \`\`\`
   ⚠️ Technique changes detected in {N} steps.
   Run \`/plan-prompts {NNN}\` to regenerate affected prompts.
   \`\`\`
```

#### Updated Review Summary

```markdown
### Step 7: Output Summary (UPDATED)

\`\`\`markdown
## Plan Review Complete: {NNN}-{slug}

### Scores (Before → After)
| Dimension | Before | After |
|-----------|--------|-------|
| Completeness | {X} | {Y} |
| Sequencing | {X} | {Y} |
| Granularity | {X} | {Y} |
| Technical | {X} | {Y} |
| Robustness | {X} | {Y} |
| **Technique** | **{X}** | **{Y}** |
| **Total** | **{X}/60** | **{Y}/60** |

### Technique Changes Applied
- Steps with technique updates: {N}
- Problem type corrections: {N}
- Risk level adjustments: {N}

### Critical Technique Issues Fixed
{list of 🔴 items}

### Next Commands
1. \`/plan-prompts {NNN}\` - **REQUIRED** if techniques changed
2. \`/plan-status {NNN}\` - View updated plan
3. \`/plan-next {NNN}\` - Begin implementation
\`\`\`
```

## Files to Create
- None (modifying existing)

## Files to Modify
- `.claude/commands/plan-feature-review.md`: Add technique review dimension

## Patterns to Follow
Reference: Current plan-feature-review.md structure (lines 1-357)

## Acceptance Criteria
- [ ] Technique appropriateness is reviewed
- [ ] Scoring includes technique dimension
- [ ] Technique changes can be recommended
- [ ] Prompt regeneration prompted when needed
- [ ] Review log includes technique changes

## Testing Requirements

### Manual Testing
- [ ] Review plan with good technique selection
- [ ] Review plan with poor technique selection
- [ ] Verify technique changes are applied

## Verification Commands
```bash
# Check technique dimension added
grep -q "TECHNIQUE APPROPRIATENESS" .claude/commands/plan-feature-review.md

# Check scoring updated
grep -q "Total.*60" .claude/commands/plan-feature-review.md
```

## Documentation Updates
- [ ] Update review docs in CLAUDE.md

## Error Recovery
If technique review fails:
1. Skip technique dimension
2. Review other dimensions
3. Note technique review skipped

## Do NOT
- Change techniques without user confirmation
- Skip prompt regeneration reminder
