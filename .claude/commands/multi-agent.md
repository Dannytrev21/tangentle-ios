# Multi-Agent Decomposition

You are implementing Multi-Agent Decomposition for complex problem solving.
The problem is divided into sub-problems, each handled by a specialized sub-agent.
Unlike GoT (exploring different approaches to the SAME problem), this technique
divides the problem into DIFFERENT parts with dependencies between them.

## Input
Complex problem: $ARGUMENTS

## Process

### Step 1: Analyze Complexity

Determine if multi-agent decomposition is appropriate for this problem:

```
═══════════════════════════════════════════════════════════════
  MULTI-AGENT COMPLEXITY ANALYSIS
═══════════════════════════════════════════════════════════════

  Problem: {problem description}

  Complexity Indicators:
  - [ ] Spans multiple architectural layers (data/service/UI)
  - [ ] Involves multiple unrelated systems or modules
  - [ ] Requires diverse expertise (different agent types)
  - [ ] Too large for single-session context window
  - [ ] Has clear separable sub-components

  Assessment: {Suitable / Not Suitable} for multi-agent

  If NOT suitable, recommend alternative:
  - Problem too simple → Handle directly
  - Need different approaches → Use /got-parallel instead
  - Unclear decomposition → Use /tot for planning first
═══════════════════════════════════════════════════════════════
```

If not suitable, explain why and suggest the appropriate alternative. Do NOT proceed with decomposition if the problem doesn't warrant it.

### Step 2: Decompose into Sub-Problems

Break the problem into 2-6 distinct sub-problems with clear boundaries:

```
═══════════════════════════════════════════════════════════════
  PROBLEM DECOMPOSITION
═══════════════════════════════════════════════════════════════

  ## Sub-Problems Identified ({count} total)

  ┌─────────────────────────────────────────────────────────────┐
  │ SP1: {sub-problem name}                                     │
  │ ──────────────────────────────────────────────────────────  │
  │ Scope: {what this covers, boundaries}                       │
  │ Agent Type: {Explore | Plan | code-architect | code-explorer}│
  │ Dependencies: none                                          │
  │ Complexity: {low | medium | high}                           │
  │                                                             │
  │ Interface Contract:                                         │
  │   Provides: {what this agent outputs for others}            │
  │   Expects: {nothing - root node}                            │
  ├─────────────────────────────────────────────────────────────┤
  │ SP2: {sub-problem name}                                     │
  │ ──────────────────────────────────────────────────────────  │
  │ Scope: {what this covers, boundaries}                       │
  │ Agent Type: {Explore | Plan | code-architect | code-explorer}│
  │ Dependencies: SP1                                           │
  │ Complexity: {low | medium | high}                           │
  │                                                             │
  │ Interface Contract:                                         │
  │   Provides: {what this agent outputs for others}            │
  │   Expects: {what it needs from SP1}                         │
  └─────────────────────────────────────────────────────────────┘

  ## Dependency Graph (must be a DAG - no cycles)

  SP1 ──┬──► SP2 ──┬──► SP4
        │          │
        └──► SP3 ──┘

  ## Execution Plan

  Wave 1 (parallel): SP1
  Wave 2 (parallel): SP2, SP3 (depend on SP1)
  Wave 3 (sequential): SP4 (depends on SP2, SP3)

═══════════════════════════════════════════════════════════════
```

Use AskUserQuestion to confirm:
- "Proceed with this decomposition?" with options: "Yes, execute", "No, modify decomposition"

### Step 3: Validate Dependencies

Before execution, verify the dependency graph is valid:

**Validation Checklist:**
- [ ] No circular dependencies (A→B→A is invalid)
- [ ] All dependencies reference existing sub-problems
- [ ] At least one sub-problem has no dependencies (root wave)
- [ ] 2-6 sub-problems total

If validation fails:
```
═══════════════════════════════════════════════════════════════
  ⚠️ DEPENDENCY VALIDATION FAILED
═══════════════════════════════════════════════════════════════

  Issue: {circular dependency detected | invalid reference | etc.}

  Problematic: {specific issue}

  Resolution Options:
  1. Merge sub-problems to break cycle
  2. Reorder dependencies
  3. Split the circular dependency into sequential steps
═══════════════════════════════════════════════════════════════
```

### Step 4: Execute in Waves

Execute sub-problems respecting dependency order. Each wave runs in parallel.

#### Wave Execution Pattern

**Wave 1** (no dependencies - launch all in SINGLE message):

```
Task(
  subagent_type="{agent type}",
  description="Multi-agent SP1: {name}",
  prompt="{sub-agent prompt}"
)
```

**CRITICAL**: Launch ALL sub-problems in a wave in a SINGLE message with multiple Task tool calls. This enables true parallel execution within each wave.

**Subsequent Waves** (after previous wave completes):

Include context from completed agents:

