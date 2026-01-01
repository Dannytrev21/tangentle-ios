import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("Cascade Delete Integration Tests")
struct CascadeDeleteTests {

    // MARK: - Task Cascade Deletes

    @Test("Delete task deletes subtasks")
    func deleteTask_deletesSubtasks() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)

        let parent = stack.createTask(title: "Parent")
        let subtask = stack.createTask(title: "Subtask")
        subtask.parentTask = parent
        let subtaskId = subtask.id!
        try stack.save()

        try await taskRepo.delete(parent)

        let fetched = try await taskRepo.fetchById(subtaskId)
        #expect(fetched == nil) // Subtask should be deleted via cascade
    }

    @Test("Delete task deletes nested subtasks")
    func deleteTask_deletesNestedSubtasks() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)

        let grandparent = stack.createTask(title: "Grandparent")
        let parent = stack.createTask(title: "Parent")
        let child = stack.createTask(title: "Child")
        parent.parentTask = grandparent
        child.parentTask = parent

        let parentId = parent.id!
        let childId = child.id!
        try stack.save()

        try await taskRepo.delete(grandparent)

        let fetchedParent = try await taskRepo.fetchById(parentId)
        let fetchedChild = try await taskRepo.fetchById(childId)
        #expect(fetchedParent == nil)
        #expect(fetchedChild == nil)
    }

    @Test("Delete task does not delete project")
    func deleteTask_doesNotDeleteProject() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)
        let projectRepo = ProjectRepository(context: stack.context)

        let project = stack.createProject(name: "Project")
        let task = stack.createTask(title: "Task")
        task.project = project
        let projectId = project.id!
        try stack.save()

        try await taskRepo.delete(task)

        let fetched = try await projectRepo.fetchById(projectId)
        #expect(fetched != nil) // Project should still exist
    }

    @Test("Delete task does not delete goal")
    func deleteTask_doesNotDeleteGoal() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)
        let goalRepo = GoalRepository(context: stack.context)

        let goal = stack.createGoal(name: "Goal")
        let task = stack.createTask(title: "Task")
        task.goal = goal
        let goalId = goal.id!
        try stack.save()

        try await taskRepo.delete(task)

        let fetched = try await goalRepo.fetchById(goalId)
        #expect(fetched != nil)
    }

    @Test("Delete task removes from strategy linked tasks")
    func deleteTask_removesFromStrategyLinkedTasks() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)
        let strategyRepo = StrategyRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Strategy")
        let task = stack.createTask(title: "Task")
        task.addToLinkedStrategies(strategy)
        let strategyId = strategy.id!
        try stack.save()

        try await taskRepo.delete(task)

        let fetched = try await strategyRepo.fetchById(strategyId)
        #expect(fetched != nil)
        #expect(fetched?.linkedTasks?.count == 0)
    }

    @Test("Delete task removes from tags")
    func deleteTask_removesFromTags() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)
        let tagRepo = TagRepository(context: stack.context)

        let tag = stack.createTag(name: "Important")
        let task = stack.createTask(title: "Task")
        task.addToTags(tag)
        let tagId = tag.id!
        try stack.save()

        try await taskRepo.delete(task)

        let fetched = try await tagRepo.fetchById(tagId)
        #expect(fetched != nil)
        #expect(fetched?.tasks?.count == 0)
    }

    // MARK: - Project Cascade Deletes

    @Test("Delete project cascades to tasks")
    func deleteProject_deletesTasksCascade() async throws {
        let stack = TestCoreDataStack()
        let projectRepo = ProjectRepository(context: stack.context)
        let taskRepo = TaskRepository(context: stack.context)

        let project = stack.createProject(name: "Project")
        let task1 = stack.createTask(title: "Task 1")
        let task2 = stack.createTask(title: "Task 2")
        task1.project = project
        task2.project = project
        let task1Id = task1.id!
        let task2Id = task2.id!
        try stack.save()

        try await projectRepo.delete(project)

        let fetched1 = try await taskRepo.fetchById(task1Id)
        let fetched2 = try await taskRepo.fetchById(task2Id)
        // Per Core Data model, project->tasks has Cascade delete
        #expect(fetched1 == nil)
        #expect(fetched2 == nil)
    }

    @Test("Delete project does not delete goal")
    func deleteProject_doesNotDeleteGoal() async throws {
        let stack = TestCoreDataStack()
        let projectRepo = ProjectRepository(context: stack.context)
        let goalRepo = GoalRepository(context: stack.context)

        let goal = stack.createGoal(name: "Goal")
        let project = stack.createProject(name: "Project")
        project.goal = goal
        let goalId = goal.id!
        try stack.save()

        try await projectRepo.delete(project)

        let fetched = try await goalRepo.fetchById(goalId)
        #expect(fetched != nil)
    }

    // MARK: - Strategy Cascade Deletes

    @Test("Delete strategy deletes outcomes")
    func deleteStrategy_deletesOutcomes() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let outcomeRepo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Strategy")
        let outcome = stack.createStrategyOutcome(strategy: strategy, result: .success)
        let outcomeId = outcome.id!
        try stack.save()

        try await strategyRepo.delete(strategy)

        let fetched = try await outcomeRepo.fetchById(outcomeId)
        #expect(fetched == nil) // Outcome should be deleted
    }

    @Test("Delete strategy with multiple outcomes deletes all")
    func deleteStrategy_deletesAllOutcomes() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let outcomeRepo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Strategy")
        var outcomeIds: [UUID] = []
        for _ in 0..<5 {
            let outcome = stack.createStrategyOutcome(strategy: strategy, result: .success)
            outcomeIds.append(outcome.id!)
        }
        try stack.save()

        try await strategyRepo.delete(strategy)

        for id in outcomeIds {
            let fetched = try await outcomeRepo.fetchById(id)
            #expect(fetched == nil)
        }
    }

    @Test("Delete strategy does not delete linked tasks")
    func deleteStrategy_doesNotDeleteLinkedTasks() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let taskRepo = TaskRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Strategy")
        let task = stack.createTask(title: "Task")
        strategy.addToLinkedTasks(task)
        let taskId = task.id!
        try stack.save()

        try await strategyRepo.delete(strategy)

        let fetched = try await taskRepo.fetchById(taskId)
        #expect(fetched != nil)
        #expect(fetched?.linkedStrategies?.count == 0)
    }

    // MARK: - Routine Cascade Deletes

    @Test("Delete routine deletes steps")
    func deleteRoutine_deletesSteps() async throws {
        let stack = TestCoreDataStack()
        let routineRepo = RoutineRepository(context: stack.context)
        let stepRepo = RoutineStepRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Routine")
        let step = stack.createRoutineStep(name: "Step", order: 0, routine: routine)
        let stepId = step.id!
        try stack.save()

        try await routineRepo.delete(routine)

        let fetched = try await stepRepo.fetchById(stepId)
        #expect(fetched == nil)
    }

    @Test("Delete routine with multiple steps deletes all")
    func deleteRoutine_deletesAllSteps() async throws {
        let stack = TestCoreDataStack()
        let routineRepo = RoutineRepository(context: stack.context)
        let stepRepo = RoutineStepRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Routine")
        var stepIds: [UUID] = []
        for i in 0..<3 {
            let step = stack.createRoutineStep(name: "Step \(i)", order: Int32(i), routine: routine)
            stepIds.append(step.id!)
        }
        try stack.save()

        try await routineRepo.delete(routine)

        for id in stepIds {
            let fetched = try await stepRepo.fetchById(id)
            #expect(fetched == nil)
        }
    }

    @Test("Delete routine does not delete linked tasks")
    func deleteRoutine_doesNotDeleteLinkedTasks() async throws {
        let stack = TestCoreDataStack()
        let routineRepo = RoutineRepository(context: stack.context)
        let taskRepo = TaskRepository(context: stack.context)

        let routine = stack.createRoutine(name: "Routine")
        let task = stack.createTask(title: "Task")
        task.routine = routine
        let taskId = task.id!
        try stack.save()

        try await routineRepo.delete(routine)

        let fetched = try await taskRepo.fetchById(taskId)
        #expect(fetched != nil)
        #expect(fetched?.routine == nil)
    }

    // MARK: - Habit Cascade Deletes

    @Test("Delete habit deletes completions")
    func deleteHabit_deletesCompletions() async throws {
        let stack = TestCoreDataStack()
        let habitRepo = HabitRepository(context: stack.context)
        let completionRepo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "Habit")
        let completion = stack.createHabitCompletion(habit: habit)
        let completionId = completion.id!
        try stack.save()

        try await habitRepo.delete(habit)

        let fetched = try await completionRepo.fetchById(completionId)
        #expect(fetched == nil)
    }

    @Test("Delete habit with many completions deletes all")
    func deleteHabit_deletesAllCompletions() async throws {
        let stack = TestCoreDataStack()
        let habitRepo = HabitRepository(context: stack.context)
        let completionRepo = HabitCompletionRepository(context: stack.context)

        let habit = stack.createHabit(name: "Habit")
        var completionIds: [UUID] = []
        for i in 0..<3 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            let completion = stack.createHabitCompletion(habit: habit, date: date)
            completionIds.append(completion.id!)
        }
        try stack.save()

        // Verify completions exist before delete
        let countBefore = habit.completions?.count ?? 0
        #expect(countBefore == 3)

        try await habitRepo.delete(habit)

        for id in completionIds {
            let fetched = try await completionRepo.fetchById(id)
            #expect(fetched == nil)
        }
    }

    // MARK: - Goal Cascade Deletes (Nullify, not Cascade)

    @Test("Delete goal nullifies project relationships")
    func deleteGoal_nullifiesProjects() async throws {
        let stack = TestCoreDataStack()
        let goalRepo = GoalRepository(context: stack.context)
        let projectRepo = ProjectRepository(context: stack.context)

        let goal = stack.createGoal(name: "Goal")
        let project = stack.createProject(name: "Project")
        project.goal = goal
        let projectId = project.id!
        try stack.save()

        try await goalRepo.delete(goal)

        let fetched = try await projectRepo.fetchById(projectId)
        #expect(fetched != nil)
        #expect(fetched?.goal == nil)
    }

    @Test("Delete goal nullifies task relationships")
    func deleteGoal_nullifiesTasks() async throws {
        let stack = TestCoreDataStack()
        let goalRepo = GoalRepository(context: stack.context)
        let taskRepo = TaskRepository(context: stack.context)

        let goal = stack.createGoal(name: "Goal")
        let task = stack.createTask(title: "Task")
        task.goal = goal
        let taskId = task.id!
        try stack.save()

        try await goalRepo.delete(goal)

        let fetched = try await taskRepo.fetchById(taskId)
        #expect(fetched != nil)
        #expect(fetched?.goal == nil)
    }

    // MARK: - FocusMode Cascade Deletes (Nullify)

    @Test("Delete focus mode nullifies task relationships")
    func deleteFocusMode_nullifiesTasks() async throws {
        let stack = TestCoreDataStack()
        let focusModeRepo = FocusModeRepository(context: stack.context)
        let taskRepo = TaskRepository(context: stack.context)

        let focusMode = stack.createFocusMode(name: "Focus Mode")
        let task = stack.createTask(title: "Task")
        task.focusMode = focusMode
        let taskId = task.id!
        try stack.save()

        try await focusModeRepo.delete(focusMode)

        let fetched = try await taskRepo.fetchById(taskId)
        #expect(fetched != nil)
        #expect(fetched?.focusMode == nil)
    }

    @Test("Delete focus mode nullifies project inclusions")
    func deleteFocusMode_nullifiesProjectInclusions() async throws {
        let stack = TestCoreDataStack()
        let focusModeRepo = FocusModeRepository(context: stack.context)
        let projectRepo = ProjectRepository(context: stack.context)

        let focusMode = stack.createFocusMode(name: "Focus Mode")
        let project = stack.createProject(name: "Project")
        focusMode.addToIncludedProjects(project)
        let projectId = project.id!
        try stack.save()

        try await focusModeRepo.delete(focusMode)

        let fetched = try await projectRepo.fetchById(projectId)
        #expect(fetched != nil)
        #expect(fetched?.focusModes?.count == 0)
    }

    // MARK: - Tag Cascade Deletes (Nullify)

    @Test("Delete tag nullifies task relationships")
    func deleteTag_nullifiesTaskRelationships() async throws {
        let stack = TestCoreDataStack()
        let tagRepo = TagRepository(context: stack.context)
        let taskRepo = TaskRepository(context: stack.context)

        let tag = stack.createTag(name: "Tag")
        let task = stack.createTask(title: "Task")
        task.addToTags(tag)
        let taskId = task.id!
        try stack.save()

        try await tagRepo.delete(tag)

        let fetched = try await taskRepo.fetchById(taskId)
        #expect(fetched != nil)
        #expect(fetched?.tags?.count == 0)
    }
}
