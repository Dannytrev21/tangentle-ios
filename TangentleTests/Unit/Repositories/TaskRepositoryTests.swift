import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("TaskRepository Tests")
struct TaskRepositoryTests {

    // MARK: - Create Tests

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

    // MARK: - Fetch Today's Tasks Tests

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

    @Test("Fetch today's tasks excludes completed tasks")
    func fetchTodaysTasks_excludesCompleted() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "Pending Today", status: .pending, scheduledDate: .testToday)
        _ = stack.createTask(title: "Completed Today", status: .done, scheduledDate: .testToday)

        try stack.save()

        let tasks = try await repo.fetchTodaysTasks()

        #expect(tasks.count == 1)
        #expect(tasks.first?.title == "Pending Today")
    }

    @Test("Fetch today's tasks returns empty when none scheduled")
    func fetchTodaysTasks_noneScheduled_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "Tomorrow Task", scheduledDate: .testTomorrow)

        try stack.save()

        let tasks = try await repo.fetchTodaysTasks()

        #expect(tasks.isEmpty)
    }

    // MARK: - Fetch Overdue Tasks Tests

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

    @Test("Fetch overdue tasks returns empty when none overdue")
    func fetchOverdueTasks_noneOverdue_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "Future Task", dueDate: .testTomorrow)

        try stack.save()

        let tasks = try await repo.fetchOverdueTasks()

        #expect(tasks.isEmpty)
    }

    // MARK: - Fetch by Priority Tests

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

    @Test("Fetch by priority returns empty for no matches")
    func fetchByPriority_noMatches_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "Low Priority", priority: .low)

        try stack.save()

        let highPriority = try await repo.fetchByPriority(.high)

        #expect(highPriority.isEmpty)
    }

    // MARK: - Delete Tests

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

    // MARK: - Fetch by Status Tests

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

    @Test("Fetch by status returns empty for no matches")
    func fetchByStatus_noMatches_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "Pending Task", status: .pending)

        try stack.save()

        let doneTasks = try await repo.fetchByStatus(.done)

        #expect(doneTasks.isEmpty)
    }

    // MARK: - Fetch Scheduled Between Tests

    @Test("Fetch scheduled between returns tasks in date range")
    func fetchScheduledBetween_returnsTasksInRange() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        let today = Date.testToday
        let tomorrow = Date.testTomorrow
        let dayAfter = Date.daysFromNow(2)
        let nextWeek = Date.daysFromNow(7)

        _ = stack.createTask(title: "Today", scheduledDate: today)
        _ = stack.createTask(title: "Tomorrow", scheduledDate: tomorrow)
        _ = stack.createTask(title: "Next Week", scheduledDate: nextWeek)

        try stack.save()

        let tasks = try await repo.fetchScheduledBetween(start: today, end: dayAfter)

        #expect(tasks.count == 2)
        #expect(tasks.contains { $0.title == "Today" })
        #expect(tasks.contains { $0.title == "Tomorrow" })
    }

    @Test("Fetch scheduled between returns empty for no matches")
    func fetchScheduledBetween_noMatches_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "Next Week", scheduledDate: Date.daysFromNow(7))

        try stack.save()

        let tasks = try await repo.fetchScheduledBetween(start: Date.testToday, end: Date.testTomorrow)

        #expect(tasks.isEmpty)
    }

    // MARK: - Fetch Pending Tests

    @Test("Fetch pending returns only pending tasks")
    func fetchPending_returnsOnlyPending() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "Pending", status: .pending)
        _ = stack.createTask(title: "Done", status: .done)
        _ = stack.createTask(title: "In Progress", status: .inProgress)

        try stack.save()

        let tasks = try await repo.fetchPending()

        #expect(tasks.count == 1)
        #expect(tasks.first?.title == "Pending")
    }

    @Test("Fetch pending returns empty when none pending")
    func fetchPending_nonePending_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "Done", status: .done)

        try stack.save()

        let tasks = try await repo.fetchPending()

        #expect(tasks.isEmpty)
    }

    // MARK: - Fetch In Progress Tests

    @Test("Fetch in progress returns only in-progress tasks")
    func fetchInProgress_returnsOnlyInProgress() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "In Progress", status: .inProgress)
        _ = stack.createTask(title: "Pending", status: .pending)

        try stack.save()

        let tasks = try await repo.fetchInProgress()

        #expect(tasks.count == 1)
        #expect(tasks.first?.title == "In Progress")
    }

    @Test("Fetch in progress returns empty when none in progress")
    func fetchInProgress_noneInProgress_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        _ = stack.createTask(title: "Pending", status: .pending)

        try stack.save()

        let tasks = try await repo.fetchInProgress()

        #expect(tasks.isEmpty)
    }

    // MARK: - Fetch by Project Tests

    @Test("Fetch by project returns tasks for specific project")
    func fetchByProject_returnsTasks() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        let project = stack.createProject(name: "My Project")
        let task1 = stack.createTask(title: "Project Task 1")
        task1.project = project
        let task2 = stack.createTask(title: "Project Task 2")
        task2.project = project
        _ = stack.createTask(title: "No Project")

        try stack.save()

        let tasks = try await repo.fetchByProject(project)

        #expect(tasks.count == 2)
        #expect(tasks.allSatisfy { $0.project == project })
    }

    @Test("Fetch by project with no tasks returns empty")
    func fetchByProject_noTasks_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        let project = stack.createProject(name: "Empty Project")
        _ = stack.createTask(title: "Other Task")

        try stack.save()

        let tasks = try await repo.fetchByProject(project)

        #expect(tasks.isEmpty)
    }

    // MARK: - Fetch by Energy Tests

    @Test("Fetch by energy returns tasks matching energy level")
    func fetchByEnergy_returnsMatching() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        let highTask = stack.createTask(title: "High Energy")
        highTask.energy = .high
        let lowTask = stack.createTask(title: "Low Energy")
        lowTask.energy = .low

        try stack.save()

        let highTasks = try await repo.fetchByEnergy(.high)

        #expect(highTasks.count == 1)
        #expect(highTasks.first?.title == "High Energy")
    }

    @Test("Fetch by energy excludes completed tasks")
    func fetchByEnergy_excludesCompleted() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        let pendingHigh = stack.createTask(title: "Pending High", status: .pending)
        pendingHigh.energy = .high
        let completedHigh = stack.createTask(title: "Completed High", status: .done)
        completedHigh.energy = .high

        try stack.save()

        let highTasks = try await repo.fetchByEnergy(.high)

        #expect(highTasks.count == 1)
        #expect(highTasks.first?.title == "Pending High")
    }

    @Test("Fetch by energy returns empty for no matches")
    func fetchByEnergy_noMatches_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        let lowTask = stack.createTask(title: "Low Energy")
        lowTask.energy = .low

        try stack.save()

        let highTasks = try await repo.fetchByEnergy(.high)

        #expect(highTasks.isEmpty)
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct task")
    func fetchById_returnsTask() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        let task = stack.createTask(title: "Find Me")
        let taskId = task.id!

        try stack.save()

        let fetched = try await repo.fetchById(taskId)

        #expect(fetched != nil)
        #expect(fetched?.title == "Find Me")
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = TaskRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }
}
