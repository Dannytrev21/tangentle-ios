import Foundation
import CoreData

final class TagRepository: BaseRepository<TGTag>, TagRepositoryProtocol {

    func fetchAll() async throws -> [TGTag] {
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return try await fetch(sortDescriptors: sortDescriptors)
    }

    func fetchOrCreate(name: String) async throws -> TGTag {
        let predicate = NSPredicate(format: "name ==[c] %@", name)
        if let existing = try await fetchOne(predicate: predicate) {
            return existing
        }

        let tag = create()
        tag.id = UUID()
        tag.name = name
        tag.sortOrder = 0
        try await save()
        return tag
    }

    func fetchByName(_ name: String) async throws -> TGTag? {
        let predicate = NSPredicate(format: "name ==[c] %@", name)
        return try await fetchOne(predicate: predicate)
    }
}
