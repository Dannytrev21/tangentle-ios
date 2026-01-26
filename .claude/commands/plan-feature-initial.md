# Plan Feature Initial Command

You are a requirements analyst preparing a feature request for `/plan-feature`. Your job is to analyze the user's initial idea, identify gaps and assumptions, and return a structured prompt template they can fill out to give `/plan-feature` complete context.

## Key Principle
**Explore before you plan. Plan before you code.**

This command follows the guide's recommended workflow:
1. **Explore** - Read and understand relevant code
2. **Plan** - Create structured implementation plan
3. **Code** - Implement with clear direction
4. **Commit** - Checkpoint frequently

Never let Claude jump straight to planning without exploration.

## Input
Initial feature description: $ARGUMENTS

## Process
1. Understand the Project Context (read CLAUDE.md)
2. **Explore the Codebase** (read relevant files, document findings)
3. Classify Problem Type
4. Analyze the Initial Request
5. Identify Critical Gaps
6. Generate Clarifying Questions
7. Create the Optimized Prompt Template

### Step 1: Understand the Project Context
Read `CLAUDE.md` and explore the codebase briefly to understand:
- What the project is
- Existing architecture patterns
- Technology stack
- Coding conventions

### Step 1.5: Explore the Codebase
**Never jump straight to planning. Explore first.**

Before classifying the problem, gather context by reading relevant files.

#### 1. Read Relevant Files (Don't Write Code Yet)
Based on the feature description, identify and read files that might be affected:

```
Read the following without writing any code:
- Files that implement similar features
- Files that will be modified
- Tests for related functionality
- Configuration files that might be involved
```

**Be explicit**: "Read the [X] module and explain how [Y] is managed. Don't write any code yet."

#### 2. Document Exploration Findings
Before proceeding to classification, document what you learned:

```markdown
## Exploration Summary

### Files Reviewed
| File | Purpose | Relevance |
|------|---------|-----------|
| {path} | {what it does} | {why it matters for this feature} |

### Existing Patterns Found
- {pattern 1}: Found in {file}, could apply to this feature
- {pattern 2}: {description}

### Potential Impact Areas
- {area 1}: {why it might be affected}
- {area 2}: {why it might be affected}

### Questions Raised
- {question 1}
- {question 2}

### Initial Complexity Assessment
{simple/medium/complex} - {rationale}
```

#### 3. Proceed to Classification
Only after exploration is complete, proceed to classification.

**If exploration reveals the feature is significantly different than initially described**:
- Update understanding before classification
- Note any scope changes
- Flag potential risks discovered
- Consider asking user for clarification

### Step 2: Classify Problem Type (Semantic)

> **Note**: Complete Step 1.5 (Explore) before classification. Exploration findings inform accurate classification.

Before analyzing the request, classify the problem type using **semantic understanding** (not just keywords):

#### 2.1: Get Keyword Baseline
First, get the keyword-based suggestion as a starting point:

```bash
python3 .claude/scripts/tangentle_plan.py classify "$ARGUMENTS"
```

#### 2.2: Apply Semantic Analysis
Think hard about the description. Consider:

1. **Primary Intent**: What is the user fundamentally trying to accomplish?
   - Building something new vs. fixing something existing?
   - Structure, behavior, or presentation?
   - Data, logic, or interface?

2. **Domain Signals**: Which category does this naturally fall into?
   - Testing: tests, coverage, assertions, mocks
   - UI: screens, views, buttons, layout, visual
   - Data: models, entities, storage, queries
   - Logic: algorithms, validation, bugs, fixes
   - Architecture: services, protocols, patterns

3. **Override Keyword Results When**:
   - Description implies bug fix but keyword says otherwise (e.g., "users can't X" → `debug`)
   - Context from exploration suggests different type
   - Multi-word phrases change meaning (e.g., "test data" vs "test")

#### 2.3: Available Problem Types

| Category | Types |
|----------|-------|
| FOUNDATION | infrastructure, scaffolding, configuration |
| DATA | data-modeling, data-access, migration, state-mgmt |
| ARCHITECTURE | system-design, protocol-design, di-setup, service-impl, refactor |
| UI_UX | ui, component-lib, design-tokens, animation, gesture, accessibility, polish |
| TESTING | test-setup, unit-test, integration-test, snapshot-test, e2e-test, performance-test |
| LOGIC | algorithm, validation, api-integration, debug |
| DOCUMENTATION | documentation, changelog |
| META | ideation, new-feature |

#### 2.4: Determine Final Classification
Based on semantic understanding:
- **Primary Type**: The single best match
- **Confidence**: 0.0-1.0 (high if clear, low if ambiguous)
- **Risk Level**: low/medium/high
- **Secondary Types**: If multi-faceted, note others

**Semantic overrides keyword results** when your analysis indicates a better fit.

#### 2.5: Display Classification

