import Foundation
@testable import Tangentle

// MARK: - Mock Task Service

final class MockTaskService: MockSpy, TaskServiceProtocol {
    var calls: [MethodCall] = []

    // Configurable results
    var getTodaysTasksResult: Result<[TGTask], Error> = .success([])
    var getOverdueTasksResult: Result<[TGTask], Error> = .success([])
    var getUpcomingTasksResult: Result<[TGTask], Error> = .success([])
    var createTaskResult: TGTask?
    var updateTaskError: Error?
    var completeTaskError: Error?
    var deleteTaskError: Error?
    var addSubtaskResult: TGTask?
    var reorderTasksError: Error?

    private func recordCall(_ name: String, arguments: [String: Any] = [:]) {
        calls.append(MethodCall(name: name, arguments: arguments))
    }

    func getTodaysTasks() async throws -> [TGTask] {
        recordCall("getTodaysTasks")
        return try getTodaysTasksResult.get()
    }

    func getOverdueTasks() async throws -> [TGTask] {
        recordCall("getOverdueTasks")
        return try getOverdueTasksResult.get()
    }

    func getUpcomingTasks(days: Int) async throws -> [TGTask] {
        recordCall("getUpcomingTasks", arguments: ["days": days])
        return try getUpcomingTasksResult.get()
    }

    func createTask(
        title: String,
        project: TGProject?,
        priority: Priority,
        estimatedDuration: Int16,
        dueDate: Date?,
        scheduledDate: Date?
    ) async throws -> TGTask {
        recordCall("createTask", arguments: [
            "title": title,
            "priority": priority.rawValue,
            "duration": estimatedDuration
        ])
        guard let result = createTaskResult else {
            fatalError("MockTaskService.createTask() - configure createTaskResult")
        }
        return result
    }

    func updateTask(_ task: TGTask, with changes: TaskChanges) async throws {
        recordCall("updateTask", arguments: ["taskId": task.id as Any])
        if let error = updateTaskError { throw error }
    }

    func completeTask(_ task: TGTask) async throws {
        recordCall("completeTask", arguments: ["taskId": task.id as Any])
        if let error = completeTaskError { throw error }
    }

    func deleteTask(_ task: TGTask) async throws {
        recordCall("deleteTask", arguments: ["taskId": task.id as Any])
        if let error = deleteTaskError { throw error }
    }

    func addSubtask(to parent: TGTask, title: String) async throws -> TGTask {
        recordCall("addSubtask", arguments: ["parentId": parent.id as Any, "title": title])
        guard let result = addSubtaskResult else {
            fatalError("MockTaskService.addSubtask() - configure addSubtaskResult")
        }
        return result
    }

    func reorderTasks(_ tasks: [TGTask]) async throws {
        recordCall("reorderTasks", arguments: ["count": tasks.count])
        if let error = reorderTasksError { throw error }
    }
}

// MARK: - Mock Strategy Service

final class MockStrategyService: MockSpy, StrategyServiceProtocol {
    var calls: [MethodCall] = []

    var getStrategiesForProblemResult: Result<[TGStrategy], Error> = .success([])
    var getTopStrategiesResult: Result<[TGStrategy], Error> = .success([])
    var recordOutcomeError: Error?
    var calculateScoreResult: Double = 0.5

    private func recordCall(_ name: String, arguments: [String: Any] = [:]) {
        calls.append(MethodCall(name: name, arguments: arguments))
    }

    func getStrategiesForProblem(_ problemType: String) async throws -> [TGStrategy] {
        recordCall("getStrategiesForProblem", arguments: ["problemType": problemType])
        return try getStrategiesForProblemResult.get()
    }

    func getTopStrategies(limit: Int) async throws -> [TGStrategy] {
        recordCall("getTopStrategies", arguments: ["limit": limit])
        return try getTopStrategiesResult.get()
    }

    func recordOutcome(
        strategy: TGStrategy,
        result: OutcomeResult,
        problemType: String,
        taskTitle: String,
        notes: String?
    ) async throws {
        recordCall("recordOutcome", arguments: [
            "strategyId": strategy.id as Any,
            "result": result.rawValue,
            "problemType": problemType,
            "taskTitle": taskTitle
        ])
        if let error = recordOutcomeError { throw error }
    }

    func calculateScore(for strategy: TGStrategy) -> Double {
        recordCall("calculateScore", arguments: ["strategyId": strategy.id as Any])
        return calculateScoreResult
    }
}

// MARK: - Mock Schedule Service

final class MockScheduleService: MockSpy, ScheduleServiceProtocol {
    var calls: [MethodCall] = []

    var getScheduleForDateResult: DaySchedule?
    var suggestTimeSlotResult: Date?
    var rescheduleTaskError: Error?
    var getAvailableSlotsResult: [TimeSlot] = []

    private func recordCall(_ name: String, arguments: [String: Any] = [:]) {
        calls.append(MethodCall(name: name, arguments: arguments))
    }

    func getScheduleForDate(_ date: Date) async throws -> DaySchedule {
        recordCall("getScheduleForDate", arguments: ["date": date])
        return getScheduleForDateResult ?? DaySchedule(date: date, tasks: [])
    }

