import Testing
import Foundation
@testable import Tangentle

/// Contract tests for AI service request/response shapes.
/// These tests validate that data structures match expected API contracts
/// without making actual network calls.
///
/// When real API integration is added, these contracts ensure:
/// - Request shapes match what the API expects
/// - Response parsing handles all expected fields
/// - Edge cases (empty, null, malformed) are handled gracefully
@Suite("AI Service Contract Tests")
struct AIServiceContractTests {

    // MARK: - AIContext Contract Tests

    @Suite("AIContext Contracts")
    struct AIContextContractTests {

        @Test("AIContext can be created with minimal data")
        func aiContext_minimalCreation() {
            let context = AIContext()

            #expect(context.problemType.isEmpty)
            #expect(context.taskTitle == nil)
            #expect(context.taskDescription == nil)
            #expect(context.taskDuration == nil)
            #expect(context.projectName == nil)
            #expect(context.energyLevel == nil)
            #expect(context.pastStrategies.isEmpty)
        }

        @Test("AIContext can be created with all fields")
        func aiContext_fullCreation() {
            let strategies = [
                AIContext.StrategyContext(
                    name: "2-Minute Version",
                    score: 0.85,
                    lastUsed: Date(),
                    successCount: 10,
                    failureCount: 2
                )
            ]

            let context = AIContext(
                problemType: "too_big",
                taskTitle: "Complete quarterly report",
                taskDescription: "Analyze Q4 metrics and write summary",
                taskDuration: 120,
                projectName: "Reports",
                energyLevel: .high,
                pastStrategies: strategies,
                userPreferences: AIContext.UserPreferences(
                    preferredDuration: 25,
                    peakFocusStart: "09:00",
                    peakFocusEnd: "12:00"
                )
            )

            #expect(context.problemType == "too_big")
            #expect(context.taskTitle == "Complete quarterly report")
            #expect(context.taskDescription == "Analyze Q4 metrics and write summary")
            #expect(context.taskDuration == 120)
            #expect(context.projectName == "Reports")
            #expect(context.energyLevel == .high)
            #expect(context.pastStrategies.count == 1)
            #expect(context.userPreferences.preferredDuration == 25)
        }

        @Test("StrategyContext requires name and score")
        func strategyContext_requiredFields() {
            let context = AIContext.StrategyContext(name: "Test", score: 0.5)

            #expect(context.name == "Test")
            #expect(context.score == 0.5)
            #expect(context.lastUsed == nil)
            #expect(context.successCount == 0)
            #expect(context.failureCount == 0)
        }

        @Test("StrategyContext handles full statistics")
        func strategyContext_fullStatistics() {
            let lastUsed = Date()
            let context = AIContext.StrategyContext(
                name: "Break It Down",
                score: 0.75,
                lastUsed: lastUsed,
                successCount: 15,
                failureCount: 5
            )

            #expect(context.name == "Break It Down")
            #expect(context.score == 0.75)
            #expect(context.lastUsed == lastUsed)
            #expect(context.successCount == 15)
            #expect(context.failureCount == 5)
        }

        @Test("UserPreferences has sensible defaults")
        func userPreferences_defaults() {
            let prefs = AIContext.UserPreferences()

            #expect(prefs.preferredDuration == 25)
            #expect(prefs.peakFocusStart == "09:00")
            #expect(prefs.peakFocusEnd == "12:00")
        }

        @Test("AIContext problemType accepts all known types")
        func aiContext_knownProblemTypes() {
            let knownTypes = [
                "too_big",
                "unclear",
                "boring",
                "scary",
                "blocked",
                "distracted",
                "low_energy",
                "overwhelmed",
                "forgot",
                "interruptions"
            ]

            for problemType in knownTypes {
                let context = AIContext(problemType: problemType)
                #expect(context.problemType == problemType)
            }
        }
    }

    // MARK: - CoachingResponse Contract Tests

    @Suite("CoachingResponse Contracts")
    struct CoachingResponseContractTests {

        @Test("CoachingResponse can be created with advice only")
        func coachingResponse_adviceOnly() {
            let response = CoachingResponse(advice: "Start small")

            #expect(response.advice == "Start small")
            #expect(response.suggestedStrategies.isEmpty)
            #expect(response.followUpQuestions == nil)
        }

