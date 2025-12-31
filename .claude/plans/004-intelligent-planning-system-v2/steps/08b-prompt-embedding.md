# Step 8b: Prompt Embedding

## Context
With technique templates structured (Step 8a), we can now embed them into step prompts to create technique-aware execution prompts.

## Goal
Update the `/plan-prompts` command to generate prompts that embed the appropriate technique methodology for each phase (planning, implementation, verification).

## Problem Type
`system-design`

## Technique Selection
- **Planning**: ToT (explore embedding strategies)
- **Implementation**: Self-Refine (iterate on prompt quality)
- **Verification**: Reflexion (learn from generated prompt issues)

## Risk Level
**High** - Prompt quality directly affects execution quality

## Prerequisites
- Step 8a completed (templates are parsed and structured)
- Steps 1-7 completed (config, scripts, command updates)

## High-Level Steps
1. Design prompt composition algorithm
2. Implement template substitution
3. Handle multi-technique composition
4. Add prompt length management
5. Update plan-prompts.md command
6. Test with various technique combinations

## Detailed Requirements

### Prompt Composition Algorithm

```python
def compose_prompt(
    step: StepInfo,
    templates: dict[str, TechniqueTemplate],
    step_requirements: str
) -> str:
    """
    Compose a technique-embedded prompt for a step.

    1. Get technique assignments for each phase
    2. Load corresponding templates
    3. Substitute placeholders
    4. Merge with step requirements
    5. Validate length
    """

    # 1. Get techniques
    planning_tech = step.techniques["planning"]
    impl_techs = step.techniques["implementation"]  # May be list
    verify_tech = step.techniques["verification"]

    # 2. Load templates
    planning_template = templates.get(planning_tech)
    impl_templates = [templates.get(t) for t in impl_techs]
    verify_template = templates.get(verify_tech)

    # 3. Build prompt sections
    prompt_parts = [
        "# Prompt: Step {N} - {Step Name}\n",
        "## Mission\n{step_mission}\n",
        "## Context\n{step_context}\n",
    ]

    # Planning section
    if planning_template and planning_template.planning_section:
        prompt_parts.append(
            f"## Planning Methodology: {planning_tech.upper()}\n"
            f"{planning_template.planning_section}\n"
        )

    # Step requirements
    prompt_parts.append(
        "## Specification\n{step_requirements}\n"
    )

    # Implementation section(s)
    if len(impl_templates) == 1:
        t = impl_templates[0]
        if t and t.implementation_section:
            prompt_parts.append(
                f"## Implementation Methodology: {impl_techs[0].upper()}\n"
                f"{t.implementation_section}\n"
            )
    elif len(impl_templates) > 1:
        prompt_parts.append(
            f"## Implementation Methodology: {' + '.join(t.upper() for t in impl_techs)}\n"
        )
        for i, t in enumerate(impl_templates):
            if t and t.implementation_section:
                prompt_parts.append(
                    f"### Phase {i+1}: {impl_techs[i].upper()}\n"
                    f"{t.implementation_section}\n"
                )

    # Verification section
    if verify_template and verify_template.verification_section:
        prompt_parts.append(
            f"## Verification Methodology: {verify_tech.upper()}\n"
            f"{verify_template.verification_section}\n"
        )

    # Acceptance criteria
    prompt_parts.append(
        "## Acceptance Criteria\n{step_acceptance_criteria}\n"
    )

    # Error recovery (technique-specific)
    if verify_template and verify_template.error_recovery_section:
        prompt_parts.append(
            f"## Error Recovery ({verify_tech.upper()})\n"
            f"{verify_template.error_recovery_section}\n"
        )

    # Completion protocol
    prompt_parts.append(
        "## Completion Protocol\n{standard_completion}\n"
    )

    # 4. Substitute placeholders
    prompt = "\n".join(prompt_parts)
    prompt = substitute_placeholders(prompt, step, step_requirements)

    # 5. Validate length
    if len(prompt) > 50000:  # ~3000 lines
        prompt = truncate_with_summary(prompt)

    return prompt
```

