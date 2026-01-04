---
name: plan-status
description: Display plan progress with visual indicators and context summary
---

# Plan Status

Show plan progress in two modes: list all plans or detailed single plan view.

## Instructions

### Step 1: Parse Input

Check if plan number provided in `$ARGS`.

```bash
if [ -z "$ARGS" ]; then
  # List mode
else
  # Detail mode
  PLAN_DIR=$(ls -d .windsurf/plans/$ARGS* 2>/dev/null | head -1)
fi
```

### Step 2: List Mode (No Plan Number)

If no plan number, list all plans:

```bash
for dir in .windsurf/plans/[0-9]*; do
  [ -f "$dir/progress.json" ] && cat "$dir/progress.json"
done
```

Extract from each progress.json:
- `planId`, `name`, `status`
- `currentStep`, `totalSteps`
- `updatedAt`

Output:

```
═══════════════════════════════════════
  PLAN OVERVIEW
═══════════════════════════════════════

| # | Name | Status | Progress | Updated |
|---|------|--------|----------|---------|
| 001 | feature-name | in_progress | 5/12 (42%) | 2026-01-01 |
| 002 | other-plan | completed | 8/8 (100%) | 2025-12-28 |

### Quick Actions
- `/plan-status {N}` - View plan details
- `/plan-next {N}` - Continue implementation
- `/plan-feature` - Create new plan
═══════════════════════════════════════
```

### Step 3: Detail Mode (With Plan Number)

Read progress.json and context.md:

```bash
cat $PLAN_DIR/progress.json
cat $PLAN_DIR/context.md
```

#### 3a. Overview Section

```
═══════════════════════════════════════
  PLAN {NNN}: {Title}
═══════════════════════════════════════

## Overview
- **Status**: {status}
- **Created**: {createdAt}
- **Updated**: {updatedAt}
- **Type**: {problemType} ({problemCategory})
```

#### 3b. Progress Bar

Calculate visual progress:
```
completed = count steps where status = "completed"
total = totalSteps
percent = completed / total * 100
filled = round(percent / 100 * 24)
empty = 24 - filled
```

Display:
```
## Progress
████████████░░░░░░░░░░░░ 50% (6/12 steps)
```

Bar characters:
- `█` - completed (filled)
- `░` - pending (empty)
- Width: 24 characters

#### 3c. Steps Table

```
## Steps
| # | Name | Status | Technique | Tests | Time |
|---|------|--------|-----------|-------|------|
| 1 | step-name | ✅ completed | tdd | 8 | 45m |
| 2 | step-two | 🔄 in_progress | reflexion | - | 30m |
| 3 | step-three | ⏳ pending | tdd | - | - |
```

Status icons:
| Status | Icon |
|--------|------|
| completed | ✅ |
| in_progress | 🔄 |
| pending | ⏳ |
| blocked | ❌ |
| retrying | 🔁 |

Time calculation:
- If `completedAt` exists: `completedAt - startedAt`
- If `in_progress`: `now - startedAt`
- Format: `{N}m` or `{H}h {M}m`

Tests column:
- If `testsPassed`: count from `testsWritten`
- If no tests: `N/A` or `-`

#### 3d. Current Step Details

If a step is `in_progress`:

```
## Current Step: {N} - {Name}
- **Status**: in_progress
- **Technique**: {techniques.implementation}
- **Attempts**: {attempts}/{retryConfig.maxTotal} ({riskLevel})
- **Started**: {startedAt}
```

If step has self-correction attempts:
```
### Retry History
- Attempt 1: {technique} - {outcome}
- Attempt 2: {technique} - {outcome}
```

#### 3e. Context Summary

From progress.json `context`:

```
## Context Summary
- **Files Created**: {count filesCreated}
- **Files Modified**: {count filesModified}
- **Tests Created**: {count testsCreated}
- **Key Decisions**: {count keyDecisions}
```

#### 3f. Recent Learnings

From context.md or progress.json `learnings`:

```
## Recent Learnings
1. {learning 1}
2. {learning 2}
3. {learning 3}
```

