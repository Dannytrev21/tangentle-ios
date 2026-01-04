# Chain of Code (CoC) Prompting

## Overview
Chain of Code mixes executable code logic with "LMulator" sections - where the AI emulates the output of functions that require semantic reasoning and can't be implemented with pure computation. This bridges the gap between what code can do and what language understanding provides.

This technique is powerful for tasks requiring both precise computation and semantic understanding.

## When to Use
- Tasks mixing logic/semantic reasoning (e.g., parsing intent)
- Template and scaffolding generation
- Migration scripts with semantic content adaptation
- E2E tests requiring behavior interpretation
- Any problem requiring both code execution and semantic judgment

## How It Works

### Phase 1: Problem Analysis
- Identify what parts require pure computation (executable)
- Identify what parts require semantic reasoning (LMulator)
- Identify mixed sections needing both

### Phase 2: Code Structure with LMulator Annotations
- Write code skeleton mixing executable and LMulator sections
- Mark LMulator functions clearly with annotations
- Define inputs/outputs for LMulator functions

### Phase 3: LMulator Execution Trace
- For each LMulator function, trace the reasoning process
- Show input, reasoning steps, and emulated output

### Phase 4: Concrete Implementation
- Translate to real runnable code
- Replace LMulator sections with heuristics, API calls, or hard-coded results

## Execution Instructions

```
## CHAIN OF CODE EXECUTION PROTOCOL

### Phase 1: Problem Analysis

**What parts require**:
- **Pure computation** (executable): [List - math, string manipulation, data structures]
- **Semantic reasoning** (LMulator): [List - understanding intent, classification, interpretation]
- **Mixed**: [List - parts that need both]

---

### Phase 2: Code Structure with LMulator Annotations

```python
def solve_problem(input_data):
    """
    Main solution combining executable code and LMulator reasoning.
    """

    # ===== EXECUTABLE: Parse input =====
    # This can run in a real interpreter
    parsed = parse_input(input_data)

    # ===== LMULATOR: Semantic understanding =====
    # This function doesn't exist - I'll emulate its output
    def understand_intent(text):
        """
        [LMULATOR] Determine what the user is trying to accomplish.
        Cannot be implemented with code alone - requires semantic reasoning.
        """
        # Emulated reasoning:
        # Looking at the text, the user seems to want...
        # Key indicators: [specific words/patterns noticed]
        # Therefore, the intent is: [classification]
        return "identified_intent"

    intent = understand_intent(parsed['text'])

    # ===== EXECUTABLE: Process based on intent =====
    if intent == "intent_type_1":
        result = process_type_1(parsed)
    elif intent == "intent_type_2":
        result = process_type_2(parsed)

    # ===== LMULATOR: Quality check =====
    def is_response_appropriate(result, original_context):
        """
        [LMULATOR] Verify the result makes sense in context.
        """
        # Emulated reasoning here
        return True

    return format_output(result)
```

---

### Phase 3: LMulator Execution Trace

For each LMulator function, trace the reasoning:

#### LMulator Call 1: `understand_intent(text)`

**Input**: "[The actual input text]"

**Reasoning Process**:
1. First, I notice [observation 1]
2. This suggests [inference 1]
3. Additionally, [observation 2]
4. Combined, this indicates [conclusion]

**Emulated Output**: `"specific_intent_classification"`

---

### Phase 4: Concrete Executable Implementation

```python
# Real implementation with inline semantic reasoning

def solve_problem(input_data):
    # Executable parsing
    parsed = input_data.strip().split('\n')

    # For semantic parts, options:
    # A: Call an LLM API
    # B: Use heuristics that approximate the reasoning
    # C: Pre-compute semantic parts and hardcode results

    # Here's Option B - heuristic approximation:
    def understand_intent(text):
        if any(word in text.lower() for word in ['help', 'how to']):
            return 'help_request'
        elif any(word in text.lower() for word in ['error', 'bug']):
            return 'debug_request'
        return 'general_request'

    intent = understand_intent(parsed[0])

    # Rest of executable logic...
    return process_by_intent(intent, parsed)
```

---

### Phase 5: Verification

**Test with examples**:
| Input | LMulator Reasoning | Executable Result | Final Output |
|-------|-------------------|-------------------|--------------|
| Example 1 | Intent: X | Computed: Y | Output: Z |

**Mixed reasoning verification**:
- Semantic parts handled correctly? [Yes/No]
- Computational parts accurate? [Yes/No]
- Integration smooth? [Yes/No]
```

## Example Application

**Task**: Parse user requests and route to appropriate handler

**Chain of Code Application**:
1. **Executable**: Parse request structure, extract fields
2. **LMulator**: Classify intent from natural language
3. **Executable**: Route to handler based on classification
4. **LMulator**: Validate response appropriateness
5. **Executable**: Format and return response

## Common Pitfalls
- Not clearly marking LMulator vs executable sections
- Making LMulator sections too complex
- Forgetting to trace LMulator reasoning
- Boundary between semantic and computational unclear
- Not providing concrete implementation alternatives
- Over-relying on LMulator when heuristics would work

## Verification Checklist
- [ ] Clear separation of executable and LMulator sections
- [ ] LMulator functions have defined inputs/outputs
- [ ] Reasoning traced for each LMulator call
- [ ] Concrete implementation provided
- [ ] Tested with real examples
- [ ] Integration between semantic and computational verified
