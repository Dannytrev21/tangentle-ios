import Foundation
import CoreData

final class ProblemTypeRepository: BaseRepository<TGProblemType>, ProblemTypeRepositoryProtocol {

    func fetchAll() async throws -> [TGProblemType] {
        let sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return try await fetch(sortDescriptors: sortDescriptors)
    }

    func fetchByIdentifier(_ identifier: String) async throws -> TGProblemType? {
        let predicate = NSPredicate(format: "identifier == %@", identifier)
        return try await fetchOne(predicate: predicate)
    }

    func fetchDefaults() async throws -> [TGProblemType] {
        let predicate = NSPredicate(format: "isDefault == YES")
        let sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }
}
