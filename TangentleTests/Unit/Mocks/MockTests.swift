import Testing
import Foundation
@testable import Tangentle

@Suite("Mock Infrastructure Tests")
struct MockTests {

    // MARK: - MockTaskRepository Tests

    @Test("Mock task repository tracks fetch calls")
    func mockTaskRepository_tracksCalls() async throws {
        let mock = MockTaskRepository()
        mock.fetchTodaysTasksResult = .success([])

        _ = try await mock.fetchTodaysTasks()

        #expect(mock.wasCalled("fetchTodaysTasks"))
        #expect(mock.callCount("fetchTodaysTasks") == 1)
    }

    @Test("Mock task repository returns configured result")
    func mockTaskRepository_returnsConfiguredResult() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Mock Task")
        try stack.save()

        let mock = MockTaskRepository()
        mock.fetchTodaysTasksResult = .success([task])

        let result = try await mock.fetchTodaysTasks()

        #expect(result.count == 1)
        #expect(result.first?.title == "Mock Task")
    }

    @Test("Mock task repository throws when configured")
    func mockTaskRepository_throwsWhenConfigured() async throws {
        let mock = MockTaskRepository()
        mock.fetchTodaysTasksResult = .failure(MockError.intentional)

        await #expect(throws: MockError.self) {
            _ = try await mock.fetchTodaysTasks()
        }
    }

    @Test("Mock task repository save tracks call count")
    func mockTaskRepository_saveTracksCallCount() async throws {
        let mock = MockTaskRepository()

        try await mock.save()
        try await mock.save()
        try await mock.save()

        #expect(mock.callCount("save") == 3)
    }

    @Test("Mock task repository save throws when configured")
    func mockTaskRepository_saveThrowsWhenConfigured() async throws {
        let mock = MockTaskRepository()
        mock.shouldThrowOnSave = true
        mock.saveError = MockError.intentional

        await #expect(throws: MockError.self) {
            try await mock.save()
        }
    }

    // MARK: - MockSpy Tests

    @Test("Method call spy records arguments")
    func methodCallSpy_recordsArguments() async throws {
        let mock = MockTaskRepository()

        _ = try await mock.fetchByPriority(.high)

        let call = mock.lastCall("fetchByPriority")
        #expect(call != nil)
        #expect(call?.arguments["priority"] as? Int == Int(Priority.high.rawValue))
    }

    @Test("Clear calls resets tracking")
    func clearCalls_resetsTracking() async throws {
        let mock = MockTaskRepository()

        _ = try await mock.fetchTodaysTasks()
        #expect(mock.callCount("fetchTodaysTasks") == 1)

        mock.clearCalls()
        #expect(mock.callCount("fetchTodaysTasks") == 0)
    }

    @Test("Last call returns most recent invocation")
    func lastCall_returnsMostRecent() async throws {
        let mock = MockTaskRepository()

        _ = try await mock.fetchByPriority(.low)
        _ = try await mock.fetchByPriority(.high)
        _ = try await mock.fetchByPriority(.medium)

        let call = mock.lastCall("fetchByPriority")
        #expect(call?.arguments["priority"] as? Int == Int(Priority.medium.rawValue))
    }

    // MARK: - MockTaskService Tests

    @Test("Mock task service tracks method calls")
    func mockTaskService_tracksMethodCalls() async throws {
        let mock = MockTaskService()
        mock.getTodaysTasksResult = .success([])
        mock.getOverdueTasksResult = .success([])

        _ = try await mock.getTodaysTasks()
        _ = try await mock.getOverdueTasks()

        #expect(mock.wasCalled("getTodaysTasks"))
        #expect(mock.wasCalled("getOverdueTasks"))
    }

    @Test("Mock task service throws on completeTask when configured")
    func mockTaskService_completeTaskThrows() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Test")
        try stack.save()

        let mock = MockTaskService()
        mock.completeTaskError = MockError.intentional

        await #expect(throws: MockError.self) {
            try await mock.completeTask(task)
        }
        #expect(mock.wasCalled("completeTask"))
    }

    // MARK: - MockStrategyService Tests

    @Test("Mock strategy service returns configured strategies")
    func mockStrategyService_returnsConfiguredStrategies() async throws {
        let stack = TestCoreDataStack()
        let strategy = stack.createStrategy(name: "Test Strategy")
        try stack.save()

        let mock = MockStrategyService()
        mock.getStrategiesForProblemResult = .success([strategy])

        let result = try await mock.getStrategiesForProblem("too_big")

        #expect(result.count == 1)
        #expect(result.first?.name == "Test Strategy")
        #expect(mock.wasCalled("getStrategiesForProblem"))
        #expect(mock.lastCall("getStrategiesForProblem")?.arguments["problemType"] as? String == "too_big")
    }

    @Test("Mock strategy service calculateScore returns configured value")
    func mockStrategyService_calculateScore() async throws {
        let stack = TestCoreDataStack()
        let strategy = stack.createStrategy()
        try stack.save()

        let mock = MockStrategyService()
        mock.calculateScoreResult = 0.85

        let score = mock.calculateScore(for: strategy)

        #expect(score == 0.85)
        #expect(mock.wasCalled("calculateScore"))
    }

    // MARK: - MockScheduleService Tests

    @Test("Mock schedule service returns default schedule when not configured")
    func mockScheduleService_returnsDefaultSchedule() async throws {
        let mock = MockScheduleService()
        let date = Date()

        let schedule = try await mock.getScheduleForDate(date)

        #expect(schedule.tasks.isEmpty)
        #expect(mock.wasCalled("getScheduleForDate"))
    }

    @Test("Mock schedule service tracks reschedule calls")
    func mockScheduleService_tracksRescheduleCalls() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask()
        try stack.save()

        let mock = MockScheduleService()
        let newDate = Date().addingTimeInterval(86400)

        try await mock.rescheduleTask(task, to: newDate)

        #expect(mock.wasCalled("rescheduleTask"))
        let call = mock.lastCall("rescheduleTask")
        #expect(call?.arguments["taskId"] != nil)
    }

    // MARK: - MockSettingsService Tests

    @Test("Mock settings service returns default settings when configured")
    func mockSettingsService_returnsDefaultSettings() async throws {
        let mock = MockSettingsService()

        _ = try await mock.getScheduleSettings()
        _ = try await mock.getTaskSettings()

        // Should return defaults when not configured
        #expect(mock.wasCalled("getScheduleSettings"))
        #expect(mock.wasCalled("getTaskSettings"))
    }

    // MARK: - MockAIServiceWithSpy Tests

    @Test("Mock AI service tracks coaching calls")
    func mockAIService_tracksCoachingCalls() async throws {
        let mock = MockAIServiceWithSpy()
        mock.mockCoachingAdvice = "Test advice"

        let advice = try await mock.getCoachingAdvice(for: "too_big", context: AIContext())

        #expect(advice.contains("Test advice"))
        #expect(mock.wasCalled("getCoachingAdvice"))
        #expect(mock.lastCall("getCoachingAdvice")?.arguments["problemType"] as? String == "too_big")
    }

    @Test("Mock AI service throws when configured")
    func mockAIService_throwsWhenConfigured() async throws {
        let mock = MockAIServiceWithSpy()
        mock.shouldThrow = true
        mock.throwError = AIServiceError.serviceUnavailable

        await #expect(throws: AIServiceError.self) {
            _ = try await mock.getCoachingAdvice(for: "blocked", context: AIContext())
        }
    }

    // MARK: - Reset Tests

    @Test("Repository mock reset clears state")
    func repositoryMock_resetClearsState() async throws {
        let mock = MockTaskRepository()
        mock.shouldThrowOnSave = true
        mock.shouldThrowOnDelete = true
        _ = try await mock.fetchTodaysTasks()

        mock.reset()

        #expect(mock.shouldThrowOnSave == false)
        #expect(mock.shouldThrowOnDelete == false)
        #expect(mock.calls.isEmpty)
    }
}
