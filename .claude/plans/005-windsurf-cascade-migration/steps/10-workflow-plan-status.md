# Step 10: Workflow - /plan-status

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: ps-plus - Structure display logic
- **Implementation**: self-refine - Iterate on display formatting (no testable logic)
- **Verification**: reflexion - Improve display based on feedback

## Risk Level
**high** - Information display; must be accurate

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 3 attempts
- Escalation: After 5 total failures

## Context
`/plan-status` displays plan progress. Without a plan number, it lists all plans. With a plan number, it shows detailed status including progress bar, steps table, current step details, and context summary.

## Goal
Create the `/plan-status` workflow that provides comprehensive plan visibility.

## Prerequisites
- Step 7 completed (plans exist to display)

## High-Level Steps
1. Parse optional plan number from input
2. If no plan specified: list all plans
3. If plan specified: show detailed status
4. Format output for readability

## Detailed Requirements

### Mode 1: List All Plans
When no plan number provided:

```markdown
## All Plans

| # | Name | Status | Progress | Updated |
|---|------|--------|----------|---------|
| 001 | ios-foundation | not_started | 0/12 (0%) | 2025-12-20 |
| 002 | fluid-ui-gestures | completed | 12/12 (100%) | 2025-12-28 |
| 003 | testing-infrastructure | in_progress | 5/10 (50%) | 2026-01-01 |

### Quick Actions
- `/plan-status {N}` - View plan details
- `/plan-next {N}` - Continue implementation
- `/plan-feature {description}` - Create new plan
```

### Mode 2: Detailed Plan Status
When plan number provided:

```markdown
## Plan {NNN}: {Plan Title}

### Overview
- **Status**: {status}
- **Created**: {date}
- **Last Updated**: {date}
- **Problem Type**: {type} ({category})

### Progress
{visual progress bar}
{completed}/{total} steps ({percent}%)

### Steps
| # | Name | Status | Technique | Tests | Time |
|---|------|--------|-----------|-------|------|
| 1 | design-tokens | ✅ completed | tdd | 5 passed | 45m |
| 2 | theme-system | ✅ completed | self-refine | 3 passed | 30m |
| 3 | typography | 🔄 in_progress | tdd | - | 15m |
| 4 | animation | ⏳ pending | reflexion | - | - |

### Current Step: {N} - {Step Name}
**Status**: {status}
**Technique**: {technique}
**Attempts**: {attempts}/{max}
**Started**: {time}

{if blocked: show blocker info}

### Context Summary
**Files Created**: {count}
**Files Modified**: {count}
**Tests Created**: {count}
**Key Decisions**: {count}

### Recent Learnings
{last 3 learnings from context.md}

### Next Commands
- `/plan-next {NNN}` - Continue current step
- `/plan-verify {NNN}` - Re-run verification
- `/plan-rollback {NNN}` - Rollback current step
```

### Progress Bar Format
```
████████████████░░░░░░░░ 67% (8/12 steps)
```
- █ for completed steps
- ░ for pending steps
- Width: 24 characters

### Status Icons
- ✅ completed
- 🔄 in_progress
- ⏳ pending
- ❌ blocked
- 🔁 retrying

### Time Display
- < 60 minutes: "{N}m"
- >= 60 minutes: "{H}h {M}m"
- Calculate from `startedAt` to `completedAt` or now

## Files to Create
- `.windsurf/workflows/plan-status.md`

## Files to Modify
None (read-only workflow).

## Patterns to Follow
Reference: `.claude/commands/plan-status.md` for structure

## Acceptance Criteria
- [ ] Workflow file under 12,000 characters
- [ ] Lists all plans when no number specified
- [ ] Shows detailed status for specific plan
- [ ] Progress bar displays correctly
- [ ] Step table shows all required columns
- [ ] Current step section shows retry info
- [ ] Context summary accurate
- [ ] Next commands relevant to current state

## Testing Requirements

### Unit Tests
**N/A** - Workflow tested via execution.

### Integration Tests
- [ ] Run `/plan-status` with multiple plans
- [ ] Verify all plans listed with correct progress
- [ ] Run `/plan-status 001`
- [ ] Verify detailed view shows correctly
- [ ] Verify step table accurate
- [ ] Verify time calculations

### Manual Verification
- [ ] Progress bar visually accurate
- [ ] Status icons correct
- [ ] No stale data displayed

## Verification Commands
```bash
# List all plans via Python (compare with workflow output)
python3 -c "
import json
import os
for d in sorted(os.listdir('.windsurf/plans')):
    p = json.load(open(f'.windsurf/plans/{d}/progress.json'))
    print(f\"{p['planId']}: {p['status']} - {p['currentStep']}/{p['totalSteps']}\")
"

# Show specific plan progress
python3 -c "
import json
p = json.load(open('.windsurf/plans/001-xxx/progress.json'))
for s in p['steps']:
    print(f\"{s['id']}: {s['status']}\")
"
```

## Documentation Updates
None for this step.

## Error Recovery
If verification fails:
1. Check progress.json exists and is valid
2. Verify date/time formatting
3. Check for missing step data
4. Validate status values

## Do NOT
- Modify any files (read-only)
- Show incomplete/stale information
- Hide blocked or failed states
- Omit retry information
