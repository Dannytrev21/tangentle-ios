import Foundation

/// Service for managing task scheduling and time slots
final class ScheduleService: ScheduleServiceProtocol {
    private let taskRepository: TaskRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    init(
        taskRepository: TaskRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.taskRepository = taskRepository
        self.settingsRepository = settingsRepository
    }

    // MARK: - Schedule Fetching

    func getScheduleForDate(_ date: Date) async throws -> DaySchedule {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let tasks = try await taskRepository.fetchScheduledBetween(
            start: startOfDay,
            end: endOfDay
        )

        return DaySchedule(date: date, tasks: tasks, focusMode: nil)
    }

    // MARK: - Time Slot Suggestions

    func suggestTimeSlot(for task: TGTask) async throws -> Date? {
        let settings = try await settingsRepository.getSettings()
        let scheduleSettings = settings.schedule

        // Parse work hours
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let peakStart = formatter.date(from: scheduleSettings.peakFocusStart),
              let peakEnd = formatter.date(from: scheduleSettings.peakFocusEnd) else {
            return nil
        }

        let calendar = Calendar.current
        let today = Date()

        // High priority/energy tasks → peak focus window
        if task.taskPriority == .high || task.energy == .high {
            var components = calendar.dateComponents([.year, .month, .day], from: today)
            let peakComponents = calendar.dateComponents([.hour, .minute], from: peakStart)
            components.hour = peakComponents.hour
            components.minute = peakComponents.minute
            return calendar.date(from: components)
        }

        // Default to next available slot
        return calendar.date(byAdding: .hour, value: 1, to: today)
    }

    // MARK: - Rescheduling

    func rescheduleTask(_ task: TGTask, to date: Date) async throws {
        task.scheduledDate = date
        task.updatedAt = Date()
        try await taskRepository.save()
    }

    // MARK: - Available Slots

    func getAvailableSlots(for date: Date) async throws -> [TimeSlot] {
        let settings = try await settingsRepository.getSettings()
        let scheduleSettings = settings.schedule

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard let workStart = formatter.date(from: scheduleSettings.workHoursStart),
              let workEnd = formatter.date(from: scheduleSettings.workHoursEnd) else {
            return []
        }

        // Generate 30-minute slots
        var slots: [TimeSlot] = []
        var current = calendar.date(
            bySettingHour: calendar.component(.hour, from: workStart),
            minute: calendar.component(.minute, from: workStart),
            second: 0,
            of: startOfDay
        )!

        let endTime = calendar.date(
            bySettingHour: calendar.component(.hour, from: workEnd),
            minute: calendar.component(.minute, from: workEnd),
            second: 0,
            of: startOfDay
        )!

        while current < endTime {
            let slotEnd = calendar.date(byAdding: .minute, value: 30, to: current)!
            slots.append(TimeSlot(start: current, end: slotEnd, isAvailable: true))
            current = slotEnd
        }

        return slots
    }
}
