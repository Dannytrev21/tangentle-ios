import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("AIService Tests")
struct AIServiceTests {

    // MARK: - Get Coaching Advice Tests

    @Test("Get coaching advice returns string for problem type")
    func getCoachingAdvice_returnsString() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let advice = try await aiService.getCoachingAdvice(
            for: "too_big",
            context: AIContext()
        )

        #expect(advice.isEmpty == false)
    }

    @Test("Get coaching advice for 'too_big' mentions breaking down")
    func getCoachingAdvice_tooBig_mentionsBreakdown() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let advice = try await aiService.getCoachingAdvice(
            for: "too_big",
            context: AIContext()
        )

        // Should mention 2-minute version or breaking down
        let containsRelevant = advice.lowercased().contains("2") ||
                               advice.lowercased().contains("start") ||
                               advice.lowercased().contains("overwhelming")
        #expect(containsRelevant)
    }

    @Test("Get coaching advice for 'unclear' mentions defining done")
    func getCoachingAdvice_unclear_mentionsDefining() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let advice = try await aiService.getCoachingAdvice(
            for: "unclear",
            context: AIContext()
        )

        let containsRelevant = advice.lowercased().contains("done") ||
                               advice.lowercased().contains("start") ||
                               advice.lowercased().contains("deliverable")
        #expect(containsRelevant)
    }

    @Test("Get coaching advice for 'boring' mentions motivation")
    func getCoachingAdvice_boring_mentionsMotivation() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let advice = try await aiService.getCoachingAdvice(
            for: "boring",
            context: AIContext()
        )

        let containsRelevant = advice.lowercased().contains("reward") ||
                               advice.lowercased().contains("motivation") ||
                               advice.lowercased().contains("body")
        #expect(containsRelevant)
    }

    @Test("Get coaching advice for 'scary' mentions permission")
    func getCoachingAdvice_scary_mentionsPermission() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let advice = try await aiService.getCoachingAdvice(
            for: "scary",
            context: AIContext()
        )

        let containsRelevant = advice.lowercased().contains("permission") ||
                               advice.lowercased().contains("fear") ||
                               advice.lowercased().contains("failure") ||
                               advice.lowercased().contains("draft")
        #expect(containsRelevant)
    }

    @Test("Get coaching advice for 'low_energy' mentions basic needs")
    func getCoachingAdvice_lowEnergy_mentionsBasicNeeds() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let advice = try await aiService.getCoachingAdvice(
            for: "low_energy",
            context: AIContext()
        )

        let containsRelevant = advice.lowercased().contains("eaten") ||
                               advice.lowercased().contains("hydrat") ||
                               advice.lowercased().contains("depleted") ||
                               advice.lowercased().contains("basic")
        #expect(containsRelevant)
    }

    @Test("Get coaching advice uses past strategies when available")
    func getCoachingAdvice_usesPastStrategies() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let context = AIContext(
            problemType: "too_big",
            pastStrategies: [
                AIContext.StrategyContext(name: "2-Minute Version", score: 0.8, successCount: 5),
                AIContext.StrategyContext(name: "Break It Down", score: 0.6, successCount: 3)
            ]
        )

        let advice = try await aiService.getCoachingAdvice(
            for: "too_big",
            context: context
        )

        // Should mention past strategies
        let mentionsStrategy = advice.contains("2-Minute") || advice.contains("Break")
        #expect(mentionsStrategy)
    }

    // MARK: - Get Coaching Response Tests

    @Test("Get coaching response returns structured response")
    func getCoachingResponse_returnsStructured() async throws {
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

    @Test("Get coaching response includes follow-up questions")
    func getCoachingResponse_includesFollowUp() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let response = try await aiService.getCoachingResponse(
            for: "too_big",
            context: AIContext()
        )

        #expect(response.followUpQuestions != nil)
        #expect(response.followUpQuestions?.isEmpty == false)
    }

    @Test("Get coaching response includes suggested strategies with context")
    func getCoachingResponse_includesStrategiesWithContext() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let context = AIContext(
            problemType: "too_big",
            pastStrategies: [
                AIContext.StrategyContext(name: "Test Strategy", score: 0.9)
            ]
        )

        let response = try await aiService.getCoachingResponse(
            for: "too_big",
            context: context
        )

        // Should have suggested strategies
        #expect(response.suggestedStrategies.isEmpty == false)
    }

    // MARK: - Prioritize Tasks Tests

    @Test("Prioritize tasks returns reordered list")
    func prioritizeTasks_returnsReordered() async throws {
        let stack = TestCoreDataStack()
        let task1 = stack.createTask(title: "Low Priority", priority: .low)
        let task2 = stack.createTask(title: "High Priority", priority: .high)
        try stack.save()

        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let result = try await aiService.prioritizeTasks([task1, task2])

        #expect(result.count == 2)
        // High priority should come first
        #expect(result.first?.title == "High Priority")
    }

    @Test("Prioritize tasks empty list returns empty")
    func prioritizeTasks_emptyList_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let result = try await aiService.prioritizeTasks([])

        #expect(result.isEmpty)
    }

    @Test("Prioritize tasks considers due date")
    func prioritizeTasks_considersDueDate() async throws {
        let stack = TestCoreDataStack()
        let laterDue = stack.createTask(title: "Later Due", priority: .medium, dueDate: Date.testTomorrow)
        let soonerDue = stack.createTask(title: "Sooner Due", priority: .medium, dueDate: Date.testToday)
        try stack.save()

        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let result = try await aiService.prioritizeTasks([laterDue, soonerDue])

        #expect(result.count == 2)
        // Earlier due date should come first when priority is same
        #expect(result.first?.title == "Sooner Due")
    }

    @Test("Prioritize tasks puts tasks with due date before those without")
    func prioritizeTasks_dueBeforeNoDue() async throws {
        let stack = TestCoreDataStack()
        let noDue = stack.createTask(title: "No Due", priority: .medium)
        let hasDue = stack.createTask(title: "Has Due", priority: .medium, dueDate: Date.testTomorrow)
        try stack.save()

        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let result = try await aiService.prioritizeTasks([noDue, hasDue])

        #expect(result.first?.title == "Has Due")
    }

    // MARK: - Suggest Schedule Tests

    @Test("Suggest schedule returns tasks with scheduled dates")
    func suggestSchedule_returnsScheduledTasks() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "To Schedule")
        try stack.save()

        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let result = try await aiService.suggestSchedule(
            for: [task],
            settings: .default
        )

        #expect(result.count == 1)
        #expect(result.first?.scheduledDate != nil)
    }

    @Test("Suggest schedule empty list returns empty")
    func suggestSchedule_emptyList_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let result = try await aiService.suggestSchedule(
            for: [],
            settings: .default
        )

        #expect(result.isEmpty)
    }

    @Test("Suggest schedule orders by energy and priority")
    func suggestSchedule_ordersByEnergyAndPriority() async throws {
        let stack = TestCoreDataStack()
        let lowTask = stack.createTask(title: "Low Task", priority: .low)
        lowTask.energy = .low
        let highTask = stack.createTask(title: "High Task", priority: .high)
        highTask.energy = .high
        try stack.save()

        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let result = try await aiService.suggestSchedule(
            for: [lowTask, highTask],
            settings: .default
        )

        #expect(result.count == 2)
        // High energy/priority should be scheduled first (earlier time)
        #expect(result.first?.title == "High Task")
    }

    // MARK: - Generate Schedule Tests

    @Test("Generate schedule returns schedule response")
    func generateSchedule_returnsResponse() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let request = ScheduleRequest(
            tasks: [
                ScheduleRequest.TaskInfo(
                    id: UUID(),
                    title: "Test Task",
                    priority: 3,
                    estimatedDuration: 30
                )
            ],
            date: Date.testToday,
            settings: .default
        )

        let response = try await aiService.generateSchedule(request: request)

        #expect(response.scheduledTasks.count == 1)
    }

    @Test("Generate schedule with high priority includes reason")
    func generateSchedule_highPriority_includesReason() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let request = ScheduleRequest(
            tasks: [
                ScheduleRequest.TaskInfo(
                    id: UUID(),
                    title: "High Priority Task",
                    priority: 5,
                    estimatedDuration: 30
                )
            ],
            date: Date.testToday,
            settings: .default
        )

        let response = try await aiService.generateSchedule(request: request)

        #expect(response.scheduledTasks.first?.reason != nil)
    }

    @Test("Generate schedule empty request returns empty response")
    func generateSchedule_emptyRequest_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let strategyService = StrategyService(strategyRepository: strategyRepo, settingsRepository: settingsRepo)
        let aiService = AIService(strategyService: strategyService)

        let request = ScheduleRequest(
            tasks: [],
            date: Date.testToday,
            settings: .default
        )

        let response = try await aiService.generateSchedule(request: request)

        #expect(response.scheduledTasks.isEmpty)
    }

    // MARK: - Mock AI Service Tests

    @Test("Mock AI service returns configured advice")
    func mockAIService_returnsConfiguredAdvice() async throws {
        let mockAI = MockAIServiceWithSpy()
        mockAI.mockCoachingAdvice = "Custom test advice"

        let advice = try await mockAI.getCoachingAdvice(
            for: "test",
            context: AIContext()
        )

        #expect(advice.contains("Custom test advice"))
        #expect(mockAI.wasCalled("getCoachingAdvice"))
    }

    @Test("Mock AI service can throw error")
    func mockAIService_throwsError() async throws {
        let mockAI = MockAIServiceWithSpy()
        mockAI.shouldThrow = true
        mockAI.throwError = MockError.intentional

        await #expect(throws: MockError.self) {
            _ = try await mockAI.getCoachingAdvice(
                for: "test",
                context: AIContext()
            )
        }
    }

    @Test("Mock AI service tracks calls")
    func mockAIService_tracksCalls() async throws {
        let mockAI = MockAIServiceWithSpy()

        _ = try await mockAI.getCoachingAdvice(for: "type1", context: AIContext())
        _ = try await mockAI.getCoachingAdvice(for: "type2", context: AIContext())

        #expect(mockAI.callCount("getCoachingAdvice") == 2)
    }

    @Test("Mock AI service records arguments")
    func mockAIService_recordsArguments() async throws {
        let mockAI = MockAIServiceWithSpy()

        _ = try await mockAI.getCoachingAdvice(for: "too_big", context: AIContext())

        let lastCall = mockAI.lastCall("getCoachingAdvice")
        #expect(lastCall?.arguments["problemType"] as? String == "too_big")
    }
}
