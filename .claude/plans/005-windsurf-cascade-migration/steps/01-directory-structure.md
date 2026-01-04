# Step 1: Directory Structure & Initialization

## Problem Type
`infrastructure`

## Technique Selection
- **Planning**: ps-plus - Structured planning for clear directory layout
- **Implementation**: least-to-most - Build directories from root to leaves
- **Verification**: self-refine - Iterate on structure if issues found

## Risk Level
**low** - Creating directories has no side effects; easily reversible

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Context
This is the foundation step. All subsequent steps depend on the `.windsurf/` directory structure existing. This step also ensures the repository's `.gitignore` excludes `.windsurf/**` to prevent accidental commits.

## Goal
Create the complete `.windsurf/` directory hierarchy with all subdirectories and ensure `.gitignore` excludes it.

## Prerequisites
- Git repository initialized
- Write access to repository root

## High-Level Steps
1. Create root `.windsurf/` directory
2. Create all subdirectories
3. Update `.gitignore` to exclude `.windsurf/**`
4. Create placeholder/template files where needed
5. Verify structure matches specification

## Detailed Requirements

### Directory Structure
```
.windsurf/
├── workflows/           # Workflow markdown files (8 main + helpers)
├── plans/               # Plan storage (mirrors .claude/plans/)
├── scripts/             # Python utilities
│   └── tests/           # Python unit tests
├── templates/           # Reusable template fragments
├── knowledge/           # Reference documentation
│   └── techniques/      # 10 technique guides
├── memory-bank/         # Cross-session context
├── rules/               # Cascade rules
└── PROJECT_CONTEXT.md   # Static project overview
```

### .gitignore Update
Add to repository `.gitignore`:
```
# Windsurf IDE (local planning system)
.windsurf/**
```

**Important**: This modification should remain as a local uncommitted change unless the user explicitly commits it.

## Files to Create
- `.windsurf/.gitkeep` (placeholder to ensure directory exists in some workflows)
- `.windsurf/workflows/.gitkeep`
- `.windsurf/plans/.gitkeep`
- `.windsurf/scripts/__init__.py` (empty, for Python imports)
- `.windsurf/scripts/tests/__init__.py`
- `.windsurf/templates/.gitkeep`
- `.windsurf/knowledge/.gitkeep`
- `.windsurf/knowledge/techniques/.gitkeep`
- `.windsurf/memory-bank/.gitkeep`
- `.windsurf/rules/.gitkeep`

## Files to Modify
- `.gitignore` - Add `.windsurf/**` exclusion

## Patterns to Follow
This is a new directory structure; no existing patterns to follow.

## Acceptance Criteria
- [ ] `.windsurf/` directory exists at repository root
- [ ] All 8 subdirectories exist: workflows, plans, scripts, scripts/tests, templates, knowledge, knowledge/techniques, memory-bank, rules
- [ ] `.gitignore` contains `.windsurf/**` entry
- [ ] Running `git status` shows `.gitignore` as modified (not staged)
- [ ] Running `ls -la .windsurf/` shows expected directories

## Testing Requirements

### Unit Tests
**N/A** - This step creates directories only, no logic to test.

### Manual Verification
- [ ] Directory tree matches specification
- [ ] `.gitignore` entry is correct and uncomitted
- [ ] No existing files were modified (except `.gitignore`)

## Verification Commands
```bash
# Verify directory structure
find .windsurf -type d | sort

# Verify .gitignore contains the exclusion
grep -F '.windsurf/**' .gitignore

# Verify .gitignore is modified but not staged
git status --porcelain .gitignore | grep '^ M'
```

## Documentation Updates
None required for this step.

## Error Recovery
If verification fails:
1. Check if `.windsurf/` already exists (may be partial)
2. Remove and recreate if structure is wrong: `rm -rf .windsurf && mkdir -p .windsurf/{workflows,plans,scripts/tests,templates,knowledge/techniques,memory-bank,rules}`
3. Check `.gitignore` syntax if grep fails

## Do NOT
- Commit the `.gitignore` change automatically
- Create any workflow or script files yet (those are later steps)
- Modify any existing project files (except `.gitignore`)
