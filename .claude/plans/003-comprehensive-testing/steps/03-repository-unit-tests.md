# Step 3: Repository Unit Tests

## Context
Repositories are the data access layer. They interact with Core Data and provide the foundation for all business logic. TaskRepository already has tests; we need to expand coverage to all 15 repositories with 90%+ coverage target.

## Goal
Complete unit test coverage for all repository implementations, ensuring all CRUD operations and custom queries are tested.

## Prerequisites
- Step 1 completed (directory structure, helpers)
- Step 2 completed (mocks available for any dependencies)

## High-Level Steps
1. Move existing TaskRepositoryTests to new location
2. Create tests for remaining 14 repositories
3. Test all protocol methods for each repository
4. Test edge cases and error conditions
5. Verify 90%+ coverage achieved

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
- `fetchPending()` returns only pending tasks
- `fetchInProgress()` returns only in-progress tasks
- `fetchByEnergy()` filters by energy level
- `fetchByProject()` returns tasks for specific project
- Edge cases: empty results, multiple matches

#### 2. ProjectRepository
Tests needed:
- `create()` creates valid project
- `fetchActive()` excludes archived
- `fetchByGoal()` returns projects for goal
- `fetchArchived()` returns only archived
- `delete()` removes project
- Edge cases: project with no tasks, project with tasks

#### 3. GoalRepository
Tests needed:
- `create()` creates valid goal
- `fetchActive()` returns active goals only
- `fetchWithUpcomingDeadlines(within:)` filters correctly
- `delete()` removes goal
- Edge cases: no goals, all past deadlines

#### 4. StrategyRepository
Tests needed:
- `fetchActive()` returns active strategies
- `fetchByProblemType()` filters correctly
- `fetchTopRated(limit:)` orders by score
- `fetchBySource()` filters by source
- `fetchForCoaching(problemType:limit:)` returns appropriate strategies
- `fetchDefaults()` returns built-in strategies
- `fetchUserCreated()` returns user strategies
- Edge cases: no strategies for problem type

#### 5. StrategyOutcomeRepository
Tests needed:
- `create()` creates valid outcome
- `fetchByStrategy()` returns outcomes for strategy
- `fetchRecent(limit:)` orders by date and limits
- Edge cases: strategy with no outcomes

#### 6. RoutineRepository
Tests needed:
- `create()` creates valid routine
- `fetchEnabled()` excludes disabled
- `fetchByType()` filters by type
- `fetchScheduledForToday()` returns today's routines
- Edge cases: no routines for type

#### 7. RoutineStepRepository
Tests needed:
- `create()` creates valid step
- `fetchByRoutine()` returns steps for routine
- Order is preserved
- Edge cases: routine with no steps

#### 8. HabitRepository
Tests needed:
- `create()` creates valid habit
- `fetchActive()` returns active habits
- `fetchDueToday()` returns today's due habits
- `fetchByFrequency()` filters by frequency
- Edge cases: no habits due today

#### 9. HabitCompletionRepository
Tests needed:
- `create()` creates valid completion
- `fetchByHabit()` returns completions for habit
- `fetchForDate(date:habit:)` filters by date
- Edge cases: no completions

#### 10. FocusModeRepository
Tests needed:
- `create()` creates valid focus mode
- `fetchActive()` returns active modes
- `fetchAutomatic()` returns auto-triggered modes
- `fetchCurrentlyActive()` returns mode active now
- Edge cases: overlapping time ranges

#### 11. ModeRepository
Tests needed:
- `create()` creates valid mode
- `fetchDefault()` returns default mode
- `fetchAll()` returns all modes
- Edge cases: no default mode set

#### 12. ProblemTypeRepository
Tests needed:
- `create()` creates valid problem type
- `fetchAll()` returns all types
- `fetchByIdentifier()` finds by identifier
- `fetchDefaults()` returns built-in types
- Edge cases: duplicate identifiers

#### 13. TagRepository
Tests needed:
- `create()` creates valid tag
- `fetchAll()` returns all tags
- `fetchOrCreate()` returns existing or creates new
- `fetchByName()` finds by name
- Edge cases: duplicate names, empty name

#### 14. SettingsRepository
Tests needed:
- `getSettings()` returns or creates settings
- `updateSettings()` persists changes
- Settings is singleton (only one exists)
- Edge cases: first launch (no settings)

## Files to Create
- `TangentleTests/Unit/Repositories/TaskRepositoryTests.swift` (move & expand)
- `TangentleTests/Unit/Repositories/ProjectRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/GoalRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/StrategyRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/StrategyOutcomeRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/RoutineRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/RoutineStepRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/HabitRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/HabitCompletionRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/FocusModeRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/ModeRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/ProblemTypeRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/TagRepositoryTests.swift`
- `TangentleTests/Unit/Repositories/SettingsRepositoryTests.swift`

## Files to Modify
- None (all new files or moves)

## Patterns to Follow
Reference: `TangentleTests/Unit/TaskRepositoryTests.swift` lines 1-126 for test structure
Reference: `TangentleTests/Unit/TestHelpers.swift` for factory methods

## Acceptance Criteria
- [ ] All 14 repository test files created
- [ ] Each repository has tests for all protocol methods
- [ ] Edge cases tested (empty, null, duplicates)
- [ ] Error conditions tested where applicable
- [ ] 90%+ line coverage for all repositories
- [ ] All tests pass

## Testing Requirements

### Unit Tests
- Test files: See "Files to Create" above
- Minimum tests per repository: 5-10 depending on complexity

### What to Test
- CRUD operations (create, read, update, delete)
- Custom query methods
- Filtering and sorting
- Relationship handling
- Edge cases (empty results, duplicates, invalid data)
- Error conditions (save failures, fetch failures)

## Verification Commands
```bash
# Run repository tests only
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/Unit/Repositories

# Run all tests
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'

# Check coverage (requires Xcode coverage enabled)
# Coverage report available in Xcode after test run
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
