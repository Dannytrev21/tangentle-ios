# Step 7: Workflow - /plan-feature

## Problem Type
`migration`

## Technique Selection
- **Planning**: least-to-most - Build plan structure piece by piece
- **Implementation**: chain-of-code - Complex file generation
- **Verification**: reflexion - Learn from artifact generation issues

## Risk Level
**medium** - Core workflow; generates multiple artifacts

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
`/plan-feature` is the core plan creation workflow. It creates the plan folder structure, generates all core artifacts (plan.md, adr.md, steps/, progress.json, context.md), assigns techniques to steps, and initializes the planning state.

## Goal
Create the `/plan-feature` workflow that generates complete plan artifacts with technique metadata and step decomposition.

## Prerequisites
- Step 1 completed (directory structure)
- Step 2 completed (Python scripts)
- Step 3 completed (templates)
- Step 6 completed (establishes workflow pattern)

## High-Level Steps
1. Parse feature description from user input
2. Determine next plan number
3. Create plan directory and subdirectories
4. Generate plan.md with Tree of Thought analysis
5. Generate adr.md with architectural decisions
6. Decompose into steps with technique assignments
7. Generate step files
8. Create progress.json with full metadata
9. Create context.md
10. Update .gitignore if needed
11. Output summary with next commands

## Detailed Requirements

### Plan Number Detection
```bash
# Find highest existing plan number
ls -d .windsurf/plans/[0-9]* 2>/dev/null | sort -V | tail -1
# If none exist, use 001; otherwise increment
```

### Directory Creation
Create: `.windsurf/plans/{NNN}-{slug}/`
Subdirectories: `steps/`, `prompts/`, `reviews/`

### Artifact Generation

#### plan.md
- Use template from `.windsurf/templates/plan.md.template`
- Fill in: plan number, title, created date, steps table, technique matrix
- Include Tree of Thought analysis for major decisions

#### adr.md
- Use template from `.windsurf/templates/adr.md.template`
- Document key architectural decisions
- Include options considered with pros/cons

#### Step Files
For each step:
1. Classify step's problem type (may differ from plan type)
2. Select techniques via: `python3 .windsurf/scripts/windsurf_plan.py techniques {type}`
3. Assess risk via: `python3 .windsurf/scripts/windsurf_plan.py risk {type}`
4. Generate step file from template

#### progress.json
- Use template from `.windsurf/templates/progress.json.template`
- Include all step metadata with technique assignments
- Initialize all steps as "pending"
- Set `createdAt` and `updatedAt` to current timestamp

#### context.md
- Use template from `.windsurf/templates/context.md.template`
- Initialize with plan overview
- Empty sections for tracking

### .gitignore Update
On first plan creation, ensure `.gitignore` contains:
```
# Windsurf IDE (local planning system)
.windsurf/**
```

### Output Summary
```markdown
## Plan Created: {NNN}-{feature-slug}

**Feature**: {Feature Name}
**Steps**: {N} implementation steps
**Location**: .windsurf/plans/{NNN}-{feature-slug}/

### Files Created
- plan.md - Main plan document
- adr.md - Architecture decisions
- steps/ - {N} step files
- progress.json - Progress tracking
- context.md - Context preservation

### Technique Matrix
| Step | Type | Planning | Implementation | Verification |
|------|------|----------|----------------|--------------|
{table rows}

### Next Commands
1. `/plan-prompts {NNN}` - Generate AI prompts for each step
2. `/plan-next {NNN}` - Start implementing first step
3. `/plan-status {NNN}` - Check progress anytime
```

## Files to Create
- `.windsurf/workflows/plan-feature.md`

## Files to Modify
- `.gitignore` (if not already updated)

## Patterns to Follow
Reference: `.claude/commands/plan-feature.md` for structure
Reference: `.claude/plans/004-intelligent-planning-system-v2/` for artifact examples

## Acceptance Criteria
- [ ] Workflow file under 12,000 characters
- [ ] Creates plan directory with correct structure
- [ ] Generates all 5 core artifacts
- [ ] Steps have technique assignments from Python scripts
- [ ] Steps have risk levels and retry configs
- [ ] progress.json is valid JSON
- [ ] .gitignore updated if needed
- [ ] Output includes next command suggestions

## Testing Requirements

### Unit Tests
**N/A** - Workflow tested via execution.

### Integration Tests
- [ ] Run `/plan-feature Add user authentication` in Cascade
- [ ] Verify plan directory created
- [ ] Verify plan.md contains Tree of Thought
- [ ] Verify each step file has technique assignments
- [ ] Verify progress.json is valid JSON
- [ ] Verify output shows next commands

### Manual Verification
- [ ] Plan number increments correctly
- [ ] Slug generated from feature name
- [ ] All files created in correct locations

## Verification Commands
```bash
# After running workflow, verify structure
ls -la .windsurf/plans/001-*

# Verify all files exist
ls .windsurf/plans/001-*/plan.md
ls .windsurf/plans/001-*/adr.md
ls .windsurf/plans/001-*/progress.json
ls .windsurf/plans/001-*/context.md
ls .windsurf/plans/001-*/steps/

# Verify JSON validity
python3 -m json.tool .windsurf/plans/001-*/progress.json > /dev/null

# Check gitignore
grep ".windsurf" .gitignore
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check Python script outputs for errors
2. Verify template placeholders are replaced
3. Check file permissions on plan directory
4. Validate JSON syntax if progress.json fails

## Do NOT
- Create prompts directory content (that's /plan-prompts)
- Begin implementation (that's /plan-next)
- Skip technique assignment for any step
- Commit any changes automatically
