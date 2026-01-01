# Testing Guide for Tangentle iOS

This document is the canonical guide for testing in Tangentle iOS. It covers all testing types, patterns, and best practices.

## Table of Contents
1. [Quick Start](#quick-start)
2. [Test Architecture](#test-architecture)
3. [Running Tests](#running-tests)
4. [Unit Tests](#unit-tests)
5. [Integration Tests](#integration-tests)
6. [Snapshot Tests](#snapshot-tests)
7. [UI/E2E Tests](#uie2e-tests)
8. [Performance Tests](#performance-tests)
9. [Test Data](#test-data)
10. [Mocking](#mocking)
11. [CI/CD Integration](#cicd-integration)
12. [Coverage](#coverage)
13. [Troubleshooting](#troubleshooting)
14. [Adding New Tests](#adding-new-tests)

---

## Quick Start

### Run All Tests
```bash
xcodebuild test -scheme Tangentle -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Run Specific Test Suites
```bash
# Unit tests only
xcodebuild test ... -only-testing:TangentleTests/Unit

# Repository tests
xcodebuild test ... -only-testing:TangentleTests/Unit/Repositories

# Service tests
xcodebuild test ... -only-testing:TangentleTests/Unit/Services

# ViewModel tests
xcodebuild test ... -only-testing:TangentleTests/Unit/ViewModels

# Integration tests
xcodebuild test ... -only-testing:TangentleTests/Integration

# Snapshot tests
xcodebuild test ... -only-testing:TangentleTests/Snapshots

# UI tests
xcodebuild test ... -only-testing:TangentleUITests

# Performance tests
xcodebuild test ... -only-testing:TangentleTests/Performance
```

### Run Single Test File
```bash
xcodebuild test ... -only-testing:TangentleTests/Unit/Repositories/TaskRepositoryTests
```

---

## Test Architecture

### Directory Structure
```
TangentleTests/
├── Unit/
│   ├── Repositories/      # Repository unit tests (15 files)
│   ├── Services/          # Service unit tests (6 files)
│   ├── ViewModels/        # ViewModel unit tests (1 file)
│   └── Mocks/             # Mock tests (1 file)
├── Integration/
│   ├── CoreData/          # Core Data relationship tests (4 files)
│   └── Services/          # Service integration tests (2 files)
├── Snapshots/
│   ├── Components/        # UI component snapshots (6 files)
│   └── Screens/           # Screen snapshots (1 file)
├── Performance/           # Performance benchmarks (5 files)
├── Contract/              # AI service contract tests (TBD)
├── Mocks/                 # Mock implementations (3 files)
├── TestHelpers/           # Test utilities and factories
└── Fixtures/              # JSON test fixtures

TangentleUITests/
├── Helpers/               # UI test utilities
├── Pages/                 # Page objects
└── Flows/                 # Flow tests
```

### Frameworks Used

| Test Type | Framework | When to Use |
|-----------|-----------|-------------|
| Unit | Swift Testing | Repositories, Services, ViewModels |
| Integration | Swift Testing | Cross-component, relationships |
| Snapshot | XCTest + swift-snapshot-testing | Visual regression |
| UI/E2E | XCUITest | User flows |
| Performance | XCTest measure {} | Benchmarking |

### Test Count Summary

| Category | Files | Tests |
|----------|-------|-------|
| Repository Unit | 15 | ~238 |
| Service Unit | 6 | ~55 |
| ViewModel Unit | 1 | ~15 |
| Mock Tests | 1 | 18 |
| Integration | 6 | ~99 |
| Snapshot | 8 | 108 |
| Performance | 4 | 47 |
| UI/E2E | 3 | 23 |
| **Total** | **44** | **~435** |

### Coverage Targets

| Layer | Target | Notes |
|-------|--------|-------|
| Repositories | 90%+ | Data access layer |
| Services | 85%+ | Business logic |
| ViewModels | 80%+ | UI state management |
| Components | All snapshots | Visual coverage |
| Flows | 2 critical flows | E2E coverage |

---

## Running Tests

### From Xcode
- ⌘U: Run all tests
- Click diamond next to test: Run single test
- ⌘⌥U: Run previous test

### From Terminal
```bash
# Run with verbose output
xcodebuild test -scheme Tangentle -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  | xcpretty

# Run with coverage
xcodebuild test -scheme Tangentle -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -enableCodeCoverage YES

# Run without parallel testing (more reliable for Swift Testing)
xcodebuild test -scheme Tangentle -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -parallel-testing-enabled NO
```

---

## Unit Tests

### Repository Tests

Use real in-memory Core Data:

```swift
import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("TaskRepository Tests")
struct TaskRepositoryTests {
    @Test("Fetch today's tasks returns scheduled tasks")
    func fetchTodaysTasks() async throws {
        // Arrange
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)
        _ = stack.createTask(title: "Today", scheduledDate: .testToday)
        try stack.save()

        // Act
        let tasks = try await repo.fetchTodaysTasks()

        // Assert
        #expect(tasks.count == 1)
        #expect(tasks.first?.title == "Today")
    }
}
```

### Service Tests

Use mocked repositories:

```swift
@Suite("TaskService Tests")
struct TaskServiceTests {
    @Test("Get today's tasks returns scheduled tasks")
    func getTodaysTasks() async throws {
        // Arrange
        let mockRepo = MockTaskRepository()
        mockRepo.fetchTodaysTasksResult = .success([...])
        let service = TaskService(taskRepository: mockRepo, ...)

        // Act
        let tasks = try await service.getTodaysTasks()

        // Assert
        #expect(tasks.count == expected)
        #expect(mockRepo.wasCalled("fetchTodaysTasks"))
    }
}
```

### ViewModel Tests

Use @MainActor and mocked services:

```swift
@Suite("TodayViewModel Tests")
struct TodayViewModelTests {
    @Test("Load tasks populates arrays")
    @MainActor
    func loadTasks() async throws {
        // Arrange
        let mockService = MockTaskService()
        mockService.getTodaysTasksResult = .success([...])
        let viewModel = TodayViewModel(taskService: mockService)

        // Act
        await viewModel.loadTasks()

        // Assert
        #expect(viewModel.todaysTasks.count == expected)
        #expect(viewModel.isLoading == false)
    }
}
```

---

## Integration Tests

Test real components working together:

```swift
@Suite("Task Relationship Integration Tests")
struct TaskRelationshipTests {
    @Test("Assigning project updates bidirectional relationship")
    func taskProject_assigningProject() async throws {
        let stack = TestCoreDataStack()

        let project = stack.createProject(name: "Project")
        let task = stack.createTask(title: "Task")
        task.project = project
        try stack.save()

        #expect(task.project == project)
        #expect(project.tasks?.contains(task) == true)
    }
}
```

### Core Data Relationship Tests
- TaskRelationshipTests: 24 tests for task-related relationships
- ProjectRelationshipTests: 10 tests for project relationships
- StrategyRelationshipTests: 12 tests for strategy-outcome relationships
- CascadeDeleteTests: 25 tests for cascade/nullify delete rules

### Service Integration Tests
- TaskServiceIntegrationTests: 15 tests for task service workflows
- StrategyServiceIntegrationTests: 13 tests for strategy service workflows

---

## Snapshot Tests

### Base Class
All snapshot tests inherit from `SnapshotTestCase`:

```swift
final class TaskCardSnapshotTests: SnapshotTestCase {
    func testTaskCard_default_light() {
        let view = TaskCard(task: makeTask())
        snapshotLight(view, size: CGSize(width: 360, height: 120))
    }

    func testTaskCard_default_dark() {
        let view = TaskCard(task: makeTask())
        snapshotDark(view, size: CGSize(width: 360, height: 120))
    }
}
```

### Recording Baselines
```swift
override func setUp() {
    super.setUp()
    // Uncomment to record new baselines:
    // isRecording = true
}
```

### Updating Baselines
1. Set `isRecording = true`
2. Run the test
3. Set `isRecording = false`
4. Commit new baseline images

### Theme Testing
```swift
func testComponent_bothThemes() {
    let view = Component()
    snapshotBothThemes(view, size: CGSize(width: 200, height: 100))
}
```

### Available Snapshot Tests
- CheckboxSnapshotTests: 15 tests (AnimatedCheckbox, CompletionIndicator)
- BadgeSnapshotTests: 33 tests (Priority, Energy, Duration, Project, Status badges)
- TaskCardSnapshotTests: 16 tests (various states)
- TabBarSnapshotTests: 14 tests (CustomTabBar, TabBarItem)
- SwipeActionSnapshotTests: 12 tests (SwipeActionButton, SwipeableRow)
- FloatingActionButtonSnapshotTests: 6 tests
- TodayViewSnapshotTests: 12 tests (TodayHeader, TaskSection, TodayEmptyState)

---

## UI/E2E Tests

### Page Object Pattern
```swift
struct TodayPage {
    let app: XCUIApplication

    var header: XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Good'")).firstMatch
    }

    var addButton: XCUIElement { app.buttons["AddTaskButton"] }

    func taskCard(titled: String) -> XCUIElement {
        app.staticTexts[titled].firstMatch
    }

    func verifyTaskVisible(_ title: String) -> Bool {
        taskCard(titled: title).waitForExistence(timeout: 5)
    }

    func swipeToComplete(task title: String) {
        let card = taskCard(titled: title)
        card.swipeRight()
    }
}
```

### Test Data Scenarios
```swift
app.launchWithScenario(.empty)          // No tasks
app.launchWithScenario(.singleTask)     // One task
app.launchWithScenario(.multipleTasks)  // Multiple tasks
app.launchWithScenario(.withOverdue)    // Tasks with overdue
app.launchWithScenario(.strategyCoaching) // For coaching tests
```

### Writing Flow Tests
```swift
final class TaskFlowTests: XCTestCase {
    var app: XCUIApplication!
    var todayPage: TodayPage!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchWithScenario(.multipleTasks)
        todayPage = TodayPage(app: app)
    }

    func testCompleteTask_removesFromList() throws {
        XCTAssertTrue(todayPage.verifyTaskVisible("Test Task 1"))
        todayPage.swipeToComplete(task: "Test Task 1")
        sleep(1)
        XCTAssertTrue(todayPage.verifyTaskNotVisible("Test Task 1"))
    }
}
```

### Accessibility Identifiers
| Component | Identifier Pattern |
|-----------|-------------------|
| TaskCard | TaskCard_{uuid} |
| AnimatedCheckbox | Checkbox |
| FloatingActionButton | AddTaskButton |
| TabBarItem | Tab_{today\|tasks\|calendar\|strategies\|settings} |
| SwipeActionButton | {title}Action (e.g., DeleteAction) |
| TodayHeader | TodayHeader |
| TodayEmptyState | EmptyStateMessage |
| TaskSection | {title}Section |

---

## Performance Tests

### Using XCTMetric
```swift
final class TaskRepositoryPerformanceTests: XCTestCase {
    func testFetchTodaysTasks_1000tasks_performance() throws {
        let stack = TestCoreDataStack()
        PerformanceTestData.seedTasks(1000, in: stack.context)
        let repo = TaskRepository(context: stack.context)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchTodaysTasks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }
}
```

### PerformanceTestData Utilities
```swift
// Seed various data sizes
PerformanceTestData.seedTasks(500, in: context)
PerformanceTestData.seedProjects(50, tasksPerProject: 10, in: context)
PerformanceTestData.seedStrategies(100, outcomesPerStrategy: 20, in: context)
PerformanceTestData.seedHabits(50, completionsPerHabit: 30, in: context)
PerformanceTestData.seedRoutines(20, stepsPerRoutine: 10, in: context)

// Clean up
PerformanceTestData.clearAllData(in: context)
```

### Current Benchmarks
- fetchTodaysTasks (100 tasks): ~0.4ms average
- fetchTodaysTasks (500 tasks): ~0.9ms average
- fetchByProblemType (50 strategies): ~0.6ms average
- calculateScore (100 outcomes × 100 iterations): ~15ms

---

## Test Data

### TestCoreDataStack
```swift
let stack = TestCoreDataStack()
let task = stack.createTask(title: "Test", priority: .high)
try stack.save()
```

### Factory Methods Available
- `createTask(title:priority:status:estimatedDuration:scheduledDate:dueDate:)`
- `createProject(name:emoji:)`
- `createGoal(name:targetDate:)`
- `createStrategy(name:problemTypes:)`
- `createRoutine(name:type:scheduledTime:)`
- `createRoutineStep(name:order:routine:)`
- `createHabit(name:frequency:)`
- `createHabitCompletion(habit:date:)`
- `createFocusMode(name:startTime:endTime:)`
- `createMode(name:isDefault:)`
- `createProblemType(identifier:label:)`
- `createTag(name:)`
- `createSettings()`
- `createStrategyOutcome(strategy:result:)`

### Date Helpers
```swift
Date.testToday       // Start of today
Date.testYesterday   // Start of yesterday
Date.testTomorrow    // Start of tomorrow
Date.daysFromNow(7)  // 7 days from now
```

### FakeDataGenerator
```swift
let title = FakeData.taskTitle()         // Random task title
let priority = FakeData.priority()       // Random priority
let date = FakeData.futureDate(within: 7) // Random date within 7 days
```

### JSON Fixtures
```swift
let tasks: [TaskFixture] = try TestFixtures.loadTasks("complex_scenario")
```

---

## Mocking

### Mock Repository Pattern
```swift
let mock = MockTaskRepository()
mock.fetchTodaysTasksResult = .success([task1, task2])
mock.saveError = MockError.intentional  // Simulate error

// After test - verify calls
#expect(mock.wasCalled("fetchTodaysTasks"))
#expect(mock.callCount("save") == 2)
```

### Mock Service Pattern
```swift
let mock = MockTaskService()
mock.getTodaysTasksResult = .success([])
mock.completeTaskError = MockError.intentional
```

### Available Mocks
**Repositories**: MockTaskRepository, MockProjectRepository, MockGoalRepository, MockStrategyRepository, MockRoutineRepository, MockRoutineStepRepository, MockHabitRepository, MockHabitCompletionRepository, MockFocusModeRepository, MockModeRepository, MockProblemTypeRepository, MockTagRepository, MockSettingsRepository, MockStrategyOutcomeRepository

**Services**: MockTaskService, MockStrategyService, MockScheduleService, MockSettingsService, MockAIServiceWithSpy

---

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          xcodebuild test \
            -scheme Tangentle \
            -sdk iphonesimulator \
            -destination 'platform=iOS Simulator,name=iPhone 15' \
            -enableCodeCoverage YES \
            -parallel-testing-enabled NO
```

### Xcode Cloud
Configure in Xcode under Product → Xcode Cloud.

---

## Coverage

### Generating Coverage Report
```bash
xcodebuild test -scheme Tangentle -enableCodeCoverage YES
xcrun xccov view --report DerivedData/.../Logs/Test/*.xcresult
```

### Current Targets
- Repositories: 90%+
- Services: 85%+
- ViewModels: 80%+

---

## Troubleshooting

### Test Won't Run
1. Clean build folder (⌘⇧K)
2. Reset simulator (Device → Erase All Content)
3. Delete DerivedData

### Snapshot Test Failures
1. Check if UI changed intentionally
2. Set `isRecording = true` to update baseline
3. Run test once, then set `isRecording = false`
4. Commit new baseline images

### UI Test Element Not Found
1. Add accessibility identifier to view
2. Check identifier spelling
3. Use `app.debugDescription` to see hierarchy
4. Use `waitForExistence(timeout:)` for async elements

### Flaky Tests
1. Add explicit waits with `waitForExistence(timeout:)`
2. Don't rely on timing
3. Clean up state between tests
4. Use `-parallel-testing-enabled NO` for Swift Testing

### Core Data Fetch Returns Empty
1. Ensure `context.save()` called after creation
2. Check predicate syntax
3. Verify relationship inverse is set

### "Multiple NSEntityDescriptions" Warning
This is cosmetic and doesn't affect test results. It occurs when multiple test runs create Core Data stacks.

### Swift Testing Shows "Failed" in Parallel Mode
Swift Testing tests may report incorrectly in parallel mode. Use `-parallel-testing-enabled NO` for accurate results.

---

## Adding New Tests

### New Repository
1. Create `TangentleTests/Unit/Repositories/{Name}RepositoryTests.swift`
2. Use `TestCoreDataStack` for real Core Data
3. Test all protocol methods
4. Test edge cases (empty, error, duplicates)
5. Target 90%+ coverage

### New Service
1. Create `TangentleTests/Unit/Services/{Name}ServiceTests.swift`
2. Add mock to `MockServices.swift` if needed
3. Use mocked repositories
4. Test business logic edge cases
5. Target 85%+ coverage

### New ViewModel
1. Create `TangentleTests/Unit/ViewModels/{Name}ViewModelTests.swift`
2. Use @MainActor on all tests
3. Use mocked services
4. Test all states: initial, loading, success, error
5. Target 80%+ coverage

### New UI Component
1. Create `TangentleTests/Snapshots/Components/{Name}SnapshotTests.swift`
2. Add accessibility identifier to component
3. Test light and dark modes
4. Test key states and variants
5. Record baselines

### New Screen
1. Create `TangentleTests/Snapshots/Screens/{Name}SnapshotTests.swift`
2. Test multiple device sizes
3. Test empty, populated, error states
4. Add page object to `TangentleUITests/Pages/`
5. Add flow tests if critical path

---

## Naming Conventions

```
Unit:        test{Method}_when{Condition}_{expectedResult}()
Integration: test{ComponentA}{ComponentB}_{interaction}()
Snapshot:    test{Component}_{state}_{theme}()
UI:          test{UserAction}_{expectedVisibleResult}()
Performance: test{Operation}_{datasetSize}_performance()
```

---

## Quick Reference

### Imports
```swift
// Unit tests (Swift Testing)
import Testing
import Foundation
@testable import Tangentle

// Snapshot tests
import XCTest
import SnapshotTesting
@testable import Tangentle

// UI tests
import XCTest
// No @testable - UI tests run against app bundle
```

### Assert Patterns
```swift
// Swift Testing
#expect(value == expected)
#expect(array.contains(element))
#expect(throws: ErrorType.self) { try operation() }

// XCTest
XCTAssertEqual(value, expected)
XCTAssertTrue(condition)
XCTAssertThrowsError(try operation())
```

### Async Test Pattern
```swift
// Swift Testing
@Test("Async operation")
func testAsync() async throws {
    let result = try await service.doSomething()
    #expect(result == expected)
}

// XCTest with async
func testAsync() async throws {
    let result = try await service.doSomething()
    XCTAssertEqual(result, expected)
}
```
