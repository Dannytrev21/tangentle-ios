# Troubleshooting

Solutions for common issues with the Windsurf planning system.

## Installation Issues

### Workflow not found

**Symptom**: Cascade doesn't recognize `/plan-*` commands.

**Solution**:
1. Check workflow files exist:
   ```bash
   ls .windsurf/workflows/*.md
   ```
2. Verify file has YAML frontmatter:
   ```bash
   head -5 .windsurf/workflows/plan-next.md
   # Should show --- and name/description fields
   ```
3. Restart Windsurf IDE

---

### Python script error

**Symptom**: Command output shows Python error or traceback.

**Solution**:
1. Check Python version:
   ```bash
   python3 --version
   # Needs 3.8+
   ```
2. Check script paths:
   ```bash
   ls .windsurf/scripts/*.py
   ```
3. Run script directly to see full error:
   ```bash
   python3 .windsurf/scripts/windsurf_plan.py --help
   ```
4. Check `__init__.py` exists:
   ```bash
   ls .windsurf/scripts/__init__.py
   ls .windsurf/scripts/tests/__init__.py
   ```

---

### Module not found

**Symptom**: `ModuleNotFoundError` when running scripts.

**Solution**:
The system uses only Python standard library. If you see import errors:

```bash
# Ensure __init__.py files exist
touch .windsurf/scripts/__init__.py
touch .windsurf/scripts/tests/__init__.py

# Check you're running from project root
pwd  # Should show your project directory
python3 .windsurf/scripts/windsurf_plan.py --help
```

---

## Git Issues

### .windsurf files in git status

**Symptom**: `.windsurf/**` files appear as untracked or staged.

**Solution**:
```bash
# Check .gitignore entry
grep windsurf .gitignore

# Add if missing
echo ".windsurf/**" >> .gitignore

# Unstage if already staged
git reset .windsurf/

# Verify exclusion
git status | grep windsurf  # Should show nothing
```

---

### Files accidentally committed

**Symptom**: .windsurf files were committed.

**Solution**:
```bash
# Remove from git tracking (keeps local files)
git rm -r --cached .windsurf/

# Add to .gitignore
echo ".windsurf/**" >> .gitignore

# Commit the removal
git commit -m "Remove .windsurf from tracking"
```

---

## Plan Issues

### Plan not found

**Symptom**: `/plan-next` says no plans exist.

**Solution**:
1. Check plans directory:
   ```bash
   ls .windsurf/plans/
   ```
2. Verify plan has progress.json:
   ```bash
   ls .windsurf/plans/*/progress.json
   ```
3. Create a new plan:
   ```
   /plan-feature Add feature description
   ```

---

### Prompts not generated

**Symptom**: `/plan-next` says prompts missing.

**Solution**:
```bash
# Check prompts directory
ls .windsurf/plans/001-*/prompts/

# Generate prompts
/plan-prompts 001
```

---

### Step stuck in progress

**Symptom**: Step shows as `in_progress` but work was lost.

**Solution**:
1. Rollback the step:
   ```
   /plan-rollback 001
   ```
2. Or manually reset in progress.json:
   ```bash
   # Edit .windsurf/plans/001-*/progress.json
   # Change step status from "in_progress" to "pending"
   ```

---

## Self-Correction Issues

### Retries not working

**Symptom**: Step fails without retry attempts.

**Solution**:
1. Check progress.json has retryConfig:
   ```bash
   cat .windsurf/plans/001-*/progress.json | grep -A4 retryConfig
   ```
2. Verify risk level is set:
   ```bash
   cat .windsurf/plans/001-*/progress.json | grep riskLevel
   ```
3. Check retry budget not exhausted:
   ```bash
   cat .windsurf/plans/001-*/progress.json | grep attempts
   ```

---

### Memory bank not saving lessons

**Symptom**: Failures don't persist to memory bank.

**Solution**:
1. Check memory bank file exists:
   ```bash
   ls .windsurf/plans/001-*/memory-bank.json
   ```
2. Add lesson manually via CLI:
   ```bash
   python3 .windsurf/scripts/windsurf_plan.py memory add \
     --step 1 \
     --failure-type "test-failure" \
     --context "Test failed due to X" \
     --lesson "Check Y before Z"
   ```

---

## Verification Issues

### All checks failing unexpectedly

**Symptom**: Verification fails but code seems correct.

**Solution**:
1. Check acceptance criteria in step prompt:
   ```bash
   cat .windsurf/plans/001-*/prompts/01-*.prompt.md | grep -A20 "Acceptance Criteria"
   ```
2. Run verification commands manually:
   ```bash
   # Copy commands from prompt and run them
   ```
3. Re-run verification:
   ```
   /plan-verify 001
   ```

---

### Tests not running

**Symptom**: Step requires tests but none are executed.

**Solution**:
1. Check Testing Requirements in step prompt:
   ```bash
   cat .windsurf/plans/001-*/prompts/01-*.prompt.md | grep -A10 "Testing Requirements"
   ```
2. Ensure test file exists and is valid:
   ```bash
   ls *Tests*.swift  # or your language's test files
   ```
3. Run tests manually to check for errors:
   ```bash
   # Your project's test command
   swift test
   # or
   python3 -m pytest
   ```

---

## Performance Issues

### Commands slow to respond

**Symptom**: `/plan-*` commands take a long time.

**Solution**:
1. Check plan size:
   ```bash
   du -sh .windsurf/plans/
   ```
2. Clean old plans if needed:
   ```bash
   # Archive completed plans
   mv .windsurf/plans/001-* ~/windsurf-archive/
   ```
3. Check memory bank size:
   ```bash
   wc -l .windsurf/plans/*/memory-bank.json
   # Should be < 10 entries per plan (FIFO limit)
   ```

---

## Context Issues

### Context not persisting

**Symptom**: Cascade forgets previous context between sessions.

**Solution**:
1. Check context.md is being updated:
   ```bash
   tail -20 .windsurf/plans/001-*/context.md
   ```
2. Check PROJECT_CONTEXT.md exists:
   ```bash
   ls .windsurf/PROJECT_CONTEXT.md
   ```
3. Use `/plan-status` to see current context:
   ```
   /plan-status 001
   ```

---

## Getting Help

### Debug Mode

Run CLI with verbose output:
```bash
python3 .windsurf/scripts/windsurf_plan.py --help
python3 .windsurf/scripts/windsurf_plan.py list
```

### Check Logs

Review context.md for history:
```bash
cat .windsurf/plans/001-*/context.md
```

### Verify System

Run tests:
```bash
python3 -m unittest discover -s .windsurf/scripts/tests -p 'test_*.py'
```

### Reset to Clean State

If everything is broken:
```bash
# Backup plans
cp -r .windsurf/plans ~/windsurf-plans-backup

# Remove and reinstall
rm -rf .windsurf
# Then follow INSTALL.md

# Restore plans
cp -r ~/windsurf-plans-backup/* .windsurf/plans/
```

---

Still stuck? Check:
- [INSTALL.md](INSTALL.md) - Installation steps
- [COMMAND_REFERENCE.md](COMMAND_REFERENCE.md) - Command details
