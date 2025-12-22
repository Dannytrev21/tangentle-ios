import Foundation
import CoreData

final class SettingsRepository: BaseRepository<TGSettings>, SettingsRepositoryProtocol {

    func getSettings() async throws -> TGSettings {
        let all = try await fetch()
        if let existing = all.first {
            return existing
        }

        // Create default settings if none exist
        let settings = create()
        settings.id = UUID()
        settings.schedule = .default
        settings.tasks = .default
        settings.display = .default
        settings.coaching = .default
        settings.updatedAt = Date()
        try await save()
        return settings
    }

    func updateSettings(_ update: (TGSettings) -> Void) async throws {
        let settings = try await getSettings()
        update(settings)
        settings.updatedAt = Date()
        try await save()
    }
}
