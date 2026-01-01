import XCTest
@testable import Tangentle

/// Performance benchmarks for ViewModel operations.
/// Tests the responsiveness of ViewModel data loading which directly
/// impacts the user experience for ADHD users.
final class ViewModelPerformanceTests: XCTestCase {

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

    // MARK: - TodayViewModel Load Performance (Sync Wrapper)

    func testTodayViewModel_loadTasks_50tasks_performance() throws {
        PerformanceTestData.seedTasks(50, in: stack.context)

        let mockService = MockTaskService()
        let mockScheduleService = MockScheduleService()

        // Pre-fetch real data to configure mock (synchronous setup)
        let taskRepo = TaskRepository(context: stack.context)

        // Run once to populate mock with real data
        let setupExpectation = expectation(description: "setup")
        Task {
            let todaysTasks = try await taskRepo.fetchTodaysTasks()
            let overdueTasks = try await taskRepo.fetchOverdueTasks()
            mockService.getTodaysTasksResult = .success(todaysTasks)
            mockService.getOverdueTasksResult = .success(overdueTasks)
            setupExpectation.fulfill()
        }
        wait(for: [setupExpectation], timeout: 10)

        // Now measure just the ViewModel load (which uses mock)
        measure(metrics: [XCTClockMetric()]) {
            let viewModel = TodayViewModel(taskService: mockService, scheduleService: mockScheduleService)
            let loadExpectation = expectation(description: "load")
            Task { @MainActor in
                await viewModel.loadTasks()
                loadExpectation.fulfill()
            }
            wait(for: [loadExpectation], timeout: 5)
        }
    }

    func testTodayViewModel_loadTasks_100tasks_performance() throws {
        PerformanceTestData.seedTasks(100, in: stack.context)

        let mockService = MockTaskService()
        let mockScheduleService = MockScheduleService()
        let taskRepo = TaskRepository(context: stack.context)

        let setupExpectation = expectation(description: "setup")
        Task {
            let todaysTasks = try await taskRepo.fetchTodaysTasks()
            let overdueTasks = try await taskRepo.fetchOverdueTasks()
            mockService.getTodaysTasksResult = .success(todaysTasks)
            mockService.getOverdueTasksResult = .success(overdueTasks)
            setupExpectation.fulfill()
        }
        wait(for: [setupExpectation], timeout: 10)

        measure(metrics: [XCTClockMetric()]) {
            let viewModel = TodayViewModel(taskService: mockService, scheduleService: mockScheduleService)
            let loadExpectation = expectation(description: "load")
            Task { @MainActor in
                await viewModel.loadTasks()
                loadExpectation.fulfill()
            }
            wait(for: [loadExpectation], timeout: 5)
        }
    }

    func testTodayViewModel_loadTasks_200tasks_performance() throws {
        PerformanceTestData.seedTasks(200, in: stack.context)

        let mockService = MockTaskService()
        let mockScheduleService = MockScheduleService()
        let taskRepo = TaskRepository(context: stack.context)

        let setupExpectation = expectation(description: "setup")
        Task {
            let todaysTasks = try await taskRepo.fetchTodaysTasks()
            let overdueTasks = try await taskRepo.fetchOverdueTasks()
            mockService.getTodaysTasksResult = .success(todaysTasks)
            mockService.getOverdueTasksResult = .success(overdueTasks)
            setupExpectation.fulfill()
        }
        wait(for: [setupExpectation], timeout: 10)

        measure(metrics: [XCTClockMetric()]) {
            let viewModel = TodayViewModel(taskService: mockService, scheduleService: mockScheduleService)
            let loadExpectation = expectation(description: "load")
            Task { @MainActor in
                await viewModel.loadTasks()
                loadExpectation.fulfill()
            }
            wait(for: [loadExpectation], timeout: 5)
        }
    }

    // MARK: - TodayViewModel with Real Services Performance

