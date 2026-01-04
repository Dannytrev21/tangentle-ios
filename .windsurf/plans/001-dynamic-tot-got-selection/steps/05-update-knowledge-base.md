# Step 5: Update Knowledge Base

## Problem Type
`infrastructure`

## Technique Selection
- **Planning**: PS+ - Structured documentation approach
- **Implementation**: Least-to-Most - Build from existing docs
- **Verification**: Self-Refine - Iterate on clarity

## Risk Level
**Low** - Adding documentation; no code changes

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Context
The knowledge base has individual technique files (tot.md, got.md) but lacks a guide for selecting between them. This step adds a reasoning-selection.md file that documents when to use ToT vs GoT.

## Goal
Create `.windsurf/knowledge/techniques/reasoning-selection.md` that:
1. Documents ToT vs GoT selection criteria
2. Provides decision flowchart
3. Shows examples of each technique application
4. References the Python selector

## Prerequisites
- None (can run in parallel with Steps 2-3)

## High-Level Steps
1. Review existing tot.md and got.md for content to reference
2. Create reasoning-selection.md with selection criteria
3. Add decision flowchart
4. Add examples for common problem types
5. Reference Python selector usage

## Detailed Requirements

### File Content
```markdown
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
  ├── Yes ──▶ Use GoT
  │
  No
  │
  ▼
Does it require exploring multiple approaches?
  │
  ├── Yes ──▶ Use ToT
  │
  No
  │
  ▼
Is it a review/verification task?
  │
  ├── Yes ──▶ Use GoT
  │
  No
  │
  ▼
Is it a new design decision?
  │
  ├── Yes ──▶ Use ToT
  │
  No
  │
  ▼
Use category default
  │
  ├── TESTING, DOCUMENTATION ──▶ GoT
  │
  └── All others ──▶ ToT
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

| Characteristic | Override To | Priority |
|----------------|-------------|----------|
| requires_synthesis | GoT | 1 (highest) |
| exploration_needed | ToT | 2 |
| multiple_approaches | ToT | 3 |
| review_task | GoT | 4 |
| new_design | ToT | 5 (lowest) |

## Examples

### Example 1: API Design (ToT)
**Problem**: "Design a REST API for user management"
**Category**: ARCHITECTURE
**Selected**: ToT
**Why**: Needs exploration of endpoints, authentication approaches, versioning

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

### Example 5: Code Review (GoT)
**Problem**: "Review PR for code quality issues"
**Category**: ARCHITECTURE (but review_task characteristic)
**Selected**: GoT (override)
**Why**: Review task overrides to GoT for synthesis

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

# With characteristic override
python3 .windsurf/scripts/windsurf_plan.py reasoning refactor ARCHITECTURE --synthesis
# Output: got (GoT: requires_synthesis characteristic matched)
```

## See Also
- [Tree of Thoughts (tot.md)](tot.md)
- [Graph of Thoughts (got.md)](got.md)
- [Technique Selector Python Module](../../scripts/technique_selector.py)
```

## Files to Create
- `.windsurf/knowledge/techniques/reasoning-selection.md`

## Files to Modify
- None

## Patterns to Follow
Reference: `.windsurf/knowledge/techniques/tot.md` - Follow similar structure

## Acceptance Criteria
- [ ] reasoning-selection.md exists in knowledge/techniques/
- [ ] Contains selection criteria for ToT and GoT
- [ ] Contains decision flowchart
- [ ] Contains category defaults table
- [ ] Contains characteristic overrides table
- [ ] Contains at least 3 examples
- [ ] References Python selector with usage examples
- [ ] Links to tot.md and got.md

## Testing Requirements

### Verification Script
```bash
# Check file exists
ls -la .windsurf/knowledge/techniques/reasoning-selection.md

# Check for key sections
grep -c "Selection Criteria\|Decision Flowchart\|Category Defaults\|Examples" \
  .windsurf/knowledge/techniques/reasoning-selection.md
# Should find 4+ matches

# Check for links
grep -c "tot.md\|got.md" .windsurf/knowledge/techniques/reasoning-selection.md
# Should find 2+ matches
```

## Verification Commands
```bash
# File exists and has content
wc -l .windsurf/knowledge/techniques/reasoning-selection.md

# Required sections present
grep -E "^## " .windsurf/knowledge/techniques/reasoning-selection.md

# Links work (files exist)
ls .windsurf/knowledge/techniques/tot.md .windsurf/knowledge/techniques/got.md
```

## Documentation Updates
- [ ] None (this step IS documentation)

## Error Recovery
If verification fails:
1. Check file path is correct
2. Ensure all required sections are present
3. Verify markdown formatting is valid
4. Check that linked files exist

## Do NOT
- Do NOT duplicate content from tot.md or got.md (reference instead)
- Do NOT make this file too long (keep focused on selection)
- Do NOT add code that should be in Python module
