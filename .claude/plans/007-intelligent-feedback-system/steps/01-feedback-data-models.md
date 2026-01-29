# Step 1: Feedback Data Models

## Problem Type
`infrastructure`

## Technique Selection
- **Planning**: ps-plus - Straightforward data structure design
- **Implementation**: tdd - Test-first ensures correct serialization
- **Verification**: self-refine - Iterate on schema until complete

## Risk Level
**low** - New files only, no modifications to existing code

## Retry Configuration
- Same technique: 2 attempts
- Alternative technique: 1 attempt
- Escalation: After 3 total failures

## Context
This is the foundation step. All other feedback system components depend on these data models. We're defining the JSON schemas and Python dataclasses that represent feedback data.

## Goal
Create well-defined data structures for:
1. Technique effectiveness records
2. Classification history entries
3. Implementation attempt records
4. Plan-level metrics

## Prerequisites
- None (first step)

## High-Level Steps
1. Define JSON schemas for each data type
2. Create Python dataclasses matching schemas
3. Implement serialization/deserialization
4. Write tests for all data structures

## Detailed Requirements

### JSON Schemas

#### technique-effectiveness.json Schema
```json
{
  "version": "1.0.0",
  "lastUpdated": "ISO-8601 timestamp",
  "byProblemType": {
    "{problem_type}": {
      "{technique}": {
        "success": 0,
        "failure": 0,
        "totalAttempts": 0,
        "averageAttemptsToSuccess": 0.0,
        "lastUsed": "ISO-8601 timestamp"
      }
    }
  }
}
```

#### classification-history.json Schema
```json
{
  "version": "1.0.0",
  "entries": [
    {
      "id": "uuid",
      "description": "original description text",
      "descriptionHash": "sha256 hash for dedup",
      "classifiedAs": "problem_type",
      "confidence": 0.95,
      "correctedTo": "problem_type or null",
      "correctionConfidence": 0.0,
      "timestamp": "ISO-8601",
      "source": "semantic|keyword|user"
    }
  ],
  "corrections": {
    "{descriptionHash}": {
      "original": "type",
      "corrected": "type",
      "count": 1
    }
  }
}
```

#### implementation-attempts.json Schema
```json
{
  "version": "1.0.0",
  "byStepId": {
    "{plan_id}_{step_id}": {
      "planId": "007",
      "stepId": 1,
      "problemType": "debug",
      "attempts": [
        {
          "attemptNumber": 1,
          "technique": "tdd",
          "method": "description of approach",
          "startedAt": "ISO-8601",
          "endedAt": "ISO-8601",
          "durationSeconds": 120,
          "errorSummary": "null or error description",
          "success": false
        }
      ],
      "totalAttempts": 1,
      "finalSuccess": false,
      "techniquesUsed": ["tdd"]
    }
  }
}
```

#### plan-metrics.json Schema
```json
{
  "version": "1.0.0",
  "totalPlans": 0,
  "totalSteps": 0,
  "completedPlans": 0,
  "completedSteps": 0,
  "averageStepsPerPlan": 0.0,
  "averageAttemptsPerStep": 0.0,
  "byCategory": {
    "{category}": {
      "plans": 0,
      "steps": 0,
      "successRate": 0.0
    }
  },
  "lastUpdated": "ISO-8601"
}
```

### Python Dataclasses

Create `.claude/scripts/feedback_models.py` with:

```python
@dataclass
class TechniqueStats:
    success: int
    failure: int
    total_attempts: int
    average_attempts_to_success: float
    last_used: str

@dataclass
class ClassificationEntry:
    id: str
    description: str
    description_hash: str
    classified_as: str
    confidence: float
    corrected_to: Optional[str]
    correction_confidence: float
    timestamp: str
    source: str  # "semantic" | "keyword" | "user"

@dataclass
class ImplementationAttempt:
    attempt_number: int
    technique: str
    method: str
    started_at: str
    ended_at: str
    duration_seconds: int
    error_summary: Optional[str]
    success: bool

@dataclass
class StepAttempts:
    plan_id: str
    step_id: int
    problem_type: str
    attempts: List[ImplementationAttempt]
    total_attempts: int
    final_success: bool
    techniques_used: List[str]
```

## Files to Create
- `.claude/schemas/feedback-data.schema.json`: Combined JSON schema
- `.claude/scripts/feedback_models.py`: Python dataclasses

## Files to Modify
- None

## Patterns to Follow
Reference: `.claude/scripts/memory_bank.py` lines 15-46 for dataclass patterns

## Acceptance Criteria
- [ ] JSON schema validates sample data correctly
- [ ] Python dataclasses can serialize to/from JSON
- [ ] All dataclasses have `to_dict()` and `from_dict()` methods
- [ ] Type hints are complete and correct
- [ ] All tests pass

## Testing Requirements

### Unit Tests
- [ ] Test file: `.claude/tests/test_feedback_models.py`
- [ ] Test cases:
  - `test_TechniqueStats_serialization()`
  - `test_ClassificationEntry_serialization()`
  - `test_ImplementationAttempt_serialization()`
  - `test_StepAttempts_serialization()`
  - `test_ClassificationEntry_hash_generation()`
  - `test_empty_optional_fields()`

### What to Test
- Serialization round-trip (object → dict → object)
- Optional field handling (None values)
- Timestamp format validation
- Hash generation consistency
- Edge cases: empty strings, zero values, max values

## Verification Commands
```bash
# Run tests
cd .claude && python3 -m pytest tests/test_feedback_models.py -v

# Validate schema
python3 -c "import json; json.load(open('schemas/feedback-data.schema.json'))"
```

## Documentation Updates
- [ ] Update `CLAUDE.md` Planning System section with data model overview

## Error Recovery
If verification fails:
1. Check JSON schema syntax
2. Verify dataclass field types match schema
3. Ensure all required fields are present

## Do NOT
- Add database dependencies (SQLite, etc.)
- Create actual data files yet (that's step 2)
- Add complex validation logic (keep models simple)
