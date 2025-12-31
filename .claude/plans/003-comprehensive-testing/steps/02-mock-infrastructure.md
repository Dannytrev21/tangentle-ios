# Step 2: Mock Infrastructure

## Context
To write isolated unit tests for services and ViewModels, we need mock implementations of all protocols. The project uses protocol-based dependency injection, making this straightforward. MockAIService already exists as a pattern to follow.

## Goal
Create comprehensive mock implementations for all repository and service protocols, enabling isolated unit testing.

## Prerequisites
- Step 1 completed (directory structure in place)

## High-Level Steps
1. Create MockRepositories.swift with mocks for all 15 repository protocols
2. Create MockServices.swift with mocks for all service protocols
3. Update TestContainer to use new mocks
4. Verify mocks compile and integrate with existing tests

## Detailed Requirements

### Mock Repository Pattern
Each mock should:
- Implement the full protocol interface
- Store data in-memory arrays/dictionaries
- Support configurable behavior via closures or properties
- Allow inspection of method calls for verification

Example pattern:
```swift
final class MockTaskRepository: TaskRepositoryProtocol {
    // Stored data
    var tasks: [TGTask] = []

    // Call tracking
    var fetchTodaysTasksCalled = false
    var saveCalledCount = 0

    // Configurable behavior
    var fetchTodaysTasksResult: Result<[TGTask], Error> = .success([])
    var shouldThrowOnSave = false

    // Protocol implementation
    func fetchTodaysTasks() async throws -> [TGTask] {
        fetchTodaysTasksCalled = true
        return try fetchTodaysTasksResult.get()
    }

    func save() async throws {
        saveCalledCount += 1
        if shouldThrowOnSave {
            throw RepositoryError.saveFailed(underlying: MockError.intentional)
        }
    }
}
```

### Repository Mocks to Create
1. MockTaskRepository
2. MockProjectRepository
3. MockGoalRepository
4. MockStrategyRepository
5. MockStrategyOutcomeRepository
6. MockRoutineRepository
7. MockRoutineStepRepository
8. MockHabitRepository
9. MockHabitCompletionRepository
10. MockFocusModeRepository
11. MockModeRepository
12. MockProblemTypeRepository
13. MockTagRepository
14. MockSettingsRepository

### Service Mocks to Create
1. MockTaskService (expand existing if present)
2. MockStrategyService
3. MockScheduleService
4. MockSettingsService
5. MockAIService (already exists in TestContainer, verify complete)
6. MockSeedDataService

### Mock Utilities
Create supporting utilities:
```swift
// Common mock error
enum MockError: Error {
    case intentional
    case notImplemented
}

// Spy helper for tracking calls
struct MethodCall {
    let name: String
    let arguments: [Any]
    let timestamp: Date
}

protocol MockSpy {
    var calls: [MethodCall] { get }
    func recordCall(_ name: String, arguments: Any...)
    func wasCalled(_ name: String) -> Bool
    func callCount(_ name: String) -> Int
}
```

## Files to Create
- `TangentleTests/Mocks/MockRepositories.swift` - All repository mocks
- `TangentleTests/Mocks/MockServices.swift` - All service mocks
- `TangentleTests/Mocks/MockUtilities.swift` - Supporting utilities

## Files to Modify
- `Tangentle/Core/DI/TestContainer.swift` - Update to use new mocks (if beneficial)

## Patterns to Follow
Reference: `Tangentle/Core/DI/TestContainer.swift` for MockAIService pattern
Reference: `Tangentle/Core/Repositories/RepositoryProtocols.swift` for protocol signatures
Reference: `Tangentle/Core/Services/ServiceProtocols.swift` for service interfaces

## Acceptance Criteria
- [ ] All 14 repository mocks created and compile
- [ ] All 6 service mocks created and compile
- [ ] MockUtilities created with spy helpers
- [ ] Mocks support configurable success/failure responses
- [ ] Mocks track method calls for verification
- [ ] `xcodebuild build` succeeds
- [ ] Existing tests still pass

## Testing Requirements

### Unit Tests
- Test file: `TangentleTests/Unit/Mocks/MockTests.swift`
- Test cases:
  - `testMockTaskRepository_fetchTodaysTasks_returnsConfiguredResult()`
  - `testMockTaskRepository_save_tracksCallCount()`
  - `testMockTaskRepository_whenConfiguredToThrow_throwsError()`
  - `testMethodCallSpy_recordsCallsCorrectly()`

### What to Test
- Mock behavior is configurable
- Call tracking works correctly
- Error simulation works
- Spy utilities function properly

## Verification Commands
```bash
# Build project
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Run all tests
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Documentation Updates
- Add mock usage examples to code comments

## Error Recovery
If verification fails:
1. Check protocol conformance for each mock
2. Verify async/throws signatures match protocols
3. Ensure generic constraints satisfied
4. Check import statements for @testable import Tangentle

## Do NOT
- Implement real logic in mocks (they should be dumb)
- Make mocks do network calls
- Add dependencies to mocks beyond Foundation
- Over-engineer spy functionality
