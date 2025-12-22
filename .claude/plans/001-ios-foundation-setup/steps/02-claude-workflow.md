# Step 2: Claude Workflow Setup

## Context
We need to establish the Claude Code workflow for iOS development. This includes creating CLAUDE.md with iOS-specific instructions, slash commands optimized for Swift/Xcode development, and documentation structure. This enables consistent, high-quality AI-assisted development.

## Goal
Create comprehensive Claude Code configuration that enables productive iOS development with clear conventions and helpful commands.

## Prerequisites
- Step 1 completed (project exists)

## High-Level Steps
1. Update CLAUDE.md with iOS development guidelines
2. Create slash commands for common iOS tasks
3. Create docs/README.md with project overview
4. Create docs/ARCHITECTURE.md with detailed architecture
5. Create docs/DATA-MODEL.md with entity documentation

## Detailed Requirements

### CLAUDE.md Content
Must include:
- Project overview and purpose
- Technology stack (Swift, SwiftUI, Core Data)
- Architecture pattern (MVVM + Repository)
- File organization conventions
- Naming conventions (Swift style)
- Testing requirements
- ADHD-specific domain concepts
- Entity relationships overview
- AI service integration points
- Common development tasks

### Slash Commands
Create these commands in `.claude/commands/`:

1. **plan-feature.md** - Create implementation plan for new feature
2. **add-entity.md** - Add new Core Data entity
3. **add-feature.md** - Scaffold a new feature module
4. **add-service.md** - Create a new service with protocol
5. **run-tests.md** - Run unit/integration tests
6. **build.md** - Build project and report errors

### Documentation Structure
```
docs/
├── README.md           # Quick start, setup, overview
├── ARCHITECTURE.md     # Detailed architecture docs
└── DATA-MODEL.md       # Entity documentation
```

## Files to Create
- `.claude/commands/add-entity.md`
- `.claude/commands/add-feature.md`
- `.claude/commands/add-service.md`
- `.claude/commands/run-tests.md`
- `.claude/commands/build.md`
- `docs/README.md`
- `docs/ARCHITECTURE.md`
- `docs/DATA-MODEL.md`

## Files to Modify
- CLAUDE.md - Main Claude instructions
- `.claude/commands/plan-feature.md`

## Patterns to Follow
Reference executive-brain CLAUDE.md for domain concepts, adapt for iOS/Swift conventions.

## Acceptance Criteria
- [ ] CLAUDE.md exists with comprehensive iOS guidance
- [ ] All 6 slash commands created and functional
- [ ] docs/README.md provides clear project overview
- [ ] docs/ARCHITECTURE.md documents MVVM + Repository pattern
- [ ] docs/DATA-MODEL.md documents all planned entities
- [ ] Claude Code recognizes slash commands

## Verification Commands
```bash
# Verify files exist
ls -la tangentle-ios/CLAUDE.md
ls -la tangentle-ios/.claude/commands/
ls -la tangentle-ios/docs/

# Verify Claude recognizes commands (manual test)
# Run: /plan-feature test feature
```

## Documentation Updates
- This step creates the documentation structure

## Error Recovery
If commands don't work:
1. Verify file extension is `.md`
2. Check file is in `.claude/commands/` directory
3. Restart Claude Code session

## Do NOT
- Copy executive-brain CLAUDE.md verbatim (needs iOS adaptation)
- Include TickTick references (we're building our own system)
- Add commands for features not yet implemented
