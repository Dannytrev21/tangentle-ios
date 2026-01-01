# Plan Feature Command

You are creating a comprehensive implementation plan for a new feature. This plan will guide AI agents through high-quality implementation with self-correction capabilities.

## Input
Feature description: $ARGUMENTS

## Process

### Step 1: Analyze the Feature Request
First, thoroughly understand what's being requested:
1. Read `CLAUDE.md` for project context and conventions
2. Explore the codebase to understand existing patterns
3. Identify affected files and systems
4. Identify existing architectural documents to understand the system

### Step 2: Determine Plan Number
Check existing plans and get next number:
```bash
ls -d .claude/plans/[0-9]* 2>/dev/null | sort -V | tail -1
```
If no plans exist, start with 001. Otherwise increment.

### Step 3: Create Plan Directory
Create: `.claude/plans/{NNN}-{feature-slug}/`

With structure:
```
.claude/plans/{NNN}-{feature-slug}/
├── plan.md           # Main plan document
├── adr.md            # Architecture Decision Record
├── steps/            # Individual step files
├── prompts/          # AI prompts (created by /plan-prompts)
├── progress.json     # Machine-readable state
└── context.md        # Accumulated context
```

### Step 4: Apply Tree of Thought Analysis
For each major decision in the feature, document:

```markdown
### Decision: {Topic}

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | ... | ... | ... |
| B | ... | ... | ... |
| C | ... | ... | ... |

**Selected: Option {X}** - {Rationale}
```

Consider at minimum:
- Data storage approach
- API design
- UI/UX approach
- Integration strategy
- Testing strategy (unit, integration, UI tests)

### Step 5: Create plan.md
Use this template:

```markdown
# Plan {NNN}: {Feature Name}

## Overview
{2-3 sentence description of the feature and its value}

## Status
- **Created**: {date}
- **Status**: Not Started
- **Current Step**: 0 of {N}

## Tree of Thought Analysis

### What are we building?
{Detailed description}

### Why are we building it?
{Business/user value}

### Key Decisions
{Tree of Thought analysis for each major decision}

### Testing Strategy
| Test Type | Scope | Files | Priority |
|-----------|-------|-------|----------|
| Unit | {what to unit test} | TangentleTests/Unit/... | Required |
| Integration | {what to integration test} | TangentleTests/Integration/... | {Required/Optional} |
| UI | {what to UI test} | TangentleUITests/... | {Required/Optional} |

## Technique Matrix

| Step | Problem Type | Planning | Implementation | Verification | Risk |
|------|--------------|----------|----------------|--------------|------|
| 1 | {step_type} | {technique} | {technique(s)} | {technique} | {low/medium/high} |
| 2 | {step_type} | {technique} | {technique(s)} | {technique} | {low/medium/high} |
| ... | ... | ... | ... | ... | ... |

## Implementation Steps

| Step | Name | Description | Type | Risk | Status |
|------|------|-------------|------|------|--------|
| 1 | {name} | {description} | {problem_type} | {risk_level} | Pending |
| 2 | {name} | {description} | {problem_type} | {risk_level} | Pending |
| ... | ... | ... | ... | ... | ... |

## Files to Create
- {path}: {description}

## Files to Modify
- {path}: {what changes}

## Dependencies
- {step X depends on step Y}

## Success Criteria
- [ ] {criterion 1}
- [ ] {criterion 2}

## Rollback Plan
{How to undo if things go wrong}
```

### Step 6: Create adr.md
Document the architectural decisions:

```markdown
# ADR: {Feature Name}

## Status
Proposed

## Context
{Why this feature is needed}

## Tree of Thought Analysis
{All major decisions with options considered}

## Decision
{Summary of selected approach}

## Consequences
### Positive
- {benefit 1}

### Negative
- {tradeoff 1}

### Mitigations
- {how to address negatives}
```

### Step 6.5: Assign Techniques to Steps

For each step identified in the plan, determine the optimal prompt engineering techniques:

#### 1. Classify Step Problem Type

The step's problem type may differ from the overall plan type:
- A "new-feature" plan may have "test-setup", "ui", and "service-impl" steps
- A "debug" plan may have "refactor" and "documentation" steps
- Analyze each step's description to determine its specific type

```bash
# For each step, classify using CLI:
cd .claude/scripts && python3 tangentle_plan.py classify "{step description}"
```

If Python unavailable, use keyword matching:
- Creates entities/models → `data-modeling`
- Creates services/repositories → `service-impl`
- Sets up infrastructure/config → `infrastructure`
- Creates/modifies UI → `ui`
- Writes tests → `unit-test` or `integration-test`
- Fixes bugs → `debug`
- Restructures code → `refactor`
- Default → same as overall plan type

#### 2. Select Techniques Per Phase

```bash
# For each step, get techniques:
cd .claude/scripts && python3 -c "
from technique_selector import TechniqueSelector, Phase
s = TechniqueSelector()

step_type = '{step_problem_type}'
for phase in [Phase.PLANNING, Phase.IMPLEMENTATION, Phase.VERIFICATION]:
    tech = s.select_techniques(step_type, phase)
    print(f'{phase.value}: {tech.primary} (retry: {tech.retry_budget})')
"
```

