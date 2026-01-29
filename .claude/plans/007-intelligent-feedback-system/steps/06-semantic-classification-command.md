# Step 6: Semantic Classification Command

## Problem Type
`new-feature`

## Technique Selection
- **Planning**: tot - Multiple command design approaches
- **Implementation**: self-refine - Iterate on markdown command quality (not testable code)
- **Verification**: reflexion - Learn from classification errors

## Risk Level
**medium** - New user-facing command

## Retry Configuration
- Same technique: 3 attempts
- Alternative technique: 2 attempts
- Escalation: After 5 total failures

## Context
This step creates the `/classify` skill that uses Claude Code's understanding to classify problem descriptions. Instead of keyword matching, Claude analyzes the description semantically and returns a classification with confidence.

Key design decision: This is **interactive** (prompts Claude Code), not automated (no API calls). The user runs `/classify "description"` and Claude provides the classification.

## Goal
Create a `/classify` command that:
1. Takes a problem description
2. Prompts Claude to classify it
3. Shows classification with confidence
4. Allows user to confirm or correct
5. Records the classification for learning

## Prerequisites
- Step 2 (Persistence Layer) completed

## High-Level Steps
1. Create classify.md skill file
2. Define classification prompt structure
3. Implement classification recording
4. Add correction handling
5. Test with various descriptions

## Detailed Requirements

### /classify Command File

Create `.claude/commands/classify.md`:

```markdown
# Semantic Classification Command

You are classifying a problem description into one of the defined problem types.
This classification drives technique selection for planning.

## Input
Description to classify: $ARGUMENTS

## Classification Process

### Step 1: Understand the Problem Types

Read the problem type taxonomy from `.claude/technique-config.json`:
- FOUNDATION: infrastructure, scaffolding, configuration
- DATA: data-modeling, data-access, migration, state-mgmt
- ARCHITECTURE: system-design, protocol-design, di-setup, service-impl, refactor
- UI_UX: ui, component-lib, design-tokens, animation, gesture, accessibility, polish
- TESTING: test-setup, unit-test, integration-test, snapshot-test, e2e-test, performance-test
- LOGIC: algorithm, validation, api-integration, debug
- DOCUMENTATION: documentation, changelog
- META: ideation, new-feature

### Step 2: Analyze the Description

Think hard about the description:

1. **Primary Intent**: What is the user trying to accomplish?
2. **Domain**: Which category does this fall into?
3. **Keywords**: What technical terms are present?
4. **Scope**: Is this narrow (single type) or broad (multiple aspects)?
5. **Similar Past Tasks**: What does this remind you of?

### Step 3: Determine Classification

Based on your analysis:

1. Select the **primary** problem type
2. Identify any **secondary** types (if multi-faceted)
3. Assess **confidence** (0.0 to 1.0)
4. Write a brief **rationale**

### Step 4: Present Classification

```
═══════════════════════════════════════════════════════════════
  SEMANTIC CLASSIFICATION
═══════════════════════════════════════════════════════════════

  Description: "{original description}"

  Primary Type: {type}
  Category: {CATEGORY}
  Confidence: {confidence}%

  Rationale:
  {2-3 sentence explanation of why this classification}

  Secondary Types (if applicable):
  - {type2} ({confidence2}%) - {brief reason}

═══════════════════════════════════════════════════════════════

  Is this classification correct?

  Options:
  1. Yes, proceed with this classification
  2. No, it should be: {list all types}
  3. Let me specify: [type]

═══════════════════════════════════════════════════════════════
```

### Step 5: Handle Response

**If user confirms (option 1)**:
- Record classification in classification history
- Output confirmation and suggested techniques

**If user corrects (option 2 or 3)**:
- Record the correction for learning
- Update classification to user's choice
- Output confirmation with corrected classification

### Step 6: Record Classification

After confirmation/correction, save to classification history:

```python
# Save classification
from scripts.feedback_store import FeedbackStore
from scripts.feedback_models import ClassificationEntry
import hashlib

