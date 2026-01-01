import XCTest
@testable import Tangentle

/// Performance benchmarks for service layer operations.
/// Tests end-to-end service workflows which combine multiple repository calls.
final class ServicePerformanceTests: XCTestCase {

    var stack: TestCoreDataStack!

    override func setUp() {
        super.setUp()
        stack = TestCoreDataStack()
    }

    override func tearDown() {
        PerformanceTestData.clearAllData(in: stack.context)
        stack = nil
        super.tearDown()
    }

    // MARK: - Task Service Performance

    func testTaskService_getTodaysTasks_100tasks_performance() throws {
        PerformanceTestData.seedTasks(100, in: stack.context)

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await taskService.getTodaysTasks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testTaskService_getTodaysTasks_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await taskService.getTodaysTasks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testTaskService_getOverdueTasks_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await taskService.getOverdueTasks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testTaskService_getUpcomingTasks_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)

        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await taskService.getUpcomingTasks(days: 7)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Strategy Service Performance

    func testStrategyService_getStrategiesForProblem_100strategies_performance() throws {
        PerformanceTestData.seedStrategies(100, outcomesPerStrategy: 20, in: stack.context)

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await strategyService.getStrategiesForProblem("too_big")
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testStrategyService_getTopStrategies_100strategies_performance() throws {
        PerformanceTestData.seedStrategies(100, outcomesPerStrategy: 50, in: stack.context)

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await strategyService.getTopStrategies(limit: 10)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Strategy Score Calculation Performance

    func testStrategyService_calculateScore_50outcomes_performance() throws {
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: strategyRepo,
            settingsRepository: settingsRepo
        )

        // Create strategy with many outcomes
        let strategy = TGStrategy(context: stack.context)
        strategy.id = UUID()
        strategy.name = "Test Strategy"
        strategy.strategyDescription = "Test description"
        strategy.problemTypesArray = ["too_big"]
        strategy.taskTypesArray = ["all"]
        strategy.source = "test"
        strategy.isActive = true
        strategy.createdAt = Date()
        strategy.updatedAt = Date()

        for i in 0..<50 {
            let outcome = TGStrategyOutcome(context: stack.context)
            outcome.id = UUID()
            outcome.result = ["success", "partial", "failure"][i % 3]
            outcome.problemType = "too_big"
            outcome.date = Date().addingTimeInterval(TimeInterval(-i * 86400))
            outcome.strategy = strategy
        }
        try? stack.context.save()

        measure(metrics: [XCTClockMetric()]) {
            // Calculate score many times to get reliable measurement
            for _ in 0..<100 {
                _ = service.calculateScore(for: strategy)
            }
        }
    }

    func testStrategyService_calculateScore_100outcomes_performance() throws {
        let strategyRepo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: strategyRepo,
            settingsRepository: settingsRepo
        )

        // Create strategy with many outcomes
        let strategy = TGStrategy(context: stack.context)
        strategy.id = UUID()
        strategy.name = "Test Strategy"
        strategy.strategyDescription = "Test description"
        strategy.problemTypesArray = ["too_big"]
        strategy.taskTypesArray = ["all"]
        strategy.source = "test"
        strategy.isActive = true
        strategy.createdAt = Date()
        strategy.updatedAt = Date()

        for i in 0..<100 {
            let outcome = TGStrategyOutcome(context: stack.context)
            outcome.id = UUID()
            outcome.result = ["success", "partial", "failure"][i % 3]
            outcome.problemType = "too_big"
            outcome.date = Date().addingTimeInterval(TimeInterval(-i * 86400))
            outcome.strategy = strategy
        }
        try? stack.context.save()

        measure(metrics: [XCTClockMetric()]) {
            // Calculate score many times to get reliable measurement
            for _ in 0..<100 {
                _ = service.calculateScore(for: strategy)
            }
        }
    }

    // MARK: - Schedule Service Performance

    func testScheduleService_getScheduleForDate_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)

        let scheduleService = ScheduleService(
            taskRepository: TaskRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let today = Date.testToday

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await scheduleService.getScheduleForDate(today)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testScheduleService_getAvailableSlots_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)

        let scheduleService = ScheduleService(
            taskRepository: TaskRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let today = Date.testToday

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await scheduleService.getAvailableSlots(for: today)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Settings Service Performance

    func testSettingsService_getSettings_performance() throws {
        // Create settings
        _ = stack.createSettings()
        try? stack.save()

        let settingsService = SettingsService(
            settingsRepository: SettingsRepository(context: stack.context)
        )

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await settingsService.getSettings()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }
}
