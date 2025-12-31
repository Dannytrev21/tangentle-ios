# Step 5: ViewModel Unit Tests

## Context
ViewModels manage UI state and user interactions. TodayViewModel has tests; we need to ensure comprehensive coverage and establish patterns for future ViewModels. Target is 80%+ coverage.

## Goal
Complete unit test coverage for all ViewModels, testing state management, user actions, and error handling.

## Prerequisites
- Step 1 completed (directory structure, helpers)
- Step 2 completed (mocks for services)

## High-Level Steps
1. Move existing TodayViewModelTests to new location
2. Expand TodayViewModel tests for complete coverage
3. Document patterns for future ViewModel tests
4. Verify 80%+ coverage achieved

## Detailed Requirements

### Test Pattern
ViewModels require @MainActor annotation and mocked services:
```swift
@Suite("ViewModelName Tests")
struct ViewModelNameTests {
    @Test("State description")
    @MainActor
    func testStateBehavior() async throws {
        // Arrange
        let mockService = MockService()
        mockService.getDataResult = .success([...])
        let viewModel = ViewModel(service: mockService)

        // Act
        await viewModel.loadData()

        // Assert
        #expect(viewModel.data.count == expected)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }
}
```

### TodayViewModel Tests (expand existing)
Current tests: 4
Additional tests needed:

**State Management:**
- `testInitialState_hasEmptyArraysAndNoError()`
- `testLoadTasks_setsLoadingDuringFetch()`
- `testLoadTasks_populatesTodaysTasksOnSuccess()`
- `testLoadTasks_populatesOverdueTasksOnSuccess()`
- `testLoadTasks_setsErrorOnFailure()`
- `testLoadTasks_clearsErrorOnRetry()`

**User Actions:**
- `testCompleteTask_updatesTaskStatus()`
- `testCompleteTask_removesFromTodaysList()`
- `testCompleteTask_setsCompletedAt()`
- `testDeleteTask_removesFromList()`
- `testDeferTask_reschedulesToTomorrow()`
- `testDeferTask_removesFromTodaysList()`

**Error Handling:**
- `testCompleteTask_handlesServiceError()`
- `testDeleteTask_handlesServiceError()`
- `testLoadTasks_handlesNetworkError()`

**Edge Cases:**
- `testLoadTasks_withNoTasks_showsEmptyState()`
- `testLoadTasks_withOnlyOverdue_populatesCorrectArray()`
- `testCompleteTask_alreadyCompleted_noOp()`

**Refresh Behavior:**
- `testRefresh_reloadsAllData()`
- `testRefresh_doesNotReloadWhileLoading()`

### Future ViewModel Patterns
Document patterns for ViewModels that don't exist yet:

**TaskDetailViewModel** (future)
```swift
// Tests for editing task properties
// Tests for adding/removing subtasks
// Tests for project assignment
// Tests for strategy association
```

**StrategyCoachingViewModel** (future)
```swift
// Tests for coaching flow
// Tests for strategy selection
// Tests for outcome recording
// Tests for strategy scoring updates
```

**SettingsViewModel** (future)
```swift
// Tests for preference changes
// Tests for notification settings
// Tests for theme changes
```

### Observable Macro Testing
With @Observable, test that:
- Property changes trigger view updates (via state inspection)
- Published state is correct after async operations
- Multiple rapid state changes are handled correctly

## Files to Create
- `TangentleTests/Unit/ViewModels/TodayViewModelTests.swift` (move & expand)

## Files to Modify
- None

## Patterns to Follow
Reference: `TangentleTests/Unit/TodayViewModelTests.swift` for @MainActor pattern
Reference: `Tangentle/Features/Tasks/TodayViewModel.swift` for implementation
Reference: `TangentleTests/Mocks/MockServices.swift` for service mocks

## Acceptance Criteria
- [ ] TodayViewModelTests moved to new location
- [ ] All state management scenarios tested
- [ ] All user actions tested
- [ ] Error handling tested
- [ ] Edge cases tested
- [ ] 80%+ line coverage for TodayViewModel
- [ ] Patterns documented for future ViewModels
- [ ] All tests pass

## Testing Requirements

### Unit Tests
- Test file: `TangentleTests/Unit/ViewModels/TodayViewModelTests.swift`
- Minimum: 15-20 tests

### What to Test
- Initial state correctness
- State after async operations
- User action effects
- Error state management
- Loading state management
- Edge case handling

## Verification Commands
```bash
# Run ViewModel tests only
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/Unit/ViewModels

# Run all tests
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Documentation Updates
- Add ViewModel testing patterns to code comments

## Error Recovery
If verification fails:
1. Check @MainActor annotation on tests
2. Verify await on async ViewModel methods
3. Check mock service setup
4. Ensure Observable properties are accessible

## Do NOT
- Test SwiftUI views (Step 7 for snapshots, Step 8 for UI tests)
- Test service logic (tested in Step 4)
- Create new ViewModels (just test existing)
- Skip @MainActor (will cause threading issues)
