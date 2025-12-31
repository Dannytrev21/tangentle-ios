# Step 4: Service Unit Tests

## Context
Services contain business logic and orchestrate between repositories. StrategyServiceTests exists; we need to expand coverage to all 7 services with 85%+ coverage target. Services should be tested with mocked repositories to isolate business logic.

## Goal
Complete unit test coverage for all service implementations using mocked dependencies.

## Prerequisites
- Step 1 completed (directory structure, helpers)
- Step 2 completed (mocks for all repositories)

## High-Level Steps
1. Move existing StrategyServiceTests to new location
2. Create tests for remaining 6 services
3. Test all protocol methods for each service
4. Test business logic edge cases
5. Verify 85%+ coverage achieved

## Detailed Requirements

### Test Pattern
Use mocked dependencies for isolation:
```swift
@Suite("ServiceName Tests")
struct ServiceNameTests {
    @Test("Method description")
    func testMethodName() async throws {
        // Arrange
        let mockRepo = MockRepository()
        mockRepo.fetchResult = .success([...])
        let service = Service(repository: mockRepo)

        // Act
        let result = try await service.method()

        // Assert
        #expect(result == expected)
        #expect(mockRepo.fetchCalled)
    }
}
```

### Services to Test

#### 1. TaskService
Tests needed:
- `getTodaysTasks()` returns scheduled tasks for today
- `getOverdueTasks()` returns past due incomplete tasks
- `getUpcomingTasks(days:)` returns tasks within range
- `createTask(...)` creates with correct defaults
- `createTask(...)` applies ADHD time buffer
- `updateTask(...)` saves changes
- `completeTask(...)` sets status and completedAt
- `deleteTask(...)` removes task
- `addSubtask(...)` creates linked subtask
- `reorderTasks(...)` updates sort order
- Edge cases: task with subtasks, task in project

#### 2. StrategyService (existing, verify complete)
Current tests: 4
Additional tests needed:
- `getStrategiesForProblem()` with no matching strategies
- `recordOutcome()` updates usage count
- `calculateScore()` with various outcome combinations
- Recency factor in scoring

#### 3. ScheduleService
Tests needed:
- `getScheduleForDate()` returns day schedule
- `suggestTimeSlot()` considers energy levels
- `suggestTimeSlot()` respects focus mode time blocks
- `rescheduleTask()` updates scheduled date
- `getAvailableSlots()` excludes blocked times
- Edge cases: fully booked day, no preferences set

#### 4. SettingsService
Tests needed:
- `getSettings()` returns or creates settings
- `getScheduleSettings()` returns schedule portion
- `getTaskSettings()` returns task portion
- `updateScheduleSettings()` persists changes
- `updateTaskSettings()` persists changes
- `updateDisplaySettings()` persists changes
- `updateCoachingSettings()` persists changes
- Edge cases: first launch, corrupt settings

#### 5. AIService
Tests needed (with MockAIService):
- `getCoachingAdvice()` returns string response
- `getCoachingResponse()` returns structured response
- `prioritizeTasks()` returns reordered tasks
- `suggestSchedule()` returns scheduled tasks
- `generateSchedule()` handles schedule request
- Error handling: no API key, network error, rate limit
- Edge cases: empty task list, malformed response

Note: Use mocks for unit tests. Contract tests in Step 9 verify shapes.

#### 6. SeedDataService
Tests needed:
- Seeds default strategies on first launch
- Seeds default problem types on first launch
- Seeds default focus modes on first launch
- Doesn't duplicate data on subsequent launches
- Edge cases: partial seed, interrupted seed

### Business Logic Tests
Special attention to ADHD-specific logic:
- **Time estimation buffer**: 5min → 15min, 30min → 45min, 60min → 120min
- **Strategy scoring**: `score = successRate × log(attempts + 1) × recencyFactor`
- **Energy matching**: high energy tasks during peak focus times
- **Focus mode filtering**: only show relevant tasks in focus mode

## Files to Create
- `TangentleTests/Unit/Services/TaskServiceTests.swift`
- `TangentleTests/Unit/Services/StrategyServiceTests.swift` (move & expand)
- `TangentleTests/Unit/Services/ScheduleServiceTests.swift`
- `TangentleTests/Unit/Services/SettingsServiceTests.swift`
- `TangentleTests/Unit/Services/AIServiceTests.swift`
- `TangentleTests/Unit/Services/SeedDataServiceTests.swift`

## Files to Modify
- None (all new files or moves)

## Patterns to Follow
Reference: `TangentleTests/Unit/StrategyServiceTests.swift` for service test structure
Reference: `Tangentle/Core/Services/ServiceProtocols.swift` for method signatures
Reference: `TangentleTests/Mocks/MockRepositories.swift` for mock usage

## Acceptance Criteria
- [ ] All 6 service test files created
- [ ] Each service has tests for all protocol methods
- [ ] Business logic edge cases tested
- [ ] ADHD-specific features tested (time buffer, scoring)
- [ ] Error handling tested
- [ ] 85%+ line coverage for all services
- [ ] All tests pass

## Testing Requirements

### Unit Tests
- Test files: See "Files to Create" above
- Minimum tests per service: 8-15 depending on complexity

### What to Test
- All public methods
- Business logic correctness
- Dependency interactions (verify mock calls)
- Error handling
- Edge cases
- ADHD-specific calculations

## Verification Commands
```bash
# Run service tests only
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/Unit/Services

# Run all tests
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Documentation Updates
- None for this step

## Error Recovery
If verification fails:
1. Check mock setup provides expected data
2. Verify service initialization with mocks
3. Check async operations complete
4. Ensure business logic matches implementation

## Do NOT
- Test repository logic (tested in Step 3)
- Make real network calls (use mocks)
- Test UI logic (tested in Step 5)
- Write integration tests here (Step 6)
