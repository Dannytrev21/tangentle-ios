# Chain of Code (CoC) Prompting

## Task: $ARGUMENTS

## Instructions

I will solve this by writing code that mixes executable logic with "LMulator" sections - where I emulate the output of functions that can't actually be compiled (semantic reasoning).

---

## Phase 1: Problem Analysis

**What parts require**:
- **Pure computation** (executable): [List - math, string manipulation, data structures]
- **Semantic reasoning** (LMulator): [List - understanding intent, classifying sentiment, interpreting meaning]
- **Mixed**: [List - parts that need both]

---

## Phase 2: Code Structure with LMulator Annotations

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
        # Emulated reasoning:
        # Given the original context was about [topic]
        # And our result is [summary]
        # This [is/is not] appropriate because [reason]
        return True  # or False with explanation
    
    if not is_response_appropriate(result, input_data):
        result = fallback_approach(parsed)
    
    # ===== EXECUTABLE: Format output =====
    return format_output(result)
```

---

## Phase 3: LMulator Execution Trace

For each LMulator function, I'll trace my reasoning:

### LMulator Call 1: `understand_intent(parsed['text'])`

**Input**: "[The actual parsed text]"

**Reasoning Process**:
1. First, I notice [observation 1]
2. This suggests [inference 1]
3. Additionally, [observation 2]
4. Combined, this indicates [conclusion]

**Emulated Output**: `"[specific intent classification]"`

---

### LMulator Call 2: `is_response_appropriate(result, original_context)`

**Input**: 
- result: "[The computed result]"
- original_context: "[The original input]"

**Reasoning Process**:
1. The original context was asking about [topic]
2. Our result addresses [what it addresses]
3. Checking alignment: [analysis]
4. Quality assessment: [assessment]

**Emulated Output**: `True` (because [reason])

---

## Phase 4: Concrete Executable Implementation

Now, translating the above into real, runnable code:

```python
# Real implementation with inline semantic reasoning

def solve_problem(input_data):
    # Executable parsing
    parsed = input_data.strip().split('\n')
    
    # For the semantic parts, we either:
    # Option A: Call an LLM API
    # Option B: Use heuristics that approximate the reasoning
    # Option C: Pre-compute the semantic parts and hardcode results
    
    # Here's Option B - heuristic approximation:
    def understand_intent(text):
        # Approximate semantic reasoning with keywords
        if any(word in text.lower() for word in ['help', 'how to', 'explain']):
            return 'help_request'
        elif any(word in text.lower() for word in ['error', 'bug', 'fix']):
            return 'debug_request'
        else:
            return 'general_request'
    
    intent = understand_intent(parsed[0])
    
    # Rest of executable logic...
    if intent == 'help_request':
        return generate_help_response(parsed)
    elif intent == 'debug_request':
        return generate_debug_response(parsed)
    else:
        return generate_general_response(parsed)
```

---

## Phase 5: Verification

**Test with examples**:

| Input | LMulator Reasoning | Executable Result | Final Output |
|-------|-------------------|-------------------|--------------|
| Example 1 | Intent: X | Computed: Y | Output: Z |
| Example 2 | Intent: A | Computed: B | Output: C |

**Mixed reasoning verification**:
- Semantic parts handled correctly? [Yes/No]
- Computational parts accurate? [Yes/No]
- Integration smooth? [Yes/No]

---

## Final Solution

```
[Complete implementation]
```

**Key insight**: The power of Chain of Code is recognizing which parts need semantic LLM reasoning vs. which parts need precise computation, and weaving them together seamlessly.
