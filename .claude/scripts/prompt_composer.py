"""
Prompt Composer for Technique-Embedded Step Prompts

Generates self-contained execution prompts that embed technique methodology
for each phase (planning, implementation, verification).
"""

from dataclasses import dataclass, field
from typing import Optional, Union
from pathlib import Path
import re

from template_parser import TechniqueTemplate, load_all_templates


MAX_PROMPT_LENGTH = 50000  # characters


@dataclass
class StepInfo:
    """Information about a step for prompt generation."""
    id: Union[int, str]
    title: str
    goal: str
    context: str
    problem_type: str
    techniques: dict  # {planning: str, implementation: [str], verification: str}
    acceptance_criteria: list[str]
    files_to_create: list[str] = field(default_factory=list)
    files_to_modify: list[str] = field(default_factory=list)


@dataclass
class PlanInfo:
    """Information about the overall plan."""
    id: str
    name: str
    title: str
    total_steps: int
    plan_dir: str
    description: str = ""


def compose_prompt(
    step: StepInfo,
    plan: PlanInfo,
    templates: dict[str, TechniqueTemplate],
    step_requirements: str
) -> str:
    """
    Compose a technique-embedded prompt for a step.

    Args:
        step: Step information
        plan: Plan information
        templates: Dictionary of loaded technique templates
        step_requirements: The detailed requirements from the step file

    Returns:
        Complete prompt with embedded technique methodology
    """
    # Get technique assignments
    planning_tech = step.techniques.get("planning", "ps-plus")
    impl_techs = step.techniques.get("implementation", ["self-refine"])
    if isinstance(impl_techs, str):
        impl_techs = [impl_techs]
    verify_tech = step.techniques.get("verification", "self-refine")

    # Load templates
    planning_template = templates.get(planning_tech)
    impl_templates = [templates.get(t) for t in impl_techs if templates.get(t)]
    verify_template = templates.get(verify_tech)

    # Build prompt sections
    sections = []

    # Header
    sections.append(f"# Prompt: Step {step.id} - {step.title}\n")

    # Mission
    sections.append(f"## Mission\n{step.goal}\n")

    # Context
    sections.append(f"""## Context
You are implementing step {step.id} of {plan.total_steps} in the "{plan.title}" plan.

**Plan Summary**: {plan.description or plan.title}

**This Step**: {step.context}

**Problem Type**: {step.problem_type}
""")

    # Pre-implementation checklist
    pre_impl = _build_pre_implementation_section(step, plan)
    if pre_impl:
        sections.append(pre_impl)

    # Planning methodology
    if planning_template and planning_template.planning_section:
        sections.append(f"""## Planning Methodology: {planning_tech.upper()}

Use this approach for planning before implementation:

{planning_template.planning_section}
""")

    # Specification
    sections.append(f"## Specification\n\n{step_requirements}\n")

    # Implementation methodology
    impl_section = _build_implementation_section(impl_techs, impl_templates)
    if impl_section:
        sections.append(impl_section)

    # Verification methodology
    if verify_template and verify_template.verification_section:
        sections.append(f"""## Verification Methodology: {verify_tech.upper()}

Use this approach for verification:

{verify_template.verification_section}
""")

    # Acceptance criteria
    ac_list = "\n".join(f"- [ ] **AC{i+1}**: {ac}"
                        for i, ac in enumerate(step.acceptance_criteria))
    sections.append(f"## Acceptance Criteria\n\nAll must pass before marking complete:\n\n{ac_list}\n")

    # Error recovery (from verification technique)
    if verify_template and verify_template.error_recovery_section:
        sections.append(f"""## Error Recovery ({verify_tech.upper()})

{verify_template.error_recovery_section}
""")

    # Completion protocol
    sections.append(_build_completion_protocol(step, plan))

    # Do NOT section
    sections.append("""## Do NOT

- Do NOT skip reading required files first
- Do NOT implement beyond this step's scope
- Do NOT ignore failing tests
- Do NOT forget to update progress.json
- Do NOT leave debugging code
- Do NOT mark complete until ALL criteria pass
""")

    # Combine sections
    prompt = "\n".join(sections)

    # Substitute placeholders
    prompt = substitute_placeholders(prompt, step, plan, step_requirements)

    # Validate and truncate if needed
    if len(prompt) > MAX_PROMPT_LENGTH:
        prompt = truncate_with_summary(prompt)

    return prompt


