import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("TaskRepository Tests")
struct TaskRepositoryTests {

    @Test("Create task saves to context")
    func createTask() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)
        let task = repo.create()
        task.id = UUID()
        task.title = "New Task"
        task.status = "pending"
        task.createdAt = Date()
        task.updatedAt = Date()

        try await repo.save()

        let fetched = try await repo.fetchById(task.id!)
        #expect(fetched != nil)
        #expect(fetched?.title == "New Task")
    }

    @Test("Fetch today's tasks returns scheduled tasks")
    func fetchTodaysTasks() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        // Create task scheduled for today
        _ = stack.createTask(title: "Today Task", scheduledDate: .testToday)

        // Create task scheduled for tomorrow (should not be included)
        _ = stack.createTask(title: "Tomorrow Task", scheduledDate: .testTomorrow)

        try stack.save()

        let tasks = try await repo.fetchTodaysTasks()

        #expect(tasks.count == 1)
        #expect(tasks.first?.title == "Today Task")
    }

    @Test("Fetch overdue tasks returns past due incomplete tasks")
    func fetchOverdueTasks() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        // Create overdue task
        _ = stack.createTask(
            title: "Overdue",
            status: .pending,
            dueDate: .testYesterday
        )

        // Create completed overdue task (should not be included)
        let completedTask = stack.createTask(
            title: "Completed",
            status: .done,
            dueDate: .testYesterday
        )
        completedTask.completedAt = Date()

        // Create future task (should not be included)
        _ = stack.createTask(title: "Future", dueDate: .testTomorrow)

        try stack.save()

        let tasks = try await repo.fetchOverdueTasks()

        #expect(tasks.count == 1)
        #expect(tasks.first?.title == "Overdue")
    }

    @Test("Fetch by priority returns correct tasks")
    func fetchByPriority() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "High", priority: .high)
        _ = stack.createTask(title: "Low", priority: .low)

        try stack.save()

        let highPriority = try await repo.fetchByPriority(.high)

        #expect(highPriority.count == 1)
        #expect(highPriority.first?.title == "High")
    }

    @Test("Delete task removes from context")
    func deleteTask() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)
        let task = stack.createTask(title: "To Delete")
        let taskId = task.id!

        try stack.save()

        try await repo.delete(task)

        let fetched = try await repo.fetchById(taskId)
        #expect(fetched == nil)
    }

    @Test("Fetch by status returns matching tasks")
    func fetchByStatus() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "Pending", status: .pending)
        _ = stack.createTask(title: "In Progress", status: .inProgress)

        try stack.save()

        let pendingTasks = try await repo.fetchByStatus(.pending)
        let inProgressTasks = try await repo.fetchByStatus(.inProgress)

        #expect(pendingTasks.count == 1)
        #expect(pendingTasks.first?.title == "Pending")
        #expect(inProgressTasks.count == 1)
        #expect(inProgressTasks.first?.title == "In Progress")
    }
}
