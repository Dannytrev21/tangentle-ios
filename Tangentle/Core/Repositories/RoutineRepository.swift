import Foundation
import CoreData

final class RoutineRepository: BaseRepository<TGRoutine>, RoutineRepositoryProtocol {

    func fetchEnabled() async throws -> [TGRoutine] {
        let predicate = NSPredicate(format: "isEnabled == YES")
        let sortDescriptors = [NSSortDescriptor(key: "scheduledTime", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchByType(_ type: RoutineType) async throws -> [TGRoutine] {
        let predicate = NSPredicate(format: "routineType == %@", type.rawValue)
        let sortDescriptors = [NSSortDescriptor(key: "scheduledTime", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchScheduledForToday() async throws -> [TGRoutine] {
        let today = Calendar.current.component(.weekday, from: Date())

        let enabled = try await fetchEnabled()
        return enabled.filter { routine in
            routine.daysOfWeekArray.contains { $0.rawValue == today }
        }
    }
}
