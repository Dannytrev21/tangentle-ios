import Foundation
import CoreData

final class ModeRepository: BaseRepository<TGMode>, ModeRepositoryProtocol {

    func fetchDefault() async throws -> TGMode? {
        let predicate = NSPredicate(format: "isDefault == YES")
        return try await fetchOne(predicate: predicate)
    }

    func fetchAll() async throws -> [TGMode] {
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try await fetch(sortDescriptors: sortDescriptors)
    }
}
