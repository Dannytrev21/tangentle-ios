---
name: plan-feature
description: Create implementation plan for a feature with technique-aware step decomposition
---

# Plan Feature

Generate a comprehensive implementation plan with Tree of Thought analysis, technique assignments, and all tracking artifacts.

## Instructions

When invoked with a feature description:

### Step 1: Parse Input

Extract feature description from user input.
Create slug: lowercase, replace spaces with hyphens, remove special characters.

```
Example: "Add user authentication" → "add-user-authentication"
```

### Step 2: Determine Plan Number

```bash
latest=$(ls -d .windsurf/plans/[0-9]* 2>/dev/null | sort -V | tail -1 | grep -oE '[0-9]+')
if [ -z "$latest" ]; then
  next="001"
else
  next=$(printf "%03d" $((10#$latest + 1)))
fi
echo "Next plan number: $next"
```

### Step 3: Read Project Context

1. Read `CLAUDE.md` or `WINDSURF.md` for project conventions
2. Explore codebase for existing patterns
3. Identify affected files and systems

### Step 4: Apply Tree of Thought Analysis

For each major decision, evaluate multiple options:

```markdown
### Decision: {Topic}

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | {approach} | {benefits} | {tradeoffs} |
| B | {approach} | {benefits} | {tradeoffs} |
| C | {approach} | {benefits} | {tradeoffs} |

**Selected: Option {X}** - {Rationale}
```

Consider at minimum:
- Data storage approach
- API/service design
- UI/UX approach
- Testing strategy

### Step 5: Decompose into Steps

Break feature into implementation steps where each step:
- Completes in one focused session (30-90 min)
- Has clear, testable acceptance criteria
- Has explicit dependencies

Typical decomposition:
1. Data models/entities
2. Repository/data access
3. Service/business logic
4. UI components
5. Integration and testing

### Step 6: Classify Each Step

For each step, determine problem type and techniques:

```bash
# Get problem type
python3 .windsurf/scripts/windsurf_plan.py classify "{step description}"

# Get techniques
python3 .windsurf/scripts/windsurf_plan.py techniques {problem_type}

# Assess risk
python3 .windsurf/scripts/windsurf_plan.py risk {problem_type}
```

If Python unavailable, use keyword matching:
- Creates models → `data-modeling`
- Creates services → `service-impl`
- Creates UI → `ui`
- Writes tests → `unit-test`
- Fixes bugs → `debug`

### Step 7: Create Directory Structure

```bash
mkdir -p .windsurf/plans/${next}-${slug}/{steps,prompts,reviews}
```

### Step 8: Generate Artifacts

#### 8.1 plan.md

```markdown
# Plan {NNN}: {Feature Title}

## Overview
{2-3 sentence description}

## Status
- **Created**: {date}
- **Status**: Not Started
- **Current Step**: 0 of {N}
- **Problem Type**: {type} (Category: {category})

## Tree of Thought Analysis

### What are we building?
{Detailed description}

### Why are we building it?
{Business/user value}

### Key Decisions
{ToT analysis results}

## Technique Matrix

| Step | Type | Planning | Implementation | Verification | Risk |
|------|------|----------|----------------|--------------|------|
{rows from classification}

## Implementation Steps

| Step | Name | Description | Status |
|------|------|-------------|--------|
{step rows}

## Success Criteria
- [ ] {criterion 1}
- [ ] All tests pass
```

#### 8.2 adr.md

```markdown
# ADR: {Feature Name}

## Status
Proposed

## Context
{Why needed}

## Decisions
{ToT decisions with rationale}

## Consequences
### Positive
- {benefits}

### Negative/Tradeoffs
- {tradeoffs with mitigations}
```

#### 8.3 Step Files

For each step, create `steps/{NN}-{name}.md`:

