# Plan 007: Intelligent Feedback System with Semantic Classification

## Overview
Implement a self-improving planning system with three major capabilities:
1. **Feedback Loop** - Track technique effectiveness across plans, learn from failures
2. **Semantic Classification** - Use Claude Code for intelligent problem classification
3. **Advanced Techniques** - Graph of Thought with sub-agents, Multi-Agent Decomposition

This transforms the planning system from static configuration to dynamic, self-improving intelligence.

## Status
- **Created**: 2025-01-26
- **Status**: Not Started
- **Current Step**: 0 of 12

## Tree of Thought Analysis

### What are we building?

A three-tier enhancement to the planning system:

**Tier 1: Feedback Loop System**
- Persistent storage of technique outcomes (success/fail/attempts)
- Cross-plan learning that improves technique selection
- Implementation-level tracking (not just step-level)
- Methods-already-used tracking to avoid repetition during debugging

**Tier 2: Semantic Classification**
- Claude Code-powered classification instead of keyword matching
- Learns from user corrections immediately
- Caches results to reduce redundant processing
- Requires classification before proceeding (no silent fallback)

**Tier 3: Advanced Multi-Agent Techniques**
- Graph of Thought (GoT) with parallel sub-agents OR git branches
- Multi-Agent Decomposition for complex problems
- Enhanced technique commands that leverage these capabilities

### Why are we building it?

| Problem | Current State | After Implementation |
|---------|--------------|---------------------|
| Technique selection | Static config weights | Dynamic, learns from outcomes |
| Classification accuracy | ~85% with keywords | >95% with semantic understanding |
| Repeated failures | Same techniques retried | Tracks methods used, avoids repetition |
| Complex problems | Single-agent sequential | Multi-agent parallel exploration |

### Key Decisions

#### Decision 1: Feedback Data Storage

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Single JSON file | Simple, atomic writes | Large file over time |
| B | Multiple JSON files | Organized by type, git-friendly | More file I/O |
| C | SQLite | Fast queries, indexes | Binary file, harder to review |

**Selected: Option B** - Multiple JSON files in `.claude/planning-data/`:
- `technique-effectiveness.json` - Success/fail counts
- `classification-history.json` - Semantic cache + overrides
- `implementation-attempts.json` - Per-implementation tracking
- `plan-metrics.json` - Aggregate statistics

Rationale: Git-trackable, easy to inspect, can selectively load data.

#### Decision 2: Semantic Classification Architecture

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Direct Claude Code prompt | Simple, accurate | Interactive, manual |
| B | Command that prompts Claude | Scriptable, can cache | Slightly more complex |
| C | Python script using Claude API | Fully automated | Requires API key management |

**Selected: Option B** - Command-based with Claude Code:
- New `/classify` skill that prompts Claude for classification
- Stores result in classification history
- User confirms before proceeding
- Learns from corrections

Rationale: Leverages Claude Code's understanding without API complexity.

#### Decision 3: Graph of Thought Implementation

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Git branches | Isolated, full rollback | Merge complexity, slow |
| B | Sub-agents (Task tool) | Parallel, independent | Context limits, coordination |
| C | Hybrid | Best of both | More complex |

**Selected: Option B** - Sub-agents (Task tool):
- Launch parallel exploration agents
- Each agent explores one branch of thought
- Main agent aggregates and selects best
- No git complexity, faster iteration

Rationale: Task tool provides clean isolation without git overhead.

#### Decision 4: Minimum Sample Threshold

| Option | Samples | Learning Speed | Stability |
|--------|---------|----------------|-----------|
| A | 5 | Fast | Noisy |
| B | 10 | Balanced | Good |
| C | 20 | Slow | Very stable |

**Selected: Option B** - 10 samples before adaptation

Rationale: Balances learning speed with statistical significance.

### Testing Strategy

| Test Type | Scope | Files | Priority |
|-----------|-------|-------|----------|
| Unit | Feedback store CRUD, effectiveness calculation | `.claude/tests/feedback_store_test.py` | Required |
| Unit | Classification history, override learning | `.claude/tests/classification_test.py` | Required |
| Integration | Full feedback loop flow | `.claude/tests/integration_test.py` | Required |
| Manual | Semantic classification accuracy | Manual test cases | Required |

## Technique Matrix

**Default Implementation Technique: TDD** (unless noted otherwise)

| Step | Problem Type | Planning | Implementation | Verification | Risk | Notes |
|------|--------------|----------|----------------|--------------|------|-------|
| 1 | infrastructure | ps-plus | tdd | self-refine | low | Data structures |
| 2 | infrastructure | ps-plus | tdd | self-refine | low | Persistence layer |
| 3 | service-impl | ps-plus | tdd | reflexion | medium | Effectiveness tracker |
| 4 | service-impl | ps-plus | tdd | reflexion | medium | Implementation attempt tracker |
| 5 | refactor | tot | tdd + self-refine | reflexion | medium | Technique selector enhancement |
| 6 | new-feature | tot | self-refine | reflexion | medium | Semantic classification command (markdown) |
| 7 | service-impl | ps-plus | tdd | self-refine | medium | Classification history + learning |
| 8 | refactor | ps-plus | tdd + self-refine | reflexion | medium | Plan-next integration |
| 9 | new-feature | tot | self-refine | reflexion | high | GoT with sub-agents |
| 10 | new-feature | tot | self-refine | got | high | Multi-agent decomposition |
| 11 | documentation | ps-plus | self-refine | self-refine | low | CLI stats command |
| 12 | integration-test | ps-plus | tdd | reflexion | medium | End-to-end testing |

