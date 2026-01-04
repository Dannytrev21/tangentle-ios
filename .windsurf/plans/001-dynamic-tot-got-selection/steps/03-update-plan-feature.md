# Step 3: Update plan-feature Workflow

## Problem Type
`service-impl`

## Technique Selection
- **Planning**: PS+ - Systematic workflow restructuring
- **Implementation**: Self-Refine - Iterate on workflow content and formatting
- **Verification**: TDD - Character count and structure validation

## Risk Level
**Medium** - Modifying core workflow; must stay under 12K chars

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
The `/plan-feature` workflow currently uses Tree of Thoughts for plan creation. This step updates it to dynamically select between ToT and GoT based on problem type, while offloading content to rules.

## Goal
Update plan-feature.md to:
1. Call Python selector to determine ToT or GoT for key decisions
2. Use the selected technique for major decisions
3. Offload common patterns to rules
4. Stay under 12K character limit

## Prerequisites
- Step 1 completed (Python reasoning selector exists)
- Step 4 completed (rules created for offloading)

## High-Level Steps
1. Read current workflow and identify content to offload
2. Add selection logic after Step 3 (Read Project Context)
3. Modify Step 4 (Tree of Thought Analysis) to be technique-aware
4. Add alternative GoT section for synthesis tasks
5. Remove offloaded content
6. Verify character count < 12K

## Detailed Requirements

### Selection Logic to Add
After Step 3 (Read Project Context), add:

```markdown
### Step 3.5: Select Reasoning Technique

Determine optimal technique for analyzing this feature:

```bash
# Get overall problem type
python3 .windsurf/scripts/windsurf_plan.py classify "{feature description}"

# Select reasoning technique
python3 .windsurf/scripts/windsurf_plan.py reasoning {type} {category}
```

Display:
```
Feature Analysis Technique: {ToT|GoT}
Rationale: {rationale}
```
```

### Modified Step 4
Replace current Step 4 with technique-aware version:

```markdown
### Step 4: Apply Reasoning Technique

#### If ToT Selected: Tree of Thought Analysis
For each major decision, document:

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | ... | ... | ... |
| B | ... | ... | ... |
| C | ... | ... | ... |

**Selected: Option {X}** - {Rationale}

Consider at minimum:
- Data storage approach
- API design
- UI/UX approach
- Testing strategy

#### If GoT Selected: Graph of Thoughts Synthesis
For each major decision, use aggregation:

**Initial Nodes**:
- T1: Requirement analysis
- T2: Technical constraints
- T3: Existing patterns

**Aggregation**:
- T4: Merge T1 + T2 for feasible requirements
- T5: Merge T4 + T3 for pattern-compliant approach

**Refinement**:
- T6: Final decision with rationale

Consider at minimum:
- How to integrate with existing patterns
- How to synthesize requirements
- How to aggregate test coverage
```

### Content to Offload to Rules
Move to `.windsurf/rules/plan-conventions.md`:
- Risk level table (Low/Medium/High/Critical with retry counts)
- Error recovery section (Plan Number Detection, Template Fill)
- Quality standards details

This should free ~1,000-1,500 chars.

### Character Budget
| Component | Before | After |
|-----------|--------|-------|
| Total | 7,960 | ~9,500 |
| Selection logic added | - | +500 |
| GoT section added | - | +1,200 |
| Offloaded to rules | - | -1,000 |
| Headroom | 4,040 | ~2,500 |

## Files to Create
- None

## Files to Modify
- `.windsurf/workflows/plan-feature.md`: Add selection, add GoT alternative, trim content

## Patterns to Follow
Reference: `.windsurf/workflows/plan-feature-initial.md` (from Step 2) - Follow same selection pattern

## Acceptance Criteria
- [ ] Workflow calls Python selector after reading context
- [ ] Displays selected technique with rationale
- [ ] Step 4 has both ToT and GoT sections
- [ ] Correct section used based on selection
- [ ] Common content offloaded to rules
- [ ] Total character count < 12,000
- [ ] YAML frontmatter preserved
- [ ] Plan artifacts generated correctly

## Testing Requirements

### Manual Testing
- [ ] Run `/plan-feature Add authentication system` - should use ToT
- [ ] Run `/plan-feature Review and update API docs` - should use GoT
- [ ] Verify plan.md includes correct technique reference
- [ ] Verify adr.md includes technique-appropriate analysis

### Verification Script
```bash
# Check character count
wc -c .windsurf/workflows/plan-feature.md
# Must be < 12000

# Check for both techniques
grep -c "ToT\|GoT\|Tree of Thought\|Graph of Thoughts" .windsurf/workflows/plan-feature.md
# Should find multiple matches

# Check frontmatter
head -5 .windsurf/workflows/plan-feature.md
```

## Verification Commands
```bash
# Character count check
wc -c .windsurf/workflows/plan-feature.md

# Validate YAML frontmatter
head -10 .windsurf/workflows/plan-feature.md

# Test plan generation would work (dry run analysis)
python3 .windsurf/scripts/windsurf_plan.py classify "Add user authentication"
python3 .windsurf/scripts/windsurf_plan.py reasoning service-impl ARCHITECTURE
```

## Documentation Updates
- [ ] None (workflow is self-documenting)

## Error Recovery
If verification fails:
1. Check character count - may need to offload more content
2. Verify both ToT and GoT sections are complete
3. Check that selection logic matches Step 2 pattern
4. Ensure plan artifacts still generate correctly

## Do NOT
- Do NOT exceed 12,000 characters
- Do NOT remove artifact generation logic (plan.md, adr.md, steps/, etc.)
- Do NOT change progress.json schema
- Do NOT break step file generation
