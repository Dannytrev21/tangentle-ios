# Test Command

Run tests for the Tangentle iOS project.

## Input
Test filter (optional): $ARGUMENTS

## Process

### Step 1: Verify Project Exists
```bash
ls Tangentle/Tangentle.xcodeproj
```

### Step 2: Run Tests
If no arguments provided, run all tests:
```bash
cd Tangentle && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' 2>&1
```

If arguments provided (test suite name), run specific tests:
```bash
cd Tangentle && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/$ARGUMENTS 2>&1
```

### Step 3: Parse Results
Extract from output:
- Test suite results
- Pass/fail counts
- Failed test names and reasons
- Execution time

### Step 4: Report Results

#### On Success
```
═══════════════════════════════════════════════════════════════
  ✅ ALL TESTS PASSED
═══════════════════════════════════════════════════════════════

## Results
- Tests Run: {N}
- Passed: {N}
- Failed: 0
- Duration: {time}

## Test Suites
✓ TaskRepositoryTests (5 tests)
✓ StrategyRepositoryTests (3 tests)
✓ TaskServiceTests (4 tests)
```

#### On Failure
```
═══════════════════════════════════════════════════════════════
  ❌ TESTS FAILED
═══════════════════════════════════════════════════════════════

## Results
- Tests Run: {N}
- Passed: {N}
- Failed: {N}

## Failed Tests
### {TestSuite}/{TestName}
**Error**: {error message}
**Location**: {file}:{line}
```

## Examples
- `/test` - Run all tests
- `/test TaskRepositoryTests` - Run specific suite
- `/test TaskServiceTests/testCreateTask` - Run specific test
