import Testing
import Foundation
@testable import Tangentle

@Suite("TodayViewModel Tests")
struct TodayViewModelTests {

    @Test("Load tasks populates today and overdue arrays")
    @MainActor
    func loadTasks() async throws {
        let stack = TestCoreDataStack()
        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )
        let scheduleService = ScheduleService(
            taskRepository: TaskRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let viewModel = TodayViewModel(
            taskService: taskService,
            scheduleService: scheduleService
        )

        // Create tasks
        _ = stack.createTask(title: "Today", scheduledDate: .testToday)
        _ = stack.createTask(title: "Overdue", status: .pending, dueDate: .testYesterday)

        try stack.save()

        await viewModel.loadTasks()

        #expect(viewModel.todaysTasks.count == 1)
        #expect(viewModel.overdueTasks.count == 1)
        #expect(viewModel.isLoading == false)
    }

    @Test("Complete task updates status and reloads")
    @MainActor
    func completeTask() async throws {
        let stack = TestCoreDataStack()
        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )
        let scheduleService = ScheduleService(
            taskRepository: TaskRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let viewModel = TodayViewModel(
            taskService: taskService,
            scheduleService: scheduleService
        )

        let task = stack.createTask(title: "To Complete", scheduledDate: .testToday)
        try stack.save()

        await viewModel.loadTasks()
        #expect(viewModel.todaysTasks.count == 1)

        await viewModel.completeTask(task)

        #expect(task.isCompleted)
        #expect(viewModel.todaysTasks.count == 0)
    }

    @Test("Initial state has empty arrays")
    @MainActor
    func initialState() async throws {
        let stack = TestCoreDataStack()
        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )
        let scheduleService = ScheduleService(
            taskRepository: TaskRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let viewModel = TodayViewModel(
            taskService: taskService,
            scheduleService: scheduleService
        )

        #expect(viewModel.todaysTasks.isEmpty)
        #expect(viewModel.overdueTasks.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    @Test("Loading state is true during load")
    @MainActor
    func loadingState() async throws {
        let stack = TestCoreDataStack()
        let taskService = TaskService(
            taskRepository: TaskRepository(context: stack.context),
            projectRepository: ProjectRepository(context: stack.context),
            strategyRepository: StrategyRepository(context: stack.context)
        )
        let scheduleService = ScheduleService(
            taskRepository: TaskRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let viewModel = TodayViewModel(
            taskService: taskService,
            scheduleService: scheduleService
        )

        // After load completes, isLoading should be false
        await viewModel.loadTasks()
        #expect(viewModel.isLoading == false)
    }
}
