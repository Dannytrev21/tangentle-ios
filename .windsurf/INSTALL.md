# Installing Windsurf Planning System

A step-by-step system for AI-assisted feature implementation with intelligent technique selection.

## Prerequisites

- Windsurf IDE installed
- Python 3.8+ available (`python3 --version`)
- Git repository initialized (`git status`)

## Installation

### Option 1: Copy from Existing Project

```bash
# From a project that has Windsurf planning:
cp -r path/to/project/.windsurf .

# Verify installation
python3 .windsurf/scripts/windsurf_plan.py --help
```

### Option 2: Manual Setup

```bash
# 1. Create directory structure
mkdir -p .windsurf/{workflows,plans,scripts/tests,templates,knowledge/techniques,memory-bank,rules}

# 2. Copy core files (from template or source):
#    - .windsurf/scripts/*.py          (9 Python scripts)
#    - .windsurf/workflows/*.md        (11 workflow files)
#    - .windsurf/templates/*.template  (6 templates)
#    - .windsurf/knowledge/**          (technique docs)
#    - .windsurf/technique-config.json (optional config)

# 3. Create Python module markers
touch .windsurf/scripts/__init__.py
touch .windsurf/scripts/tests/__init__.py

# 4. Update .gitignore (important!)
echo ".windsurf/**" >> .gitignore
```

## Verification

```bash
# Check directory structure
find .windsurf -type d | sort

# Expected:
# .windsurf
# .windsurf/knowledge
# .windsurf/knowledge/techniques
# .windsurf/memory-bank
# .windsurf/plans
# .windsurf/rules
# .windsurf/scripts
# .windsurf/scripts/tests
# .windsurf/templates
# .windsurf/workflows

# Test Python scripts
python3 .windsurf/scripts/windsurf_plan.py --help

# Expected: CLI help with classify, techniques, risk, etc.

# Test in Windsurf
# Type /plan-status in Cascade - should show "No plans found"
```

## Post-Installation Setup

### Initialize Project Context

First time you run `/plan-feature`, the system creates:
- `PROJECT_CONTEXT.md` - Static project overview
- `memory-bank/` files - Session context tracking

You can pre-populate these manually:

```bash
# Create project context
cat > .windsurf/PROJECT_CONTEXT.md << 'EOF'
# Project Context

## Overview
Brief project description here.

## Tech Stack
| Component | Technology |
|-----------|------------|
| Language  | Swift/Python/TypeScript/etc |
| Framework | Your framework |

## Architecture
High-level architecture notes.

## Key Patterns
Important patterns used.
EOF
```

## Updating

When new versions are available:

```bash
# Backup existing plans
cp -r .windsurf/plans .windsurf/plans.backup

# Copy new files (preserves plans/)
cp -r path/to/new/.windsurf/workflows .windsurf/
cp -r path/to/new/.windsurf/scripts .windsurf/
cp -r path/to/new/.windsurf/templates .windsurf/
cp -r path/to/new/.windsurf/knowledge .windsurf/

# Re-verify
python3 .windsurf/scripts/windsurf_plan.py --help
```

## Troubleshooting Installation

### "command not found: python3"
Install Python 3.8+:
- macOS: `brew install python`
- Ubuntu: `apt install python3`
- Windows: Download from python.org

### "No module named X"
The system uses only Python standard library. If you see import errors:
```bash
# Ensure __init__.py exists
touch .windsurf/scripts/__init__.py
touch .windsurf/scripts/tests/__init__.py
```

### .windsurf appears in git status
```bash
# Check .gitignore entry
grep windsurf .gitignore

# Add if missing
echo ".windsurf/**" >> .gitignore

# Unstage if already staged
git reset .windsurf/
```

---

Next: [QUICK_START.md](QUICK_START.md) - Create your first plan
