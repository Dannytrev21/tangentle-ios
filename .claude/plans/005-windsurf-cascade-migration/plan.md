# Plan 005: Windsurf Cascade Plan Command System

## Overview
Migrate the Claude Code intelligent planning/execution system to Windsurf IDE (Cascade), implementing 8 workflow commands as workspace-local workflows with supporting Python scripts, templates, rules, knowledge, and memory bank. This preserves all 10 prompt engineering techniques, phase-based execution, self-correction with retry budgets, and repo-agnostic operation.

## Status
- **Created**: 2026-01-02
- **Status**: Not Started
- **Current Step**: 0 of 18
- **Problem Type**: migration (Category: DATA)
- **Risk Level**: HIGH (0.80)

## Tree of Thought Analysis

### What are we building?
A complete port of the Claude Code planning system to Windsurf IDE, including:
- 8 workflow commands callable via `/plan-*` in Cascade chat
- Python scripts for problem classification, technique selection, risk assessment, and self-correction
- Template files for reusable workflow components
- Knowledge files for technique documentation
- Memory bank for cross-session learning
- Full `.windsurf/` directory structure with gitignore exclusion

### Why are we building it?
To enable the same high-quality, technique-aware, self-correcting AI-assisted development workflow in Windsurf IDE that exists in Claude Code, allowing:
- Repo-agnostic planning across any technology stack
- Consistent quality through prompt engineering techniques
- Learning from failures via memory bank
- Progress persistence across sessions

### Key Decisions

#### Decision 1: Python Script Architecture

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Port existing scripts as-is | Minimal rewrite, proven logic | May have Claude-specific assumptions |
| B | Rewrite for Windsurf patterns | Clean slate, optimized | More work, risk of logic drift |
| C | Hybrid: port core, rewrite interfaces | Best of both worlds | Moderate complexity |

**Selected: Option C (Hybrid)** - Port the core classification/selection logic from existing scripts but create new interface layers for Windsurf's workflow invocation patterns. This preserves the battle-tested algorithms while adapting to Windsurf's execution model.

#### Decision 2: Workflow Decomposition Strategy

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | 8 monolithic workflows | Simpler structure | Risk of hitting 12K char limit |
| B | 8 main + helper workflows | Modular, reusable | More files to manage |
| C | Templates + minimal workflows | Maximum reuse | Cascade may not read templates well |

**Selected: Option B (Main + Helper Workflows)** - Each of the 8 `/plan-*` commands gets a main workflow file, with shared logic extracted to helper workflows (e.g., `/plan-internal-verify`, `/plan-internal-commit`). This stays within character limits while maintaining clear entry points.

#### Decision 3: Technique Prompt Storage

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Inline in step prompts | Self-contained prompts | Very large prompt files |
| B | Reference in knowledge/ | Smaller prompts | Cascade must load references |
| C | Templates + inline summary | Best of both | More complex generation |

**Selected: Option A (Inline in step prompts)** - Per user preference, full technique instructions will be embedded directly in each step prompt. This ensures Cascade has all context without needing to load external files, though prompt files will be larger.

#### Decision 4: File Tracking Granularity

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | created + modified only | Simple, covers 90% cases | Can't handle renames/deletes |
| B | All 4 operations | Complete tracking | More complex staging logic |
| C | Single list with metadata | Flexible, extensible | More parsing required |

**Selected: Option B (All 4 operations)** - Track `filesCreated`, `filesModified`, `filesDeleted`, and `filesRenamed` per step. This enables precise rollback and commit staging for all scenarios.

#### Decision 5: Initialization Strategy

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Lazy creation | Minimal upfront setup | Inconsistent structure initially |
| B | Full initialization on first run | Consistent from start | Larger first-run time |
| C | Separate /windsurf-init command | Explicit user control | Extra command to remember |

**Selected: Option B (Full initialization)** - The first `/plan-feature` run will create the complete `.windsurf/` structure including all directories, template files, and gitignore update. Subsequent runs will update as needed.

#### Decision 6: Verification Command Discovery

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Deep inspection (10+ file types) | Comprehensive | More code to maintain |
| B | Common patterns (4-5 files) | Simpler, covers most cases | May miss edge cases |
| C | Always prompt user | Reliable | More user friction |

