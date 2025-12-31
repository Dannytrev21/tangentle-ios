# Plan 004: Intelligent Planning System v2

## Overview
A comprehensive upgrade to the Claude Code planning system that automatically selects and applies optimal prompt engineering techniques based on problem type and workflow phase, with composable techniques, risk-based self-correction, and full CLI tooling.

## Status
- **Created**: 2025-12-24
- **Status**: Not Started
- **Current Step**: 0 of 15

## Tree of Thought Analysis

### What are we building?
An intelligent meta-planning system that:
1. **Classifies problems** into 20+ types (debug, ui, algorithm, infrastructure, etc.)
2. **Selects techniques** from 10 prompt engineering methods (ToT, TDD, Reflexion, etc.)
3. **Composes techniques** across phases (planning → implementation → verification)
4. **Self-corrects** based on risk level (low-risk: 2+1 retries, high-risk: full Reflexion)
5. **Provides tooling** via Python scripts and CLI for orchestration

### Why are we building it?
- **Consistency**: Remove human decision-making about which technique to use
- **Quality**: Apply proven prompt engineering systematically
- **Efficiency**: Match technique complexity to problem complexity
- **Self-healing**: Automatically recover from failures without user intervention
- **Learning**: Log technique selections for future optimization

### Key Decisions

#### Decision 1: Problem Type Taxonomy

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Original 10 types (debug, ui, etc.) | Simple, easy to classify | Many steps don't fit cleanly |
| B | Expanded 20 types (add infrastructure, animation, etc.) | Better coverage | More rules to maintain |
| C | Hierarchical (5 categories with subtypes) | Balanced complexity | Requires 2-level classification |

**Selected: Option C** - Hierarchical taxonomy with 5 parent categories and 20+ subtypes. This balances precision with maintainability.

**Taxonomy**:
```
FOUNDATION (infrastructure, scaffolding, configuration)
DATA (data-modeling, data-access, migration, state-mgmt)
ARCHITECTURE (system-design, protocol-design, di-setup, service-impl, refactor)
UI/UX (ui, component-lib, design-tokens, animation, gesture, accessibility, polish)
TESTING (test-setup, unit-test, integration-test, snapshot-test, e2e-test, performance-test)
LOGIC (algorithm, validation, api-integration, debug)
DOCUMENTATION (documentation, changelog)
```

#### Decision 2: Technique Selection Architecture

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Static JSON mapping | Simple, fast | No contextual adaptation |
| B | Rule-based Python script | Flexible, debuggable | Requires maintenance |
| C | LLM-based selection | Most adaptive | Expensive, unpredictable |
| D | Hybrid: JSON defaults + Python overrides | Best of both | Slightly complex |

**Selected: Option D** - Hybrid approach with JSON defaults that Python can override based on step context (complexity score, dependencies, risk level).

#### Decision 3: Technique Composition Model

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Single technique per step | Simple execution | Less flexible |
| B | Sequential composition (A → B → C) | Clear ordering | May be overkill |
| C | Phase-based (plan/implement/verify) | Natural mapping | Medium complexity |
| D | Weighted ensemble (primary + modifiers) | Most powerful | Complex orchestration |

**Selected: Option C** - Phase-based composition where each step has distinct techniques for planning, implementation, and verification phases.

#### Decision 4: Self-Correction Strategy

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Fixed 3 retries for all | Simple | Wasteful or insufficient |
| B | Risk-based depth | Appropriate effort | Needs risk assessment |
| C | Cost-aware adaptive | Efficient | Complex tracking |

**Selected: Option B** - Risk-based with clear rules:
- **Low-risk** (FOUNDATION, DOCUMENTATION): 2 retries same technique, 1 alternative
- **Medium-risk** (DATA, UI/UX): 3 retries with technique rotation
- **High-risk** (ARCHITECTURE, TESTING, LOGIC): Full Reflexion loop (up to 5 attempts with technique switching)

#### Decision 5: CLI Tooling Approach

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Pure .md commands only | No new dependencies | Limited orchestration |
| B | Python CLI wrapper | Rich features | Adds Python dependency |
| C | Both: .md calls Python scripts | Best UX | More files to maintain |

**Selected: Option C** - Claude commands (`.md`) remain the interface, but they invoke Python scripts for complex logic (technique selection, progress tracking, risk assessment).

### Technique Mapping Matrix

Based on problem types and phases, here's the complete technique mapping:

