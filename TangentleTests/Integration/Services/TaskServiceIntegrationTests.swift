import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("TaskService Integration Tests")
struct TaskServiceIntegrationTests {

    // MARK: - Create Task Integration

    @Test("Create task in project sets relationship correctly")
    func taskService_createTaskInProject_relationshipCorrect() async throws {
        let stack = TestCoreDataStack()
        let project = stack.createProject(name: "Project")
        try stack.save()

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let task = try await taskService.createTask(
            title: "New Task",
            project: project,
            priority: .medium,
            estimatedDuration: 30,
            dueDate: nil,
            scheduledDate: Date()
        )

        #expect(task.project == project)
        #expect(project.tasks?.contains(task) == true)
    }

    @Test("Create task without project works")
    func taskService_createTaskWithoutProject_works() async throws {
        let stack = TestCoreDataStack()

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let task = try await taskService.createTask(
            title: "No Project Task",
            project: nil,
            priority: .high,
            estimatedDuration: 15,
            dueDate: nil,
            scheduledDate: nil
        )

        #expect(task.title == "No Project Task")
        #expect(task.project == nil)
        #expect(task.id != nil)
    }

    @Test("Create task persists to database")
    func taskService_createTask_persistsToDatabase() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)

        let taskService = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let task = try await taskService.createTask(
            title: "Persistent Task",
            project: nil,
            priority: .medium,
            estimatedDuration: 30,
            dueDate: nil,
            scheduledDate: Date()
        )

        // Refetch to verify persistence
        let fetched = try await taskRepo.fetchById(task.id!)
        #expect(fetched != nil)
        #expect(fetched?.title == "Persistent Task")
    }

    // MARK: - Subtask Integration

    @Test("Add subtask creates correct relationship")
    func taskService_addSubtask_createsRelationship() async throws {
        let stack = TestCoreDataStack()
        let parent = stack.createTask(title: "Parent Task")
        try stack.save()

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let subtask = try await taskService.addSubtask(to: parent, title: "Subtask")

        #expect(subtask.parentTask == parent)
        #expect(parent.subtasks?.contains(subtask) == true)
    }

    @Test("Subtask inherits parent project")
    func taskService_addSubtask_inheritsProject() async throws {
        let stack = TestCoreDataStack()
        let project = stack.createProject(name: "Project")
        let parent = stack.createTask(title: "Parent Task")
        parent.project = project
        try stack.save()

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let subtask = try await taskService.addSubtask(to: parent, title: "Subtask")

        #expect(subtask.project == project)
    }

    @Test("Multiple subtasks have correct sort order")
    func taskService_addMultipleSubtasks_correctSortOrder() async throws {
        let stack = TestCoreDataStack()
        let parent = stack.createTask(title: "Parent Task")
        try stack.save()

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let subtask1 = try await taskService.addSubtask(to: parent, title: "Subtask 1")
        let subtask2 = try await taskService.addSubtask(to: parent, title: "Subtask 2")
        let subtask3 = try await taskService.addSubtask(to: parent, title: "Subtask 3")

        // sortOrder is assigned based on subtasksArray.count which includes the subtask after adding
        // So first subtask gets sortOrder = 1, second = 2, etc.
        #expect(subtask1.sortOrder < subtask2.sortOrder)
        #expect(subtask2.sortOrder < subtask3.sortOrder)
    }

    // MARK: - Complete Task Integration

    @Test("Complete task sets status and completedAt")
    func taskService_completeTask_setsStatusAndCompletedAt() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Task to Complete", status: .pending)
        try stack.save()

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        try await taskService.completeTask(task)

        #expect(task.taskStatus == .done)
        #expect(task.completedAt != nil)
    }

    // MARK: - Reorder Tasks Integration

    @Test("Reorder tasks persists correctly")
    func taskService_reorderTasks_persistsCorrectly() async throws {
        let stack = TestCoreDataStack()
        let task1 = stack.createTask(title: "Task 1")
        task1.sortOrder = 0
        let task2 = stack.createTask(title: "Task 2")
        task2.sortOrder = 1
        let task3 = stack.createTask(title: "Task 3")
        task3.sortOrder = 2
        try stack.save()

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        try await taskService.reorderTasks([task3, task1, task2])

        #expect(task3.sortOrder == 0)
        #expect(task1.sortOrder == 1)
        #expect(task2.sortOrder == 2)
    }

    // MARK: - Fetch Operations Integration

    @Test("Get today's tasks uses repository correctly")
    func taskService_getTodaysTasks_usesRepositoryCorrectly() async throws {
        let stack = TestCoreDataStack()
        _ = stack.createTask(title: "Today Task", scheduledDate: .testToday)
        _ = stack.createTask(title: "Tomorrow Task", scheduledDate: .testTomorrow)
        try stack.save()

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let tasks = try await taskService.getTodaysTasks()

        #expect(tasks.count == 1)
        #expect(tasks.first?.title == "Today Task")
    }

    @Test("Get overdue tasks uses repository correctly")
    func taskService_getOverdueTasks_usesRepositoryCorrectly() async throws {
        let stack = TestCoreDataStack()
        _ = stack.createTask(title: "Overdue Task", status: .pending, dueDate: .testYesterday)
        _ = stack.createTask(title: "Future Task", dueDate: .testTomorrow)
        try stack.save()

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let tasks = try await taskService.getOverdueTasks()

        #expect(tasks.count == 1)
        #expect(tasks.first?.title == "Overdue Task")
    }

    @Test("Get upcoming tasks uses date range correctly")
    func taskService_getUpcomingTasks_usesDateRangeCorrectly() async throws {
        let stack = TestCoreDataStack()
        // Use tomorrow to ensure it's in the future
        _ = stack.createTask(title: "Tomorrow Task", scheduledDate: .testTomorrow)
        _ = stack.createTask(title: "Next Week Task", scheduledDate: Date.daysFromNow(7))
        try stack.save()

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let tasks = try await taskService.getUpcomingTasks(days: 3)

        #expect(tasks.count == 1)
        #expect(tasks.first?.title == "Tomorrow Task")
    }

    // MARK: - Update Task Integration

    @Test("Update task persists changes")
    func taskService_updateTask_persistsChanges() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)
        let task = stack.createTask(title: "Original Title")
        let taskId = task.id!
        try stack.save()

        let taskService = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let changes = TaskChanges(title: "Updated Title", priority: .high)
        try await taskService.updateTask(task, with: changes)

        let fetched = try await taskRepo.fetchById(taskId)
        #expect(fetched?.title == "Updated Title")
        #expect(fetched?.taskPriority == .high)
    }

    @Test("Update task can change project")
    func taskService_updateTask_canChangeProject() async throws {
        let stack = TestCoreDataStack()
        let project1 = stack.createProject(name: "Project 1")
        let project2 = stack.createProject(name: "Project 2")
        let task = stack.createTask(title: "Task")
        task.project = project1
        try stack.save()

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        let changes = TaskChanges(project: project2)
        try await taskService.updateTask(task, with: changes)

        #expect(task.project == project2)
        #expect(project1.tasks?.contains(task) != true)
        #expect(project2.tasks?.contains(task) == true)
    }

    // MARK: - Delete Task Integration

    @Test("Delete task removes from database")
    func taskService_deleteTask_removesFromDatabase() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)
        let task = stack.createTask(title: "Task to Delete")
        let taskId = task.id!
        try stack.save()

        let taskService = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        try await taskService.deleteTask(task)

        let fetched = try await taskRepo.fetchById(taskId)
        #expect(fetched == nil)
    }

    @Test("Delete task cascades to subtasks")
    func taskService_deleteTask_cascadesToSubtasks() async throws {
        let stack = TestCoreDataStack()
        let taskRepo = TaskRepository(context: stack.context)
        let parent = stack.createTask(title: "Parent")
        let subtask = stack.createTask(title: "Subtask")
        subtask.parentTask = parent
        let subtaskId = subtask.id!
        try stack.save()

        let taskService = TaskService(
            taskRepository: taskRepo,
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        try await taskService.deleteTask(parent)

        let fetched = try await taskRepo.fetchById(subtaskId)
        #expect(fetched == nil)
    }
}
