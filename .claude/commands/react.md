# ReAct Prompting (Reasoning + Acting)

## Task: $ARGUMENTS

## Instructions

I will interleave reasoning with actions, observing results and adjusting my approach dynamically.

---

## ReAct Loop

### Cycle 1

**Thought 1**: Let me understand what needs to be done here.
[Reasoning about the task, what information I need, what action to take first]

**Action 1**: [Specific action - read file, run command, search, etc.]
```
[Command or action specification]
```

**Observation 1**: 
[Results of the action]

---

### Cycle 2

**Thought 2**: Based on what I observed...
[Reasoning about the observation, what it means, what to do next]

**Action 2**: [Next action based on reasoning]
```
[Command or action specification]
```

**Observation 2**:
[Results of the action]

---

### Cycle 3

**Thought 3**: Now I see that...
[Updated reasoning, potentially revising the approach]

**Action 3**: [Adjusted action]
```
[Command or action specification]
```

**Observation 3**:
[Results of the action]

---

[Continue cycles as needed...]

---

### Final Cycle

**Thought N**: I now have enough information to complete the task.
[Summary of what was learned, final approach]

**Action N**: [Final implementation action]
```
[Final code or command]
```

**Observation N**:
[Final results]

---

## Summary

**Journey**:
1. Started with: [initial understanding]
2. Discovered: [key findings]
3. Adjusted: [changes to approach]
4. Final result: [outcome]

**What I would do differently next time**:
[Lessons learned for similar tasks]
