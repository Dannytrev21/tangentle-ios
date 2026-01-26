# Graph of Thought - Parallel Exploration

You are implementing Graph of Thought (GoT) problem solving using parallel sub-agents.
Each sub-agent explores one branch of the solution space independently.

## Input
Problem to explore: $ARGUMENTS

## Process

### Step 1: Decompose into Exploration Branches

Analyze the problem and identify 3-5 distinct exploration paths. Consider:

**For Technical Problems**:
- Branch by architecture approach (monolith vs microservice vs serverless)
- Branch by technology choice (framework A vs B vs C)
- Branch by data model (normalized vs denormalized vs hybrid)

**For Debugging Problems**:
- Branch by suspected cause (frontend vs backend vs data)
- Branch by investigation method (logs vs traces vs reproduction)
- Branch by fix approach (quick patch vs refactor vs redesign)

**For Design Problems**:
- Branch by user flow (simplified vs full-featured vs progressive)
- Branch by visual approach (minimal vs rich vs adaptive)
- Branch by interaction pattern (standard vs innovative vs hybrid)

Present the decomposition:

```
===============================================================
  GRAPH OF THOUGHT - BRANCH DECOMPOSITION
===============================================================

  Problem: {problem description}

  Identified Branches:
  +-------------------------------------------------------------+
  | Branch A: {approach name}                                   |
  | Focus: {what this branch explores}                          |
  | Key Question: {what we're trying to answer}                 |
  +-------------------------------------------------------------+
  | Branch B: {approach name}                                   |
  | Focus: {what this branch explores}                          |
  | Key Question: {what we're trying to answer}                 |
  +-------------------------------------------------------------+
  | Branch C: {approach name}                                   |
  | Focus: {what this branch explores}                          |
  | Key Question: {what we're trying to answer}                 |
  +-------------------------------------------------------------+

  Ready to launch parallel exploration? [Y/n]
===============================================================
```

Use AskUserQuestion to confirm before launching:
- "Launch exploration?" with options: "Yes, explore all branches", "No, modify branches"

### Step 2: Launch Parallel Sub-Agents

**CRITICAL**: Launch ALL branches in a SINGLE message with multiple Task tool calls.
This enables true parallel execution.

For each branch, use the Task tool with `subagent_type="Explore"`:

```
Task(
  subagent_type="Explore",
  description="GoT Branch A: {approach name}",
  prompt="{sub-agent prompt below}"
)
```

#### Sub-Agent Prompt Template

Use this template for each branch's prompt:

```
## Graph of Thought - Branch Exploration

You are exploring ONE branch of a multi-branch solution space.
Focus ONLY on your assigned approach. Do not try to solve the whole problem.
Return ONLY your exploration results in the specified format.

### Problem Context
{original problem description}

### Your Branch
**Approach**: {branch approach name}
**Focus**: {what to explore}
**Key Question**: {question to answer}

### Instructions
1. Explore this approach thoroughly
2. Identify strengths and weaknesses
3. Note any critical insights
4. Estimate feasibility (0-100%)
5. Document your findings

### Output Format
Return ONLY this format:

BRANCH EXPLORATION RESULTS
==========================
Approach: {name}
Feasibility: {0-100}%

Key Findings:
1. {finding 1}
2. {finding 2}
3. {finding 3}

Strengths:
- {strength 1}
- {strength 2}

Weaknesses:
- {weakness 1}
- {weakness 2}

Critical Insight:
{most important discovery}

Recommendation:
{should this approach be pursued? why/why not?}
```

### Step 3: Collect Results

Wait for all sub-agents to complete. The Task tool will return results.

**Timeout Handling**:
- If a branch times out, note it in results
- Continue with branches that completed
- If all branches time out, report failure

### Step 4: Aggregate and Synthesize

Once all branches complete (or timeout), aggregate findings:

```
===============================================================
  GRAPH OF THOUGHT - AGGREGATION
===============================================================

  ## Branch Results Summary

  | Branch | Approach | Feasibility | Key Insight |
  |--------|----------|-------------|-------------|
  | A | {name} | {X}% | {insight} |
  | B | {name} | {Y}% | {insight} |
  | C | {name} | {Z}% | {insight} |

  ## Cross-Branch Analysis

  ### Converging Insights
  {insights that appear in multiple branches or support each other}
  - {converging insight 1}
  - {converging insight 2}

  ### Diverging Perspectives
  {where branches disagree or offer contradictory findings}
  - {diverging point 1}
  - {diverging point 2}

  ### Synthesis
  {how insights from different branches combine to form a complete picture}

  ## Recommended Approach

  **Primary Strategy**: Branch {X} - {rationale}

  **Incorporate from Other Branches**:
  - From Branch {Y}: {specific element to adopt}
  - From Branch {Z}: {specific element to adopt}

  **Avoid**:
  - From Branch {X}: {specific pitfall identified}

  ## Final Recommendation

  {synthesized solution that draws from best of all branches,
   addressing the original problem with insights from parallel exploration}

===============================================================
```

## Constraints

- **Minimum branches**: 2 (need multiple perspectives)
- **Maximum branches**: 5 (more = diminishing returns)
- **Sub-agent timeout**: 5 minutes each
- **Thorough exploration**: subagent_type="Explore" uses thorough mode

## Edge Cases

### User Declines to Launch
Ask what they want instead:
- Modify branches
- Cancel and reformulate problem
- Proceed with subset of branches

### Sub-Agent Timeout
```
Branch {X}: TIMEOUT
- Could not complete exploration within time limit
- Consider: Narrowing the focus for this branch
```

### All Branches Fail
```
===============================================================
  GRAPH OF THOUGHT - EXPLORATION FAILED
===============================================================

  All branches failed to produce results.

  Possible causes:
  1. Problem too broad - try narrowing scope
  2. Branches too similar - need more diverse approaches
  3. Technical issue - retry with fewer branches

  Suggestions:
  - Reformulate the problem with clearer constraints
  - Try /tot for sequential exploration instead
  - Break problem into smaller sub-problems first
===============================================================
```

### Branches Return Conflicting Information
Note in "Diverging Perspectives" section and:
1. Identify the source of conflict
2. Determine which has stronger evidence
3. Note uncertainty in final recommendation

## Example

### Input
`/got-parallel "How should we implement the AI coaching feature?"`

### Branch Decomposition
1. **Local Processing**: On-device LLM for privacy, offline capability
2. **Cloud API**: Claude/GPT API for best quality, always current
3. **Hybrid Approach**: Local for quick responses, cloud for complex queries

### After Exploration

| Branch | Approach | Feasibility | Key Insight |
|--------|----------|-------------|-------------|
| A | Local | 40% | Model size constraints, quality concerns |
| B | Cloud | 90% | Good quality, latency concerns, cost |
| C | Hybrid | 70% | Best UX, complex to implement |

### Final Recommendation
Primary: Cloud API (highest feasibility, best quality)
Incorporate from Hybrid: Add response caching for common queries
Avoid from Local: Don't try to run full LLM locally on iOS

## Do NOT

- Launch more than 5 sub-agents (diminishing returns)
- Skip the aggregation step (raw results aren't useful alone)
- Ignore branches that completed (even if others timed out)
- Report raw results without synthesis
- Use sequential Task calls (must be parallel in single message)
