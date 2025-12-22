# Step 12: Testing Setup

## Context
With all pieces in place, we need to establish testing patterns that future development will follow. This step creates sample unit tests for repositories and services, integration tests with in-memory Core Data, and sets up the testing infrastructure.

## Goal
Create testing infrastructure with example tests that demonstrate patterns for testing repositories, services, and view models.

## Prerequisites
- All previous steps completed (1-11)

## High-Level Steps
1. Set up test target configuration
2. Create test helpers and utilities
3. Write repository unit tests
4. Write service unit tests
5. Write view model tests
6. Create integration test examples

## Detailed Requirements

### Test Helpers
Create `TangentleTests/TestHelpers.swift`:

```swift
import XCTest
import CoreData
@testable import Tangentle

/// Provides in-memory Core Data stack for testing
final class TestCoreDataStack {
    static func createInMemory() -> NSManagedObjectContext {
        let controller = PersistenceController(inMemory: true)
        return controller.viewContext
    }
}

/// Factory for creating test data
enum TestFactory {
    static func createTask(
        context: NSManagedObjectContext,
        title: String = "Test Task",
        status: TaskStatus = .pending,
        priority: Int = 0
    ) -> TGTask {
        let task = TGTask(context: context, title: title)
        task.statusEnum = status
        task.priority = Int16(priority)
        return task
    }

    static func createProject(
        context: NSManagedObjectContext,
        name: String = "Test Project"
    ) -> TGProject {
        let project = TGProject(context: context)
        project.id = UUID()
        project.name = name
        project.isActive = true
        project.createdAt = Date()
        project.updatedAt = Date()
        return project
    }

    static func createStrategy(
        context: NSManagedObjectContext,
        name: String = "Test Strategy",
        problemTypes: [String] = ["too_big"]
    ) -> TGStrategy {
        let strategy = TGStrategy(context: context)
        strategy.id = UUID()
        strategy.name = name
        strategy.strategyDescription = "Test description"
        strategy.problemTypes = problemTypes as NSObject
        strategy.taskTypes = ["all"] as NSObject
        strategy.source = "user"
        strategy.isActive = true
        strategy.createdAt = Date()
        strategy.updatedAt = Date()
        return strategy
    }
}

/// Async test helper
extension XCTestCase {
    func awaitAsync<T>(
        timeout: TimeInterval = 10,
        _ operation: @escaping () async throws -> T
    ) throws -> T {
        let expectation = expectation(description: "Async operation")
        var result: Result<T, Error>?

        Task {
            do {
                let value = try await operation()
                result = .success(value)
            } catch {
                result = .failure(error)
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        case .none:
            throw NSError(domain: "TestError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Operation timed out"])
        }
    }
}
```

### Repository Tests
Create `TangentleTests/Unit/TaskRepositoryTests.swift`:

```swift
import Testing
import CoreData
@testable import Tangentle

@Suite("TaskRepository Tests")
struct TaskRepositoryTests {

    @Test("Create task saves to database")
    func testCreateTask() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let repository = TaskRepository(context: context)

        // Act
        let task = try await repository.createTask(title: "My Task", project: nil, priority: 3)

        // Assert
        #expect(task.title == "My Task")
        #expect(task.priority == 3)
        #expect(task.statusEnum == .pending)
    }

    @Test("Fetch all returns created tasks")
    func testFetchAll() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let repository = TaskRepository(context: context)

        _ = try await repository.createTask(title: "Task 1", project: nil, priority: 0)
        _ = try await repository.createTask(title: "Task 2", project: nil, priority: 0)

        // Act
        let tasks = try await repository.fetchAll()

        // Assert
        #expect(tasks.count == 2)
    }

    @Test("Fetch by status filters correctly")
    func testFetchByStatus() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let repository = TaskRepository(context: context)

        let task1 = try await repository.createTask(title: "Pending", project: nil, priority: 0)
        let task2 = try await repository.createTask(title: "Completed", project: nil, priority: 0)
        task2.markCompleted()
        try await repository.save()

        // Act
        let pending = try await repository.fetchByStatus(.pending)
        let completed = try await repository.fetchByStatus(.completed)

        // Assert
        #expect(pending.count == 1)
        #expect(pending.first?.title == "Pending")
        #expect(completed.count == 1)
        #expect(completed.first?.title == "Completed")
    }

    @Test("Delete removes task")
    func testDelete() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let repository = TaskRepository(context: context)
        let task = try await repository.createTask(title: "To Delete", project: nil, priority: 0)

        // Act
        try await repository.delete(task)
        let tasks = try await repository.fetchAll()

        // Assert
        #expect(tasks.isEmpty)
    }

    @Test("Fetch overdue returns past due tasks")
    func testFetchOverdue() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let repository = TaskRepository(context: context)

        let pastTask = try await repository.createTask(title: "Overdue", project: nil, priority: 0)
        pastTask.dueDate = Date().addingTimeInterval(-86400) // Yesterday
        try await repository.save()

        let futureTask = try await repository.createTask(title: "Future", project: nil, priority: 0)
        futureTask.dueDate = Date().addingTimeInterval(86400) // Tomorrow
        try await repository.save()

        // Act
        let overdue = try await repository.fetchOverdue()

        // Assert
        #expect(overdue.count == 1)
        #expect(overdue.first?.title == "Overdue")
    }
}
```

