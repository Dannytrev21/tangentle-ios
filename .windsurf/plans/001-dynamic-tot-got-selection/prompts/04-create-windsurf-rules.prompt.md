# Prompt: Step 4 - Create Windsurf Rules

## Mission
Create three Windsurf rules to provide contextual guidance and offload content from workflows.

## Context
You are implementing step 4 of 6 in the "Dynamic ToT/GoT Selection & Windsurf Rules Integration" plan.

**Plan Summary**: Enable dynamic selection between Tree of Thoughts (ToT) and Graph of Thoughts (GoT) reasoning techniques, with Windsurf rules to offload workflow content.

**This Step**: Creates three rules that provide contextual guidance to Cascade and allow workflows to reference common content instead of duplicating it.

**Dependencies**:
- Requires: None (can run in parallel with Step 1)
- Enables: Steps 2, 3 (workflow updates reference these rules)

## Pre-Implementation Checklist
Before creating any files, complete these steps:

### 1. Read Required Files
Read these files to understand existing patterns:

| File | Why | Focus On |
|------|-----|----------|
| `.windsurf/workflows/plan-feature-initial.md` | Content to extract | Question categories, quality standards |
| `.windsurf/workflows/plan-feature.md` | Content to extract | Risk levels, error recovery |

### 2. Verify Prerequisites
```bash
# Verify rules directory exists
ls -la .windsurf/rules/

# Check it's empty (only .gitkeep)
ls .windsurf/rules/
```

### 3. Understand Current State
```bash
cat .windsurf/plans/001-dynamic-tot-got-selection/context.md
```

## Specification

### Goal
Create three Windsurf rules in `.windsurf/rules/`:
1. `plan-conventions.md` - Always On rule with planning conventions
2. `technique-selection.md` - Model Decision rule for ToT/GoT guidance
3. `no-staging.md` - Glob rule to prevent .windsurf file staging

### Requirements
1. Each rule must have YAML frontmatter with trigger and description
2. Each rule must be under 6,000 characters
3. Total of all rules must be under 12,000 characters
4. Content must be useful for Cascade context
5. Rules must use valid trigger types: always_on, model_decision, glob

### Rule Specifications

#### Rule 1: plan-conventions.md (~3,000 chars)
- **Trigger**: `always_on`
- **Purpose**: Core conventions always available to Cascade
- **Content**:
  - Question categories for requirements (Scope, UX, Data, Technical, Visual, Integration, Testing, Rollout)
  - Quality standards for steps
  - Testing requirements
  - Context preservation guidelines
  - Risk levels table

#### Rule 2: technique-selection.md (~2,500 chars)
- **Trigger**: `model_decision`
- **Purpose**: Guidance when Cascade needs to choose between ToT and GoT
- **Content**:
  - When to use ToT (exploration, design decisions, multiple approaches)
  - When to use GoT (synthesis, aggregation, review)
  - How each technique works (steps)
  - Category defaults
  - Characteristic overrides
  - CLI command reference

#### Rule 3: no-staging.md (~500 chars)
- **Trigger**: `glob`
- **Glob pattern**: `.windsurf/**`
- **Purpose**: Warn when .windsurf files are about to be staged
- **Content**:
  - What's in .windsurf/
  - Why not to commit
  - How to unstage
  - How to add to .gitignore

## Implementation Guide

### Step-by-Step Instructions

1. **Create plan-conventions.md**
   ```bash
   cat > .windsurf/rules/plan-conventions.md << 'EOF'
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
   EOF
   ```

2. **Create technique-selection.md**
   ```bash
   cat > .windsurf/rules/technique-selection.md << 'EOF'
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
   EOF
   ```

3. **Create no-staging.md**
   ```bash
   cat > .windsurf/rules/no-staging.md << 'EOF'
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
   EOF
   ```

4. **Verify character counts**
   ```bash
   wc -c .windsurf/rules/*.md
   # Each should be < 6000, total < 12000
   ```

## Acceptance Criteria
All must pass before marking complete:

- [ ] **AC1**: plan-conventions.md exists with `trigger: always_on`
  - Verify: `head -3 .windsurf/rules/plan-conventions.md`