**Selected: Option A (Deep inspection)** - Check package.json, Makefile, .github/workflows/*, setup.py, pyproject.toml, Cargo.toml, go.mod, build.gradle, pom.xml, CMakeLists.txt, and README.md. Cache discovered commands in `.windsurf/knowledge/repo-commands.md`.

#### Decision 7: Memory Bank Integration

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | File-based only | Simple, portable | No cross-plan retrieval |
| B | Windsurf Memories only | Native integration | Plan-specific context harder |
| C | Hybrid approach | Best of both | More complexity |

**Selected: Option C (Hybrid)** - Plan-specific lessons stored in `.windsurf/plans/{NNN}/memory-bank.json`. Cross-plan learnings surfaced to Windsurf's native Memories feature via "create a memory" prompts when significant patterns emerge.

### Testing Strategy

| Test Type | Scope | Location | Priority |
|-----------|-------|----------|----------|
| Unit | Python scripts (classifier, selector, risk, self-correction) | `.windsurf/scripts/tests/` | Required |
| Integration | Workflow → Python → artifact creation | Manual + test repo | Required |
| Functional | Each /plan-* command end-to-end | Test repo | Required |
| Regression | Compare output to Claude Code version | Side-by-side | Optional |

## Technique Matrix

| Step | Problem Type | Planning | Implementation | Verification | Risk |
|------|--------------|----------|----------------|--------------|------|
| 1 | infrastructure | ps-plus | least-to-most | self-refine | low |
| 2 | infrastructure | ps-plus | least-to-most | self-refine | low |
| 3 | scaffolding | ps-plus | chain-of-code | self-refine | low |
| 4 | migration | least-to-most | chain-of-code | reflexion | medium |
| 5 | migration | least-to-most | chain-of-code | reflexion | medium |
| 6 | migration | least-to-most | chain-of-code | reflexion | medium |
| 7 | migration | least-to-most | chain-of-code | reflexion | medium |
| 8 | service-impl | ps-plus | tdd | reflexion | high |
| 9 | service-impl | ps-plus | tdd | reflexion | high |
| 10 | service-impl | ps-plus | self-refine | reflexion | high |
| 11 | service-impl | ps-plus | tdd | reflexion | high |
| 12 | service-impl | ps-plus | tdd | reflexion | high |
| 13 | service-impl | ps-plus | tdd | reflexion | high |
| 14 | service-impl | ps-plus | tdd | reflexion | high |
| 15 | service-impl | ps-plus | tdd | reflexion | high |
| 16 | documentation | ps-plus | self-refine | got | low |
| 17 | integration-test | ps-plus | tdd | reflexion | medium |
| 18 | documentation | ps-plus | self-refine | got | low |

## Implementation Steps

| Step | Name | Description | Type | Risk | Status |
|------|------|-------------|------|------|--------|
| 1 | directory-structure | Create .windsurf/ directory hierarchy and .gitignore update | infrastructure | low | Pending |
| 2 | python-foundation | Port core Python scripts (classifier, selector, risk, utils) | infrastructure | low | Pending |
| 3 | templates-foundation | Create workflow template files for reusable components | scaffolding | low | Pending |
| 4 | knowledge-techniques | Create technique documentation in knowledge/ | migration | medium | Pending |
| 5 | self-correction-engine | Port self-correction with memory bank and technique rotation | migration | medium | Pending |
| 6 | workflow-plan-feature-initial | Create /plan-feature-initial workflow | migration | medium | Pending |
| 7 | workflow-plan-feature | Create /plan-feature workflow | migration | medium | Pending |
| 8 | workflow-plan-prompts | Create /plan-prompts workflow | service-impl | high | Pending |
| 9 | workflow-plan-next | Create /plan-next workflow with phase-based execution | service-impl | high | Pending |
| 10 | workflow-plan-status | Create /plan-status workflow | service-impl | high | Pending |
| 11 | workflow-plan-verify | Create /plan-verify workflow | service-impl | high | Pending |
| 12 | workflow-plan-rollback | Create /plan-rollback workflow | service-impl | high | Pending |
| 13 | workflow-plan-feature-review | Create /plan-feature-review workflow with agentic reasoning | service-impl | high | Pending |
| 14 | helper-workflows | Create internal helper workflows for shared logic | service-impl | high | Pending |
| 15 | commit-staging | Implement per-step file tracking and selective commit staging | service-impl | high | Pending |
| 16 | project-context-system | Create PROJECT_CONTEXT.md and memory-bank structure | documentation | low | Pending |
| 17 | end-to-end-testing | Test all workflows in a fresh test repository | integration-test | medium | Pending |
| 18 | migration-guide | Document migration from Claude Code to Windsurf | documentation | low | Pending |

## Files to Create

### Directory Structure
- `.windsurf/workflows/` - Workflow markdown files
- `.windsurf/plans/` - Plan storage (mirrors `.claude/plans/`)
- `.windsurf/scripts/` - Python utilities
- `.windsurf/scripts/tests/` - Python unit tests
- `.windsurf/templates/` - Reusable template fragments
- `.windsurf/knowledge/` - Reference documentation
- `.windsurf/knowledge/techniques/` - Technique guides
- `.windsurf/memory-bank/` - Cross-session context
- `.windsurf/rules/` - Cascade rules

### Workflow Files (8 main + helpers)
- `.windsurf/workflows/plan-feature-initial.md`
- `.windsurf/workflows/plan-feature.md`
- `.windsurf/workflows/plan-prompts.md`
- `.windsurf/workflows/plan-next.md`
- `.windsurf/workflows/plan-status.md`
- `.windsurf/workflows/plan-verify.md`
- `.windsurf/workflows/plan-rollback.md`
- `.windsurf/workflows/plan-feature-review.md`
- `.windsurf/workflows/_internal-verify.md`
- `.windsurf/workflows/_internal-commit.md`
- `.windsurf/workflows/_internal-init.md`

### Python Scripts (ported from Claude Code)
- `.windsurf/scripts/problem_classifier.py`
- `.windsurf/scripts/technique_selector.py`
- `.windsurf/scripts/risk_assessor.py`
- `.windsurf/scripts/self_correction.py`
- `.windsurf/scripts/memory_bank.py`
- `.windsurf/scripts/prompt_composer.py`
- `.windsurf/scripts/utils.py`
- `.windsurf/scripts/windsurf_plan.py` (CLI orchestrator)

### Templates
- `.windsurf/templates/plan.md.template`
- `.windsurf/templates/adr.md.template`
- `.windsurf/templates/step.md.template`
- `.windsurf/templates/prompt.md.template`
- `.windsurf/templates/progress.json.template`
- `.windsurf/templates/context.md.template`

### Knowledge Files
- `.windsurf/knowledge/architecture.md`
- `.windsurf/knowledge/techniques/tdd.md`
- `.windsurf/knowledge/techniques/tot.md`
- `.windsurf/knowledge/techniques/got.md`
- `.windsurf/knowledge/techniques/reflexion.md`
- `.windsurf/knowledge/techniques/self-refine.md`
- `.windsurf/knowledge/techniques/self-consistency.md`
- `.windsurf/knowledge/techniques/react.md`
- `.windsurf/knowledge/techniques/ps-plus.md`
- `.windsurf/knowledge/techniques/chain-of-code.md`
- `.windsurf/knowledge/techniques/least-to-most.md`
- `.windsurf/knowledge/repo-commands.md` (auto-generated)

### Memory Bank
- `.windsurf/memory-bank/productContext.md`
- `.windsurf/memory-bank/activeContext.md`
- `.windsurf/memory-bank/progress.md`
- `.windsurf/memory-bank/decisionLog.md`
- `.windsurf/memory-bank/systemPatterns.md`

### Project Context
- `.windsurf/PROJECT_CONTEXT.md`

## Files to Modify
- Repository `.gitignore` - Add `.windsurf/**` (left as local modification)

## Dependencies
- Step 2 depends on Step 1 (directories must exist)
- Steps 4-5 depend on Step 2 (Python foundation)
- Steps 6-13 depend on Steps 3-5 (templates, techniques, self-correction)
- Step 14 can run in parallel with Steps 10-13
- Step 15 depends on Steps 9, 12 (needs plan-next and plan-rollback)
- Step 17 depends on all Steps 1-16
- Step 18 depends on Step 17

## Success Criteria
- [ ] All 8 `/plan-*` workflows create correct artifacts under `.windsurf/plans/`
- [ ] Default plan selection works via `progress.json.updatedAt`
- [ ] `.gitignore` is updated to ignore `.windsurf/**` and remains uncommitted
- [ ] `/plan-next` enforces tests and updates `progress.json` with technique tracking
- [ ] Per-step file association (created/modified/deleted/renamed) enables precise commit staging
- [ ] `/plan-rollback` safely reverts uncommitted step changes
- [ ] `/plan-feature-review` produces review logs with agentic ToT/GoT analysis
- [ ] Self-correction works with memory bank, retry budgets, and technique rotation
- [ ] Python scripts pass unit tests (>80% coverage)
- [ ] All 10 prompt engineering techniques are available and selectable
- [ ] System works in any git repository (repo-agnostic)

## Rollback Plan
1. **Partial rollback**: Delete specific `.windsurf/` subdirectories if step fails
2. **Full rollback**: Delete entire `.windsurf/` directory
3. **Git cleanup**: Remove `.windsurf/**` from `.gitignore` if needed
4. No committed changes to undo (everything stays in `.windsurf/`)

## Constraints
- Each workflow file must stay under 12,000 characters
- Nothing in `.windsurf/**` is ever committed to the repository
- Workflows must work without iOS/Swift-specific assumptions
- Python scripts must use standard library only (no pip dependencies)
- Commit messages are user-provided with suggested simple descriptions
