---
name: _internal-commit
description: Stage step files and commit safely
---

# Internal: Commit Step Changes

Safely stages only step-related files (never .windsurf/**) and commits.

## Input

From calling workflow:
- **files**: Step file tracking object
  - created: [file paths]
  - modified: [file paths]
  - deleted: [file paths]
  - renamed: [{from, to}]
- **message**: Commit message (user-provided or suggested)
- **step**: Step number for reference

## Safeguards

**CRITICAL**: These rules are absolute:
1. NEVER stage `.windsurf/**` files
2. NEVER stage `.git/**` files
3. ALWAYS show preview before commit
4. ALWAYS allow cancel

## Steps

### 1. Collect Files

```bash
# Gather all files to stage
files_to_stage=()
for f in {files.created}; do files_to_stage+=("$f"); done
for f in {files.modified}; do files_to_stage+=("$f"); done
```

### 2. Validate Paths

```bash
for file in "${files_to_stage[@]}"; do
  # Check for forbidden paths
  if [[ "$file" == .windsurf/* ]]; then
    echo "ERROR: Cannot stage .windsurf files: $file"
    exit 1
  fi
  if [[ "$file" == .git/* ]]; then
    echo "ERROR: Cannot stage .git files: $file"
    exit 1
  fi
done
```

### 3. Verify Files Exist

```bash
missing=()
for file in {files.created} {files.modified}; do
  if [ ! -f "$file" ]; then
    missing+=("$file")
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "WARNING: Files not found:"
  printf '  - %s\n' "${missing[@]}"
fi
```

### 4. Stage Files

```bash
# Stage created and modified files
for file in "${files_to_stage[@]}"; do
  [ -f "$file" ] && git add "$file"
done

# Handle deletions
for file in {files.deleted}; do
  git rm "$file" 2>/dev/null || true
done

# Handle renames
for rename in {files.renamed}; do
  # Format: "old_path:new_path"
  old="${rename%%:*}"
  new="${rename##*:}"
  git mv "$old" "$new" 2>/dev/null || true
done
```

### 5. Safety Check

```bash
# Verify no .windsurf files staged
staged=$(git diff --cached --name-only)
if echo "$staged" | grep -q "^\.windsurf/"; then
  echo "ERROR: .windsurf files were staged, aborting"
  git reset HEAD
  exit 1
fi
```

### 6. Show Preview

```
═══════════════════════════════════════
  COMMIT PREVIEW: Step {N}
═══════════════════════════════════════

## Message
{message}

## Files to Commit
{git diff --cached --name-only, formatted as list}

## Changes Summary
{git diff --cached --stat}

## Excluded (not staged)
- .windsurf/** (planning files)

Proceed? (yes / no)
═══════════════════════════════════════
```

### 7. Execute Commit

If confirmed:

```bash
git commit -m "{message}"
commit_hash=$(git rev-parse --short HEAD)
```

### 8. Report Result

```
═══════════════════════════════════════
  ✅ COMMIT COMPLETE
═══════════════════════════════════════

Hash: {commit_hash}
Message: {message}
Files: {count}

{git diff --stat HEAD~1}

Step {N} changes are now committed.
═══════════════════════════════════════
```

## Output

Return structured result:

```json
{
  "committed": true,
  "hash": "abc1234",
  "files": 5,
  "message": "feat: ..."
}
```

Or if cancelled:

```json
{
  "committed": false,
  "reason": "user_cancelled"
}
```

## Error Handling

### No Files to Stage
```
ℹ️ No files to commit for this step.
Step may have only modified .windsurf/ files.
```

### Staging Fails
```bash
if ! git add "$file"; then
  echo "WARNING: Failed to stage: $file"
  echo "Continuing with other files..."
fi
```

### Commit Fails
```bash
if ! git commit -m "{message}"; then
  echo "ERROR: Commit failed"
  echo "Check: git status"
  exit 1
fi
```

### Pre-commit Hook Fails
```
═══════════════════════════════════════
  ⚠️ PRE-COMMIT HOOK FAILED
═══════════════════════════════════════

The pre-commit hook rejected the commit.

Review the errors above and:
1. Fix the issues
2. Run `/plan-next {NNN}` to retry
═══════════════════════════════════════
```

## Do NOT

- Do NOT stage .windsurf/** ever
- Do NOT stage .git/** ever
- Do NOT commit without preview
- Do NOT commit without user confirmation
- Do NOT modify commit hooks
- Do NOT use --no-verify
