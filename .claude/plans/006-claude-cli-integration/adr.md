# ADR: Claude CLI System Full Integration

## Status
Proposed

## Context
The project has a sophisticated intelligent planning system with problem classification, technique selection, and risk-based self-correction. However, it doesn't leverage proven Claude Code CLI patterns documented in `claude_cli_system.md`:

1. **Explore before plan**: The guide emphasizes "never let Claude jump straight to coding"
2. **Thinking keywords**: "think", "think hard", "ultrathink" for reasoning depth
3. **CLAUDE.md best practices**: Keep under 300 lines with pointer-style references
4. **TDD emphasis**: "The robots LOVE TDD"
5. **Context management**: Strategic use of /compact and /clear
6. **Commit frequently**: Git as safety net with frequent checkpoints

The current planning system starts at `plan-feature-initial` without formal exploration, doesn't use thinking keywords, and CLAUDE.md is at ~300 lines without imports.

## Tree of Thought Analysis

### Integration Scope

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Knowledge Base only | Quick, low risk | Passive reference, not embedded |
| B | Prompt Enhancement | Medium effort, high impact | Doesn't add capabilities |
| C | Command Enhancement | New capabilities | Higher complexity |
| D | Full Integration | Comprehensive | Highest effort |

**Selected: Option D** - Full Integration per user request.

### CLAUDE.md Strategy

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Streamline + @imports | Clean, follows guide | Need to manage imports |
| B | Keep as-is, separate knowledge | No changes to main file | Doesn't follow guide recommendation |
| C | Merge everything | Complete in one place | Exceeds 300 lines, bloated context |

**Selected: Option A** - Streamline to ~250 lines with modular @imports.

### Thinking Keyword Mapping

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Map to risk level | Automatic, appropriate | Less user control |
| B | User-selectable | Maximum flexibility | Cognitive overhead |
| C | Fixed for all | Simple | Ignores complexity variance |

**Selected: Option A** - Automatic mapping:
- Low risk → "think about"
- Medium risk → "think hard about"
- High/Critical risk → "ultrathink about"

### Explore Phase

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | New `/plan-explore` command | Clean separation | Another command |
| B | Substep in plan-feature-initial | Integrated | Longer workflow |
| C | Implicit in classification | Automatic | Less visibility |

**Selected: Option B** - Integrate as explicit substep with documentation.

### Backward Compatibility

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Full backward compatibility | Old plans work | Constrains changes |
| B | No backward compatibility | Freedom to redesign | Old plans may break |
| C | Migration path | Best of both | More work |

**Selected: Option B** - Per user decision, existing plans (001-005) may not work with enhanced commands. Fresh plans will use new system.

## Decision

Implement full integration with:

1. **Knowledge Base**: Create `.claude/knowledge/` directory with modular reference files
2. **Streamlined CLAUDE.md**: Reduce to ~250 lines using @imports
3. **Thinking Keywords**: Embed in prompts based on risk level via Python utility
4. **Explore Phase**: Add as Step 1.5 in plan-feature-initial
5. **TDD Emphasis**: Make TDD the default implementation technique
6. **Context Guidance**: Add to plan-next prompts (no tracking)
7. **Recovery Enhancement**: Add checkpoint patterns to plan-rollback
8. **Subagents**: Defer to Phase 2

## Consequences

### Positive
- Prompts automatically use appropriate reasoning depth
- CLAUDE.md follows best practices and stays maintainable
- Exploration phase prevents premature solutions
- TDD emphasis improves code quality
- Context guidance prevents failed long sessions
- Knowledge base provides reference without bloating context

### Negative
- Existing plans (001-005) may not work with new commands
- More files to maintain in knowledge base
- Slightly more complex command execution

### Mitigations
- Old plans can be manually updated if needed
- Knowledge base is modular - only load what's needed
- Commands remain the same interface, just enhanced content
- Clear documentation of new patterns

## Implementation Notes

### Thinking Keyword Integration Points
1. `technique_selector.py` - Add `get_thinking_keyword(risk_level)` function
2. `plan-prompts.md` - Template includes thinking keyword placeholder
3. Generated prompts - Replace placeholder based on step risk

### Knowledge Base Structure
```
.claude/knowledge/
├── README.md                 # Index and usage guide
├── claude-code-mastery.md    # Core principles
├── thinking-keywords.md      # Depth reference
├── context-management.md     # Session guidance
└── tdd-patterns.md          # Test-driven patterns
```

### CLAUDE.md Import Pattern
```markdown
## Intelligent Planning System
See @.claude/knowledge/claude-code-mastery.md for detailed patterns.
```

## Related Decisions
- ADR 004: Intelligent Planning System v2 (technique selection foundation)
- This ADR extends 004 with CLI mastery patterns
