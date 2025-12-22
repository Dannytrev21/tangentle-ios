import Foundation
import CoreData

extension TGProject {
    // MARK: - Computed Properties

    var tasksArray: [TGTask] {
        let set = tasks as? Set<TGTask> ?? []
        return set.sorted { ($0.sortOrder) < ($1.sortOrder) }
    }

    var activeTasks: [TGTask] {
        tasksArray.filter { $0.taskStatus.isActive }
    }

    var completedTasks: [TGTask] {
        tasksArray.filter { $0.isCompleted }
    }

    var pendingTasks: [TGTask] {
        tasksArray.filter { $0.taskStatus == .pending }
    }

    var inProgressTasks: [TGTask] {
        tasksArray.filter { $0.taskStatus == .inProgress }
    }

    var overdueTasks: [TGTask] {
        tasksArray.filter { $0.isOverdue }
    }

    var completionPercentage: Double {
        guard !tasksArray.isEmpty else { return 0 }
        return Double(completedTasks.count) / Double(tasksArray.count)
    }

    var focusModesArray: [TGFocusMode] {
        let set = focusModes as? Set<TGFocusMode> ?? []
        return Array(set)
    }

    // MARK: - Convenience Initializer

    convenience init(
        context: NSManagedObjectContext,
        name: String,
        emoji: String? = nil,
        color: String? = nil
    ) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.color = color
        self.isActive = true
        self.sortOrder = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    func archive() {
        isActive = false
        updatedAt = Date()
    }

    func unarchive() {
        isActive = true
        updatedAt = Date()
    }

    func updateTimestamp() {
        updatedAt = Date()
    }
}

// MARK: - TGGoal Extension

extension TGGoal {
    var projectsArray: [TGProject] {
        let set = projects as? Set<TGProject> ?? []
        return Array(set)
    }

    var tasksArray: [TGTask] {
        let set = tasks as? Set<TGTask> ?? []
        return set.sorted { ($0.sortOrder) < ($1.sortOrder) }
    }

    var completedTasks: [TGTask] {
        tasksArray.filter { $0.isCompleted }
    }

    var completionPercentage: Double {
        guard !tasksArray.isEmpty else { return 0 }
        return Double(completedTasks.count) / Double(tasksArray.count)
    }

    convenience init(
        context: NSManagedObjectContext,
        name: String,
        description: String? = nil,
        targetDate: Date? = nil
    ) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.goalDescription = description
        self.targetDate = targetDate
        self.isActive = true
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func updateTimestamp() {
        updatedAt = Date()
    }
}

// MARK: - TGTag Extension

extension TGTag {
    var tasksArray: [TGTask] {
        let set = tasks as? Set<TGTask> ?? []
        return set.sorted { ($0.sortOrder) < ($1.sortOrder) }
    }

    convenience init(
        context: NSManagedObjectContext,
        name: String,
        color: String? = nil
    ) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.color = color
        self.sortOrder = 0
    }
}
