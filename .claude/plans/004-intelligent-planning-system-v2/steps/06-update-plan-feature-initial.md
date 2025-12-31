# Step 6: Update plan-feature-initial

## Context
With the core scripts ready, we can now upgrade the planning commands. Starting with `/plan-feature-initial`, we'll add problem type detection and confirmation.

## Goal
Update the `/plan-feature-initial` command to detect problem types, suggest techniques, and output a more intelligent requirements template.

## Problem Type
`refactor`

## Technique Selection
- **Planning**: PS+ (structured modification planning)
- **Implementation**: Self-Refine (iterate on prompt quality)
- **Verification**: TDD (test command behavior)

## Risk Level
**Low** - Modifying a non-critical planning step

## Prerequisites
- Steps 1-5 completed (config and scripts ready)

## High-Level Steps
1. Analyze current plan-feature-initial.md
2. Add problem type detection section
3. Add technique suggestion section
4. Update Tree of Thought analysis with technique considerations
5. Modify output template to include technique metadata
6. Add confirmation workflow for detected type
7. Test the updated command

## Detailed Requirements

### Current Command Flow
1. Read CLAUDE.md
2. Analyze request with Tree of Thought
3. Identify gaps
4. Generate questions
5. Create optimized prompt template

### New Command Flow
1. Read CLAUDE.md
2. **NEW: Classify problem type using Python script**
3. **NEW: Get technique suggestions for detected type**
4. Analyze request with Tree of Thought (enhanced with type info)
5. Identify gaps (including technique-specific gaps)
6. Generate questions (including technique confirmation)
7. Create optimized prompt template (with technique metadata)

### Changes to plan-feature-initial.md

```markdown
# Plan Feature Initial Command (Updated)

## Step 1.5: Classify Problem Type (NEW)

Before analyzing the request, classify the problem type:

\`\`\`bash
# Run classifier
python3 .claude/scripts/problem_classifier.py --description "$ARGUMENTS"
\`\`\`

This returns:
- Primary type and category
- Confidence score
- Alternative types
- Suggested techniques

### Display Classification
\`\`\`
═══════════════════════════════════════════════════════════════
  PROBLEM CLASSIFICATION
═══════════════════════════════════════════════════════════════

  Detected Type: [primary_type] (Category: [category])
  Confidence: [confidence]%

  Suggested Techniques:
  ┌─────────────┬────────────────────┐
  │ Phase       │ Technique          │
  ├─────────────┼────────────────────┤
  │ Planning    │ [planning_tech]    │
  │ Implement   │ [impl_tech]        │
  │ Verify      │ [verify_tech]      │
  └─────────────┴────────────────────┘

  Alternatives considered:
  - [alt1] (confidence%)
  - [alt2] (confidence%)

═══════════════════════════════════════════════════════════════
\`\`\`

### Add to Questions
\`\`\`markdown
### Problem Type Confirmation

Based on your description, I classified this as a **[type]** problem.

**Question**: Is this classification correct?

**Options**:
- [ ] Yes, this is correct
- [ ] No, it's actually: [alternatives listed]
- [ ] Other: _______________

**Your answer**: _______________
\`\`\`

## Updated Output Template

The optimized prompt should include:

\`\`\`markdown
/plan-feature {Feature Name}

## Problem Classification
- **Type**: [confirmed_type]
- **Category**: [category]
- **Risk Level**: [risk_level]

## Technique Selection
- **Planning**: [technique] - [rationale]
- **Implementation**: [technique] - [rationale]
- **Verification**: [technique] - [rationale]

## Overview
{Brief description}

... rest of template ...
\`\`\`
```

### Integration with Python Script

```bash
# In the command, call the classifier
CLASSIFICATION=$(python3 -c "
import sys
sys.path.insert(0, '.claude/scripts')
from problem_classifier import ProblemClassifier
from technique_selector import TechniqueSelector, Phase

classifier = ProblemClassifier()
selector = TechniqueSelector()

result = classifier.classify('$ARGUMENTS')

techniques = {
    'planning': selector.select_techniques(result.primary_type, Phase.PLANNING),
    'implementation': selector.select_techniques(result.primary_type, Phase.IMPLEMENTATION),
    'verification': selector.select_techniques(result.primary_type, Phase.VERIFICATION),
}

print(f'Type: {result.primary_type}')
print(f'Category: {result.primary_category}')
print(f'Confidence: {result.confidence:.0%}')
print(f'Planning: {techniques[\"planning\"].primary}')
print(f'Implementation: {techniques[\"implementation\"].primary}')
print(f'Verification: {techniques[\"verification\"].primary}')
")
```

## Files to Create
- None (modifying existing)

## Files to Modify
- `.claude/commands/plan-feature-initial.md`: Add classification and technique suggestion

## Patterns to Follow
Reference: Current plan-feature-initial.md structure (lines 1-328)

## Acceptance Criteria
- [ ] Problem type is detected automatically
- [ ] Confidence score is displayed
- [ ] Techniques are suggested for each phase
- [ ] User can confirm or override classification
- [ ] Output template includes technique metadata
- [ ] Command works without Python scripts (fallback)

## Testing Requirements

### Manual Testing
- [ ] Run `/plan-feature-initial Add a new login screen` and verify:
  - Classification shows "ui"
  - Techniques suggested match config
  - Confirmation question appears
- [ ] Run `/plan-feature-initial Fix the crash when saving` and verify:
  - Classification shows "debug"
  - Reflexion suggested for verification

### Integration Test
```bash
# Simulate the command
echo "Add OAuth authentication" | python3 -c "
import sys
sys.path.insert(0, '.claude/scripts')
from problem_classifier import ProblemClassifier
c = ProblemClassifier()
desc = sys.stdin.read().strip()
result = c.classify(desc)
assert result.primary_type in ['new-feature', 'api-integration']
print('Classification test passed')
"
```

## Verification Commands
```bash
# Check command file was updated
grep -q "problem_classifier" .claude/commands/plan-feature-initial.md && echo "Classifier integrated"

# Check technique section exists
grep -q "Technique Selection" .claude/commands/plan-feature-initial.md && echo "Technique section added"
```

## Documentation Updates
- [ ] Update command description in CLAUDE.md

## Error Recovery
If classification fails:
1. Fall back to asking user directly
2. Log error for debugging
3. Continue with manual type selection

## Do NOT
- Remove existing Tree of Thought analysis
- Make Python scripts required (must have fallback)
- Change the core question format
