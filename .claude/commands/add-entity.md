# Add Entity Command

Add a new Core Data entity to the Tangentle data model.

## Input
Entity description: $ARGUMENTS

## Process

### Step 1: Parse Entity Request
Extract from the description:
- Entity name (will be prefixed with TG)
- Attributes and types
- Relationships to other entities
- Optional: Default values

### Step 2: Verify Data Model Exists
```bash
ls Tangentle/Tangentle/Data/Tangentle.xcdatamodeld
```

If not found, inform user the Core Data model hasn't been created yet.

### Step 3: Document the Entity
Create a specification showing:

```
═══════════════════════════════════════════════════════════════
  NEW ENTITY: TG{EntityName}
═══════════════════════════════════════════════════════════════

## Attributes
| Name | Type | Optional | Default | Notes |
|------|------|----------|---------|-------|
| id | UUID | No | - | Primary identifier |
| {attr} | {type} | {yes/no} | {default} | {notes} |
| createdAt | Date | No | - | Creation timestamp |
| updatedAt | Date | No | - | Last update |

## Relationships
| Name | Destination | Type | Delete Rule | Inverse |
|------|-------------|------|-------------|---------|
| {rel} | TG{Entity} | {to-one/to-many} | {rule} | {inverse} |

## CloudKit Compatibility
- [x] Uses UUID for identifier
- [x] Has createdAt/updatedAt
- [x] No unique constraints
```

### Step 4: Create Extension File
Generate `Tangentle/Core/Models/TG{Entity}+Extensions.swift`:

```swift
import Foundation
import CoreData

extension TG{Entity} {
    // Computed properties

    // Convenience initializer
    convenience init(context: NSManagedObjectContext, name: String) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Helper methods
}
```

### Step 5: Create Repository
Generate `Tangentle/Core/Repositories/{Entity}Repository.swift`:

```swift
import CoreData

protocol {Entity}RepositoryProtocol: Repository where Entity == TG{Entity} {
    // Entity-specific queries
}

final class {Entity}Repository: BaseRepository<TG{Entity}>, {Entity}RepositoryProtocol {
    // Implementation
}
```

### Step 6: Output Instructions
```
## Manual Steps Required

1. **Add entity to Tangentle.xcdatamodeld**
   - Open Xcode
   - Add new entity named "TG{Entity}"
   - Add attributes from spec above
   - Configure relationships
   - Set class name to "TG{Entity}"
   - Set module to "Current Product Module"

2. **Add to DI Container**
   Update `Core/DI/AppContainer.swift`:
   ```swift
   private lazy var _{entity}Repository: {Entity}Repository = {
       {Entity}Repository(context: viewContext)
   }()
   var {entity}Repository: {Entity}RepositoryProtocol { _{entity}Repository }
   ```

3. **Build and verify**
   `/build`
```

## Examples
- `/add-entity Note with title, content, and link to Task`
- `/add-entity Reminder with time, message, and recurring flag`