def _build_pre_implementation_section(step: StepInfo, plan: PlanInfo) -> str:
    """Build the pre-implementation checklist section."""
    lines = ["## Pre-Implementation Checklist\n"]
    lines.append("### 1. Read Required Files")

    if step.files_to_modify:
        lines.append("\nRead files that will be modified:")
        for f in step.files_to_modify:
            lines.append(f"- `{f}`")

    lines.append("\n### 2. Verify Prerequisites")
    lines.append("```bash")
    lines.append("# Check plan context")
    lines.append(f"cat {plan.plan_dir}/context.md | tail -50")
    lines.append(f"cat {plan.plan_dir}/progress.json | python3 -c \"import json,sys; p=json.load(sys.stdin); print(f'Step {{p.get(\\\"currentStep\\\")}} of {{p.get(\\\"totalSteps\\\")}}')\"")
    lines.append("```\n")

    return "\n".join(lines)


def _build_implementation_section(
    impl_techs: list[str],
    impl_templates: list[TechniqueTemplate]
) -> str:
    """Build the implementation methodology section."""
    if not impl_templates:
        return ""

    lines = []

    if len(impl_templates) == 1:
        t = impl_templates[0]
        if t.implementation_section:
            lines.append(f"""## Implementation Methodology: {impl_techs[0].upper()}

Use this approach for implementation:

{t.implementation_section}
""")
    else:
        # Multiple techniques - compose them
        lines.append(f"## Implementation Methodology: {' + '.join(t.upper() for t in impl_techs)}\n")
        lines.append("Apply these techniques in sequence:\n")

        for i, t in enumerate(impl_templates):
            if t and t.implementation_section:
                lines.append(f"""### Phase {i+1}: {impl_techs[i].upper()}

{t.implementation_section}
""")

    return "\n".join(lines)


def _build_completion_protocol(step: StepInfo, plan: PlanInfo) -> str:
    """Build the completion protocol section."""
    files_created = ", ".join(f'"{f}"' for f in step.files_to_create) if step.files_to_create else "[]"
    files_modified = ", ".join(f'"{f}"' for f in step.files_to_modify) if step.files_to_modify else "[]"

    return f"""## Completion Protocol

After ALL acceptance criteria pass:

### 1. Update Progress
Update `{plan.plan_dir}/progress.json`:
- Set `steps[N].status` to "completed"
- Set `steps[N].completedAt` to ISO timestamp
- Set `steps[N].verificationPassed` to true
- Increment `currentStep`
- Add files to `context.filesCreated` and `context.filesModified`

### 2. Update Context
Add summary to `{plan.plan_dir}/context.md`:
```markdown
---

## Step {step.id} Complete - {{date}}

### Summary
{{What was accomplished}}

### Files Created
{files_created}

### Files Modified
{files_modified}

### Key Decisions
{{Any important decisions made}}

### Ready for Next Step
{{Prerequisites for next step}}
```

### 3. Commit Changes
```bash
git add .
git commit -m "feat(planning): Complete step {step.id} - {step.title}"
```
"""


