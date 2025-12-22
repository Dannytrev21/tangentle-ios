# Step 5: Repository Protocol

## Context
The repository pattern abstracts data access, enabling testability and flexibility. We define a generic protocol and base implementation that all entity-specific repositories will inherit from. This is the foundation of our clean data layer.

## Goal
Create a generic repository protocol and base Core Data implementation that handles common CRUD operations.

## Prerequisites
- Step 3 completed (Core Data model exists)
- Step 4 completed (Model extensions exist)

## High-Level Steps
1. Create generic Repository protocol
2. Create CoreDataRepository base implementation
3. Create Persistence controller for Core Data stack
4. Add error types for repository operations

## Detailed Requirements

### Repository Protocol
Create `Core/Repositories/Repository.swift`:

```swift
import Foundation
import CoreData

/// Errors that can occur during repository operations
enum RepositoryError: Error, LocalizedError {
    case notFound
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "Entity not found"
        case .saveFailed(let error):
            return "Save failed: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Fetch failed: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Delete failed: \(error.localizedDescription)"
        case .invalidData(let reason):
            return "Invalid data: \(reason)"
        }
    }
}

/// Generic repository protocol for data access
protocol Repository {
    associatedtype Entity: NSManagedObject

    /// The managed object context
    var context: NSManagedObjectContext { get }

    /// Fetch all entities
    func fetchAll() async throws -> [Entity]

    /// Fetch entities matching predicate
    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [Entity]

    /// Fetch single entity by ID
    func fetchById(_ id: UUID) async throws -> Entity?

    /// Create new entity
    func create() -> Entity

    /// Save changes
    func save() async throws

    /// Delete entity
    func delete(_ entity: Entity) async throws

    /// Delete all entities
    func deleteAll() async throws

    /// Count entities
    func count(predicate: NSPredicate?) async throws -> Int
}

/// Default implementations
extension Repository {
    func fetchAll() async throws -> [Entity] {
        try await fetch(predicate: nil, sortDescriptors: nil)
    }

    func fetch(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [Entity] {
        try await context.perform {
            let request = Entity.fetchRequest()
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors

            do {
                let results = try context.fetch(request)
                return results as? [Entity] ?? []
            } catch {
                throw RepositoryError.fetchFailed(error)
            }
        }
    }

    func fetchById(_ id: UUID) async throws -> Entity? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let results = try await fetch(predicate: predicate, sortDescriptors: nil)
        return results.first
    }

    func create() -> Entity {
        Entity(context: context)
    }

    func save() async throws {
        guard context.hasChanges else { return }

        try await context.perform {
            do {
                try self.context.save()
            } catch {
                throw RepositoryError.saveFailed(error)
            }
        }
    }

    func delete(_ entity: Entity) async throws {
        try await context.perform {
            self.context.delete(entity)
            do {
                try self.context.save()
            } catch {
                throw RepositoryError.deleteFailed(error)
            }
        }
    }

    func deleteAll() async throws {
        let entities = try await fetchAll()
        try await context.perform {
            for entity in entities {
                self.context.delete(entity)
            }
            do {
                try self.context.save()
            } catch {
                throw RepositoryError.deleteFailed(error)
            }
        }
    }

    func count(predicate: NSPredicate? = nil) async throws -> Int {
        try await context.perform {
            let request = Entity.fetchRequest()
            request.predicate = predicate

            do {
                return try self.context.count(for: request)
            } catch {
                throw RepositoryError.fetchFailed(error)
            }
        }
    }
}
```

### Persistence Controller
Create `Data/Persistence.swift`:

```swift
import CoreData

/// Core Data stack manager
final class PersistenceController {
    static let shared = PersistenceController()

    /// For SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Add sample data for previews
        return controller
    }()

    let container: NSPersistentContainer

    /// Main context for UI operations
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    /// Background context for heavy operations
    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Tangentle")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                // In production, handle this more gracefully
                fatalError("Core Data store failed: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    /// Save context if there are changes
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Log error in production
                print("Save error: \(error)")
            }
        }
    }
}
```

### Base Repository Class
Create `Core/Repositories/BaseRepository.swift`:

```swift
import CoreData

/// Base class for entity-specific repositories
class BaseRepository<Entity: NSManagedObject>: Repository {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }
}
```

## Files to Create
- `Tangentle/Core/Repositories/Repository.swift` - Protocol and default implementations
- `Tangentle/Core/Repositories/BaseRepository.swift` - Base class
- `Tangentle/Data/Persistence.swift` - Core Data stack

## Files to Modify
- None

## Patterns to Follow
- Use async/await for all data operations
- Perform Core Data work in context.perform blocks
- Provide sensible default implementations
- Use generics for type safety

## Acceptance Criteria
- [ ] Repository protocol defined with all CRUD methods
- [ ] Default implementations compile and work
- [ ] PersistenceController initializes Core Data stack
- [ ] In-memory option works for testing
- [ ] Project builds without warnings

## Verification Commands
```bash
# Build to verify protocols compile
cd tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Check files exist
ls -la tangentle-ios/Tangentle/Tangentle/Core/Repositories/
ls -la tangentle-ios/Tangentle/Tangentle/Data/Persistence.swift
```

## Documentation Updates
- [ ] Update docs/ARCHITECTURE.md with repository pattern details

## Error Recovery
If protocol doesn't compile:
1. Check Entity constraint matches NSManagedObject
2. Verify async/await syntax is correct for Swift 5.9
3. Ensure context.perform closures are properly structured

## Do NOT
- Use synchronous Core Data operations
- Forget context.perform for thread safety
- Access context from wrong thread
- Create multiple PersistenceController instances