If Python unavailable, use this technique reference table:

| Problem Type | Planning | Implementation | Verification |
|--------------|----------|----------------|--------------|
| infrastructure | ps-plus | least-to-most | self-refine |
| data-modeling | ps-plus | self-refine | tdd |
| service-impl | ps-plus | tdd, self-refine | reflexion |
| ui | ps-plus | self-refine | manual |
| unit-test | ps-plus | tdd | self-refine |
| debug | react | reflexion | self-refine |
| algorithm | self-consistency | tdd | reflexion |
| refactor | ps-plus | self-refine | tdd |
| documentation | ps-plus | self-refine | got |

#### 3. Assess Risk Per Step

```bash
# Assess risk for each step:
cd .claude/scripts && python3 -c "
from risk_assessor import RiskAssessor, StepInfo
a = RiskAssessor()

step = StepInfo(
    problem_type='{step_type}',
    files_to_modify={file_count},
    has_data_migration={True|False},
    affects_persistence={True|False},
    has_breaking_change={True|False}
)
result = a.assess_risk(step)
print(f'Risk Level: {result.level.value}')
print(f'Retry Budget: {result.retry_config.max_total}')
"
```

Risk level determines retry configuration:
- **Low**: 3 total retries (2 same, 1 alternative)
- **Medium**: 5 total retries (3 same, 2 alternative)
- **High**: 7 total retries (3 same, 3 alternative)
- **Critical**: 10 total retries (4 same, 4 alternative) + escalation

#### 4. Document Technique Rationale

For each step, note why these techniques were selected:
- What about the step's requirements led to this technique?
- What alternatives were considered?
- What risk factors influenced the selection?

### Step 7: Create Individual Step Files
For each implementation step, create `.claude/plans/{NNN}-{slug}/steps/{NN}-{step-name}.md`:

```markdown
# Step {N}: {Step Name}

## Problem Type
`{step_problem_type}`

## Technique Selection
- **Planning**: {technique} - {rationale for this technique}
- **Implementation**: {technique(s)} - {rationale}
- **Verification**: {technique} - {rationale}

## Risk Level
**{low|medium|high|critical}** - {explanation of risk factors}

## Retry Configuration
- Same technique: {n} attempts
- Alternative technique: {n} attempts
- Escalation: After {n} total failures

## Context
{Why this step is needed, what it builds on}

## Goal
{Clear, measurable objective}

## Prerequisites
- Step {X} completed
- {other requirements}

## High-Level Steps
1. {step 1}
2. {step 2}
3. {step 3}

## Detailed Requirements
{Specific implementation details}

## Files to Create
- `{path}`: {description}

## Files to Modify
- `{path}`: {what to change}

## Patterns to Follow
Reference: `{existing file}` lines {X-Y}

## Acceptance Criteria
- [ ] {criterion 1}
- [ ] {criterion 2}
- [ ] {criterion 3}
- [ ] All tests pass

## Testing Requirements
Each step MUST include appropriate tests. Select applicable types:

### Unit Tests
- [ ] Test file: `TangentleTests/Unit/{FeatureName}Tests.swift`
- [ ] Test cases:
  - `test{FunctionName}_when{Condition}_should{ExpectedBehavior}()`
  - {additional test cases}

### Integration Tests (if applicable)
- [ ] Test file: `TangentleTests/Integration/{FeatureName}IntegrationTests.swift`
- [ ] Test cases:
  - `test{ComponentA}IntegratesWith{ComponentB}()`

### UI Tests (if applicable)
- [ ] Test file: `TangentleUITests/{FeatureName}UITests.swift`
- [ ] Test cases:
  - `test{UserAction}_should{VisibleResult}()`

### What to Test
- {specific behavior 1}
- {specific behavior 2}
- Edge cases: {list edge cases}
- Error handling: {list error scenarios}

## Verification Commands
```bash
# Build project
xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Run unit tests for this feature
xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/Unit/{TestClass}

# Run all tests
xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Documentation Updates
- [ ] Update `{file}`: {what to add}

## Error Recovery
If verification fails:
1. {recovery step 1}
2. {recovery step 2}

