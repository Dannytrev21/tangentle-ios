# Plan 001: Dynamic ToT/GoT Selection & Windsurf Rules Integration

## Overview
Enhance the Windsurf planning system with dynamic selection between Tree of Thoughts (ToT) and Graph of Thoughts (GoT) based on problem characteristics. Additionally, introduce Windsurf rules to offload common patterns from workflows, freeing up character budget for the enhanced selection logic.

## Status
- **Created**: 2026-01-04
- **Status**: Not Started
- **Current Step**: 0 of 6
- **Problem Type**: refactor (Category: ARCHITECTURE)

## Tree of Thought Analysis

### What are we building?
A dynamic reasoning technique selector that:
1. Analyzes problem characteristics to choose between ToT and GoT
2. Integrates selection into `/plan-feature-initial` and `/plan-feature` workflows
3. Uses Windsurf rules to offload common patterns, staying under 12K char limits

### Why are we building it?
- **ToT** excels at exploration and decision-making with multiple valid paths
- **GoT** excels at synthesis, merging perspectives, and verification tasks
- Currently the workflows use ToT for everything, missing optimization opportunities
- Character budget is tight; rules can offload ~3-4K of content

### Key Decisions

#### Decision 1: Where to implement selection logic

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Python script only | Clean separation, testable, reusable | Requires CLI call in workflow |
| B | Inline in workflows | Self-contained, no dependencies | Duplicates logic, uses char budget |
| C | Python + rules reference | Python for logic, rules for patterns | Best of both, adds complexity |

**Selected: Option C** - Python script handles classification logic (select_reasoning_technique), rules document the criteria for Model Decision activation. This maximizes testability while keeping workflows lean.

#### Decision 2: ToT vs GoT selection criteria

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Category-based only | Simple, predictable | Misses nuanced cases |
| B | Characteristic-based | More accurate | Requires keyword analysis |
| C | Hybrid: category + characteristics | Best accuracy | More complex implementation |

**Selected: Option C** - Use category as default, allow characteristic keywords to override. This provides predictable defaults with flexibility for nuanced cases.

Selection criteria:
| Characteristic | ToT | GoT |
|----------------|-----|-----|
| Exploration needed | Yes | No |
| Multiple valid approaches | Yes | Merge |
| Synthesis/aggregation | No | Yes |
| Review/verification | Sometimes | Yes |
| New design decision | Yes | Sometimes |

Category defaults:
| Category | Default Technique |
|----------|-------------------|
| FOUNDATION | ToT |
| DATA | ToT |
| ARCHITECTURE | ToT |
| UI_UX | ToT |
| TESTING | GoT |
| LOGIC | ToT |
| DOCUMENTATION | GoT |
| META | ToT |

#### Decision 3: Rules architecture

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | One big rule file | Simple structure | Hits 6K limit fast |
| B | Multiple focused rules | Modular, targeted activation | More files to manage |
| C | Layered rules (global + workspace) | Flexibility for different projects | Complexity |

**Selected: Option B** - Create focused rules:
- `plan-conventions.md` (Always On) - Core planning conventions
- `technique-selection.md` (Model Decision) - When to use ToT/GoT
- `no-staging.md` (Glob: `.windsurf/**`) - Prevent .windsurf commits

#### Decision 4: Character budget allocation

| Component | Current | After Changes | Limit |
|-----------|---------|---------------|-------|
| plan-feature-initial.md | 6,709 | ~8,000 | 12,000 |
| plan-feature.md | 7,960 | ~9,000 | 12,000 |
| plan-conventions.md | 0 | ~3,000 | 6,000 |
| technique-selection.md | 0 | ~2,500 | 6,000 |
| no-staging.md | 0 | ~500 | 6,000 |
| **Rules Total** | 0 | ~6,000 | 12,000 |

Strategy: Move common patterns (question categories, quality standards, error recovery) to rules, add ToT/GoT selection logic to workflows.

## Technique Matrix

| Step | Problem Type | Planning | Implementation | Verification | Risk |
|------|--------------|----------|----------------|--------------|------|
| 1 | service-impl | ps-plus | tdd | reflexion | medium |
| 2 | service-impl | ps-plus | self-refine | tdd | medium |
| 3 | service-impl | ps-plus | self-refine | tdd | medium |
| 4 | infrastructure | ps-plus | least-to-most | self-refine | low |
| 5 | infrastructure | ps-plus | least-to-most | self-refine | low |
| 6 | integration-test | ps-plus | tdd | reflexion | medium |

## Implementation Steps

| Step | Name | Description | Type | Risk | Status |
|------|------|-------------|------|------|--------|
| 1 | Python Reasoning Technique Selector | Add select_reasoning_technique() to technique_selector.py with ToT/GoT selection logic | service-impl | medium | Pending |
| 2 | Update plan-feature-initial | Add dynamic ToT/GoT selection, offload content to rules | service-impl | medium | Pending |
| 3 | Update plan-feature | Add dynamic ToT/GoT selection, offload content to rules | service-impl | medium | Pending |
| 4 | Create Windsurf Rules | Create plan-conventions.md, technique-selection.md, no-staging.md | infrastructure | low | Pending |
| 5 | Update Knowledge Base | Add ToT/GoT selection criteria documentation | infrastructure | low | Pending |
| 6 | Integration Testing | Test workflows end-to-end with various problem types | integration-test | medium | Pending |

## Files to Create
- `.windsurf/rules/plan-conventions.md` - Always On rule with planning conventions
- `.windsurf/rules/technique-selection.md` - Model Decision rule for technique guidance
- `.windsurf/rules/no-staging.md` - Glob rule to prevent .windsurf staging
- `.windsurf/knowledge/techniques/reasoning-selection.md` - ToT vs GoT selection guide

## Files to Modify
- `.windsurf/scripts/technique_selector.py` - Add select_reasoning_technique()
- `.windsurf/scripts/tests/test_technique_selector.py` - Tests for new function
- `.windsurf/workflows/plan-feature-initial.md` - Add selection, trim content
- `.windsurf/workflows/plan-feature.md` - Add selection, trim content

## Dependencies
- Step 1 must complete before Steps 2-3 (provides selection function)
- Step 4 must complete before Steps 2-3 (provides rules to reference)
- Steps 2-3 can run in parallel after Steps 1, 4
- Step 5 can run in parallel with Steps 2-3
- Step 6 depends on all other steps

## Success Criteria
- [ ] `select_reasoning_technique()` correctly returns ToT or GoT based on problem
- [ ] `/plan-feature-initial` dynamically selects ToT or GoT
- [ ] `/plan-feature` dynamically selects ToT or GoT
- [ ] 3 Windsurf rules created and load correctly
- [ ] Workflows remain under 12K character limit
- [ ] Rules remain under 6K each, 12K total
- [ ] All new functions have unit tests
- [ ] Integration test confirms end-to-end flow

## Rollback Plan
1. Revert workflow changes using git
2. Remove new rules from `.windsurf/rules/`
3. Revert technique_selector.py changes
4. System returns to always-ToT behavior

## Revision History

| Date | Changes |
|------|---------|
| 2026-01-10 | Plan review: Clarified CLI command creation in Step 1, added fallback behavior to Steps 2-3, fixed import paths in Step 6 |
| 2026-01-04 | Initial plan creation |
