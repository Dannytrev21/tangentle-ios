# Windsurf Planning System Architecture

## Overview

This document describes the technique-based AI planning system for Windsurf IDE. The system enables intelligent, self-correcting AI-assisted development through:

- **Problem Classification**: Automatically identify the type of problem (33 types, 8 categories)
- **Technique Selection**: Choose optimal prompt engineering techniques for each phase
- **Phase-Based Execution**: Planning → Implementation → Verification
- **Self-Correction**: Retry with learning from failures via memory bank
- **Progress Persistence**: Track progress across sessions

## Technique Reference

| Technique | Best For | Cost | Typical Phase |
|-----------|----------|------|---------------|
| PS+ (Plan-and-Solve Plus) | Structured planning | Low | Planning |
| Least-to-Most | Decomposition | Low | Planning |
| TDD | Implementation with tests | Medium | Implementation |
| Self-Refine | Iterative improvement | Medium | Implementation |
| Chain-of-Code | Mixed logic/semantic tasks | Medium | Implementation |
| ReAct | Interactive problem-solving | Medium | Planning |
| ToT (Tree of Thoughts) | Complex decisions | High | Planning |
| GoT (Graph of Thoughts) | Merging/refinement | High | Verification |
| Self-Consistency | Algorithm verification | High | Verification |
| Reflexion | Learning from failures | Medium-High | Verification |

## Problem Type Taxonomy

### Categories

| Category | Description | Risk Level Range |
|----------|-------------|------------------|
| FOUNDATION | Infrastructure, scaffolding, config | Low |
| DATA | Modeling, access, migration, state | Medium-High |
| ARCHITECTURE | System design, protocols, services | Medium-High |
| UI_UX | Views, components, animations | Low-Medium |
| TESTING | Test infrastructure and implementation | Low-Medium |
| LOGIC | Algorithms, validation, debugging | Medium |
| DOCUMENTATION | Docs, changelogs | Low |
| META | Ideation, new features | Medium |

### Problem Types per Category

**FOUNDATION**: infrastructure, scaffolding, configuration

**DATA**: data-modeling, data-access, migration, state-mgmt

**ARCHITECTURE**: system-design, protocol-design, di-setup, service-impl, refactor

**UI_UX**: ui, component-lib, design-tokens, animation, gesture, accessibility, polish

**TESTING**: test-setup, unit-test, integration-test, snapshot-test, e2e-test, performance-test

**LOGIC**: algorithm, validation, api-integration, debug

**DOCUMENTATION**: documentation, changelog

**META**: ideation, new-feature

## Phase-Based Execution

Each step is executed in three phases, each with an assigned technique:

### Planning Phase
**Purpose**: Understand requirements, design approach

**Common Techniques**:
- PS+ for straightforward problems
- ToT for complex decisions requiring exploration
- Least-to-Most for decomposable problems
- ReAct for interactive discovery

### Implementation Phase
**Purpose**: Write code, create artifacts

**Common Techniques**:
- TDD for algorithm and business logic
- Self-Refine for iterative quality improvement
- Chain-of-Code for mixed semantic/logic tasks
- Least-to-Most for incremental building

### Verification Phase
**Purpose**: Test, validate, ensure quality

**Common Techniques**:
- Reflexion for learning from test failures
- Self-Consistency for correctness checking
- GoT for documentation review
- TDD for test execution

## Technique Selection Flow

```
1. Classify problem description
   └── Python: problem_classifier.py
   └── Output: problem_type, category, confidence

2. Look up default techniques
   └── Config: technique-config.json
   └── Output: techniques for each phase

3. Adjust based on context
   └── Previous failures → prefer Reflexion
   └── High complexity → prefer ToT
   └── High risk → increase retry budget

4. Apply technique during execution
   └── Load: .windsurf/knowledge/techniques/{technique}.md
   └── Follow execution instructions
```

## Self-Correction Engine

### Risk Levels and Retry Budgets

| Risk Level | Same Technique | Alternative | Total |
|------------|----------------|-------------|-------|
| Low | 2 | 1 | 3 |
| Medium | 3 | 2 | 5 |
| High | 3 | 3 | 7 |
| Critical | 5 | 5 | 10 |

### Technique Rotation

When same-technique retries are exhausted, rotate to alternatives:

| Failure Pattern | Suggested Technique |
|-----------------|---------------------|
| Edge case missing | TDD |
| Not converging | Self-Consistency |
| Architecture issue | ToT |
| Async/timing | ReAct |
| Repeat mistakes | Reflexion |

### Memory Bank

Plan-specific lessons stored in `.windsurf/plans/{NNN}/memory-bank.json`:

```json
{
  "maxEntries": 10,
  "entries": [
    {
      "timestamp": "ISO date",
      "stepId": 1,
      "failureType": "logic_error",
      "context": "What was attempted",
      "lesson": "What was learned",
      "resolution": "How it was resolved"
    }
  ]
}
```

FIFO: Oldest entries removed when max exceeded.

## Directory Structure

```
.windsurf/
├── workflows/              # Cascade workflow commands
│   ├── plan-feature.md
│   ├── plan-next.md
│   └── ...
├── plans/                  # Plan storage (per plan)
│   └── {NNN}-{slug}/
│       ├── plan.md
│       ├── progress.json
│       ├── context.md
│       └── memory-bank.json
├── scripts/                # Python utilities
│   ├── problem_classifier.py
│   ├── technique_selector.py
│   ├── risk_assessor.py
│   └── windsurf_plan.py
├── templates/              # Artifact templates
│   ├── plan.md.template
│   └── ...
├── knowledge/              # Reference documentation
│   ├── architecture.md     # This file
│   └── techniques/         # Technique guides
├── memory-bank/            # Global context files
└── technique-config.json   # Technique mappings
```

## Workflow Commands

| Command | Purpose |
|---------|---------|
| /plan-feature-initial | Gather requirements, classify problem |
| /plan-feature | Create full implementation plan |
| /plan-prompts | Generate AI prompts for steps |
| /plan-next | Execute next step with phases |
| /plan-status | Check plan progress |
| /plan-verify | Re-run step verification |
| /plan-rollback | Rollback step changes |
| /plan-feature-review | Review plan quality |

## Key Design Decisions

1. **Hybrid Architecture**: Python for deterministic logic, workflows for orchestration
2. **Technique Embedding**: Full instructions embedded in step prompts
3. **File Tracking**: Created, modified, deleted, renamed per step
4. **Never Committed**: Nothing in .windsurf/ is ever committed to git
5. **Standard Library Only**: Python scripts use no external dependencies
