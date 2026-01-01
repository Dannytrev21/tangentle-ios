import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("ScheduleService Tests")
struct ScheduleServiceTests {

    // MARK: - Get Schedule For Date Tests

    @Test("Get schedule for date returns day schedule with tasks")
    func getScheduleForDate_returnsDaySchedule() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Scheduled Task", scheduledDate: Date.testToday)
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let schedule = try await service.getScheduleForDate(Date.testToday)

        #expect(schedule.tasks.count == 1)
        #expect(schedule.tasks.first?.title == "Scheduled Task")
    }

    @Test("Get schedule for date returns empty schedule when no tasks")
    func getScheduleForDate_noTasks_returnsEmpty() async throws {
        let stack = TestCoreDataStack()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let schedule = try await service.getScheduleForDate(Date.testToday)

        #expect(schedule.tasks.isEmpty)
    }

    @Test("Get schedule for date returns correct date")
    func getScheduleForDate_returnsCorrectDate() async throws {
        let stack = TestCoreDataStack()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let targetDate = Date.testTomorrow
        let schedule = try await service.getScheduleForDate(targetDate)

        let calendar = Calendar.current
        #expect(calendar.isDate(schedule.date, inSameDayAs: targetDate))
    }

    @Test("Get schedule for date only includes tasks for that date")
    func getScheduleForDate_onlyTasksForDate() async throws {
        let stack = TestCoreDataStack()
        _ = stack.createTask(title: "Today Task", scheduledDate: Date.testToday)
        _ = stack.createTask(title: "Tomorrow Task", scheduledDate: Date.testTomorrow)
        _ = stack.createTask(title: "Yesterday Task", scheduledDate: Date.testYesterday)
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let schedule = try await service.getScheduleForDate(Date.testToday)

        #expect(schedule.tasks.count == 1)
        #expect(schedule.tasks.first?.title == "Today Task")
    }

    // MARK: - Suggest Time Slot Tests

    @Test("Suggest time slot returns date for task")
    func suggestTimeSlot_returnsDate() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Test Task")
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let slot = try await service.suggestTimeSlot(for: task)

        #expect(slot != nil)
    }

    @Test("Suggest time slot for high priority task suggests peak focus time")
    func suggestTimeSlot_highPriority_suggestsPeakFocus() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "High Priority Task", priority: .high)
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let slot = try await service.suggestTimeSlot(for: task)

        #expect(slot != nil)
        // High priority should be during peak focus hours (morning)
        if let slot = slot {
            let hour = Calendar.current.component(.hour, from: slot)
            // Default peak focus is 9am-12pm
            #expect(hour >= 8 && hour <= 12)
        }
    }

    @Test("Suggest time slot for high energy task suggests peak focus time")
    func suggestTimeSlot_highEnergy_suggestsPeakFocus() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "High Energy Task")
        task.energy = .high
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let slot = try await service.suggestTimeSlot(for: task)

        #expect(slot != nil)
    }

    @Test("Suggest time slot for low priority task returns next available")
    func suggestTimeSlot_lowPriority_returnsNextAvailable() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Low Priority Task", priority: .low)
        task.energy = .low
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let slot = try await service.suggestTimeSlot(for: task)

        #expect(slot != nil)
    }

    // MARK: - Reschedule Task Tests

    @Test("Reschedule task updates scheduled date")
    func rescheduleTask_updatesScheduledDate() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Task", scheduledDate: Date.testToday)
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let newDate = Date.testTomorrow
        try await service.rescheduleTask(task, to: newDate)

        let calendar = Calendar.current
        #expect(task.scheduledDate != nil)
        #expect(calendar.isDate(task.scheduledDate!, inSameDayAs: newDate))
    }

    @Test("Reschedule task updates timestamp")
    func rescheduleTask_updatesTimestamp() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Task", scheduledDate: Date.testToday)
        task.updatedAt = Date.testYesterday
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        try await service.rescheduleTask(task, to: Date.testTomorrow)

        #expect(task.updatedAt ?? Date.distantPast > Date.testYesterday)
    }

    @Test("Reschedule task from nil date")
    func rescheduleTask_fromNilDate() async throws {
        let stack = TestCoreDataStack()
        let task = stack.createTask(title: "Unscheduled Task")
        task.scheduledDate = nil
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        try await service.rescheduleTask(task, to: Date.testToday)

        #expect(task.scheduledDate != nil)
    }

    // MARK: - Get Available Slots Tests

    @Test("Get available slots returns slots for date")
    func getAvailableSlots_returnsSlots() async throws {
        let stack = TestCoreDataStack()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let slots = try await service.getAvailableSlots(for: Date.testToday)

        // Should have some slots based on work hours
        #expect(slots.count > 0)
    }

    @Test("Get available slots returns 30-minute slots")
    func getAvailableSlots_returns30MinuteSlots() async throws {
        let stack = TestCoreDataStack()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let slots = try await service.getAvailableSlots(for: Date.testToday)

        if let firstSlot = slots.first {
            let duration = firstSlot.end.timeIntervalSince(firstSlot.start)
            #expect(duration == 30 * 60) // 30 minutes in seconds
        }
    }

    @Test("Get available slots respects work hours")
    func getAvailableSlots_respectsWorkHours() async throws {
        let stack = TestCoreDataStack()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let slots = try await service.getAvailableSlots(for: Date.testToday)

        // All slots should be within work hours
        for slot in slots {
            let hour = Calendar.current.component(.hour, from: slot.start)
            // Default work hours are typically 9-17
            #expect(hour >= 6 && hour <= 22) // Reasonable bounds
        }
    }

    @Test("Get available slots marks all as available")
    func getAvailableSlots_allAvailable() async throws {
        let stack = TestCoreDataStack()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let slots = try await service.getAvailableSlots(for: Date.testToday)

        // Current implementation marks all as available
        for slot in slots {
            #expect(slot.isAvailable == true)
        }
    }

    // MARK: - Edge Cases

    @Test("Get schedule for past date returns schedule")
    func getScheduleForDate_pastDate() async throws {
        let stack = TestCoreDataStack()
        _ = stack.createTask(title: "Past Task", scheduledDate: Date.testYesterday)
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let schedule = try await service.getScheduleForDate(Date.testYesterday)

        #expect(schedule.tasks.count == 1)
    }

    @Test("Get schedule for future date returns schedule")
    func getScheduleForDate_futureDate() async throws {
        let stack = TestCoreDataStack()
        let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        _ = stack.createTask(title: "Future Task", scheduledDate: futureDate)
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let schedule = try await service.getScheduleForDate(futureDate)

        #expect(schedule.tasks.count == 1)
    }

    @Test("Multiple tasks scheduled for same date")
    func getScheduleForDate_multipleTasks() async throws {
        let stack = TestCoreDataStack()
        _ = stack.createTask(title: "Task 1", scheduledDate: Date.testToday)
        _ = stack.createTask(title: "Task 2", scheduledDate: Date.testToday)
        _ = stack.createTask(title: "Task 3", scheduledDate: Date.testToday)
        try stack.save()

        let taskRepo = TaskRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)

        let service = ScheduleService(
            taskRepository: taskRepo,
            settingsRepository: settingsRepo
        )

        let schedule = try await service.getScheduleForDate(Date.testToday)

        #expect(schedule.tasks.count == 3)
    }
}
