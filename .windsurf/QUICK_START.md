# Quick Start: Windsurf Planning System

Get from feature idea to working code in 6 steps.

## Overview

The planning system breaks down complex features into manageable steps with AI guidance:

```
Feature Idea → Requirements → Plan → Prompts → Step-by-Step Implementation → Done
```

## Create Your First Plan

### Step 1: Gather Requirements

Open Windsurf in your repository and type in Cascade:

```
/plan-feature-initial Add user authentication with login and registration
```

Cascade will:
1. Classify your problem type (e.g., "ui", "api-integration")
2. Ask clarifying questions
3. Generate a detailed specification

Answer the questions. When done, you'll get a ready-to-use `/plan-feature` prompt.

### Step 2: Create the Plan

Copy the generated specification and run:

```
/plan-feature Add user authentication with login and registration

Requirements:
- Email/password registration
- Login with remember me
- Password reset flow
- Session management

Tech Stack: SwiftUI, Core Data
```

This creates:
- `.windsurf/plans/001-user-authentication/plan.md` - Main plan
- `adr.md` - Architecture decisions
- `steps/*.md` - Step specifications
- `progress.json` - Machine-readable state

### Step 3: Generate Prompts

```
/plan-prompts 001
```

This generates AI prompts for each step with embedded technique instructions.

### Step 4: Start Implementation

```
/plan-next 001
```

Cascade will:
1. Show current step details
2. Execute planning phase
3. Execute implementation phase
4. Execute verification phase
5. Track files created/modified
6. Prompt for commit

### Step 5: Commit and Continue

When a step passes verification, commit your changes:

```bash
# Cascade suggests the files and message
git add <suggested files>
git commit -m "Implement step 1: Login view"
```

Then continue:

```
/plan-next 001
```

### Step 6: Monitor Progress

```
/plan-status 001
```

Shows:
- Progress bar
- Step table with status
- Current context
- Recent learnings

## Daily Workflow

```
1. /plan-status           # See where you are
2. /plan-next [N]         # Continue implementation
3. Commit when prompted   # Save progress
4. /plan-status           # Confirm progress
5. Repeat until complete
```

## Common Commands Quick Reference

| Command | What It Does |
|---------|--------------|
| `/plan-status` | View all plans or details of one |
| `/plan-next 001` | Execute next step in plan 001 |
| `/plan-verify 001` | Re-run verification for current step |
| `/plan-rollback 001` | Undo uncommitted changes |
| `/plan-feature-review 001` | Analyze plan quality |

## Tips for Success

### Keep Steps Small
Good plans have steps that take 30-90 minutes each. If a step feels too big, break it down.

### Commit After Each Step
The system tracks files per step. Commit when prompted to maintain clean history.

### Use Self-Correction
If a step fails, the system will:
1. Retry with the same technique
2. Rotate to a different technique
3. Escalate if all retries fail

Check the memory bank for lessons learned:
```
/plan-status 001  # Shows recent learnings
```

### Resume After Breaks
The system tracks context. When you return:
```
/plan-status     # See where you left off
/plan-next 001   # Continue from last step
```

## Example Session

```
> /plan-feature-initial Add dark mode support

Classification: ui
Questions:
- Which components need theming?
- Store preference locally or sync?
...

> /plan-feature Add dark mode support
  [specification from above]

Created: Plan 001 with 5 steps

> /plan-prompts 001

Generated 5 prompts

> /plan-next 001

Executing Step 1: Create theme provider
[Planning phase...]
[Implementation phase...]
[Verification phase...]
All checks passed!

Files created: Theme.swift
Commit? y

> git add Theme.swift && git commit -m "Add theme provider"

> /plan-status 001

Progress: [===---] 1/5 (20%)
Current: Step 2 - Add dark color palette
```

---

Next: [COMMAND_REFERENCE.md](COMMAND_REFERENCE.md) - All commands in detail
