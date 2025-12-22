import Foundation
import CoreData

final class StrategyRepository: BaseRepository<TGStrategy>, StrategyRepositoryProtocol {

    override func fetchActive() async throws -> [TGStrategy] {
        let predicate = NSPredicate(format: "isActive == YES")
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchByProblemType(_ type: String) async throws -> [TGStrategy] {
        // Transformable array search requires fetching all and filtering
        let active = try await fetchActive()
        return active.filter { strategy in
            strategy.problemTypesArray.contains(type)
        }
    }

    func fetchTopRated(limit: Int) async throws -> [TGStrategy] {
        let active = try await fetchActive()
        return Array(active.sorted { $0.score > $1.score }.prefix(limit))
    }

    func fetchBySource(_ source: String) async throws -> [TGStrategy] {
        let predicate = NSPredicate(format: "source == %@", source)
        return try await fetch(predicate: predicate)
    }

    func fetchForCoaching(problemType: String, limit: Int = 5) async throws -> [TGStrategy] {
        let strategies = try await fetchByProblemType(problemType)
        return Array(strategies.sorted { $0.score > $1.score }.prefix(limit))
    }

    func fetchDefaults() async throws -> [TGStrategy] {
        return try await fetchBySource("default")
    }

    func fetchUserCreated() async throws -> [TGStrategy] {
        return try await fetchBySource("user")
    }
}