### Strategy Repository Tests
Create `TangentleTests/Unit/StrategyRepositoryTests.swift`:

```swift
import Testing
import CoreData
@testable import Tangentle

@Suite("StrategyRepository Tests")
struct StrategyRepositoryTests {

    @Test("Fetch by problem type filters correctly")
    func testFetchByProblemType() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let repository = StrategyRepository(context: context)

        let strategy1 = TestFactory.createStrategy(context: context, name: "For Too Big", problemTypes: ["too_big"])
        let strategy2 = TestFactory.createStrategy(context: context, name: "For Boring", problemTypes: ["boring"])
        try context.save()

        // Act
        let tooBigStrategies = try await repository.fetchByProblemType("too_big")
        let boringStrategies = try await repository.fetchByProblemType("boring")

        // Assert
        #expect(tooBigStrategies.count == 1)
        #expect(tooBigStrategies.first?.name == "For Too Big")
        #expect(boringStrategies.count == 1)
        #expect(boringStrategies.first?.name == "For Boring")
    }

    @Test("Calculate score with outcomes")
    func testCalculateScore() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let repository = StrategyRepository(context: context)

        let strategy = TestFactory.createStrategy(context: context, name: "Test", problemTypes: ["too_big"])

        // Add some outcomes
        try await repository.recordOutcome(
            strategy: strategy,
            result: .success,
            problemType: "too_big",
            taskType: "all",
            taskTitle: "Task 1",
            notes: nil
        )
        try await repository.recordOutcome(
            strategy: strategy,
            result: .success,
            problemType: "too_big",
            taskType: "all",
            taskTitle: "Task 2",
            notes: nil
        )

        // Act
        let score = repository.calculateScore(for: strategy, problemType: "too_big", taskType: "all")

        // Assert
        #expect(score > 0)
        #expect(strategy.usageCount == 2)
    }
}
```

### Service Tests
Create `TangentleTests/Unit/TaskServiceTests.swift`:

