import Foundation

/// Service for managing tasks with business logic
final class TaskService: TaskServiceProtocol {
    private let taskRepository: TaskRepositoryProtocol
    private let projectRepository: ProjectRepositoryProtocol
    private let strategyRepository: StrategyRepositoryProtocol

    init(
        taskRepository: TaskRepositoryProtocol,
        projectRepository: ProjectRepositoryProtocol,
        strategyRepository: StrategyRepositoryProtocol
    ) {
        self.taskRepository = taskRepository
        self.projectRepository = projectRepository
        self.strategyRepository = strategyRepository
    }

    // MARK: - Fetch Operations

    func getTodaysTasks() async throws -> [TGTask] {
        try await taskRepository.fetchTodaysTasks()
    }

    func getOverdueTasks() async throws -> [TGTask] {
        try await taskRepository.fetchOverdueTasks()
    }

    func getUpcomingTasks(days: Int) async throws -> [TGTask] {
        let start = Date()
        let end = Calendar.current.date(byAdding: .day, value: days, to: start)!
        return try await taskRepository.fetchScheduledBetween(start: start, end: end)
    }

    // MARK: - CRUD Operations

    func createTask(
        title: String,
        project: TGProject?,
        priority: Priority,
        estimatedDuration: Int16,
        dueDate: Date?,
        scheduledDate: Date?
    ) async throws -> TGTask {
        let task = taskRepository.create()
        task.id = UUID()
        task.title = title
        task.project = project
        task.taskPriority = priority
        task.estimatedDuration = estimatedDuration
        task.dueDate = dueDate
        task.scheduledDate = scheduledDate
        task.taskStatus = .pending
        task.energy = .medium
        task.createdAt = Date()
        task.updatedAt = Date()
        task.sortOrder = 0

        try await taskRepository.save()
        return task
    }

    func updateTask(_ task: TGTask, with changes: TaskChanges) async throws {
        if let title = changes.title { task.title = title }
        if let desc = changes.taskDescription { task.taskDescription = desc }
        if let status = changes.status { task.taskStatus = status }
        if let priority = changes.priority { task.taskPriority = priority }
        if let duration = changes.estimatedDuration { task.estimatedDuration = duration }
        if let due = changes.dueDate { task.dueDate = due }
        if let scheduled = changes.scheduledDate { task.scheduledDate = scheduled }
        if let project = changes.project { task.project = project }

        task.updatedAt = Date()
        try await taskRepository.save()
    }

    func completeTask(_ task: TGTask) async throws {
        task.complete()
        try await taskRepository.save()
    }

    func deleteTask(_ task: TGTask) async throws {
        try await taskRepository.delete(task)
    }

    // MARK: - Subtask Operations

    func addSubtask(to parent: TGTask, title: String) async throws -> TGTask {
        let subtask = taskRepository.create()
        subtask.id = UUID()
        subtask.title = title
        subtask.parentTask = parent
        subtask.project = parent.project
        subtask.taskStatus = .pending
        subtask.estimatedDuration = 15
        subtask.energy = parent.energy
        subtask.sortOrder = Int32(parent.subtasksArray.count)
        subtask.createdAt = Date()
        subtask.updatedAt = Date()

        try await taskRepository.save()
        return subtask
    }

    // MARK: - Reordering

    func reorderTasks(_ tasks: [TGTask]) async throws {
        for (index, task) in tasks.enumerated() {
            task.sortOrder = Int32(index)
            task.updatedAt = Date()
        }
        try await taskRepository.save()
    }
}
