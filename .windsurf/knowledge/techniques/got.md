# Graph of Thoughts (GoT) Prompting

## Overview
Graph of Thoughts models reasoning as a graph rather than a tree, allowing thoughts to branch, merge, loop back, and aggregate. This enables more complex reasoning patterns than linear chains or trees, particularly when insights from multiple paths can be combined.

This technique excels at synthesis tasks where merging diverse perspectives produces better results.

## When to Use
- Merging ideas from multiple sources or approaches
- Documentation review requiring holistic assessment
- Protocol design where multiple concerns must be balanced
- Refinement through aggregation of feedback
- Any problem where combining insights yields better solutions
- Complex verification requiring multi-path analysis

## How It Works

### Graph Initialization
- Create thought nodes for initial approaches
- Establish connections between related thoughts
- Assign scores to each node

### Graph Transformations
1. **Expansion**: Generate new thoughts from existing ones
2. **Aggregation**: Merge compatible thoughts into synthesized insights
3. **Pruning**: Remove low-scoring paths
4. **Refinement Loop**: Iterate on a thought to improve it

### Convergence
- Follow the path through the graph to the final solution
- Document how aggregation improved over individual paths

## Execution Instructions

```
## GRAPH OF THOUGHTS EXECUTION PROTOCOL

### Graph Initialization

#### Thought Nodes (Initial)

**T1** [Root]: Problem understanding
- Content: [Initial problem analysis]
- Score: -
- Connections: → T2, T3, T4

**T2** [Branch A]: First approach
- Content: [Approach A reasoning]
- Score: [0-10]
- Connections: → T5

**T3** [Branch B]: Second approach
- Content: [Approach B reasoning]
- Score: [0-10]
- Connections: → T6

**T4** [Branch C]: Third approach
- Content: [Approach C reasoning]
- Score: [0-10]
- Connections: → T7

---

### Graph Transformations

#### Transformation 1: Expansion (Generate new thoughts)

**T5** [Expanding T2]:
- Content: [Detailed exploration of approach A]
- Score: [0-10]
- Connections: → T8

**T6** [Expanding T3]:
- Content: [Detailed exploration of approach B]
- Score: [0-10]
- Connections: → T8  ← Both T5 and T6 lead to T8!

**T7** [Expanding T4]:
- Content: [Detailed exploration of approach C]
- Score: [0-10]
- Connections: [PRUNED - score too low]

---

#### Transformation 2: Aggregation (Merge thoughts)

**T8** [Merging T5 + T6]:
- Content: Both approaches A and B have merit. Combining strengths:
  - From A: [Key insight]
  - From B: [Key insight]
  - Combined: [Synthesized approach]
- Score: [0-10] (higher than T5 or T6 alone)
- Connections: → T9

---

#### Transformation 3: Refinement Loop (Enhance thought)

**T9** [Refining T8 - Iteration 1]:
- Content: [First refinement of merged approach]
- Feedback: [What could be improved]
- Score: [0-10]
- Connections: → T10

**T10** [Refining T9 - Iteration 2]:
- Content: [Second refinement incorporating feedback]
- Score: [0-10]
- Connections: → T11 (or back to T9 if score dropped)

**T11** [Final]:
- Content: [Final refined solution]
- Score: [0-10]
- Connections: → SOLUTION

---

### Graph Visualization

```
        T1 (Root)
       /  |  \
      T2  T3  T4
      |   |    X (pruned)
      T5  T6
       \  /
        T8 (merge)
         |
        T9 (refine)
         |
        T10 (refine)
         |
        T11 (final)
```

---

### Scoring Summary

| Node | Score | Status |
|------|-------|--------|
| T2 | 6/10 | Explored |
| T3 | 7/10 | Explored |
| T4 | 3/10 | Pruned |
| T5 | 7/10 | Merged |
| T6 | 7/10 | Merged |
| T8 | 8/10 | Refined |
| T11 | 9/10 | **Final** |

---

### Key Graph Operations Used

1. **Branching** (T1 → T2, T3, T4): Explored multiple approaches
2. **Pruning** (T4 eliminated): Removed low-scoring path
3. **Aggregation** (T5 + T6 → T8): Merged insights
4. **Refinement Loop** (T8 → T9 → T10 → T11): Iteratively improved

---

### Final Solution

**From Node T11**:
[Final implementation]

**Why this is better than any single branch**:
- Incorporated [insight from A]
- Combined with [insight from B]
- Refined through [N] iterations
- Final score [X/10] vs best single branch [Y/10]
```

## Example Application

**Task**: Review a plan document for completeness

**GoT Application**:
1. **Branch**: Check completeness, sequencing, granularity
2. **Expand**: Deep analysis of each dimension
3. **Aggregate**: Combine findings into holistic assessment
4. **Refine**: Prioritize recommendations
5. **Final**: Unified review with weighted recommendations

## Common Pitfalls
- Creating too many nodes without evaluation
- Not leveraging aggregation (treating as tree instead of graph)
- Forgetting to loop back for refinement
- Losing track of node connections
- Not scoring consistently across nodes
- Over-complicating the graph structure

## Verification Checklist
- [ ] Multiple initial thought nodes created
- [ ] Connections between nodes explicitly tracked
- [ ] Aggregation used to merge compatible insights
- [ ] Refinement loops applied to improve solutions
- [ ] Low-scoring nodes pruned appropriately
- [ ] Final solution better than any individual path
- [ ] Graph visualization shows reasoning structure
