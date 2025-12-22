# Step 4: Model Extensions

## Context
Core Data generates NSManagedObject subclasses, but we need Swift-friendly extensions with computed properties, convenience initializers, and type-safe enums. This step creates the bridge between Core Data's Objective-C heritage and modern Swift patterns.

## Goal
Create Swift extensions for all Core Data entities that provide type-safe access, convenience methods, and enum-based status/type properties.

## Prerequisites
- Step 3 completed (Core Data model exists)

## High-Level Steps
1. Create enum definitions for status types
2. Create extensions for each entity with computed properties
3. Add convenience initializers
4. Add helper methods for common operations

## Detailed Requirements

### Enum Definitions
Create in `Core/Models/Enums.swift`:

```swift
enum TaskStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case inProgress = "in_progress"
    case waitingFor = "waiting_for"
    case completed = "completed"
    case deferred = "deferred"
    case delegated = "delegated"
    case deleted = "deleted"
}

enum EnergyLevel: String, CaseIterable, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
}

enum StrategyResult: String, CaseIterable, Codable {
    case success = "success"
    case partial = "partial"
    case failure = "failure"
}

enum HabitFrequency: String, CaseIterable, Codable {
    case daily = "daily"
    case weekly = "weekly"
}

enum RoutineType: String, CaseIterable, Codable {
    case morning = "morning"
    case evening = "evening"
    case focusBlock = "focus_block"
    case lowEnergy = "low_energy"
    case custom = "custom"
}

enum StrategySource: String, CaseIterable, Codable {
    case user = "user"
    case `default` = "default"
}
```

### TGTask Extension
Create in `Core/Models/TGTask+Extensions.swift`:

```swift
extension TGTask {
    var statusEnum: TaskStatus {
        get { TaskStatus(rawValue: status ?? "pending") ?? .pending }
        set { status = newValue.rawValue }
    }

    var energyEnum: EnergyLevel {
        get { EnergyLevel(rawValue: energyRequired ?? "medium") ?? .medium }
        set { energyRequired = newValue.rawValue }
    }

    var isCompleted: Bool { statusEnum == .completed }
    var isPending: Bool { statusEnum == .pending }
    var isOverdue: Bool {
        guard let due = dueDate else { return false }
        return due < Date() && !isCompleted
    }

    var subtasksArray: [TGTask] {
        (subtasks?.allObjects as? [TGTask]) ?? []
    }

    var tagsArray: [TGTag] {
        (tags?.allObjects as? [TGTag]) ?? []
    }

    var blockedByArray: [TGTask] {
        (blockedBy?.allObjects as? [TGTask]) ?? []
    }

    var isBlocked: Bool {
        blockedByArray.contains { !$0.isCompleted }
    }

    convenience init(context: NSManagedObjectContext, title: String) {
        self.init(context: context)
        self.id = UUID()
        self.title = title
        self.status = TaskStatus.pending.rawValue
        self.priority = 0
        self.estimatedDuration = 30
        self.energyRequired = EnergyLevel.medium.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
        self.sortOrder = 0
    }

    func markCompleted() {
        statusEnum = .completed
        completedAt = Date()
        updatedAt = Date()
    }
}
```

### Similar Extensions for Other Entities
Each entity should have:
1. Enum-typed computed properties for string fields
2. Array accessors for to-many relationships
3. Convenience initializer with required fields
4. Helper methods for common operations
5. `updatedAt` auto-update in modifying methods

### Settings JSON Helpers
Create `Core/Models/TGSettings+Extensions.swift`:

```swift
extension TGSettings {
    struct ScheduleConfig: Codable {
        var workDays: [String]
        var workHoursStart: String
        var workHoursEnd: String
        var peakFocusStart: String
        var peakFocusEnd: String
        var lowEnergyStart: String
        var lowEnergyEnd: String
        var medicationTime: String
        var medicationKickIn: String

        static var `default`: ScheduleConfig {
            ScheduleConfig(
                workDays: ["monday", "tuesday", "wednesday", "thursday", "friday"],
                workHoursStart: "09:00",
                workHoursEnd: "17:00",
                peakFocusStart: "09:00",
                peakFocusEnd: "12:00",
                lowEnergyStart: "14:00",
                lowEnergyEnd: "16:00",
                medicationTime: "06:00",
                medicationKickIn: "07:00"
            )
        }
    }

    var schedule: ScheduleConfig {
        get {
            guard let data = scheduleSettings else { return .default }
            return (try? JSONDecoder().decode(ScheduleConfig.self, from: data)) ?? .default
        }
        set {
            scheduleSettings = try? JSONEncoder().encode(newValue)
            updatedAt = Date()
        }
    }

    // Similar for taskSettings, displaySettings, coachingSettings
}
```

## Files to Create
- `Tangentle/Core/Models/Enums.swift`
- `Tangentle/Core/Models/TGTask+Extensions.swift`
- `Tangentle/Core/Models/TGProject+Extensions.swift`
- `Tangentle/Core/Models/TGGoal+Extensions.swift`
- `Tangentle/Core/Models/TGStrategy+Extensions.swift`
- `Tangentle/Core/Models/TGStrategyOutcome+Extensions.swift`
- `Tangentle/Core/Models/TGRoutine+Extensions.swift`
- `Tangentle/Core/Models/TGRoutineStep+Extensions.swift`
- `Tangentle/Core/Models/TGHabit+Extensions.swift`
- `Tangentle/Core/Models/TGHabitCompletion+Extensions.swift`
- `Tangentle/Core/Models/TGFocusMode+Extensions.swift`
- `Tangentle/Core/Models/TGMode+Extensions.swift`
- `Tangentle/Core/Models/TGProblemType+Extensions.swift`
- `Tangentle/Core/Models/TGTag+Extensions.swift`
- `Tangentle/Core/Models/TGSettings+Extensions.swift`

## Files to Modify
- None

## Patterns to Follow
- Use computed properties for enum conversions
- Always update `updatedAt` when modifying
- Provide array accessors for NSSet relationships
- Include default values in convenience initializers

## Acceptance Criteria
- [ ] All enum types defined and compile
- [ ] Each entity has extension file
- [ ] Computed properties provide type-safe access
- [ ] Convenience initializers work correctly
- [ ] Project builds without warnings
- [ ] Extensions are testable

## Verification Commands
```bash
# Build to verify extensions compile
cd tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Check all extension files exist
ls -la tangentle-ios/Tangentle/Tangentle/Core/Models/
```

## Documentation Updates
- [ ] Update docs/DATA-MODEL.md with enum definitions

## Error Recovery
If extensions don't compile:
1. Verify Core Data model was generated correctly
2. Check entity names match exactly (TGTask not Task)
3. Ensure model class names are correct in .xcdatamodeld

## Do NOT
- Modify generated NSManagedObject subclasses directly
- Use force unwrapping for optional properties
- Forget to update `updatedAt` in mutation methods
- Create circular references in computed properties
