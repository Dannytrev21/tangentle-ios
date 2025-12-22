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
