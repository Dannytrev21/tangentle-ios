---
name: plan-feature-initial
description: Requirements analysis for new features with AI-based problem classification
---

# Plan Feature Initial

Analyze a feature request to gather requirements, classify the problem type, and prepare a structured specification for `/plan-feature`.

## Instructions

When invoked with a feature description:

### Step 1: Problem Classification

Run the Python classifier:
```bash
python3 .windsurf/scripts/windsurf_plan.py classify "{description}"
```

Display classification:
```
═══════════════════════════════════════════════════════════════
  PROBLEM CLASSIFICATION
═══════════════════════════════════════════════════════════════
  Type: {type} (Category: {category})
  Confidence: {confidence}%

  Suggested Techniques:
  ┌─────────────┬────────────────────┐
  │ Planning    │ {planning_tech}    │
  │ Implement   │ {impl_tech}        │
  │ Verify      │ {verify_tech}      │
  └─────────────┴────────────────────┘
═══════════════════════════════════════════════════════════════
```

### Step 2: Tree of Thought Analysis

Analyze across 5 branches:

**WHAT (Scope & Features)**
- Core capabilities requested
- Edge cases to consider
- What is explicitly out of scope
- Must-haves vs nice-to-haves

**WHO (Users & Personas)**
- Primary user(s)
- User goals and pain points
- Technical skill level
- Accessibility needs

**HOW (Technical Approach)**
- Data models involved
- APIs/services needed
- UI components required
- Integrations required

**CONSTRAINTS (Limitations)**
- Platform requirements
- Performance requirements
- Dependencies to avoid
- Timeline/phase constraints

**SUCCESS (Metrics)**
- Definition of done
- Success measurements
- Acceptance criteria
- Testing requirements

For each branch, categorize findings:
- **Explicit**: Clearly stated by user
- **Implicit**: Inferred from context
- **Missing**: Critical gaps to fill
- **Ambiguous**: Multiple interpretations possible

### Step 3: Gap Identification

Categorize gaps by severity:

| Severity | Description | Action |
|----------|-------------|--------|
| 🔴 **Blocking** | Cannot plan without this | Must answer |
| 🟡 **Important** | Affects architecture | Should answer |
| 🟢 **Optional** | Has sensible defaults | May skip |

### Step 4: Generate Questions

For each gap, create a question with:
- Clear question text
- Context explaining why it matters
- Options where applicable
- Default suggestion if skipped

### Step 5: Output Generation

Generate analysis in this format:

```markdown
# Feature Analysis: {Feature Name}

## Problem Classification
- **Type**: {type} (Category: {category})
- **Confidence**: {confidence}%
- **Techniques**:
  | Phase | Technique |
  |-------|-----------|
  | Planning | {tech} |
  | Implementation | {tech} |
  | Verification | {tech} |

## Summary of Understanding
{2-3 paragraph summary of feature as understood}

### Assumptions Made
- {assumption 1}
- {assumption 2}

## Questions to Complete the Plan

### 🔴 Blocking Questions (Must Answer)

#### 0. Problem Type Confirmation
> The problem type affects techniques and plan structure.

Detected: **{type}** (Category: {category})

**Question**: Is this classification correct?
- [ ] Yes, correct
- [ ] No, it's: {alternatives}
- [ ] Other: ___

**Answer**: ___

---

#### 1. {Category}
> {Why this matters}

**Question**: {Question text}

**Options**:
- [ ] Option A
- [ ] Option B
- [ ] Other: ___

**Answer**: ___

---

### 🟡 Important Questions (Should Answer)

#### 2. {Category}
> {Context}

**Question**: {Question}

**Default if skipped**: {default}

**Answer**: ___

---

### 🟢 Optional Questions (May Skip)

#### 3. {Category}
> {Context}

**Question**: {Question}

**Default if skipped**: {default}

**Answer**: ___

---

## Ready to Proceed?

Once you've answered the questions, I'll generate the /plan-feature input.

**Confirm when ready**: (yes / edit / cancel)
```

### Step 6: Wait for User Response

- **yes**: Proceed to synthesize /plan-feature input
- **edit**: Allow modifications to answers
- **cancel**: Abort workflow

### Step 7: Synthesize /plan-feature Input

When user confirms, generate:

```markdown
/plan-feature {Feature Name}

## Problem Classification
- **Type**: {confirmed_type}
- **Category**: {category}
- **Risk Level**: {risk_level}

## Technique Selection
- **Planning**: {tech} - {rationale}
- **Implementation**: {tech} - {rationale}
- **Verification**: {tech} - {rationale}

## Overview
{Original description + clarifications}

## Scope

### Must Have (MVP)
- {from blocking questions}

### Should Have (v1.1)
- {from important questions}

### Won't Have (Future)
- {explicitly excluded}

## Technical Requirements

### Platform/Device
{Answer}

### Data Model
{Answer}

### UI/UX Approach
{Answer}

### Integrations
{Answer}

## Constraints
- {from constraint answers}

## Success Criteria
- [ ] {from success answers}

## Additional Context
{Other answers provided}
```

## Question Categories

Always check these areas for gaps:

**Scope**: MVP features, exclusions, phasing, existing features affected
**UX**: Primary flow, gestures, accessibility, error states
**Data**: New entities, existing data used, storage, sync
**Technical**: iOS version, dependencies, performance, offline behavior
**Visual**: Design spec, reusable components, new components, dark mode
**Integration**: Services, APIs, third-party, background processing
**Testing**: Coverage level, manual testing, edge cases, devices
**Rollout**: Feature flags, migration, rollback, analytics

## Example

**Input**: "Add a dark mode toggle to settings"

**Gap Analysis**:
- **Explicit**: Toggle in settings, enable dark mode
- **Implicit**: Uses system appearance API, persists preference
- **Missing**:
  - 🔴 Follow system or independent toggle?
  - 🟡 Animate transition?
  - 🟢 New Appearance section or existing Settings?
- **Ambiguous**: Pure black vs dark gray, schedule option scope

## Quality Standards

**Questions**: Specific, provide options, explain importance, give defaults
**Assumptions**: State explicitly, be conservative, allow overrides
**Output**: Complete, consistently formatted, copy-paste ready
