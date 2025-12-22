import Foundation
import CoreData

final class StrategyOutcomeRepository: BaseRepository<TGStrategyOutcome>, StrategyOutcomeRepositoryProtocol {

    func fetchByStrategy(_ strategy: TGStrategy) async throws -> [TGStrategyOutcome] {
        let predicate = NSPredicate(format: "strategy == %@", strategy)
        let sortDescriptors = [NSSortDescriptor(key: "usedAt", ascending: false)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchRecent(limit: Int) async throws -> [TGStrategyOutcome] {
        let sortDescriptors = [NSSortDescriptor(key: "usedAt", ascending: false)]
        let all = try await fetch(sortDescriptors: sortDescriptors)
        return Array(all.prefix(limit))
    }
}