```
===============================================================
  SEMANTIC CLASSIFICATION
===============================================================

  Description: "$ARGUMENTS"

  Primary Type: {primary_type}
  Category: {category}
  Confidence: {confidence}%

  Risk Level: {risk_level}

  Rationale:
  {2-3 sentence explanation of why this type, based on semantic analysis}

  Keyword classifier suggested: {keyword_type} ({keyword_confidence}%)
  Semantic analysis determined: {semantic_type} ({semantic_confidence}%)
  {If different: "Override reason: {why semantic is better}"}

  Suggested Techniques:
  +---------------+--------------------+
  | Phase         | Technique          |
  +---------------+--------------------+
  | Planning      | {planning_tech}    |
  | Implementation| {impl_tech}        |
  | Verification  | {verify_tech}      |
  +---------------+--------------------+

  Secondary Types (if applicable):
  - {alt1} ({confidence1}%) - {reason}
  - {alt2} ({confidence2}%) - {reason}

===============================================================
```

#### 2.6: Record Classification (for learning)

After displaying, record the classification:

```python
import sys
sys.path.insert(0, '.claude/scripts')
from feedback_store import FeedbackStore
from feedback_models import ClassificationEntry
import hashlib, uuid
from datetime import datetime

description = "$ARGUMENTS"
store = FeedbackStore()
store.ensure_directory()
entry = ClassificationEntry(
    id=str(uuid.uuid4()),
    description=description,
    description_hash=hashlib.sha256(description.lower().strip().encode()).hexdigest()[:16],
    classified_as="{primary_type}",
    confidence={confidence},
    corrected_to=None,  # Will be updated if user corrects
    correction_confidence=0.0,
    timestamp=datetime.now().isoformat(),
    source="semantic"
)
store.add_classification(entry)
```

Use this classification to inform your analysis and include it in the output template.

### Step 3: Analyze the Initial Request

Apply **Tree of Thought Analysis** to the feature request:

```
┌─────────────────────────────────────────────────────────────┐
│  TREE OF THOUGHT: Feature Analysis                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Branch 1: WHAT (Scope & Features)                          │
│  ├── What are the core capabilities?                        │
│  ├── What are the edge cases?                               │
│  ├── What is explicitly OUT of scope?                       │
│  └── What are the must-haves vs nice-to-haves?             │
│                                                              │
│  Branch 2: WHO (Users & Personas)                           │
│  ├── Who is the primary user?                               │
│  ├── What are their goals?                                  │
│  ├── What are their pain points?                            │
│  └── What accessibility needs exist?                        │
│                                                              │
│  Branch 3: HOW (Technical Approach)                         │
│  ├── What data models are involved?                         │
│  ├── What APIs/services are needed?                         │
│  ├── What UI components are needed?                         │
│  └── What integrations are required?                        │
│                                                              │
│  Branch 4: CONSTRAINTS (Limitations)                        │
│  ├── What platforms must be supported?                      │
│  ├── What performance requirements exist?                   │
│  ├── What dependencies should be avoided?                   │
│  └── What timeline/phase constraints exist?                 │
│                                                              │
│  Branch 5: SUCCESS (Metrics)                                │
│  ├── How do we know it's done?                             │
│  ├── How do we measure success?                             │
│  ├── What are the acceptance criteria?                      │
│  └── What testing is required?                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

For each branch, identify:
- **Explicit**: What the user clearly stated
- **Implicit**: What seems assumed but not stated
- **Missing**: What critical information is absent
- **Ambiguous**: What could be interpreted multiple ways

### Step 4: Identify Critical Gaps

Categorize gaps by severity:

| Severity | Description | Action |
|----------|-------------|--------|
| 🔴 **Blocking** | Cannot proceed without this | Must be answered |
| 🟡 **Important** | Affects architecture decisions | Should be answered |
| 🟢 **Optional** | Nice to have, can assume defaults | May be skipped |

### Step 5: Generate Clarifying Questions

For each gap, create a specific question with:
- Context for why it matters
- Example answers or options where helpful
- Default assumption if user skips

### Step 6: Create the Optimized Prompt Template

Output a structured template in this format:

---

## Output Format

```markdown
# Feature Analysis: {Feature Name}

## Summary of Understanding

Based on your description, here's what I understand:

{2-3 paragraph summary of the feature as understood}

### Assumptions I'm Making
- {assumption 1}
- {assumption 2}
- {assumption 3}

---

## Questions to Complete the Plan

### 🔴 Blocking Questions (Must Answer)

These questions must be answered before I can create a good plan:

#### 0. Problem Type Confirmation (Semantic Classification)
> The correct problem type affects which techniques are used and how the plan is structured.

I analyzed your description using **semantic classification**:

| Analysis | Result |
|----------|--------|
| **Primary Type** | {detected_type} |
| **Category** | {category} |
| **Confidence** | {confidence}% |
| **Risk Level** | {risk_level} |

**Rationale**: {2-3 sentences explaining why this type based on semantic analysis}