```
Task(
  subagent_type="{agent type}",
  description="Multi-agent SP2: {name}",
  prompt="## Context from Prerequisites\n{outputs from SP1}\n\n{sub-agent prompt}"
)
```

#### Sub-Agent Prompt Template

Use this template for each sub-agent:

```markdown
## Multi-Agent Task: {sub-problem name}

You are a specialized agent handling ONE part of a larger problem.
Focus ONLY on your assigned sub-problem. Do not implement other parts.

### Overall Problem Context
{brief description of full problem - 2-3 sentences}

### Your Sub-Problem
**Scope**: {specific scope and boundaries}
**Complexity**: {low | medium | high}

### Context from Prerequisites
{outputs from dependency agents - include if any}

### Your Task
{detailed task description}

### Constraints
- Stay within your defined scope
- Do not implement other sub-problems
- Your output must integrate with other agents' work
- Focus on quality within your scope, not breadth

### Interface Contract
You are PROVIDING for downstream agents:
- {what downstream agents need from you}

You EXPECT from upstream agents (provided above):
- {what you need from dependencies - or "Nothing (root node)"}

### Output Format
Return ONLY this format:

SUB-PROBLEM SOLUTION
====================
Sub-Problem: {name}
Status: Complete | Partial | Blocked

Solution Summary:
{high-level description of what was accomplished}

Detailed Solution:
{your full solution - code, analysis, design, etc.}

Artifacts Created:
- {file or component 1}: {purpose}
- {file or component 2}: {purpose}

Interface Provided:
{what downstream agents can use from your work}

Integration Notes:
{important information for final integration}

Blockers (if any):
{anything preventing completion - or "None"}
```

### Step 5: Collect and Verify Results

After each wave completes, verify interface contracts before proceeding:

```
═══════════════════════════════════════════════════════════════
  WAVE {N} COMPLETE
═══════════════════════════════════════════════════════════════

  | Agent | Sub-Problem | Status | Interface |
  |-------|-------------|--------|-----------|
  | SP1 | {name} | ✓ Complete | ✓ Valid |
  | SP2 | {name} | ✓ Complete | ✓ Valid |

  Interface Verification:
  - SP1 provides {x} for SP3: ✓ Verified
  - SP2 provides {y} for SP3: ✓ Verified

  Proceeding to Wave {N+1}...
═══════════════════════════════════════════════════════════════
```

### Step 6: Handle Failures

If a sub-agent fails or returns partial results:

```
═══════════════════════════════════════════════════════════════
  ⚠️ MULTI-AGENT EXECUTION ISSUE
═══════════════════════════════════════════════════════════════

  ## Wave {N} Status

  | Agent | Sub-Problem | Status |
  |-------|-------------|--------|
  | SP1 | {name} | ✓ Complete |
  | SP2 | {name} | ✗ Failed |
  | SP3 | {name} | ⏸ Blocked (depends on SP2) |

  ## Failure Details
  Agent SP2 failed: {error summary from agent output}

  ## Impact Analysis
  - SP3 cannot proceed (direct dependency)
  - SP4 cannot proceed (transitive dependency)
  - SP5 can still proceed (no dependency on SP2)

  ## Recovery Options
  1. **Retry SP2** - Same agent type, refined prompt
  2. **Reassign SP2** - Try different agent type
  3. **Manual SP2** - Handle this sub-problem directly
  4. **Abort** - Cancel decomposition, try different approach

  ## Recommendation
  {suggested action based on failure type and severity}
═══════════════════════════════════════════════════════════════
```

Use AskUserQuestion for recovery:
- "How should we handle the failure?" with options based on situation

### Step 7: Integrate Results

After all waves complete successfully:

```
═══════════════════════════════════════════════════════════════
  MULTI-AGENT INTEGRATION
═══════════════════════════════════════════════════════════════

  ## Execution Summary

  | Wave | Agents | Status | Duration |
  |------|--------|--------|----------|
  | 1 | SP1 | ✓ Complete | {time} |
  | 2 | SP2, SP3 | ✓ Complete | {time} |
  | 3 | SP4 | ✓ Complete | {time} |

  Total: {N} sub-problems, {M} waves, all successful

  ## Interface Verification (Final)

  ✓ All contracts satisfied
  ✓ No orphaned artifacts
  ✓ Integration points verified

  ## Integrated Solution

  ### Overview
  {cohesive summary combining all agent outputs}

  ### Components
  1. **{SP1 contribution}**: {summary}
  2. **{SP2 contribution}**: {summary}
  3. **{SP3 contribution}**: {summary}
  4. **{SP4 contribution}**: {summary}

  ### Files Created/Modified

  | File | Created By | Purpose |
  |------|------------|---------|
  | {path} | SP1 | {purpose} |
  | {path} | SP2 | {purpose} |
  | {path} | SP3 | {purpose} |

  ### Integration Notes
  {any important notes about how pieces fit together}

  ### Next Steps
  {suggested follow-up actions}

═══════════════════════════════════════════════════════════════
```

