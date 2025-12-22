# Plan Feature Review Command

You are reviewing and critiquing an existing implementation plan. Your job is to identify gaps, improve step quality, add missing details, and ensure the plan is robust enough for successful AI-driven implementation.

## Input
Plan number to review: $ARGUMENTS

## Process

### Step 1: Load the Plan

Read all plan files:
```
.claude/plans/{NNN}-{slug}/
├── plan.md
├── adr.md
├── steps/*.md
├── progress.json
└── context.md
```

Also read `CLAUDE.md` to understand project conventions and any existing code patterns.

### Step 2: Apply Tree of Thought Review

Analyze the plan across 5 critical dimensions:

```
┌─────────────────────────────────────────────────────────────────┐
│  TREE OF THOUGHT: Plan Review Analysis                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Branch 1: COMPLETENESS                                          │
│  ├── Are all features from the original request covered?        │
│  ├── Are there missing edge cases or error handling?            │
│  ├── Is the data model complete for all requirements?           │
│  ├── Are all integrations accounted for?                        │
│  └── Are there implicit requirements not made explicit?         │
│                                                                  │
│  Branch 2: SEQUENCING & DEPENDENCIES                             │
│  ├── Are steps in the optimal order?                            │
│  ├── Are dependencies between steps correct?                    │
│  ├── Are there steps that could be parallelized?                │
│  ├── Are there unnecessary blocking dependencies?               │
│  └── Is there a critical path that could be shortened?          │
│                                                                  │
│  Branch 3: GRANULARITY                                           │
│  ├── Are any steps too large (>90 min)?                         │
│  ├── Are any steps too small (could be combined)?               │
│  ├── Is each step independently verifiable?                     │
│  ├── Does each step produce tangible output?                    │
│  └── Can each step fail gracefully without blocking others?     │
│                                                                  │
│  Branch 4: TECHNICAL QUALITY                                     │
│  ├── Do the architectural decisions align with codebase?        │
│  ├── Are there better patterns in the existing code?            │
│  ├── Are all file paths and references accurate?                │
│  ├── Are verification commands complete and correct?            │
│  └── Are rollback procedures realistic?                         │
│                                                                  │
│  Branch 5: RISK & ROBUSTNESS                                     │
│  ├── What are the highest-risk steps?                           │
│  ├── Are there sufficient error recovery procedures?            │
│  ├── Are there external dependencies that could fail?           │
│  ├── Is there adequate testing coverage planned?                │
│  └── Are there assumptions that need validation?                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Step 3: Generate Critique Report

For each dimension, rate and document:

```markdown
## Review Findings

### 1. Completeness: {score}/10
| Finding | Severity | Recommendation |
|---------|----------|----------------|
| {issue} | 🔴/🟡/🟢 | {fix} |

### 2. Sequencing & Dependencies: {score}/10
| Finding | Severity | Recommendation |
|---------|----------|----------------|
| {issue} | 🔴/🟡/🟢 | {fix} |

### 3. Granularity: {score}/10
| Finding | Severity | Recommendation |
|---------|----------|----------------|
| {issue} | 🔴/🟡/🟢 | {fix} |

### 4. Technical Quality: {score}/10
| Finding | Severity | Recommendation |
|---------|----------|----------------|
| {issue} | 🔴/🟡/🟢 | {fix} |

### 5. Risk & Robustness: {score}/10
| Finding | Severity | Recommendation |
|---------|----------|----------------|
| {issue} | 🔴/🟡/🟢 | {fix} |
```

Severity levels:
- 🔴 **Critical**: Must fix before proceeding
- 🟡 **Important**: Should fix to improve quality
- 🟢 **Minor**: Nice to have, low impact

### Step 4: Identify Specific Changes

Create an actionable change list:

#### Step Changes
```markdown
### Steps to Add
| New Step # | Name | Description | Insert After |
|------------|------|-------------|--------------|
| {N.5} | {name} | {description} | Step {N} |

### Steps to Remove
| Step # | Name | Reason |
|--------|------|--------|
| {N} | {name} | {why remove} |

### Steps to Split
| Original | Split Into | Reason |
|----------|------------|--------|
| Step {N} | Steps {N}a, {N}b | {too large, multiple concerns} |

### Steps to Merge
| Steps | Merge Into | Reason |
|-------|------------|--------|
| {N}, {M} | Step {X} | {too small, same concern} |

### Steps to Reorder
| Step | Move From | Move To | Reason |
|------|-----------|---------|--------|
| {name} | Position {X} | Position {Y} | {dependency, optimization} |

### Steps to Enhance
| Step # | Enhancement | Details |
|--------|-------------|---------|
| {N} | Add verification | {specific commands} |
| {N} | Add error handling | {specific scenarios} |
| {N} | Add details | {specific requirements} |
```

#### ADR Changes
```markdown
### Decisions to Revisit
| Decision | Original | Proposed Change | Rationale |
|----------|----------|-----------------|-----------|
| {topic} | {current} | {new} | {why} |

### Missing Decisions
| Topic | Recommended Decision | Rationale |
|-------|---------------------|-----------|
| {topic} | {decision} | {why} |
```

#### Context Updates
```markdown
### Missing Context
- {what context is missing}

