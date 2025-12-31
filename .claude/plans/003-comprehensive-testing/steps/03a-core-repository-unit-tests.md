# Step 3a: Core Repository Unit Tests

## Context
This step focuses on the most critical repositories: Task, Project, Goal, and Strategy. These form the core of the app's data model and are used most frequently. TaskRepository already has tests that will be expanded.

## Goal
Complete unit test coverage for the 4 core repositories with 90%+ coverage target.

## Prerequisites
- Step 1 completed (directory structure, helpers)
- Note: Does NOT require Step 2 (mocks) - repository tests use real in-memory Core Data

## High-Level Steps
1. Move existing TaskRepositoryTests to new location
2. Expand TaskRepository tests to cover all methods
3. Create ProjectRepository tests
4. Create GoalRepository tests
5. Create StrategyRepository tests (complex due to scoring)
6. Verify 90%+ coverage for all 4 repositories

## Detailed Requirements

### Test Pattern
Follow existing TaskRepositoryTests pattern:
```swift
@Suite("RepositoryName Tests")
struct RepositoryNameTests {
    @Test("Method description")
    func testMethodName() async throws {
        // Arrange
        let stack = TestCoreDataStack()
        let repo = Repository(context: stack.context)

        // Act
        let result = try await repo.method()

        // Assert
        #expect(result == expected)
    }
}
```

### Repositories to Test

#### 1. TaskRepository (existing, expand)
Current tests: 6
Additional tests needed:
- `fetchScheduledBetween(start:end:)` with various date ranges
- `fetchScheduledBetween(start:end:)` with no matching tasks
- `fetchPending()` returns only pending tasks
- `fetchInProgress()` returns only in-progress tasks
- `fetchByEnergy()` filters by energy level
- `fetchByProject()` returns tasks for specific project
- `fetchByProject()` with project that has no tasks
- Edge cases: empty results, multiple matches

#### 2. ProjectRepository
Tests needed:
- `create()` creates valid project with required fields
- `fetchActive()` excludes archived projects
- `fetchActive()` returns empty when all archived
- `fetchByGoal()` returns projects for specific goal
- `fetchByGoal()` with goal that has no projects
- `fetchArchived()` returns only archived
- `fetchArchived()` returns empty when none archived
- `delete()` removes project
- `delete()` does not cascade delete tasks (nullifies)
- Edge cases: project with no tasks, project with many tasks

#### 3. GoalRepository
Tests needed:
- `create()` creates valid goal
- `fetchActive()` returns active goals only
- `fetchActive()` excludes completed goals
- `fetchWithUpcomingDeadlines(within:)` filters correctly
- `fetchWithUpcomingDeadlines(within:)` excludes past deadlines
- `fetchWithUpcomingDeadlines(within:)` with 0 days returns today only
- `delete()` removes goal
- Edge cases: no goals, all past deadlines, goal with projects

#### 4. StrategyRepository
Tests needed:
- `fetchActive()` returns active strategies
- `fetchActive()` excludes inactive
- `fetchByProblemType()` filters correctly
- `fetchByProblemType()` returns empty for unknown type
- `fetchTopRated(limit:)` orders by score descending
- `fetchTopRated(limit:)` respects limit
- `fetchBySource()` filters by source
- `fetchForCoaching(problemType:limit:)` returns appropriate strategies
- `fetchForCoaching(problemType:limit:)` prioritizes high-scoring strategies
- `fetchDefaults()` returns built-in strategies only
- `fetchUserCreated()` returns user strategies only
- Edge cases: no strategies for problem type, all strategies equal score

## Files to Create
- `TangentleTests/Unit/Repositories/TaskRepositoryTests.swift` (move & expand)
- `TangentleTests/Unit/Repositories/ProjectRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/GoalRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/StrategyRepositoryTests.swift`

## Files to Modify
- None (all new files or moves)

## Patterns to Follow
Reference: `TangentleTests/Unit/TaskRepositoryTests.swift` lines 1-126 for test structure
Reference: `TangentleTests/Unit/TestHelpers.swift` for factory methods

## Acceptance Criteria
- [ ] TaskRepositoryTests moved and expanded (12+ tests)
- [ ] ProjectRepositoryTests created (10+ tests)
- [ ] GoalRepositoryTests created (8+ tests)
- [ ] StrategyRepositoryTests created (12+ tests)
- [ ] 90%+ line coverage for all 4 repositories
- [ ] All tests pass

## Testing Requirements

### Unit Tests
- Test files: See "Files to Create" above
- Minimum 40+ tests total across 4 repositories

### What to Test
- CRUD operations (create, read, update, delete)
- Custom query methods
- Filtering and sorting
- Relationship handling (Task-Project, Project-Goal, Strategy-Outcomes)
- Edge cases (empty results, duplicates, invalid data)

## Verification Commands
```bash
# Run core repository tests only
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/Unit/Repositories/TaskRepositoryTests -only-testing:TangentleTests/Unit/Repositories/ProjectRepositoryTests -only-testing:TangentleTests/Unit/Repositories/GoalRepositoryTests -only-testing:TangentleTests/Unit/Repositories/StrategyRepositoryTests

# Run all tests
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Documentation Updates
- None for this step

## Error Recovery
If verification fails:
1. Check Core Data model matches test expectations
2. Verify TestCoreDataStack provides correct context
3. Check factory methods create valid entities
4. Ensure async operations complete before assertions

## Do NOT
- Test Core Data itself (Apple's responsibility)
- Test BaseRepository abstract methods (tested via concrete repos)
- Write integration tests (Step 6)
- Add new repository methods (just test existing)
- Wait for Step 2 (mocks not needed for repository tests)