| Problem Type | Planning | Implementation | Verification |
|--------------|----------|----------------|--------------|
| **FOUNDATION** | | | |
| infrastructure | PS+ | Least-to-Most | Self-Refine |
| scaffolding | PS+ | Chain-of-Code | Self-Refine |
| configuration | ReAct | Self-Refine | TDD |
| **DATA** | | | |
| data-modeling | ToT | Least-to-Most | Self-Consistency |
| data-access | PS+ | TDD | Reflexion |
| migration | Least-to-Most | Chain-of-Code | Reflexion |
| state-mgmt | ToT | TDD | Reflexion |
| **ARCHITECTURE** | | | |
| system-design | ToT | Self-Consistency | GoT |
| protocol-design | GoT | Self-Refine | Self-Consistency |
| di-setup | PS+ | Least-to-Most | TDD |
| service-impl | PS+ | TDD + Self-Refine | Reflexion |
| refactor | PS+ | Self-Refine | TDD |
| **UI/UX** | | | |
| ui | PS+ | Self-Refine | Manual + Visual |
| component-lib | ToT | Self-Refine | Snapshot |
| design-tokens | PS+ | Self-Refine | Self-Refine |
| animation | GoT | Self-Refine | Manual |
| gesture | ToT | Chain-of-Code | Manual |
| accessibility | PS+ | TDD | Reflexion |
| polish | ReAct | Self-Refine | Manual |
| **TESTING** | | | |
| test-setup | PS+ | Chain-of-Code | Self-Refine |
| unit-test | PS+ | TDD | Self-Refine |
| integration-test | Least-to-Most | TDD | Reflexion |
| snapshot-test | PS+ | Self-Refine | Manual |
| e2e-test | Least-to-Most | Chain-of-Code | Reflexion |
| performance-test | ToT | TDD | Self-Consistency |
| **LOGIC** | | | |
| algorithm | Self-Consistency | TDD | Reflexion |
| validation | PS+ | TDD | Self-Refine |
| api-integration | ReAct | Chain-of-Code | Reflexion |
| debug | ReAct | Reflexion | Self-Refine |
| **DOCUMENTATION** | | | |
| documentation | PS+ | Self-Refine | GoT |
| changelog | PS+ | Self-Refine | Self-Refine |
| **META** | | | |
| ideation | ToT | Self-Consistency | GoT |
| new-feature | ToT | TDD + Self-Refine | Reflexion |

### Testing Strategy

| Test Type | Scope | Files | Priority |
|-----------|-------|-------|----------|
| Unit | Technique selector logic, risk assessment | TangentleTests/Unit/Planning/ | Required |
| Integration | Full workflow: classify → select → execute | TangentleTests/Integration/ | Required |
| Manual | Verify technique selection quality | N/A | Required |

## Implementation Steps

| Step | Name | Description | Status | Risk |
|------|------|-------------|--------|------|
| 1 | Technique Config Schema | Define JSON schema + all dataclass interfaces | Pending | Low |
| 2 | Problem Classifier Script | Python script to classify problem types | Pending | Medium |
| 3 | Technique Selector Script | Python script to select techniques based on context | Pending | Medium |
| 4 | Risk Assessor Script | Python script to assess step risk levels | Pending | Medium |
| 5 | CLI Orchestrator | Python CLI tool (`tangentle-plan`) | Pending | Medium |
| 6 | Update plan-feature-initial | Add problem type detection and confirmation | Pending | Low |
| 7 | Update plan-feature | Embed technique selection in plan creation | Pending | Medium |
| 8a | Technique Template Extraction | Extract/structure existing technique templates | Pending | Medium |
| 8b | Prompt Embedding | Generate technique-aware prompts | Pending | High |
| 9 | Update plan-next | Execute with composable techniques | Pending | High |
| 10 | Update plan-verify | Technique-aware verification | Pending | Medium |
| 11 | Update plan-rollback | Handle technique state on rollback | Pending | Low |
| 12 | Update plan-feature-review | Review technique selections | Pending | Medium |
| 13 | Self-Correction Engine | Implement Reflexion loop for high-risk steps | Pending | High |
| 14 | Documentation & Testing | Write docs, integration tests, smoke tests | Pending | Low |

## Files to Create

| Path | Description |
|------|-------------|
| `.claude/technique-config.json` | Default technique mappings |
| `.claude/scripts/problem_classifier.py` | Classifies problem descriptions |
| `.claude/scripts/technique_selector.py` | Selects techniques based on problem + context |
| `.claude/scripts/risk_assessor.py` | Assesses step risk level |
| `.claude/scripts/tangentle_plan.py` | CLI orchestrator |
| `.claude/scripts/reflexion_engine.py` | Self-correction loop implementation |
| `.claude/scripts/__init__.py` | Package init |
| `.claude/scripts/utils.py` | Shared utilities |

## Files to Modify

| Path | Changes |
|------|---------|
| `.claude/commands/plan-feature-initial.md` | Add problem type detection |
| `.claude/commands/plan-feature.md` | Embed technique selection |
| `.claude/commands/plan-prompts.md` | Generate technique-embedded prompts |
| `.claude/commands/plan-next.md` | Execute with technique phases |
| `.claude/commands/plan-verify.md` | Technique-aware verification |
| `.claude/commands/plan-rollback.md` | Reset technique state |
| `.claude/commands/plan-feature-review.md` | Review technique choices |
| `CLAUDE.md` | Document new planning system |

## Dependencies

```
Step 1 → Steps 2, 3, 4 (Config required for scripts)
Steps 2, 3, 4 → Step 5 (Scripts required for CLI)
Steps 1-5 → Steps 6-12 (Infrastructure before commands)
Step 8 → Step 9 (Prompts before execution)
Steps 6-12 → Step 13 (Commands before self-correction)
Steps 1-13 → Step 14 (All before docs)
```

## Success Criteria

- [ ] Problem types auto-classify with >90% accuracy
- [ ] Technique selection is deterministic and explainable
- [ ] Composable techniques work across phases
- [ ] Self-correction recovers from failures automatically
- [ ] Risk-based retry depth works correctly
- [ ] CLI tooling is intuitive and reliable
- [ ] All existing `/plan-*` commands continue to work
- [ ] Technique rationale is logged to context.md
- [ ] Full documentation in CLAUDE.md

## Rollback Plan

1. **Per-step rollback**: Each step creates isolated files
2. **Full rollback**: Revert `.claude/commands/` to pre-modification state
3. **Preserved originals**: Backup existing commands before modification
4. **Gradual rollout**: New system uses different progress.json schema, old plans unaffected

## Revision History

| Date | Changes |
|------|---------|
| 2025-12-24 | Initial plan created |