## Do NOT
- {common mistake 1}
- {common mistake 2}
```

### Step 8: Create progress.json

```json
{
  "planId": "{NNN}",
  "name": "{feature-slug}",
  "title": "{Feature Name}",
  "description": "{Brief description}",
  "problemType": "{overall_problem_type}",
  "problemCategory": "{FOUNDATION|DATA|ARCHITECTURE|UI_UX|TESTING|LOGIC|DOCUMENTATION|META}",
  "createdAt": "{ISO date}",
  "updatedAt": "{ISO date}",
  "status": "not_started",
  "currentStep": 0,
  "totalSteps": {N},
  "techniqueProfile": {
    "defaultPlanning": "{technique}",
    "defaultImplementation": "{technique}",
    "defaultVerification": "{technique}"
  },
  "steps": [
    {
      "id": 1,
      "name": "{step-slug}",
      "title": "{Step Title}",
      "problemType": "{step_problem_type}",
      "status": "pending",
      "techniques": {
        "planning": "{technique}",
        "implementation": ["{technique}", "{optional_secondary}"],
        "verification": "{technique}"
      },
      "techniqueRationale": "{why these techniques were selected}",
      "riskLevel": "{low|medium|high|critical}",
      "riskScore": 0.0,
      "retryConfig": {
        "maxSameTechnique": 2,
        "maxAlternative": 1,
        "maxTotal": 3
      },
      "attempts": 0,
      "techniquesUsed": [],
      "promptGenerated": false,
      "startedAt": null,
      "completedAt": null,
      "verificationPassed": null,
      "testsPassed": null,
      "testsWritten": [],
      "notes": ""
    }
  ],
  "context": {
    "filesCreated": [],
    "filesModified": [],
    "testsCreated": [],
    "keyDecisions": [],
    "blockers": [],
    "learnings": []
  }
}
```

### Step 9: Create context.md

```markdown
# Plan {NNN} Context

This file maintains context for resuming work on this plan from a fresh terminal or after conversation compacting.

## Quick Status
- **Plan**: {Feature Name}
- **Current Step**: {N} - {Step Name}
- **Last Updated**: {date/time}

## What's Been Done
{Summary of completed work}

## Files Created
| File | Purpose |
|------|---------|

## Files Modified
| File | Changes |
|------|---------|

## Tests Created
| Test File | Test Cases | Status |
|-----------|------------|--------|
| {test file path} | {number} tests | Passing/Failing |

## Key Decisions Made
1. {Decision 1}: {rationale}

## Current State
{Description of where things are}

## Next Actions
1. {What to do next}

## Things to Remember
- {Important context 1}
- {Important context 2}

## Blockers
{Any current blockers}

## Learnings
{What we've learned during implementation}
```

### Step 10: Output Summary
After creating all files, output:

```
## Plan Created: {NNN}-{feature-slug}

**Feature**: {Feature Name}
**Steps**: {N} implementation steps
**Location**: .claude/plans/{NNN}-{feature-slug}/

### Files Created
- plan.md - Main plan document
- adr.md - Architecture decisions
- steps/ - {N} step files
- progress.json - Progress tracking
- context.md - Context preservation

### Next Commands
1. `/plan-prompts {NNN}` - Generate AI prompts for each step
2. `/plan-next {NNN}` - Start implementing first step
3. `/plan-status {NNN}` - Check progress anytime
```

## Quality Standards

### For Steps
- Each step should be completable in one focused session (30-90 minutes)
- Steps should have clear, testable acceptance criteria
- Dependencies between steps must be explicit
- Verification commands must be copy-pasteable
- **Every step MUST include tests** - no exceptions

### For Testing (MANDATORY)
- Every step must define what tests to write
- Unit tests for all new functions, methods, and computed properties
- Integration tests when multiple components interact
- UI tests for user-facing features and interactions
- Tests must be written BEFORE marking a step complete
- Test naming convention: `test{What}_when{Condition}_should{Expected}()`
- Minimum test coverage goals:
  - Services/Business Logic: 80%+ coverage
  - ViewModels: 70%+ coverage
  - Repositories: 60%+ coverage
  - UI Components: UI tests for critical paths

### For Tree of Thought
- Consider at least 3 options for each major decision
- Document pros/cons objectively
- Explain rationale for selection
- Consider long-term maintainability

### For Context Preservation
- Write as if explaining to someone with no prior context
- Include specific file paths and line numbers
- Document "why" not just "what"
- Update after every significant change

## Constraints
- DO NOT begin working on any of the next prompts or implementing this before the plan-prompts has been called. This is just for the setup and plan. Actual implementation step will begin after.
- **TESTING IS MANDATORY**: No step can be marked complete without tests. If a step creates new code, that code must have tests. UI-only steps must have UI tests or at minimum manual verification checklists.

## Test Type Guidelines

| Code Type | Test Type Required | Example |
|-----------|-------------------|---------|
| Services | Unit tests | `testTaskService_createTask_shouldPersistToRepository()` |
| ViewModels | Unit tests | `testTodayViewModel_loadTasks_shouldPopulateTasksList()` |
| Repositories | Unit tests (in-memory) | `testTaskRepository_fetchByStatus_shouldFilterCorrectly()` |
| Views/Components | UI tests | `testTaskCard_tapCheckbox_shouldMarkComplete()` |
| Gestures/Animations | Manual verification + UI tests | `testSwipeableRow_swipeLeft_shouldRevealActions()` |
| API/Network | Integration tests (mocked) | `testAIService_sendMessage_shouldReturnResponse()` |

## When Tests Are Not Applicable
In rare cases where tests are genuinely not applicable (e.g., pure asset changes, documentation-only steps), document:
```markdown
## Testing Requirements
**N/A - Reason**: {explain why tests don't apply}
**Manual Verification**: {what to check manually}
```
