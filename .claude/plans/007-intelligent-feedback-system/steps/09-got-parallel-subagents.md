# Step 9: Graph of Thought with Parallel Sub-Agents

## Problem Type
`new-feature`

## Technique Selection
- **Planning**: tot - Multiple architecture approaches
- **Implementation**: self-refine - Iterate on sub-agent coordination
- **Verification**: reflexion - Learn from failures, avoid circular verification

## Risk Level
**high** - Complex multi-agent coordination

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 3 attempts
- Escalation: After 7 total failures

## Context
Graph of Thought (GoT) explores multiple solution paths in parallel, then aggregates the best insights. This step implements GoT using Claude Code's Task tool to launch parallel sub-agents, each exploring one branch of the solution space.

Key innovation: Instead of git branches (slow, merge-heavy), we use sub-agents that return their findings, which the main agent aggregates.

## Goal
Create a `/got-parallel` command that:
1. Defines exploration branches from a problem
2. Launches parallel sub-agents (one per branch)
3. Collects results from all branches
4. Aggregates findings into best solution
5. Presents synthesized recommendation

## Prerequisites
- Step 8 (Plan-Next Integration) completed

## High-Level Steps
1. Design branch definition format
2. Create sub-agent prompt templates
3. Implement parallel launch logic
4. Create aggregation algorithm
5. Build user-facing command
6. Test with sample problems

## Detailed Requirements

### /got-parallel Command File

Create `.claude/commands/got-parallel.md`:

```markdown
# Graph of Thought - Parallel Exploration

You are implementing Graph of Thought (GoT) problem solving using parallel sub-agents.
Each sub-agent explores one branch of the solution space independently.

## Input
Problem to explore: $ARGUMENTS

## Process

### Step 1: Decompose into Exploration Branches

Analyze the problem and identify 3-5 distinct exploration paths:

```
═══════════════════════════════════════════════════════════════
  GRAPH OF THOUGHT - BRANCH DECOMPOSITION
