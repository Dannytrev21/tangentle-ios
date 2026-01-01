import Foundation
import CoreData
@testable import Tangentle

/// Test helper for creating in-memory Core Data stack
struct TestCoreDataStack {
    let container: TestContainer
    var context: NSManagedObjectContext { container.viewContext }

    init() {
        container = TestContainer()
    }

    func createTask(
        title: String = "Test Task",
        priority: Priority = .medium,
        status: TaskStatus = .pending,
        estimatedDuration: Int16 = 30,
        scheduledDate: Date? = nil,
        dueDate: Date? = nil
    ) -> TGTask {
        let task = TGTask(context: context)
        task.id = UUID()
        task.title = title
        task.taskPriority = priority
        task.taskStatus = status
        task.estimatedDuration = estimatedDuration
        task.scheduledDate = scheduledDate
        task.dueDate = dueDate
        task.energy = .medium
        task.createdAt = Date()
        task.updatedAt = Date()
        task.sortOrder = 0
        return task
    }

    func createProject(name: String = "Test Project", emoji: String? = nil) -> TGProject {
        let project = TGProject(context: context)
        project.id = UUID()
        project.name = name
        project.emoji = emoji
        project.isActive = true
        project.sortOrder = 0
        project.createdAt = Date()
        project.updatedAt = Date()
        return project
    }

    func createStrategy(
        name: String = "Test Strategy",
        problemTypes: [String] = ["too_big"]
    ) -> TGStrategy {
        let strategy = TGStrategy(context: context)
        strategy.id = UUID()
        strategy.name = name
        strategy.strategyDescription = "Test description"
        strategy.problemTypesArray = problemTypes
        strategy.taskTypesArray = ["all"]
        strategy.source = "test"
        strategy.isActive = true
        strategy.usageCount = 0
        strategy.createdAt = Date()
        strategy.updatedAt = Date()
        return strategy
    }

    func createGoal(
        name: String = "Test Goal",
        targetDate: Date? = nil
    ) -> TGGoal {
        let goal = TGGoal(context: context)
        goal.id = UUID()
        goal.name = name
        goal.targetDate = targetDate
        goal.isActive = true
        goal.createdAt = Date()
        goal.updatedAt = Date()
        return goal
    }

    func createRoutine(
        name: String = "Test Routine",
        type: RoutineType = .morning,
        scheduledTime: Date = Date()
    ) -> TGRoutine {
        let routine = TGRoutine(context: context)
        routine.id = UUID()
        routine.name = name
        routine.routineType = type.rawValue
        routine.scheduledTime = scheduledTime
        routine.isEnabled = true
        routine.daysOfWeek = [1, 2, 3, 4, 5] // Weekdays
        routine.estimatedDuration = 30
        routine.createdAt = Date()
        routine.updatedAt = Date()
        return routine
    }

    func createRoutineStep(
        name: String = "Test Step",
        order: Int32 = 0,
        routine: TGRoutine
    ) -> TGRoutineStep {
        let step = TGRoutineStep(context: context)
        step.id = UUID()
        step.name = name
        step.sortOrder = order
        step.estimatedDuration = 5
        step.routine = routine
        return step
    }

    func createHabit(
        name: String = "Test Habit",
        frequency: HabitFrequency = .daily
    ) -> TGHabit {
        let habit = TGHabit(context: context)
        habit.id = UUID()
        habit.name = name
        habit.frequency = frequency.rawValue
        habit.isActive = true
        habit.streakCount = 0
        habit.targetCount = 1
        habit.createdAt = Date()
        habit.updatedAt = Date()
        return habit
    }

    func createHabitCompletion(
        habit: TGHabit,
        date: Date = Date()
    ) -> TGHabitCompletion {
        let completion = TGHabitCompletion(context: context)
        completion.id = UUID()
        completion.date = date
        completion.count = 1
        completion.habit = habit
        return completion
    }

    func createFocusMode(
        name: String = "Test Focus Mode",
        startTime: Date? = nil,
        endTime: Date? = nil
    ) -> TGFocusMode {
        let mode = TGFocusMode(context: context)
        mode.id = UUID()
        mode.name = name
        mode.startTime = startTime
        mode.endTime = endTime
        mode.isActive = true
        mode.isAutomatic = false
        mode.sortOrder = 0
        mode.createdAt = Date()
        mode.updatedAt = Date()
        return mode
    }

    func createMode(
        name: String = "Test Mode",
        isDefault: Bool = false
    ) -> TGMode {
        let mode = TGMode(context: context)
        mode.id = UUID()
        mode.name = name
        mode.isDefault = isDefault
        mode.isShared = false
        mode.createdAt = Date()
        mode.updatedAt = Date()
        return mode
    }

    func createProblemType(
        identifier: String = "test_problem",
        label: String = "Test Problem"
    ) -> TGProblemType {
        let problemType = TGProblemType(context: context)
        problemType.id = UUID()
        problemType.identifier = identifier
        problemType.label = label
        problemType.problemTypeDescription = "Test problem description"
        problemType.isDefault = false
        problemType.sortOrder = 0
        return problemType
    }

    func createTag(name: String = "Test Tag") -> TGTag {
        let tag = TGTag(context: context)
        tag.id = UUID()
        tag.name = name
        tag.sortOrder = 0
        return tag
    }

    func createSettings() -> TGSettings {
        let settings = TGSettings(context: context)
        settings.id = UUID()
        settings.schedule = ScheduleSettings.default
        settings.tasks = TaskSettings.default
        settings.display = DisplaySettings.default
        settings.coaching = CoachingSettings.default
        settings.updatedAt = Date()
        return settings
    }

    func createStrategyOutcome(
        strategy: TGStrategy,
        result: OutcomeResult = .success
    ) -> TGStrategyOutcome {
        let outcome = TGStrategyOutcome(context: context)
        outcome.id = UUID()
        outcome.result = result.rawValue
        outcome.problemType = strategy.problemTypesArray.first ?? "unknown"
        outcome.taskTitle = "Test Task"
        outcome.taskType = "general"
        outcome.date = Date()
        outcome.strategy = strategy
        return outcome
    }

    func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

/// Date helpers for testing
extension Date {
    static var testToday: Date { Calendar.current.startOfDay(for: Date()) }

    static var testYesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: testToday)!
    }

    static var testTomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: testToday)!
    }

    static func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: testToday)!
    }
}
