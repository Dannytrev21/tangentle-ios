import Foundation

// MARK: - Task Status

enum TaskStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case done = "done"
    case waitingFor = "waiting_for"
    case deferred = "deferred"
    case delegated = "delegated"
    case deleted = "deleted"

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .done: return "Done"
        case .waitingFor: return "Waiting For"
        case .deferred: return "Deferred"
        case .delegated: return "Delegated"
        case .deleted: return "Deleted"
        }
    }

    var isCompleted: Bool {
        self == .done
    }

    var isActive: Bool {
        self == .pending || self == .inProgress
    }
}

// MARK: - Priority

enum Priority: Int16, Codable, CaseIterable {
    case none = 0
    case low = 1
    case mediumLow = 2
    case medium = 3
    case mediumHigh = 4
    case high = 5

    var displayName: String {
        switch self {
        case .none: return "None"
        case .low: return "Low"
        case .mediumLow, .medium: return "Medium"
        case .mediumHigh, .high: return "High"
        }
    }
}

// MARK: - Energy Level

enum EnergyLevel: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"

    var displayName: String { rawValue.capitalized }
}

// MARK: - Strategy Outcome Result

enum OutcomeResult: String, Codable, CaseIterable {
    case success = "success"
    case partial = "partial"
    case failure = "failure"

    var scoreValue: Int {
        switch self {
        case .success: return 3
        case .partial: return 1
        case .failure: return -1
        }
    }
}

// MARK: - Habit Frequency

enum HabitFrequency: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case custom = "custom"
}

// MARK: - Routine Type

enum RoutineType: String, Codable, CaseIterable {
    case morning = "morning"
    case evening = "evening"
    case custom = "custom"
}

// MARK: - Days of Week

enum DayOfWeek: Int, Codable, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }

    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}