    func suggestTimeSlot(for task: TGTask) async throws -> Date? {
        recordCall("suggestTimeSlot", arguments: ["taskId": task.id as Any])
        return suggestTimeSlotResult
    }

    func rescheduleTask(_ task: TGTask, to date: Date) async throws {
        recordCall("rescheduleTask", arguments: ["taskId": task.id as Any, "date": date])
        if let error = rescheduleTaskError { throw error }
    }

    func getAvailableSlots(for date: Date) async throws -> [TimeSlot] {
        recordCall("getAvailableSlots", arguments: ["date": date])
        return getAvailableSlotsResult
    }
}

// MARK: - Mock Settings Service

final class MockSettingsService: MockSpy, SettingsServiceProtocol {
    var calls: [MethodCall] = []

    var getSettingsResult: TGSettings?
    var getScheduleSettingsResult: ScheduleSettings?
    var getTaskSettingsResult: TaskSettings?
    var updateError: Error?

    private func recordCall(_ name: String, arguments: [String: Any] = [:]) {
        calls.append(MethodCall(name: name, arguments: arguments))
    }

    func getSettings() async throws -> TGSettings {
        recordCall("getSettings")
        guard let result = getSettingsResult else {
            fatalError("MockSettingsService.getSettings() - configure getSettingsResult")
        }
        return result
    }

    func getScheduleSettings() async throws -> ScheduleSettings {
        recordCall("getScheduleSettings")
        return getScheduleSettingsResult ?? .default
    }

    func getTaskSettings() async throws -> TaskSettings {
        recordCall("getTaskSettings")
        return getTaskSettingsResult ?? .default
    }

    func updateScheduleSettings(_ settings: ScheduleSettings) async throws {
        recordCall("updateScheduleSettings")
        if let error = updateError { throw error }
    }

    func updateTaskSettings(_ settings: TaskSettings) async throws {
        recordCall("updateTaskSettings")
        if let error = updateError { throw error }
    }

    func updateDisplaySettings(_ settings: DisplaySettings) async throws {
        recordCall("updateDisplaySettings")
        if let error = updateError { throw error }
    }

    func updateCoachingSettings(_ settings: CoachingSettings) async throws {
        recordCall("updateCoachingSettings")
        if let error = updateError { throw error }
    }
}

// MARK: - Extended Mock AI Service

/// Extended MockAIService with call tracking (extends the one in TestContainer)
final class MockAIServiceWithSpy: MockSpy, AIServiceProtocol {
    var calls: [MethodCall] = []

    var mockCoachingAdvice: String = "Mock coaching advice"
    var mockCoachingResponse: CoachingResponse?
    var mockPrioritizedTasks: [TGTask]?
    var mockScheduledTasks: [TGTask]?
    var mockScheduleResponse: ScheduleResponse?
    var shouldThrow = false
    var throwError: Error = MockError.intentional

    private func recordCall(_ name: String, arguments: [String: Any] = [:]) {
        calls.append(MethodCall(name: name, arguments: arguments))
    }

    func getCoachingAdvice(for problemType: String, context: AIContext) async throws -> String {
        recordCall("getCoachingAdvice", arguments: ["problemType": problemType])
        if shouldThrow { throw throwError }
        return "\(mockCoachingAdvice) for \(problemType)"
    }

    func getCoachingResponse(for problemType: String, context: AIContext) async throws -> CoachingResponse {
        recordCall("getCoachingResponse", arguments: ["problemType": problemType])
        if shouldThrow { throw throwError }
        if let response = mockCoachingResponse {
            return response
        }
        let advice = try await getCoachingAdvice(for: problemType, context: context)
        return CoachingResponse(
            advice: advice,
            suggestedStrategies: ["Mock Strategy 1", "Mock Strategy 2"],
            followUpQuestions: ["What's blocking you?"]
        )
    }

    func prioritizeTasks(_ tasks: [TGTask]) async throws -> [TGTask] {
        recordCall("prioritizeTasks", arguments: ["taskCount": tasks.count])
        if shouldThrow { throw throwError }
        return mockPrioritizedTasks ?? tasks
    }

    func suggestSchedule(for tasks: [TGTask], settings: ScheduleSettings) async throws -> [TGTask] {
        recordCall("suggestSchedule", arguments: ["taskCount": tasks.count])
        if shouldThrow { throw throwError }
        return mockScheduledTasks ?? tasks
    }

    func generateSchedule(request: ScheduleRequest) async throws -> ScheduleResponse {
        recordCall("generateSchedule", arguments: ["taskCount": request.tasks.count])
        if shouldThrow { throw throwError }
        if let response = mockScheduleResponse {
            return response
        }
        return ScheduleResponse(scheduledTasks: [])
    }
}

// MARK: - Mock Seed Data Service

/// Mock for SeedDataService (note: SeedDataService is a class, not a protocol)
final class MockSeedDataService: MockSpy {
    var calls: [MethodCall] = []

    var seedIfNeededError: Error?
    var hasSeeded = false

    private func recordCall(_ name: String, arguments: [String: Any] = [:]) {
        calls.append(MethodCall(name: name, arguments: arguments))
    }

    func seedIfNeeded() async throws {
        recordCall("seedIfNeeded")
        if let error = seedIfNeededError { throw error }
        hasSeeded = true
    }
}