def substitute_placeholders(
    prompt: str,
    step: StepInfo,
    plan: PlanInfo,
    requirements: str
) -> str:
    """
    Substitute all placeholders in the prompt.

    Args:
        prompt: The prompt text with placeholders
        step: Step information
        plan: Plan information
        requirements: Step requirements text

    Returns:
        Prompt with all placeholders substituted
    """
    # Build replacement dictionary
    impl_techs = step.techniques.get("implementation", ["self-refine"])
    if isinstance(impl_techs, str):
        impl_techs = [impl_techs]

    replacements = {
        "{step_number}": str(step.id),
        "{step_name}": step.title,
        "{step_mission}": step.goal,
        "{step_context}": step.context,
        "{step_requirements}": requirements,
        "{plan_name}": plan.title,
        "{plan_id}": plan.id,
        "{plan_dir}": plan.plan_dir,
        "{total_steps}": str(plan.total_steps),
        "{technique_planning}": step.techniques.get("planning", "ps-plus"),
        "{technique_impl}": ", ".join(impl_techs),
        "{technique_verify}": step.techniques.get("verification", "self-refine"),
        "{problem_type}": step.problem_type,
    }

    for placeholder, value in replacements.items():
        prompt = prompt.replace(placeholder, str(value))

    return prompt


def truncate_with_summary(prompt: str) -> str:
    """
    Truncate long prompts while preserving essential sections.

    Prioritizes keeping:
    - Mission and Context (required for understanding)
    - Acceptance Criteria (required for verification)
    - Completion Protocol (required for progress tracking)

    Summarizes:
    - Methodology sections (can be long)
    """
    if len(prompt) <= MAX_PROMPT_LENGTH:
        return prompt

    lines = prompt.split('\n')
    truncated = []
    in_methodology = False
    methodology_count = 0

    for line in lines:
        # Detect methodology sections
        if 'Methodology:' in line and line.startswith('##'):
            in_methodology = True
            methodology_count += 1
            truncated.append(line)
            truncated.append("")
            truncated.append("*(Section summarized due to prompt length limits)*")
            truncated.append("")
        elif line.startswith('##') and in_methodology:
            # New top-level section ends methodology
            in_methodology = False
            truncated.append(line)
        elif not in_methodology:
            truncated.append(line)
        # Skip methodology content when in_methodology=True

    result = '\n'.join(truncated)
    result += f"\n\n> Note: {methodology_count} technique methodology sections were summarized due to length constraints."

    return result


def get_technique_names(templates: dict[str, TechniqueTemplate]) -> list[str]:
    """Get list of available technique names."""
    return list(templates.keys())


def validate_techniques(
    techniques: dict,
    templates: dict[str, TechniqueTemplate]
) -> tuple[bool, list[str]]:
    """
    Validate that all referenced techniques exist.

    Args:
        techniques: Technique assignment dict
        templates: Available templates

    Returns:
        Tuple of (is_valid, list of missing techniques)
    """
    missing = []
    available = set(templates.keys())

    # Check planning technique
    planning = techniques.get("planning")
    if planning and planning not in available:
        missing.append(f"planning: {planning}")

    # Check implementation techniques
    impl = techniques.get("implementation", [])
    if isinstance(impl, str):
        impl = [impl]
    for t in impl:
        if t not in available:
            missing.append(f"implementation: {t}")

    # Check verification technique
    verify = techniques.get("verification")
    if verify and verify not in available:
        missing.append(f"verification: {verify}")

    return len(missing) == 0, missing


def compose_from_step_file(
    step_filepath: str,
    plan: PlanInfo,
    templates: dict[str, TechniqueTemplate]
) -> str:
    """
    Compose a prompt from a step file.

    Args:
        step_filepath: Path to the step markdown file
        plan: Plan information
        templates: Loaded technique templates

    Returns:
        Composed prompt string
    """
    path = Path(step_filepath)
    if not path.exists():
        raise FileNotFoundError(f"Step file not found: {step_filepath}")

    content = path.read_text()

    # Parse step file to extract info
    step = _parse_step_file(content, path.stem)

    # Get requirements section
    requirements = _extract_requirements(content)

    return compose_prompt(step, plan, templates, requirements)


