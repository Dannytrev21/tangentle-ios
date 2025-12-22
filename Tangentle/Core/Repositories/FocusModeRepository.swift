import Foundation
import CoreData

final class FocusModeRepository: BaseRepository<TGFocusMode>, FocusModeRepositoryProtocol {

    override func fetchActive() async throws -> [TGFocusMode] {
        let predicate = NSPredicate(format: "isActive == YES")
        let sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchAutomatic() async throws -> [TGFocusMode] {
        let predicate = NSPredicate(format: "isActive == YES AND isAutomatic == YES")
        let sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchCurrentlyActive() async throws -> TGFocusMode? {
        let automatic = try await fetchAutomatic()
        let now = Date()
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: now)

        for focusMode in automatic {
            // Check if today is an active day
            guard focusMode.daysOfWeekArray.contains(where: { $0.rawValue == currentWeekday }) else {
                continue
            }

            // Check if current time is within the mode's schedule
            if focusMode.isActiveNow {
                return focusMode
            }
        }

        return nil
    }
}
