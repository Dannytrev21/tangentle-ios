---
name: _internal-init
description: Initialize Windsurf directory structure
---

# Internal: Initialize Windsurf Structure

Creates the complete .windsurf/ directory structure and initializes required files.

## When to Use

Call this helper when:
- First plan is being created
- Directory structure needs repair
- Setting up Windsurf in a new repository

## Steps

### 1. Create Directory Structure

```bash
mkdir -p .windsurf/{workflows,plans,scripts/tests,templates,knowledge/techniques,memory-bank,rules}
```

### 2. Create Python Module Markers

```bash
touch .windsurf/scripts/__init__.py
touch .windsurf/scripts/tests/__init__.py
```

### 3. Create .gitkeep Files

```bash
for dir in workflows plans templates knowledge knowledge/techniques memory-bank rules; do
  touch .windsurf/$dir/.gitkeep
done
```

### 4. Update .gitignore

```bash
if ! grep -q '.windsurf/\*\*' .gitignore 2>/dev/null; then
  echo -e "\n# Windsurf IDE (local planning system)\n.windsurf/**" >> .gitignore
fi
```

### 5. Create PROJECT_CONTEXT.md Template

Only if it doesn't exist:

```bash
if [ ! -f .windsurf/PROJECT_CONTEXT.md ]; then
cat > .windsurf/PROJECT_CONTEXT.md << 'EOF'
# Project Context

> **Update Trigger**: Major architecture changes, new major dependencies.

## Overview
{Brief project description}

## Tech Stack
| Component | Technology |
|-----------|------------|
| Language | {language} |
| Framework | {framework} |

## Architecture
{High-level architecture}

## Key Patterns
{Important patterns used}

## Conventions
{Coding conventions}

---
*Last updated: {date}*
EOF
fi
```

### 6. Initialize Memory Bank Files

Create each file with proper template if missing:

**productContext.md** (Update on product direction changes):
```bash
if [ ! -f ".windsurf/memory-bank/productContext.md" ]; then
cat > .windsurf/memory-bank/productContext.md << 'EOF'
# Product Context

> **Update Trigger**: Product direction changes, new target users.

## Purpose
{What the product does}

## Users
{Who uses the product}

## Current Focus
{Development priorities}

---
*Last updated: {date}*
EOF
fi
```

**activeContext.md** (Update every session):
```bash
if [ ! -f ".windsurf/memory-bank/activeContext.md" ]; then
cat > .windsurf/memory-bank/activeContext.md << 'EOF'
# Active Context

> **Update Trigger**: Every session start/end.

## Current Work
{What's being worked on}

## Recent Changes
{Recent changes}

## Open Questions
{Unresolved questions}

---
*Last updated: {date}*
EOF
fi
```

**progress.md** (Update after step completion):
```bash
if [ ! -f ".windsurf/memory-bank/progress.md" ]; then
cat > .windsurf/memory-bank/progress.md << 'EOF'
# Progress Tracking

> **Update Trigger**: After each step completion.

## Current Session
- Started: {date}
- Focus: {objective}

## Completed This Session
{List of completed items}

## Next Steps
{Planned next actions}

---
*Last updated: {date}*
EOF
fi
```

**decisionLog.md** (Append-only after decisions):
```bash
if [ ! -f ".windsurf/memory-bank/decisionLog.md" ]; then
cat > .windsurf/memory-bank/decisionLog.md << 'EOF'
# Decision Log

> **Update Trigger**: Append after significant decisions. Never delete entries.

## Decisions

### {date} - {Decision Title}
**Context**: {Why needed}
**Decision**: {What was decided}
**Rationale**: {Why}

---
*Append-only log*
EOF
fi
```

**systemPatterns.md** (Update when patterns discovered):
```bash
if [ ! -f ".windsurf/memory-bank/systemPatterns.md" ]; then
cat > .windsurf/memory-bank/systemPatterns.md << 'EOF'
# System Patterns

> **Update Trigger**: When new patterns discovered.

## Discovered Patterns

### {Pattern Name}
**Where Used**: {files/components}
**Description**: {what it does}

---
*Last updated: {date}*
EOF
fi
```

### 7. Initialize Knowledge Files

Create repo-commands.md if missing:

```bash
if [ ! -f ".windsurf/knowledge/repo-commands.md" ]; then
cat > .windsurf/knowledge/repo-commands.md << 'EOF'
# Repository Commands

> **Update Trigger**: When build/test commands change.

## Quick Reference
| Action | Command |
|--------|---------|
| Build | `{build command}` |
| Test | `{test command}` |
| Lint | `{lint command}` |
| Run | `{run command}` |

---
*Auto-discovered on: {date}*
EOF
fi
```

## Output

Return confirmation:

```
═══════════════════════════════════════
  ✅ WINDSURF INITIALIZED
═══════════════════════════════════════

Directories: {count} created/verified
Files: {count} initialized
.gitignore: {updated/already configured}

Structure:
.windsurf/
├── workflows/       (command definitions)
├── plans/           (implementation plans)
├── scripts/         (Python utilities)
│   └── tests/       (unit tests)
├── templates/       (artifact templates)
├── knowledge/
│   └── techniques/  (prompt techniques)
├── memory-bank/     (context persistence)
└── rules/           (custom rules)
═══════════════════════════════════════
```

## Idempotent

This helper is safe to run multiple times:
- Existing directories are not modified
- Existing files are not overwritten
- .gitignore entry is only added once

## Do NOT

- Do NOT overwrite existing files
- Do NOT delete any content
- Do NOT modify existing .gitignore entries
