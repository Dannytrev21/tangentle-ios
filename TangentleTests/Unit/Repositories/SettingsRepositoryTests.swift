import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("SettingsRepository Tests")
struct SettingsRepositoryTests {

    // MARK: - Get Settings Tests

    @Test("Get settings returns existing settings")
    func getSettings_returnsExisting() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        let existing = stack.createSettings()

        try stack.save()

        let fetched = try await repo.getSettings()

        #expect(fetched.id == existing.id)
    }

    @Test("Get settings creates settings if none exist")
    func getSettings_createsIfNone() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        // Don't create any settings

        let settings = try await repo.getSettings()

        #expect(settings != nil)
        #expect(settings.id != nil)
    }

    @Test("Get settings has default values when created")
    func getSettings_hasDefaultValues() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        let settings = try await repo.getSettings()

        // Check default settings structs are populated
        #expect(settings.schedule != nil)
        #expect(settings.tasks != nil)
        #expect(settings.display != nil)
        #expect(settings.coaching != nil)
    }

    @Test("Multiple calls to get settings return same entity")
    func getSettings_multipleCalls_returnsSame() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        let first = try await repo.getSettings()
        let second = try await repo.getSettings()

        #expect(first.id == second.id)
    }

    @Test("Get settings returns only one even if multiple exist")
    func getSettings_multipleExist_returnsOne() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        // Create multiple settings (shouldn't happen in practice)
        _ = stack.createSettings()
        _ = stack.createSettings()

        try stack.save()

        let settings = try await repo.getSettings()

        // Should still return settings without crashing
        #expect(settings != nil)
    }

    // MARK: - Update Settings Tests

    @Test("Update settings persists changes")
    func updateSettings_persistsChanges() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        // Get initial settings
        let initial = try await repo.getSettings()
        let initialUpdatedAt = initial.updatedAt

        // Wait a tiny bit to ensure different timestamp
        try await Task.sleep(nanoseconds: 10_000_000) // 10ms

        // Update settings
        try await repo.updateSettings { settings in
            // Modify some settings
            settings.schedule = ScheduleSettings.default
        }

        // Fetch again
        let updated = try await repo.getSettings()

        // updatedAt should be newer
        #expect(updated.updatedAt ?? Date.distantPast > initialUpdatedAt ?? Date.distantFuture)
    }

    @Test("Update settings updates timestamp")
    func updateSettings_updatesTimestamp() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        let settings = stack.createSettings()
        let originalTimestamp = Date.testYesterday
        settings.updatedAt = originalTimestamp

        try stack.save()

        try await repo.updateSettings { _ in
            // No-op, just trigger update
        }

        let fetched = try await repo.getSettings()

        #expect(fetched.updatedAt ?? Date.distantPast > originalTimestamp)
    }

    @Test("Update settings creates settings if none exist")
    func updateSettings_createsIfNone() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        // Don't create any settings, just update
        try await repo.updateSettings { settings in
            // Update triggers creation
        }

        let settings = try await repo.getSettings()

        #expect(settings != nil)
    }

    // MARK: - Settings Properties Tests

    @Test("Settings schedule property works")
    func settings_scheduleProperty() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        let settings = try await repo.getSettings()

        // Should have default schedule settings
        let schedule = settings.schedule
        #expect(schedule != nil)
    }

    @Test("Settings tasks property works")
    func settings_tasksProperty() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        let settings = try await repo.getSettings()

        // Should have default task settings
        let tasks = settings.tasks
        #expect(tasks != nil)
    }

    @Test("Settings display property works")
    func settings_displayProperty() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        let settings = try await repo.getSettings()

        // Should have default display settings
        let display = settings.display
        #expect(display != nil)
    }

    @Test("Settings coaching property works")
    func settings_coachingProperty() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        let settings = try await repo.getSettings()

        // Should have default coaching settings
        let coaching = settings.coaching
        #expect(coaching != nil)
    }

    // MARK: - Edge Cases

    @Test("First launch creates settings")
    func getSettings_firstLaunch_createsSettings() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        // Simulate first launch - no settings exist

        let settings = try await repo.getSettings()

        #expect(settings != nil)
        #expect(settings.id != nil)
    }

    @Test("Settings singleton behavior")
    func getSettings_singletonBehavior() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        // Get settings multiple times
        let first = try await repo.getSettings()
        let second = try await repo.getSettings()
        let third = try await repo.getSettings()

        // All should be the same instance
        #expect(first.id == second.id)
        #expect(second.id == third.id)
    }

    @Test("Update settings multiple times")
    func updateSettings_multipleTimes() async throws {
        let stack = TestCoreDataStack()
        let repo = SettingsRepository(context: stack.context)

        let settings = try await repo.getSettings()
        let settingsId = settings.id

        // Multiple updates
        try await repo.updateSettings { _ in }
        try await repo.updateSettings { _ in }
        try await repo.updateSettings { _ in }

        // Should still be same settings
        let fetched = try await repo.getSettings()
        #expect(fetched.id == settingsId)
    }
}
