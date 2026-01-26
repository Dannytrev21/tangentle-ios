# Semantic Classification Command

You are classifying a problem description into one of the defined problem types using semantic understanding, not just keyword matching. This classification drives technique selection for planning.

## Input
Description to classify: $ARGUMENTS

## Problem Type Taxonomy

Before classifying, understand the available types:

### FOUNDATION
- `infrastructure`: Core setup (build systems, CI/CD, tooling)
- `scaffolding`: Project structure, boilerplate generation
- `configuration`: Config files, settings, environment setup

### DATA
- `data-modeling`: Core Data models, entity relationships, schemas
- `data-access`: Repository pattern, CRUD operations, queries
- `migration`: Data migrations, schema updates, transformations
- `state-mgmt`: State management, observable patterns, data flow

### ARCHITECTURE
- `system-design`: High-level architecture, component design
- `protocol-design`: Protocol definitions, interfaces, contracts
- `di-setup`: Dependency injection container and setup
- `service-impl`: Service layer, business logic services
- `refactor`: Code refactoring, restructuring, cleanup

### UI_UX
- `ui`: General UI implementation, views, screens
- `component-lib`: Reusable component library, design system
- `design-tokens`: Colors, typography, spacing, theme tokens
- `animation`: Animations, transitions, motion design
- `gesture`: Gesture handlers, touch interactions
- `accessibility`: VoiceOver, dynamic type, accessibility features
- `polish`: UI refinements, visual improvements

### TESTING
- `test-setup`: Test infrastructure, mocks, fixtures
- `unit-test`: Unit tests for individual functions/classes
- `integration-test`: Integration tests across components
- `snapshot-test`: UI snapshot tests for visual regression
- `e2e-test`: End-to-end tests with full app simulation
- `performance-test`: Performance and benchmark tests

### LOGIC
- `algorithm`: Algorithm implementation, data structures
- `validation`: Input validation, form validation
- `api-integration`: API client, network calls, OAuth, authentication
- `debug`: Bug fixing, debugging, issue resolution

### DOCUMENTATION
- `documentation`: README, guides, API docs
- `changelog`: Changelog updates, release notes

### META
- `ideation`: Brainstorming, exploration, concept development
- `new-feature`: General new feature (default fallback)

## Classification Process

### Step 0: Check for Learned Classification
First, check if we have learned a classification from similar past descriptions:

```python
import sys
sys.path.insert(0, '.claude/scripts')
from feedback_store import FeedbackStore
from classification_history import ClassificationHistory

store = FeedbackStore()
store.ensure_directory()
history = ClassificationHistory(store)

learned = history.get_learned_classification("$ARGUMENTS")
if learned:
    learned_type, confidence, rationale = learned
    print(f"Learned classification: {learned_type} ({confidence:.0%})")
    print(f"Rationale: {rationale}")
else:
    print("No learned classification found")
```

**If a learned classification is found** with confidence > 0.7, use it as the primary suggestion but still allow user confirmation.

### Step 1: Read Keyword-Based Suggestion
Get the keyword-based classification as a baseline:

```bash
python3 .claude/scripts/problem_classifier.py "$ARGUMENTS"
```

This provides a baseline. Compare with learned classification if available.

### Step 2: Semantic Analysis

Think hard about the description considering:

1. **Primary Intent**: What is the user fundamentally trying to accomplish?
   - Is this building something new or fixing something existing?
   - Is this about structure, behavior, or presentation?
   - Is this about data, logic, or interface?

2. **Domain Signals**: Which category does this naturally fall into?
   - Testing: mentions tests, coverage, assertions, mocks
   - UI: mentions screens, views, buttons, layout, visual
   - Data: mentions models, entities, storage, queries
   - Logic: mentions algorithms, validation, bugs, fixes
   - Architecture: mentions services, protocols, patterns

3. **Complexity Indicators**: How complex is this?
   - Single file vs. multi-file
   - Isolated vs. integrated
   - New vs. modification

4. **Risk Assessment**: What could go wrong?
   - Data loss potential
   - Breaking change potential
   - User-facing impact

### Step 3: Determine Final Classification

Based on semantic understanding:

1. **Primary Type**: The single best match
2. **Confidence**: 0.0 to 1.0 based on how certain you are
3. **Rationale**: 2-3 sentences explaining why
4. **Secondary Types**: If multi-faceted, list others that apply

### Step 4: Get Techniques

Look up techniques for the classification:

```bash
python3 .claude/scripts/tangentle_plan.py techniques {primary_type}
```

### Step 5: Present Classification

Output this format:

```
===============================================================
  SEMANTIC CLASSIFICATION
===============================================================

  Description: "{original description}"

  Primary Type: {type}
  Category: {CATEGORY}
  Confidence: {confidence}%

  Risk Level: {low/medium/high}

  Rationale:
  {2-3 sentence explanation of why this classification}

  Secondary Types (if applicable):
  - {type2} ({confidence2}%) - {brief reason}

  Suggested Techniques:
  +---------------+--------------------------------------------+
  | Phase         | Technique                                  |
  +---------------+--------------------------------------------+
  | Planning      | {planning_technique}                       |
  | Implementation| {impl_technique}                           |
  | Verification  | {verify_technique}                         |
  +---------------+--------------------------------------------+

===============================================================

  Is this classification correct?

  Options:
  1. Yes, proceed with this classification
  2. No, let me specify the correct type

===============================================================
```

### Step 6: Handle User Response

Use the AskUserQuestion tool with:
- **Question**: "Is this classification correct?"
- **Options**:
  1. "Yes, proceed" - Confirm classification
  2. "No, specify type" - User will provide correct type

