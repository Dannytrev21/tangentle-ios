# Step 7: Plan-Feature-Initial Explore Phase

## Problem Type
`refactor`

## Technique Selection
- **Planning**: ps-plus - Structured approach to adding explore substep
- **Implementation**: self-refine - Iteratively improve explore instructions
- **Verification**: tdd - Verify explore phase is documented and executed

## Risk Level
**medium** - Modifying requirements gathering command

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Reasoning Depth
**Think hard about** how explore phase integrates before classification.

## Context
The guide emphasizes "never let Claude jump straight to coding" with an explicit explore phase. This step adds a formal exploration substep to plan-feature-initial between reading CLAUDE.md and classifying the problem.

## Goal
Add explicit "Explore" phase as Step 1.5 in plan-feature-initial.md that gathers codebase context before problem classification.

## Prerequisites
- Step 1 completed (knowledge base with explore pattern documentation)

## High-Level Steps
1. Read current plan-feature-initial.md
2. Identify insertion point after "Understand the Project Context"
3. Add new "Step 1.5: Explore the Codebase" section
4. Add explicit "Don't write any code yet" instruction
5. Add exploration documentation requirement
6. Verify explore phase is well-integrated

## Detailed Requirements

### New Step 1.5: Explore the Codebase
Insert after Step 1 (Understand the Project Context):

```markdown
### Step 1.5: Explore the Codebase
**Never jump straight to planning. Explore first.**

Before classifying the problem, gather context:

#### 1. Read Relevant Files (Don't Write Code Yet)
Based on the feature description, identify and read files that might be affected:

```
Read the following without writing any code:
- Files that implement similar features
- Files that will be modified
- Tests for related functionality
- Configuration files that might be involved
```

**Be explicit**: "Read the [X] module and explain how [Y] is managed. Don't write any code yet."

#### 2. Document Exploration Findings
Before proceeding, document what you learned:

```markdown
## Exploration Summary

### Files Reviewed
| File | Purpose | Relevance |
|------|---------|-----------|
| {path} | {what it does} | {why it matters for this feature} |

### Existing Patterns Found
- {pattern 1}: Found in {file}, could apply to this feature
- {pattern 2}: {description}

### Potential Impact Areas
- {area 1}: {why it might be affected}
- {area 2}: {why it might be affected}

### Questions Raised
- {question 1}
- {question 2}

### Initial Complexity Assessment
{simple/medium/complex} - {rationale}
```

#### 3. Proceed to Classification
Only after exploration is complete, proceed to Step 1.5 (Classify Problem Type).

**If exploration reveals the feature is significantly different than initially described**:
- Update understanding before classification
- Note any scope changes
- Flag potential risks discovered
```

### Update Process Section
Add exploration as explicit step in the Process list:
```markdown
## Process

### Step 1: Understand the Project Context
[existing content]

### Step 1.5: Explore the Codebase
Gather context by reading relevant files. Don't write code yet.
Document findings before classification.

### Step 2: Classify Problem Type (was Step 1.5)
[renumber subsequent steps]
```

### Add Exploration Reminder
Add to the beginning of the command:
```markdown
## Key Principle
**Explore before you plan. Plan before you code.**

This command follows the guide's recommended workflow:
1. Explore - Read and understand relevant code
2. Plan - Create structured implementation plan
3. Code - Implement with clear direction
4. Commit - Checkpoint frequently
```

## Files to Create
- None

## Files to Modify
- `.claude/commands/plan-feature-initial.md`: Add explore phase

## Patterns to Follow
Reference: Guide's "Phase 1: Explore" workflow
Reference: `.claude/knowledge/claude-code-mastery.md` explore section

## Acceptance Criteria
- [ ] Step 1.5 "Explore the Codebase" section exists
- [ ] Explicit "Don't write any code yet" instruction included
- [ ] Exploration documentation template provided
- [ ] Key Principle section added at top
- [ ] Subsequent steps renumbered correctly
- [ ] Process flow is logical and clear
- [ ] Exploration findings are required before classification

## Testing Requirements
**N/A - Reason**: Command documentation enhancement
**Manual Verification**:
- Run `/plan-feature-initial` on test feature
- Verify explore phase is prompted
- Check that exploration is documented before classification

## Verification Commands
```bash
# Verify explore section exists
grep -c "Explore the Codebase" .claude/commands/plan-feature-initial.md
grep -c "Don't write any code yet" .claude/commands/plan-feature-initial.md
grep -c "Exploration Summary" .claude/commands/plan-feature-initial.md

# Verify key principle
grep -c "Explore before you plan" .claude/commands/plan-feature-initial.md

# Verify step numbering
grep "Step 1.5" .claude/commands/plan-feature-initial.md
grep "Step 2:" .claude/commands/plan-feature-initial.md
```

## Documentation Updates
- [ ] Update step notes in progress.json

## Error Recovery
If verification fails:
1. Identify missing content
2. Review guide's explore phase description
3. Add missing exploration instructions
4. Re-run verification

## Do NOT
- Create a separate `/plan-explore` command (integrate into initial)
- Remove existing classification logic
- Make exploration optional (it's required)
- Skip the "don't write code" instruction