```markdown
# Step {N}: {Name}

## Problem Type
`{type}`

## Technique Selection
- **Planning**: {tech}
- **Implementation**: {tech}
- **Verification**: {tech}

## Risk Level
**{level}** - {explanation}

## Retry Configuration
- Same technique: {n} attempts
- Alternative: {n} attempts

## Goal
{Clear objective}

## Prerequisites
- {dependencies}

## Requirements
{Implementation details}

## Acceptance Criteria
- [ ] {criterion}

## Testing Requirements
{What tests to write}

## Verification Commands
\`\`\`bash
# Build and test
xcodebuild test -scheme {Scheme} ...
\`\`\`
```

#### 8.4 progress.json

```json
{
  "planId": "{NNN}",
  "name": "{slug}",
  "title": "{Title}",
  "status": "not_started",
  "currentStep": 0,
  "totalSteps": {N},
  "steps": [
    {
      "id": 1,
      "name": "{slug}",
      "title": "{Title}",
      "problemType": "{type}",
      "status": "pending",
      "techniques": {
        "planning": "{tech}",
        "implementation": ["{tech}"],
        "verification": "{tech}"
      },
      "riskLevel": "{level}",
      "retryConfig": {
        "maxSameTechnique": {n},
        "maxAlternative": {n},
        "maxTotal": {n}
      }
    }
  ]
}
```

#### 8.5 context.md

```markdown
# Plan {NNN} Context

## Quick Status
- **Plan**: {Title}
- **Current Step**: 0 - Not Started
- **Last Updated**: {date}

## What's Been Done
Plan created with full specification.

## Files Created
| File | Purpose |
|------|---------|
| plan.md | Main plan document |
| adr.md | Architecture decisions |
| steps/ | Step specifications |
| progress.json | Progress tracking |

## Next Actions
1. Run `/plan-prompts {NNN}` to generate AI prompts
2. Run `/plan-next {NNN}` to start implementation
```

### Step 9: Update .gitignore

If `.windsurf/**` not already in .gitignore:

```bash
grep -q ".windsurf" .gitignore || echo -e "\n# Windsurf IDE\n.windsurf/**" >> .gitignore
```

### Step 10: Output Summary

Display:

```markdown
═══════════════════════════════════════════════════════════════
  PLAN CREATED: {NNN}-{slug}
═══════════════════════════════════════════════════════════════

**Feature**: {Title}
**Steps**: {N} implementation steps
**Location**: `.windsurf/plans/{NNN}-{slug}/`

## Files Created
- plan.md - Main plan with Tree of Thought analysis
- adr.md - Architecture decisions
- steps/ - {N} step files with techniques
- progress.json - Progress tracking
- context.md - Context preservation

## Technique Matrix
| Step | Problem Type | Planning | Implementation | Verification | Risk |
|------|--------------|----------|----------------|--------------|------|
{technique matrix rows}

## Next Commands
1. `/plan-prompts {NNN}` - Generate AI prompts
2. `/plan-next {NNN}` - Start implementation
3. `/plan-status {NNN}` - View progress
═══════════════════════════════════════════════════════════════
```

## Quality Standards

### Steps
- Each step completable in 30-90 minutes
- Clear, testable acceptance criteria
- Explicit dependencies between steps
- **Every step MUST include tests**

### Tree of Thought
- At least 3 options per major decision
- Document pros/cons objectively
- Explain selection rationale

### Techniques
- Match technique to problem type
- Document rationale for selection
- Higher risk = more retries

## Risk Levels

| Level | Same Tech | Alt Tech | Total | Escalate |
|-------|-----------|----------|-------|----------|
| Low | 2 | 1 | 3 | 2 |
| Medium | 3 | 2 | 5 | 3 |
| High | 3 | 3 | 7 | 5 |
| Critical | 5 | 5 | 10 | 7 |

## Error Recovery

### Plan Number Detection Fails
1. Check `.windsurf/plans/` exists
2. List contents: `ls .windsurf/plans/`
3. Set number explicitly

### Template Fill Fails
1. Verify template file exists
2. Check placeholder syntax: `{{NAME}}`
3. Escape special characters

## Do NOT
- Do NOT create prompts (that's `/plan-prompts`)
- Do NOT begin implementation (that's `/plan-next`)
- Do NOT skip technique assignment
- Do NOT commit changes automatically
