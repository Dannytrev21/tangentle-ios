# Step 3: Thinking Keywords Config & Utility

> **Scope Clarification**: This step implements ALL thinking keyword functionality (config, utils, TechniqueSelector). Step 11 only adds the CLI command.

## Problem Type
`configuration`

## Technique Selection
- **Planning**: react - Interactive development with immediate feedback
- **Implementation**: self-refine - Iteratively improve function quality
- **Verification**: tdd - Unit tests verify correct mapping

## Risk Level
**low** - Adding new utility functions, no modification to existing logic

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Reasoning Depth
**Think about** the mapping logic and edge cases.

## Context
The guide describes thinking keywords that control reasoning depth. This step creates utility functions to map risk levels to appropriate thinking keywords, which will be used by prompt generation.

## Goal
Create Python utility functions that map risk levels to thinking keywords for embedding in generated prompts.

## Prerequisites
- None (independent utility)

## High-Level Steps
1. Add thinking keyword mapping to technique-config.json
2. Create utility function in utils.py
3. Add function to technique_selector.py for integration
4. Write unit tests for mapping
5. Verify all tests pass

## Detailed Requirements

### Mapping Logic
```python
def get_thinking_keyword(risk_level: str) -> str:
    """
    Map risk level to appropriate thinking keyword.

    Args:
        risk_level: One of "low", "medium", "high", "critical"

    Returns:
        Thinking keyword phrase for prompt embedding
    """
    mapping = {
        "low": "Think about",
        "medium": "Think hard about",
        "high": "Ultrathink about",
        "critical": "Ultrathink about"
    }
    return mapping.get(risk_level.lower(), "Think hard about")
```

### technique-config.json Addition
```json
{
  "thinkingKeywords": {
    "low": "Think about",
    "medium": "Think hard about",
    "high": "Ultrathink about",
    "critical": "Ultrathink about"
  },
  "thinkingKeywordDescriptions": {
    "Think about": "Standard reasoning depth",
    "Think hard about": "Increased reasoning allocation",
    "Ultrathink about": "Maximum reasoning budget (~31,999 tokens)"
  }
}
```

### Integration with TechniqueSelector
Add method to TechniqueSelector class:
```python
def get_thinking_keyword_for_step(self, step_info: dict) -> str:
    """Get thinking keyword based on step's risk level."""
    risk_level = step_info.get("riskLevel", "medium")
    return get_thinking_keyword(risk_level)
```

## Files to Create
- None

## Files to Modify
- `.claude/technique-config.json`: Add thinkingKeywords mapping
- `.claude/scripts/utils.py`: Add get_thinking_keyword function
- `.claude/scripts/technique_selector.py`: Add integration method
- `.claude/scripts/test_technique_selector.py`: Add unit tests

## Patterns to Follow
Reference: `.claude/scripts/technique_selector.py` for existing patterns
Reference: `.claude/scripts/test_technique_selector.py` for test patterns

## Acceptance Criteria
- [ ] technique-config.json has thinkingKeywords section
- [ ] get_thinking_keyword function exists in utils.py
- [ ] Function correctly maps all risk levels
- [ ] TechniqueSelector has get_thinking_keyword_for_step method
- [ ] All unit tests pass
- [ ] Unknown risk levels default to "think about"

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/scripts/test_thinking_keywords.py` or in existing test file
- [ ] Test cases:
  - `test_get_thinking_keyword_low_returns_think_about()`
  - `test_get_thinking_keyword_medium_returns_think_hard()`
  - `test_get_thinking_keyword_high_returns_ultrathink()`
  - `test_get_thinking_keyword_critical_returns_ultrathink()`
  - `test_get_thinking_keyword_unknown_returns_default()`
  - `test_get_thinking_keyword_case_insensitive()`

### What to Test
- All valid risk levels return correct keyword
- Unknown risk level returns safe default
- Case insensitivity (LOW, Low, low all work)
- Integration with TechniqueSelector

## Verification Commands
```bash
# Run unit tests
cd .claude/scripts && python3 -m pytest test_technique_selector.py -v -k thinking

# Or run all tests
cd .claude/scripts && python3 -m pytest -v

# Verify config has new section
grep -A5 "thinkingKeywords" .claude/technique-config.json

# Test function directly
cd .claude/scripts && python3 -c "
from utils import get_thinking_keyword
print(get_thinking_keyword('low'))
print(get_thinking_keyword('medium'))
print(get_thinking_keyword('high'))
print(get_thinking_keyword('critical'))
print(get_thinking_keyword('unknown'))
"
```

## Documentation Updates
- [ ] Update step notes in progress.json

## Error Recovery
If verification fails:
1. Check test output for specific failures
2. Verify function signature matches expected
3. Ensure technique-config.json is valid JSON
4. Re-run tests

## Do NOT
- Modify existing risk assessment logic
- Change existing technique selection behavior
- Add complexity beyond simple mapping
