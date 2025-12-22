import Foundation

// MARK: - Task Service Protocol

/// Task management service protocol
protocol TaskServiceProtocol {
    func getTodaysTasks() async throws -> [TGTask]
    func getOverdueTasks() async throws -> [TGTask]
    func getUpcomingTasks(days: Int) async throws -> [TGTask]

    func createTask(
        title: String,
        project: TGProject?,
        priority: Priority,
        estimatedDuration: Int16,
        dueDate: Date?,
        scheduledDate: Date?
    ) async throws -> TGTask

    func updateTask(_ task: TGTask, with changes: TaskChanges) async throws
    func completeTask(_ task: TGTask) async throws
    func deleteTask(_ task: TGTask) async throws

    func addSubtask(to parent: TGTask, title: String) async throws -> TGTask
    func reorderTasks(_ tasks: [TGTask]) async throws
}

/// Encapsulates optional changes to apply to a task
struct TaskChanges {
    var title: String?
    var taskDescription: String?
    var status: TaskStatus?
    var priority: Priority?
    var estimatedDuration: Int16?
    var dueDate: Date?
    var scheduledDate: Date?
    var project: TGProject?

    init(
        title: String? = nil,
        taskDescription: String? = nil,
        status: TaskStatus? = nil,
        priority: Priority? = nil,
        estimatedDuration: Int16? = nil,
        dueDate: Date? = nil,
        scheduledDate: Date? = nil,
        project: TGProject? = nil
    ) {
        self.title = title
        self.taskDescription = taskDescription
        self.status = status
        self.priority = priority
        self.estimatedDuration = estimatedDuration
        self.dueDate = dueDate
        self.scheduledDate = scheduledDate
        self.project = project
    }
}

// MARK: - Strategy Service Protocol

/// Strategy coaching service protocol
protocol StrategyServiceProtocol {
    func getStrategiesForProblem(_ problemType: String) async throws -> [TGStrategy]
    func getTopStrategies(limit: Int) async throws -> [TGStrategy]
    func recordOutcome(
        strategy: TGStrategy,
        result: OutcomeResult,
        problemType: String,
        taskTitle: String,
        notes: String?
    ) async throws
    func calculateScore(for strategy: TGStrategy) -> Double
}

// MARK: - Schedule Service Protocol

/// Schedule management service protocol
protocol ScheduleServiceProtocol {
    func getScheduleForDate(_ date: Date) async throws -> DaySchedule
    func suggestTimeSlot(for task: TGTask) async throws -> Date?
    func rescheduleTask(_ task: TGTask, to date: Date) async throws
    func getAvailableSlots(for date: Date) async throws -> [TimeSlot]
}

/// Represents a day's schedule with tasks and focus mode
struct DaySchedule {
    let date: Date
    let tasks: [TGTask]
    let focusMode: TGFocusMode?

    init(date: Date, tasks: [TGTask], focusMode: TGFocusMode? = nil) {
        self.date = date
        self.tasks = tasks
        self.focusMode = focusMode
    }
}

/// Represents a time slot for scheduling
struct TimeSlot {
    let start: Date
    let end: Date
    let isAvailable: Bool

    init(start: Date, end: Date, isAvailable: Bool = true) {
        self.start = start
        self.end = end
        self.isAvailable = isAvailable
    }
}

// MARK: - Settings Service Protocol

/// Settings management service protocol
protocol SettingsServiceProtocol {
    func getSettings() async throws -> TGSettings
    func getScheduleSettings() async throws -> ScheduleSettings
    func getTaskSettings() async throws -> TaskSettings
    func updateScheduleSettings(_ settings: ScheduleSettings) async throws
    func updateTaskSettings(_ settings: TaskSettings) async throws
    func updateDisplaySettings(_ settings: DisplaySettings) async throws
    func updateCoachingSettings(_ settings: CoachingSettings) async throws
}

// MARK: - AI Service Protocol

/// Context for AI coaching requests
struct AIContext {
    let problemType: String
    let taskTitle: String?
    let taskDescription: String?
    let taskDuration: Int?
    let projectName: String?
    let energyLevel: EnergyLevel?
    let pastStrategies: [StrategyContext]
    let userPreferences: UserPreferences

    /// Historical context about a strategy
    struct StrategyContext {
        let name: String
        let score: Double
        let lastUsed: Date?
        let successCount: Int
        let failureCount: Int

        init(name: String, score: Double, lastUsed: Date? = nil, successCount: Int = 0, failureCount: Int = 0) {
            self.name = name
            self.score = score
            self.lastUsed = lastUsed
            self.successCount = successCount
            self.failureCount = failureCount
        }
    }

