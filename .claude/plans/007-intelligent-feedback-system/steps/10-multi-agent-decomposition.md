# Step 10: Multi-Agent Decomposition

## Problem Type
`new-feature`

## Technique Selection
- **Planning**: tot - Multiple decomposition strategies
- **Implementation**: self-refine - Iterate on agent coordination
- **Verification**: got - Validate with parallel verification

## Risk Level
**high** - Complex multi-agent orchestration

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 3 attempts
- Escalation: After 7 total failures

## Context
Multi-Agent Decomposition breaks complex problems into sub-problems, assigns each to a specialized sub-agent, and orchestrates the results. Unlike GoT (exploring different approaches to the SAME problem), this technique divides the problem into DIFFERENT parts.

Use cases:
- Large refactoring (one agent per module)
- Complex features (one agent per layer: data, logic, UI)
- Investigation (one agent per hypothesis)

## Goal
Create a `/multi-agent` command that:
1. Decomposes complex problems into sub-problems
2. Assigns specialized sub-agents to each
3. Defines dependencies between sub-agents
4. Orchestrates execution (respecting dependencies)
5. Integrates results into cohesive solution

## Prerequisites
- Step 9 (GoT Parallel) completed (reuses sub-agent patterns)

## High-Level Steps
1. Design decomposition format
2. Define agent specializations
3. Implement dependency-aware orchestration
4. Create result integration logic
5. Build user-facing command
6. Test with complex problems

## Detailed Requirements

### /multi-agent Command File

Create `.claude/commands/multi-agent.md`:

```markdown
# Multi-Agent Decomposition

You are implementing Multi-Agent Decomposition for complex problem solving.
The problem is divided into sub-problems, each handled by a specialized agent.

## Input
Complex problem: $ARGUMENTS

## Process

### Step 1: Analyze Complexity

Determine if multi-agent is appropriate:

```
═══════════════════════════════════════════════════════════════
  MULTI-AGENT ANALYSIS
═══════════════════════════════════════════════════════════════

  Problem: {problem description}

  Complexity Indicators:
  - [ ] Spans multiple architectural layers
  - [ ] Involves multiple unrelated systems
  - [ ] Requires diverse expertise
  - [ ] Too large for single-session context

  Assessment: {Suitable / Not Suitable} for multi-agent

  If not suitable, recommend: {alternative approach}
═══════════════════════════════════════════════════════════════
```

### Step 2: Decompose into Sub-Problems

Break the problem into distinct sub-problems:

```
═══════════════════════════════════════════════════════════════
  PROBLEM DECOMPOSITION
═══════════════════════════════════════════════════════════════

  ## Sub-Problems Identified

  ┌─────────────────────────────────────────────────────────────┐
  │ Sub-Problem 1: {name}                                       │
  │ Scope: {what this covers}                                   │
  │ Agent Type: {specialization}                                │
  │ Dependencies: {none | sub-problem X}                        │
  │ Estimated Complexity: {low/medium/high}                     │
  ├─────────────────────────────────────────────────────────────┤
  │ Sub-Problem 2: {name}                                       │
  │ Scope: {what this covers}                                   │
  │ Agent Type: {specialization}                                │
  │ Dependencies: {sub-problem 1}                               │
  │ Estimated Complexity: {low/medium/high}                     │
  ├─────────────────────────────────────────────────────────────┤
  │ Sub-Problem 3: {name}                                       │
  │ Scope: {what this covers}                                   │
  │ Agent Type: {specialization}                                │
  │ Dependencies: {sub-problem 1, 2}                            │
  │ Estimated Complexity: {low/medium/high}                     │
  └─────────────────────────────────────────────────────────────┘

  ## Dependency Graph

  Sub-Problem 1 ──┬──► Sub-Problem 2 ──┬──► Sub-Problem 4
                  │                     │
                  └──► Sub-Problem 3 ───┘

  ## Execution Plan
  - Wave 1 (parallel): Sub-Problem 1
  - Wave 2 (parallel): Sub-Problem 2, 3 (depend on 1)
  - Wave 3: Sub-Problem 4 (depends on 2, 3)

  Proceed with decomposition? [Y/n]
═══════════════════════════════════════════════════════════════
```

### Step 3: Define Agent Specializations

Available agent types and their focus:

| Agent Type | Specialization | Use For |
|------------|----------------|---------|
| `Explore` | Codebase analysis | Understanding existing code |
| `Plan` | Architecture design | Planning implementation |
| `feature-dev:code-architect` | System design | Complex architectural decisions |
| `feature-dev:code-explorer` | Deep analysis | Understanding patterns |
| `feature-dev:code-reviewer` | Code review | Quality verification |

### Step 4: Execute in Waves

Launch agents respecting dependencies:

```markdown
## Wave 1 Execution

Launching agents with no dependencies:

```
Agent 1 (Sub-Problem 1): Task(subagent_type="{type}", prompt="...")
```

## Wave 2 Execution

After Wave 1 completes, launch dependent agents:

```
# Include outputs from Wave 1 in context
Agent 2 (Sub-Problem 2): Task(
  subagent_type="{type}",
  prompt="Context from Agent 1: {...}\n\nYour task: ..."
)
Agent 3 (Sub-Problem 3): Task(
  subagent_type="{type}",
  prompt="Context from Agent 1: {...}\n\nYour task: ..."
)
```
```

#### Sub-Agent Prompt Template

```markdown
## Multi-Agent Task: {sub-problem name}

You are a specialized agent handling ONE part of a larger problem.
Focus ONLY on your assigned sub-problem.

### Overall Problem Context
{brief description of full problem}

### Your Sub-Problem
**Scope**: {specific scope}
**Dependencies Provided**: {context from previous agents}

