# Tree of Thoughts (ToT) Prompting

## Overview
Tree of Thoughts explores multiple reasoning paths as a tree structure. It generates branches for different approaches, evaluates each using scoring criteria, prunes unpromising paths, expands promising ones, and potentially backtracks when a path leads to a dead end.

This technique excels at complex decisions where multiple valid approaches exist and thorough exploration is warranted.

## When to Use
- Complex decisions with multiple valid approaches
- System design requiring exploration of alternatives
- Problems with significant uncertainty about best approach
- Architecture decisions with tradeoffs
- Exploration tasks where the solution space is large
- Any problem benefiting from explicit consideration of alternatives

## How It Works

### Root: Problem Analysis
- State the problem clearly
- Identify 3-5 high-level approaches to explore

### Level 1: Branch Exploration
- For each approach, develop the reasoning
- Evaluate: feasibility, complexity, confidence
- Mark status: EXPLORE or PRUNE

### Level 2+: Expand Best Branches
- Take promising branches deeper
- Create sub-options within each approach
- Continue evaluation and pruning

### Backtracking
- When a path hits a dead end, backtrack
- Try alternative branches that were set aside

### Convergence
- Select the winning path
- Document why alternatives were rejected
- Extract final solution

## Execution Instructions

```
## TREE OF THOUGHTS EXECUTION PROTOCOL

### Root: Initial Problem Analysis

**Problem**: [Clear statement of what needs to be solved]

**Possible high-level approaches**:
1. [Approach A]
2. [Approach B]
3. [Approach C]

---

### Level 1: Branch Exploration

#### Branch A: [Approach A Name]

**Thought**: [Reasoning for this approach]

**Evaluation**:
- Feasibility: [sure/maybe/impossible]
- Estimated complexity: [low/medium/high]
- Confidence: [0-10]

**Status**: [EXPLORE / PRUNE]

---

#### Branch B: [Approach B Name]

**Thought**: [Reasoning for this approach]

**Evaluation**:
- Feasibility: [sure/maybe/impossible]
- Estimated complexity: [low/medium/high]
- Confidence: [0-10]

**Status**: [EXPLORE / PRUNE]

---

#### Branch C: [Approach C Name]

**Thought**: [Reasoning for this approach]

**Evaluation**:
- Feasibility: [sure/maybe/impossible]
- Estimated complexity: [low/medium/high]
- Confidence: [0-10]

**Status**: [EXPLORE / PRUNE]

---

### Level 2: Expanding Best Branches

#### Branch A.1 (Expanding Branch A)

**Thought**: Taking approach A further, the next step would be...

**Sub-options**:
- A.1a: [Variant 1]
- A.1b: [Variant 2]

**Evaluation for A.1a**:
- Progress toward goal: [0-10]
- Remaining difficulty: [low/medium/high]

**Evaluation for A.1b**:
- Progress toward goal: [0-10]
- Remaining difficulty: [low/medium/high]

**Selected**: A.1[a/b] because [reason]

---

### Level 3: Deep Exploration

#### Branch A.1a.1 (Going deeper)

**Thought**: [Detailed implementation thinking]

**Partial Implementation**:
[Code or design so far]

**Evaluation**:
- Does this work so far? [yes/partial/no]
- Blockers: [Any issues encountered]

**Decision**: [CONTINUE / BACKTRACK to A.1b]

---

### Backtracking (if needed)

**Why backtracking**: [Branch A.1a hit a dead end because...]

**Returning to**: Branch A.1b

**New exploration from A.1b**:
[Continue from alternative branch]

---

### Convergence

**Winning Path**: Root → A → A.1 → A.1a → [Solution]

**Why this path won**:
- [Reason 1]
- [Reason 2]

**What we learned from pruned branches**:
- Branch C showed that [insight]
- Backtracking taught us [lesson]

---

### Final Solution

**Implementation**:
[Complete solution from winning path]

**Confidence**: [High/Medium] - we explored N alternative paths
```

## Example Application

**Task**: Design data storage for a task management app

**ToT Application**:
1. **Branches**: Core Data, SwiftData, SQLite + custom, UserDefaults
2. **Evaluation**: CloudKit sync needs → prune UserDefaults
3. **Expand**: Core Data vs SwiftData deeper analysis
4. **Backtrack**: SwiftData lacks needed migration support
5. **Converge**: Core Data selected with clear rationale

## Common Pitfalls
- Not exploring enough initial branches
- Pruning too aggressively before adequate evaluation
- Failing to backtrack when a path clearly fails
- Not documenting why branches were pruned
- Going too deep without checking alternatives
- Losing track of branch hierarchy

## Verification Checklist
- [ ] Multiple approaches identified at root
- [ ] Each branch evaluated with consistent criteria
- [ ] Pruning decisions documented with rationale
- [ ] Promising branches expanded to sufficient depth
- [ ] Backtracking attempted when paths fail
- [ ] Final path selected with clear reasoning
- [ ] Learnings from rejected branches captured
