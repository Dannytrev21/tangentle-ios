# Plan 006: Claude CLI System Full Integration

## Overview
A comprehensive integration of the Claude Code CLI mastery guide into the intelligent planning system, enhancing prompts with thinking keywords, formalizing the explore phase, strengthening TDD emphasis, adding context management guidance, and streamlining CLAUDE.md with imports. This transforms the planning system to automatically apply proven Claude Code best practices.

## Status
- **Created**: 2026-01-21
- **Status**: Not Started
- **Current Step**: 0 of 13

## Tree of Thought Analysis

### What are we building?
A full integration layer that embeds Claude Code CLI mastery patterns into every aspect of the planning system:
1. **Knowledge Base** - Reference documentation at `.claude/knowledge/`
2. **Streamlined CLAUDE.md** - Under 300 lines with `@` imports
3. **Thinking Keywords** - Risk-based depth (think → think hard → ultrathink)
4. **Enhanced Prompts** - TDD emphasis, context guidance, commit checkpoints
5. **Explore Phase** - Formal exploration before classification
6. **Recovery Patterns** - Enhanced rollback with checkpoint guidance

### Why are we building it?
- **Consistency**: Apply proven patterns automatically, not manually
- **Quality**: Thinking depth matched to problem complexity
- **Efficiency**: Explore before plan prevents wasted effort
- **Resilience**: Better recovery from failures via checkpoints
- **Maintainability**: Streamlined CLAUDE.md that doesn't bloat

### Key Decisions

#### Decision 1: Knowledge Base Organization

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Single large file | All in one place | Unwieldy, hard to update |
| B | Multiple topic files | Modular, focused | More files to manage |
| C | Hierarchical with index | Organized, discoverable | More complex structure |

**Selected: Option B** - Multiple topic files in `.claude/knowledge/` directory:
- `claude-code-mastery.md` - Core guide principles
- `thinking-keywords.md` - Depth mapping reference
- `context-management.md` - Token/session guidance
- `tdd-patterns.md` - Test-driven patterns

Rationale: Allows selective loading via `@` imports without bloating context.

#### Decision 2: Thinking Keyword Integration

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Hardcoded in prompts | Simple, predictable | Inflexible |
| B | Risk-based mapping | Automatic, appropriate depth | More complex |
| C | User-selectable per step | Maximum control | Cognitive overhead |

**Selected: Option B** - Automatic risk-based mapping:
- Low risk → "think about"
- Medium risk → "think hard about"
- High/Critical risk → "ultrathink about"

Rationale: Matches the guide's recommendation while leveraging existing risk assessment.

#### Decision 3: Explore Phase Implementation

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | New `/plan-explore` command | Clean separation | Another command to remember |
| B | Substep in plan-feature-initial | Integrated workflow | Longer command |
| C | Automatic pre-classification | Invisible to user | Less control |

**Selected: Option B** - Substep in `plan-feature-initial`:
- Step 1.5 between reading CLAUDE.md and classification
- Explicit "Read relevant files without writing code" phase
- Document findings before proceeding

Rationale: Follows guide's "never let Claude jump straight to coding" without adding commands.

#### Decision 4: CLAUDE.md Streamlining Approach

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Aggressive trim to 200 lines | Maximum lean | May lose important context |
| B | Moderate trim to 250 lines | Balanced | Still substantial |
| C | Extract planning system docs only | Focused reduction | Still near 300 lines |

**Selected: Option B** - Moderate streamlining to ~250 lines:
- Move Intelligent Planning System v2 details to knowledge file
- Keep essential: project overview, tech stack, commands, conventions
- Use `@` imports for: technique reference, problem types, detailed workflows

Rationale: Balances guide's recommendation with maintaining essential context.

#### Decision 5: Context Management Approach

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Token tracking in progress.json | Precise | Complex implementation |
| B | Guidance in prompts | Simple, effective | No enforcement |
| C | Automatic /compact triggers | Proactive | May interrupt workflow |

**Selected: Option B** - Guidance in prompts:
- Add context awareness section to prompt templates
- Suggest `/compact` at 70%+ usage
- Recommend `/clear` between unrelated tasks
- "Document and Clear" pattern for long plans

Rationale: User's explicit choice; balances awareness with simplicity.

### Testing Strategy

| Test Type | Scope | Files | Priority |
|-----------|-------|-------|----------|
| Unit | Python script enhancements | .claude/scripts/test_*.py | Required |
| Integration | Full workflow with new prompts | Manual execution | Required |
| Manual | Verify prompts produce expected behavior | N/A | Required |

**Note**: This plan modifies documentation and prompt templates primarily. Testing focuses on:
1. Python script changes compile and run
2. New commands execute without errors
3. Generated prompts include expected sections

## Technique Matrix

| Step | Problem Type | Planning | Implementation | Verification | Risk |
|------|--------------|----------|----------------|--------------|------|
| 1 | documentation | ps-plus | self-refine | got | low |
| 2 | refactor | ps-plus | self-refine | self-refine | medium |
| 3 | configuration | react | self-refine | tdd | low |
| 4 | documentation | ps-plus | self-refine | got | medium |
| 5 | refactor | ps-plus | self-refine | tdd | medium |
| 6 | refactor | ps-plus | self-refine | tdd | medium |
| 7 | refactor | ps-plus | self-refine | tdd | medium |
| 8 | refactor | ps-plus | self-refine | tdd | medium |
| 9 | refactor | ps-plus | self-refine | self-refine | low |
| 10 | refactor | ps-plus | self-refine | self-refine | low |
| 11 | service-impl | ps-plus | tdd | reflexion | medium |
| 12 | documentation | ps-plus | self-refine | self-refine | low |
| 13 | integration-test | least-to-most | tdd | reflexion | medium |