### Your Task
{detailed task description}

### Constraints
- Stay within your scope
- Do not implement other sub-problems
- Output must integrate with other agents' work

### Interface Contract
Your output will be used by: {downstream agents}
They expect: {format/interface they need}

### Output Format
```
SUB-PROBLEM SOLUTION
====================
Sub-Problem: {name}
Status: Complete / Partial / Blocked

Solution:
{your solution}

Artifacts Created:
- {file or component 1}
- {file or component 2}

Interface Provided:
{what downstream agents can use}

Blockers (if any):
{anything preventing completion}

Notes for Integration:
{important info for final integration}
```
```

### Step 5: Collect and Integrate Results

```
═══════════════════════════════════════════════════════════════
  MULTI-AGENT INTEGRATION
═══════════════════════════════════════════════════════════════

  ## Execution Summary

  | Agent | Sub-Problem | Status | Duration |
  |-------|-------------|--------|----------|
  | 1 | {name} | Complete | {time} |
  | 2 | {name} | Complete | {time} |
  | 3 | {name} | Complete | {time} |
  | 4 | {name} | Complete | {time} |

  ## Integration Analysis

  ### Interfaces Match
  - [ ] Agent 1 → Agent 2: {status}
  - [ ] Agent 1 → Agent 3: {status}
  - [ ] Agent 2, 3 → Agent 4: {status}

  ### Conflicts Detected
  - {any conflicts between agent outputs}

  ### Resolution
  - {how conflicts were resolved}

  ## Integrated Solution

  {Cohesive solution combining all agent outputs}

  ## Files Created/Modified

  | File | Created By | Purpose |
  |------|------------|---------|
  | {path} | Agent 1 | {purpose} |
  | {path} | Agent 2 | {purpose} |

  ## Verification Status

  - [ ] All interfaces connect properly
  - [ ] No duplicate code/logic
  - [ ] Consistent naming conventions
  - [ ] Tests pass across all components

═══════════════════════════════════════════════════════════════
```

### Step 6: Handle Failures

If any agent fails:

```
═══════════════════════════════════════════════════════════════
  ⚠️ MULTI-AGENT EXECUTION ISSUE
═══════════════════════════════════════════════════════════════

  ## Status

  | Agent | Sub-Problem | Status |
  |-------|-------------|--------|
  | 1 | {name} | ✓ Complete |
  | 2 | {name} | ✗ Failed |
  | 3 | {name} | ⏸ Blocked (depends on 2) |

  ## Failure Details
  Agent 2 failed: {error summary}

  ## Options
  1. Retry Agent 2 with modified approach
  2. Reassign Sub-Problem 2 to different agent type
  3. Manual intervention for Sub-Problem 2
  4. Abort and handle entire problem differently

  ## Recommendation
  {suggested action based on failure type}

═══════════════════════════════════════════════════════════════
```

## Decomposition Strategies

### By Layer (Vertical)
For features spanning the stack:
1. Data Layer Agent: Schema, models, migrations
2. Service Layer Agent: Business logic, APIs
3. UI Layer Agent: Views, components

### By Module (Horizontal)
For refactoring across modules:
1. Module A Agent: Changes in module A
2. Module B Agent: Changes in module B
3. Integration Agent: Ensure modules work together

### By Concern (Cross-cutting)
For complex features:
1. Core Logic Agent: Main functionality
2. Error Handling Agent: Edge cases, failures
3. Testing Agent: Test coverage

## Example

### Input
"Implement user authentication with OAuth support"

### Decomposition
1. **Data Agent**: User model, session storage
2. **Auth Agent**: OAuth flow, token management
3. **API Agent**: Login/logout endpoints
4. **UI Agent**: Login screen, error states
5. **Integration Agent**: Connect all pieces

### Dependency Graph
```
Data Agent ──► Auth Agent ──┬──► API Agent ──┬──► Integration
                            │                │
                            └──► UI Agent ───┘
```

## Constraints
- Maximum 6 sub-problems (more = coordination overhead)
- Minimum 2 sub-problems (else don't use multi-agent)
- Clear interface contracts between agents
- Dependency cycles are not allowed
```

## Files to Create
- `.claude/commands/multi-agent.md`: Multi-agent command

## Files to Modify
- None

## Patterns to Follow
Reference: `.claude/commands/got-parallel.md` for sub-agent patterns

## Acceptance Criteria
- [ ] Problem decomposition produces distinct sub-problems
- [ ] Dependencies correctly identified and ordered
- [ ] Wave execution respects dependencies
- [ ] Results properly integrated
- [ ] Failure handling works correctly
- [ ] Interface contracts validated

## Testing Requirements

### Manual Tests
- [ ] Test with vertical decomposition (stack layers)
- [ ] Test with horizontal decomposition (modules)
- [ ] Test dependency chain execution
- [ ] Test failure in dependent agent
- [ ] Test parallel execution within waves

### What to Test
- Decomposition quality
- Dependency detection
- Wave execution order
- Integration coherence
- Failure recovery

## Verification Commands
```bash
# Verify command file exists
cat .claude/commands/multi-agent.md | head -30

# Test decomposition (manual)
# Run /multi-agent "Implement full CRUD for new entity"
```

## Documentation Updates
- [ ] Add /multi-agent to CLAUDE.md
- [ ] Document decomposition strategies
- [ ] Explain when to use vs. GoT

## Error Recovery
If verification fails:
1. Check dependency graph for cycles
2. Verify interface contracts are clear
3. Test with simpler 2-agent problem

## Do NOT
- Allow circular dependencies
- Skip interface contract definition
- Ignore failed agents in integration
- Create more than 6 sub-problems
