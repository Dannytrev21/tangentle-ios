import Foundation
import CoreData

/// Base repository implementation with common functionality
class BaseRepository<Entity: NSManagedObject>: Repository {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func create() -> Entity {
        Entity(context: context)
    }

    // MARK: - Batch Operations

    func fetchAll(sortedBy key: String? = nil, ascending: Bool = true) async throws -> [Entity] {
        var sortDescriptors: [NSSortDescriptor]?
        if let key = key {
            sortDescriptors = [NSSortDescriptor(key: key, ascending: ascending)]
        }
        return try await fetch(sortDescriptors: sortDescriptors)
    }

    func fetchActive() async throws -> [Entity] {
        let predicate = NSPredicate(format: "isActive == YES")
        return try await fetch(predicate: predicate)
    }

    // MARK: - Transaction Support

    func performTransaction(_ block: @escaping () throws -> Void) async throws {
        try await context.perform {
            try block()
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    // MARK: - Background Operations

    func performInBackground<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            let backgroundContext = PersistenceController.shared.newBackgroundContext()
            backgroundContext.perform {
                do {
                    let result = try block(backgroundContext)
                    if backgroundContext.hasChanges {
                        try backgroundContext.save()
                    }
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: - Refresh

    func refresh(_ entity: Entity) {
        context.refresh(entity, mergeChanges: true)
    }

    func refreshAll() {
        context.refreshAllObjects()
    }
}

// MARK: - Repository Errors

enum RepositoryError: LocalizedError {
    case notFound
    case contextUnavailable
    case saveFailed(underlying: Error)
    case fetchFailed(underlying: Error)
    case invalidData(message: String)

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Entity not found"
        case .contextUnavailable:
            return "Core Data context unavailable"
        case .saveFailed(let error):
            return "Save failed: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Fetch failed: \(error.localizedDescription)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        }
    }
}