═══════════════════════════════════════════════════════════════

  Problem: {problem description}

  Identified Branches:
  ┌─────────────────────────────────────────────────────────────┐
  │ Branch A: {approach name}                                   │
  │ Focus: {what this branch explores}                          │
  │ Key Question: {what we're trying to answer}                 │
  ├─────────────────────────────────────────────────────────────┤
  │ Branch B: {approach name}                                   │
  │ Focus: {what this branch explores}                          │
  │ Key Question: {what we're trying to answer}                 │
  ├─────────────────────────────────────────────────────────────┤
  │ Branch C: {approach name}                                   │
  │ Focus: {what this branch explores}                          │
  │ Key Question: {what we're trying to answer}                 │
  └─────────────────────────────────────────────────────────────┘

  Shall I launch parallel exploration? [Y/n]
═══════════════════════════════════════════════════════════════
```

### Step 2: Launch Parallel Sub-Agents

For each branch, launch a Task tool with subagent_type="Explore":

```
# Launch all branches in parallel (single message, multiple tool calls)
Branch A: Task(subagent_type="Explore", prompt="...")
Branch B: Task(subagent_type="Explore", prompt="...")
Branch C: Task(subagent_type="Explore", prompt="...")
```

#### Sub-Agent Prompt Template

```markdown
## Graph of Thought - Branch Exploration

You are exploring ONE branch of a multi-branch solution space.
Focus ONLY on your assigned approach. Do not try to solve the whole problem.

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
Return your findings as:

```
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
{should this approach be pursued? why?}
```
```

### Step 3: Collect and Wait for Results

After launching, wait for all sub-agents to complete:

```
═══════════════════════════════════════════════════════════════
  EXPLORATION IN PROGRESS
═══════════════════════════════════════════════════════════════

  Branch A: ⏳ Exploring...
  Branch B: ⏳ Exploring...
  Branch C: ⏳ Exploring...

  (Sub-agents running in parallel)
═══════════════════════════════════════════════════════════════
```

### Step 4: Aggregate Results

Once all branches complete, synthesize findings:

```
═══════════════════════════════════════════════════════════════
  GRAPH OF THOUGHT - AGGREGATION
═══════════════════════════════════════════════════════════════

  ## Branch Results Summary

  | Branch | Approach | Feasibility | Key Insight |
  |--------|----------|-------------|-------------|
  | A | {name} | {X}% | {insight} |
  | B | {name} | {Y}% | {insight} |
  | C | {name} | {Z}% | {insight} |

  ## Cross-Branch Analysis

  ### Converging Insights
  - {insight that appears in multiple branches}

  ### Diverging Perspectives
  - {where branches disagree}

  ### Synthesis
  {How insights from different branches combine}

  ## Recommended Approach

  **Primary**: Branch {X} - {rationale}
  **Incorporate from Branch {Y}**: {specific element}
  **Avoid from Branch {Z}**: {specific pitfall}

  ## Final Recommendation

  {Synthesized solution that draws from best of all branches}

═══════════════════════════════════════════════════════════════
```

### Step 5: Output Implementation Plan

If the problem was about implementation:

```
═══════════════════════════════════════════════════════════════
  GRAPH OF THOUGHT - IMPLEMENTATION PLAN
═══════════════════════════════════════════════════════════════

  Based on parallel exploration, recommended implementation:

  1. {Step from primary branch}
  2. {Step incorporating secondary insight}
  3. {Step avoiding identified pitfall}
  4. ...

  ## Key Decisions Made
  - {Decision 1}: Chose {X} over {Y} because {reason from exploration}
  - {Decision 2}: ...

  ## Risks Identified
  - {Risk from Branch A}
  - {Risk from Branch B}

  ## Mitigation Strategies
  - {Mitigation discovered during exploration}

═══════════════════════════════════════════════════════════════
```

## Branch Decomposition Guidelines

### For Technical Problems
- Branch by architecture approach (monolith vs microservice)
- Branch by technology choice (framework A vs B)
- Branch by data model (normalized vs denormalized)

### For Debugging Problems
- Branch by suspected cause
- Branch by investigation method
- Branch by fix approach

### For Design Problems
- Branch by user flow
- Branch by visual approach
- Branch by interaction pattern

## Example

### Input
"How should we implement the AI coaching feature?"

### Branches
1. **Local Processing**: On-device LLM for privacy, offline capability
2. **Cloud API**: Claude/GPT API for best quality, always current
3. **Hybrid**: Local for quick responses, cloud for complex queries

### Exploration Results
- Local: 40% feasible (model size constraints, quality concerns)
- Cloud: 90% feasible (good quality, latency concerns, cost)
- Hybrid: 70% feasible (best UX, complex to implement)

### Synthesis
Primary: Cloud API (highest feasibility, best quality)
Incorporate from Hybrid: Add response caching for common queries
Avoid from Local: Don't try to run full LLM locally

## Constraints
- Maximum 5 branches (more = diminishing returns)
- Minimum 2 branches (need multiple perspectives)
- Sub-agent timeout: 5 minutes each
- Total process timeout: 15 minutes
```

## Files to Create
- `.claude/commands/got-parallel.md`: GoT command

## Files to Modify
- None

## Patterns to Follow
Reference: `.claude/commands/tot.md` for thought exploration pattern

## Acceptance Criteria
- [ ] Branch decomposition produces 2-5 distinct approaches
- [ ] Sub-agents launch in parallel
- [ ] Results collected from all branches
- [ ] Aggregation produces coherent synthesis
- [ ] Recommendations draw from multiple branches
- [ ] Timeout handling works correctly

## Testing Requirements

### Manual Tests
- [ ] Test with technical architecture question
- [ ] Test with debugging problem
- [ ] Test with design decision
- [ ] Test timeout handling
- [ ] Test with 2 branches (minimum)
- [ ] Test with 5 branches (maximum)

### What to Test
- Branch generation quality
- Sub-agent prompt effectiveness
- Aggregation logic
- Timeout scenarios

## Verification Commands
```bash
# Verify command file exists
cat .claude/commands/got-parallel.md | head -30

# Test branch generation (manual)
# Run /got-parallel "How should we implement caching?"
```

## Documentation Updates
- [ ] Add /got-parallel to CLAUDE.md
- [ ] Document when to use GoT vs other techniques

## Error Recovery
If verification fails:
1. Check Task tool syntax
2. Verify sub-agent prompts are complete
3. Test with simpler problem first

## Do NOT
- Use git branches (too slow)
- Launch more than 5 sub-agents
- Skip the aggregation step
- Ignore timeout handling