- [ ] **AC2**: technique-selection.md exists with `trigger: model_decision`
  - Verify: `head -3 .windsurf/rules/technique-selection.md`

- [ ] **AC3**: no-staging.md exists with `trigger: glob` and `glob: .windsurf/**`
  - Verify: `head -4 .windsurf/rules/no-staging.md`

- [ ] **AC4**: Each rule < 6,000 characters
  - Verify: `wc -c .windsurf/rules/*.md`

- [ ] **AC5**: Total rules < 12,000 characters
  - Verify: `cat .windsurf/rules/*.md | wc -c`

- [ ] **AC6**: All rules have description in frontmatter
  - Verify: `grep "description:" .windsurf/rules/*.md`

## Verification Protocol

### 1. File Existence Check
```bash
ls -la .windsurf/rules/*.md
```
Expected: 3 files (plan-conventions.md, technique-selection.md, no-staging.md)

### 2. Character Count Check
```bash
wc -c .windsurf/rules/*.md
```
Expected: Each < 6000, total shown at end

### 3. Total Character Check
```bash
cat .windsurf/rules/*.md | wc -c
```
Expected: < 12000

### 4. Frontmatter Check
```bash
for f in .windsurf/rules/*.md; do
  echo "=== $f ==="
  head -5 "$f"
done
```
Expected: Each starts with `---`, has trigger and description

### 5. Content Check
```bash
# Check plan-conventions has key sections
grep -c "Question Categories\|Quality Standards\|Risk Levels" .windsurf/rules/plan-conventions.md
# Should be 3+

# Check technique-selection has both techniques
grep -c "Tree of Thoughts\|Graph of Thoughts" .windsurf/rules/technique-selection.md
# Should be 2+
```

## Error Recovery

### If Character Limit Exceeded
1. Trim verbose explanations
2. Remove redundant examples
3. Use bullet points instead of paragraphs
4. Consider what's truly necessary for Cascade context

### If Frontmatter Invalid
1. Ensure `---` on first line
2. Ensure closing `---` after frontmatter fields
3. Check trigger is valid: always_on, model_decision, manual, glob
4. For glob trigger, ensure glob field is present

## Completion Protocol

After ALL acceptance criteria pass:

### 1. Update Progress
Update `.windsurf/plans/001-dynamic-tot-got-selection/progress.json`:
```json
{
  "steps[3]": {
    "status": "completed",
    "completedAt": "{ISO date}",
    "verificationPassed": true,
    "notes": "Created 3 Windsurf rules"
  },
  "context.filesCreated": [
    ".windsurf/rules/plan-conventions.md",
    ".windsurf/rules/technique-selection.md",
    ".windsurf/rules/no-staging.md"
  ]
}
```

### 2. Update Context
Add to `.windsurf/plans/001-dynamic-tot-got-selection/context.md`:
```markdown
## Step 4 Complete - {date}

### What Was Done
- Created plan-conventions.md (Always On) - ~3,000 chars
- Created technique-selection.md (Model Decision) - ~2,500 chars
- Created no-staging.md (Glob) - ~500 chars
- Total rules: ~6,000 chars (limit: 12,000)

### Files Created
- `.windsurf/rules/plan-conventions.md`
- `.windsurf/rules/technique-selection.md`
- `.windsurf/rules/no-staging.md`

### Key Decisions
- Always On for conventions (need context in every conversation)
- Model Decision for technique selection (AI applies when relevant)
- Glob for .windsurf protection (triggers on file access)
```

## Do NOT
- Do NOT exceed 6,000 characters per rule file
- Do NOT exceed 12,000 characters total for all rules
- Do NOT use triggers other than: always_on, model_decision, manual, glob
- Do NOT omit the description field in frontmatter
- Do NOT include code that should be in Python modules

## Quality Checklist
Before marking complete, verify:
- [ ] All 3 rules created
- [ ] Each under 6K chars
- [ ] Total under 12K chars
- [ ] Valid frontmatter on each
- [ ] Content is useful for Cascade
- [ ] progress.json updated
- [ ] context.md updated
