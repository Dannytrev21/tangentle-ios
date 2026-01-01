import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("TaskService Tests")
struct TaskServiceTests {

    // MARK: - Get Today's Tasks Tests

    @Test("Get today's tasks returns scheduled tasks for today")
    func getTodaysTasks_returnsScheduledTasks() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Today Task", scheduledDate: Date.testToday)
        try stack.save()

        let mockTaskRepo = MockTaskRepository()
        mockTaskRepo.fetchTodaysTasksResult = .success([task])

        let service = TaskService(
            taskRepository: mockTaskRepo,
            projectRepository: MockProjectRepository(),
            strategyRepository: MockStrategyRepository()
        )

        let tasks = try await service.getTodaysTasks()

        #expect(tasks.count == 1)
        #expect(tasks.first?.title == "Today Task")
        #expect(mockTaskRepo.wasCalled("fetchTodaysTasks"))
    }

    @Test("Get today's tasks returns empty when no tasks scheduled")
    func getTodaysTasks_noTasks_returnsEmpty() async throws {
        let mockTaskRepo = MockTaskRepository()
        mockTaskRepo.fetchTodaysTasksResult = .success([])

        let service = TaskService(
            taskRepository: mockTaskRepo,
            projectRepository: MockProjectRepository(),
            strategyRepository: MockStrategyRepository()
        )

        let tasks = try await service.getTodaysTasks()

        #expect(tasks.isEmpty)
        #expect(mockTaskRepo.wasCalled("fetchTodaysTasks"))
    }

    @Test("Get today's tasks propagates repository error")
    func getTodaysTasks_repositoryError_throws() async throws {
        let mockTaskRepo = MockTaskRepository()
        mockTaskRepo.fetchTodaysTasksResult = .failure(MockError.intentional)

        let service = TaskService(
            taskRepository: mockTaskRepo,
            projectRepository: MockProjectRepository(),
            strategyRepository: MockStrategyRepository()
        )

        await #expect(throws: MockError.self) {
            _ = try await service.getTodaysTasks()
        }
    }

    // MARK: - Get Overdue Tasks Tests

    @Test("Get overdue tasks returns past due incomplete tasks")
    func getOverdueTasks_returnsPastDueIncomplete() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Overdue", dueDate: Date.testYesterday)
        try stack.save()

        let mockTaskRepo = MockTaskRepository()
        mockTaskRepo.fetchOverdueTasksResult = .success([task])

        let service = TaskService(
            taskRepository: mockTaskRepo,
            projectRepository: MockProjectRepository(),
            strategyRepository: MockStrategyRepository()
        )

        let tasks = try await service.getOverdueTasks()

        #expect(tasks.count == 1)
        #expect(mockTaskRepo.wasCalled("fetchOverdueTasks"))
    }

    @Test("Get overdue tasks returns empty when none overdue")
    func getOverdueTasks_noneOverdue_returnsEmpty() async throws {
        let mockTaskRepo = MockTaskRepository()
        mockTaskRepo.fetchOverdueTasksResult = .success([])

        let service = TaskService(
            taskRepository: mockTaskRepo,
            projectRepository: MockProjectRepository(),
            strategyRepository: MockStrategyRepository()
        )

        let tasks = try await service.getOverdueTasks()

        #expect(tasks.isEmpty)
    }

    // MARK: - Get Upcoming Tasks Tests

    @Test("Get upcoming tasks calls repository with correct date range")
    func getUpcomingTasks_callsWithCorrectDays() async throws {
        let mockTaskRepo = MockTaskRepository()
        mockTaskRepo.fetchScheduledBetweenResult = .success([])

        let service = TaskService(
            taskRepository: mockTaskRepo,
            projectRepository: MockProjectRepository(),
            strategyRepository: MockStrategyRepository()
        )

        _ = try await service.getUpcomingTasks(days: 7)

        #expect(mockTaskRepo.wasCalled("fetchScheduledBetween"))
    }

    @Test("Get upcoming tasks returns scheduled tasks within range")
    func getUpcomingTasks_returnsTasksInRange() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Upcoming", scheduledDate: Date.testTomorrow)
        try stack.save()

        let mockTaskRepo = MockTaskRepository()
        mockTaskRepo.fetchScheduledBetweenResult = .success([task])

        let service = TaskService(
            taskRepository: mockTaskRepo,
            projectRepository: MockProjectRepository(),
            strategyRepository: MockStrategyRepository()
        )

        let tasks = try await service.getUpcomingTasks(days: 7)

        #expect(tasks.count == 1)
    }

    // MARK: - Create Task Tests

    @Test("Create task returns task with correct properties")
    func createTask_returnsTaskWithProperties() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let task = try await service.createTask(
            title: "New Task",
            project: nil,
            priority: .high,
            estimatedDuration: 30,
            dueDate: Date.testTomorrow,
            scheduledDate: Date.testToday
        )

        #expect(task.title == "New Task")
        #expect(task.taskPriority == .high)
        #expect(task.estimatedDuration == 30)
        #expect(task.taskStatus == .pending)
        #expect(task.id != nil)
    }

    @Test("Create task sets default status to pending")
    func createTask_setsDefaultStatus() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let task = try await service.createTask(
            title: "Test Task",
            project: nil,
            priority: .medium,
            estimatedDuration: 15,
            dueDate: nil,
            scheduledDate: nil
        )

        #expect(task.taskStatus == .pending)
    }

    @Test("Create task sets default energy to medium")
    func createTask_setsDefaultEnergy() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let task = try await service.createTask(
            title: "Test Task",
            project: nil,
            priority: .medium,
            estimatedDuration: 15,
            dueDate: nil,
            scheduledDate: nil
        )

        #expect(task.energy == .medium)
    }

    @Test("Create task sets timestamps")
    func createTask_setsTimestamps() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let before = Date()
        let task = try await service.createTask(
            title: "Test Task",
            project: nil,
            priority: .medium,
            estimatedDuration: 15,
            dueDate: nil,
            scheduledDate: nil
        )
        let after = Date()

        #expect(task.createdAt != nil)
        #expect(task.createdAt! >= before)
        #expect(task.createdAt! <= after)
    }

    @Test("Create task with project links task to project")
    func createTask_withProject_linksToProject() async throws {
        let stack = TestCoreDataStack()
        let project = stack.createProject(name: "Test Project")
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let task = try await service.createTask(
            title: "Project Task",
            project: project,
            priority: .medium,
            estimatedDuration: 15,
            dueDate: nil,
            scheduledDate: nil
        )

        #expect(task.project == project)
    }

    // MARK: - Update Task Tests

    @Test("Update task applies title change")
    func updateTask_appliesTitle() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Original Title")
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let changes = TaskChanges(title: "Updated Title")
        try await service.updateTask(task, with: changes)

        #expect(task.title == "Updated Title")
    }

    @Test("Update task applies priority change")
    func updateTask_appliesPriority() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Task", priority: .low)
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let changes = TaskChanges(priority: .high)
        try await service.updateTask(task, with: changes)

        #expect(task.taskPriority == .high)
    }

    @Test("Update task updates timestamp")
    func updateTask_updatesTimestamp() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Task")
        task.updatedAt = Date.testYesterday
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let changes = TaskChanges(title: "Updated")
        try await service.updateTask(task, with: changes)

        #expect(task.updatedAt ?? Date.distantPast > Date.testYesterday)
    }

    @Test("Update task applies multiple changes")
    func updateTask_appliesMultipleChanges() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Task", priority: .low)
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let changes = TaskChanges(
            title: "Updated Task",
            status: .inProgress,
            priority: .high,
            estimatedDuration: 60
        )
        try await service.updateTask(task, with: changes)

        #expect(task.title == "Updated Task")
        #expect(task.taskStatus == .inProgress)
        #expect(task.taskPriority == .high)
        #expect(task.estimatedDuration == 60)
    }

    // MARK: - Complete Task Tests

    @Test("Complete task sets status to done")
    func completeTask_setsStatusToDone() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "To Complete", status: .pending)
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        try await service.completeTask(task)

        #expect(task.taskStatus == .done)
    }

    @Test("Complete task sets completedAt timestamp")
    func completeTask_setsCompletedAt() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "To Complete", status: .pending)
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let before = Date()
        try await service.completeTask(task)

        #expect(task.completedAt != nil)
        #expect(task.completedAt! >= before)
    }

    // MARK: - Delete Task Tests

    @Test("Delete task removes from repository")
    func deleteTask_removesFromRepository() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "To Delete")
        let taskId = task.id!
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        try await service.deleteTask(task)

        let fetched = try await taskRepo.fetchById(taskId)
        #expect(fetched == nil)
    }

    // MARK: - Add Subtask Tests

    @Test("Add subtask creates linked subtask")
    func addSubtask_createsLinkedSubtask() async throws {
        let stack = TestCoreDataStack()
        let parent = stack.createTask(title: "Parent Task")
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let subtask = try await service.addSubtask(to: parent, title: "Subtask")

        #expect(subtask.title == "Subtask")
        #expect(subtask.parentTask == parent)
    }

    @Test("Add subtask inherits parent project")
    func addSubtask_inheritsProject() async throws {
        let stack = TestCoreDataStack()
        let project = stack.createProject(name: "Test Project")
        let parent = stack.createTask(title: "Parent Task")
        parent.project = project
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let subtask = try await service.addSubtask(to: parent, title: "Subtask")

        #expect(subtask.project == project)
    }

    @Test("Add subtask inherits parent energy")
    func addSubtask_inheritsEnergy() async throws {
        let stack = TestCoreDataStack()
        let parent = stack.createTask(title: "Parent Task")
        parent.energy = .high
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let subtask = try await service.addSubtask(to: parent, title: "Subtask")

        #expect(subtask.energy == .high)
    }

    @Test("Add subtask sets default duration to 15 minutes")
    func addSubtask_setsDefaultDuration() async throws {
        let stack = TestCoreDataStack()
        let parent = stack.createTask(title: "Parent Task")
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let subtask = try await service.addSubtask(to: parent, title: "Subtask")

        #expect(subtask.estimatedDuration == 15)
    }

    // MARK: - Reorder Tasks Tests

    @Test("Reorder tasks updates sort order")
    func reorderTasks_updatesSortOrder() async throws {
        let stack = TestCoreDataStack()
        let task1 = stack.createTask(title: "Task 1")
        let task2 = stack.createTask(title: "Task 2")
        let task3 = stack.createTask(title: "Task 3")
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        // Reorder: task3, task1, task2
        try await service.reorderTasks([task3, task1, task2])

        #expect(task3.sortOrder == 0)
        #expect(task1.sortOrder == 1)
        #expect(task2.sortOrder == 2)
    }

    @Test("Reorder tasks updates timestamps")
    func reorderTasks_updatesTimestamps() async throws {
        let stack = TestCoreDataStack()
        let task1 = stack.createTask(title: "Task 1")
        let task2 = stack.createTask(title: "Task 2")
        task1.updatedAt = Date.testYesterday
        task2.updatedAt = Date.testYesterday
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)

        let service = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        try await service.reorderTasks([task2, task1])

        #expect(task1.updatedAt ?? Date.distantPast > Date.testYesterday)
        #expect(task2.updatedAt ?? Date.distantPast > Date.testYesterday)
    }

    // MARK: - Error Handling Tests

    @Test("Service handles repository save error")
    func updateTask_saveError_throws() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Test")
        try stack.save()

        let mockTaskRepo = MockTaskRepository()
        mockTaskRepo.shouldThrowOnSave = true

        let service = TaskService(
            taskRepository: mockTaskRepo,
            projectRepository: MockProjectRepository(),
            strategyRepository: MockStrategyRepository()
        )

        await #expect(throws: Error.self) {
            try await service.updateTask(task, with: TaskChanges(title: "Updated"))
        }
    }
}