        @Test("CoachingResponse can be created with all fields")
        func coachingResponse_allFields() {
            let response = CoachingResponse(
                advice: "Try breaking this down into smaller steps",
                suggestedStrategies: ["2-Minute Version", "First Step Only"],
                followUpQuestions: ["What's the smallest piece?", "What's blocking you?"]
            )

            #expect(response.advice.isEmpty == false)
            #expect(response.suggestedStrategies.count == 2)
            #expect(response.followUpQuestions?.count == 2)
        }

        @Test("CoachingResponse handles empty strategies")
        func coachingResponse_emptyStrategies() {
            let response = CoachingResponse(
                advice: "Test advice",
                suggestedStrategies: []
            )

            #expect(response.suggestedStrategies.isEmpty)
        }

        @Test("CoachingResponse handles empty follow-up questions")
        func coachingResponse_emptyFollowUp() {
            let response = CoachingResponse(
                advice: "Test advice",
                suggestedStrategies: [],
                followUpQuestions: []
            )

            #expect(response.followUpQuestions?.isEmpty == true)
        }
    }

    // MARK: - ScheduleRequest Contract Tests

    @Suite("ScheduleRequest Contracts")
    struct ScheduleRequestContractTests {

        @Test("ScheduleRequest can be created with empty tasks")
        func scheduleRequest_emptyTasks() {
            let request = ScheduleRequest(
                tasks: [],
                date: Date(),
                settings: .default
            )

            #expect(request.tasks.isEmpty)
        }

        @Test("ScheduleRequest TaskInfo requires essential fields")
        func taskInfo_requiredFields() {
            let taskInfo = ScheduleRequest.TaskInfo(
                id: UUID(),
                title: "Test Task",
                priority: 3,
                estimatedDuration: 30
            )

            #expect(taskInfo.title == "Test Task")
            #expect(taskInfo.priority == 3)
            #expect(taskInfo.estimatedDuration == 30)
            #expect(taskInfo.energyRequired == "medium")
            #expect(taskInfo.dueDate == nil)
        }

        @Test("ScheduleRequest TaskInfo handles all fields")
        func taskInfo_allFields() {
            let dueDate = Date()
            let taskInfo = ScheduleRequest.TaskInfo(
                id: UUID(),
                title: "Important Task",
                priority: 5,
                estimatedDuration: 60,
                energyRequired: "high",
                dueDate: dueDate
            )

            #expect(taskInfo.title == "Important Task")
            #expect(taskInfo.priority == 5)
            #expect(taskInfo.estimatedDuration == 60)
            #expect(taskInfo.energyRequired == "high")
            #expect(taskInfo.dueDate == dueDate)
        }

        @Test("ScheduleRequest preserves task order")
        func scheduleRequest_preservesOrder() {
            let tasks = [
                ScheduleRequest.TaskInfo(id: UUID(), title: "First", priority: 1, estimatedDuration: 15),
                ScheduleRequest.TaskInfo(id: UUID(), title: "Second", priority: 2, estimatedDuration: 30),
                ScheduleRequest.TaskInfo(id: UUID(), title: "Third", priority: 3, estimatedDuration: 45)
            ]

            let request = ScheduleRequest(
                tasks: tasks,
                date: Date(),
                settings: .default
            )

            #expect(request.tasks[0].title == "First")
            #expect(request.tasks[1].title == "Second")
            #expect(request.tasks[2].title == "Third")
        }

        @Test("ScheduleRequest priority range is 0-5")
        func scheduleRequest_priorityRange() {
            for priority in 0...5 {
                let taskInfo = ScheduleRequest.TaskInfo(
                    id: UUID(),
                    title: "P\(priority) Task",
                    priority: priority,
                    estimatedDuration: 15
                )
                #expect(taskInfo.priority == priority)
            }
        }

        @Test("ScheduleRequest energy values are valid")
        func scheduleRequest_energyValues() {
            let validEnergies = ["low", "medium", "high"]

            for energy in validEnergies {
                let taskInfo = ScheduleRequest.TaskInfo(
                    id: UUID(),
                    title: "Test",
                    priority: 3,
                    estimatedDuration: 15,
                    energyRequired: energy
                )
                #expect(taskInfo.energyRequired == energy)
            }
        }
    }

    // MARK: - ScheduleResponse Contract Tests

    @Suite("ScheduleResponse Contracts")
    struct ScheduleResponseContractTests {

