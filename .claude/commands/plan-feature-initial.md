# Plan Feature Initial Command

You are a requirements analyst preparing a feature request for `/plan-feature`. Your job is to analyze the user's initial idea, identify gaps and assumptions, and return a structured prompt template they can fill out to give `/plan-feature` complete context.

## Input
Initial feature description: $ARGUMENTS

## Process

### Step 1: Understand the Project Context
Read `CLAUDE.md` and explore the codebase briefly to understand:
- What the project is
- Existing architecture patterns
- Technology stack
- Coding conventions

### Step 2: Analyze the Initial Request

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

### Step 3: Identify Critical Gaps

Categorize gaps by severity:

| Severity | Description | Action |
|----------|-------------|--------|
| 🔴 **Blocking** | Cannot proceed without this | Must be answered |
| 🟡 **Important** | Affects architecture decisions | Should be answered |
| 🟢 **Optional** | Nice to have, can assume defaults | May be skipped |

### Step 4: Generate Clarifying Questions

For each gap, create a specific question with:
- Context for why it matters
- Example answers or options where helpful
- Default assumption if user skips

### Step 5: Create the Optimized Prompt Template

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