```swift
import Testing
import CoreData
@testable import Tangentle

@Suite("TaskService Tests")
struct TaskServiceTests {

    @Test("Time estimate adds buffer")
    func testEstimateWithBuffer() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let taskRepo = TaskRepository(context: context)
        let projectRepo = ProjectRepository(context: context)
        let strategyRepo = StrategyRepository(context: context)
        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: projectRepo,
            strategyRepository: strategyRepo
        )

        // Act & Assert
        #expect(service.estimateWithBuffer(5) == 15) // 3x for tiny tasks
        #expect(service.estimateWithBuffer(30) == 45) // 1.5x for medium
        #expect(service.estimateWithBuffer(60) == 120) // 2x for long
    }

    @Test("Break down task creates subtasks")
    func testBreakDownTask() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let taskRepo = TaskRepository(context: context)
        let projectRepo = ProjectRepository(context: context)
        let strategyRepo = StrategyRepository(context: context)
        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: projectRepo,
            strategyRepository: strategyRepo
        )

        let parentTask = try await service.createTask(title: "Big Task", in: nil)

        // Act
        let subtasks = try await service.breakDownTask(parentTask, into: ["Step 1", "Step 2", "Step 3"])

        // Assert
        #expect(subtasks.count == 3)
        #expect(subtasks.allSatisfy { $0.parentTask == parentTask })
        #expect(subtasks.allSatisfy { $0.estimatedDuration == 15 })
    }

    @Test("Complete task updates status")
    func testCompleteTask() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let taskRepo = TaskRepository(context: context)
        let projectRepo = ProjectRepository(context: context)
        let strategyRepo = StrategyRepository(context: context)
        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: projectRepo,
            strategyRepository: strategyRepo
        )

        let task = try await service.createTask(title: "To Complete", in: nil)
        #expect(task.statusEnum == .pending)

        // Act
        try await service.completeTask(task)

        // Assert
        #expect(task.statusEnum == .completed)
        #expect(task.completedAt != nil)
    }
}
```

### Integration Tests
Create `TangentleTests/Integration/SeedDataIntegrationTests.swift`:

```swift
import Testing
import CoreData
@testable import Tangentle

@Suite("Seed Data Integration Tests")
struct SeedDataIntegrationTests {

    @Test("Seed service populates default data")
    func testSeedCreatesDefaults() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let seedService = SeedDataService(context: context)

        // Act
        try await seedService.seedIfNeeded()

        // Assert - Check strategies
        let strategyRequest = TGStrategy.fetchRequest()
        let strategies = try context.fetch(strategyRequest)
        #expect(strategies.count >= 18)

        // Assert - Check problem types
        let typeRequest = TGProblemType.fetchRequest()
        let types = try context.fetch(typeRequest)
        #expect(types.count == 11)

        // Assert - Check focus modes
        let modeRequest = TGFocusMode.fetchRequest()
        let modes = try context.fetch(modeRequest)
        #expect(modes.count >= 5)
    }

    @Test("Seed service only runs once")
    func testSeedIdempotent() async throws {
        // Arrange
        let context = TestCoreDataStack.createInMemory()
        let seedService = SeedDataService(context: context)

        // Act - Run twice
        try await seedService.seedIfNeeded()
        try await seedService.seedIfNeeded()

        // Assert - Still only one set of data
        let strategyRequest = TGStrategy.fetchRequest()
        let strategies = try context.fetch(strategyRequest)
        #expect(strategies.count >= 18)
        #expect(strategies.count < 40) // Not doubled
    }
}
```

## Files to Create
- `TangentleTests/TestHelpers.swift`
- `TangentleTests/Unit/TaskRepositoryTests.swift`
- `TangentleTests/Unit/StrategyRepositoryTests.swift`
- `TangentleTests/Unit/TaskServiceTests.swift`
- `TangentleTests/Integration/SeedDataIntegrationTests.swift`

## Files to Modify
- Test target configuration if needed

## Patterns to Follow
- Use Swift Testing framework (@Test, @Suite, #expect)
- Create in-memory Core Data for isolation
- Use factory methods for test data
- Test one thing per test
- Name tests descriptively

## Acceptance Criteria
- [ ] Test helpers created
- [ ] Repository tests pass
- [ ] Service tests pass
- [ ] Integration tests pass
- [ ] All tests run in < 30 seconds
- [ ] Tests demonstrate patterns for future development

## Verification Commands
```bash
# Run all tests
cd tangentle-ios/Tangentle && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test suite
cd tangentle-ios/Tangentle && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/TaskRepositoryTests
```

## Documentation Updates
- [ ] Update docs/ARCHITECTURE.md with testing patterns

## Error Recovery
If tests fail:
1. Check in-memory Core Data setup
2. Verify model entities match test expectations
3. Look for async timing issues
4. Check test isolation (clean context per test)

## Do NOT
- Use production database in tests
- Create tests that depend on each other
- Skip async waiting for Core Data
- Leave flaky tests
