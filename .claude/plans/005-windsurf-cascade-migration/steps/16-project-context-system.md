# Step 16: Project Context System

## Problem Type
`documentation`

## Technique Selection
- **Planning**: ps-plus - Structure context file organization
- **Implementation**: self-refine - Iterate on content structure
- **Verification**: got - Ensure context files work together

## Risk Level
**low** - Documentation creation; low risk

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Context
The project context system provides persistent context for Cascade across sessions. It includes static project overview, dynamic memory bank files, and repo-specific knowledge.

## Goal
Create the complete project context system with templates and initialization.

## Prerequisites
- Step 1 completed (directories exist)
- Step 14 completed (_internal-init creates structure)

## High-Level Steps
1. Create PROJECT_CONTEXT.md template
2. Create memory-bank file templates
3. Create knowledge file templates
4. Implement context update triggers
5. Document context refresh workflow

## Detailed Requirements

### PROJECT_CONTEXT.md
Static project overview (updated rarely):

```markdown
# Project Context

## Overview
{Brief project description - what it does, why it exists}

## Tech Stack
| Component | Technology |
|-----------|------------|
| Language | {language} |
| Framework | {framework} |
| Database | {database} |
| Testing | {testing framework} |

## Architecture
{High-level architecture description}

### Key Components
- **{Component 1}**: {description}
- **{Component 2}**: {description}

### Data Flow
{How data moves through the system}

## Key Patterns
{Important patterns used in the codebase}

## Conventions
### Naming
- {convention 1}
- {convention 2}

### File Organization
{How files are organized}

### Testing
{Testing conventions}

## External Dependencies
- {dependency 1}: {purpose}
- {dependency 2}: {purpose}

---
*Last updated: {date}*
```

### Memory Bank Files

#### productContext.md
```markdown
# Product Context

## Purpose
{What the product does and why}

## Users
{Who uses the product}

## Goals
{Product goals and metrics}

## Current Focus
{Current development priorities}

---
*Last updated: {date}*
```

#### activeContext.md
```markdown
# Active Context

## Current Work
{What's currently being worked on}

## Recent Changes
{Recent significant changes}

## Open Questions
{Unresolved questions}

## Blockers
{Current blockers}

---
*Last updated: {date}*
```

#### progress.md
```markdown
# Progress Tracking

## Current Session
- Started: {date}
- Focus: {what we're doing}

## Completed This Session
{List of completed items}

## In Progress
{List of in-progress items}

## Next Steps
{Planned next actions}

---
*Last updated: {date}*
```

#### decisionLog.md (append-only)
```markdown
# Decision Log

## Decisions

### {date} - {decision title}
**Context**: {why this decision was needed}
**Options Considered**:
1. {option 1}
2. {option 2}
**Decision**: {what was decided}
**Rationale**: {why}
**Consequences**: {expected impact}

---
```

#### systemPatterns.md
```markdown
# System Patterns

## Discovered Patterns

### {Pattern Name}
**Where Used**: {files/components}
**Description**: {what it does}
**Example**:
\`\`\`{language}
{code example}
\`\`\`

---
*Last updated: {date}*
```

### Knowledge Files

#### architecture.md
```markdown
# Architecture Guide

## System Architecture
{Diagram or description}

## Layer Responsibilities
| Layer | Responsibility | Key Files |
|-------|----------------|-----------|
| {layer} | {what it does} | {files} |

## Dependencies
{How components depend on each other}

---
*Last updated: {date}*
```

#### repo-commands.md (auto-generated)
```markdown
# Repository Commands

## Build
\`\`\`bash
{build command}
\`\`\`

## Test
\`\`\`bash
{test command}
\`\`\`

## Lint
\`\`\`bash
{lint command}
\`\`\`

## Run
\`\`\`bash
{run command}
\`\`\`

---
*Auto-discovered on: {date}*
*Source: {where discovered from}*
```

### Context Update Triggers
Workflows should update context when:
1. **PROJECT_CONTEXT.md**: Major architecture changes
2. **activeContext.md**: Every session start/end
3. **progress.md**: After each step completion
4. **decisionLog.md**: After significant decisions (append)
5. **systemPatterns.md**: When new patterns discovered
6. **repo-commands.md**: When test/build commands change

### Windsurf Memories Integration
For cross-plan learnings, instruct workflows to:
```
Create a memory of: "{insight description}"
```

This surfaces the insight to Windsurf's native Memories for automatic retrieval.

## Files to Create
- `.windsurf/PROJECT_CONTEXT.md`
- `.windsurf/memory-bank/productContext.md`
- `.windsurf/memory-bank/activeContext.md`
- `.windsurf/memory-bank/progress.md`
- `.windsurf/memory-bank/decisionLog.md`
- `.windsurf/memory-bank/systemPatterns.md`
- `.windsurf/knowledge/architecture.md`
- `.windsurf/knowledge/repo-commands.md`

## Files to Modify
- `.windsurf/workflows/_internal-init.md` (ensure files created)

## Patterns to Follow
Reference: Memory bank structure from spec

## Acceptance Criteria
- [ ] PROJECT_CONTEXT.md created with template
- [ ] All 5 memory-bank files created
- [ ] All 2 knowledge files created
- [ ] Files have clear section structure
- [ ] Update triggers documented
- [ ] Windsurf Memories integration noted
- [ ] _internal-init creates these files

## Testing Requirements

### Unit Tests
**N/A** - Documentation files; no logic to test.

### Integration Tests
- [ ] Run _internal-init
- [ ] Verify all context files created
- [ ] Verify templates have correct structure
- [ ] Test appending to decisionLog.md

### Manual Verification
- [ ] File templates are complete
- [ ] Placeholders are clear
- [ ] Update triggers make sense

## Verification Commands
```bash
# Verify all files exist
ls -la .windsurf/PROJECT_CONTEXT.md
ls -la .windsurf/memory-bank/*.md
ls -la .windsurf/knowledge/*.md

# Check file structure
head -20 .windsurf/PROJECT_CONTEXT.md
head -10 .windsurf/memory-bank/decisionLog.md

# Verify append works for decision log
echo "### Test Entry" >> .windsurf/memory-bank/decisionLog.md
tail -5 .windsurf/memory-bank/decisionLog.md
```

## Documentation Updates
This step IS the documentation system. No additional updates needed.

## Error Recovery
If verification fails:
1. Check file creation permissions
2. Verify _internal-init runs correctly
3. Check template syntax
4. Ensure no missing sections

## Do NOT
- Create overly complex templates
- Skip any required files
- Make templates project-specific (must be generic)
- Forget update trigger documentation