        @Test("ScheduleResponse can be created empty")
        func scheduleResponse_empty() {
            let response = ScheduleResponse()

            #expect(response.scheduledTasks.isEmpty)
        }

        @Test("ScheduleResponse can contain scheduled tasks")
        func scheduleResponse_withTasks() {
            let taskId = UUID()
            let scheduledTime = Date()

            let response = ScheduleResponse(scheduledTasks: [
                ScheduleResponse.ScheduledTask(
                    taskId: taskId,
                    scheduledTime: scheduledTime,
                    reason: "Peak focus time"
                )
            ])

            #expect(response.scheduledTasks.count == 1)
            #expect(response.scheduledTasks[0].taskId == taskId)
            #expect(response.scheduledTasks[0].scheduledTime == scheduledTime)
            #expect(response.scheduledTasks[0].reason == "Peak focus time")
        }

        @Test("ScheduledTask can have nil reason")
        func scheduledTask_nilReason() {
            let task = ScheduleResponse.ScheduledTask(
                taskId: UUID(),
                scheduledTime: Date(),
                reason: nil
            )

            #expect(task.reason == nil)
        }

        @Test("ScheduledTask preserves UUID identity")
        func scheduledTask_preservesUUID() {
            let originalId = UUID()
            let task = ScheduleResponse.ScheduledTask(
                taskId: originalId,
                scheduledTime: Date()
            )

            #expect(task.taskId == originalId)
        }
    }

    // MARK: - AIServiceError Contract Tests

    @Suite("AIServiceError Contracts")
    struct AIServiceErrorContractTests {

        @Test("AIServiceError noAPIKey has description")
        func error_noAPIKey() {
            let error = AIServiceError.noAPIKey

            #expect(error.errorDescription?.isEmpty == false)
            #expect(error.errorDescription?.lowercased().contains("api key") == true)
        }

        @Test("AIServiceError networkError wraps underlying error")
        func error_networkError() {
            let underlyingError = NSError(domain: "test", code: 500)
            let error = AIServiceError.networkError(underlying: underlyingError)

            #expect(error.errorDescription?.isEmpty == false)
            #expect(error.errorDescription?.contains("Network") == true)
        }

        @Test("AIServiceError invalidResponse has description")
        func error_invalidResponse() {
            let error = AIServiceError.invalidResponse

            #expect(error.errorDescription?.isEmpty == false)
            #expect(error.errorDescription?.lowercased().contains("invalid") == true)
        }

        @Test("AIServiceError rateLimited has description")
        func error_rateLimited() {
            let error = AIServiceError.rateLimited

            #expect(error.errorDescription?.isEmpty == false)
            #expect(error.errorDescription?.lowercased().contains("rate") == true)
        }

        @Test("AIServiceError serviceUnavailable has description")
        func error_serviceUnavailable() {
            let error = AIServiceError.serviceUnavailable

            #expect(error.errorDescription?.isEmpty == false)
            #expect(error.errorDescription?.lowercased().contains("unavailable") == true)
        }
    }

    // MARK: - AIServiceProtocol Contract Tests

    @Suite("AIServiceProtocol Contracts")
    struct AIServiceProtocolContractTests {

        @Test("AIService implements all protocol methods")
        func aiService_implementsProtocol() async throws {
            let stack = TestCoreDataStack()
            let strategyRepo = StrategyRepository(context: stack.context)
            let settingsRepo = SettingsRepository(context: stack.context)
            let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
            let aiService = AIService(strategyService: strategyService)

            // Verify all methods can be called without error
            let advice = try await aiService.getCoachingAdvice(for: "test", context: AIContext())
            #expect(advice.isEmpty == false)

            let response = try await aiService.getCoachingResponse(for: "test", context: AIContext())
            #expect(response.advice.isEmpty == false)

            let prioritized = try await aiService.prioritizeTasks([])
            #expect(prioritized.isEmpty)

            let scheduled = try await aiService.suggestSchedule(for: [], settings: .default)
            #expect(scheduled.isEmpty)

            let scheduleResponse = try await aiService.generateSchedule(
                request: ScheduleRequest(tasks: [], date: Date(), settings: .default)
            )
            #expect(scheduleResponse.scheduledTasks.isEmpty)
        }

