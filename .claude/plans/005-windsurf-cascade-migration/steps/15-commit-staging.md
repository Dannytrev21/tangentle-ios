# Step 15: Commit Staging System

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Structure file tracking logic
- **Implementation**: tdd - Test staging accuracy
- **Verification**: reflexion - Learn from staging errors

## Risk Level
**high** - Incorrect staging could commit wrong files or expose .windsurf/

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 3 attempts
- Escalation: After 5 total failures

## Context
The commit staging system uses per-step file tracking to stage exactly the right files for commits. This ensures `.windsurf/**` is never staged and only step-related files are included.

## Goal
Implement the complete file tracking and commit staging system with safeguards.

## Prerequisites
- Step 9 completed (plan-next tracks files)
- Step 14 completed (_internal-commit helper)

## High-Level Steps
1. Implement file operation detection during step execution
2. Store file operations in progress.json per step
3. Implement staging logic with exclusion safeguards
4. Add user-provided commit message with suggestions
5. Test end-to-end file tracking and staging

## Detailed Requirements

### File Operation Detection
During step execution, detect:

```python
class FileTracker:
    def __init__(self, plan_path: str, step_id: int):
        self.plan_path = plan_path
        self.step_id = step_id
        self.initial_state = self._snapshot()

    def _snapshot(self) -> dict:
        """Capture current file state (paths, mtimes, hashes)"""
        pass

    def detect_changes(self) -> dict:
        """Compare current state to initial, return operations"""
        current = self._snapshot()
        return {
            "created": [f for f in current if f not in self.initial_state],
            "modified": [f for f in current if f in self.initial_state
                        and current[f]['hash'] != self.initial_state[f]['hash']],
            "deleted": [f for f in self.initial_state if f not in current],
            "renamed": self._detect_renames()
        }
```

### Progress.json Schema
Per-step file tracking:
```json
{
  "steps": [{
    "id": 1,
    "files": {
      "created": ["src/new_service.py", "tests/test_new_service.py"],
      "modified": ["src/existing.py"],
      "deleted": [],
      "renamed": [{"from": "old_name.py", "to": "new_name.py"}]
    }
  }]
}
```

### Staging Safeguards

#### Exclusion List
Never stage:
- `.windsurf/**` (planning system)
- `.git/**` (git internals)
- `*.pyc`, `__pycache__/` (Python bytecode)
- `.env`, `*.secret` (secrets)

#### Validation
```python
def validate_files(files: list) -> tuple[list, list]:
    """Return (allowed, rejected) file lists"""
    excluded_patterns = [
        r'^\.windsurf/',
        r'^\.git/',
        r'__pycache__',
        r'\.pyc$',
        r'\.env$',
        r'\.secret$'
    ]
    allowed = []
    rejected = []
    for f in files:
        if any(re.match(p, f) for p in excluded_patterns):
            rejected.append(f)
        else:
            allowed.append(f)
    return allowed, rejected
```

### Commit Message Format
User-provided with suggestions:

```markdown
## Ready to Commit

### Files to Stage
**Created**:
- src/new_service.py
- tests/test_new_service.py

**Modified**:
- src/existing.py

**Deleted**: (none)
**Renamed**: (none)

### Suggested Message
`feat(step-03): Add new service layer`

### Enter commit message:
(or press Enter to use suggested)
```

### Commit Execution
```bash
# Stage files
git add src/new_service.py tests/test_new_service.py src/existing.py

# Verify no excluded files staged
git diff --cached --name-only | grep -E '^\.windsurf/' && exit 1

# Commit with message
git commit -m "{user_message}"

# Report result
git log -1 --oneline
```

### Python Script: file_tracker.py
Add to `.windsurf/scripts/`:

```python
#!/usr/bin/env python3
"""File tracking for commit staging."""

import os
import hashlib
import json
import re
from pathlib import Path

class FileTracker:
    EXCLUDED_PATTERNS = [
        r'^\.windsurf/',
        r'^\.git/',
        r'__pycache__',
        r'\.pyc$',
        r'\.env$',
        r'\.secret$'
    ]

    def __init__(self, repo_root: str):
        self.repo_root = Path(repo_root)

    def validate_files(self, files: list) -> tuple:
        allowed, rejected = [], []
        for f in files:
            if any(re.match(p, f) for p in self.EXCLUDED_PATTERNS):
                rejected.append(f)
            else:
                allowed.append(f)
        return allowed, rejected

    def get_staging_commands(self, files: dict) -> list:
        commands = []
        allowed_created, _ = self.validate_files(files.get('created', []))
        allowed_modified, _ = self.validate_files(files.get('modified', []))

        if allowed_created or allowed_modified:
            commands.append(f"git add {' '.join(allowed_created + allowed_modified)}")

        for f in files.get('deleted', []):
            allowed, _ = self.validate_files([f])
            if allowed:
                commands.append(f"git rm {f}")

        for r in files.get('renamed', []):
            # Renames handled by git mv during step
            pass

        return commands
```

## Files to Create
- `.windsurf/scripts/file_tracker.py`
- `.windsurf/scripts/tests/test_file_tracker.py`

## Files to Modify
- `.windsurf/scripts/windsurf_plan.py` (add `stage` and `commit` commands)
- `.windsurf/workflows/_internal-commit.md` (use file_tracker)

## Patterns to Follow
Reference: Git staging best practices
Reference: Existing progress.json schema

## Acceptance Criteria
- [ ] file_tracker.py created with validation logic
- [ ] Exclusion patterns prevent .windsurf/** staging
- [ ] Progress.json stores per-step file operations
- [ ] Commit staging uses validated file list
- [ ] User can provide custom commit message
- [ ] Suggested message follows convention
- [ ] Unit tests pass for file_tracker

## Testing Requirements

### Unit Tests
- [ ] Test file: `.windsurf/scripts/tests/test_file_tracker.py`
  - `test_validate_excludes_windsurf()` - .windsurf/** rejected
  - `test_validate_excludes_git()` - .git/** rejected
  - `test_validate_allows_source()` - src/** allowed
  - `test_validate_allows_tests()` - tests/** allowed
  - `test_staging_commands_correct()` - git add command correct
  - `test_deleted_uses_git_rm()` - deleted files use git rm

### Integration Tests
- [ ] Create step that modifies files
- [ ] Run step execution
- [ ] Verify files tracked in progress.json
- [ ] Run commit staging
- [ ] Verify only allowed files staged
- [ ] Verify .windsurf/** not staged

### Manual Verification
- [ ] Commit message prompt appears
- [ ] Suggested message is reasonable
- [ ] Exclusion list comprehensive

## Verification Commands
```bash
# Run unit tests
cd .windsurf/scripts && python3 -m unittest tests/test_file_tracker.py -v

# Test validation
python3 -c "
from file_tracker import FileTracker
ft = FileTracker('.')
allowed, rejected = ft.validate_files(['.windsurf/plans/001/x.md', 'src/main.py'])
print(f'Allowed: {allowed}')
print(f'Rejected: {rejected}')
"

# After staging, verify no .windsurf files
git diff --cached --name-only | grep ".windsurf" | wc -l  # Should be 0
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check exclusion patterns are correct
2. Verify file paths are relative to repo root
3. Check git commands for syntax errors
4. Validate progress.json file tracking data

## Do NOT
- Stage .windsurf/** under any circumstances
- Commit without user confirmation
- Skip file validation
- Use absolute paths in git commands
