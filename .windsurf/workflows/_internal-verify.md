---
name: _internal-verify
description: Execute verification commands with reporting
---

# Internal: Run Verification

Executes verification commands from step prompts and reports results.

## Input

From calling workflow:
- **step**: Step object from progress.json
- **prompt**: Step prompt content
- **technique**: Verification technique assigned

## Steps

### 1. Extract Acceptance Criteria

Parse the step prompt for AC items:

```bash
grep -E '^\- \[ \]' {prompt_file}
```

Format: `- [ ] **ACN**: Description`

### 2. Extract Verification Commands

Find bash commands in `## Verification` section:

```bash
sed -n '/^## Verification/,/^## /p' {prompt_file} | grep -A 1 "^\`\`\`bash"
```

### 3. Execute Each Command

```bash
for cmd in {commands}; do
  output=$($cmd 2>&1)
  exit_code=$?

  if [ $exit_code -eq 0 ]; then
    status="PASS"
    icon="✅"
  else
    status="FAIL"
    icon="❌"
  fi

  results+=("$icon $cmd → $status")
done
```

### 4. Technique-Specific Checks

#### TDD
```bash
# Run test suite for step files
test_output=$(python3 -m pytest {test_files} 2>&1)
test_count=$(echo "$test_output" | grep -oE '[0-9]+ passed')
```

Report:
```
Tests: {passed}/{total}
Coverage: {%} (if available)
```

#### Reflexion
```bash
# Check memory bank for lessons
python3 .windsurf/scripts/windsurf_plan.py memory context \
  --plan {NNN} --step {N}
```

Report:
```
Memory Bank: {N} lessons available
Applied: {yes/no for each}
```

#### Self-Consistency
```bash
# Run verification 3 times
for i in 1 2 3; do
  results_$i=$({verify_command} 2>&1)
done
# Compare outputs
```

Report:
```
Runs: 3
Agreement: {2/3 or 3/3}
```

#### Self-Refine
Compare current to previous attempt quality:
```
Iteration: {N}
Improvement: {yes/no}
Quality: {score if measurable}
```

#### GoT
Aggregate from multiple verification paths:
```
Paths verified: {N}
Conflicts: {none/list}
Consensus: {result}
```

### 5. Generate Report

```markdown
═══════════════════════════════════════
  VERIFICATION: Step {N}
═══════════════════════════════════════

## Commands
| Command | Status |
|---------|--------|
| {cmd} | ✅/❌ |

## Acceptance Criteria
| # | Criterion | Status |
|---|-----------|--------|
| 1 | {description} | ✅/❌ |

## Technique: {name}
{technique-specific results}

## Summary
- Passed: {N}/{total}
- Failed: {N}/{total}
- **Overall**: {PASS/FAIL}
═══════════════════════════════════════
```

## Output

Return structured result:

```json
{
  "overall": "PASS|FAIL",
  "passed": 5,
  "failed": 1,
  "total": 6,
  "failures": [
    {
      "criterion": "AC2",
      "error": "Expected X, got Y",
      "command": "grep ..."
    }
  ],
  "technique": {
    "name": "tdd",
    "testsRun": 10,
    "testsPassed": 9
  }
}
```

## Error Handling

### Command Times Out
```bash
timeout 30 {command} || echo "TIMEOUT"
```

### Command Not Found
```
⚠️ Command not found: {cmd}
Skipping verification item.
```

### Parse Error
If AC cannot be parsed:
```
⚠️ Could not parse acceptance criteria.
Manual verification required.
```

## Do NOT

- Do NOT modify any files
- Do NOT skip technique-specific checks
- Do NOT suppress error output
- Do NOT mark PASS if any command fails
