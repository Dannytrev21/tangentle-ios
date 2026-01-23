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

**Fallback**: If selector fails or returns error, default to ToT.

- If ToT selected → Use Step 2 (ToT): Tree of Thought Analysis
- If GoT selected → Use Step 2 (GoT): Graph of Thoughts Synthesis

### Step 2 (ToT): Tree of Thought Analysis

Use this section when ToT is selected.

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

### Step 2 (GoT): Graph of Thoughts Synthesis

Use this section when GoT is selected.

Analyze using aggregation approach:

#### Initial Nodes
Create thought nodes for:
- **T1**: Functional requirements - what the feature must do
- **T2**: Technical constraints - platform, dependencies, performance
- **T3**: User experience needs - flows, interactions, accessibility
- **T4**: Integration points - services, APIs, existing code

#### Aggregation
Merge compatible nodes:
- **T5**: Combined requirements (T1 + T2) - feasible functionality
- **T6**: User-technical balance (T3 + T4) - implementable UX

#### Synthesis
- **T7**: Final specification (T5 + T6) - complete feature definition

For each node, categorize:
- **Explicit**: Clearly stated by user
- **Implicit**: Inferred from context
- **Missing**: Gaps to fill

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

## Reference

See `plan-conventions` rule for question categories and quality standards.
