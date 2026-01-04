# Step 18: Migration Guide Documentation

## Problem Type
`documentation`

## Technique Selection
- **Planning**: ps-plus - Structure documentation sections
- **Implementation**: self-refine - Iterate on clarity
- **Verification**: got - Ensure guide is complete and coherent

## Risk Level
**low** - Documentation only; no code changes

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Context
With all components built and tested, users need documentation on how to migrate from Claude Code to Windsurf, or how to set up the system in a new repository.

## Goal
Create comprehensive documentation for installing and using the Windsurf planning system.

## Prerequisites
- Step 17 completed (system is tested and working)

## High-Level Steps
1. Write installation guide
2. Write quick start guide
3. Write command reference
4. Write migration guide from Claude Code
5. Write troubleshooting guide
6. Create README for .windsurf/

## Detailed Requirements

### Installation Guide

```markdown
# Installing Windsurf Planning System

## Prerequisites
- Windsurf IDE installed
- Python 3.8+ available
- Git repository initialized

## Installation

### Option 1: Copy from Template Repository
\`\`\`bash
# Clone template
git clone https://github.com/user/windsurf-planning-template /tmp/template

# Copy to your repo
cp -r /tmp/template/.windsurf .

# Initialize
# Type /plan-feature-initial in Windsurf Cascade
\`\`\`

### Option 2: Manual Setup
\`\`\`bash
# Create directory structure
mkdir -p .windsurf/{workflows,plans,scripts/tests,templates,knowledge/techniques,memory-bank,rules}

# Copy Python scripts
# Copy workflow files
# Copy templates
# Copy knowledge files

# Update .gitignore
echo ".windsurf/**" >> .gitignore
\`\`\`

## Verification
\`\`\`bash
# Check structure
find .windsurf -type d | sort

# Test Python scripts
python3 .windsurf/scripts/windsurf_plan.py --help

# Test in Windsurf
# Type /plan-status in Cascade
\`\`\`
```

### Quick Start Guide

```markdown
# Quick Start: Windsurf Planning System

## Create Your First Plan

1. **Open Windsurf** in your repository

2. **Type in Cascade chat**:
   \`\`\`
   /plan-feature-initial Add a new user profile feature
   \`\`\`

3. **Answer the questions** Cascade presents

4. **Confirm** to proceed to plan creation

5. **Generate prompts**:
   \`\`\`
   /plan-prompts 001
   \`\`\`

6. **Start implementation**:
   \`\`\`
   /plan-next 001
   \`\`\`

7. **Check progress**:
   \`\`\`
   /plan-status 001
   \`\`\`

## Daily Workflow

\`\`\`
1. /plan-status           # See where you are
2. /plan-next [N]         # Continue implementation
3. commit when prompted   # Save progress
4. /plan-status           # Confirm progress
\`\`\`
```

### Command Reference

```markdown
# Command Reference

## /plan-feature-initial [description]
Analyze a feature idea and prepare for planning.

**Input**: Natural language feature description
**Output**: Problem classification, questions, ready /plan-feature prompt

---

## /plan-feature [description]
Create a new implementation plan.

**Input**: Detailed feature specification
**Output**: Plan directory with all artifacts

---

## /plan-prompts [plan-number]
Generate AI prompts for each step.

**Input**: Plan number (optional, defaults to most recent)
**Output**: Prompt files in prompts/

---

## /plan-next [plan-number]
Execute the next step in a plan.

**Input**: Plan number (optional)
**Output**: Step execution with phases, file tracking, commit prompt

---

## /plan-status [plan-number]
Display plan progress.

**Input**: Plan number (optional)
**Output**: Progress bar, step table, context summary

---

## /plan-verify [plan-number]
Re-run verification for current step.

**Input**: Plan number (optional)
**Output**: PASS/FAIL results per criterion

---

## /plan-rollback [plan-number]
Revert current step's uncommitted changes.

**Input**: Plan number (optional)
**Output**: Reverted files, reset step status

---

## /plan-feature-review [plan-number]
Review plan quality with agentic reasoning.

**Input**: Plan number (optional)
**Output**: 6-dimension analysis, recommendations, review log
```

### Migration from Claude Code

