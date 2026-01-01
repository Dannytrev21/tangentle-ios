"""
Template Parser for Technique Command Files

Extracts structured templates from markdown technique files,
supporting both marked templates (with section markers) and
legacy templates (using heuristic parsing).
"""

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional


@dataclass
class TechniqueTemplate:
    """Structured representation of a technique template."""
    id: str                             # e.g., "tdd", "reflexion"
    name: str                           # Human-readable name
    description: str                    # When to use
    planning_section: str = ""          # Markdown for planning phase
    implementation_section: str = ""    # Markdown for implementation phase
    verification_section: str = ""      # Markdown for verification phase
    error_recovery_section: str = ""    # How to handle failures
    placeholders: list[str] = field(default_factory=list)  # Variables to substitute


def parse_technique_template(filepath: str) -> TechniqueTemplate:
    """
    Parse a technique markdown file into structured template.

    Args:
        filepath: Path to the technique markdown file

    Returns:
        TechniqueTemplate with extracted sections
    """
    path = Path(filepath)
    if not path.exists():
        raise FileNotFoundError(f"Template file not found: {filepath}")

    content = path.read_text()
    technique_id = path.stem  # e.g., "tdd" from "tdd.md"

    # Check if file has section markers
    if "<!-- SECTION:" in content:
        return _parse_marked_template(content, technique_id)
    else:
        return _parse_legacy_template(content, technique_id)


def _parse_marked_template(content: str, technique_id: str) -> TechniqueTemplate:
    """Extract sections using HTML comment markers."""
    pattern = r'<!-- SECTION:(\w+) -->(.*?)<!-- /SECTION:\1 -->'
    matches = re.findall(pattern, content, re.DOTALL)
    sections = {name: text.strip() for name, text in matches}

    # Extract name and description from header
    name = _extract_title(content) or technique_id.upper()
    description = _extract_description(content) or ""

    # Find placeholders (e.g., {task}, {context}, $ARGUMENTS)
    placeholders = _extract_placeholders(content)

    return TechniqueTemplate(
        id=technique_id,
        name=name,
        description=description,
        planning_section=sections.get('PLANNING', ''),
        implementation_section=sections.get('IMPLEMENTATION', ''),
        verification_section=sections.get('VERIFICATION', ''),
        error_recovery_section=sections.get('ERROR_RECOVERY', ''),
        placeholders=placeholders
    )


