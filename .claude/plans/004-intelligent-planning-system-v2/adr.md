# ADR: Intelligent Planning System v2

## Status
Proposed

## Context
The current planning system (`/plan-feature`, `/plan-prompts`, `/plan-next`, etc.) uses generic prompts for all steps regardless of the problem type. We have 10 specialized prompt engineering techniques available:

- **ToT (Tree of Thoughts)**: Explore multiple reasoning paths, prune unpromising branches
- **GoT (Graph of Thoughts)**: Model reasoning as a graph with branching, merging, refinement
- **Reflexion**: Learn from failures with memory bank, retry with accumulated wisdom
- **Self-Consistency**: Generate multiple solutions, vote on best
- **Self-Refine**: Iterative feedback and refinement
- **TDD**: Test-first development with RED-GREEN-REFACTOR
- **ReAct**: Interleaved reasoning and action with observation
- **PS+ (Plan-and-Solve Plus)**: Detailed planning with intermediate verification
- **Chain-of-Code**: Mix executable code with semantic reasoning
- **Least-to-Most**: Decompose into subproblems, solve sequentially

Different problem types benefit from different techniques. A debugging task benefits from ReAct (observe → reason → act), while algorithm development benefits from TDD. Currently, users must manually choose techniques or use suboptimal generic prompts.

## Tree of Thought Analysis

### Branch 1: Problem Classification Approach

**Option 1A: Keywords-based classification**
- Scan problem description for keywords ("fix", "add", "refactor")
- Fast, simple, no LLM call
- But: High false positive rate, misses context

**Option 1B: LLM-based classification with confirmation**
- Claude analyzes the problem description
- Returns top-3 likely types with confidence
- User confirms or overrides
- More accurate, but adds a step

**Option 1C: Explicit user tagging**
- User specifies `--type=debug` in command
- Most accurate, but cognitive load on user
- Defeats purpose of "automatic" system

**Selected: 1B** - LLM classification with hybrid confirmation. Best accuracy while reducing user burden. Confirmation step adds minimal friction but prevents misclassification cascades.

### Branch 2: Technique Selection Granularity

**Option 2A: One technique per problem type**
- Simple: debug → Reflexion, ui → Self-Refine
- Easy to implement
- But: Ignores step-level variation

**Option 2B: One technique per step**
- Each step in a plan gets its own technique
- More nuanced
- But: Same technique for plan/implement/verify phases

**Option 2C: Technique per step per phase**
- Each step has: planning technique, implementation technique, verification technique
- Maximum flexibility
- More complex orchestration

**Option 2D: Primary technique + modifiers**
- Each step has a primary technique
- Modifiers add constraints (e.g., TDD + accessibility-first)
- Powerful but complex

**Selected: 2C** - Phase-based technique composition. Natural fit for how work actually happens: plan → implement → verify. Each phase has different needs (ToT for planning, TDD for implementation, Reflexion for verification).

### Branch 3: Self-Correction Depth

**Option 3A: Fixed retry count**
- All steps get 3 retries
- Simple to implement
- But: Wasteful for simple steps, insufficient for complex

**Option 3B: Risk-based depth**
- Assess step risk (high/medium/low)
- High-risk: Full Reflexion loop (5 attempts)
- Low-risk: Quick retry (2 attempts)
- Requires risk assessment logic

**Option 3C: Cost-aware adaptive**
- Track API costs per step
- Auto-scale retries based on budget
- Complex, requires cost tracking

**Option 3D: Outcome-based escalation**
- Start minimal, escalate on failure patterns
- If first failure → retry same technique
- If second failure → switch technique
- If third failure → escalate to user

**Selected: 3B + 3D hybrid** - Risk-based with escalation. Assess risk upfront to set retry budget, then follow escalation pattern within that budget. High-risk steps get full Reflexion, low-risk get 2+1.

### Branch 4: Tooling Architecture

**Option 4A: Pure markdown commands**
- All logic embedded in `.md` files
- No new dependencies
- But: Repetitive, hard to maintain

**Option 4B: Python scripts called by commands**
- `.md` commands invoke Python scripts
- Scripts handle: classification, selection, tracking
- Best of both: simple interface, rich backend

**Option 4C: Standalone Python CLI**
- Replace Claude commands with Python CLI
- Full control over UX
- But: Breaks existing muscle memory

**Option 4D: Hybrid with fallback**
- Python scripts when available
- Fallback to inline logic if scripts fail
- Most robust but complex

**Selected: 4B** - Python scripts invoked by markdown commands. Keeps familiar interface (`/plan-feature`, `/plan-next`) while enabling complex logic in maintainable Python code.

### Branch 5: Configuration Management

**Option 5A: Hardcoded in scripts**
- Technique mappings in Python code
- Simple but inflexible
- Changes require code edits

**Option 5B: JSON configuration file**
- `.claude/technique-config.json`
- Easy to customize per-project
- Can version control separately

**Option 5C: Hierarchical config**
- Default config in package
- Project config overrides
- User config overrides project
- Most flexible, more complex

**Selected: 5B** - Single JSON config at `.claude/technique-config.json`. Provides customization without complexity. Can add hierarchy later if needed.

## Decision

Implement an intelligent planning system with:

1. **Hierarchical problem taxonomy** with 7 categories and 22+ subtypes
2. **LLM-based classification** with user confirmation
3. **Phase-based technique composition** (plan/implement/verify)
4. **Risk-based self-correction** with escalation patterns
5. **Python scripts** invoked by markdown commands
6. **JSON configuration** for technique mappings

## Consequences

### Positive
- Consistent high-quality prompt engineering across all plans
- Reduced cognitive load on users (no technique selection needed)
- Self-correcting behavior reduces manual intervention
- Extensible via JSON config and Python scripts
- Preserves existing command interface

### Negative
- Adds Python dependency to planning workflow
- More complex than current system
- Initial calibration of technique mappings required
- Classification errors could cascade (mitigated by confirmation)

### Mitigations
- Python scripts fail gracefully to inline behavior
- User confirmation catches classification errors early
- Technique mappings are visible in JSON, easily adjusted
- Risk assessment is transparent (logged to context.md)
- Full backward compatibility with existing plans