### Stale Context
- {what context needs updating}
```

### Step 5: Apply Changes

After documenting changes, apply them to the plan files:

1. **Update plan.md**
   - Revise step table with new order/additions/removals
   - Update dependencies
   - Add/revise success criteria
   - Note: Add a "## Revision History" section if not present

2. **Update adr.md**
   - Add new decisions or revise existing ones
   - Document alternative approaches considered
   - Update consequences

3. **Create/Update step files**
   - Create new step files for added steps
   - Update existing steps with enhancements
   - Renumber steps if order changed (update file names)

4. **Update progress.json**
   - Update totalSteps
   - Add/remove/reorder step entries
   - Update updatedAt timestamp

5. **Update context.md**
   - Add review findings to "Things to Remember"
   - Update current state description

### Step 6: Create Review Log

Create `.claude/plans/{NNN}-{slug}/reviews/review-{date}.md`:

```markdown
# Plan Review: {date}

## Overall Assessment
- **Previous Score**: {X}/50
- **New Score**: {Y}/50
- **Improvement**: +{delta}

## Summary of Changes

### Steps Added
{list with rationale}

### Steps Removed
{list with rationale}

### Steps Modified
{list with changes}

### Steps Reordered
{previous order → new order}

### ADR Updates
{what changed}

## Remaining Concerns
{anything that couldn't be addressed}

## Recommendations for Implementation
{specific advice for executing the plan}
```

### Step 7: Output Summary

```markdown
## Plan Review Complete: {NNN}-{slug}

### Scores (Before → After)
| Dimension | Before | After |
|-----------|--------|-------|
| Completeness | {X} | {Y} |
| Sequencing | {X} | {Y} |
| Granularity | {X} | {Y} |
| Technical | {X} | {Y} |
| Robustness | {X} | {Y} |
| **Total** | **{X}/50** | **{Y}/50** |

### Changes Applied
- Steps added: {N}
- Steps removed: {N}
- Steps modified: {N}
- Steps reordered: Yes/No
- ADR updated: Yes/No

### Critical Issues Fixed
{list of 🔴 items addressed}

### Next Commands
1. `/plan-prompts {NNN}` - Regenerate prompts if steps changed significantly
2. `/plan-status {NNN}` - View updated plan status
3. `/plan-next {NNN}` - Begin implementation
```

## Quality Standards

### For the Review
- Be constructively critical, not nitpicky
- Focus on issues that impact implementation success
- Validate technical accuracy against actual codebase
- Ensure steps match project conventions from CLAUDE.md

### For Changes
- Every change must have clear rationale
- Don't change things that are already good
- Preserve the original intent of the plan
- Ensure renumbering is consistent across all files
- Keep step sizes appropriate (30-90 minutes)

### For Tree of Thought
- Consider multiple perspectives on each finding
- Challenge your own assumptions
- Look for non-obvious issues
- Consider both short-term and long-term implications

## Common Issues to Check

### Completeness Issues
- [ ] Missing error handling steps
- [ ] Missing testing steps
- [ ] Missing documentation updates
- [ ] Missing cleanup/finalization step
- [ ] Missing migration step for existing data

### Sequencing Issues
- [ ] UI steps before data layer is complete
- [ ] Integration steps before components exist
- [ ] Testing steps that should be earlier
- [ ] Configuration steps that should be first

### Granularity Issues
- [ ] "Implement entire feature" as one step
- [ ] Multiple unrelated changes in one step
- [ ] Overly trivial steps that waste context

### Technical Issues
- [ ] Incorrect file paths
- [ ] Missing file references
- [ ] Outdated API patterns
- [ ] Missing verification commands
- [ ] Verification commands that won't work

### Risk Issues
- [ ] No rollback for data migrations
- [ ] External API calls without fallback
- [ ] Shared resource modifications without locking
- [ ] Missing backup steps for destructive operations

## Example Review Output

```markdown
## Review Findings for Plan 002

### 1. Completeness: 7/10
| Finding | Severity | Recommendation |
|---------|----------|----------------|
| No accessibility step | 🟡 Important | Add Step 8: Accessibility audit |
| Missing haptic feedback | 🟢 Minor | Add to gesture step details |

### 2. Sequencing: 6/10
| Finding | Severity | Recommendation |
|---------|----------|----------------|
| Animation step before gesture system | 🔴 Critical | Move Step 5 after Step 7 |
| Color system too late | 🟡 Important | Move Step 3 to Step 1 |

[...continues for all dimensions...]

### Steps to Reorder
| Step | Move From | Move To | Reason |
|------|-----------|---------|--------|
| Color System | 3 | 1 | Foundation for all UI work |
| Animations | 5 | 8 | Depends on gestures being complete |

### Steps to Add
| New Step # | Name | Description | Insert After |
|------------|------|-------------|--------------|
| 9 | Accessibility Audit | VoiceOver, Dynamic Type | Step 8 |
| 10 | Performance Profiling | Gesture responsiveness | Step 9 |
```

## Constraints
- DO NOT delete the original plan files - only modify them
- DO NOT start implementation - this is review only
- DO preserve the review log for historical reference
- DO update all cross-references when renumbering steps
