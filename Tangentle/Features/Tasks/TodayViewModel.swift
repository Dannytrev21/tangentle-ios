import Foundation
import Observation

@Observable
final class TodayViewModel {
    var todaysTasks: [TGTask] = []
    var overdueTasks: [TGTask] = []
    var isLoading = false
    var error: Error?

    private let taskService: TaskServiceProtocol
    private let scheduleService: ScheduleServiceProtocol

    init(taskService: TaskServiceProtocol, scheduleService: ScheduleServiceProtocol) {
        self.taskService = taskService
        self.scheduleService = scheduleService
    }

    @MainActor
    func loadTasks() async {
        isLoading = true
        defer { isLoading = false }

        do {
            async let today = taskService.getTodaysTasks()
            async let overdue = taskService.getOverdueTasks()

            todaysTasks = try await today
            overdueTasks = try await overdue
        } catch {
            self.error = error
        }
    }

    @MainActor
    func completeTask(_ task: TGTask) async {
        do {
            try await taskService.completeTask(task)
            await loadTasks()
        } catch {
            self.error = error
        }
    }

    @MainActor
    func deleteTask(_ task: TGTask) async {
        do {
            try await taskService.deleteTask(task)
            await loadTasks()
        } catch {
            self.error = error
        }
    }

    @MainActor
    func deferTask(_ task: TGTask) async {
        do {
            // Defer task by setting status and moving scheduled date to tomorrow
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
            try await taskService.updateTask(task, with: TaskChanges(
                status: .deferred,
                scheduledDate: tomorrow
            ))
            await loadTasks()
        } catch {
            self.error = error
        }
    }
}
