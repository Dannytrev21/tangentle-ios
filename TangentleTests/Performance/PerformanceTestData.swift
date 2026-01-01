import Foundation
import CoreData
@testable import Tangentle

/// Utilities for seeding large datasets for performance testing
struct PerformanceTestData {

    // MARK: - Task Seeding

    /// Seed tasks for performance testing
    static func seedTasks(_ count: Int, in context: NSManagedObjectContext) {
        let today = Calendar.current.startOfDay(for: Date())
        let statuses = ["pending", "in_progress", "completed", "deferred"]
        let energies = ["low", "medium", "high"]
        let durations: [Int16] = [15, 30, 45, 60, 90, 120]

        for i in 0..<count {
            let task = TGTask(context: context)
            task.id = UUID()
            task.title = "Performance Test Task \(i)"
            task.taskDescription = "Description for task \(i)"
            task.status = statuses[i % statuses.count]
            task.priority = Int16(i % 6)
            task.energyRequired = energies[i % energies.count]
            task.estimatedDuration = durations[i % durations.count]
            task.sortOrder = Int32(i)

            // 1/3 scheduled for today
            if i % 3 == 0 {
                task.scheduledDate = today
            }

            // 20% overdue
            if i % 5 == 0 {
                task.dueDate = today.addingTimeInterval(-86400)
            }

            task.createdAt = Date()
            task.updatedAt = Date()
        }

        try? context.save()
    }

    // MARK: - Project Seeding

    /// Seed projects with tasks
    static func seedProjects(_ count: Int, tasksPerProject: Int, in context: NSManagedObjectContext) {
        for i in 0..<count {
            let project = TGProject(context: context)
            project.id = UUID()
            project.name = "Project \(i)"
            project.isActive = i % 10 != 0 // 90% active
            project.sortOrder = Int32(i)
            project.createdAt = Date()
            project.updatedAt = Date()

            // Add tasks
            for j in 0..<tasksPerProject {
                let task = TGTask(context: context)
                task.id = UUID()
                task.title = "Task \(j) in Project \(i)"
                task.status = "pending"
                task.priority = Int16(j % 6)
                task.energyRequired = "medium"
                task.project = project
                task.createdAt = Date()
                task.updatedAt = Date()
            }
        }

        try? context.save()
    }

    // MARK: - Strategy Seeding

    /// Seed strategies with outcomes
    static func seedStrategies(
        _ count: Int,
        outcomesPerStrategy: Int,
        in context: NSManagedObjectContext
    ) {
        let problemTypes = ["too_big", "unclear", "boring", "scary", "blocked", "distracted", "low_energy", "overwhelmed"]
        let outcomes = ["success", "partial", "failure"]

        for i in 0..<count {
            let strategy = TGStrategy(context: context)
            strategy.id = UUID()
            strategy.name = "Strategy \(i)"
            strategy.strategyDescription = "Description for strategy \(i)"
            strategy.problemTypesArray = [problemTypes[i % problemTypes.count]]
            strategy.taskTypesArray = ["all"]
            strategy.source = i % 2 == 0 ? "default" : "user"
            strategy.isActive = true
            strategy.usageCount = Int32(outcomesPerStrategy)
            strategy.createdAt = Date()
            strategy.updatedAt = Date()

            // Add outcomes
            for j in 0..<outcomesPerStrategy {
                let outcome = TGStrategyOutcome(context: context)
                outcome.id = UUID()
                outcome.result = outcomes[j % outcomes.count]
                outcome.problemType = strategy.problemTypesArray.first!
                outcome.date = Date().addingTimeInterval(TimeInterval(-j * 86400))
                outcome.strategy = strategy
            }
        }

        try? context.save()
    }

    // MARK: - Habit Seeding

    /// Seed habits with completions
    static func seedHabits(
        _ count: Int,
        completionsPerHabit: Int,
        in context: NSManagedObjectContext
    ) {
        let frequencies = ["daily", "weekly"]

        for i in 0..<count {
            let habit = TGHabit(context: context)
            habit.id = UUID()
            habit.name = "Habit \(i)"
            habit.frequency = frequencies[i % frequencies.count]
            habit.isActive = true
            habit.streakCount = Int32(i % 30)
            habit.createdAt = Date()
            habit.updatedAt = Date()

            // Add completions
            for j in 0..<completionsPerHabit {
                let completion = TGHabitCompletion(context: context)
                completion.id = UUID()
                completion.date = Date().addingTimeInterval(TimeInterval(-j * 86400))
                completion.habit = habit
            }
        }

        try? context.save()
    }

    // MARK: - Routine Seeding

    /// Seed routines with steps
    static func seedRoutines(
        _ count: Int,
        stepsPerRoutine: Int,
        in context: NSManagedObjectContext
    ) {
        let types = ["morning", "evening", "focus", "shutdown"]

        for i in 0..<count {
            let routine = TGRoutine(context: context)
            routine.id = UUID()
            routine.name = "Routine \(i)"
            routine.routineType = types[i % types.count]
            routine.scheduledTime = Date()
            routine.isEnabled = true
            routine.daysOfWeek = [1, 2, 3, 4, 5]
            routine.estimatedDuration = Int16(stepsPerRoutine * 5)
            routine.createdAt = Date()
            routine.updatedAt = Date()

            // Add steps
            for j in 0..<stepsPerRoutine {
                let step = TGRoutineStep(context: context)
                step.id = UUID()
                step.name = "Step \(j)"
                step.sortOrder = Int32(j)
                step.estimatedDuration = 5
                step.routine = routine
            }
        }

        try? context.save()
    }

    // MARK: - Cleanup

    /// Clean up all test data
    static func clearAllData(in context: NSManagedObjectContext) {
        let entityNames = [
            "TGTask", "TGProject", "TGGoal", "TGStrategy",
            "TGStrategyOutcome", "TGRoutine", "TGRoutineStep",
            "TGHabit", "TGHabitCompletion", "TGFocusMode",
            "TGMode", "TGProblemType", "TGTag", "TGSettings"
        ]

        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            if let objects = try? context.fetch(fetchRequest) {
                for object in objects {
                    context.delete(object)
                }
            }
        }

        try? context.save()
    }
}