Show last 3-5 learnings.

#### 3g. Blockers (if any)

From progress.json `blockers`:

```
## Blockers
- {blocker 1}
- {blocker 2}
```

#### 3h. Next Commands

Based on current state:

```
## Commands
- `/plan-next {NNN}` - Continue current step
- `/plan-verify {NNN}` - Re-run verification
- `/plan-rollback {NNN}` - Rollback last step
```

### Step 4: Error Handling

#### Plan Not Found
```
Plan not found: {ARGS}

Available plans:
{list from .windsurf/plans/}

Run `/plan-feature` to create a new plan.
```

#### No Plans Exist
```
No plans found.

Run `/plan-feature {description}` to create your first plan.
```

#### Corrupt Progress Data
```
Error reading plan data.

Try:
1. Check JSON: python3 -m json.tool $PLAN_DIR/progress.json
2. Restore from git: git checkout $PLAN_DIR/progress.json
```

## Output Examples

### List Mode Output

```
═══════════════════════════════════════
  PLAN OVERVIEW
═══════════════════════════════════════

| # | Name | Status | Progress | Updated |
|---|------|--------|----------|---------|
| 001 | ios-foundation | not_started | 0/12 (0%) | 2026-01-01 |
| 002 | fluid-ui | completed | 12/12 (100%) | 2025-12-28 |
| 005 | windsurf-migration | in_progress | 9/18 (50%) | 2026-01-02 |

### Quick Actions
- `/plan-status {N}` - View plan details
- `/plan-next {N}` - Continue implementation
- `/plan-feature` - Create new plan
═══════════════════════════════════════
```

### Detail Mode Output

```
═══════════════════════════════════════
  PLAN 005: Windsurf Cascade Migration
═══════════════════════════════════════

## Overview
- **Status**: in_progress
- **Created**: 2026-01-02
- **Updated**: 2026-01-02
- **Type**: migration (DATA)

## Progress
████████████░░░░░░░░░░░░ 50% (9/18 steps)

## Steps
| # | Name | Status | Technique | Tests | Time |
|---|------|--------|-----------|-------|------|
| 1 | directory-structure | ✅ completed | least-to-most | N/A | 15m |
| 2 | python-foundation | ✅ completed | least-to-most | 76 | 60m |
| 3 | templates-foundation | ✅ completed | chain-of-code | N/A | 30m |
| 4 | knowledge-techniques | ✅ completed | chain-of-code | N/A | 60m |
| 5 | self-correction | ✅ completed | chain-of-code | 55 | 60m |
| 6 | plan-feature-initial | ✅ completed | chain-of-code | N/A | 15m |
| 7 | plan-feature | ✅ completed | chain-of-code | N/A | 15m |
| 8 | plan-prompts | ✅ completed | tdd | N/A | 15m |
| 9 | plan-next | ✅ completed | tdd | N/A | 20m |
| 10 | plan-status | 🔄 in_progress | self-refine | - | - |
| 11 | plan-verify | ⏳ pending | tdd | - | - |
| ... | ... | ... | ... | ... | ... |

## Current Step: 10 - plan-status
- **Status**: in_progress
- **Technique**: self-refine
- **Attempts**: 1/7 (high)
- **Started**: 2026-01-02 22:00

## Context Summary
- **Files Created**: 44
- **Files Modified**: 2
- **Tests Created**: 131 total
- **Key Decisions**: 9

## Recent Learnings
1. Python 3.13 compatible with all scripts
2. CLI uses structured output for workflow parsing
3. JSON templates need unquoted placeholders

## Commands
- `/plan-next 005` - Continue current step
- `/plan-verify 005` - Re-run verification
- `/plan-rollback 005` - Rollback last step
═══════════════════════════════════════
```

## Do NOT

- Do NOT modify any files (read-only workflow)
- Do NOT hide blocked or failed states
- Do NOT omit retry information
- Do NOT show stale data (always read fresh)
- Do NOT exceed 12,000 character limit
