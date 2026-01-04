---
name: plan-prompts
description: Generate technique-embedded AI prompts for plan steps
---

# Plan Prompts

Generate comprehensive prompts for each step in a plan, embedding full technique documentation for self-contained execution.

## Instructions

When invoked with a plan number:

### Step 1: Load Plan

If plan number provided:
```bash
PLAN_DIR=$(ls -d .windsurf/plans/$ARGS* 2>/dev/null | head -1)
```

If not found:
```bash
ls .windsurf/plans/ | head -5
```
Then ask user to specify.

### Step 2: Read Plan Metadata

Load `$PLAN_DIR/progress.json`:
- Extract `planId`, `title`, `description`
- Get all steps with their technique assignments
- Note total steps and current state

### Step 3: Create Prompts Directory

```bash
mkdir -p $PLAN_DIR/prompts
```

### Step 4: For Each Step, Generate Prompt

Loop through steps array in progress.json:

#### 4a. Read Step File
```bash
cat $PLAN_DIR/steps/{NN}-{step-name}.md
```

Extract from step file:
- Goal and requirements
- Problem type
- Technique assignments (planning/implementation/verification)
- Acceptance criteria
- Verification commands
- Testing requirements

#### 4b. Load Technique Documentation

For the primary implementation technique:
```bash
cat .windsurf/knowledge/techniques/{technique}.md
```

This content will be embedded inline in the prompt.

#### 4c. Compose Prompt Using Template

Read template: `.windsurf/templates/prompt.md.template`

Fill placeholders with step data. The prompt must include:

1. **Mission**: One clear sentence goal
2. **Context**: Plan summary, this step's purpose, dependencies
3. **Technique Assignment**: Table with phase/technique/rationale
4. **Technique Instructions**: FULL embedded content from technique .md file
5. **Pre-Implementation Checklist**: Files to read, prerequisites
6. **Specification**: Goals, requirements, code structure
7. **Implementation Guide**: Step-by-step instructions
8. **Acceptance Criteria**: All criteria with verification commands
9. **Verification Protocol**: Commands with expected outputs
10. **Testing Requirements**: Unit/integration/manual tests
11. **Error Recovery**: Common failures and how to fix
12. **Completion Protocol**: How to update progress.json and context.md
13. **Do NOT**: Things to avoid

#### 4d. Write Prompt File

```bash
# Write to prompts directory
echo "$PROMPT_CONTENT" > $PLAN_DIR/prompts/{NN}-{step-name}.prompt.md
```

File naming: `{NN}-{step-slug}.prompt.md` (e.g., `01-directory-structure.prompt.md`)

### Step 5: Update Progress

For each step in progress.json:
```json
"promptGenerated": true
```

Update the progress.json file with:
```bash
# Use Python for JSON updates
python3 -c "
import json
with open('$PLAN_DIR/progress.json', 'r') as f:
    p = json.load(f)
for s in p['steps']:
    s['promptGenerated'] = True
with open('$PLAN_DIR/progress.json', 'w') as f:
    json.dump(p, f, indent=2)
"
```

### Step 6: Output Summary

Display generation report:

```
========================================
  PROMPTS GENERATED: Plan {NNN}
========================================

**Plan**: {Plan Title}
**Steps**: {N} prompts generated
**Location**: .windsurf/plans/{NNN}-{slug}/prompts/

## Generated Files
| Step | File | Technique | Size |
|------|------|-----------|------|
| 1 | 01-{name}.prompt.md | {tech} | {KB} |
| 2 | 02-{name}.prompt.md | {tech} | {KB} |
...

## Technique Distribution
- TDD: {N} steps
- Self-Refine: {N} steps
- Chain-of-Code: {N} steps
- Reflexion: {N} (verification)

## Next Commands
1. `/plan-next {NNN}` - Start implementing step 1
2. `/plan-status {NNN}` - View plan progress
========================================
```

## Prompt Template Structure

Each generated prompt follows this structure:

```markdown
# Prompt: Step {N} - {Step Title}

## Mission
{One clear sentence describing what to accomplish}

## Context
You are implementing step {N} of {total} in the "{Plan Title}" plan.

**Plan Summary**: {Brief description}
**This Step**: {Purpose and what it enables}
**Dependencies**:
- Requires: {Previous steps that must be complete}
- Enables: {Steps that depend on this one}

## Technique Assignment
| Phase | Technique | Why |
|-------|-----------|-----|
| Planning | {technique} | {rationale} |
| Implementation | {technique} | {rationale} |
| Verification | {technique} | {rationale} |

## Technique Instructions: {Primary Technique}

{FULL CONTENT FROM .windsurf/knowledge/techniques/{technique}.md}

(This section should be 1000+ words with complete instructions)

## Pre-Implementation Checklist
[From step file]

## Specification
[Goals, requirements from step file]

## Implementation Guide
[Step-by-step instructions]

## Acceptance Criteria
[All criteria with verification commands]

## Verification Protocol
[Commands with expected outputs]

## Testing Requirements
[Unit tests, integration tests, manual verification]

## Error Recovery
[Common failures and how to fix]

## Completion Protocol
[How to update progress.json and context.md]

## Do NOT
[Things to avoid]
```

## Quality Standards

### Technique Embedding
- Full technique content embedded inline (not referenced)
- Includes Overview, When to Use, How It Works, Execution Instructions
- Substantial content (1000+ words)

### Completeness
- Each prompt is self-contained (zero prior context needed)
- All file paths relative to project root
- All commands copy-pasteable
- All expected outputs specified

### Verification Rigor
- Every acceptance criterion has verification command
- Every verification has expected output
- Clear pass/fail definitions

## Error Recovery

### Technique File Not Found
1. Check technique name: `ls .windsurf/knowledge/techniques/`
2. Verify spelling matches step's technique assignment
3. Fall back to default technique if missing

### Step File Not Found
1. Check step files exist: `ls $PLAN_DIR/steps/`
2. Verify step numbering is sequential
3. Generate prompts only for existing steps

### JSON Parse Error
1. Validate progress.json: `python3 -c "import json; json.load(open('$PLAN_DIR/progress.json'))"`
2. Fix JSON syntax errors
3. Retry prompt generation

## Do NOT

- Do NOT generate partial prompts (all steps or none)
- Do NOT skip technique embedding (must be inline)
- Do NOT leave placeholder text like `{{PLACEHOLDER}}`
- Do NOT modify step files (read-only)
- Do NOT skip promptGenerated flag update
- Do NOT use technique references (embed full content)
