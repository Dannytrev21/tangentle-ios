# Step 7: Update plan-feature

## Context
The `/plan-feature` command creates the full implementation plan. With techniques now selected, we need to embed this metadata into the plan structure and step files.

## Goal
Update the `/plan-feature` command to include technique selection in plans, add technique metadata to progress.json, and generate technique-aware step files.

## Problem Type
`refactor`

## Technique Selection
- **Planning**: PS+ (structured modification)
- **Implementation**: Self-Refine (iterate on integration quality)
- **Verification**: TDD (test plan generation)

## Risk Level
**Medium** - Core planning command modification

## Prerequisites
- Steps 1-6 completed (infrastructure and initial command)

## High-Level Steps
1. Analyze current plan-feature.md
2. Add technique selection to plan creation
3. Modify step file template to include techniques
4. Update progress.json schema with technique fields
5. Add technique rationale to context.md
6. Integrate risk assessment per step
7. Test the updated command

## Detailed Requirements

### Current Plan Creation Flow
1. Analyze feature request
2. Determine plan number
3. Create plan directory
4. Apply Tree of Thought analysis
5. Create plan.md, adr.md
6. Create step files
7. Create progress.json, context.md

### New Plan Creation Flow
1. Analyze feature request
2. **NEW: Get problem type from /plan-feature-initial or detect**
3. Determine plan number
4. Create plan directory
5. Apply Tree of Thought analysis (with technique-aware decisions)
6. **NEW: For each step, classify sub-problem and select techniques**
7. **NEW: Assess risk per step**
8. Create plan.md (with technique matrix), adr.md
9. Create step files (with technique assignments)
10. Create progress.json (with technique metadata), context.md

### Changes to plan-feature.md

#### New Section: Step Technique Assignment

```markdown
### Step 6.5: Assign Techniques to Steps (NEW)

For each step in the plan:

1. **Classify Step Problem Type**
   - Analyze step description
   - May differ from overall plan type
   - e.g., A "new-feature" plan may have "test-setup" and "ui" steps

2. **Select Techniques**
\`\`\`python
from technique_selector import TechniqueSelector, Phase
selector = TechniqueSelector()

for step in steps:
    step_type = classify_step(step.description)
    step.techniques = {
        Phase.PLANNING: selector.select_techniques(step_type, Phase.PLANNING),
        Phase.IMPLEMENTATION: selector.select_techniques(step_type, Phase.IMPLEMENTATION),
        Phase.VERIFICATION: selector.select_techniques(step_type, Phase.VERIFICATION),
    }
\`\`\`

3. **Assess Risk**
\`\`\`python
from risk_assessor import RiskAssessor
assessor = RiskAssessor()

for step in steps:
    step.risk = assessor.assess_risk(step)
\`\`\`
```

#### Updated plan.md Template

```markdown
## Technique Matrix

| Step | Problem Type | Planning | Implementation | Verification | Risk |
|------|--------------|----------|----------------|--------------|------|
| 1 | {step_type} | {tech} | {tech} | {tech} | {level} |
| 2 | {step_type} | {tech} | {tech} | {tech} | {level} |
| ... | ... | ... | ... | ... | ... |

## Implementation Steps (Updated)

| Step | Name | Description | Status | Type | Risk |
|------|------|-------------|--------|------|------|
| 1 | {name} | {desc} | Pending | {type} | {risk} |
```

#### Updated Step File Template

```markdown
# Step {N}: {Step Name}

## Problem Type
\`{step_problem_type}\`

## Technique Selection
- **Planning**: {technique} - {rationale}
- **Implementation**: {technique} - {rationale}
- **Verification**: {technique} - {rationale}

## Risk Level
**{level}** - {explanation}

## Retry Configuration
- Same technique: {n} attempts
- Alternative technique: {n} attempts
- Escalation: After {n} total failures

## Context
{Why this step is needed}

... rest of step template ...
```

#### Updated progress.json Schema

```json
{
  "planId": "{NNN}",
  "name": "{feature-slug}",
  "problemType": "{overall_type}",
  "problemCategory": "{category}",
  "techniqueProfile": {
    "defaultPlanning": "{technique}",
    "defaultImplementation": "{technique}",
    "defaultVerification": "{technique}"
  },
  "steps": [
    {
      "id": 1,
      "name": "{step-slug}",
      "title": "{Step Title}",
      "problemType": "{step_type}",
      "status": "pending",
      "techniques": {
        "planning": "{technique}",
        "implementation": ["{technique}", "{technique}"],
        "verification": "{technique}"
      },
      "techniqueRationale": "{why these techniques}",
      "riskLevel": "{low|medium|high|critical}",
      "riskScore": 0.0,
      "retryConfig": {
        "maxSameTechnique": 2,
        "maxAlternative": 1,
        "maxTotal": 5
      },
      "attempts": 0,
      "techniquesUsed": [],
      "promptGenerated": false,
      "startedAt": null,
      "completedAt": null
    }
  ]
}
```

## Files to Create
- None (modifying existing)

## Files to Modify
- `.claude/commands/plan-feature.md`: Add technique and risk integration

## Patterns to Follow
Reference: Current plan-feature.md structure (lines 1-402)

## Acceptance Criteria
- [ ] Step problem types are classified individually
- [ ] Techniques are assigned per step per phase
- [ ] Risk levels are assessed per step
- [ ] progress.json includes technique metadata
- [ ] Step files include technique assignments
- [ ] Technique rationale is documented
- [ ] Works without Python scripts (fallback)

## Testing Requirements

### Manual Testing
- [ ] Run `/plan-feature Add user authentication` and verify:
  - Technique matrix appears in plan.md
  - Each step has problem type and techniques
  - progress.json has technique fields
  - Step files have technique sections

### Schema Validation
```bash
# Verify progress.json schema
python3 -c "
import json
progress = json.load(open('.claude/plans/NNN-slug/progress.json'))
assert 'techniqueProfile' in progress
assert 'techniques' in progress['steps'][0]
print('Schema validation passed')
"
```

## Verification Commands
```bash
# Check plan.md has technique matrix
grep -q "Technique Matrix" .claude/commands/plan-feature.md && echo "Matrix section added"

# Check progress.json schema updated
grep -q "techniqueProfile" .claude/commands/plan-feature.md && echo "Schema updated"
```

## Documentation Updates
- [ ] Update plan structure documentation in CLAUDE.md

## Error Recovery
If technique assignment fails:
1. Use default techniques from config
2. Mark step with "technique-assignment-failed" note
3. Continue with plan creation

## Do NOT
- Break existing plan file structure
- Require techniques for old plans to work
- Remove any existing plan fields
