# Reasoning Technique Selection

## Overview
The planning system uses two primary reasoning techniques:
- **Tree of Thoughts (ToT)**: Exploration and decision-making
- **Graph of Thoughts (GoT)**: Synthesis and aggregation

This guide helps select the optimal technique for a given problem.

## Selection Criteria

### Use ToT When
- Problem requires exploring multiple approaches
- Making architecture or design decisions
- Multiple valid solutions exist
- Requirements are uncertain or evolving
- The problem space needs exploration

### Use GoT When
- Synthesizing information from multiple sources
- Aggregating findings or feedback
- Reviewing and verifying work
- Merging perspectives into unified output
- Task is about combination, not exploration

## Decision Flowchart

```
Start
  │
  ▼
Is this a synthesis/aggregation task?
  │
  ├── Yes ──► Use GoT
  │
  No
  │
  ▼
Does it require exploring multiple approaches?
  │
  ├── Yes ──► Use ToT
  │
  No
  │
  ▼
Is it a review/verification task?
  │
  ├── Yes ──► Use GoT
  │
  No
  │
  ▼
Is it a new design decision?
  │
  ├── Yes ──► Use ToT
  │
  No
  │
  ▼
Use category default
  │
  ├── TESTING, DOCUMENTATION ──► GoT
  │
  └── All others ──► ToT
```

## Category Defaults

| Category | Default | Rationale |
|----------|---------|-----------|
| FOUNDATION | ToT | Infrastructure decisions need exploration |
| DATA | ToT | Data models benefit from approach exploration |
| ARCHITECTURE | ToT | Architecture requires evaluating alternatives |
| UI_UX | ToT | UI decisions have multiple valid approaches |
| TESTING | GoT | Tests verify and synthesize requirements |
| LOGIC | ToT | Algorithms need exploration |
| DOCUMENTATION | GoT | Docs synthesize and aggregate information |
| META | ToT | Meta-decisions need exploration |

## Characteristic Overrides

Characteristics can override category defaults:

| Characteristic | Override To | Priority | Example |
|----------------|-------------|----------|---------|
| requires_synthesis | GoT | 1 (highest) | "Merge all feedback into spec" |
| exploration_needed | ToT | 2 | "Explore ways to implement" |
| multiple_approaches | ToT | 3 | "Could use A, B, or C" |
| review_task | GoT | 4 | "Review this plan for issues" |
| new_design | ToT | 5 (lowest) | "Design a new system for X" |

Higher priority overrides lower. If multiple characteristics match, the highest priority wins.

## Examples

### Example 1: API Design (ToT)
**Problem**: "Design a REST API for user management"
**Category**: ARCHITECTURE
**Selected**: ToT
**Why**: Needs exploration of endpoints, authentication approaches, versioning strategies

### Example 2: Test Coverage (GoT)
**Problem**: "Review test coverage and identify gaps"
**Category**: TESTING
**Selected**: GoT
**Why**: Aggregating findings from multiple test files, synthesizing recommendations

### Example 3: Documentation Update (GoT)
**Problem**: "Update API documentation with new endpoints"
**Category**: DOCUMENTATION
**Selected**: GoT
**Why**: Synthesizing existing docs with new endpoint information

### Example 4: Data Migration (ToT)
**Problem**: "Migrate user data to new schema"
**Category**: DATA
**Selected**: ToT
**Why**: Multiple migration approaches exist, need to evaluate tradeoffs

### Example 5: Code Review (GoT with Override)
**Problem**: "Review PR for code quality issues"
**Category**: ARCHITECTURE (but review_task characteristic)
**Selected**: GoT (override)
**Why**: The `review_task` characteristic overrides ARCHITECTURE default to GoT

## Python Selector

Use the CLI to get technique selection:

```bash
# Basic usage
python3 .windsurf/scripts/windsurf_plan.py reasoning {problem_type} {category}

# Examples
python3 .windsurf/scripts/windsurf_plan.py reasoning api-integration ARCHITECTURE
# Output: tot (ToT: Category ARCHITECTURE defaults to exploration)

python3 .windsurf/scripts/windsurf_plan.py reasoning unit-test TESTING
# Output: got (GoT: Category TESTING defaults to synthesis)

# With characteristic override flags
python3 .windsurf/scripts/windsurf_plan.py reasoning refactor ARCHITECTURE --synthesis
# Output: got (GoT: requires_synthesis characteristic matched)

python3 .windsurf/scripts/windsurf_plan.py reasoning docs DOCUMENTATION --exploration
# Output: tot (ToT: exploration_needed characteristic matched)
```

### CLI Flags

| Flag | Characteristic | Override To |
|------|----------------|-------------|
| `--synthesis` | requires_synthesis | GoT |
| `--exploration` | exploration_needed | ToT |
| `--multiple` | multiple_approaches | ToT |
| `--review` | review_task | GoT |
| `--design` | new_design | ToT |

## See Also
- [Tree of Thoughts (tot.md)](tot.md) - Full ToT methodology
- [Graph of Thoughts (got.md)](got.md) - Full GoT methodology
- [Technique Selector Python Module](../../scripts/technique_selector.py) - Implementation details