## Implementation Steps

| Step | Name | Description | Type | Risk | Status |
|------|------|-------------|------|------|--------|
| 1 | Feedback Data Models | Define JSON schemas and Python dataclasses | infrastructure | low | Pending |
| 2 | Feedback Persistence Layer | CRUD operations for feedback data files | infrastructure | low | Pending |
| 3 | Effectiveness Tracker | Calculate and query technique effectiveness | service-impl | medium | Pending |
| 4 | Implementation Attempt Tracker | Track methods used during implementation/debugging | service-impl | medium | Pending |
| 5 | Technique Selector Enhancement | Integrate effectiveness data into selection | refactor | medium | Pending |
| 6 | Semantic Classification Command | New /classify skill using Claude Code | new-feature | medium | Pending |
| 7 | Classification History & Learning | Store classifications, learn from overrides | service-impl | medium | Pending |
| 8 | Plan-Next Integration | Record outcomes, track implementation attempts | refactor | medium | Pending |
| 9 | Graph of Thought with Sub-Agents | Parallel exploration using Task tool | new-feature | high | Pending |
| 10 | Multi-Agent Decomposition | Complex problem decomposition | new-feature | high | Pending |
| 11 | CLI Feedback Stats | Command to view effectiveness statistics | documentation | low | Pending |
| 12 | Integration Testing | End-to-end test suite | integration-test | medium | Pending |

## Files to Create

### Data Layer
- `.claude/planning-data/technique-effectiveness.json` - Effectiveness tracking
- `.claude/planning-data/classification-history.json` - Semantic cache + overrides
- `.claude/planning-data/implementation-attempts.json` - Per-implementation tracking
- `.claude/planning-data/plan-metrics.json` - Aggregate statistics
- `.claude/schemas/feedback-data.schema.json` - JSON schema for validation

### Python Scripts
- `.claude/scripts/feedback_store.py` - Persistence layer
- `.claude/scripts/effectiveness_tracker.py` - Effectiveness calculations
- `.claude/scripts/implementation_tracker.py` - Implementation attempt tracking
- `.claude/scripts/semantic_classifier.py` - Classification with Claude integration
- `.claude/scripts/classification_history.py` - Classification learning

### Commands
- `.claude/commands/classify.md` - New /classify skill
- `.claude/commands/feedback.md` - CLI feedback stats command
- `.claude/commands/got-parallel.md` - GoT with sub-agents
- `.claude/commands/multi-agent.md` - Multi-agent decomposition

### Tests
- `.claude/tests/test_feedback_store.py` - Persistence tests
- `.claude/tests/test_effectiveness_tracker.py` - Calculation tests
- `.claude/tests/test_implementation_tracker.py` - Attempt tracking tests
- `.claude/tests/test_classification_history.py` - Learning tests
- `.claude/tests/test_integration.py` - End-to-end tests

## Files to Modify

- `.claude/scripts/technique_selector.py` - Add effectiveness integration
- `.claude/scripts/tangentle_plan.py` - Add feedback subcommand
- `.claude/commands/plan-next.md` - Add outcome recording
- `.claude/commands/plan-feature.md` - Use semantic classification
- `.claude/technique-config.json` - Add dynamic adjustment config

## Dependencies

```
Step 1 (Data Models) → Step 2 (Persistence)
Step 2 (Persistence) → Step 3 (Effectiveness) + Step 4 (Implementation Tracker)
Step 3 (Effectiveness) → Step 5 (Selector Enhancement)
Step 4 (Implementation Tracker) → Step 8 (Plan-Next Integration)
Step 5 (Selector Enhancement) → Step 8 (Plan-Next Integration)
Step 6 (Semantic Classification) → Step 7 (Classification History)
Step 7 (Classification History) → Step 8 (Plan-Next Integration)
Step 8 (Plan-Next Integration) → Step 9 (GoT) + Step 10 (Multi-Agent)
Step 9 + Step 10 → Step 11 (CLI Stats)
All Steps → Step 12 (Integration Testing)
```

## Success Criteria

- [ ] Feedback data persists across sessions in `.claude/planning-data/`
- [ ] Technique selection changes based on historical success rates (after 10 samples)
- [ ] Implementation attempts tracked - knows what methods were already tried
- [ ] Semantic classification via `/classify` command
- [ ] Classification learns from user overrides immediately
- [ ] `/feedback` command shows effectiveness statistics
- [ ] GoT parallel exploration works via sub-agents
- [ ] Multi-agent decomposition available for complex problems
- [ ] All existing tests still pass
- [ ] New tests achieve 80%+ coverage on new code

## Rollback Plan

1. **Data files**: Delete `.claude/planning-data/` directory
2. **New scripts**: Delete new Python files
3. **Modified scripts**: `git checkout` original versions
4. **Commands**: Delete new command files

The system gracefully handles missing feedback data (treats as empty/new project).

## Risk Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking existing plans | All new features are additive, existing flows unchanged |
| Feedback data corruption | JSON schema validation, atomic writes |
| Sub-agent coordination failures | Timeout handling, fallback to sequential |
| Overfitting to small samples | 10-sample minimum before adaptation |