    /// User preferences relevant to coaching
    struct UserPreferences {
        let preferredDuration: Int
        let peakFocusStart: String
        let peakFocusEnd: String

        init(preferredDuration: Int = 25, peakFocusStart: String = "09:00", peakFocusEnd: String = "12:00") {
            self.preferredDuration = preferredDuration
            self.peakFocusStart = peakFocusStart
            self.peakFocusEnd = peakFocusEnd
        }
    }

    init(
        problemType: String = "",
        taskTitle: String? = nil,
        taskDescription: String? = nil,
        taskDuration: Int? = nil,
        projectName: String? = nil,
        energyLevel: EnergyLevel? = nil,
        pastStrategies: [StrategyContext] = [],
        userPreferences: UserPreferences = UserPreferences()
    ) {
        self.problemType = problemType
        self.taskTitle = taskTitle
        self.taskDescription = taskDescription
        self.taskDuration = taskDuration
        self.projectName = projectName
        self.energyLevel = energyLevel
        self.pastStrategies = pastStrategies
        self.userPreferences = userPreferences
    }
}

/// Request for AI scheduling
struct ScheduleRequest {
    let tasks: [TaskInfo]
    let date: Date
    let settings: ScheduleSettings

    /// Simplified task info for scheduling requests
    struct TaskInfo {
        let id: UUID
        let title: String
        let priority: Int
        let estimatedDuration: Int
        let energyRequired: String
        let dueDate: Date?

        init(id: UUID, title: String, priority: Int, estimatedDuration: Int, energyRequired: String = "medium", dueDate: Date? = nil) {
            self.id = id
            self.title = title
            self.priority = priority
            self.estimatedDuration = estimatedDuration
            self.energyRequired = energyRequired
            self.dueDate = dueDate
        }
    }

    init(tasks: [TaskInfo], date: Date = Date(), settings: ScheduleSettings) {
        self.tasks = tasks
        self.date = date
        self.settings = settings
    }
}

/// Response from AI scheduling
struct ScheduleResponse {
    let scheduledTasks: [ScheduledTask]

    /// A task with its scheduled time and reasoning
    struct ScheduledTask {
        let taskId: UUID
        let scheduledTime: Date
        let reason: String?

        init(taskId: UUID, scheduledTime: Date, reason: String? = nil) {
            self.taskId = taskId
            self.scheduledTime = scheduledTime
            self.reason = reason
        }
    }

    init(scheduledTasks: [ScheduledTask] = []) {
        self.scheduledTasks = scheduledTasks
    }
}

/// Coaching response from AI
struct CoachingResponse {
    let advice: String
    let suggestedStrategies: [String]
    let followUpQuestions: [String]?

    init(advice: String, suggestedStrategies: [String] = [], followUpQuestions: [String]? = nil) {
        self.advice = advice
        self.suggestedStrategies = suggestedStrategies
        self.followUpQuestions = followUpQuestions
    }
}

/// AI service protocol for coaching and scheduling
protocol AIServiceProtocol {
    /// Get coaching advice for a problem type
    func getCoachingAdvice(for problemType: String, context: AIContext) async throws -> String

    /// Get full coaching response with strategies
    func getCoachingResponse(for problemType: String, context: AIContext) async throws -> CoachingResponse

    /// Prioritize tasks using AI
    func prioritizeTasks(_ tasks: [TGTask]) async throws -> [TGTask]

    /// Suggest schedule for tasks
    func suggestSchedule(for tasks: [TGTask], settings: ScheduleSettings) async throws -> [TGTask]

    /// Get schedule with reasoning
    func generateSchedule(request: ScheduleRequest) async throws -> ScheduleResponse
}

// MARK: - Default Implementations

extension AIServiceProtocol {
    func getCoachingResponse(for problemType: String, context: AIContext) async throws -> CoachingResponse {
        let advice = try await getCoachingAdvice(for: problemType, context: context)
        return CoachingResponse(
            advice: advice,
            suggestedStrategies: [],
            followUpQuestions: nil
        )
    }

    func generateSchedule(request: ScheduleRequest) async throws -> ScheduleResponse {
        // Default: return empty schedule
        return ScheduleResponse(scheduledTasks: [])
    }
}

// MARK: - AI Service Errors

enum AIServiceError: LocalizedError {
    case noAPIKey
    case networkError(underlying: Error)
    case invalidResponse
    case rateLimited
    case serviceUnavailable

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key not configured"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .rateLimited:
            return "Rate limited - please try again later"
        case .serviceUnavailable:
            return "AI service temporarily unavailable"
        }
    }
}
