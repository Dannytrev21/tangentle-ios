import Foundation
import CoreData

/// Generic repository protocol for CRUD operations
protocol Repository {
    associatedtype Entity: NSManagedObject

    var context: NSManagedObjectContext { get }

    // MARK: - Create
    func create() -> Entity

    // MARK: - Read
    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [Entity]
    func fetchOne(predicate: NSPredicate) async throws -> Entity?
    func fetchById(_ id: UUID) async throws -> Entity?
    func count(predicate: NSPredicate?) async throws -> Int

    // MARK: - Update
    func save() async throws

    // MARK: - Delete
    func delete(_ entity: Entity) async throws
    func deleteAll(predicate: NSPredicate?) async throws
}

// MARK: - Default Implementations

extension Repository {
    func fetch(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) async throws -> [Entity] {
        try await context.perform {
            let request = Entity.fetchRequest()
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            return try self.context.fetch(request) as? [Entity] ?? []
        }
    }

    func fetchOne(predicate: NSPredicate) async throws -> Entity? {
        try await context.perform {
            let request = Entity.fetchRequest()
            request.predicate = predicate
            request.fetchLimit = 1
            return (try self.context.fetch(request) as? [Entity])?.first
        }
    }

    func fetchById(_ id: UUID) async throws -> Entity? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        return try await fetchOne(predicate: predicate)
    }

    func count(predicate: NSPredicate? = nil) async throws -> Int {
        try await context.perform {
            let request = Entity.fetchRequest()
            request.predicate = predicate
            return try self.context.count(for: request)
        }
    }

    func save() async throws {
        try await context.perform {
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    func delete(_ entity: Entity) async throws {
        try await context.perform {
            self.context.delete(entity)
            try self.context.save()
        }
    }

    func deleteAll(predicate: NSPredicate? = nil) async throws {
        let entities = try await fetch(predicate: predicate)
        try await context.perform {
            for entity in entities {
                self.context.delete(entity)
            }
            try self.context.save()
        }
    }
}

// MARK: - Fetch Request Helpers

extension Repository {
    func makeFetchRequest() -> NSFetchRequest<Entity> {
        Entity.fetchRequest() as! NSFetchRequest<Entity>
    }

    func makePredicate(_ format: String, _ args: CVarArg...) -> NSPredicate {
        NSPredicate(format: format, arguments: getVaList(args))
    }

    func makeSortDescriptor(
        _ key: String,
        ascending: Bool = true
    ) -> NSSortDescriptor {
        NSSortDescriptor(key: key, ascending: ascending)
    }
}