def _parse_legacy_template(content: str, technique_id: str) -> TechniqueTemplate:
    """
    Heuristic parsing for files without markers.

    Attempts to identify planning, implementation, and verification sections
    based on common header patterns.
    """
    sections = {}

    # Map technique ID to expected structure
    # Different techniques have different phase names
    technique_section_map = {
        'tdd': {
            'planning': ['Phase 1: Requirements', 'Test Cases'],
            'implementation': ['Phase 2', 'Phase 3', 'Implement', 'Go GREEN', 'RED-GREEN'],
            'verification': ['Phase 4', 'Phase 5', 'Refactor', 'Final Deliverables'],
        },
        'tot': {
            'planning': ['Root:', 'Initial Problem', 'Level 1'],
            'implementation': ['Level 2', 'Level 3', 'Expanding', 'Deep Exploration'],
            'verification': ['Convergence', 'Final Solution'],
        },
        'reflexion': {
            'planning': ['Attempt 1', 'Actor'],
            'implementation': ['Attempt 2', 'Attempt 3', 'Memory Bank'],
            'verification': ['Final Result', 'Accumulated Wisdom', 'Evaluator'],
        },
        'self-refine': {
            'planning': ['Iteration 0', 'Initial Generation'],
            'implementation': ['Iteration 1', 'Iteration 2', 'Refinement'],
            'verification': ['Iteration 3', 'Final Check', 'Stopping Criteria'],
        },
        'self-consistency': {
            'planning': ['Phase 1', 'Generate Multiple'],
            'implementation': ['SOLUTION 1', 'SOLUTION 2', 'SOLUTION 3'],
            'verification': ['Phase 2', 'Phase 3', 'Phase 4', 'Evaluation', 'Consensus', 'Final Selection'],
        },
        'react': {
            'planning': ['Cycle 1', 'Thought 1'],
            'implementation': ['Cycle 2', 'Cycle 3', 'Action'],
            'verification': ['Final Cycle', 'Summary'],
        },
        'ps-plus': {
            'planning': ['Phase 1', 'Problem Understanding'],
            'implementation': ['Phase 2', 'Phase 3', 'Plan Formulation', 'Execution'],
            'verification': ['Phase 4', 'Final Verification'],
        },
        'chain-of-code': {
            'planning': ['Phase 1', 'Problem Analysis'],
            'implementation': ['Phase 2', 'Phase 3', 'Phase 4', 'Code Structure', 'LMulator'],
            'verification': ['Phase 5', 'Verification', 'Final Solution'],
        },
        'got': {
            'planning': ['Graph Initialization', 'Thought Nodes'],
            'implementation': ['Graph Transformations', 'Expansion', 'Aggregation', 'Refinement'],
            'verification': ['Graph Visualization', 'Scoring Summary', 'Final Solution'],
        },
        'least-to-most': {
            'planning': ['Phase 1', 'Decomposition'],
            'implementation': ['Phase 2', 'Sequential Solving', 'Subproblem'],
            'verification': ['Phase 3', 'Final Integration'],
        },
    }

    # Get section patterns for this technique
    section_patterns = technique_section_map.get(technique_id, {})

    # Try to find Planning section
    planning_patterns = section_patterns.get('planning', ['Planning', 'Before', 'Preparation', 'Phase 1', 'Step 1'])
    sections['PLANNING'] = _extract_section_by_patterns(content, planning_patterns)

    # Try to find Implementation section
    impl_patterns = section_patterns.get('implementation', ['Implementation', 'Process', 'Steps', 'Execution', 'Phase 2'])
    sections['IMPLEMENTATION'] = _extract_section_by_patterns(content, impl_patterns)

    # Try to find Verification section
    verify_patterns = section_patterns.get('verification', ['Verification', 'Validation', 'Check', 'Final', 'Summary'])
    sections['VERIFICATION'] = _extract_section_by_patterns(content, verify_patterns)

    # Try to find Error Recovery section
    error_patterns = ['Error', 'Recovery', 'Fallback', 'Failure']
    sections['ERROR_RECOVERY'] = _extract_section_by_patterns(content, error_patterns)

    # If implementation section is empty, use a chunk of the middle content
    if not sections['IMPLEMENTATION']:
        lines = content.split('\n')
        # Take middle 60% of content
        start = len(lines) // 5
        end = len(lines) * 4 // 5
        sections['IMPLEMENTATION'] = '\n'.join(lines[start:end])

    return TechniqueTemplate(
        id=technique_id,
        name=_extract_title(content) or technique_id.upper(),
        description=_extract_description(content) or "",
        planning_section=sections.get('PLANNING', ''),
        implementation_section=sections.get('IMPLEMENTATION', ''),
        verification_section=sections.get('VERIFICATION', ''),
        error_recovery_section=sections.get('ERROR_RECOVERY', ''),
        placeholders=_extract_placeholders(content)
    )


def _extract_section_by_patterns(content: str, patterns: list[str]) -> str:
    """Extract content matching any of the given header patterns."""
    for pattern in patterns:
        # Look for headers containing this pattern
        regex = rf'##\s*[^\n]*{re.escape(pattern)}[^\n]*\n(.*?)(?=\n##|\n---\s*\n##|$)'
        match = re.search(regex, content, re.IGNORECASE | re.DOTALL)
        if match:
            return match.group(1).strip()
    return ''


def _extract_title(content: str) -> Optional[str]:
    """Extract title from first # heading."""
    match = re.search(r'^#\s+(.+?)(?:\s*\(.+\))?\s*$', content, re.MULTILINE)
    if match:
        return match.group(1).strip()
    return None


def _extract_description(content: str) -> Optional[str]:
    """Extract description from Instructions section or first paragraph."""
    # First try to find Instructions section
    instructions_match = re.search(
        r'##\s*Instructions?\s*\n+(.+?)(?=\n---|\n##|$)',
        content, re.IGNORECASE | re.DOTALL
    )
    if instructions_match:
        # Get first paragraph of instructions
        text = instructions_match.group(1).strip()
        first_para = text.split('\n\n')[0]
        return first_para.strip()

    # Fall back to first paragraph after title
    match = re.search(r'^#[^\n]+\n\n([^\n#]+)', content, re.MULTILINE)
    return match.group(1).strip() if match else None


