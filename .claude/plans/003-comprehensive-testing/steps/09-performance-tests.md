# Step 9: Performance Tests

## Context
ADHD users are particularly sensitive to lag and delays. Performance testing ensures the app remains responsive even with large datasets. XCTest's `measure {}` block provides built-in benchmarking.

## Goal
Create performance benchmarks for critical operations, especially repository queries and data loading, to establish baselines and catch performance regressions.

## Prerequisites
- Step 3 completed (repository patterns established)
- Step 1 completed (test infrastructure)

## High-Level Steps
1. Identify critical performance paths
2. Create performance test infrastructure
3. Implement repository performance tests
4. Implement service performance tests
5. Establish baseline metrics
6. Configure CI thresholds (future)

## Detailed Requirements

### Performance Test Pattern
```swift
import XCTest
@testable import Tangentle

final class RepositoryPerformanceTests: XCTestCase {

    func testFetchTodaysTasks_performance() throws {
        // Arrange - seed large dataset
        let stack = TestCoreDataStack()
        seedLargeDataset(in: stack.context, taskCount: 1000)
        let repo = TaskRepository(context: stack.context)

        // Act & Measure
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchTodaysTasks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    private func seedLargeDataset(in context: NSManagedObjectContext, taskCount: Int) {
        for i in 0..<taskCount {
            let task = TGTask(context: context)
            task.id = UUID()
            task.title = "Task \(i)"
            task.status = "pending"
            task.scheduledDate = i % 3 == 0 ? Date() : nil // 1/3 scheduled today
            task.createdAt = Date()
            task.updatedAt = Date()
        }
        try? context.save()
    }
}
```

### Critical Performance Paths

#### Repository Operations (Data Layer)
Most critical - affects every screen:

1. **TaskRepository**
   - `fetchTodaysTasks()` with 100, 500, 1000 tasks
   - `fetchOverdueTasks()` with many overdue items
   - `fetchByStatus()` filtering large dataset
   - `fetchByPriority()` filtering large dataset
   - `fetchScheduledBetween()` date range query

2. **StrategyRepository**
   - `fetchByProblemType()` with many strategies
   - `fetchTopRated()` sorting by computed score
   - `fetchForCoaching()` combined filter + sort + limit

3. **ProjectRepository**
   - `fetchActive()` with many projects
   - `fetchByGoal()` with relationships

4. **General Repository Operations**
   - `save()` with single entity
   - `save()` with batch (50, 100, 500 entities)
   - `delete()` with cascade relationships

#### Service Operations (Business Layer)
1. **TaskService**
   - `getTodaysTasks()` full workflow
   - `createTask()` with project assignment
   - `reorderTasks()` with many tasks

2. **StrategyService**
   - `calculateScore()` with many outcomes
   - `getStrategiesForProblem()` ranking

3. **ScheduleService**
   - `getScheduleForDate()` complex schedule generation

#### ViewModel Operations (UI Layer)
1. **TodayViewModel**
   - `loadTasks()` initial load time
   - `refresh()` reload time

### Performance Metrics

| Metric | Description | Use Case |
|--------|-------------|----------|
| XCTClockMetric | Wall clock time | Overall responsiveness |
| XCTCPUMetric | CPU time | Efficiency |
| XCTMemoryMetric | Memory usage | Memory pressure |
| XCTStorageMetric | Disk I/O | Core Data writes |

### Baseline Expectations

| Operation | Dataset | Target | Max Acceptable |
|-----------|---------|--------|----------------|
| fetchTodaysTasks | 1000 tasks | < 50ms | < 100ms |
| fetchOverdueTasks | 1000 tasks | < 50ms | < 100ms |
| save (single) | 1 entity | < 10ms | < 50ms |
| save (batch 100) | 100 entities | < 100ms | < 500ms |
| calculateScore | 100 outcomes | < 5ms | < 20ms |
| loadTasks (VM) | 100 tasks | < 100ms | < 200ms |

