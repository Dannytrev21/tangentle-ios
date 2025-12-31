# Step 1: Technique Config Schema

## Context
This is the foundation step that defines the data structures used by all other components. The technique configuration schema determines how problem types map to techniques across phases.

## Goal
Create a comprehensive JSON schema and default configuration file that maps problem types to prompt engineering techniques.

## Problem Type
`configuration`

## Technique Selection
- **Planning**: PS+ (clear schema design benefits from structured planning)
- **Implementation**: Self-Refine (iterate on schema completeness)
- **Verification**: TDD (validate schema with test cases)

## Risk Level
**Low** - Self-contained, no dependencies, easy to modify

## Prerequisites
- None (this is the first step)

## High-Level Steps
1. Design the JSON schema structure
2. Define all problem types in hierarchical taxonomy
3. Map each problem type to techniques for each phase
4. Define risk levels per problem type
5. Add metadata fields (descriptions, examples)
6. Create the default configuration file
7. Write schema validation logic

## Detailed Requirements

### Schema Structure
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "version": "1.0.0",
  "problemTypes": {
    "<category>": {
      "description": "string",
      "subtypes": {
        "<subtype>": {
          "description": "string",
          "keywords": ["array", "of", "detection", "keywords"],
          "riskLevel": "low|medium|high",
          "techniques": {
            "planning": "<technique-id>",
            "implementation": ["<technique-id>", "<technique-id>"],
            "verification": "<technique-id>"
          },
          "retryConfig": {
            "maxAttempts": 3,
            "escalationPath": ["same", "alternative", "user"]
          }
        }
      }
    }
  },
  "techniques": {
    "<technique-id>": {
      "name": "string",
      "description": "string",
      "promptTemplate": "path/to/template.md",
      "costLevel": "low|medium|high",
      "bestFor": ["list", "of", "use", "cases"]
    }
  },
  "defaults": {
    "unknownProblemType": "new-feature",
    "defaultRiskLevel": "medium",
    "maxTotalRetries": 5
  }
}
```

### Problem Type Categories
```
FOUNDATION:
  - infrastructure
  - scaffolding
  - configuration

DATA:
  - data-modeling
  - data-access
  - migration
  - state-mgmt

ARCHITECTURE:
  - system-design
  - protocol-design
  - di-setup
  - service-impl
  - refactor

UI_UX:
  - ui
  - component-lib
  - design-tokens
  - animation
  - gesture
  - accessibility
  - polish

TESTING:
  - test-setup
  - unit-test
  - integration-test
  - snapshot-test
  - e2e-test
  - performance-test

LOGIC:
  - algorithm
  - validation
  - api-integration
  - debug

DOCUMENTATION:
  - documentation
  - changelog

META:
  - ideation
  - new-feature
```

### Technique Definitions
```
tot - Tree of Thoughts
got - Graph of Thoughts
reflexion - Reflexion with memory
self-consistency - Multiple solutions voting
self-refine - Iterative refinement
tdd - Test-Driven Development
react - Reasoning + Acting
ps-plus - Plan and Solve Plus
chain-of-code - Code + semantic mixing
least-to-most - Decomposition
```

## Files to Create
- `.claude/technique-config.json`: The main configuration file
- `.claude/schemas/technique-config.schema.json`: JSON schema for validation

## Files to Modify
- None

## Patterns to Follow
Reference existing config patterns in the codebase for JSON structure conventions.

## Acceptance Criteria
- [ ] JSON schema is valid and complete
- [ ] All 22+ problem types are defined with full metadata
- [ ] All 10 techniques are defined with metadata
- [ ] Each problem type has techniques for all 3 phases
- [ ] Risk levels are assigned appropriately
- [ ] Retry configurations are defined
- [ ] Keywords for classification are comprehensive
- [ ] Schema validates successfully

## Testing Requirements

### Unit Tests
- [ ] Test file: `TangentleTests/Unit/Planning/TechniqueConfigTests.swift` (if needed)
- [ ] For this step, validation is primarily schema-based

### Validation Tests
```bash
# Validate JSON syntax
python3 -c "import json; json.load(open('.claude/technique-config.json'))"

# Validate schema compliance
python3 -c "
import json
from jsonschema import validate
config = json.load(open('.claude/technique-config.json'))
schema = json.load(open('.claude/schemas/technique-config.schema.json'))
validate(config, schema)
print('Schema validation passed')
"
```

### What to Test
- JSON is valid
- All required fields present
- No duplicate problem types
- All technique references exist
- Risk levels are valid values

## Verification Commands
```bash
# Check file exists and is valid JSON
cat .claude/technique-config.json | python3 -m json.tool > /dev/null && echo "Valid JSON"

# Count problem types
python3 -c "import json; c=json.load(open('.claude/technique-config.json')); print(f'Problem types: {sum(len(v.get(\"subtypes\", {})) for v in c[\"problemTypes\"].values())}')"
```

## Documentation Updates
- [ ] Add technique config section to CLAUDE.md

## Error Recovery
If validation fails:
1. Check JSON syntax with a linter
2. Verify all required fields are present
3. Cross-reference technique IDs

## Do NOT
- Add techniques that don't have corresponding `.md` templates
- Create circular dependencies in retry paths
- Use vague keywords that could match too broadly
