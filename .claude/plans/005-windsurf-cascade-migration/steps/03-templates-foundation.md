# Step 3: Templates Foundation

## Problem Type
`scaffolding`

## Technique Selection
- **Planning**: ps-plus - Structured template design
- **Implementation**: chain-of-code - Mixed markdown/JSON template creation
- **Verification**: self-refine - Validate template placeholders

## Risk Level
**low** - Creating template files; easily modified or replaced

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Context
Template files provide reusable structures for plan artifacts. Workflows will read these templates and fill in placeholders to generate consistent output. Templates must stay under Windsurf's character limits while containing complete structure.

## Goal
Create template files for all plan artifacts (plan.md, adr.md, step.md, prompt.md, progress.json, context.md) that workflows can use for generation.

## Prerequisites
- Step 1 completed (`.windsurf/templates/` directory exists)

## High-Level Steps
1. Create plan.md template with Tree of Thought structure
2. Create adr.md template with decision documentation format
3. Create step.md template with technique/testing sections
4. Create prompt.md template with full technique embedding placeholder
5. Create progress.json template with all metadata fields
6. Create context.md template for session preservation
7. Validate all templates have correct placeholders

## Detailed Requirements

### Template Placeholders
Use `{{PLACEHOLDER_NAME}}` syntax for variable substitution:
- `{{PLAN_NUMBER}}` - 3-digit plan number (e.g., "005")
- `{{PLAN_SLUG}}` - kebab-case name (e.g., "windsurf-migration")
- `{{PLAN_TITLE}}` - Human-readable title
- `{{CREATED_DATE}}` - ISO date of creation
- `{{STEP_NUMBER}}` - 2-digit step number
- `{{STEP_NAME}}` - Step slug
- `{{STEP_TITLE}}` - Step human title
- `{{PROBLEM_TYPE}}` - Classified problem type
- `{{TECHNIQUES}}` - Technique assignments block
- `{{CONTENT}}` - Main content placeholder

### Template Character Limits
Each template should be designed to produce output under Windsurf limits:
- plan.md template: ~5000 chars (expands with steps)
- adr.md template: ~4000 chars
- step.md template: ~3000 chars (per step)
- prompt.md template: ~2000 chars base (+ technique content)
- progress.json template: ~2000 chars base (+ steps array)
- context.md template: ~1500 chars base

## Files to Create
- `.windsurf/templates/plan.md.template`
- `.windsurf/templates/adr.md.template`
- `.windsurf/templates/step.md.template`
- `.windsurf/templates/prompt.md.template`
- `.windsurf/templates/progress.json.template`
- `.windsurf/templates/context.md.template`

## Files to Modify
None.

## Patterns to Follow
Reference: `.claude/plans/002-fluid-ui-gestures/plan.md` for plan structure
Reference: `.claude/plans/002-fluid-ui-gestures/steps/01-design-tokens.md` for step structure
Reference: `.claude/plans/004-intelligent-planning-system-v2/progress.json` for JSON schema

## Acceptance Criteria
- [ ] All 6 template files created in `.windsurf/templates/`
- [ ] Templates use consistent `{{PLACEHOLDER}}` syntax
- [ ] plan.md template includes Tree of Thought section
- [ ] step.md template includes technique selection and testing sections
- [ ] prompt.md template includes all sections (mission, context, spec, AC, verification)
- [ ] progress.json template is valid JSON when placeholders are strings
- [ ] Each template is under 6000 characters (leaves room for expansion)

## Testing Requirements

### Unit Tests
**N/A** - Templates are static files. Validation is manual.

### Manual Verification
- [ ] Each template file contains correct sections for its artifact type
- [ ] All placeholder names follow the `{{NAME}}` convention
- [ ] progress.json.template parses as valid JSON (with string placeholders)
- [ ] Templates align with Claude Code artifact structures

## Verification Commands
```bash
# Verify all templates exist
ls -la .windsurf/templates/*.template

# Check template sizes (should be under 6000 chars each)
wc -c .windsurf/templates/*.template

# Verify JSON template validity (replace placeholders with test values)
cat .windsurf/templates/progress.json.template | \
  sed 's/{{[^}]*}}/"placeholder"/g' | \
  python3 -m json.tool > /dev/null && echo "Valid JSON"

# Check for placeholder syntax consistency
grep -h '{{' .windsurf/templates/*.template | sort | uniq
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check placeholder syntax: must be `{{NAME}}` with uppercase
2. For JSON parse errors, check for trailing commas or missing quotes
3. Compare section headings with Claude Code artifacts

## Do NOT
- Include technique content in templates (those go in knowledge/)
- Create overly complex nested placeholders
- Use different placeholder syntax than `{{NAME}}`
- Exceed 6000 characters per template (need expansion room)
