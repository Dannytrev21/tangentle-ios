# Test-Driven Development (TDD) for AI Agents

## Task: $ARGUMENTS

## Instructions

I will follow strict TDD: write failing tests first, then implement just enough code to pass them, then refactor. Tests are the specification.

---

## Phase 1: Requirements → Test Cases

**Understanding Requirements**:
[Restate what needs to be built]

**Deriving Test Cases**:

### Test Category 1: Happy Path
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

### Test Category 2: Edge Cases
```python
def test_empty_input():
    """What happens with no input?"""
    assert function_under_test([]) == [expected for empty]

def test_single_element():
    """Boundary case with minimal input."""
    assert function_under_test([single]) == [expected]

def test_maximum_size():
    """Stress test with large input."""
    large_input = [generate large test data]
    result = function_under_test(large_input)
    assert [appropriate assertions]
```

### Test Category 3: Error Cases
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

### Test Category 4: Business Logic
```python
def test_specific_business_rule_1():
    """[Describe the business rule]"""
    # Specific scenario that tests this rule
    assert function_under_test(scenario_input) == expected_per_rule

def test_specific_business_rule_2():
    """[Describe another business rule]"""
    assert function_under_test(another_scenario) == another_expected
```

---

## Phase 2: Run Tests (Expecting RED)

**Test Execution**:
```bash
pytest test_file.py -v
```

**Expected Results**:
```
test_basic_functionality FAILED (not implemented)
test_empty_input FAILED (not implemented)
test_single_element FAILED (not implemented)
test_maximum_size FAILED (not implemented)
test_invalid_input_type FAILED (not implemented)
test_null_input FAILED (not implemented)
test_specific_business_rule_1 FAILED (not implemented)
test_specific_business_rule_2 FAILED (not implemented)

0 passed, 8 failed
```

**Confirmation**: All tests fail as expected. ✓ RED phase complete.

---

## Phase 3: Implement Minimal Code (Go GREEN)

**Goal**: Write the simplest code that makes ALL tests pass. No more, no less.

### Iteration 3.1: Make first test pass

```python
def function_under_test(input_data):
    # Minimal implementation for test_basic_functionality
    [simplest possible code]
```

**Run tests**: 
- test_basic_functionality: PASSED ✓
- Others: Still failing

### Iteration 3.2: Make edge case tests pass

```python
def function_under_test(input_data):
    # Add handling for edge cases
    if not input_data:
        return [empty case result]
    if len(input_data) == 1:
        return [single element result]
    
    # Original logic
    [previous code]
```

**Run tests**:
- test_basic_functionality: PASSED ✓
- test_empty_input: PASSED ✓
- test_single_element: PASSED ✓
- Others: Still failing

### Iteration 3.3: Add error handling

```python
def function_under_test(input_data):
    # Input validation
    if input_data is None:
        raise ValueError("Input cannot be None")
    if not isinstance(input_data, list):
        raise TypeError("Input must be a list")
    
    # Edge cases
    [previous edge case handling]
    
    # Main logic
    [previous code]
```

**Run tests**:
- All error tests: PASSED ✓

### Iteration 3.4: Implement business rules

```python
def function_under_test(input_data):
    [Complete implementation with all rules]
```

**Final test run**:
```
test_basic_functionality PASSED
test_empty_input PASSED
test_single_element PASSED
test_maximum_size PASSED
test_invalid_input_type PASSED
test_null_input PASSED
test_specific_business_rule_1 PASSED
test_specific_business_rule_2 PASSED

8 passed, 0 failed
```

**Confirmation**: All tests pass. ✓ GREEN phase complete.

---

## Phase 4: Refactor (Keep GREEN)

Now improve the code without changing behavior (tests must stay green).

**Refactoring opportunities identified**:
1. [Code smell 1]: [How to fix]
2. [Code smell 2]: [How to fix]
3. [Performance improvement]: [How to improve]

**Refactored implementation**:
```python
def function_under_test(input_data):
    """
    [Clear docstring]
    
    Args:
        input_data: [Description]
    
    Returns:
        [Description]
    
    Raises:
        ValueError: [When]
        TypeError: [When]
    """
    _validate_input(input_data)
    
    if _is_trivial_case(input_data):
        return _handle_trivial(input_data)
    
    return _process_normal(input_data)


def _validate_input(data):
    """Input validation extracted for clarity."""
    if data is None:
        raise ValueError("Input cannot be None")
    if not isinstance(data, list):
        raise TypeError("Input must be a list")


def _is_trivial_case(data):
    """Check for edge cases that need special handling."""
    return len(data) <= 1


def _handle_trivial(data):
    """Handle empty or single-element cases."""
    if not data:
        return [empty result]
    return [single element result]


def _process_normal(data):
    """Main processing logic for normal cases."""
    [Clean, well-organized main logic]
```

**Run tests after refactoring**:
```
8 passed, 0 failed
```

**Confirmation**: Tests still pass. ✓ REFACTOR phase complete.

---

## Phase 5: Final Deliverables

### Complete Test Suite
```python
[All tests]
```

### Complete Implementation
```python
[Final refactored code]
```

### Coverage Report
```
Name                    Stmts   Miss  Cover
-------------------------------------------
function_under_test.py     25      0   100%
-------------------------------------------
TOTAL                      25      0   100%
```

---

## TDD Summary

| Phase | Status | Notes |
|-------|--------|-------|
| Write Tests | ✓ | 8 test cases covering all requirements |
| RED | ✓ | All tests initially failed |
| GREEN | ✓ | Minimal code to pass all tests |
| REFACTOR | ✓ | Improved code quality, tests still pass |

**Key Benefit**: The tests now serve as living documentation and regression protection. Any future changes that break expected behavior will be caught immediately.
