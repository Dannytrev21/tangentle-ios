import Foundation
import CoreData

final class HabitCompletionRepository: BaseRepository<TGHabitCompletion>, HabitCompletionRepositoryProtocol {

    func fetchByHabit(_ habit: TGHabit) async throws -> [TGHabitCompletion] {
        let predicate = NSPredicate(format: "habit == %@", habit)
        let sortDescriptors = [NSSortDescriptor(key: "completedAt", ascending: false)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchForDate(_ date: Date, habit: TGHabit) async throws -> [TGHabitCompletion] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = NSPredicate(
            format: "habit == %@ AND completedAt >= %@ AND completedAt < %@",
            habit,
            startOfDay as NSDate,
            endOfDay as NSDate
        )

        return try await fetch(predicate: predicate)
    }
}
