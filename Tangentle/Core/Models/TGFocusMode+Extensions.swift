import Foundation
import CoreData

extension TGFocusMode {
    // MARK: - Computed Properties

    var daysOfWeekArray: [DayOfWeek] {
        get {
            let intArray = daysOfWeek ?? []
            return intArray.compactMap { DayOfWeek(rawValue: $0) }
        }
        set {
            daysOfWeek = newValue.map { $0.rawValue }
        }
    }

    var filterTagsArray: [String] {
        get { filterTags ?? [] }
        set { filterTags = newValue }
    }

    var includedProjectsArray: [TGProject] {
        let set = includedProjects as? Set<TGProject> ?? []
        return set.sorted { ($0.sortOrder) < ($1.sortOrder) }
    }

    var tasksArray: [TGTask] {
        let set = tasks as? Set<TGTask> ?? []
        return set.sorted { ($0.sortOrder) < ($1.sortOrder) }
    }

    var isActiveNow: Bool {
        guard isActive else { return false }
        guard isAutomatic else { return true }

        let now = Date()
        let calendar = Calendar.current

        // Check day of week
        let todayWeekday = calendar.component(.weekday, from: now)
        guard daysOfWeekArray.contains(where: { $0.rawValue == todayWeekday }) else {
            return false
        }

        // Check time window if set
        guard let start = startTime, let end = endTime else { return true }

        let startComponents = calendar.dateComponents([.hour, .minute], from: start)
        let endComponents = calendar.dateComponents([.hour, .minute], from: end)
        let nowComponents = calendar.dateComponents([.hour, .minute], from: now)

        guard let startMinutes = startComponents.hour.map({ $0 * 60 + (startComponents.minute ?? 0) }),
              let endMinutes = endComponents.hour.map({ $0 * 60 + (endComponents.minute ?? 0) }),
              let nowMinutes = nowComponents.hour.map({ $0 * 60 + (nowComponents.minute ?? 0) }) else {
            return true
        }

        return nowMinutes >= startMinutes && nowMinutes <= endMinutes
    }

    // MARK: - Convenience Initializer

    convenience init(
        context: NSManagedObjectContext,
        name: String,
        description: String? = nil,
        isAutomatic: Bool = false
    ) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.focusModeDescription = description
        self.isAutomatic = isAutomatic
        self.isActive = true
        self.sortOrder = 0
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Methods

    func setSchedule(startTime: Date, endTime: Date, daysOfWeek: [DayOfWeek]) {
        self.startTime = startTime
        self.endTime = endTime
        self.daysOfWeekArray = daysOfWeek
        self.isAutomatic = true
        updateTimestamp()
    }

    func addProject(_ project: TGProject) {
        mutableSetValue(forKey: "includedProjects").add(project)
        updateTimestamp()
    }

    func removeProject(_ project: TGProject) {
        mutableSetValue(forKey: "includedProjects").remove(project)
        updateTimestamp()
    }

    func updateTimestamp() {
        updatedAt = Date()
    }
}

// MARK: - TGMode Extension

extension TGMode {
    var settingsData: [String: Any]? {
        guard let data = settings else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    convenience init(
        context: NSManagedObjectContext,
        name: String,
        description: String? = nil,
        settings: [String: Any] = [:],
        isDefault: Bool = false
    ) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.modeDescription = description
        self.settings = try? JSONSerialization.data(withJSONObject: settings)
        self.isDefault = isDefault
        self.isShared = false
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    func updateTimestamp() {
        updatedAt = Date()
    }
}

// MARK: - TGProblemType Extension

extension TGProblemType {
    var suggestedStrategyIdsArray: [UUID] {
        get { suggestedStrategyIds ?? [] }
        set { suggestedStrategyIds = newValue }
    }

    convenience init(
        context: NSManagedObjectContext,
        identifier: String,
        label: String,
        description: String,
        isDefault: Bool = false
    ) {
        self.init(context: context)
        self.id = UUID()
        self.identifier = identifier
        self.label = label
        self.problemTypeDescription = description
        self.isDefault = isDefault
        self.sortOrder = 0
    }
}
