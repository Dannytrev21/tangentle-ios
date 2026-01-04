# Step 4: Knowledge Base - Technique Documentation

## Problem Type
`migration`

## Technique Selection
- **Planning**: least-to-most - Migrate techniques from simplest to most complex
- **Implementation**: chain-of-code - Adapt markdown content for Windsurf context
- **Verification**: reflexion - Learn from any missing/incorrect content

## Risk Level
**medium** - Content migration may miss nuances; requires careful review

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
The planning system uses 10 prompt engineering techniques, each with detailed instructions for AI agents. These technique documents need to be migrated to `.windsurf/knowledge/techniques/` where they can be referenced by the prompt composer and embedded in step prompts.

## Goal
Create comprehensive technique documentation for all 10 prompt engineering techniques, adapted for Windsurf Cascade's execution model.

## Prerequisites
- Step 1 completed (`.windsurf/knowledge/techniques/` exists)
- Access to Claude Code technique files in `.claude/commands/`

## High-Level Steps
1. Migrate PS+ (Plan-and-Solve Plus) technique
2. Migrate TDD (Test-Driven Development) technique
3. Migrate ToT (Tree of Thoughts) technique
4. Migrate GoT (Graph of Thoughts) technique
5. Migrate Reflexion technique with memory bank format
6. Migrate Self-Refine technique
7. Migrate Self-Consistency technique
8. Migrate ReAct technique
9. Migrate Chain-of-Code technique
10. Migrate Least-to-Most technique
11. Create architecture.md overview document

## Detailed Requirements

### Technique Document Structure
Each technique file should contain:

```markdown
# {Technique Name}

## Overview
{1-2 paragraph description of the technique}

## When to Use
- {Use case 1}
- {Use case 2}
- {Use case 3}

## How It Works
{Step-by-step process description}

## Execution Instructions
{Detailed instructions for AI agent to follow}

## Example Application
{Concrete example of technique in action}

## Common Pitfalls
- {Pitfall 1}
- {Pitfall 2}

## Verification Checklist
- [ ] {Verification item 1}
- [ ] {Verification item 2}
```

### Technique Reference Table
Create in `architecture.md`:

| Technique | Best For | Cost | Phase Typical |
|-----------|----------|------|---------------|
| PS+ | Structured planning | Low | Planning |
| TDD | Implementation with tests | Medium | Implementation |
| ToT | Complex decisions | High | Planning |
| GoT | Merging/refinement | High | Verification |
| Reflexion | Learning from failures | Medium | Verification |
| Self-Refine | Iterative improvement | Medium | Implementation |
| Self-Consistency | Algorithm verification | High | Verification |
| ReAct | Interactive problem-solving | Medium | Planning |
| Chain-of-Code | Mixed logic/semantic | Medium | Implementation |
| Least-to-Most | Decomposition | Low | Planning |

### Content Adaptation for Windsurf
1. Remove Claude Code-specific references
2. Adapt command invocation examples
3. Ensure instructions work with Cascade's execution model
4. Preserve core algorithm/process descriptions

## Files to Create
- `.windsurf/knowledge/architecture.md`
- `.windsurf/knowledge/techniques/ps-plus.md`
- `.windsurf/knowledge/techniques/tdd.md`
- `.windsurf/knowledge/techniques/tot.md`
- `.windsurf/knowledge/techniques/got.md`
- `.windsurf/knowledge/techniques/reflexion.md`
- `.windsurf/knowledge/techniques/self-refine.md`
- `.windsurf/knowledge/techniques/self-consistency.md`
- `.windsurf/knowledge/techniques/react.md`
- `.windsurf/knowledge/techniques/chain-of-code.md`
- `.windsurf/knowledge/techniques/least-to-most.md`
- `.windsurf/technique-config.json` (technique mappings - port from .claude/)

## Files to Modify
None.

## Patterns to Follow
Reference: `.claude/commands/tdd.md` for TDD structure (most comprehensive)
Reference: `.claude/commands/reflexion.md` for memory bank format
Reference: `.claude/commands/tot.md` for Tree of Thoughts structure

## Acceptance Criteria
- [ ] All 10 technique files created in `.windsurf/knowledge/techniques/`
- [ ] `architecture.md` created with technique reference table
- [ ] Each technique file follows the standard structure
- [ ] Technique files contain actionable instructions for AI agents
- [ ] No Claude Code-specific references remain
- [ ] reflexion.md includes memory bank entry format
- [ ] tdd.md includes Red-Green-Refactor cycle

## Testing Requirements

### Unit Tests
**N/A** - Documentation files, tested by content review.

### Manual Verification
- [ ] Each technique file has all required sections
- [ ] Execution instructions are clear and actionable
- [ ] No broken references to Claude Code paths
- [ ] reflexion.md memory bank format is complete
- [ ] architecture.md table matches technique files

## Verification Commands
```bash
# Verify all technique files exist
ls -la .windsurf/knowledge/techniques/*.md

# Check each file has required sections
for f in .windsurf/knowledge/techniques/*.md; do
  echo "=== $f ==="
  grep -c "## Overview\|## When to Use\|## How It Works\|## Execution Instructions" "$f"
done

# Check for Claude Code references (should be 0)
grep -ri "\.claude" .windsurf/knowledge/

# Verify architecture.md exists and has technique table
head -50 .windsurf/knowledge/architecture.md
```

## Documentation Updates
This step IS the documentation. No additional updates needed.

## Error Recovery
If verification fails:
1. Compare with source files in `.claude/commands/`
2. Check for missing sections in technique files
3. Verify no Claude Code paths leaked through
4. Ensure memory bank format matches Reflexion spec

## Do NOT
- Simply copy files without adaptation
- Keep Claude Code-specific path references
- Skip any of the 10 techniques
- Omit the memory bank entry format from reflexion.md
