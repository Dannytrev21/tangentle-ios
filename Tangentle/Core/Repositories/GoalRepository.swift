import Foundation
import CoreData

final class GoalRepository: BaseRepository<TGGoal>, GoalRepositoryProtocol {

    override func fetchActive() async throws -> [TGGoal] {
        let predicate = NSPredicate(format: "isActive == YES")
        let sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchWithUpcomingDeadlines(within days: Int) async throws -> [TGGoal] {
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: now)!

        let predicate = NSPredicate(
            format: "isActive == YES AND targetDate != nil AND targetDate >= %@ AND targetDate <= %@",
            now as NSDate,
            futureDate as NSDate
        )

        let sortDescriptors = [NSSortDescriptor(key: "targetDate", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }
}
