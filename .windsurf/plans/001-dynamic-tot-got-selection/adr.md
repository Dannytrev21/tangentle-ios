# ADR: Dynamic ToT/GoT Selection & Windsurf Rules Integration

## Status
Proposed

## Context
The Windsurf planning system currently uses Tree of Thoughts (ToT) uniformly for requirements analysis (`/plan-feature-initial`) and plan creation (`/plan-feature`). However:

1. **ToT vs GoT have different strengths**:
   - ToT excels at exploration, branching decisions, and evaluating multiple approaches
   - GoT excels at synthesis, aggregation, merging perspectives, and verification

2. **Character budget pressure**: Workflows have a 12K character limit. Current sizes:
   - plan-feature-initial.md: 6,709 chars (56% used)
   - plan-feature.md: 7,960 chars (66% used)
   Adding selection logic requires freeing space.

3. **Windsurf rules unused**: The `.windsurf/rules/` directory exists but is empty. Rules can:
   - Be "Always On" (every conversation)
   - Use "Model Decision" (AI decides when to apply)
   - Use "Glob" patterns (file-based activation)
   - Offload common patterns from workflows

## Tree of Thought Analysis

### Decision 1: Selection Logic Location

**Branch A: Python script only**
- Add `select_reasoning_technique()` to technique_selector.py
- Workflows call CLI: `python3 windsurf_plan.py reasoning {type}`
- Pros: Testable, reusable, single source of truth
- Cons: Adds CLI dependency, slight overhead

**Branch B: Inline in workflows**
- Embed selection logic directly in workflow markdown
- Pros: Self-contained, no external dependencies
- Cons: Duplicates logic, consumes character budget

**Branch C: Python + rules reference (SELECTED)**
- Python for selection logic (testable, maintainable)
- Rules document criteria (Model Decision can trigger guidance)
- Pros: Best of both, maximizes testability, rules enhance context
- Cons: Two places to update if criteria change

**Selection: Branch C** - Provides testable logic in Python while leveraging rules for contextual guidance.

### Decision 2: ToT vs GoT Selection Criteria

**Evaluated approaches**:
1. Category-only: Too rigid, misses nuanced cases
2. Characteristic-only: Too complex, unpredictable
3. Hybrid: Category defaults + characteristic overrides (SELECTED)

**Final criteria**:

| Characteristic | ToT | GoT |
|----------------|-----|-----|
| Exploration needed | Yes | No |
| Multiple valid approaches | Yes | Merge |
| Synthesis/aggregation | No | Yes |
| Review/verification | Sometimes | Yes |
| New design decision | Yes | Sometimes |

| Category | Default | Rationale |
|----------|---------|-----------|
| FOUNDATION | ToT | Infrastructure decisions need exploration |
| DATA | ToT | Data models benefit from approach exploration |
| ARCHITECTURE | ToT | Architecture requires evaluating alternatives |
| UI_UX | ToT | UI decisions have multiple valid approaches |
| TESTING | GoT | Tests verify and synthesize requirements |
| LOGIC | ToT | Algorithms need exploration |
| DOCUMENTATION | GoT | Docs synthesize and aggregate information |
| META | ToT | Meta-decisions need exploration |

### Decision 3: Rules Architecture

**Option A: Monolithic rule** - One large file
- Cons: Hits 6K limit, inflexible activation

**Option B: Focused rules (SELECTED)**
- `plan-conventions.md` (Always On): Core conventions always applied
- `technique-selection.md` (Model Decision): AI applies when reasoning needed
- `no-staging.md` (Glob: `.windsurf/**`): Prevents .windsurf staging

**Option C: Layered rules**
- Global + workspace separation
- Cons: Overkill for this use case

### Decision 4: Character Budget Strategy

Move these from workflows to rules:
- Question categories (Scope, UX, Data, Technical, etc.)
- Quality standards for steps and testing
- Common error recovery patterns

Keep in workflows:
- Core step-by-step instructions
- Dynamic selection logic
- Output formats

## Decision

Implement hybrid approach:
1. **Python module** (`technique_selector.py`) gains `select_reasoning_technique()` function
2. **Workflows** updated to call selection function and use appropriate technique
3. **Rules created**:
   - `plan-conventions.md`: Core conventions (Always On)
   - `technique-selection.md`: ToT/GoT guidance (Model Decision)
   - `no-staging.md`: Prevent .windsurf commits (Glob)
4. **Content offloaded** from workflows to rules for character budget

## Consequences

### Positive
- **Optimized reasoning**: ToT for exploration, GoT for synthesis
- **Testable logic**: Selection function has unit tests
- **Character headroom**: Offloading to rules frees ~2K chars per workflow
- **Rules foundation**: First rules establish pattern for future use
- **Maintainable**: Criteria in one place (Python), documentation in another (rules)

### Negative
- **Complexity**: More moving parts (Python + rules + workflows)
- **Breaking change**: Not backward compatible with existing behavior
- **Learning curve**: Users must understand ToT vs GoT distinction

### Mitigations
- **Complexity**: Clear documentation and integration tests
- **Breaking change**: Explicitly noted in plan (no backward compat required)
- **Learning curve**: Rules include explanatory guidance