## Implementation Steps

| Step | Name | Description | Type | Risk | Status |
|------|------|-------------|------|------|--------|
| 1 | Knowledge Base Creation | Create .claude/knowledge/ with modular reference docs | documentation | low | Pending |
| 2 | CLAUDE.md Streamlining | Refactor to ~250 lines with @imports | refactor | medium | Pending |
| 3 | Thinking Keywords Config & Utility | Add thinking keyword config, utils, and TechniqueSelector methods | configuration | low | Pending |
| 4 | Prompt Template Enhancement | Update plan-prompts.md with thinking keywords, TDD, context | documentation | medium | Pending |
| 5 | Plan-Prompts Integration | Embed thinking keywords based on risk level | refactor | medium | Pending |
| 6 | Plan-Next Enhancement | Add context management guidance | refactor | medium | Pending |
| 7 | Plan-Feature-Initial Explore | Add formal explore substep | refactor | medium | Pending |
| 8 | Plan-Feature TDD Emphasis | Strengthen TDD as default, add explore workflow | refactor | medium | Pending |
| 9 | Plan-Rollback Recovery | Add checkpoint and recovery guidance | refactor | low | Pending |
| 10 | Plan-Verify Enhancement | Strengthen with guide verification principles | refactor | low | Pending |
| 11 | Thinking CLI Command & Integration | Add CLI `thinking` command and verify full integration | service-impl | medium | Pending |
| 12 | Git Workflow Guidance | Add commit frequently, checkpoint patterns to prompts | documentation | low | Pending |
| 13 | Integration Verification | Test full workflow with enhanced commands | integration-test | medium | Pending |

## Files to Create

| Path | Description |
|------|-------------|
| `.claude/knowledge/claude-code-mastery.md` | Core guide principles extracted |
| `.claude/knowledge/thinking-keywords.md` | Depth mapping reference |
| `.claude/knowledge/context-management.md` | Token/session guidance |
| `.claude/knowledge/tdd-patterns.md` | Test-driven patterns reference |
| `.claude/knowledge/README.md` | Knowledge base index |

## Files to Modify

| Path | Changes |
|------|---------|
| `CLAUDE.md` | Streamline to ~250 lines, add @imports |
| `.claude/commands/plan-prompts.md` | Add thinking keywords, TDD emphasis, context guidance |
| `.claude/commands/plan-next.md` | Add context management, checkpoint guidance |
| `.claude/commands/plan-feature-initial.md` | Add explore substep before classification |
| `.claude/commands/plan-feature.md` | Strengthen TDD, add explore workflow documentation |
| `.claude/commands/plan-rollback.md` | Add checkpoint recovery guidance |
| `.claude/commands/plan-verify.md` | Enhance verification protocol |
| `.claude/scripts/technique_selector.py` | Add thinking keyword mapping function |
| `.claude/scripts/utils.py` | Add thinking keyword utilities |
| `.claude/technique-config.json` | Add thinking keyword mappings to risk levels |

## Dependencies

```
Step 1 → Steps 2, 4 (Knowledge base needed for imports and references)
Step 2 → Step 4 (CLAUDE.md streamlined before prompt updates)
Step 3 → Steps 4, 5, 11 (Thinking utility needed for integration)
Step 4 → Steps 5, 6 (Template updated before command integration)
Steps 5, 6 → Step 13 (Commands updated before integration test)
Steps 7, 8, 9, 10 → Step 13 (All commands ready for testing)
Step 11 → Step 13 (Python scripts updated for full test)
Step 12 → Step 13 (Git guidance complete for full test)
```

## Success Criteria

- [ ] Knowledge base created with 5 modular files
- [ ] CLAUDE.md reduced to ~250 lines with working @imports
- [ ] Thinking keywords appear in generated prompts based on risk level
- [ ] Explore phase documented and executed in plan-feature-initial
- [ ] TDD emphasized as default implementation technique
- [ ] Context management guidance appears in plan-next output
- [ ] Checkpoint/recovery guidance in rollback command
- [ ] All Python scripts pass their tests
- [ ] Full workflow executes without errors (new plan → prompts → next)
- [ ] Generated prompts include all expected sections

## Rollback Plan

1. **Per-step rollback**: Each step creates or modifies specific files
2. **Git safety**: Commit after each step for easy revert
3. **Backup strategy**: Existing commands backed up before modification
4. **Isolated testing**: Test each command independently before integration

## Phase 2 (Deferred)

The following items are explicitly deferred to a future plan:
- Custom subagents in `.claude/agents/` (code-reviewer, test-writer)
- CI/CD GitHub Actions integration
- Token tracking in progress.json
- Automatic /compact triggers

## Revision History

| Date | Changes |
|------|---------|
| 2026-01-21 | Initial plan created |
| 2026-01-21 | Review: Clarified Step 3/11 scope, fixed capitalization |
