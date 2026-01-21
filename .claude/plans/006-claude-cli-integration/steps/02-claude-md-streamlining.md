# Step 2: CLAUDE.md Streamlining

## Problem Type
`refactor`

## Technique Selection
- **Planning**: ps-plus - Structured approach to identify what to keep/move
- **Implementation**: self-refine - Iteratively trim while preserving essential context
- **Verification**: self-refine - Verify line count and that imports work

## Risk Level
**medium** - Modifying core project configuration file

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Reasoning Depth
**Think hard about** what content is essential vs. what can be imported.

## Context
The guide recommends keeping CLAUDE.md under 300 lines. The current file is approximately 300 lines. This step streamlines it to ~250 lines by moving detailed planning system documentation to the knowledge base and using @imports.

## Goal
Reduce CLAUDE.md to approximately 250 lines while maintaining all essential context through modular @imports.

## Prerequisites
- Step 1 completed (knowledge base exists for imports)

## High-Level Steps
1. Analyze current CLAUDE.md structure and identify movable content
2. Identify sections that can reference knowledge base via @imports
3. Create backup of current CLAUDE.md
4. Refactor CLAUDE.md to ~250 lines
5. Add @import references to knowledge base files
6. Verify line count and that essential context remains

## Detailed Requirements

### Content to KEEP in CLAUDE.md (Essential)
- Project Overview section
- Technology Stack table
- Core Principles list
- Architecture overview (brief)
- Key Architectural Decisions (summary)
- Project Structure tree
- Domain Entities table
- Task Status Values enum
- Energy Levels enum
- Coding Conventions (essential subset)
- Build & Run commands
- Do NOT list

### Content to MOVE/REFERENCE
- Intelligent Planning System v2 detailed tables → @.claude/knowledge/claude-code-mastery.md
- Prompt Engineering Techniques full list → technique-config.json reference
- Phase-Based Technique Selection details → knowledge reference
- Self-Correction Engine details → knowledge reference
- CLI Tool examples → brief mention + reference
- Problem Type Taxonomy full table → reference

### @import Pattern
```markdown
## Intelligent Planning System
For detailed planning system documentation including techniques and workflows:
- See @.claude/knowledge/claude-code-mastery.md
- See @.claude/knowledge/thinking-keywords.md
- Configuration: `.claude/technique-config.json`
```

## Files to Create
- None

## Files to Modify
- `CLAUDE.md`: Streamline to ~250 lines with @imports

## Patterns to Follow
Reference: Guide's recommendation "Keep it under 300 lines—shorter is better"
Reference: "Prefer pointers over copies"

## Acceptance Criteria
- [ ] CLAUDE.md is approximately 250 lines (±20)
- [ ] All essential project context remains
- [ ] @import references point to existing knowledge files
- [ ] No orphaned references to removed content
- [ ] File is well-formatted and readable
- [ ] Core commands and conventions are preserved

## Testing Requirements
**N/A - Reason**: Documentation refactoring
**Manual Verification**:
- Count lines: `wc -l CLAUDE.md` should be ~250
- Review that essential sections are present
- Verify @import paths exist
- Test that Claude can understand project from streamlined file

## Verification Commands
```bash
# Count lines
wc -l CLAUDE.md

# Verify essential sections exist
grep -c "## Project Overview" CLAUDE.md
grep -c "## Technology Stack" CLAUDE.md
grep -c "## Core Principles" CLAUDE.md
grep -c "## Coding Conventions" CLAUDE.md
grep -c "## Build & Run" CLAUDE.md

# Verify @imports reference existing files
grep "@.claude/knowledge" CLAUDE.md

# Verify knowledge files exist
ls .claude/knowledge/*.md
```

## Documentation Updates
- [ ] Update step notes in progress.json

## Error Recovery
If verification fails:
1. If too many lines: identify more content to move
2. If essential content missing: restore from backup
3. If imports broken: verify file paths
4. Re-run verification

## Do NOT
- Remove essential project context (tech stack, architecture, conventions)
- Create broken @import references
- Make file unreadable with excessive abbreviation
- Remove the "Do NOT" section
