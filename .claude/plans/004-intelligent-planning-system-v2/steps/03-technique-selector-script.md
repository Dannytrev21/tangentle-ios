# Step 3: Technique Selector Script

## Context
Once we know the problem type, we need to select the appropriate techniques for each phase of the work. This script reads the configuration and returns the optimal technique(s) based on problem type, phase, and context.

## Goal
Create a Python script that selects the best prompt engineering techniques based on problem type, workflow phase, and step context.

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: PS+ (structured service design)
- **Implementation**: TDD + Self-Refine (test-driven with refinement)
- **Verification**: Reflexion (learn from technique selection failures)

## Risk Level
**Medium** - Core logic for technique selection

## Prerequisites
- Step 1 completed (technique-config.json exists)
- Step 2 completed (classifier available for type detection)

## High-Level Steps
1. Design the selector interface
2. Implement phase-based technique lookup
3. Add composition logic for multi-technique steps
4. Implement complexity-based technique adjustment
5. Add technique chaining support
6. Create technique metadata retrieval
7. Write comprehensive tests

## Detailed Requirements

### Interface
```python
class TechniqueSelector:
    def __init__(self, config_path: str = ".claude/technique-config.json"):
        """Initialize with technique configuration."""

    def select_techniques(
        self,
        problem_type: str,
        phase: Phase,
        context: StepContext = None
    ) -> TechniqueSelection:
        """
        Select techniques for a specific phase.

        Args:
            problem_type: The classified problem type
            phase: planning | implementation | verification
            context: Optional step context for refinement

        Returns:
            TechniqueSelection with primary and optional secondary techniques
        """

    def get_technique_prompt(
        self,
        technique_id: str
    ) -> str:
        """Get the prompt template for a technique."""

    def get_technique_metadata(
        self,
        technique_id: str
    ) -> TechniqueMetadata:
        """Get metadata about a technique."""

    def compose_techniques(
        self,
        techniques: list[str],
        problem_description: str
    ) -> str:
        """Compose multiple techniques into a single prompt."""

class Phase(Enum):
    PLANNING = "planning"
    IMPLEMENTATION = "implementation"
    VERIFICATION = "verification"

@dataclass
class StepContext:
    step_number: int
    total_steps: int
    complexity_score: float  # 0.0 to 1.0
    dependencies: list[str]
    risk_level: str
    previous_failures: int
    files_affected: list[str]

@dataclass
class TechniqueSelection:
    primary: str                    # Main technique
    secondary: list[str]            # Supporting techniques
    prompt_template: str            # Combined prompt
    rationale: str                  # Why these were selected
    estimated_cost: str             # low/medium/high
    retry_budget: int               # Max retries for this selection
```

### Selection Algorithm
```
1. LOOKUP BASE TECHNIQUES
   - Read from config for problem_type + phase
   - Get primary technique
   - Get any secondary techniques

2. CONTEXT ADJUSTMENT
   - If complexity_score > 0.7: prefer expensive techniques (ToT, Self-Consistency)
   - If previous_failures > 0: switch to Reflexion
   - If step is early in plan: prefer ToT for exploration
   - If step is late in plan: prefer TDD for verification

3. COST OPTIMIZATION
   - If low complexity + low risk: downgrade to PS+
   - If high complexity + high risk: upgrade to full Reflexion

4. TECHNIQUE COMPOSITION
   - If multiple techniques selected:
     - Primary provides main structure
     - Secondary provides constraints/modifiers
   - Merge prompt templates intelligently

5. RETURN SELECTION
   - Include rationale for logging
   - Include retry budget from risk assessment
```

### Technique Prompt Templates
Each technique has a template that can be composed:

```python
TECHNIQUE_TEMPLATES = {
    "tot": ".claude/commands/tot.md",
    "got": ".claude/commands/got.md",
    "reflexion": ".claude/commands/reflexion.md",
    "self-consistency": ".claude/commands/self-consistency.md",
    "self-refine": ".claude/commands/self-refine.md",
    "tdd": ".claude/commands/tdd.md",
    "react": ".claude/commands/react.md",
    "ps-plus": ".claude/commands/ps-plus.md",
    "chain-of-code": ".claude/commands/chain-of-code.md",
    "least-to-most": ".claude/commands/least-to-most.md",
}
```

## Files to Create
- `.claude/scripts/technique_selector.py`: Main selector implementation
- `.claude/scripts/test_technique_selector.py`: Unit tests

## Files to Modify
- `.claude/scripts/__init__.py`: Export selector

## Patterns to Follow
Reference: `.claude/commands/plan-prompts.md` for how prompts are currently generated

## Acceptance Criteria
- [ ] Selector returns valid techniques for all problem types
- [ ] Phase-specific selection works correctly
- [ ] Context-based adjustment improves selections
- [ ] Technique composition produces valid prompts
- [ ] Rationale is logged for debugging
- [ ] All unit tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/scripts/test_technique_selector.py`
- [ ] Test cases:
  - `test_select_planning_technique_for_algorithm()`
  - `test_select_implementation_technique_for_ui()`
  - `test_select_verification_technique_for_debug()`
  - `test_context_adjustment_increases_complexity()`
  - `test_previous_failures_triggers_reflexion()`
  - `test_compose_techniques_merges_prompts()`
  - `test_get_technique_prompt_returns_valid_template()`

### Test Data
```python
TEST_CASES = [
    ("algorithm", Phase.IMPLEMENTATION, None, "tdd"),
    ("ui", Phase.IMPLEMENTATION, None, "self-refine"),
    ("debug", Phase.IMPLEMENTATION, None, "reflexion"),
    ("debug", Phase.IMPLEMENTATION, StepContext(previous_failures=2), "reflexion"),
]
```

## Verification Commands
```bash
# Run selector tests
cd .claude/scripts && python3 -m pytest test_technique_selector.py -v

# Test selection interactively
python3 -c "
from technique_selector import TechniqueSelector, Phase
s = TechniqueSelector()
result = s.select_techniques('algorithm', Phase.IMPLEMENTATION)
print(f'Primary: {result.primary}')
print(f'Secondary: {result.secondary}')
print(f'Rationale: {result.rationale}')
"
```

## Documentation Updates
- [ ] Add technique selection section to CLAUDE.md

## Error Recovery
If technique selection fails:
1. Fall back to default technique for phase
2. Log the failure for debugging
3. Use PS+ as universal fallback

## Do NOT
- Select techniques that don't have templates
- Ignore context when making selections
- Compose incompatible techniques
