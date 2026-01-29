# ADR: Intelligent Feedback System with Semantic Classification

## Status
Proposed

## Context

The current planning system has several limitations:

1. **Static Technique Selection**: `technique-config.json` has hardcoded weights that never adapt. If TDD consistently fails for a certain problem type in this codebase, the system keeps recommending it.

2. **Keyword-Based Classification**: The `ProblemClassifier` uses keyword matching (~85% accuracy). Ambiguous descriptions like "Add a button to delete user data" may classify incorrectly.

3. **No Implementation-Level Tracking**: During debugging/implementation, the system doesn't track which approaches have been tried, leading to repeated failures with the same methods.

4. **Single-Agent Sequential Processing**: Complex problems are handled sequentially by one agent, missing opportunities for parallel exploration.

## Tree of Thought Analysis

### Decision 1: Feedback Data Architecture

**Options Considered**:

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Single monolithic JSON | Simple, atomic | Large file, slow load |
| B | Multiple JSON files | Organized, git-friendly | More file operations |
| C | SQLite database | Fast queries, indexes | Binary, hard to inspect |
| D | Hybrid (JSON + SQLite) | Best of both | Complex, two systems |

**Analysis**:
- Option A fails at scale (10,000+ entries = slow)
- Option C loses git visibility
- Option D adds unnecessary complexity
- Option B balances all concerns

**Selected: Option B** - Multiple JSON files organized by concern.

### Decision 2: Semantic Classification Method

**Options Considered**:

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | Claude API call | Automated, scriptable | API key, cost |
| B | Claude Code prompt (skill) | Interactive, accurate | Manual step |
| C | Local LLM | Free, offline | Less accurate, setup |
| D | Hybrid keyword + semantic | Fallback available | Complexity |

**Analysis**:
- User specified "Use Claude Code" (not API)
- User specified "Require classification before proceeding"
- This means interactive skill, not automated fallback

**Selected: Option B** - Claude Code skill (`/classify`) that:
1. Prompts Claude to classify the description
2. Shows classification with confidence
3. User confirms or corrects
4. System learns from corrections

### Decision 3: Implementation Attempt Tracking Scope

**Options Considered**:

| Option | Scope | Granularity | Use Case |
|--------|-------|-------------|----------|
| A | Per-step | Step completion | "TDD failed for this step" |
| B | Per-implementation | Each attempt within step | "Tried TDD 2x, then Reflexion" |
| C | Per-action | Individual commands/changes | "Tried fix A, then fix B" |

**Analysis**:
- Option A already exists (in progress.json)
- Option C is too granular, hard to aggregate
- Option B fills the gap: track what was tried during implementation

**Selected: Option B** - Per-implementation tracking with:
- Methods/techniques attempted
- Error messages encountered
- Time spent per attempt
- Final outcome

### Decision 4: Graph of Thought Implementation

**Options Considered**:

| Option | Mechanism | Isolation | Parallelism |
|--------|-----------|-----------|-------------|
| A | Git branches | Full (code) | Limited (manual merge) |
| B | Sub-agents (Task tool) | Context only | High (parallel calls) |
| C | Sequential exploration | None | None |

**Analysis**:
- Git branches: Heavy, slow, merge complexity
- Sub-agents: Light, fast, automatic aggregation
- Sequential: Misses the point of GoT

**Selected: Option B** - Sub-agents via Task tool:
1. Main agent defines exploration branches
2. Launches N parallel sub-agents (one per branch)
3. Each explores independently
4. Main agent aggregates results
5. Best path selected based on sub-agent outputs

### Decision 5: Learning from Classification Overrides

**Options Considered**:

| Option | Learning Speed | Stability | Effort |
|--------|---------------|-----------|--------|
| A | Immediate | May oscillate | Low |
| B | Batch (daily/weekly) | Stable | Medium |
| C | Threshold-based | Balanced | Medium |

**Analysis**:
- User specified "Yes, immediate"
- But we should prevent oscillation

**Selected: Option A with safeguards**:
- Immediate learning on override
- But classification history includes confidence decay
- Recent overrides weighted higher than old ones
- After 3 consistent overrides, high confidence in correction

## Decision

Implement a three-tier feedback system:

### Tier 1: Effectiveness Feedback Loop
- Track success/failure/attempts per technique per problem type
- Store in `technique-effectiveness.json`
- Integrate into `TechniqueSelector` after 10 samples minimum
- Adjusts selection weights dynamically

### Tier 2: Semantic Classification
- New `/classify` skill prompts Claude Code
- Stores results in `classification-history.json`
- Learns immediately from user corrections
- Requires explicit classification (no silent fallback)

### Tier 3: Advanced Techniques
- GoT with parallel sub-agents via Task tool
- Multi-agent decomposition for complex problems
- Implementation attempt tracking to avoid repetition

### Data Model

```
.claude/planning-data/
├── technique-effectiveness.json    # {problem_type: {technique: {success, fail, attempts}}}
├── classification-history.json     # [{description, classified_as, confidence, corrected_to, timestamp}]
├── implementation-attempts.json    # {step_id: [{method, error, duration, success}]}
└── plan-metrics.json               # Aggregate statistics
```

## Consequences

### Positive
- System improves with usage (self-improving)
- Higher classification accuracy via Claude understanding
- Avoids repeated failures with same methods
- Parallel exploration for complex problems
- Full visibility into planning system effectiveness

### Negative
- Additional complexity in planning workflow
- Interactive classification adds a step
- Sub-agent coordination adds failure modes
- More files to manage

### Mitigations
- Graceful degradation: empty data = use defaults
- Clear error messages when sub-agents fail
- JSON schema validation prevents corruption
- Comprehensive tests for all new components