## Decomposition Strategies

Choose the appropriate strategy based on problem characteristics:

### By Layer (Vertical Decomposition)
Best for: Features spanning the application stack

```
Problem: "Implement user profile editing"

SP1: Data Layer Agent (Explore)
    - Schema changes, model updates

SP2: Service Layer Agent (Plan)
    - Business logic, validation
    - Depends on: SP1

SP3: API Layer Agent (Explore)
    - Endpoints, request/response
    - Depends on: SP2

SP4: UI Layer Agent (code-architect)
    - Views, forms, state
    - Depends on: SP3
```

### By Module (Horizontal Decomposition)
Best for: Refactoring across multiple modules

```
Problem: "Standardize error handling across modules"

SP1: Auth Module Agent (Explore)
    - Error handling in auth/

SP2: Tasks Module Agent (Explore)
    - Error handling in tasks/

SP3: Projects Module Agent (Explore)
    - Error handling in projects/

SP4: Integration Agent (Plan)
    - Ensure consistency, shared patterns
    - Depends on: SP1, SP2, SP3
```

### By Concern (Cross-Cutting Decomposition)
Best for: Complex features with orthogonal concerns

```
Problem: "Add comprehensive logging to the app"

SP1: Core Logic Agent (code-architect)
    - Main logging infrastructure

SP2: Error Handling Agent (Explore)
    - Error-specific logging
    - Depends on: SP1

SP3: Performance Agent (Explore)
    - Performance metric logging
    - Depends on: SP1

SP4: Testing Agent (code-reviewer)
    - Verify logging coverage
    - Depends on: SP2, SP3
```

## Agent Types Reference

| Agent Type | subagent_type | Best For |
|------------|---------------|----------|
| Codebase Explorer | `Explore` | Understanding existing code, patterns |
| Architecture Planner | `Plan` | Designing implementation approach |
| System Architect | `feature-dev:code-architect` | Complex architectural decisions |
| Deep Analyzer | `feature-dev:code-explorer` | Deep pattern analysis |
| Quality Reviewer | `feature-dev:code-reviewer` | Code review, quality verification |

## Constraints

- **Minimum sub-problems**: 2 (else multi-agent is overkill)
- **Maximum sub-problems**: 6 (coordination overhead exceeds benefit)
- **Dependency graph**: Must be a DAG (no circular dependencies)
- **Interface contracts**: Required for all inter-agent dependencies
- **Wave parallelism**: All agents in a wave launch in SINGLE message

## Edge Cases

### Problem Too Simple
```
═══════════════════════════════════════════════════════════════
  MULTI-AGENT NOT RECOMMENDED
═══════════════════════════════════════════════════════════════

  This problem does not warrant multi-agent decomposition.

  Reason: {only 1 sub-problem identified | no clear boundaries}

  Recommendation: Handle directly or use /tot for planning
═══════════════════════════════════════════════════════════════
```

### All Agents Fail
```
═══════════════════════════════════════════════════════════════
  MULTI-AGENT DECOMPOSITION FAILED
═══════════════════════════════════════════════════════════════

  All agents in Wave 1 failed to produce results.

  Possible causes:
  1. Problem poorly decomposed - boundaries unclear
  2. Sub-problems too complex individually
  3. Missing context for agents

  Suggestions:
  - Re-decompose with clearer boundaries
  - Try /got-parallel to explore approaches first
  - Handle the problem directly without decomposition
═══════════════════════════════════════════════════════════════
```

### Partial Success
If some sub-problems complete but integration fails:
1. Document what completed successfully
2. Identify the integration gap
3. Offer to continue with manual integration or re-run failed parts

## Example

### Input
`/multi-agent "Implement user authentication with OAuth support"`

### Decomposition
```
SP1: Data Layer (Explore)
    - User model, token storage schema

SP2: OAuth Integration (code-architect)
    - OAuth flow, provider abstraction
    - Depends on: SP1

SP3: Auth Service (Plan)
    - Login, logout, session management
    - Depends on: SP1

SP4: API Endpoints (Explore)
    - Auth routes, middleware
    - Depends on: SP2, SP3

SP5: UI Components (code-architect)
    - Login screens, OAuth buttons
    - Depends on: SP4
```

### Execution
- Wave 1: SP1
- Wave 2: SP2, SP3 (parallel)
- Wave 3: SP4
- Wave 4: SP5

### Result
Integrated auth system with:
- User model with OAuth support
- OAuth provider abstraction
- Session management service
- Protected API routes
- Complete UI flow

## Do NOT

- Create more than 6 sub-problems (diminishing returns)
- Allow circular dependencies (A→B→A is invalid)
- Skip interface contract definition (causes integration failures)
- Ignore failed agents in final integration (document gaps)
- Use for simple problems (overkill, overhead > benefit)
- Launch agents sequentially when they can run in parallel
- Proceed without user confirmation on decomposition
