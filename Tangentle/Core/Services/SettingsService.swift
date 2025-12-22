import Foundation

/// Service for managing user settings
final class SettingsService: SettingsServiceProtocol {
    private let settingsRepository: SettingsRepositoryProtocol

    init(settingsRepository: SettingsRepositoryProtocol) {
        self.settingsRepository = settingsRepository
    }

    // MARK: - Get Settings

    func getSettings() async throws -> TGSettings {
        try await settingsRepository.getSettings()
    }

    func getScheduleSettings() async throws -> ScheduleSettings {
        let settings = try await settingsRepository.getSettings()
        return settings.schedule
    }

    func getTaskSettings() async throws -> TaskSettings {
        let settings = try await settingsRepository.getSettings()
        return settings.tasks
    }

    // MARK: - Update Settings

    func updateScheduleSettings(_ newSettings: ScheduleSettings) async throws {
        try await settingsRepository.updateSettings { settings in
            settings.schedule = newSettings
        }
    }

    func updateTaskSettings(_ newSettings: TaskSettings) async throws {
        try await settingsRepository.updateSettings { settings in
            settings.tasks = newSettings
        }
    }

    func updateDisplaySettings(_ newSettings: DisplaySettings) async throws {
        try await settingsRepository.updateSettings { settings in
            settings.display = newSettings
        }
    }

    func updateCoachingSettings(_ newSettings: CoachingSettings) async throws {
        try await settingsRepository.updateSettings { settings in
            settings.coaching = newSettings
        }
    }
}