**If user confirms (option 1)**:
- Record classification in history
- Output confirmation with techniques

**If user specifies different type (option 2)**:
- Ask which type using AskUserQuestion with all available types
- Record the correction for learning
- Update classification to user's choice

### Step 7: Record Classification

After confirmation/correction, save to classification history using ClassificationHistory:

```python
# Execute this to record the classification
import sys
sys.path.insert(0, '.claude/scripts')

from feedback_store import FeedbackStore
from classification_history import ClassificationHistory

description = "{the original description}"
final_type = "{the final type after confirmation/correction}"
original_type = "{the type that was suggested}"
confidence = {confidence as float, e.g., 0.85}
was_corrected = {True if user corrected, False if confirmed}

store = FeedbackStore()
store.ensure_directory()
history = ClassificationHistory(store)

# Add the classification
if was_corrected:
    # Record original classification first
    entry = history.add_classification(
        description=description,
        classified_as=original_type,
        confidence=confidence,
        source="semantic"
    )
    # Then record the correction (enables learning)
    history.record_correction(entry.id, final_type)
    print(f"Correction recorded: {original_type} -> {final_type}")
    print("This will help improve future classifications!")
else:
    # Just record the confirmed classification
    entry = history.add_classification(
        description=description,
        classified_as=final_type,
        confidence=confidence,
        source="semantic"
    )
    print(f"Classification recorded: {final_type}")
```

**Learning Note**: When users correct classifications, the system learns from these corrections. Future similar descriptions will suggest the corrected type.

### Step 8: Output Final Confirmation

```
===============================================================
  CLASSIFICATION RECORDED
===============================================================

  Type: {final_type}
  Category: {category}

  Techniques for this type:
  +---------------+--------------------------------------------+
  | Planning      | {planning} - {brief description}           |
  | Implementation| {impl} - {brief description}               |
  | Verification  | {verify} - {brief description}             |
  +---------------+--------------------------------------------+

  Risk Level: {risk_level}
  Thinking Keyword: "{thinking_keyword}"

  Next Steps:
  - Use `/plan-feature-initial {description}` to start planning
  - Or use `/plan-feature {description}` if requirements are clear

===============================================================
```

## Classification Guidelines

### High Confidence (>0.8)
- Clear technical terms match a single type
- Description fits squarely in one category
- No ambiguity in intent
- Example: "Add unit tests for the AuthService" -> `unit-test` (95%)

### Medium Confidence (0.5-0.8)
- Some ambiguity present
- Could fit multiple types reasonably
- Context would help clarify
- Example: "Improve the settings screen" -> `ui` (70%) or `polish` (60%)

### Low Confidence (<0.5)
- Very vague description
- New/unusual request type
- Recommend asking for clarification
- Example: "Make it better" -> ask for more detail

### Common Patterns

| Pattern | Likely Type | Why |
|---------|-------------|-----|
| "Add a screen/view for..." | ui | Creating new UI |
| "Fix the bug where..." | debug | Bug resolution |
| "Refactor the..." | refactor | Code restructuring |
| "Add tests for..." | unit-test | Test creation |
| "Set up..." | infrastructure | Foundation work |
| "Create a new entity/model..." | data-modeling | Data structures |
| "Integrate with API..." | api-integration | External services |
| "Improve performance of..." | algorithm | Optimization |
| "Add authentication/OAuth" | api-integration | Auth is API work |
| "Migration from X to Y" | migration | Data migration |

### Edge Cases

**Very Short Descriptions** (e.g., "Fix bug"):
- Ask for more detail before classifying
- Confidence should be low (<0.5)

**Very Long Descriptions**:
- Identify the primary intent
- Note secondary aspects but focus on main goal

**Multi-faceted Tasks**:
- Pick the primary type based on what comes first/main goal
- List secondary types with lower confidence
- Example: "Add settings screen with data persistence"
  - Primary: `ui` (creating the screen)
  - Secondary: `data-access` (persistence layer)

## Do NOT
- Auto-classify without showing reasoning
- Skip the confirmation step
- Use only keyword matching (that's what problem_classifier.py does)
- Implement learning from corrections (that's Step 7)
- Record without user confirmation

## Examples

### Example 1: Clear Classification
**Input**: `/classify "Add unit tests for the TaskRepository"`

**Analysis**:
- Intent: Write tests for existing code
- Domain: TESTING
- Keyword signals: "unit tests", "Repository"
- Complexity: Low (tests for existing code)

**Output**: `unit-test` at 95% confidence

### Example 2: Needs Semantic Understanding
**Input**: `/classify "Users can't log in after the update"`

**Keyword classifier** might say: `api-integration` (matches "log in")

**Semantic understanding** says: This is a **bug fix** (`debug`)
- "can't" indicates something is broken
- "after the update" indicates regression
- This is about fixing, not building

**Output**: `debug` at 90% confidence

### Example 3: Ambiguous
**Input**: `/classify "Make the app faster"`

**Analysis**:
- Intent: Improve performance (vague)
- Could be: algorithm optimization, UI performance, database queries
- Confidence: Low

**Output**: Ask for clarification
- "What aspect is slow? (UI responsiveness, data loading, specific feature)"

### Example 4: Multi-faceted
**Input**: `/classify "Add a settings screen with dark mode toggle that persists"`

**Analysis**:
- Primary: Creating a UI screen (`ui`)
- Secondary: Persisting preference (`data-access`)
- Secondary: Theme handling (`design-tokens`)

**Output**:
- Primary: `ui` at 75%
- Secondary: `data-access` at 60%, `design-tokens` at 50%
