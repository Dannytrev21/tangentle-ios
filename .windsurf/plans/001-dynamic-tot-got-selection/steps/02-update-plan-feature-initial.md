# Step 2: Update plan-feature-initial Workflow

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
The `/plan-feature-initial` workflow currently uses Tree of Thoughts for all analyses. This step updates it to dynamically select between ToT and GoT based on problem type, while offloading content to rules to stay under 12K chars.

## Goal
Update plan-feature-initial.md to:
1. Call Python selector to determine ToT or GoT
2. Use the selected technique for analysis
3. Offload common patterns to rules
4. Stay under 12K character limit

## Prerequisites
- Step 1 completed (Python reasoning selector exists)
- Step 4 completed (rules created for offloading)

## High-Level Steps
1. Read current workflow and identify content to offload
2. Add selection logic that calls Python script
3. Modify analysis section to use selected technique
4. Remove offloaded content (now in rules)
5. Verify character count < 12K
6. Test workflow functionality

## Detailed Requirements

### Selection Logic to Add
After Step 1 (Problem Classification), add:

```markdown
### Step 1.5: Select Reasoning Technique

Based on classification, select the optimal reasoning technique:

```bash
python3 .windsurf/scripts/windsurf_plan.py reasoning {problem_type} {category}
```

Display selection:
```
Reasoning Technique: {ToT|GoT}
Rationale: {rationale from selector}
```

If ToT selected, use Tree of Thought Analysis (Branch 1-5).
If GoT selected, use Graph of Thoughts Synthesis.
```

### ToT vs GoT Analysis Sections

**For ToT (exploration)**:
Keep existing Tree of Thought Analysis with 5 branches.

**For GoT (synthesis)**:
```markdown
### Step 2 (GoT): Graph of Thoughts Synthesis

Analyze using aggregation approach:

#### Initial Nodes
Create thought nodes for:
- T1: Functional requirements
- T2: Technical constraints
- T3: User experience needs
- T4: Integration points

#### Aggregation
Merge compatible nodes:
- T5: Combined requirements (T1 + T2)
- T6: User-technical balance (T3 + T4)

#### Synthesis
- T7: Final specification (T5 + T6)

For each node, categorize:
- **Explicit**: Clearly stated by user
- **Implicit**: Inferred from context
- **Missing**: Gaps to fill
```

### Content to Offload to Rules
Move to `.windsurf/rules/plan-conventions.md`:
- Question categories (Scope, UX, Data, Technical, Visual, etc.)
- Quality standards section
- Example analysis section

This should free ~1,500-2,000 chars.

### Character Budget
| Component | Before | After |
|-----------|--------|-------|
| Total | 6,709 | ~8,500 |
| Selection logic added | - | +1,200 |
| GoT section added | - | +800 |
| Offloaded to rules | - | -1,200 |
| Headroom | 5,291 | ~3,500 |

## Files to Create
- None

## Files to Modify
- `.windsurf/workflows/plan-feature-initial.md`: Add selection, add GoT, trim content

## Patterns to Follow
Reference: `.windsurf/workflows/plan-feature.md` - Follow existing workflow structure

## Acceptance Criteria
- [ ] Workflow calls Python selector after classification
- [ ] Displays selected technique (ToT or GoT) with rationale
- [ ] ToT analysis section retained for ToT selection
- [ ] GoT synthesis section added for GoT selection
- [ ] Common content offloaded to rules (references added)
- [ ] Total character count < 12,000
- [ ] Workflow YAML frontmatter preserved
- [ ] Workflow still produces valid /plan-feature input

## Testing Requirements

### Manual Testing
- [ ] Run `/plan-feature-initial Add REST API` - should select ToT
- [ ] Run `/plan-feature-initial Review documentation` - should select GoT
- [ ] Run `/plan-feature-initial Write unit tests` - should select GoT
- [ ] Verify output format matches expected structure

### Verification Script
```bash
# Check character count
wc -c .windsurf/workflows/plan-feature-initial.md
# Must be < 12000

# Check for selection logic
grep -c "reasoning_technique\|ToT\|GoT" .windsurf/workflows/plan-feature-initial.md
# Should find multiple matches

# Check frontmatter preserved
head -5 .windsurf/workflows/plan-feature-initial.md
# Should show --- and name/description
```

## Verification Commands
```bash
# Character count check
wc -c .windsurf/workflows/plan-feature-initial.md

# Syntax check (YAML frontmatter)
head -10 .windsurf/workflows/plan-feature-initial.md

# Integration test with classifier
python3 .windsurf/scripts/windsurf_plan.py classify "Add REST API"
python3 .windsurf/scripts/windsurf_plan.py reasoning api-integration ARCHITECTURE
```

## Documentation Updates
- [ ] None (workflow is self-documenting)

## Error Recovery
If verification fails:
1. Check character count - may need to offload more content
2. Verify Python selector is callable from workflow path
3. Check YAML frontmatter syntax
4. Ensure both ToT and GoT sections are properly formatted

## Fallback Behavior
**IMPORTANT**: If the Python selector fails (command not found, error, etc.), the workflow MUST fall back to ToT (Tree of Thoughts) as the default reasoning technique. This ensures the workflow never breaks due to script issues.

Add this fallback logic to the workflow:
```markdown
If selector fails or returns error, default to ToT.
```

## Do NOT
- Do NOT exceed 12,000 characters
- Do NOT remove YAML frontmatter
- Do NOT change the output format (must still produce /plan-feature input)
- Do NOT hardcode technique selection (must use Python selector)
