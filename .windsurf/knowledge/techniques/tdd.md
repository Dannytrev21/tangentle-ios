# Test-Driven Development (TDD)

## Overview
TDD is a development technique where tests are written before implementation code. It follows a strict Red-Green-Refactor cycle: write a failing test (Red), write minimal code to pass it (Green), then improve the code (Refactor). Tests become the specification and safety net.

This technique produces highly testable, well-designed code with built-in regression protection.

## When to Use
- Algorithm implementation requiring correctness guarantees
- Business logic with clear input/output relationships
- Data access layers where correctness is critical
- Service implementation with defined contracts
- Validation logic with multiple rules
- Any code where automated testing is valuable

## How It Works

### RED Phase: Write Failing Tests
- Define expected behavior through tests
- Write tests for happy path, edge cases, and error cases
- Run tests to confirm they fail (proves test is valid)

### GREEN Phase: Write Minimal Code
- Implement just enough code to pass tests
- No extra features, no premature optimization
- Run tests to confirm they pass

### REFACTOR Phase: Improve Code
- Clean up implementation without changing behavior
- Remove duplication, improve naming, extract functions
- Tests must remain passing throughout

## Execution Instructions

```
## TDD EXECUTION PROTOCOL

### Phase 1: Requirements → Test Cases

**Understanding Requirements**:
[Restate what needs to be built]

**Deriving Test Cases**:

#### Test Category 1: Happy Path
```python
def test_basic_functionality():
    """The most common, expected use case."""
    # Arrange
    input_data = [example input]
    expected = [expected output]

    # Act
    result = function_under_test(input_data)

    # Assert
    assert result == expected
```

#### Test Category 2: Edge Cases
```python
def test_empty_input():
    """What happens with no input?"""
    assert function_under_test([]) == [expected for empty]

def test_single_element():
    """Boundary case with minimal input."""
    assert function_under_test([single]) == [expected]

def test_maximum_size():
    """Stress test with large input."""
    assert [appropriate assertions]
```

#### Test Category 3: Error Cases
```python
def test_invalid_input_type():
    """Should handle or reject wrong types gracefully."""
    with pytest.raises(TypeError):
        function_under_test("not a list")

def test_null_input():
    """Handle None appropriately."""
    with pytest.raises(ValueError):
        function_under_test(None)
```

#### Test Category 4: Business Logic
```python
def test_specific_business_rule():
    """[Describe the business rule]"""
    assert function_under_test(scenario_input) == expected_per_rule
```

---

### Phase 2: Run Tests (Expecting RED)

**Test Execution**:
```bash
pytest test_file.py -v
```

**Expected Results**: All tests fail (not implemented)

**Confirmation**: ✓ RED phase complete

---

### Phase 3: Implement Minimal Code (Go GREEN)

**Goal**: Write the simplest code that makes ALL tests pass.

#### Iteration 1: Make first test pass
[Minimal implementation]

**Run tests**: First test passes, others still failing

#### Iteration 2: Make edge case tests pass
[Add handling for edge cases]

**Run tests**: More tests passing

#### Iteration 3: Add error handling
[Add validation]

**Run tests**: Error tests pass

#### Iteration 4: Implement business rules
[Complete implementation]

**Final test run**: All tests pass

**Confirmation**: ✓ GREEN phase complete

---

### Phase 4: Refactor (Keep GREEN)

**Refactoring opportunities identified**:
1. [Code smell 1]: [How to fix]
2. [Code smell 2]: [How to fix]

**Refactored implementation**:
[Clean, well-organized code with extracted functions]

**Run tests after refactoring**: All tests still pass

**Confirmation**: ✓ REFACTOR phase complete

---

### Phase 5: Final Deliverables

**Complete Test Suite**: [All tests]

**Complete Implementation**: [Final refactored code]

**Coverage Report**: [Target 100% for tested functions]
```

## Example Application

**Task**: Implement a priority queue

**TDD Application**:
1. **RED**: Write tests for enqueue, dequeue, peek, empty check
2. **GREEN**: Implement minimal heap-based queue
3. **REFACTOR**: Extract helper methods, add docstrings

## Common Pitfalls
- Writing tests after implementation (defeats the purpose)
- Making tests too complex or testing implementation details
- Skipping the refactor phase
- Writing more code than needed to pass tests
- Not running tests after each small change
- Testing private methods instead of public behavior

## Verification Checklist
- [ ] Tests written before implementation
- [ ] Tests cover happy path, edge cases, error cases
- [ ] All tests failed initially (RED confirmed)
- [ ] Minimal code written to pass each test
- [ ] All tests pass (GREEN confirmed)
- [ ] Code refactored without breaking tests
- [ ] No debug code or commented code left
- [ ] Tests serve as documentation