def _parse_step_file(content: str, filename: str) -> StepInfo:
    """Parse a step markdown file into StepInfo."""
    # Extract step ID from filename (e.g., "01-some-name" -> 1)
    id_match = re.match(r'^(\d+[a-z]?)', filename)
    step_id = id_match.group(1) if id_match else filename

    # Extract title from first heading
    title_match = re.search(r'^#\s+(?:Step\s+\S+:\s+)?(.+)$', content, re.MULTILINE)
    title = title_match.group(1).strip() if title_match else filename

    # Extract goal from ## Goal section
    goal_match = re.search(r'##\s+Goal\s*\n+(.+?)(?=\n##|\n---|\Z)', content, re.DOTALL)
    goal = goal_match.group(1).strip() if goal_match else ""

    # Extract context from ## Context section
    context_match = re.search(r'##\s+Context\s*\n+(.+?)(?=\n##|\n---|\Z)', content, re.DOTALL)
    context = context_match.group(1).strip() if context_match else ""

    # Extract problem type
    type_match = re.search(r'##\s+Problem Type\s*\n+`?([^`\n]+)`?', content)
    problem_type = type_match.group(1).strip() if type_match else "unknown"

    # Extract techniques
    techniques = _extract_techniques(content)

    # Extract acceptance criteria
    criteria = _extract_acceptance_criteria(content)

    # Extract files to create/modify
    files_create = _extract_file_list(content, "Files to Create")
    files_modify = _extract_file_list(content, "Files to Modify")

    return StepInfo(
        id=step_id,
        title=title,
        goal=goal,
        context=context,
        problem_type=problem_type,
        techniques=techniques,
        acceptance_criteria=criteria,
        files_to_create=files_create,
        files_to_modify=files_modify
    )


def _normalize_technique_name(name: str) -> str:
    """Normalize technique name to standard ID format."""
    name = name.lower().strip()
    # Handle common abbreviations
    if name == "ps+" or name == "ps":
        return "ps-plus"
    if name == "coc":
        return "chain-of-code"
    if name == "l2m":
        return "least-to-most"
    # Remove parenthetical descriptions
    name = re.sub(r'\s*\([^)]*\)', '', name)
    return name.strip()


def _extract_techniques(content: str) -> dict:
    """Extract technique assignments from step file."""
    techniques = {
        "planning": "ps-plus",
        "implementation": ["self-refine"],
        "verification": "self-refine"
    }

    # Look for Technique Selection section
    tech_match = re.search(
        r'##\s+Technique Selection\s*\n(.+?)(?=\n##|\Z)',
        content, re.DOTALL
    )

    if tech_match:
        tech_section = tech_match.group(1)

        # Extract planning - match word chars, hyphens, and + suffix
        planning = re.search(r'\*\*Planning\*\*:\s*([\w+-]+)', tech_section)
        if planning:
            techniques["planning"] = _normalize_technique_name(planning.group(1))

        # Extract implementation (may be list)
        impl = re.search(r'\*\*Implementation\*\*:\s*(.+?)(?=\n|$)', tech_section)
        if impl:
            impl_text = impl.group(1).strip()
            # Handle list format (comma or +)
            if ',' in impl_text:
                techniques["implementation"] = [
                    _normalize_technique_name(t)
                    for t in impl_text.split(',')
                    if t.strip()
                ]
            elif ' + ' in impl_text:
                # Plus with spaces is a separator
                techniques["implementation"] = [
                    _normalize_technique_name(t)
                    for t in impl_text.split(' + ')
                    if t.strip()
                ]
            else:
                techniques["implementation"] = [_normalize_technique_name(impl_text)]

        # Extract verification
        verify = re.search(r'\*\*Verification\*\*:\s*([\w+-]+)', tech_section)
        if verify:
            techniques["verification"] = _normalize_technique_name(verify.group(1))

    return techniques