### Multi-Technique Handling

When multiple techniques are assigned to implementation:

1. **Sequential composition**: Techniques execute in order
   - TDD first (write tests)
   - Self-Refine second (polish implementation)

2. **Section merging**: Each technique's section is labeled clearly
   - "### Phase 1: TDD"
   - "### Phase 2: Self-Refine"

3. **Conflict resolution**: If techniques conflict:
   - TDD says "write tests first"
   - Self-Refine says "implement, then iterate"
   - Resolution: TDD takes precedence for test creation, Self-Refine for polish

### Placeholder Substitution

```python
STANDARD_PLACEHOLDERS = {
    "{step_number}": step.id,
    "{step_name}": step.title,
    "{step_mission}": step.goal,
    "{step_context}": step.context,
    "{step_requirements}": step_requirements,
    "{step_acceptance_criteria}": format_criteria(step.acceptance_criteria),
    "{plan_name}": plan.title,
    "{plan_dir}": f".claude/plans/{plan.id}-{plan.name}",
    "{technique_planning}": step.techniques["planning"],
    "{technique_impl}": ", ".join(step.techniques["implementation"]),
    "{technique_verify}": step.techniques["verification"],
}

def substitute_placeholders(prompt: str, step: StepInfo, requirements: str) -> str:
    for placeholder, value in STANDARD_PLACEHOLDERS.items():
        prompt = prompt.replace(placeholder, str(value))
    return prompt
```

### Prompt Length Management

```python
MAX_PROMPT_LENGTH = 50000  # characters

def truncate_with_summary(prompt: str) -> str:
    """
    If prompt exceeds limit:
    1. Keep mission, context, acceptance criteria (required)
    2. Summarize long technique sections
    3. Add note about truncation
    """
    if len(prompt) <= MAX_PROMPT_LENGTH:
        return prompt

    # Find technique sections
    sections = split_by_headers(prompt)

    # Summarize verbose sections
    for section in sections:
        if len(section) > 5000 and "Methodology" in section:
            sections[section] = summarize_section(section, max_length=2000)

    truncated = join_sections(sections)
    truncated += "\n\n> Note: Some technique details were summarized due to length."
    return truncated
```

## Files to Create
- `.claude/scripts/prompt_composer.py`: Main composition logic
- `.claude/scripts/test_prompt_composer.py`: Unit tests

## Files to Modify
- `.claude/commands/plan-prompts.md`: Integrate prompt composer

## Acceptance Criteria
- [ ] Single-technique prompts generate correctly
- [ ] Multi-technique prompts compose without conflicts
- [ ] Placeholders are all substituted
- [ ] Prompt length is managed
- [ ] Generated prompts are self-contained
- [ ] Unit tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/scripts/test_prompt_composer.py`
- [ ] Test cases:
  - `test_compose_single_technique_prompt()`
  - `test_compose_multi_technique_prompt()`
  - `test_placeholder_substitution()`
  - `test_prompt_truncation()`
  - `test_missing_template_uses_fallback()`

### Manual Verification
```bash
# Generate a test prompt
python3 -c "
from prompt_composer import compose_prompt
from template_parser import load_all_templates

templates = load_all_templates()
step = MockStep(techniques={'planning': 'tot', 'implementation': ['tdd'], 'verification': 'reflexion'})
prompt = compose_prompt(step, templates, 'Write a sort function')
print(prompt[:2000])
"
```

## Verification Commands
```bash
# Run tests
cd .claude/scripts && python3 -m pytest test_prompt_composer.py -v

# Check command updated
grep -q "prompt_composer" .claude/commands/plan-prompts.md
```

## Error Recovery
If prompt composition fails:
1. Fall back to generic prompt template (pre-v2)
2. Log which technique failed
3. Mark prompt as "degraded" in progress.json

## Do NOT
- Generate prompts that reference external files (must be self-contained)
- Exceed prompt length limits without truncation
- Lose step requirements in technique sections
