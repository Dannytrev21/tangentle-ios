# Plan 006 Context

This file maintains context for resuming work on this plan from a fresh terminal or after conversation compacting.

## Quick Status
- **Plan**: Claude CLI System Full Integration
- **Current Step**: 0 - Not Started
- **Last Updated**: 2026-01-21

## What's Been Done
- Plan created and structured
- ADR documented with all key decisions
- 13 steps defined with technique assignments
- Progress.json initialized

## Integration Decisions Summary

| Decision | Selection | Rationale |
|----------|-----------|-----------|
| Integration Depth | D) Full | Comprehensive coverage requested |
| CLAUDE.md Strategy | A) Streamline + imports | Follow guide's 300 line recommendation |
| Thinking Keywords | A) Risk-mapped | Automatic appropriate depth |
| Explore Phase | B) Substep | Integrated without new command |
| Context Management | B) Guidance only | Simple, no tracking overhead |
| Subagents | Deferred | Phase 2 future work |
| Backward Compatibility | No | Fresh start with enhanced system |

## Files to Create
| File | Purpose | Status |
|------|---------|--------|
| `.claude/knowledge/README.md` | Index | Pending |
| `.claude/knowledge/claude-code-mastery.md` | Core principles | Pending |
| `.claude/knowledge/thinking-keywords.md` | Depth reference | Pending |
| `.claude/knowledge/context-management.md` | Session guidance | Pending |
| `.claude/knowledge/tdd-patterns.md` | Test patterns | Pending |

## Files to Modify
| File | Changes | Status |
|------|---------|--------|
| `CLAUDE.md` | Streamline to ~250 lines | Pending |
| `.claude/commands/plan-prompts.md` | Add thinking keywords section | Pending |
| `.claude/commands/plan-next.md` | Add context guidance | Pending |
| `.claude/commands/plan-feature-initial.md` | Add explore substep | Pending |
| `.claude/commands/plan-feature.md` | Strengthen TDD | Pending |
| `.claude/commands/plan-rollback.md` | Add recovery patterns | Pending |
| `.claude/commands/plan-verify.md` | Enhance verification | Pending |
| `.claude/scripts/technique_selector.py` | Add thinking keyword function | Pending |
| `.claude/scripts/utils.py` | Add thinking utilities | Pending |
| `.claude/technique-config.json` | Add thinking mappings | Pending |

## Key Patterns to Embed

### Thinking Keywords (from guide)
- "think" → standard reasoning
- "think hard" → increased depth
- "think harder" → more allocation
- "ultrathink" → maximum budget (~31,999 tokens)

### Mapped to Risk:
- Low risk → "think about"
- Medium risk → "think hard about"
- High/Critical risk → "ultrathink about"

### Explore Phase (from guide)
"Ask Claude to read relevant files without writing code. Be explicit: 'Read the authentication module and explain how sessions are managed. Don't write any code yet.'"

### Context Thresholds (from guide)
- 50-69%: Work normally
- 70-84%: Consider `/compact`
- 85-92%: Auto-compact may trigger
- 93%+: Use `/clear`

### TDD Pattern (from guide)
1. Write failing tests first
2. Confirm tests fail
3. Commit the tests
4. Implement to pass
5. Verify with subagent
6. Commit implementation

### Git Checkpoints (from guide)
- Commit frequently - Git is your safety net
- Before risky modifications, create explicit checkpoints
- `git add -A && git commit -m "checkpoint before refactoring"`

## Tests Created
| Test File | Test Cases | Status |
|-----------|------------|--------|
| None yet | - | - |

## Current State
Plan initialized. Ready for Step 1: Knowledge Base Creation.

## Next Actions
1. Run `/plan-prompts 006` to generate prompts
2. Run `/plan-next 006` to start Step 1

## Things to Remember
- This plan modifies the planning system itself (meta-level)
- Changes affect how future plans are created and executed
- No backward compatibility with plans 001-005 required
- Subagents are explicitly deferred to Phase 2
- Testing is primarily manual verification + Python unit tests

## Blockers
None currently.

## Learnings
- **2026-01-21 Review**: Steps 3 and 11 had overlapping scope for thinking keywords. Clarified: Step 3 handles ALL implementation (config, utils, TechniqueSelector). Step 11 only adds CLI command.
- Capitalization standardized to "Think about" (capitalized)
