# Command Reference

Complete reference for all Windsurf planning system commands.

## Planning Commands

### /plan-feature-initial [description]

Analyze a feature idea and prepare for planning.

**Purpose**: Gather requirements before creating a plan.

**Input**: Natural language feature description.

**Process**:
1. Classifies problem type (33 types, 8 categories)
2. Asks clarifying questions (grouped by priority)
3. Generates ready-to-use `/plan-feature` prompt

**Output**: Problem classification, answered questions, specification.

**Example**:
```
/plan-feature-initial Add a REST API for user management
```

---

### /plan-feature [description]

Create a new implementation plan.

**Purpose**: Generate a complete plan with steps, techniques, and artifacts.

**Input**: Detailed feature specification (ideally from `/plan-feature-initial`).

**Process**:
1. Determines next plan number
2. Creates plan directory
3. Generates plan.md, adr.md, steps/*.md
4. Assigns techniques and risk levels per step
5. Creates progress.json and context.md

**Output**: Plan directory at `.windsurf/plans/NNN-slug/`

**Artifacts Created**:
| File | Purpose |
|------|---------|
| `plan.md` | Main plan document |
| `adr.md` | Architecture Decision Record |
| `steps/NN-name.md` | Step specifications |
| `progress.json` | Machine-readable state |
| `context.md` | Session context |

**Example**:
```
/plan-feature Add user authentication

Requirements:
- Email/password login
- OAuth support (Google, Apple)
- Password reset
```

---

### /plan-prompts [plan-number]

Generate AI prompts for each step.

**Purpose**: Create technique-embedded prompts for execution.

**Input**: Plan number (defaults to most recent).

**Process**:
1. Reads each step specification
2. Loads assigned technique documentation
3. Embeds full technique instructions inline
4. Creates prompt file per step

**Output**: `prompts/NN-name.prompt.md` files.

**Note**: Must run before `/plan-next`.

**Example**:
```
/plan-prompts 001
```

---

## Execution Commands

### /plan-next [plan-number]

Execute the next step in a plan.

**Purpose**: Implement one step at a time with guidance.

**Input**: Plan number (defaults to most recent with pending steps).

**Process**:
1. Selects next step (in_progress > pending by order)
2. Loads step prompt
3. Executes planning phase (technique-guided)
4. Executes implementation phase
5. Executes verification phase
6. Tracks files created/modified/deleted/renamed
7. Prompts for commit if successful

**Output**: Implemented step, updated progress.

**Phases**:
| Phase | Technique Examples |
|-------|-------------------|
| Planning | PS+, ToT, ReAct |
| Implementation | TDD, Self-Refine, Reflexion |
| Verification | TDD, GoT, Self-Consistency |

**Self-Correction**: On failure, retries with same technique, then rotates to alternatives.

**Example**:
```
/plan-next 001
```

---

### /plan-verify [plan-number]

Re-run verification for current step.

**Purpose**: Check if current step meets acceptance criteria without re-implementing.

**Input**: Plan number (optional).

**Process**:
1. Extracts acceptance criteria from step prompt
2. Runs verification commands
3. Reports PASS/FAIL per criterion
4. Applies technique-specific verification

**Output**: Verification results with status per criterion.

**When to Use**:
- After manual fixes
- To confirm step completion
- After external changes

**Example**:
```
/plan-verify 001
```

---

### /plan-rollback [plan-number]

Revert current step's uncommitted changes.

**Purpose**: Safely undo work when a step goes wrong.

**Input**: Plan number (optional).

**Process**:
1. Checks git state (refuses if committed)
2. Shows preview of changes to revert
3. Asks for confirmation
4. Reverts files (created: delete, modified: checkout, etc.)
5. Offers memory bank preserve/reset option
6. Updates progress.json

**Safety Rules**:
| State | Behavior |
|-------|----------|
| All uncommitted | Full rollback available |
| All committed | Refuses (use git revert) |
| Mixed | Partial rollback offered |

**Example**:
```
/plan-rollback 001
```

---

## Status Commands

### /plan-status [plan-number]

Display plan progress.

**Purpose**: View overall progress and step details.

**Input**: Plan number (optional - lists all if omitted).

**Output Modes**:

**List Mode** (no plan number):
```
Plans:
001-user-auth      [====------] 40%  Step 3/5
002-dark-mode      [==========] 100% Complete
```

**Detail Mode** (with plan number):
```
Plan 001: User Authentication
Progress: [====------] 40% (2/5)

Steps:
| # | Name | Status | Technique | Tests |
|---|------|--------|-----------|-------|
| 1 | Login view | done | TDD | 5/5 |
| 2 | Auth service | done | TDD | 8/8 |
| 3 | Session mgmt | current | Reflexion | - |
| 4 | Password reset | pending | - | - |
| 5 | Remember me | pending | - | - |

Context: 4 files created, 2 decisions made
```

**Example**:
```
/plan-status       # List all plans
/plan-status 001   # Show plan 001 details
```

---

### /plan-feature-review [plan-number]

Review plan quality with agentic reasoning.

**Purpose**: Analyze and improve plan before or during execution.

**Input**: Plan number (optional).

**Process**:
1. Analyzes 6 dimensions (Completeness, Sequencing, Granularity, Technical, Risk, Technique)
2. Uses Tree of Thoughts per dimension
3. Merges findings with Graph of Thoughts
4. Scores each dimension (1-10)
5. Generates recommendations
6. Optionally updates plan artifacts

**Dimensions**:
| Dimension | Weight | Focus |
|-----------|--------|-------|
| Completeness | 20% | All requirements covered? |
| Sequencing | 15% | Dependencies respected? |
| Granularity | 20% | Steps right size? |
| Technical | 20% | Sound approach? |
| Risk | 15% | Risk levels correct? |
| Technique | 10% | Right techniques? |

**Output**: Review score, recommendations, optional plan updates.

**Example**:
```
/plan-feature-review 001
```

---

## CLI Commands

The Python CLI provides direct access to planning utilities:

```bash
python3 .windsurf/scripts/windsurf_plan.py [command] [options]
```

### classify [description]

Classify a problem description.

```bash
python3 .windsurf/scripts/windsurf_plan.py classify "Fix the login bug"
# Output: debug (LOGIC category)
```

### techniques [problem-type]

Show techniques for a problem type.

```bash
python3 .windsurf/scripts/windsurf_plan.py techniques debug
# Output: planning=react, implementation=reflexion, verification=self-refine
```

### risk [problem-type]

Assess risk level and retry budget.

```bash
python3 .windsurf/scripts/windsurf_plan.py risk migration
# Output: HIGH (retry budget: 7)
```

### status [plan-number]

Show plan status from CLI.

```bash
python3 .windsurf/scripts/windsurf_plan.py status 001
```

### list

List all plans.

```bash
python3 .windsurf/scripts/windsurf_plan.py list
```

### stage [--plan N] [--step M]

Generate staging commands for a step.

```bash
python3 .windsurf/scripts/windsurf_plan.py stage --plan 001 --step 3
# Output: git add commands (excludes .windsurf/**)
```

---

## Workflow Files

All commands correspond to workflow files in `.windsurf/workflows/`:

| Command | Workflow File |
|---------|---------------|
| /plan-feature-initial | plan-feature-initial.md |
| /plan-feature | plan-feature.md |
| /plan-prompts | plan-prompts.md |
| /plan-next | plan-next.md |
| /plan-status | plan-status.md |
| /plan-verify | plan-verify.md |
| /plan-rollback | plan-rollback.md |
| /plan-feature-review | plan-feature-review.md |

Internal helpers (called by main workflows):
- `_internal-init.md` - Directory initialization
- `_internal-verify.md` - Verification execution
- `_internal-commit.md` - Commit staging

---

Next: [MIGRATION_FROM_CLAUDE.md](MIGRATION_FROM_CLAUDE.md) - For Claude Code users