### Large Dataset Seeding
```swift
struct PerformanceTestData {
    static func seedTasks(_ count: Int, in context: NSManagedObjectContext) {
        let today = Calendar.current.startOfDay(for: Date())

        for i in 0..<count {
            let task = TGTask(context: context)
            task.id = UUID()
            task.title = "Performance Task \(i)"
            task.status = ["pending", "in_progress", "done"].randomElement()!
            task.priority = Int16.random(in: 0...5)
            task.energy = ["low", "medium", "high"].randomElement()!
            task.estimatedDuration = Int16([15, 30, 45, 60].randomElement()!)
            task.scheduledDate = i % 3 == 0 ? today : nil
            task.dueDate = i % 5 == 0 ? today.addingTimeInterval(-86400) : nil // 20% overdue
            task.createdAt = Date()
            task.updatedAt = Date()
        }
        try? context.save()
    }

    static func seedStrategies(_ count: Int, withOutcomes outcomeCount: Int, in context: NSManagedObjectContext) {
        let problemTypes = ["too_big", "unclear", "boring", "scary", "blocked"]

        for i in 0..<count {
            let strategy = TGStrategy(context: context)
            strategy.id = UUID()
            strategy.name = "Strategy \(i)"
            strategy.strategyDescription = "Description for strategy \(i)"
            strategy.problemTypesArray = [problemTypes.randomElement()!]
            strategy.source = i % 2 == 0 ? "default" : "user"
            strategy.isActive = true
            strategy.createdAt = Date()
            strategy.updatedAt = Date()

            // Add outcomes
            for j in 0..<outcomeCount {
                let outcome = TGStrategyOutcome(context: context)
                outcome.id = UUID()
                outcome.result = ["success", "partial", "failure"].randomElement()!
                outcome.problemType = strategy.problemTypesArray.first!
                outcome.usedAt = Date().addingTimeInterval(TimeInterval(-j * 86400))
                outcome.strategy = strategy
            }
        }
        try? context.save()
    }
}
```

### Regression Detection
Performance tests should:
1. Establish baselines (first run)
2. Compare subsequent runs to baseline
3. Fail if performance degrades beyond threshold (typically 20%)

Configure in scheme:
- Enable "Gather coverage data"
- Set baseline in scheme settings
- Configure max allowed deviation

## Files to Create
- `TangentleTests/Performance/PerformanceTestData.swift`
- `TangentleTests/Performance/TaskRepositoryPerformanceTests.swift`
- `TangentleTests/Performance/StrategyRepositoryPerformanceTests.swift`
- `TangentleTests/Performance/ServicePerformanceTests.swift`
- `TangentleTests/Performance/ViewModelPerformanceTests.swift`

## Files to Modify
- None

## Patterns to Follow
Reference: XCTest performance testing documentation
Reference: `TangentleTests/Unit/Repositories/` for repository patterns

## Acceptance Criteria
- [ ] Performance test infrastructure created
- [ ] Repository performance tests for critical queries
- [ ] Service performance tests for key operations
- [ ] ViewModel load performance tested
- [ ] Baselines established for all tests
- [ ] Tests complete within acceptable time
- [ ] All tests pass
- [ ] Metrics documented in code comments

## Testing Requirements

### Performance Tests
- Test files: See "Files to Create" above
- Minimum: 15-20 performance tests

### What to Test
- Query performance with large datasets
- Memory usage during operations
- Batch operation efficiency
- Computed property performance (scores)

## Verification Commands
```bash
# Run performance tests only
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/Performance

# Run all tests
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Documentation Updates
- Document baseline expectations in test comments
- Document how to update baselines

## Error Recovery
If verification fails:
1. Check if test environment is consistent
2. Verify seed data is created correctly
3. Ensure context.save() called before queries
4. Check for memory leaks affecting performance
5. Run multiple times to confirm consistency

## Do NOT
- Set unrealistic targets (measure real performance first)
- Test on slow/overloaded CI machines (local first)
- Mix performance tests with functional tests
- Measure one-off operations (measure averages)
- Forget to seed data before measuring