        @Test("Mock AI service conforms to protocol")
        func mockAIService_conformsToProtocol() async throws {
            let mock = MockAIService()

            // Verify mock can be used in place of real service
            let advice = try await mock.getCoachingAdvice(for: "test", context: AIContext())
            #expect(advice.isEmpty == false)
        }

        @Test("Default protocol implementations work")
        func protocol_defaultImplementations() async throws {
            // Create a minimal implementation that only has getCoachingAdvice
            let mock = MinimalAIService()

            // getCoachingResponse has default implementation
            let response = try await mock.getCoachingResponse(for: "test", context: AIContext())
            #expect(response.advice == "Minimal advice")
            #expect(response.suggestedStrategies.isEmpty)
            #expect(response.followUpQuestions == nil)

            // generateSchedule has default implementation
            let request = ScheduleRequest(tasks: [], date: Date(), settings: .default)
            let scheduleResponse = try await mock.generateSchedule(request: request)
            #expect(scheduleResponse.scheduledTasks.isEmpty)
        }
    }

    // MARK: - Claude API Contract Tests (Future Integration)

    @Suite("Claude API Contracts")
    struct ClaudeAPIContractTests {

        @Test("Coaching request shape matches expected format")
        func coachingRequest_shape() {
            // This test validates the shape of data that would be sent to Claude API
            // When real API is integrated, this ensures our request format is correct

            let context = AIContext(
                problemType: "too_big",
                taskTitle: "Quarterly Report",
                taskDescription: "Analyze and summarize Q4 metrics",
                taskDuration: 120,
                projectName: "Reports",
                energyLevel: .medium,
                pastStrategies: [
                    AIContext.StrategyContext(name: "2-Minute Version", score: 0.8)
                ]
            )

            // Validate all fields that would be serialized
            #expect(context.problemType == "too_big")
            #expect(context.taskTitle != nil)
            #expect(context.pastStrategies.first?.name == "2-Minute Version")
        }

        @Test("Problem types match ADHD coaching vocabulary")
        func problemTypes_matchVocabulary() {
            // These are the problem types the Claude prompt is trained to handle
            let expectedProblemTypes = Set([
                "too_big",
                "unclear",
                "boring",
                "scary",
                "blocked",
                "distracted",
                "low_energy",
                "overwhelmed",
                "forgot",
                "interruptions"
            ])

            // Verify these match what we send
            for problemType in expectedProblemTypes {
                let context = AIContext(problemType: problemType)
                #expect(expectedProblemTypes.contains(context.problemType))
            }
        }

        @Test("Strategy context includes scoring data for personalization")
        func strategyContext_includesScoringData() {
            let context = AIContext.StrategyContext(
                name: "Body Doubling",
                score: 0.85,
                lastUsed: Date(),
                successCount: 17,
                failureCount: 3
            )

            // Claude needs this data to provide personalized advice
            #expect(context.score >= 0.0 && context.score <= 1.0)
            #expect(context.successCount >= 0)
            #expect(context.failureCount >= 0)
        }

        @Test("User preferences include timing data")
        func userPreferences_includesTimingData() {
            let prefs = AIContext.UserPreferences(
                preferredDuration: 45,
                peakFocusStart: "10:00",
                peakFocusEnd: "13:00"
            )

            // Claude uses this to tailor advice to user's schedule
            #expect(prefs.preferredDuration > 0)
            #expect(prefs.peakFocusStart.contains(":"))
            #expect(prefs.peakFocusEnd.contains(":"))
        }
    }

    // MARK: - Gemini API Contract Tests (Future Integration)

    @Suite("Gemini API Contracts")
    struct GeminiAPIContractTests {

        @Test("Schedule request shape matches expected format")
        func scheduleRequest_shape() {
            // This test validates the shape of data that would be sent to Gemini API
            // When real API is integrated, this ensures our request format is correct

            let request = ScheduleRequest(
                tasks: [
                    ScheduleRequest.TaskInfo(
                        id: UUID(),
                        title: "High Priority Task",
                        priority: 5,
                        estimatedDuration: 60,
                        energyRequired: "high"
                    ),
                    ScheduleRequest.TaskInfo(
                        id: UUID(),
                        title: "Low Priority Task",
                        priority: 1,
                        estimatedDuration: 15,
                        energyRequired: "low"
                    )
                ],
                date: Date(),
                settings: .default
            )

            // Validate structure
            #expect(request.tasks.count == 2)
            #expect(request.tasks[0].priority == 5)
            #expect(request.tasks[1].priority == 1)
        }

