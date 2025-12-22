import Foundation
import CoreData

final class HabitRepository: BaseRepository<TGHabit>, HabitRepositoryProtocol {

    override func fetchActive() async throws -> [TGHabit] {
        let predicate = NSPredicate(format: "isActive == YES")
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchDueToday() async throws -> [TGHabit] {
        let active = try await fetchActive()
        return active.filter { !$0.isCompletedToday }
    }

    func fetchByFrequency(_ frequency: HabitFrequency) async throws -> [TGHabit] {
        let predicate = NSPredicate(
            format: "isActive == YES AND frequency == %@",
            frequency.rawValue
        )
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }
}
