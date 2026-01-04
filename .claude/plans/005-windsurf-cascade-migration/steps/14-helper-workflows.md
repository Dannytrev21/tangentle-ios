# Step 14: Internal Helper Workflows

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Identify shared logic patterns
- **Implementation**: tdd - Test helper accuracy
- **Verification**: reflexion - Learn from integration issues

## Risk Level
**high** - Helpers used by multiple workflows; bugs affect everything

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 3 attempts
- Escalation: After 5 total failures

## Context
Helper workflows contain shared logic extracted from main workflows to stay under 12K character limits and enable reuse. They're prefixed with `_` to indicate internal use.

## Goal
Create internal helper workflows for shared operations: initialization, verification, and commit staging.

## Prerequisites
- Steps 6-13 completed (main workflows exist)
- Identify common patterns across workflows

## High-Level Steps
1. Identify shared logic patterns
2. Create _internal-init.md for initialization
3. Create _internal-verify.md for verification
4. Create _internal-commit.md for commit staging
5. Update main workflows to call helpers
6. Test helper invocation

## Detailed Requirements

### Helper: _internal-init.md

Handles first-run initialization:

```markdown
---
name: _internal-init
description: Initialize .windsurf/ structure
---

# Internal: Initialize Windsurf Structure

This helper creates the complete .windsurf/ directory structure.

## Steps

1. **Create directory structure**
   \`\`\`bash
   mkdir -p .windsurf/{workflows,plans,scripts/tests,templates,knowledge/techniques,memory-bank,rules}
   \`\`\`

2. **Create placeholder files**
   \`\`\`bash
   touch .windsurf/scripts/__init__.py
   touch .windsurf/scripts/tests/__init__.py
   \`\`\`

3. **Update .gitignore**
   If `.gitignore` does not contain `.windsurf/**`:
   - Append `# Windsurf IDE\n.windsurf/**` to `.gitignore`
   - Leave as local modification

4. **Create PROJECT_CONTEXT.md template**
   \`\`\`bash
   cat > .windsurf/PROJECT_CONTEXT.md << 'EOF'
   # Project Context

   ## Overview
   {Brief project description}

   ## Tech Stack
   {Languages, frameworks, tools}

   ## Architecture
   {High-level architecture}

   ## Key Patterns
   {Important patterns used}

   ## Conventions
   {Coding conventions}
   EOF
   \`\`\`

5. **Initialize memory-bank**
   \`\`\`bash
   cat > .windsurf/memory-bank/productContext.md << 'EOF'
   # Product Context

   ## Purpose
   {What the product does}

   ## Users
   {Who uses it}

   ## Goals
   {Product goals}
   EOF
   \`\`\`

## Output
- Confirmation of directories created
- List of initialized files
- .gitignore update status
```

### Helper: _internal-verify.md

Handles verification execution:

```markdown
---
name: _internal-verify
description: Run verification commands with reporting
---

# Internal: Run Verification

This helper executes verification commands and reports results.

## Input
- List of verification commands
- List of acceptance criteria
- Technique (for technique-specific checks)

## Steps

1. **Execute commands**
   For each command:
   - Run command
   - Capture exit code and output
   - Record PASS/FAIL

2. **Check acceptance criteria**
   For each criterion:
   - Evaluate if met
   - Record status

3. **Apply technique-specific checks**
   If technique metadata exists:
   - TDD: Check test coverage
   - Reflexion: Check lesson application
   - Self-Consistency: Multiple runs comparison

4. **Generate report**
   \`\`\`markdown
   ## Verification Results

   ### Commands
   | Command | Status | Output |
   |---------|--------|--------|
   | ... | ✅/❌ | ... |

   ### Criteria
   | Criterion | Status |
   |-----------|--------|
   | ... | ✅/❌ |

   ### Overall: {PASS/FAIL}
   \`\`\`

## Output
- Verification report
- Overall status (PASS/FAIL)
- Failed items list
```

### Helper: _internal-commit.md

Handles selective commit staging:

```markdown
---
name: _internal-commit
description: Stage and commit step files
---

# Internal: Commit Step Changes

This helper stages only step-related files and commits.

## Input
- Step file tracking (created, modified, deleted, renamed)
- Commit message (user-provided or suggested)

## Steps

1. **Validate files**
   - Ensure no `.windsurf/**` files in list
   - Ensure files exist (for created/modified)

2. **Stage files**
   \`\`\`bash
   # Stage created and modified
   git add {created files} {modified files}

   # Handle deletions
   git rm {deleted files}

   # Handle renames
   git mv {from} {to}  # if not already done
   \`\`\`

3. **Verify staging**
   \`\`\`bash
   git status --porcelain
   # Ensure only step files staged
   # Ensure no .windsurf/** files staged
   \`\`\`

4. **Commit**
   \`\`\`bash
   git commit -m "{message}"
   \`\`\`

5. **Report result**
   \`\`\`markdown
   ## Commit Complete

   **Message**: {message}
   **Files**: {count} files changed

   ### Staged Files
   - {file list}

   **Commit hash**: {short hash}
   \`\`\`

## Safeguards
- Never stage `.windsurf/**`
- Validate all file paths before staging
- Show preview before commit
- Allow cancel

## Output
- Commit confirmation
- Commit hash
- Files committed list
```

### Main Workflow Updates
Update these workflows to call helpers:
- `/plan-feature` → calls `_internal-init`
- `/plan-next` → calls `_internal-verify`, `_internal-commit`
- `/plan-verify` → calls `_internal-verify`
- `/plan-rollback` → may call `_internal-commit` (for rollback commit)

## Files to Create
- `.windsurf/workflows/_internal-init.md`
- `.windsurf/workflows/_internal-verify.md`
- `.windsurf/workflows/_internal-commit.md`

## Files to Modify
- `.windsurf/workflows/plan-feature.md` (add init call)
- `.windsurf/workflows/plan-next.md` (add verify/commit calls)
- `.windsurf/workflows/plan-verify.md` (add verify call)

## Patterns to Follow
Reference: Windsurf workflow nesting documentation

## Acceptance Criteria
- [ ] All 3 helper workflows created
- [ ] Each helper under 12,000 characters
- [ ] `_internal-init` creates all directories
- [ ] `_internal-init` updates .gitignore
- [ ] `_internal-verify` runs commands with PASS/FAIL
- [ ] `_internal-verify` applies technique-specific checks
- [ ] `_internal-commit` never stages .windsurf/**
- [ ] Main workflows successfully call helpers
- [ ] Helpers reusable across multiple workflows

## Testing Requirements

### Unit Tests
**N/A** - Workflows tested via execution.

### Integration Tests
- [ ] Run `_internal-init` in fresh repo
- [ ] Verify directories created
- [ ] Verify .gitignore updated
- [ ] Run `_internal-verify` with test commands
- [ ] Verify PASS/FAIL reporting
- [ ] Run `_internal-commit` with file list
- [ ] Verify only specified files staged
- [ ] Test main workflow → helper invocation

### Manual Verification
- [ ] Helpers are called correctly from main workflows
- [ ] No .windsurf/** files ever staged
- [ ] Reports are clear and accurate

## Verification Commands
```bash
# Check helper files exist
ls -la .windsurf/workflows/_internal-*.md

# Check character counts
wc -c .windsurf/workflows/_internal-*.md

# After running init, verify structure
find .windsurf -type d | sort

# After running commit, verify no .windsurf staged
git status --porcelain | grep ".windsurf" | wc -l  # Should be 0
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check workflow nesting syntax
2. Verify file paths in helpers
3. Test helpers independently
4. Check git command syntax

## Do NOT
- Make helpers user-invocable (prefix with _)
- Include complex business logic (just shared operations)
- Stage .windsurf/** files ever
- Skip validation steps
