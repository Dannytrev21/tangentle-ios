# Step 4: Create Windsurf Rules

## Problem Type
`infrastructure`

## Technique Selection
- **Planning**: PS+ - Structured rule creation
- **Implementation**: Least-to-Most - Build rules incrementally
- **Verification**: Self-Refine - Iterate on rule content

## Risk Level
**Low** - Creating new files; no existing functionality affected

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Context
Windsurf rules provide contextual guidance to Cascade. This step creates three rules to:
1. Offload common content from workflows (character budget)
2. Provide technique selection guidance (Model Decision)
3. Prevent .windsurf files from being staged (Glob)

## Goal
Create three Windsurf rules in `.windsurf/rules/`:
1. `plan-conventions.md` (Always On) - Core planning conventions
2. `technique-selection.md` (Model Decision) - ToT/GoT guidance
3. `no-staging.md` (Glob: `.windsurf/**`) - Prevent staging

## Prerequisites
- None (can run in parallel with Step 1)

## High-Level Steps
1. Create plan-conventions.md with Always On trigger
2. Create technique-selection.md with Model Decision trigger
3. Create no-staging.md with Glob trigger
4. Verify all rules < 6K chars each
5. Verify total < 12K chars
6. Test rule loading in Cascade

## Detailed Requirements

### Rule 1: plan-conventions.md (~3,000 chars)
```markdown
---
trigger: always_on
description: Core conventions for the Windsurf planning system
---

# Planning System Conventions

## Question Categories for Requirements Analysis

When gathering requirements, check these areas for gaps:

### Scope
- Minimum viable version (MVP)
- Features explicitly excluded
- Phasing (v1 vs v2)
- Existing features affected

### User Experience
- Primary user flow
- Gestures/interactions expected
- Accessibility requirements
- Error state handling

### Data
- New entities/models needed
- Existing data consumed
- Storage location (local/cloud)
- Sync strategy

### Technical
- Platform/version requirements
- Dependencies acceptable
- Performance targets
- Offline behavior

### Visual Design
- Design spec or reference available
- Reusable components
- New components needed
- Dark mode requirements

### Integration
- Existing services involved
- APIs consumed/exposed
- Third-party integrations
- Background processing needs

### Testing
- Coverage level expected
- Manual testing required
- Edge cases to handle
- Devices to test

### Rollout
- Feature flagging needed
- Migration strategy
- Rollback plan
- Analytics requirements

## Quality Standards

### For Steps
- Completable in 30-90 minutes
- Clear, testable acceptance criteria
- Explicit dependencies
- Copy-pasteable verification commands
- **Every step MUST include tests**

### For Testing
- Unit tests for all new functions/methods
- Integration tests when components interact
- UI tests for user-facing features
- Test naming: `test{What}_when{Condition}_should{Expected}()`

### For Context Preservation
- Write as if explaining to someone with no prior context
- Include specific file paths and line numbers
- Document "why" not just "what"
- Update after every significant change

## Risk Levels

| Level | Same Tech | Alt Tech | Total | When to Use |
|-------|-----------|----------|-------|-------------|
| Low | 2 | 1 | 3 | Simple, low-impact changes |
| Medium | 3 | 2 | 5 | Standard implementation |
| High | 3 | 3 | 7 | Complex or breaking changes |
| Critical | 4 | 4 | 10 | Data migration, core systems |
```

