import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("SettingsService Tests")
struct SettingsServiceTests {

    // MARK: - Get Settings Tests

    @Test("Get settings returns existing settings")
    func getSettings_returnsExisting() async throws {
        let stack = TestCoreDataStack()
        let settings = stack.createSettings()
        try stack.save()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        let result = try await service.getSettings()

        #expect(result.id == settings.id)
    }

    @Test("Get settings creates settings if none exist")
    func getSettings_createsIfNone() async throws {
        let stack = TestCoreDataStack()
        // Don't create any settings

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        let result = try await service.getSettings()

        #expect(result.id != nil)
    }

    @Test("Get settings returns same settings on multiple calls")
    func getSettings_multipleCalls_returnsSame() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        let first = try await service.getSettings()
        let second = try await service.getSettings()

        #expect(first.id == second.id)
    }

    // MARK: - Get Schedule Settings Tests

    @Test("Get schedule settings returns schedule portion")
    func getScheduleSettings_returnsSchedulePortion() async throws {
        let stack = TestCoreDataStack()
        _ = stack.createSettings()
        try stack.save()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        let scheduleSettings = try await service.getScheduleSettings()

        // Should have default values
        #expect(scheduleSettings.workHoursStart.isEmpty == false)
        #expect(scheduleSettings.workHoursEnd.isEmpty == false)
    }

    @Test("Get schedule settings has default peak focus hours")
    func getScheduleSettings_hasDefaultPeakFocus() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        let scheduleSettings = try await service.getScheduleSettings()

        // Default peak focus is 9am-12pm
        #expect(scheduleSettings.peakFocusStart.isEmpty == false)
        #expect(scheduleSettings.peakFocusEnd.isEmpty == false)
    }

    // MARK: - Get Task Settings Tests

    @Test("Get task settings returns task portion")
    func getTaskSettings_returnsTaskPortion() async throws {
        let stack = TestCoreDataStack()
        _ = stack.createSettings()
        try stack.save()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        let taskSettings = try await service.getTaskSettings()

        // Should have some default values
        #expect(taskSettings.defaultDuration > 0)
    }

    @Test("Get task settings has default duration")
    func getTaskSettings_hasDefaultDuration() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        let taskSettings = try await service.getTaskSettings()

        // Default duration is 30 minutes
        #expect(taskSettings.defaultDuration >= 15)
        #expect(taskSettings.defaultDuration <= 60)
    }

    // MARK: - Update Schedule Settings Tests

    @Test("Update schedule settings persists changes")
    func updateScheduleSettings_persistsChanges() async throws {
        let stack = TestCoreDataStack()
        _ = stack.createSettings()
        try stack.save()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        var newSchedule = ScheduleSettings()
        newSchedule.workHoursStart = "08:00"
        newSchedule.workHoursEnd = "18:00"

        try await service.updateScheduleSettings(newSchedule)

        let fetched = try await service.getScheduleSettings()
        #expect(fetched.workHoursStart == "08:00")
        #expect(fetched.workHoursEnd == "18:00")
    }

    @Test("Update schedule settings with different peak focus hours")
    func updateScheduleSettings_differentPeakFocus() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        var newSchedule = ScheduleSettings()
        newSchedule.peakFocusStart = "10:00"
        newSchedule.peakFocusEnd = "13:00"

        try await service.updateScheduleSettings(newSchedule)

        let fetched = try await service.getScheduleSettings()
        #expect(fetched.peakFocusStart == "10:00")
        #expect(fetched.peakFocusEnd == "13:00")
    }

    // MARK: - Update Task Settings Tests

    @Test("Update task settings persists changes")
    func updateTaskSettings_persistsChanges() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        var newTaskSettings = TaskSettings()
        newTaskSettings.defaultDuration = 45

        try await service.updateTaskSettings(newTaskSettings)

        let fetched = try await service.getTaskSettings()
        #expect(fetched.defaultDuration == 45)
    }

    @Test("Update task settings with break settings")
    func updateTaskSettings_breakSettings() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        var newTaskSettings = TaskSettings()
        newTaskSettings.breakAfterMinutes = 60
        newTaskSettings.shortBreakDuration = 10

        try await service.updateTaskSettings(newTaskSettings)

        let fetched = try await service.getTaskSettings()
        #expect(fetched.breakAfterMinutes == 60)
        #expect(fetched.shortBreakDuration == 10)
    }

    // MARK: - Update Display Settings Tests

    @Test("Update display settings persists changes")
    func updateDisplaySettings_persistsChanges() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        var newDisplaySettings = DisplaySettings()
        newDisplaySettings.theme = "dark"
        newDisplaySettings.compactMode = true

        try await service.updateDisplaySettings(newDisplaySettings)

        let settings = try await service.getSettings()
        #expect(settings.display.theme == "dark")
        #expect(settings.display.compactMode == true)
    }

    @Test("Update display settings with light theme")
    func updateDisplaySettings_lightTheme() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        var newDisplaySettings = DisplaySettings()
        newDisplaySettings.theme = "light"
        newDisplaySettings.showCompletedTasks = true

        try await service.updateDisplaySettings(newDisplaySettings)

        let settings = try await service.getSettings()
        #expect(settings.display.theme == "light")
        #expect(settings.display.showCompletedTasks == true)
    }

    // MARK: - Update Coaching Settings Tests

    @Test("Update coaching settings persists changes")
    func updateCoachingSettings_persistsChanges() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        var newCoachingSettings = CoachingSettings()
        newCoachingSettings.enabled = true
        newCoachingSettings.maxTurns = 15

        try await service.updateCoachingSettings(newCoachingSettings)

        let settings = try await service.getSettings()
        #expect(settings.coaching.enabled == true)
        #expect(settings.coaching.maxTurns == 15)
    }

    @Test("Update coaching settings with auto suggest disabled")
    func updateCoachingSettings_autoSuggestDisabled() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        var newCoachingSettings = CoachingSettings()
        newCoachingSettings.autoSuggestStrategies = false
        newCoachingSettings.showMotivationalMessages = false

        try await service.updateCoachingSettings(newCoachingSettings)

        let settings = try await service.getSettings()
        #expect(settings.coaching.autoSuggestStrategies == false)
        #expect(settings.coaching.showMotivationalMessages == false)
    }

    // MARK: - Edge Cases

    @Test("First launch creates default settings")
    func firstLaunch_createsDefaultSettings() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        // First access should create default settings
        let settings = try await service.getSettings()

        #expect(settings.id != nil)
        // Check that we can access sub-settings without crashing
        let _ = settings.schedule
        let _ = settings.tasks
        let _ = settings.display
        let _ = settings.coaching
    }

    @Test("Multiple updates preserve other settings")
    func multipleUpdates_preserveOtherSettings() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        // Update schedule
        var newSchedule = ScheduleSettings()
        newSchedule.workHoursStart = "07:00"
        newSchedule.workHoursEnd = "19:00"
        try await service.updateScheduleSettings(newSchedule)

        // Update tasks
        var newTaskSettings = TaskSettings()
        newTaskSettings.defaultDuration = 50
        try await service.updateTaskSettings(newTaskSettings)

        // Verify both are preserved
        let schedule = try await service.getScheduleSettings()
        let tasks = try await service.getTaskSettings()

        #expect(schedule.workHoursStart == "07:00")
        #expect(tasks.defaultDuration == 50)
    }

    @Test("Time estimate buffer applies correctly")
    func timeEstimateBuffer_appliesCorrectly() async throws {
        let stack = TestCoreDataStack()

        let settingsRepo = SettingsRepository(context: stack.context)
        let service = SettingsService(settingsRepository: settingsRepo)

        let taskSettings = try await service.getTaskSettings()

        // Test the ADHD buffer calculation
        // 5 min task -> 15 min (3x for tiny tasks)
        #expect(taskSettings.estimateWithBuffer(5) == 15)
        // 20 min task -> 30 min (1.5x)
        #expect(taskSettings.estimateWithBuffer(20) == 30)
        // 60 min task -> 120 min (2x)
        #expect(taskSettings.estimateWithBuffer(60) == 120)
    }
}
