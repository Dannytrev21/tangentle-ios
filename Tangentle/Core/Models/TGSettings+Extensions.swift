import Foundation
import CoreData

// MARK: - Settings Codable Structures

struct ScheduleSettings: Codable, Equatable {
    var workHoursStart: String = "09:00"
    var workHoursEnd: String = "17:00"
    var peakFocusStart: String = "09:00"
    var peakFocusEnd: String = "12:00"
    var lowEnergyStart: String = "14:00"
    var lowEnergyEnd: String = "16:00"
    var weekendWorkEnabled: Bool = false

    static var `default`: ScheduleSettings { ScheduleSettings() }
}

struct TaskSettings: Codable, Equatable {
    var defaultDuration: Int = 30
    var maxDuration: Int = 120
    var timeEstimateBuffer: Double = 1.5
    var breakAfterMinutes: Int = 90
    var shortBreakDuration: Int = 5
    var longBreakDuration: Int = 15

    static var `default`: TaskSettings { TaskSettings() }

    /// Apply ADHD time buffer to duration estimate
    func estimateWithBuffer(_ minutes: Int) -> Int {
        if minutes <= 5 { return 15 }           // 3x for tiny tasks
        if minutes <= 30 { return Int(Double(minutes) * 1.5) }  // 1.5x
        return minutes * 2                       // 2x for longer tasks
    }
}

struct DisplaySettings: Codable, Equatable {
    var theme: String = "system"
    var compactMode: Bool = false
    var showCompletedTasks: Bool = true
    var showSubtasks: Bool = true
    var hapticFeedbackEnabled: Bool = true
    /// Haptic intensity: "off", "selective", "rich". Default is "selective".
    var hapticIntensity: String = "selective"

    static var `default`: DisplaySettings { DisplaySettings() }
}

struct CoachingSettings: Codable, Equatable {
    var enabled: Bool = true
    var maxTurns: Int = 10
    var autoSuggestStrategies: Bool = true
    var showMotivationalMessages: Bool = true

    static var `default`: CoachingSettings { CoachingSettings() }
}

// MARK: - TGSettings Extension

extension TGSettings {
    var schedule: ScheduleSettings {
        get {
            guard let data = scheduleSettings else { return .default }
            return (try? JSONDecoder().decode(ScheduleSettings.self, from: data)) ?? .default
        }
        set {
            scheduleSettings = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    var tasks: TaskSettings {
        get {
            guard let data = taskSettings else { return .default }
            return (try? JSONDecoder().decode(TaskSettings.self, from: data)) ?? .default
        }
        set {
            taskSettings = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    var display: DisplaySettings {
        get {
            guard let data = displaySettings else { return .default }
            return (try? JSONDecoder().decode(DisplaySettings.self, from: data)) ?? .default
        }
        set {
            displaySettings = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    var coaching: CoachingSettings {
        get {
            guard let data = coachingSettings else { return .default }
            return (try? JSONDecoder().decode(CoachingSettings.self, from: data)) ?? .default
        }
        set {
            coachingSettings = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    // MARK: - Core Data Lifecycle

    /// Called automatically when a new TGSettings entity is created.
    /// Sets up default values for the singleton settings object.
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.id = UUID()
        self.scheduleSettings = try? JSONEncoder().encode(ScheduleSettings.default)
        self.taskSettings = try? JSONEncoder().encode(TaskSettings.default)
        self.displaySettings = try? JSONEncoder().encode(DisplaySettings.default)
        self.coachingSettings = try? JSONEncoder().encode(CoachingSettings.default)
        self.updatedAt = Date()
    }

    // MARK: - Static Methods

    static func getOrCreate(in context: NSManagedObjectContext) -> TGSettings {
        let request: NSFetchRequest<TGSettings> = TGSettings.fetchRequest()
        request.fetchLimit = 1

        if let existing = try? context.fetch(request).first {
            return existing
        }

        return TGSettings(context: context)
    }
}
