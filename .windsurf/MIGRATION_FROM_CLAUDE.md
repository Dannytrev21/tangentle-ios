# Migrating from Claude Code

If you're coming from Claude Code's planning system, this guide maps the concepts and shows migration steps.

## Directory Mapping

| Claude Code | Windsurf | Notes |
|-------------|----------|-------|
| `.claude/commands/` | `.windsurf/workflows/` | Markdown workflows |
| `.claude/plans/` | `.windsurf/plans/` | Same structure |
| `.claude/scripts/` | `.windsurf/scripts/` | Same Python files |
| `.claude/technique-config.json` | `.windsurf/technique-config.json` | Optional config |
| `CLAUDE.md` | `.windsurf/PROJECT_CONTEXT.md` | Project context |

## Command Mapping

| Claude Code | Windsurf | Notes |
|-------------|----------|-------|
| `/plan-feature-initial` | `/plan-feature-initial` | Same |
| `/plan-feature` | `/plan-feature` | Same |
| `/plan-prompts` | `/plan-prompts` | Same |
| `/plan-next` | `/plan-next` | Same |
| `/plan-status` | `/plan-status` | Same |
| `/plan-verify` | `/plan-verify` | Same |
| `/plan-rollback` | `/plan-rollback` | Same |
| `/plan-feature-review` | `/plan-feature-review` | Same |

## What Stays the Same

The core system is identical:

- **Plan Structure**: plan.md, adr.md, steps/, prompts/, progress.json, context.md
- **Problem Types**: 33 types in 8 categories (FOUNDATION, DATA, ARCHITECTURE, UI/UX, TESTING, LOGIC, DOCUMENTATION, META)
- **Techniques**: 10 techniques (ToT, GoT, TDD, Reflexion, Self-Refine, etc.)
- **Self-Correction**: Memory bank with FIFO (max 10), retry budgets per risk level
- **Phase Execution**: Planning → Implementation → Verification
- **File Tracking**: Created, modified, deleted, renamed per step
- **Progress Tracking**: JSON state with technique metadata

## What's Different

### Workflow Format
Claude Code commands are in `.claude/commands/` as skill definitions.
Windsurf workflows are in `.windsurf/workflows/` as markdown with YAML frontmatter.

### Character Limit
Windsurf workflows have a 12,000 character limit.
Complex logic is decomposed into helper workflows (`_internal-*.md`).

### Native Memories
Windsurf has native Memories integration.
The memory bank still uses file-based storage for plan-specific context.

### .gitignore Pattern
| System | Pattern |
|--------|---------|
| Claude Code | `.claude/**` (often committed) |
| Windsurf | `.windsurf/**` (never committed) |

## Migration Steps

### Step 1: Create Windsurf Structure

```bash
mkdir -p .windsurf/{workflows,plans,scripts/tests,templates,knowledge/techniques,memory-bank,rules}
touch .windsurf/scripts/__init__.py
touch .windsurf/scripts/tests/__init__.py
```

### Step 2: Copy Python Scripts

```bash
# Copy all scripts
cp .claude/scripts/*.py .windsurf/scripts/

# Update paths in scripts (if any hardcoded .claude references)
# Most scripts use relative paths, so this may not be needed
```

### Step 3: Copy Existing Plans (Optional)

If you want to continue existing plans in Windsurf:

```bash
cp -r .claude/plans/* .windsurf/plans/

# Update any path references in progress.json
# Usually not needed as paths are relative
```

### Step 4: Copy Knowledge Base

```bash
# Copy technique documentation
cp -r .claude/knowledge/* .windsurf/knowledge/

# Copy technique config if customized
cp .claude/technique-config.json .windsurf/ 2>/dev/null || true
```

### Step 5: Copy Templates

```bash
cp .claude/templates/* .windsurf/templates/ 2>/dev/null || true
```

### Step 6: Create Project Context

Transfer key information from CLAUDE.md:

```bash
cat > .windsurf/PROJECT_CONTEXT.md << 'EOF'
# Project Context

## Overview
[Copy from CLAUDE.md overview]

## Tech Stack
[Copy from CLAUDE.md]

## Architecture
[Copy from CLAUDE.md]

## Key Patterns
[Copy from CLAUDE.md]
EOF
```

### Step 7: Update .gitignore

```bash
# Add Windsurf exclusion
echo ".windsurf/**" >> .gitignore

# Verify
grep windsurf .gitignore
```

### Step 8: Verify Installation

```bash
# Test CLI
python3 .windsurf/scripts/windsurf_plan.py --help

# List plans (if any migrated)
python3 .windsurf/scripts/windsurf_plan.py list

# Test in Windsurf
# Type /plan-status in Cascade
```

## Parallel Usage

You can use both systems in parallel:

- Claude Code: `.claude/` (for Claude Code CLI)
- Windsurf: `.windsurf/` (for Windsurf IDE)

They don't interfere because:
- Different directories
- Different .gitignore patterns
- Independent plan numbering

To share plans between systems:
```bash
# Copy a plan from Claude to Windsurf
cp -r .claude/plans/005-feature .windsurf/plans/

# Or vice versa
cp -r .windsurf/plans/001-feature .claude/plans/
```

## Differences in Usage

### Command Invocation
| Claude Code | Windsurf |
|-------------|----------|
| CLI or macro | Cascade /command |
| Terminal-based | IDE-integrated |

### Workflow Execution
| Claude Code | Windsurf |
|-------------|----------|
| Claude interprets markdown | Cascade interprets markdown |
| No character limit | 12K character limit |
| Skills system | Workflows system |

### Context Persistence
| Claude Code | Windsurf |
|-------------|----------|
| CLAUDE.md + conversation | PROJECT_CONTEXT.md + Memories |
| Compact/resume | Session-based + Memories |

## Troubleshooting Migration

### Scripts don't work
```bash
# Check for .claude path references
grep -r "\.claude" .windsurf/scripts/

# If found, replace with .windsurf
sed -i '' 's/\.claude/.windsurf/g' .windsurf/scripts/*.py
```

### Plans not found
```bash
# Check plan directory
ls .windsurf/plans/

# Verify progress.json exists
ls .windsurf/plans/*/progress.json
```

### Workflows not recognized
```bash
# Check workflow files exist
ls .windsurf/workflows/*.md

# Verify YAML frontmatter
head -5 .windsurf/workflows/plan-next.md
```

---

Next: [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
