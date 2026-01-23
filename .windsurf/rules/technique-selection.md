---
trigger: model_decision
description: Apply when Cascade needs to select between Tree of Thoughts and Graph of Thoughts reasoning techniques
---

# ToT vs GoT Selection Guide

When analyzing complex problems, select the appropriate reasoning technique:

## Tree of Thoughts (ToT)

**Use when**:
- Exploring multiple approaches to a problem
- Making architecture or design decisions
- Evaluating alternatives with tradeoffs
- Building new features with uncertain requirements
- The problem space is large and unexplored

**How it works**:
1. Branch: Generate 3-5 high-level approaches
2. Evaluate: Score each on feasibility, complexity, confidence
3. Prune: Eliminate low-scoring paths
4. Expand: Develop promising branches deeper
5. Backtrack: If a path fails, try alternatives
6. Converge: Select winning path with rationale

**Categories that default to ToT**:
FOUNDATION, DATA, ARCHITECTURE, UI_UX, LOGIC, META

## Graph of Thoughts (GoT)

**Use when**:
- Synthesizing information from multiple sources
- Aggregating findings or feedback
- Reviewing and verifying work
- Merging perspectives into unified output
- The task is about combination, not exploration

**How it works**:
1. Initialize: Create thought nodes for each perspective
2. Expand: Develop each node independently
3. Aggregate: Merge compatible insights
4. Prune: Remove low-scoring paths
5. Refine: Iterate on merged solutions
6. Converge: Output synthesized result

**Categories that default to GoT**:
TESTING, DOCUMENTATION

## Characteristic Overrides

These characteristics override category defaults:

| Characteristic | Selects | Example |
|----------------|---------|---------|
| `requires_synthesis` | GoT | "Merge all feedback into spec" |
| `exploration_needed` | ToT | "Explore ways to implement" |
| `multiple_approaches` | ToT | "Could use A, B, or C" |
| `review_task` | GoT | "Review this plan for issues" |
| `new_design` | ToT | "Design a new system for X" |

## CLI Command

```bash
python3 .windsurf/scripts/windsurf_plan.py reasoning {problem_type} {category}
# Returns: tot or got with rationale
```