```markdown
# Migrating from Claude Code

## What Changes

| Claude Code | Windsurf |
|-------------|----------|
| `.claude/commands/` | `.windsurf/workflows/` |
| `.claude/plans/` | `.windsurf/plans/` |
| `.claude/scripts/` | `.windsurf/scripts/` |
| `CLAUDE.md` | `.windsurf/PROJECT_CONTEXT.md` |
| Python CLI | Same CLI, adapted paths |

## What Stays the Same
- Plan structure (plan.md, adr.md, steps/, prompts/, etc.)
- Problem type taxonomy (33 types, 8 categories)
- Technique selection (10 techniques)
- Self-correction with memory bank
- Progress tracking in JSON

## Migration Steps

### 1. Copy Scripts
\`\`\`bash
# Adapt paths in scripts
cp .claude/scripts/*.py .windsurf/scripts/
# Edit: replace .claude with .windsurf
\`\`\`

### 2. Copy Existing Plans (Optional)
\`\`\`bash
# If you want to continue existing plans
cp -r .claude/plans/* .windsurf/plans/
\`\`\`

### 3. Copy Knowledge
\`\`\`bash
cp .claude/technique-config.json .windsurf/
\`\`\`

### 4. Update .gitignore
\`\`\`bash
echo ".windsurf/**" >> .gitignore
\`\`\`

### 5. Test
\`\`\`bash
python3 .windsurf/scripts/windsurf_plan.py list
\`\`\`

## Differences in Usage
- Commands are `/plan-*` instead of macro-based
- Cascade executes workflows directly
- Native Memories integration available
- 12K character limit requires workflow decomposition
```

### Troubleshooting Guide

```markdown
# Troubleshooting

## Common Issues

### Workflow not found
**Symptom**: Cascade doesn't recognize /plan-* command
**Solution**: Check .windsurf/workflows/ exists with .md files

### Python script error
**Symptom**: Command output shows Python error
**Solution**:
1. Check Python 3.8+ installed: `python3 --version`
2. Check script paths: `ls .windsurf/scripts/`
3. Run directly: `python3 .windsurf/scripts/windsurf_plan.py --help`

### .windsurf files in commit
**Symptom**: .windsurf/** appears in git status as staged
**Solution**:
1. Unstage: `git reset .windsurf/`
2. Check .gitignore: `grep windsurf .gitignore`
3. Add if missing: `echo ".windsurf/**" >> .gitignore`

### Plan not found
**Symptom**: /plan-next says no plans exist
**Solution**:
1. Check plans: `ls .windsurf/plans/`
2. Create plan: `/plan-feature {description}`

### Self-correction not working
**Symptom**: Step fails without retry
**Solution**:
1. Check progress.json has retryConfig
2. Check memory bank: `ls .windsurf/plans/{N}/memory-bank.json`
3. Run: `python3 .windsurf/scripts/windsurf_plan.py retry --help`

### Prompts not generated
**Symptom**: /plan-next says prompts missing
**Solution**: Run `/plan-prompts {plan-number}`
```

### README for .windsurf/

```markdown
# .windsurf/ - Planning System

This directory contains the Windsurf planning system for AI-assisted development.

## Structure
- `workflows/` - Workflow commands (/plan-*)
- `plans/` - Implementation plans
- `scripts/` - Python utilities
- `templates/` - Artifact templates
- `knowledge/` - Reference documentation
- `memory-bank/` - Cross-session context
- `rules/` - Cascade rules

## Getting Started
See: QUICK_START.md

## Commands
See: COMMAND_REFERENCE.md

## This directory is NOT committed
All contents are local to your workspace.
```

## Files to Create
- `.windsurf/INSTALL.md`
- `.windsurf/QUICK_START.md`
- `.windsurf/COMMAND_REFERENCE.md`
- `.windsurf/MIGRATION_FROM_CLAUDE.md`
- `.windsurf/TROUBLESHOOTING.md`
- `.windsurf/README.md`

## Files to Modify
None.

## Patterns to Follow
Reference: Good documentation practices

## Acceptance Criteria
- [ ] Installation guide complete
- [ ] Quick start guide complete
- [ ] Command reference for all 8 commands
- [ ] Migration guide from Claude Code
- [ ] Troubleshooting covers common issues
- [ ] README provides overview
- [ ] Documentation is clear and actionable

## Testing Requirements

### Unit Tests
**N/A** - Documentation only.

### Manual Verification
- [ ] Installation steps work in fresh repo
- [ ] Quick start produces expected results
- [ ] Command reference is accurate
- [ ] Migration steps work
- [ ] Troubleshooting covers real issues

## Verification Commands
```bash
# Verify all docs exist
ls -la .windsurf/*.md

# Check word count (should be substantial)
wc -w .windsurf/*.md

# Verify no broken internal links
grep -r "See:" .windsurf/*.md
```

## Documentation Updates
This step IS the documentation. No additional updates needed.

## Error Recovery
If verification fails:
1. Check file creation
2. Review content for accuracy
3. Test instructions manually
4. Update based on testing results

## Do NOT
- Use project-specific examples (must be generic)
- Skip any required document
- Leave placeholders in final docs
- Make documentation overly complex
