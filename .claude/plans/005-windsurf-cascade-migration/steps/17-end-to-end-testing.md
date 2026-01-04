# Step 17: End-to-End Testing

## Problem Type
`integration-test`

## Technique Selection
- **Planning**: ps-plus - Structure test scenarios
- **Implementation**: tdd - Write tests before confirming features work
- **Verification**: reflexion - Learn from test failures

## Risk Level
**medium** - Testing may reveal issues requiring fixes

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
All workflows and scripts are created. Now we need comprehensive end-to-end testing in a fresh test repository to verify everything works together.

## Goal
Test all 8 workflows end-to-end in a fresh repository, documenting any issues found.

## Prerequisites
- Steps 1-16 completed (all components exist)
- Access to create a test repository

## High-Level Steps
1. Create fresh test repository
2. Copy Windsurf system to test repo
3. Test /plan-feature-initial
4. Test /plan-feature
5. Test /plan-prompts
6. Test /plan-next (multiple steps)
7. Test /plan-status
8. Test /plan-verify
9. Test /plan-rollback
10. Test /plan-feature-review
11. Test self-correction flow
12. Test commit staging
13. Document all issues
14. Fix critical issues

## Detailed Requirements

### Test Repository Setup
```bash
# Create test repo
mkdir /tmp/windsurf-test-repo
cd /tmp/windsurf-test-repo
git init

# Create minimal project structure
mkdir src tests
echo "print('hello')" > src/main.py
echo "def test_main(): assert True" > tests/test_main.py
echo "# Test Project" > README.md

# Copy Windsurf system
cp -r {original}/.windsurf .

# Initial commit
git add .
git commit -m "Initial test project"
```

### Test Scenario 1: Complete Plan Lifecycle

#### 1.1 /plan-feature-initial
```
Input: "Add a user authentication system with login and logout"
Expected:
- Problem classification output
- Tree of Thought analysis
- Clarifying questions
- Ready /plan-feature prompt
```

#### 1.2 /plan-feature
```
Input: {output from 1.1}
Expected:
- Plan directory created: .windsurf/plans/001-user-authentication/
- plan.md with Tree of Thought
- adr.md with decisions
- steps/ with step files
- progress.json with technique metadata
- context.md initialized
- .gitignore updated
```

#### 1.3 /plan-prompts
```
Input: /plan-prompts 001
Expected:
- Prompt files in prompts/
- Each prompt has technique embedded
- progress.json updated (promptGenerated=true)
```

#### 1.4 /plan-next (Step 1)
```
Input: /plan-next 001
Expected:
- Step 1 executes
- Planning phase output
- Implementation phase with file tracking
- Verification phase with test enforcement
- Commit prompt appears
- progress.json updated
- context.md updated
```

#### 1.5 /plan-status
```
Input: /plan-status 001
Expected:
- Detailed status display
- Progress bar
- Step table with status
- Current step info
```

### Test Scenario 2: Verification and Rollback

#### 2.1 Intentional Failure
Create a step that will fail verification (e.g., missing test).

#### 2.2 /plan-verify
```
Input: /plan-verify 001
Expected:
- Re-runs verification
- Shows PASS/FAIL per criterion
- Triggers self-correction on failure
```

#### 2.3 /plan-rollback
```
Input: /plan-rollback 001
Expected:
- Preview of changes to revert
- Confirmation prompt
- Files reverted correctly
- Step status reset to pending
- Memory bank option (preserve/reset)
```

### Test Scenario 3: Self-Correction

#### 3.1 Multiple Failures
Trigger multiple failures to test retry logic.

```
Expected:
- Memory bank entries created
- Retry attempts tracked
- Technique rotation after same-technique exhausted
- Escalation after total budget exhausted
```

### Test Scenario 4: Plan Review

#### 4.1 /plan-feature-review
```
Input: /plan-feature-review 001
Expected:
- 6-dimension analysis
- Scores for each dimension
- Recommendations generated
- Review log created in reviews/
- Plan artifacts updated if needed
- Prompt regen warning if techniques changed
```