    func testTodayViewModel_realServices_100tasks_performance() throws {
        PerformanceTestData.seedTasks(100, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let taskService = TaskService(
                taskRepository: TaskRepository(context: stack.context),
                projectRepository: ProjectRepository(context: stack.context),
                strategyRepository: StrategyRepository(context: stack.context)
            )

            let scheduleService = ScheduleService(
                taskRepository: TaskRepository(context: stack.context),
                settingsRepository: SettingsRepository(context: stack.context)
            )

            let viewModel = TodayViewModel(taskService: taskService, scheduleService: scheduleService)

            let loadExpectation = expectation(description: "load")
            Task { @MainActor in
                await viewModel.loadTasks()
                loadExpectation.fulfill()
            }
            wait(for: [loadExpectation], timeout: 5)
        }
    }

    func testTodayViewModel_realServices_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let taskService = TaskService(
                taskRepository: TaskRepository(context: stack.context),
                projectRepository: ProjectRepository(context: stack.context),
                strategyRepository: StrategyRepository(context: stack.context)
            )

            let scheduleService = ScheduleService(
                taskRepository: TaskRepository(context: stack.context),
                settingsRepository: SettingsRepository(context: stack.context)
            )

            let viewModel = TodayViewModel(taskService: taskService, scheduleService: scheduleService)

            let loadExpectation = expectation(description: "load")
            Task { @MainActor in
                await viewModel.loadTasks()
                loadExpectation.fulfill()
            }
            wait(for: [loadExpectation], timeout: 5)
        }
    }

    // MARK: - TodayViewModel Complete Task Performance

    func testTodayViewModel_completeTask_performance() throws {
        PerformanceTestData.seedTasks(100, in: stack.context)

        let mockService = MockTaskService()
        let mockScheduleService = MockScheduleService()
        let taskRepo = TaskRepository(context: stack.context)

        var taskToComplete: TGTask?

        let setupExpectation = expectation(description: "setup")
        Task {
            let todaysTasks = try await taskRepo.fetchTodaysTasks()
            let overdueTasks = try await taskRepo.fetchOverdueTasks()
            mockService.getTodaysTasksResult = .success(todaysTasks)
            mockService.getOverdueTasksResult = .success(overdueTasks)
            mockService.completeTaskError = nil
            taskToComplete = todaysTasks.first
            setupExpectation.fulfill()
        }
        wait(for: [setupExpectation], timeout: 10)

        guard let task = taskToComplete else {
            XCTFail("No tasks to test")
            return
        }

        let viewModel = TodayViewModel(taskService: mockService, scheduleService: mockScheduleService)

        // Load initial data
        let loadExpectation = expectation(description: "load")
        Task { @MainActor in
            await viewModel.loadTasks()
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5)

        measure(metrics: [XCTClockMetric()]) {
            let completeExpectation = expectation(description: "complete")
            Task { @MainActor in
                await viewModel.completeTask(task)
                completeExpectation.fulfill()
            }
            wait(for: [completeExpectation], timeout: 5)
        }
    }

    // MARK: - TodayViewModel Delete Task Performance

    func testTodayViewModel_deleteTask_performance() throws {
        PerformanceTestData.seedTasks(100, in: stack.context)

        let mockService = MockTaskService()
        let mockScheduleService = MockScheduleService()
        let taskRepo = TaskRepository(context: stack.context)

        var taskToDelete: TGTask?

        let setupExpectation = expectation(description: "setup")
        Task {
            let todaysTasks = try await taskRepo.fetchTodaysTasks()
            let overdueTasks = try await taskRepo.fetchOverdueTasks()
            mockService.getTodaysTasksResult = .success(todaysTasks)
            mockService.getOverdueTasksResult = .success(overdueTasks)
            mockService.deleteTaskError = nil
            taskToDelete = todaysTasks.first
            setupExpectation.fulfill()
        }
        wait(for: [setupExpectation], timeout: 10)

        guard let task = taskToDelete else {
            XCTFail("No tasks to test")
            return
        }

        let viewModel = TodayViewModel(taskService: mockService, scheduleService: mockScheduleService)

        // Load initial data
        let loadExpectation = expectation(description: "load")
        Task { @MainActor in
            await viewModel.loadTasks()
            loadExpectation.fulfill()
        }
        wait(for: [loadExpectation], timeout: 5)

        measure(metrics: [XCTClockMetric()]) {
            let deleteExpectation = expectation(description: "delete")
            Task { @MainActor in
                await viewModel.deleteTask(task)
                deleteExpectation.fulfill()
            }
            wait(for: [deleteExpectation], timeout: 5)
        }
    }
}
