# Step 8: Workflow - /plan-prompts

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Structured prompt generation approach
- **Implementation**: tdd - Test prompt output format
- **Verification**: reflexion - Learn from prompt quality issues

## Risk Level
**high** - Prompt quality directly affects implementation quality

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 3 attempts
- Escalation: After 5 total failures

## Context
`/plan-prompts` generates AI prompts for each step in a plan. Each prompt embeds the full technique instructions (per user preference) and includes all context needed for successful execution. Prompt quality is critical for implementation quality.

## Goal
Create the `/plan-prompts` workflow that generates comprehensive, technique-embedded prompts for each plan step.

## Prerequisites
- Step 4 completed (technique knowledge files)
- Step 7 completed (/plan-feature creates step files)

## High-Level Steps
1. Load plan state from progress.json
2. Load technique content from knowledge files
3. For each step:
   - Read step file
   - Get technique assignments
   - Load technique documentation
   - Generate prompt with embedded technique
   - Write to prompts/ directory
4. Update progress.json (promptGenerated = true per step)
5. Output generation summary

## Detailed Requirements

### Prompt Structure
Each prompt file should contain:

```markdown
# Step {N}: {Step Title}

## Mission
You are implementing step {N} of plan {NNN}: {Plan Title}.
Your objective: {Step goal from step file}

## Context
### Plan Overview
{Brief plan description}

### Why This Step
{Why this step is needed, what it builds on}

### Previous Work
{What was done in previous steps}

## Pre-Implementation Checklist
- [ ] Read and understand the step requirements
- [ ] Review related existing code
- [ ] Identify files to create/modify
- [ ] Understand testing requirements

## Specification

### Goals
{From step file}

### Requirements
{From step file}

### Files to Create
{From step file}

### Files to Modify
{From step file}

### Patterns to Follow
{From step file}

## Technique: {Technique Name}

{FULL technique documentation from .windsurf/knowledge/techniques/{technique}.md}

### Phase-Based Execution
Apply this technique in three phases:

**Planning Phase** ({planning_technique}):
{Instructions for planning}

**Implementation Phase** ({impl_technique}):
{Instructions for implementation}

**Verification Phase** ({verify_technique}):
{Instructions for verification}

## Step-by-Step Instructions
{Numbered steps from step file}

## Edge Cases to Handle
{From step file or inferred}

## Acceptance Criteria
{From step file}

## Verification Commands
\`\`\`bash
{Commands from step file}
\`\`\`

## Error Recovery
If verification fails:
{Recovery steps from step file}

## Completion Protocol
When this step is complete:
1. Ensure all acceptance criteria are met
2. Run verification commands
3. Document any deviations or learnings
4. Report completion status
```

### Technique Embedding
For each step:
1. Get primary technique from `step.techniques.implementation[0]`
2. Read full content from `.windsurf/knowledge/techniques/{technique}.md`
3. Embed in prompt under "## Technique" section

### Progress Update
After generating all prompts:
```json
{
  "steps": [{
    "promptGenerated": true
  }]
}
```

### Output Format
```markdown
## Prompts Generated: Plan {NNN}

**Plan**: {Plan Title}
**Steps**: {N} prompts generated

### Generated Files
| Step | Prompt File | Technique | Size |
|------|-------------|-----------|------|
| 1 | 01-step-name.prompt.md | tdd | 15KB |
| 2 | 02-step-name.prompt.md | reflexion | 12KB |
| ... | ... | ... | ... |

### Technique Distribution
- TDD: {N} steps
- Reflexion: {N} steps
- Self-Refine: {N} steps

### Next Commands
- `/plan-next {NNN}` - Start implementing first step
- `/plan-status {NNN}` - View plan status
```

## Files to Create
- `.windsurf/workflows/plan-prompts.md`

## Files to Modify
- Existing plan's `progress.json` (sets promptGenerated)

## Patterns to Follow
Reference: `.claude/commands/plan-prompts.md` for structure
Reference: `.claude/plans/002-fluid-ui-gestures/prompts/` for examples

## Acceptance Criteria
- [ ] Workflow file under 12,000 characters
- [ ] Generates prompt file for each step
- [ ] Each prompt contains full technique documentation
- [ ] Prompts include all required sections
- [ ] progress.json updated with promptGenerated=true
- [ ] Output shows generation summary

## Testing Requirements

### Unit Tests
**N/A** - Workflow tested via execution.

### Integration Tests
- [ ] Create a test plan with 3 steps
- [ ] Run `/plan-prompts {plan-number}`
- [ ] Verify 3 prompt files created
- [ ] Verify each prompt has technique embedded
- [ ] Verify progress.json updated
- [ ] Verify output shows summary table

### Manual Verification
- [ ] Prompt files are readable and well-formatted
- [ ] Technique sections contain complete instructions
- [ ] No placeholder text remains in prompts

## Verification Commands
```bash
# List generated prompts
ls -la .windsurf/plans/{NNN}-*/prompts/

# Check prompt sizes (technique embedding makes them large)
wc -l .windsurf/plans/{NNN}-*/prompts/*.prompt.md

# Verify technique sections exist
grep -l "## Technique" .windsurf/plans/{NNN}-*/prompts/*.prompt.md | wc -l

# Verify progress updated
python3 -c "
import json
with open('.windsurf/plans/{NNN}-xxx/progress.json') as f:
    p = json.load(f)
    print('Prompts generated:', all(s.get('promptGenerated') for s in p['steps']))
"
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check technique file paths exist
2. Verify step files have required sections
3. Check file write permissions
4. Validate JSON after progress update

## Do NOT
- Generate partial prompts (all or nothing)
- Skip technique embedding (user requirement)
- Leave placeholder text in prompts
- Modify step files (only read them)