### Rule 2: technique-selection.md (~2,500 chars)
```markdown
---
trigger: model_decision
description: Apply when Cascade needs to select between Tree of Thoughts and Graph of Thoughts reasoning techniques
---

# ToT vs GoT Selection Guide

When analyzing complex problems, select the appropriate reasoning technique:

## Tree of Thoughts (ToT)

**Use when**:
- Exploring multiple approaches to a problem
- Making architecture or design decisions
- Evaluating alternatives with tradeoffs
- Building new features with uncertain requirements
- The problem space is large and unexplored

**How it works**:
1. Branch: Generate 3-5 high-level approaches
2. Evaluate: Score each on feasibility, complexity, confidence
3. Prune: Eliminate low-scoring paths
4. Expand: Develop promising branches deeper
5. Backtrack: If a path fails, try alternatives
6. Converge: Select winning path with rationale

**Categories that default to ToT**:
FOUNDATION, DATA, ARCHITECTURE, UI_UX, LOGIC, META

## Graph of Thoughts (GoT)

**Use when**:
- Synthesizing information from multiple sources
- Aggregating findings or feedback
- Reviewing and verifying work
- Merging perspectives into unified output
- The task is about combination, not exploration

**How it works**:
1. Initialize: Create thought nodes for each perspective
2. Expand: Develop each node independently
3. Aggregate: Merge compatible insights
4. Prune: Remove low-scoring paths
5. Refine: Iterate on merged solutions
6. Converge: Output synthesized result

**Categories that default to GoT**:
TESTING, DOCUMENTATION

## Characteristic Overrides

These characteristics override category defaults:

| Characteristic | Selects | Example |
|----------------|---------|---------|
| `requires_synthesis` | GoT | "Merge all feedback into spec" |
| `exploration_needed` | ToT | "Explore ways to implement" |
| `multiple_approaches` | ToT | "Could use A, B, or C" |
| `review_task` | GoT | "Review this plan for issues" |
| `new_design` | ToT | "Design a new system for X" |

## CLI Command

```bash
python3 .windsurf/scripts/windsurf_plan.py reasoning {problem_type} {category}
# Returns: tot or got with rationale
```
```

### Rule 3: no-staging.md (~500 chars)
```markdown
---
trigger: glob
glob: .windsurf/**
description: Prevent Windsurf planning files from being staged or committed
---

# Do Not Stage .windsurf Files

Files in `.windsurf/` are local to your workspace and should NOT be committed to git.

## What's in .windsurf/
- `plans/` - Implementation plans and progress
- `rules/` - Cascade customization rules
- `scripts/` - Python utilities
- `workflows/` - Command definitions
- `templates/` - Artifact templates
- `knowledge/` - Reference documentation
- `memory-bank/` - Session context

## If You See .windsurf in Staging

```bash
# Unstage
git reset .windsurf/

# Verify .gitignore has entry
grep ".windsurf" .gitignore

# Add if missing
echo ".windsurf/**" >> .gitignore
```

**Never commit .windsurf files to the repository.**
```

## Files to Create
- `.windsurf/rules/plan-conventions.md`
- `.windsurf/rules/technique-selection.md`
- `.windsurf/rules/no-staging.md`

## Files to Modify
- None

## Patterns to Follow
Reference: Windsurf rules documentation - YAML frontmatter with trigger field

## Acceptance Criteria
- [ ] plan-conventions.md exists with `trigger: always_on`
- [ ] technique-selection.md exists with `trigger: model_decision`
- [ ] no-staging.md exists with `trigger: glob` and `glob: .windsurf/**`
- [ ] Each rule < 6,000 characters
- [ ] Total rules < 12,000 characters
- [ ] All rules have description in frontmatter
- [ ] Content is useful for Cascade context

## Testing Requirements

### Verification Script
```bash
# Check each rule exists and has proper frontmatter
for rule in plan-conventions.md technique-selection.md no-staging.md; do
  echo "=== $rule ==="
  head -5 .windsurf/rules/$rule
  wc -c .windsurf/rules/$rule
done

# Check total size
cat .windsurf/rules/*.md | wc -c
# Must be < 12000
```

### Manual Testing
- [ ] Open Windsurf and check rules appear in Customizations panel
- [ ] Verify Always On rule shows as active
- [ ] Try to stage a .windsurf file - Glob rule should provide guidance
- [ ] Ask about ToT vs GoT - Model Decision rule should trigger

## Verification Commands
```bash
# Check file existence
ls -la .windsurf/rules/*.md

# Check character counts
wc -c .windsurf/rules/*.md

# Verify frontmatter
for f in .windsurf/rules/*.md; do head -5 "$f"; echo "---"; done

# Verify total under limit
total=$(cat .windsurf/rules/*.md 2>/dev/null | wc -c)
echo "Total: $total (limit: 12000)"
```

## Documentation Updates
- [ ] Add rules section to README.md explaining each rule

## Error Recovery
If verification fails:
1. Check YAML frontmatter syntax (must have `---` delimiters)
2. Verify trigger field is one of: always_on, model_decision, manual, glob
3. For glob trigger, ensure glob field is present
4. Trim content if exceeding character limits

## Do NOT
- Do NOT exceed 6,000 characters per rule file
- Do NOT exceed 12,000 characters total for all rules
- Do NOT use triggers other than: always_on, model_decision, manual, glob
- Do NOT omit the description field in frontmatter
