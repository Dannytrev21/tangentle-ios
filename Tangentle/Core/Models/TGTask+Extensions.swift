import Foundation
import CoreData

extension TGTask {
    // MARK: - Computed Properties

    var taskStatus: TaskStatus {
        get { TaskStatus(rawValue: status ?? "pending") ?? .pending }
        set { status = newValue.rawValue }
    }

    var taskPriority: Priority {
        get { Priority(rawValue: priority) ?? .none }
        set { priority = newValue.rawValue }
    }

    var energy: EnergyLevel {
        get { EnergyLevel(rawValue: energyRequired ?? "medium") ?? .medium }
        set { energyRequired = newValue.rawValue }
    }

    var isCompleted: Bool {
        taskStatus.isCompleted
    }

    var isOverdue: Bool {
        guard let due = dueDate else { return false }
        return due < Date() && !isCompleted
    }

    var hasSubtasks: Bool {
        (subtasks?.count ?? 0) > 0
    }

    var subtasksArray: [TGTask] {
        let set = subtasks as? Set<TGTask> ?? []
        return set.sorted { ($0.sortOrder) < ($1.sortOrder) }
    }

    var tagsArray: [TGTag] {
        let set = tags as? Set<TGTag> ?? []
        return set.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }

    var blockedByArray: [TGTask] {
        let set = blockedBy as? Set<TGTask> ?? []
        return Array(set)
    }

    var blockingArray: [TGTask] {
        let set = blocking as? Set<TGTask> ?? []
        return Array(set)
    }

    var isBlocked: Bool {
        blockedByArray.contains { !$0.isCompleted }
    }

    var linkedStrategiesArray: [TGStrategy] {
        let set = linkedStrategies as? Set<TGStrategy> ?? []
        return Array(set)
    }

    // MARK: - Convenience Initializer

    convenience init(
        context: NSManagedObjectContext,
        title: String,
        project: TGProject? = nil,
        priority: Priority = .none,
        estimatedDuration: Int16 = 30,
        energy: EnergyLevel = .medium
    ) {
        self.init(context: context)
        self.id = UUID()
        self.title = title
        self.project = project
        self.taskPriority = priority
        self.estimatedDuration = estimatedDuration
        self.energy = energy
        self.taskStatus = .pending
        self.createdAt = Date()
        self.updatedAt = Date()
        self.sortOrder = 0
    }

    // MARK: - Methods

    func complete() {
        taskStatus = .done
        completedAt = Date()
        updatedAt = Date()
    }

    func start() {
        taskStatus = .inProgress
        startDate = Date()
        updatedAt = Date()
    }

    func defer_() {
        taskStatus = .deferred
        updatedAt = Date()
    }

    func updateTimestamp() {
        updatedAt = Date()
    }

    func addSubtask(_ subtask: TGTask) {
        subtask.parentTask = self
        subtask.sortOrder = Int32(subtasksArray.count)
        updateTimestamp()
    }

    func addBlocker(_ blocker: TGTask) {
        mutableSetValue(forKey: "blockedBy").add(blocker)
        updateTimestamp()
    }

    func removeBlocker(_ blocker: TGTask) {
        mutableSetValue(forKey: "blockedBy").remove(blocker)
        updateTimestamp()
    }
}
