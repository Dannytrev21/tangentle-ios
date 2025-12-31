# Step 8: Update plan-prompts

## Context
This is the most critical step. The `/plan-prompts` command generates the prompts that guide AI implementation. With technique selection in place, we must embed the selected technique's structure into each prompt.

## Goal
Update the `/plan-prompts` command to generate technique-embedded prompts that combine step requirements with the selected prompt engineering methodology.

## Problem Type
`system-design`

## Technique Selection
- **Planning**: ToT (explore multiple prompt composition approaches)
- **Implementation**: Self-Refine + Chain-of-Code (iterative with semantic mixing)
- **Verification**: Reflexion (learn from prompt quality issues)

## Risk Level
**High** - Prompt quality directly affects implementation quality

## Prerequisites
- Steps 1-7 completed (techniques assigned to steps)

## High-Level Steps
1. Analyze current plan-prompts.md
2. Design technique embedding strategy
3. Create technique-aware prompt template
4. Implement prompt composition logic
5. Add phase-specific sections
6. Handle multi-technique composition
7. Generate technique-specific verification
8. Test with multiple technique combinations

## Detailed Requirements

### Current Prompt Generation
1. Load plan and step files
2. Apply generic prompt template
3. Add verification commands
4. Write prompt files

### New Prompt Generation
1. Load plan with technique metadata
2. **For each step:**
   - Load assigned techniques
   - Load technique templates
   - **Compose technique structure into prompt**
   - Add step-specific requirements
   - Add technique-specific verification
3. Write technique-embedded prompt files

### Technique Embedding Strategy

Each technique has a structure that gets embedded into the prompt:

```
┌─────────────────────────────────────────────────────────────┐
│  PROMPT STRUCTURE                                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. MISSION (from step file)                                │
│     └── Clear objective                                     │
│                                                              │
│  2. CONTEXT (from step file + plan)                         │
│     └── Dependencies, previous work, constraints            │
│                                                              │
│  3. TECHNIQUE: PLANNING PHASE (from technique template)     │
│     └── e.g., ToT branching structure                       │
│     └── e.g., PS+ problem decomposition                     │
│                                                              │
│  4. SPECIFICATION (from step file)                          │
│     └── Detailed requirements                               │
│                                                              │
│  5. TECHNIQUE: IMPLEMENTATION PHASE (from technique)        │
│     └── e.g., TDD red-green-refactor                       │
│     └── e.g., Self-Refine iteration loops                   │
│                                                              │
│  6. TECHNIQUE: VERIFICATION PHASE (from technique)          │
│     └── e.g., Reflexion memory bank                         │
│     └── e.g., Self-Consistency voting                       │
│                                                              │
│  7. ACCEPTANCE CRITERIA (from step file)                    │
│     └── Measurable success conditions                       │
│                                                              │
│  8. ERROR RECOVERY (technique-aware)                        │
│     └── Retry strategy from risk assessment                 │
│                                                              │
│  9. COMPLETION PROTOCOL                                     │
│     └── Progress updates, context updates                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Technique Template Sections

Each technique template should expose sections that can be embedded:

```python
# Technique template structure
class TechniqueTemplate:
    def get_planning_section(self, context: dict) -> str:
        """Return the planning methodology section."""

    def get_implementation_section(self, context: dict) -> str:
        """Return the implementation methodology section."""

    def get_verification_section(self, context: dict) -> str:
        """Return the verification methodology section."""

    def get_error_recovery_section(self, retry_config: dict) -> str:
        """Return technique-specific error recovery."""
```

### Example: TDD Embedded Prompt

```markdown
# Prompt: Step 5 - Task Repository Tests

## Mission
Implement comprehensive unit tests for TaskRepository.

## Context
...

## Implementation Methodology: TDD

Follow strict Test-Driven Development:

### Phase 1: Write Failing Tests (RED)
Before writing any production code:

\`\`\`swift
// Write tests first
@Suite("TaskRepository Tests")
struct TaskRepositoryTests {
    @Test("Create task saves to database")
    func testCreateTask() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let repository = TaskRepository(context: context)

        // Act
        let task = try await repository.createTask(title: "Test")

        // Assert
        #expect(task.title == "Test")
    }
}
\`\`\`

**Run tests - all should FAIL** (not implemented yet)

### Phase 2: Minimal Implementation (GREEN)
Write the minimum code to make tests pass:

[Implementation guidance...]

**Run tests - all should PASS**

### Phase 3: Refactor (KEEP GREEN)
Improve code quality while keeping tests green:

[Refactoring guidance...]

## Verification Methodology: Reflexion

If tests fail after implementation:

### Memory Bank
[Accumulate lessons from failures]

### Attempt Loop
1. **Attempt 1**: Initial implementation
   - Run tests
   - If pass: Done
   - If fail: Analyze and add to memory bank

2. **Attempt 2**: Apply lessons from memory
   - Consult memory bank
   - Adjust implementation
   - Run tests

[Continue until success or max attempts]

## Acceptance Criteria
...
```

### Multi-Technique Composition

When multiple techniques are assigned to implementation:

```python
def compose_techniques(techniques: list[str], step_context: dict) -> str:
    """
    Compose multiple techniques into a coherent prompt section.

    Example: ["tdd", "self-refine"]

    Output:
    ## Implementation Methodology: TDD + Self-Refine

    This step uses TDD as the primary methodology with
    Self-Refine for quality iteration.

    ### Phase 1: TDD Cycle
    [TDD structure]

    ### Phase 2: Self-Refine Polish
    After tests pass, apply self-refine:
    [Self-refine structure]
    """
    sections = []
    for technique in techniques:
        template = load_technique_template(technique)
        section = template.get_implementation_section(step_context)
        sections.append(section)

    return merge_sections(sections)
```

## Files to Create
- None (modifying existing)

## Files to Modify
- `.claude/commands/plan-prompts.md`: Complete technique embedding

## Patterns to Follow
Reference: Current technique command files for structure:
- `.claude/commands/tdd.md`
- `.claude/commands/reflexion.md`
- `.claude/commands/tot.md`

## Acceptance Criteria
- [ ] Prompts include technique methodology sections
- [ ] Planning, implementation, verification phases are technique-aware
- [ ] Multi-technique composition works correctly
- [ ] Error recovery reflects retry configuration
- [ ] Generated prompts are self-contained (no external refs)
- [ ] Technique rationale is embedded in prompts

## Testing Requirements

### Manual Testing
- [ ] Generate prompts for plan with TDD technique
- [ ] Generate prompts for plan with Reflexion technique
- [ ] Generate prompts with multi-technique step
- [ ] Verify prompt sections are coherent

### Validation
```bash
# Check prompt includes technique section
grep -q "Implementation Methodology" .claude/plans/NNN-slug/prompts/01-*.prompt.md
```

## Verification Commands
```bash
# Verify technique embedding in prompt template
grep -q "TECHNIQUE:" .claude/commands/plan-prompts.md && echo "Technique sections added"

# Check for multi-technique handling
grep -q "compose_techniques\|Multi-Technique" .claude/commands/plan-prompts.md
```

## Documentation Updates
- [ ] Update prompt generation docs in CLAUDE.md
- [ ] Add technique composition guide

## Error Recovery
If technique embedding fails:
1. Fall back to generic prompt template
2. Log which technique failed
3. Add note to prompt about missing technique

## Do NOT
- Generate prompts that require reading external technique files
- Lose step-specific requirements in technique structure
- Create prompts that are too long (>3000 lines)
