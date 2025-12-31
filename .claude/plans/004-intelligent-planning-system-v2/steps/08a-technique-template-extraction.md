# Step 8a: Technique Template Extraction

## Context
Before embedding techniques into prompts, we need to extract and structure the existing technique templates so they can be programmatically composed.

## Goal
Extract the existing technique templates (ToT, TDD, Reflexion, etc.) into a structured format that can be parsed and composed by the prompt generation system.

## Problem Type
`data-modeling`

## Technique Selection
- **Planning**: PS+ (structured extraction process)
- **Implementation**: Self-Refine (iterate on template structure)
- **Verification**: TDD (test template parsing)

## Risk Level
**Medium** - Foundation for Step 8b, must be correct

## Prerequisites
- Step 1 completed (config schema exists)
- Existing technique templates exist in `.claude/commands/`

## High-Level Steps
1. Analyze existing technique template structures
2. Design unified template schema
3. Create template parser
4. Extract sections from each technique
5. Write structured templates to JSON/Python
6. Test template loading

## Detailed Requirements

### Template Schema
Each technique template should expose:

```python
@dataclass
class TechniqueTemplate:
    id: str                    # e.g., "tdd", "reflexion"
    name: str                  # Human-readable name
    description: str           # When to use
    planning_section: str      # Markdown for planning phase
    implementation_section: str # Markdown for implementation phase
    verification_section: str  # Markdown for verification phase
    error_recovery_section: str # How to handle failures
    placeholders: list[str]    # Variables to substitute (e.g., {task}, {context})
```

### Section Extraction Markers
Add markers to existing technique files to delimit sections:

```markdown
<!-- SECTION:PLANNING -->
## Planning Phase
...
<!-- /SECTION:PLANNING -->

<!-- SECTION:IMPLEMENTATION -->
## Implementation Phase
...
<!-- /SECTION:IMPLEMENTATION -->

<!-- SECTION:VERIFICATION -->
## Verification Phase
...
<!-- /SECTION:VERIFICATION -->

<!-- SECTION:ERROR_RECOVERY -->
## Error Recovery
...
<!-- /SECTION:ERROR_RECOVERY -->
```

### Template Parser

```python
def parse_technique_template(filepath: str) -> TechniqueTemplate:
    """
    Parse a technique markdown file into structured template.

    Handles:
    - Files with explicit section markers
    - Files without markers (legacy - use heuristics)
    """
    content = Path(filepath).read_text()

    if "<!-- SECTION:" in content:
        return parse_marked_template(content)
    else:
        return parse_legacy_template(content)

def parse_marked_template(content: str) -> TechniqueTemplate:
    """Extract sections using markers."""
    pattern = r'<!-- SECTION:(\w+) -->(.*?)<!-- /SECTION:\1 -->'
    matches = re.findall(pattern, content, re.DOTALL)
    sections = {name: text.strip() for name, text in matches}
    return TechniqueTemplate(
        planning_section=sections.get('PLANNING', ''),
        implementation_section=sections.get('IMPLEMENTATION', ''),
        verification_section=sections.get('VERIFICATION', ''),
        error_recovery_section=sections.get('ERROR_RECOVERY', '')
    )
```

### Files to Modify
Add section markers to these technique templates:
- `.claude/commands/tdd.md`
- `.claude/commands/tot.md`
- `.claude/commands/reflexion.md`
- `.claude/commands/self-refine.md`
- `.claude/commands/self-consistency.md`
- `.claude/commands/react.md`
- `.claude/commands/ps-plus.md`
- `.claude/commands/chain-of-code.md`
- `.claude/commands/got.md`
- `.claude/commands/least-to-most.md`

## Files to Create
- `.claude/scripts/template_parser.py`: Template extraction logic
- `.claude/scripts/test_template_parser.py`: Unit tests
- `.claude/templates/`: Directory for structured templates (optional)

## Files to Modify
- All 10 technique command files: Add section markers

## Acceptance Criteria
- [ ] All 10 technique templates have section markers
- [ ] Parser extracts all sections correctly
- [ ] Templates load without errors
- [ ] Missing sections fall back to empty string
- [ ] Placeholders are identified in each template
- [ ] Unit tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/scripts/test_template_parser.py`
- [ ] Test cases:
  - `test_parse_marked_template_extracts_sections()`
  - `test_parse_legacy_template_uses_heuristics()`
  - `test_missing_section_returns_empty_string()`
  - `test_all_techniques_parse_successfully()`

## Verification Commands
```bash
# Test parser
python3 -c "
from template_parser import parse_technique_template
for tech in ['tdd', 'tot', 'reflexion']:
    template = parse_technique_template(f'.claude/commands/{tech}.md')
    assert template.implementation_section, f'{tech} missing implementation'
    print(f'{tech}: OK')
"
```

## Error Recovery
If a template cannot be parsed:
1. Log warning with template path
2. Return template with empty sections
3. Continue - prompt generator will handle missing sections

## Do NOT
- Break existing technique commands
- Remove any content from templates
- Add markers that interfere with normal usage