store = FeedbackStore()
entry = ClassificationEntry(
    id=str(uuid.uuid4()),
    description="{description}",
    description_hash=hashlib.sha256("{description}".encode()).hexdigest()[:16],
    classified_as="{final_type}",
    confidence={confidence},
    corrected_to="{correction or None}",
    correction_confidence={correction_confidence or 0.0},
    timestamp=datetime.now().isoformat(),
    source="semantic"  # or "user" if corrected
)
store.add_classification(entry)
```

### Step 7: Output Techniques

After recording:

```
═══════════════════════════════════════════════════════════════
  CLASSIFICATION RECORDED
═══════════════════════════════════════════════════════════════

  Type: {final_type}
  Category: {CATEGORY}

  Suggested Techniques:
  ┌─────────────┬────────────────────┐
  │ Planning    │ {technique}        │
  │ Implement   │ {technique}        │
  │ Verify      │ {technique}        │
  └─────────────┴────────────────────┘

  Use this classification in your /plan-feature prompt.

═══════════════════════════════════════════════════════════════
```

## Classification Guidelines

### High Confidence (>0.8)
- Clear technical terms match a type
- Description fits squarely in one category
- No ambiguity in intent

### Medium Confidence (0.5-0.8)
- Some ambiguity present
- Could fit multiple types
- Context would help clarify

### Low Confidence (<0.5)
- Very vague description
- New/unusual request type
- Recommend asking for clarification

### Common Patterns

| Pattern | Likely Type |
|---------|-------------|
| "Add a screen/view for..." | ui |
| "Fix the bug where..." | debug |
| "Refactor the..." | refactor |
| "Add tests for..." | unit-test |
| "Set up..." | infrastructure |
| "Create a new entity/model..." | data-modeling |
| "Integrate with API..." | api-integration |
| "Improve performance of..." | algorithm or performance-test |

## Examples

### Example 1: Clear Classification
Input: "Add unit tests for the TaskRepository"
- Type: unit-test
- Confidence: 95%
- Rationale: Explicitly mentions unit tests for a repository

### Example 2: Ambiguous (needs clarification)
Input: "Make the app faster"
- Type: algorithm (primary) or performance-test
- Confidence: 40%
- Rationale: "Faster" is vague - could be algorithm optimization,
  performance testing, or UI responsiveness. Asking for clarification.

### Example 3: Multi-faceted
Input: "Add a settings screen with persistence"
- Primary: ui (70%)
- Secondary: data-access (60%)
- Rationale: Creating UI for settings (ui) but also needs data persistence (data-access)
```

## Files to Create
- `.claude/commands/classify.md`: Classification skill

## Files to Modify
- None

## Patterns to Follow
Reference: `.claude/commands/plan-feature-initial.md` for interactive command pattern

## Acceptance Criteria
- [ ] Command prompts for classification
- [ ] Shows confidence and rationale
- [ ] Allows user correction
- [ ] Records classification to history
- [ ] Shows suggested techniques after recording
- [ ] Handles ambiguous cases gracefully

## Testing Requirements

### Manual Tests
- [ ] Test file: Manual test cases
- [ ] Test cases:
  - Clear debug description → debug type
  - Clear UI description → ui type
  - Ambiguous description → low confidence, asks clarification
  - User correction flow works
  - Recording persists to file

### What to Test
- Various problem types
- Edge cases (very short, very long descriptions)
- Correction flow
- Persistence

## Verification Commands
```bash
# Test command exists
cat .claude/commands/classify.md | head -20

# Test persistence file created after use
cat .claude/planning-data/classification-history.json | head -20
```

## Documentation Updates
- [ ] Add /classify to CLAUDE.md command list

## Error Recovery
If verification fails:
1. Check command file syntax
2. Verify persistence integration
3. Test with simple description first

## Do NOT
- Call Claude API directly
- Skip the confirmation step
- Auto-classify without user review
