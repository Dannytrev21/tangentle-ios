# Step 1: Knowledge Base Creation

## Problem Type
`documentation`

## Technique Selection
- **Planning**: ps-plus - Structured approach to organize multiple related documents
- **Implementation**: self-refine - Iteratively improve content quality
- **Verification**: got - Verify coherence across related documents

## Risk Level
**low** - Creating new files, no modifications to existing code

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Reasoning Depth
**Think about** the structure and content organization.

## Context
This step creates the foundation for the integration by establishing a modular knowledge base. The guide recommends keeping CLAUDE.md lean with pointer-style references. This knowledge base will contain extracted principles that prompts can reference.

## Goal
Create `.claude/knowledge/` directory with 5 modular reference documents that capture Claude Code CLI mastery patterns.

## Prerequisites
- None (first step)
- Source material: `claude_cli_system.md` in project root

## High-Level Steps
1. Create `.claude/knowledge/` directory
2. Create README.md as index
3. Extract core principles to claude-code-mastery.md
4. Document thinking keywords in thinking-keywords.md
5. Extract context management patterns to context-management.md
6. Document TDD patterns in tdd-patterns.md
7. Verify all files are well-organized and cross-referenced

## Detailed Requirements

### README.md
- Purpose: Index for the knowledge base
- Contents: List of files with brief descriptions, usage guide for @imports

### claude-code-mastery.md
Extract from `claude_cli_system.md`:
- The "explore, plan, code, commit" workflow
- CLAUDE.md best practices (under 300 lines, pointers)
- Multi-agent patterns overview
- Recovery patterns (/rewind, Escape, checkpoints)
- Git worktrees for parallel work
- Dual Claude review pattern

### thinking-keywords.md
- Document all thinking keywords: think, think hard, think harder, ultrathink
- Explain token allocation implications
- Document risk-level mapping for this project
- Include examples of when to use each

### context-management.md
- Context window basics (200K tokens)
- Session commands: /clear, /compact, /context
- Threshold guidance (50-69%, 70-84%, 85-92%, 93%+)
- "Document and Clear" pattern for multi-day work
- Memory hierarchy (enterprise → user → project → subdirectory)

### tdd-patterns.md
- The guide's TDD workflow (6 steps)
- "The robots LOVE TDD" emphasis
- Pre-commit hooks recommendation
- Existing code modification rule
- Integration with planning system techniques

## Files to Create
- `.claude/knowledge/README.md`: Index and usage guide
- `.claude/knowledge/claude-code-mastery.md`: Core guide principles
- `.claude/knowledge/thinking-keywords.md`: Depth reference
- `.claude/knowledge/context-management.md`: Session guidance
- `.claude/knowledge/tdd-patterns.md`: Test-driven patterns

## Files to Modify
- None

## Patterns to Follow
Reference: `claude_cli_system.md` for source content
Keep each file focused and under 200 lines

## Acceptance Criteria
- [ ] `.claude/knowledge/` directory exists
- [ ] README.md provides clear index with usage guide
- [ ] claude-code-mastery.md contains core workflow patterns
- [ ] thinking-keywords.md documents all keywords with risk mapping
- [ ] context-management.md has threshold guidance
- [ ] tdd-patterns.md captures full TDD workflow
- [ ] All files are well-formatted markdown
- [ ] Cross-references between files are consistent

## Testing Requirements
**N/A - Reason**: Documentation-only step
**Manual Verification**:
- Read each file and verify content accuracy against source
- Check that @imports work: reference a file from test context
- Verify no duplicate content between files

## Verification Commands
```bash
# Verify directory structure
ls -la .claude/knowledge/

# Count lines in each file (should be under 200 each)
wc -l .claude/knowledge/*.md

# Verify files contain expected sections
grep -l "explore, plan, code, commit" .claude/knowledge/*.md
grep -l "ultrathink" .claude/knowledge/*.md
grep -l "/compact" .claude/knowledge/*.md
grep -l "TDD" .claude/knowledge/*.md
```

## Documentation Updates
- [ ] Update this step's notes in progress.json upon completion

## Error Recovery
If verification fails:
1. Identify which file is incomplete or incorrect
2. Review source material in `claude_cli_system.md`
3. Refine the specific file content
4. Re-run verification

## Do NOT
- Copy entire guide verbatim - extract and organize
- Create overly long files (keep under 200 lines each)
- Include CI/CD GitHub Actions content (explicitly excluded)
- Duplicate content between files