### Test Scenario 5: Commit Staging

#### 5.1 Complete Step and Commit
```
Expected:
- Only step files staged
- .windsurf/** never staged
- User can provide custom message
- Commit succeeds
```

### Test Results Template
```markdown
## Test Results: {date}

### Environment
- OS: {os}
- Python: {version}
- Windsurf: {version}

### Scenario Results

| Scenario | Test | Status | Notes |
|----------|------|--------|-------|
| 1.1 | /plan-feature-initial | ✅/❌ | {notes} |
| 1.2 | /plan-feature | ✅/❌ | {notes} |
| ... | ... | ... | ... |

### Issues Found
1. **{Issue Title}**: {description}
   - Severity: {critical/major/minor}
   - Affected: {workflow/script}
   - Fix: {proposed fix}

### Fixes Applied
1. {description of fix}
```

## Files to Create
- `.windsurf/scripts/tests/test_e2e.py` (automated portions)
- Test results document (in plan reviews/)

## Files to Modify
- Any files with issues found during testing

## Patterns to Follow
Reference: Standard E2E testing practices

## Acceptance Criteria
- [ ] Test repository created and set up
- [ ] All 8 workflows tested
- [ ] All test scenarios executed
- [ ] Self-correction flow verified
- [ ] Commit staging verified (.windsurf excluded)
- [ ] Issues documented
- [ ] Critical issues fixed
- [ ] Test results recorded

## Testing Requirements

### E2E Test Script
```python
#!/usr/bin/env python3
"""End-to-end test automation for Windsurf planning system."""

import subprocess
import json
import os
from pathlib import Path

def test_directory_structure():
    """Verify .windsurf/ structure exists."""
    required = [
        '.windsurf/workflows',
        '.windsurf/plans',
        '.windsurf/scripts',
        '.windsurf/templates',
        '.windsurf/knowledge/techniques',
        '.windsurf/memory-bank'
    ]
    for d in required:
        assert Path(d).exists(), f"Missing: {d}"

def test_python_scripts():
    """Verify Python scripts execute without error."""
    scripts = [
        'python3 .windsurf/scripts/windsurf_plan.py --help',
        'python3 .windsurf/scripts/windsurf_plan.py classify "test"',
        'python3 .windsurf/scripts/windsurf_plan.py techniques debug'
    ]
    for cmd in scripts:
        result = subprocess.run(cmd, shell=True, capture_output=True)
        assert result.returncode == 0, f"Failed: {cmd}"

def test_gitignore_excludes_windsurf():
    """Verify .gitignore contains .windsurf/**."""
    with open('.gitignore') as f:
        content = f.read()
    assert '.windsurf' in content, ".windsurf not in .gitignore"
```

### Manual Testing Checklist
- [ ] Cascade loads workflows correctly
- [ ] /plan-feature-initial produces expected output
- [ ] /plan-feature creates all artifacts
- [ ] /plan-prompts generates technique-embedded prompts
- [ ] /plan-next executes with phases visible
- [ ] /plan-status shows accurate progress
- [ ] /plan-verify reports PASS/FAIL correctly
- [ ] /plan-rollback reverts changes safely
- [ ] /plan-feature-review uses ToT/GoT analysis
- [ ] Commits never include .windsurf/**

## Verification Commands
```bash
# Run automated tests
cd .windsurf/scripts && python3 -m pytest tests/test_e2e.py -v

# Verify workflows are loadable (manual in Windsurf)
# Type /plan-status in Cascade chat

# Check for .windsurf in recent commits (should be none)
git log --name-only --oneline -5 | grep ".windsurf" | wc -l  # Should be 0
```

## Documentation Updates
- Record test results in plan's reviews/ directory

## Error Recovery
If verification fails:
1. Document the specific failure
2. Identify root cause
3. Fix the issue
4. Re-run affected test
5. Update test results

## Do NOT
- Skip any workflow test
- Ignore failing tests
- Commit .windsurf/** during testing
- Leave critical issues unfixed
