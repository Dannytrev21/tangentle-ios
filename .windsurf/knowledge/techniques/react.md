# ReAct Prompting (Reasoning + Acting)

## Overview
ReAct interleaves reasoning with actions, observing results and adjusting approach dynamically. Unlike pure planning techniques, ReAct takes action mid-reasoning, learns from observations, and adapts its strategy based on real-world feedback.

This technique is ideal for interactive problem-solving where the environment provides feedback.

## When to Use
- Debugging where investigation reveals new information
- Interactive problem-solving with environment feedback
- API integration requiring discovery of endpoints/responses
- Configuration tasks with trial-and-error
- Any task where observations inform next steps
- Problems where the full picture isn't known upfront

## How It Works

### ReAct Cycle
Each cycle consists of three parts:
1. **Thought**: Reason about current state and what to do next
2. **Action**: Take a specific action (read file, run command, search, etc.)
3. **Observation**: Record what was learned from the action

Cycles repeat until the task is complete or blocked.

## Execution Instructions

```
## REACT EXECUTION PROTOCOL

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
[Final results - confirmation of success]

---

## Summary

**Journey**:
1. Started with: [initial understanding]
2. Discovered: [key findings from observations]
3. Adjusted: [changes to approach based on feedback]
4. Final result: [outcome]

**What I would do differently next time**:
[Lessons learned for similar tasks]
```

## Example Application

**Task**: Debug a failing API integration

**ReAct Application**:
1. **Thought**: Check error logs first
   **Action**: Read log file
   **Observation**: 401 Unauthorized error
2. **Thought**: Authentication issue, check credentials
   **Action**: Print API key configuration
   **Observation**: Key is set correctly
3. **Thought**: Maybe token expired, check token endpoint
   **Action**: Curl the token refresh endpoint
   **Observation**: Token was indeed expired
4. **Thought**: Need to implement token refresh
   **Action**: Implement refresh logic
   **Observation**: API calls now succeed

## Common Pitfalls
- Taking actions without clear reasoning (acting blindly)
- Not updating understanding based on observations
- Repeating the same action expecting different results
- Forgetting to record observations
- Not knowing when to stop cycling
- Actions that don't provide useful observations

## Verification Checklist
- [ ] Each action preceded by clear reasoning (Thought)
- [ ] Observations recorded for each action
- [ ] Reasoning updated based on observations
- [ ] Strategy adjusted when observations contradict expectations
- [ ] Clear stopping criteria or completion state
- [ ] Lessons learned documented for future reference
