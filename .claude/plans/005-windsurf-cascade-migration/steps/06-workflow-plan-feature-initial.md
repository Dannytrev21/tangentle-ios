# Step 6: Workflow - /plan-feature-initial

## Problem Type
`migration`

## Technique Selection
- **Planning**: least-to-most - Break down requirements analysis flow
- **Implementation**: chain-of-code - Mixed workflow markdown and logic
- **Verification**: reflexion - Learn from workflow execution issues

## Risk Level
**medium** - First workflow; establishes patterns for others

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
`/plan-feature-initial` is the entry point for new features. It acts as a requirements analyst: analyzing initial ideas, identifying gaps, producing clarifying questions, and generating a ready-to-use `/plan-feature` prompt. This sets the pattern for all other workflows.

## Goal
Create the `/plan-feature-initial` workflow that guides users through requirements gathering with AI-based problem classification and structured output.

## Prerequisites
- Step 1 completed (workflows directory exists)
- Step 2 completed (Python classifier available)
- Step 3 completed (templates available)

## High-Level Steps
1. Design workflow structure within 12K char limit
2. Implement problem classification via Python script
3. Implement Tree of Thought feature analysis
4. Create gap identification with severity levels
5. Generate clarifying questions
6. Produce fill-in template for /plan-feature
7. Implement hybrid confirm → proceed flow

## Detailed Requirements

### Workflow File Structure
```markdown
---
name: plan-feature-initial
description: Requirements analysis for new features
---

# Plan Feature Initial

{Instructions for Cascade to follow}
```

### Input Handling
The workflow receives initial feature description via natural language in the Cascade chat. Parse the user's message to extract the feature description.

### Process Flow
1. **Classification Phase**
   - Run: `python3 .windsurf/scripts/windsurf_plan.py classify "{description}"`
   - Parse output: problem type, category, confidence, techniques

2. **Analysis Phase**
   - Apply Tree of Thought to analyze 5 branches:
     - WHAT (Scope & Features)
     - WHO (Users & Personas)
     - HOW (Technical Approach)
     - CONSTRAINTS (Limitations)
     - SUCCESS (Metrics)

3. **Gap Identification**
   - Identify: Explicit, Implicit, Missing, Ambiguous
   - Categorize by severity: 🔴 Blocking, 🟡 Important, 🟢 Optional

4. **Question Generation**
   - Generate questions for each gap
   - Provide context, options, and defaults

5. **Output Generation**
   - Display classification results
   - Display questions grouped by severity
   - Generate `/plan-feature` prompt template

6. **Hybrid Flow**
   - Show synthesized `/plan-feature` input for review
   - Wait for user confirmation
   - Proceed to `/plan-feature` automatically after confirmation

### Output Format
```markdown
# Feature Analysis: {Feature Name}

## Problem Classification
- **Type**: {type} (Category: {category})
- **Confidence**: {confidence}%
- **Suggested Techniques**:
  | Phase | Technique |
  |-------|-----------|
  | Planning | {tech} |
  | Implementation | {tech} |
  | Verification | {tech} |

## Summary of Understanding
{2-3 paragraph summary}

### Assumptions
- {assumption 1}
- {assumption 2}

## Questions to Complete the Plan

### 🔴 Blocking Questions
{questions that must be answered}

### 🟡 Important Questions
{questions that should be answered}

### 🟢 Optional Questions
{questions with sensible defaults}

## Optimized Prompt for /plan-feature

Once you've answered the questions above, I'll proceed with:

\`\`\`
/plan-feature {Feature Name}
{structured content from answers}
\`\`\`

**Ready to proceed?** (yes/no/edit)
```

## Files to Create
- `.windsurf/workflows/plan-feature-initial.md`

## Files to Modify
None.

## Patterns to Follow
Reference: `.claude/commands/plan-feature-initial.md` for analysis structure
Reference: Windsurf workflow syntax from documentation

## Acceptance Criteria
- [ ] Workflow file created at `.windsurf/workflows/plan-feature-initial.md`
- [ ] File is under 12,000 characters
- [ ] Workflow invokes Python classifier correctly
- [ ] Tree of Thought analysis covers all 5 branches
- [ ] Questions grouped by severity (🔴/🟡/🟢)
- [ ] Output includes ready `/plan-feature` prompt
- [ ] Hybrid confirm → proceed flow implemented
- [ ] Workflow is invocable via `/plan-feature-initial` in Cascade

## Testing Requirements

### Unit Tests
**N/A** - Workflow is declarative; tested by execution.

### Integration Tests
- [ ] Run `/plan-feature-initial Add a login screen` in Cascade
- [ ] Verify classification output appears
- [ ] Verify questions are generated
- [ ] Verify `/plan-feature` prompt is generated
- [ ] Verify "Ready to proceed?" prompt appears

### Manual Verification
- [ ] Workflow file exists and is valid markdown
- [ ] No syntax errors when loaded in Windsurf
- [ ] Character count under 12,000

## Verification Commands
```bash
# Check file exists and size
wc -c .windsurf/workflows/plan-feature-initial.md

# Verify under 12K limit
[ $(wc -c < .windsurf/workflows/plan-feature-initial.md) -lt 12000 ] && echo "OK" || echo "TOO LARGE"

# Check for required sections
grep -c "Problem Classification\|Tree of Thought\|Blocking Questions\|plan-feature" \
  .windsurf/workflows/plan-feature-initial.md
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check character count and reduce if over limit
2. Verify Python script path is correct
3. Test classifier invocation separately
4. Check markdown syntax for Windsurf compatibility

## Do NOT
- Exceed 12,000 character limit
- Skip problem classification step
- Hardcode techniques (must come from classifier)
- Auto-proceed without user confirmation