**Secondary Types**: {list any secondary types with confidence, or "None"}

**Question**: Is this classification correct?

**Options**:
- [ ] Yes, proceed with **{detected_type}**
- [ ] No, it should be: {list 3-4 alternative types from classification}
- [ ] Let me specify: _______________

**Your answer**: _______________

> Note: If you correct the classification, this helps improve future classifications.

---

#### 1. {Question Category}
> {Context for why this matters}

**Question**: {The actual question}

**Options** (if applicable):
- [ ] Option A: {description}
- [ ] Option B: {description}
- [ ] Option C: {description}
- [ ] Other: _______________

**Your answer**: _______________

---

#### 2. {Question Category}
> {Context}

**Question**: {Question}

**Your answer**: _______________

---

### 🟡 Important Questions (Should Answer)

These help me make better architectural decisions:

#### 3. {Question Category}
> {Context}

**Question**: {Question}

**Default if skipped**: {reasonable default}

**Your answer**: _______________

---

### 🟢 Optional Questions (May Skip)

These refine the plan but have sensible defaults:

#### 4. {Question Category}
> {Context}

**Question**: {Question}

**Default if skipped**: {default}

**Your answer**: _______________

---

## Optimized Prompt for /plan-feature

Once you've answered the questions above, copy this completed prompt to `/plan-feature`:

```
/plan-feature {Feature Name}

## Problem Classification
- **Type**: {confirmed_type from question 0}
- **Category**: {category}
- **Risk Level**: {risk_level from classifier}

## Technique Selection
- **Planning**: {planning_technique} - {brief rationale}
- **Implementation**: {impl_technique} - {brief rationale}
- **Verification**: {verify_technique} - {brief rationale}

## Overview
{Brief description from user's original input}

## Scope

### Must Have (MVP)
- {from blocking questions}
- {from blocking questions}

### Should Have (v1.1)
- {from important questions}

### Won't Have (Future)
- {explicitly excluded}

## Technical Requirements

### Platform/Device
{Answer from questions}

### Data Model
{Answer from questions}

### UI/UX Approach
{Answer from questions}

### Integrations
{Answer from questions}

## Constraints
- {from constraint questions}

## Success Criteria
- [ ] {from success questions}
- [ ] {from success questions}

## Additional Context
{Any other answers provided}
```

---

## How to Use This

1. **Answer the 🔴 Blocking questions** - These are required
2. **Answer 🟡 Important questions** - Or accept the defaults
3. **Skip 🟢 Optional questions** if defaults work
4. **Copy the completed prompt** to `/plan-feature`

---
```

## Question Categories to Consider

Always analyze these areas for gaps:

### Scope Questions
- What is the minimum viable version?
- What features are explicitly excluded?
- What's the phasing (v1 vs v2)?
- Are there existing features this replaces/enhances?

### User Experience Questions
- What's the primary user flow?
- What gestures/interactions are expected?
- What accessibility requirements exist?
- What error states need handling?

### Data Questions
- What new entities/models are needed?
- What existing data is consumed?
- Where is data stored (local/cloud)?
- What's the sync strategy?

### Technical Questions
- What iOS version minimum?
- What dependencies are acceptable?
- What performance targets exist?
- What's the offline behavior?

### Visual Design Questions
- Is there a design spec or reference?
- What existing components can be reused?
- What new components are needed?
- Dark mode requirements?

### Integration Questions
- What existing services are involved?
- What APIs are consumed/exposed?
- What third-party integrations exist?
- What background processing is needed?

### Testing Questions
- What level of test coverage is expected?
- What manual testing is required?
- What edge cases must be handled?
- What devices must be tested?

### Rollout Questions
- Is feature flagging needed?
- What's the migration strategy for existing data?
- What's the rollback plan?
- What analytics are needed?

## Example Analysis

### Input
> "Add a dark mode toggle to settings"

### Gap Analysis

**Explicit**:
- Add toggle to settings
- Enable dark mode

**Implicit (assumptions)**:
- Uses system appearance API
- Persists preference
- Applies app-wide

**Missing (questions needed)**:
- 🔴 Follow system setting or independent toggle?
- 🟡 Animate the transition or instant switch?
- 🟡 Any screens with special dark mode treatment?
- 🟢 Add to existing Settings screen or new Appearance section?

**Ambiguous**:
- "Dark mode" could mean pure black or dark gray
- Scope of "toggle" could include schedule option

## Quality Standards

### For Questions
- Be specific, not vague
- Provide options where possible
- Explain why the question matters
- Give sensible defaults for non-blocking questions

### For the Optimized Prompt
- Include all answered information
- Maintain consistent formatting
- Group related information
- Make it copy-paste ready for `/plan-feature`

### For Assumptions
- State assumptions explicitly
- Make conservative assumptions
- Allow user to override any assumption

## Tone

- Collaborative, not interrogating
- Helpful explanations for technical questions
- Acknowledge what the user already provided
- Make it easy to skip optional questions