        @Test("Schedule response can be parsed")
        func scheduleResponse_parsing() {
            // Simulate what we'd receive from Gemini
            let response = ScheduleResponse(scheduledTasks: [
                ScheduleResponse.ScheduledTask(
                    taskId: UUID(),
                    scheduledTime: Date(),
                    reason: "Scheduled during peak focus hours due to high energy requirement"
                )
            ])

            #expect(response.scheduledTasks.count == 1)
            #expect(response.scheduledTasks[0].reason?.isEmpty == false)
        }

        @Test("Task info energy values match expected enum")
        func taskInfo_energyValues() {
            // These values must match what Gemini API expects
            let validEnergies = ["low", "medium", "high"]

            for energy in validEnergies {
                let info = ScheduleRequest.TaskInfo(
                    id: UUID(),
                    title: "Test",
                    priority: 3,
                    estimatedDuration: 30,
                    energyRequired: energy
                )
                #expect(validEnergies.contains(info.energyRequired))
            }
        }

        @Test("Schedule settings include all required fields")
        func scheduleSettings_requiredFields() {
            let settings = ScheduleSettings.default

            // These fields are needed for Gemini to generate a good schedule
            #expect(settings.workHoursStart.isEmpty == false)
            #expect(settings.workHoursEnd.isEmpty == false)
            #expect(settings.peakFocusStart.isEmpty == false)
            #expect(settings.peakFocusEnd.isEmpty == false)
        }
    }

    // MARK: - Response Validation Tests

    @Suite("Response Validation")
    struct ResponseValidationTests {

        @Test("Coaching advice is never empty")
        func coachingAdvice_neverEmpty() async throws {
            let stack = TestCoreDataStack()
            let strategyRepo = StrategyRepository(context: stack.context)
            let settingsRepo = SettingsRepository(context: stack.context)
            let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
            let aiService = AIService(strategyService: strategyService)

            // Test all problem types return non-empty advice
            let problemTypes = ["too_big", "unclear", "boring", "scary", "unknown"]
            for problemType in problemTypes {
                let advice = try await aiService.getCoachingAdvice(
                    for: problemType,
                    context: AIContext()
                )
                #expect(advice.isEmpty == false, "Advice should not be empty for \(problemType)")
            }
        }

        @Test("Coaching response includes non-empty advice")
        func coachingResponse_nonEmptyAdvice() async throws {
            let stack = TestCoreDataStack()
            let strategyRepo = StrategyRepository(context: stack.context)
            let settingsRepo = SettingsRepository(context: stack.context)
            let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
            let aiService = AIService(strategyService: strategyService)

            let response = try await aiService.getCoachingResponse(
                for: "too_big",
                context: AIContext()
            )

            #expect(response.advice.isEmpty == false)
        }

        @Test("Schedule response preserves task IDs")
        func scheduleResponse_preservesIDs() async throws {
            let stack = TestCoreDataStack()
            let strategyRepo = StrategyRepository(context: stack.context)
            let settingsRepo = SettingsRepository(context: stack.context)
            let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
            let aiService = AIService(strategyService: strategyService)

            let taskIds = [UUID(), UUID(), UUID()]
            let request = ScheduleRequest(
                tasks: taskIds.enumerated().map { index, id in
                    ScheduleRequest.TaskInfo(
                        id: id,
                        title: "Task \(index)",
                        priority: 3,
                        estimatedDuration: 30
                    )
                },
                date: Date(),
                settings: .default
            )

            let response = try await aiService.generateSchedule(request: request)

            // All task IDs should be preserved in response
            let responseIds = Set(response.scheduledTasks.map { $0.taskId })
            let requestIds = Set(taskIds)
            #expect(responseIds == requestIds)
        }
    }
}

// MARK: - Test Helpers

/// Minimal AI service implementation for testing default protocol methods
private final class MinimalAIService: AIServiceProtocol {
    func getCoachingAdvice(for problemType: String, context: AIContext) async throws -> String {
        return "Minimal advice"
    }

    func prioritizeTasks(_ tasks: [TGTask]) async throws -> [TGTask] {
        return tasks
    }

    func suggestSchedule(for tasks: [TGTask], settings: ScheduleSettings) async throws -> [TGTask] {
        return tasks
    }
}