def _extract_placeholders(content: str) -> list[str]:
    """Extract placeholder variables from content."""
    placeholders = set()

    # Find {variable} style placeholders
    brace_matches = re.findall(r'\{(\w+)\}', content)
    placeholders.update(brace_matches)

    # Find $ARGUMENTS style placeholders
    dollar_matches = re.findall(r'\$(\w+)', content)
    placeholders.update(dollar_matches)

    # Filter out common false positives
    false_positives = {
        'x', 'y', 'n', 'N', 'i', 'j', 'k',  # Loop variables
        'if', 'else', 'for', 'while',  # Control flow
        'bash', 'python', 'markdown',  # Code blocks
        'ISO', 'NNN',  # Format placeholders in examples
    }

    return sorted(list(placeholders - false_positives))


def load_all_templates(commands_dir: Optional[str] = None) -> dict[str, TechniqueTemplate]:
    """
    Load all technique templates from the commands directory.

    Args:
        commands_dir: Path to commands directory (defaults to .claude/commands)

    Returns:
        Dictionary mapping technique ID to TechniqueTemplate
    """
    if commands_dir is None:
        # Try to find .claude/commands relative to current directory or script location
        possible_paths = [
            Path('.claude/commands'),
            Path(__file__).parent.parent / 'commands',
        ]
        for path in possible_paths:
            if path.exists():
                commands_dir = str(path)
                break
        else:
            raise FileNotFoundError("Could not find .claude/commands directory")

    commands_path = Path(commands_dir)
    templates = {}

    technique_files = [
        "tdd.md", "tot.md", "reflexion.md", "self-refine.md",
        "self-consistency.md", "react.md", "ps-plus.md",
        "chain-of-code.md", "got.md", "least-to-most.md"
    ]

    for filename in technique_files:
        filepath = commands_path / filename
        if filepath.exists():
            try:
                template = parse_technique_template(str(filepath))
                templates[template.id] = template
            except Exception as e:
                # Log warning but continue
                print(f"Warning: Could not parse {filename}: {e}")
                # Create minimal template
                technique_id = filepath.stem
                templates[technique_id] = TechniqueTemplate(
                    id=technique_id,
                    name=technique_id.upper(),
                    description=f"Failed to parse: {e}",
                )

    return templates


def get_template_section(template: TechniqueTemplate, phase: str) -> str:
    """
    Get the appropriate section for a given phase.

    Args:
        template: The TechniqueTemplate
        phase: One of 'planning', 'implementation', 'verification', 'error_recovery'

    Returns:
        The section content as markdown
    """
    phase_map = {
        'planning': template.planning_section,
        'implementation': template.implementation_section,
        'verification': template.verification_section,
        'error_recovery': template.error_recovery_section,
    }
    return phase_map.get(phase.lower(), '')


def template_has_section(template: TechniqueTemplate, phase: str) -> bool:
    """Check if a template has content for a given phase."""
    return bool(get_template_section(template, phase))


# CLI interface for testing
if __name__ == '__main__':
    import sys

    if len(sys.argv) > 1:
        filepath = sys.argv[1]
        template = parse_technique_template(filepath)
        print(f"Template: {template.name} ({template.id})")
        print(f"Description: {template.description[:100]}...")
        print(f"Planning section: {len(template.planning_section)} chars")
        print(f"Implementation section: {len(template.implementation_section)} chars")
        print(f"Verification section: {len(template.verification_section)} chars")
        print(f"Error recovery section: {len(template.error_recovery_section)} chars")
        print(f"Placeholders: {template.placeholders}")
    else:
        # Load all templates
        templates = load_all_templates()
        print(f"Loaded {len(templates)} templates:")
        for tid, template in templates.items():
            sections_filled = sum([
                bool(template.planning_section),
                bool(template.implementation_section),
                bool(template.verification_section),
            ])
            print(f"  {tid}: {sections_filled}/3 sections")
