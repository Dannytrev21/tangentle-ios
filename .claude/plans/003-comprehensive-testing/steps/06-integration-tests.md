# Step 6: Integration Tests

## Context
Integration tests verify that components work together correctly. This includes Core Data relationships, cascade behaviors, and service-to-repository interactions without mocks.

## Goal
Create integration tests that verify correct behavior when real components interact, especially Core Data relationship handling and cascade deletes.

## Prerequisites
- Step 1 completed (directory structure)
- Step 3 completed (understand repository patterns)

## High-Level Steps
1. Create Core Data relationship tests
2. Create cascade delete tests
3. Create service integration tests (real repos, mocked AI)
4. Verify data integrity across operations

## Detailed Requirements

### Test Pattern
Use real Core Data (in-memory) but may mock external services:
```swift
@Suite("Integration Tests")
struct IntegrationTests {
    @Test("Full flow description")
    func testFullFlow() async throws {
        // Arrange - use real repos, real Core Data
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)
        let projectRepo = ProjectRepository(context: stack.context)
        let taskService = TaskService(
            taskRepository: taskRepo,
            projectRepository: projectRepo,
            strategyRepository: StrategyRepository(context: stack.context)
        )

        // Act - perform multi-component operation
        let project = projectRepo.create()
        project.name = "Test Project"
        try await projectRepo.save()

        let task = try await taskService.createTask(
            title: "Test Task",
            project: project,
            priority: .high,
            estimatedDuration: 30,
            dueDate: nil,
            scheduledDate: Date()
        )

        // Assert - verify relationships are correct
        #expect(task.project == project)
        #expect(project.tasks?.contains(task) == true)
    }
}
```

### Core Data Relationship Tests

#### Task-Project Relationships
- `testTaskProject_assigningProject_updatesRelationship()`
- `testTaskProject_removingProject_clearsRelationship()`
- `testProject_withMultipleTasks_containsAllTasks()`
- `testProject_taskCount_isAccurate()`

#### Task-Subtask Relationships
- `testTaskSubtask_addingSubtask_updatesParent()`
- `testTaskSubtask_subtaskAccessesParent()`
- `testTaskSubtask_multipleSubtasks_maintainOrder()`
- `testTaskSubtask_nestedSubtasks_workCorrectly()`

#### Task-Strategy Relationships
- `testTaskStrategy_assigningStrategy_updatesRelationship()`
- `testTaskStrategy_multipleStrategies_allAccessible()`
- `testStrategy_usedByMultipleTasks_trackedCorrectly()`

#### Task-Tag Relationships
- `testTaskTag_addingTag_updatesRelationship()`
- `testTaskTag_multipleTags_allAccessible()`
- `testTag_usedByMultipleTasks_trackedCorrectly()`

#### Strategy-Outcome Relationships
- `testStrategyOutcome_addingOutcome_updatesStrategy()`
- `testStrategyOutcome_multipleOutcomes_maintainOrder()`
- `testStrategy_scoreCalculation_usesAllOutcomes()`

#### Project-Goal Relationships
- `testProjectGoal_assigningGoal_updatesRelationship()`
- `testGoal_withMultipleProjects_containsAll()`

#### Routine-Step Relationships
- `testRoutineStep_addingStep_updatesRoutine()`
- `testRoutineStep_stepOrder_isPreserved()`
- `testRoutine_stepCount_isAccurate()`

#### Habit-Completion Relationships
- `testHabitCompletion_addingCompletion_updatesHabit()`
- `testHabit_completionHistory_accessible()`

### Cascade Delete Tests

#### Task Cascades
- `testDeleteTask_deletesSubtasks()`
- `testDeleteTask_doesNotDeleteProject()`
- `testDeleteTask_removesFromStrategies()`
- `testDeleteTask_removesFromTags()`

#### Project Cascades
- `testDeleteProject_doesNotDeleteTasks()` (nullifies relationship)
- `testDeleteProject_taskProjectBecomesNil()`

#### Strategy Cascades
- `testDeleteStrategy_deletesOutcomes()`
- `testDeleteStrategy_removesFromTasks()`

#### Routine Cascades
- `testDeleteRoutine_deletesSteps()`

#### Habit Cascades
- `testDeleteHabit_deletesCompletions()`

#### Goal Cascades
- `testDeleteGoal_doesNotDeleteProjects()` (nullifies)

### Service Integration Tests

#### TaskService Integration
- `testTaskService_createTaskInProject_relationshipCorrect()`
- `testTaskService_completeTaskWithSubtasks_allCompleted()`
- `testTaskService_reorderTasks_persistsCorrectly()`

#### StrategyService Integration
- `testStrategyService_recordOutcome_updatesScore()`
- `testStrategyService_getTopStrategies_orderedByScore()`
- `testStrategyService_coachingFlow_fullCycle()`

### Data Integrity Tests
- `testConcurrentSaves_noDataCorruption()`
- `testLargeDataset_queriesReturnCorrectResults()`
- `testRefresh_updatesObjectsFromStore()`

## Files to Create
- `TangentleTests/Integration/CoreData/TaskRelationshipTests.swift`
- `TangentleTests/Integration/CoreData/ProjectRelationshipTests.swift`
- `TangentleTests/Integration/CoreData/StrategyRelationshipTests.swift`
- `TangentleTests/Integration/CoreData/CascadeDeleteTests.swift`
- `TangentleTests/Integration/Services/TaskServiceIntegrationTests.swift`
- `TangentleTests/Integration/Services/StrategyServiceIntegrationTests.swift`

## Files to Modify
- None

## Patterns to Follow
Reference: `TangentleTests/Unit/TestHelpers.swift` for TestCoreDataStack usage
Reference: `Tangentle/Data/Tangentle.xcdatamodeld` for relationship definitions

## Acceptance Criteria
- [ ] All Core Data relationships tested
- [ ] All cascade delete behaviors verified
- [ ] Service integration tests pass with real repos
- [ ] Data integrity verified under concurrent access
- [ ] All tests pass
- [ ] Tests use in-memory Core Data (fast, isolated)

## Testing Requirements

### Integration Tests
- Test files: See "Files to Create" above
- Minimum: 30-40 integration tests

### What to Test
- Relationship bidirectionality
- Cascade behaviors match model definition
- Cross-component data flows
- Data consistency

## Verification Commands
```bash
# Run integration tests only
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleTests/Integration

# Run all tests
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Documentation Updates
- None for this step

## Error Recovery
If verification fails:
1. Check Core Data model relationship definitions
2. Verify delete rules (Cascade, Nullify, Deny)
3. Check inverse relationships are set
4. Ensure context.save() after changes

## Do NOT
- Mock repositories in integration tests (use real ones)
- Test isolated unit behavior (covered in Steps 3-5)
- Make network calls (AI still mocked)
- Create slow tests (in-memory DB should be fast)