def _extract_acceptance_criteria(content: str) -> list[str]:
    """Extract acceptance criteria from step file."""
    criteria = []

    # Look for Acceptance Criteria section
    ac_match = re.search(
        r'##\s+Acceptance Criteria\s*\n(.+?)(?=\n##|\Z)',
        content, re.DOTALL
    )

    if ac_match:
        ac_section = ac_match.group(1)
        # Split by lines and find bullet points
        for line in ac_section.split('\n'):
            line = line.strip()
            # Match bullet points or checkboxes
            bullet_match = re.match(r'^[-*]\s+\[?\s*\]?\s*(.+)$', line)
            if bullet_match:
                criterion = bullet_match.group(1).strip()
                # Remove markdown bold formatting
                criterion = re.sub(r'\*\*([^*]+)\*\*', r'\1', criterion)
                if criterion:
                    criteria.append(criterion)

    return criteria


def _extract_file_list(content: str, section_name: str) -> list[str]:
    """Extract file list from a section."""
    files = []

    pattern = rf'##\s+{re.escape(section_name)}\s*\n(.+?)(?=\n##|\Z)'
    match = re.search(pattern, content, re.DOTALL)

    if match:
        section = match.group(1)
        # Find all file paths (in backticks or as list items)
        for path_match in re.finditer(r'`([^`]+)`', section):
            files.append(path_match.group(1))

    return files


def _extract_requirements(content: str) -> str:
    """Extract the detailed requirements section from a step file."""
    # Look for common requirement sections
    for section_name in ["Detailed Requirements", "Requirements", "Specification", "High-Level Steps"]:
        pattern = rf'##\s+{re.escape(section_name)}\s*\n(.+?)(?=\n##\s+(?:Acceptance|Testing|Files to|Do NOT)|\Z)'
        match = re.search(pattern, content, re.DOTALL | re.IGNORECASE)
        if match:
            return match.group(1).strip()

    # Fall back to everything between Context and Acceptance Criteria
    fallback = re.search(
        r'##\s+Context.+?\n##\s+\w+\s*\n(.+?)(?=##\s+Acceptance|\Z)',
        content, re.DOTALL
    )
    if fallback:
        return fallback.group(1).strip()

    return ""


# CLI interface for testing
if __name__ == '__main__':
    import sys
    import json

    if len(sys.argv) > 1 and sys.argv[1] == '--test':
        # Quick test mode
        templates = load_all_templates()

        step = StepInfo(
            id=1,
            title="Test Step",
            goal="Implement test functionality",
            context="Testing prompt composition",
            problem_type="algorithm",
            techniques={
                "planning": "tot",
                "implementation": ["tdd"],
                "verification": "reflexion"
            },
            acceptance_criteria=["Code compiles", "Tests pass", "Documentation complete"]
        )

        plan = PlanInfo(
            id="004",
            name="test-plan",
            title="Test Plan",
            total_steps=5,
            plan_dir=".claude/plans/004-test",
            description="A test plan for prompt composition"
        )

        prompt = compose_prompt(step, plan, templates, "Write a sort function that handles edge cases.")
        print(f"Prompt length: {len(prompt)} chars")
        print("---")
        print(prompt[:3000])
        print("...")
        print(f"\n[Truncated - total {len(prompt)} chars]")

    elif len(sys.argv) > 2:
        # Compose from step file
        step_file = sys.argv[1]
        plan_dir = sys.argv[2]

        # Load plan info from progress.json
        progress_file = Path(plan_dir) / "progress.json"
        if progress_file.exists():
            progress = json.loads(progress_file.read_text())
            plan = PlanInfo(
                id=progress.get("planId", "unknown"),
                name=progress.get("name", "unknown"),
                title=progress.get("title", "Unknown Plan"),
                total_steps=progress.get("totalSteps", 1),
                plan_dir=plan_dir,
                description=progress.get("description", "")
            )
        else:
            print(f"Error: progress.json not found in {plan_dir}")
            sys.exit(1)

        templates = load_all_templates()
        prompt = compose_from_step_file(step_file, plan, templates)
        print(prompt)

    else:
        print("Usage:")
        print("  python prompt_composer.py --test              # Run test mode")
        print("  python prompt_composer.py <step.md> <plan_dir>  # Compose from file")
