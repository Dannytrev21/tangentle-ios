# Tree of Thoughts (ToT) Prompting

## Task: $ARGUMENTS

## Instructions

I will explore multiple reasoning paths as a tree, evaluate each branch, prune unpromising ones, and potentially backtrack to try alternatives.

---

<!-- SECTION:PLANNING -->
## Root: Initial Problem Analysis

**Problem**: [Clear statement]

**Possible high-level approaches**:
1. [Approach A]
2. [Approach B]  
3. [Approach C]

---

## Level 1: Branch Exploration

### Branch A: [Approach A Name]

**Thought**: [Reasoning for this approach]

**Evaluation**:
- Feasibility: [sure/maybe/impossible]
- Estimated complexity: [low/medium/high]
- Confidence: [0-10]

**Status**: [EXPLORE / PRUNE]

---

### Branch B: [Approach B Name]

**Thought**: [Reasoning for this approach]

**Evaluation**:
- Feasibility: [sure/maybe/impossible]
- Estimated complexity: [low/medium/high]
- Confidence: [0-10]

**Status**: [EXPLORE / PRUNE]

---

### Branch C: [Approach C Name]

**Thought**: [Reasoning for this approach]

**Evaluation**:
- Feasibility: [sure/maybe/impossible]
- Estimated complexity: [low/medium/high]
- Confidence: [0-10]

**Status**: [EXPLORE / PRUNE]

<!-- /SECTION:PLANNING -->

---

<!-- SECTION:IMPLEMENTATION -->
## Level 2: Expanding Best Branches

### Branch A.1 (Expanding Branch A)

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

### Branch B.1 (Expanding Branch B) [If not pruned]

**Thought**: [Continue reasoning]

[Similar structure...]

---

## Level 3: Deep Exploration

### Branch A.1a.1 (Going deeper)

**Thought**: [Detailed implementation thinking]

**Partial Implementation**:
```
[Code so far]
```

**Evaluation**:
- Does this work so far? [yes/partial/no]
- Blockers: [Any issues encountered]

**Decision**: [CONTINUE / BACKTRACK to A.1b]

---

## Backtracking (if needed)

**Why backtracking**: [Branch A.1a hit a dead end because...]

**Returning to**: Branch A.1b

**New exploration from A.1b**:
[Continue from alternative branch]

<!-- /SECTION:IMPLEMENTATION -->

---

<!-- SECTION:VERIFICATION -->
## Convergence

**Winning Path**: Root → A → A.1 → A.1a → A.1a.1 → [Solution]

**Why this path won**:
- [Reason 1]
- [Reason 2]

**What we learned from pruned branches**:
- Branch C showed that [insight]
- Backtracking taught us [lesson]

---

## Final Solution

**Implementation**:
```
[Complete solution from winning path]
```

**Confidence**: [High/Medium] - we explored N alternative paths and this was clearly the best.
<!-- /SECTION:VERIFICATION -->

<!-- SECTION:ERROR_RECOVERY -->
## Error Recovery

If no path leads to a solution:
1. Review pruned branches - did we prune too aggressively?
2. Consider combining insights from multiple branches
3. Add new branches with alternative approaches
4. Backtrack to an earlier decision point
5. Re-evaluate initial problem understanding
<!-- /SECTION:ERROR_RECOVERY -->
