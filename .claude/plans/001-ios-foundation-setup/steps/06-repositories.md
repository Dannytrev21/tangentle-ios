# Step 6: Entity Repositories

## Context
With the repository protocol defined, we now create concrete repository implementations for each entity. Each repository adds entity-specific query methods beyond basic CRUD.

## Goal
Create repository implementations for all Core Data entities with specialized query methods.

## Prerequisites
- Step 5 completed (Repository protocol exists)
- Step 4 completed (Model extensions exist)

## High-Level Steps
1. Create TaskRepository with task-specific queries
2. Create ProjectRepository
3. Create GoalRepository
4. Create StrategyRepository with scoring queries
5. Create remaining entity repositories
6. Create SettingsRepository (singleton pattern)

## Detailed Requirements

### TaskRepository
Create `Core/Repositories/TaskRepository.swift`:

```swift
import CoreData

protocol TaskRepositoryProtocol: Repository where Entity == TGTask {
    func fetchTodaysTasks() async throws -> [TGTask]
    func fetchOverdue() async throws -> [TGTask]
    func fetchByStatus(_ status: TaskStatus) async throws -> [TGTask]
    func fetchByProject(_ project: TGProject) async throws -> [TGTask]
    func fetchByFocusMode(_ focusMode: TGFocusMode) async throws -> [TGTask]
    func fetchScheduled(for date: Date) async throws -> [TGTask]
    func fetchByPriority(_ priority: Int) async throws -> [TGTask]
    func fetchSubtasks(of parent: TGTask) async throws -> [TGTask]
    func fetchUnscheduled() async throws -> [TGTask]
    func createTask(title: String, project: TGProject?, priority: Int) async throws -> TGTask
}

final class TaskRepository: BaseRepository<TGTask>, TaskRepositoryProtocol {

    func fetchTodaysTasks() async throws -> [TGTask] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = NSPredicate(
            format: "(scheduledDate >= %@ AND scheduledDate < %@) OR (dueDate >= %@ AND dueDate < %@)",
            startOfDay as NSDate, endOfDay as NSDate,
            startOfDay as NSDate, endOfDay as NSDate
        )
        let sortDescriptors = [
            NSSortDescriptor(key: "scheduledTime", ascending: true),
            NSSortDescriptor(key: "priority", ascending: false)
        ]

        return try await fetch(predicate: predicate, sortDescriptors: sortDescriptors)
    }

    func fetchOverdue() async throws -> [TGTask] {
        let now = Date()
        let predicate = NSPredicate(
            format: "dueDate < %@ AND status != %@",
            now as NSDate,
            TaskStatus.completed.rawValue
        )
        return try await fetch(predicate: predicate, sortDescriptors: [
            NSSortDescriptor(key: "dueDate", ascending: true)
        ])
    }

    func fetchByStatus(_ status: TaskStatus) async throws -> [TGTask] {
        let predicate = NSPredicate(format: "status == %@", status.rawValue)
        return try await fetch(predicate: predicate, sortDescriptors: [
            NSSortDescriptor(key: "sortOrder", ascending: true)
        ])
    }

    func fetchByProject(_ project: TGProject) async throws -> [TGTask] {
        let predicate = NSPredicate(format: "project == %@", project)
        return try await fetch(predicate: predicate, sortDescriptors: [
            NSSortDescriptor(key: "sortOrder", ascending: true)
        ])
    }

    func fetchByFocusMode(_ focusMode: TGFocusMode) async throws -> [TGTask] {
        let predicate = NSPredicate(format: "focusMode == %@", focusMode)
        return try await fetch(predicate: predicate, sortDescriptors: [
            NSSortDescriptor(key: "sortOrder", ascending: true)
        ])
    }

    func fetchScheduled(for date: Date) async throws -> [TGTask] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = NSPredicate(
            format: "scheduledDate >= %@ AND scheduledDate < %@",
            startOfDay as NSDate, endOfDay as NSDate
        )
        return try await fetch(predicate: predicate, sortDescriptors: [
            NSSortDescriptor(key: "scheduledTime", ascending: true)
        ])
    }

    func fetchByPriority(_ priority: Int) async throws -> [TGTask] {
        let predicate = NSPredicate(format: "priority == %d", priority)
        return try await fetch(predicate: predicate, sortDescriptors: nil)
    }

    func fetchSubtasks(of parent: TGTask) async throws -> [TGTask] {
        let predicate = NSPredicate(format: "parentTask == %@", parent)
        return try await fetch(predicate: predicate, sortDescriptors: [
            NSSortDescriptor(key: "sortOrder", ascending: true)
        ])
    }

    func fetchUnscheduled() async throws -> [TGTask] {
        let predicate = NSPredicate(
            format: "scheduledDate == nil AND status == %@",
            TaskStatus.pending.rawValue
        )
        return try await fetch(predicate: predicate, sortDescriptors: [
            NSSortDescriptor(key: "priority", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ])
    }

    func createTask(title: String, project: TGProject? = nil, priority: Int = 0) async throws -> TGTask {
        let task = TGTask(context: context, title: title)
        task.project = project
        task.priority = Int16(priority)
        try await save()
        return task
    }
}
```

### StrategyRepository
Create `Core/Repositories/StrategyRepository.swift` with scoring logic:

```swift
protocol StrategyRepositoryProtocol: Repository where Entity == TGStrategy {
    func fetchByProblemType(_ type: String) async throws -> [TGStrategy]
    func fetchTopStrategies(forProblem: String, limit: Int) async throws -> [TGStrategy]
    func recordOutcome(strategy: TGStrategy, result: StrategyResult, problemType: String, taskType: String, taskTitle: String, notes: String?) async throws
    func calculateScore(for strategy: TGStrategy, problemType: String, taskType: String) -> Double
}

final class StrategyRepository: BaseRepository<TGStrategy>, StrategyRepositoryProtocol {

    func fetchByProblemType(_ type: String) async throws -> [TGStrategy] {
        // problemTypes is Transformable [String] - need to check contains
        let predicate = NSPredicate(
            format: "isActive == YES AND problemTypes CONTAINS %@", type
        )
        return try await fetch(predicate: predicate, sortDescriptors: nil)
    }

    func fetchTopStrategies(forProblem problemType: String, limit: Int = 5) async throws -> [TGStrategy] {
        let strategies = try await fetchByProblemType(problemType)

        // Sort by calculated score
        let scored = strategies.map { strategy in
            (strategy: strategy, score: calculateScore(for: strategy, problemType: problemType, taskType: "all"))
        }
        .sorted { $0.score > $1.score }
        .prefix(limit)
        .map { $0.strategy }

        return Array(scored)
    }

    func recordOutcome(
        strategy: TGStrategy,
        result: StrategyResult,
        problemType: String,
        taskType: String,
        taskTitle: String,
        notes: String?
    ) async throws {
        let outcome = TGStrategyOutcome(context: context)
        outcome.id = UUID()
        outcome.date = Date()
        outcome.result = result.rawValue
        outcome.problemType = problemType
        outcome.taskType = taskType
        outcome.taskTitle = taskTitle
        outcome.notes = notes
        outcome.strategy = strategy

        strategy.usageCount += 1
        strategy.updatedAt = Date()

        try await save()
    }

    func calculateScore(for strategy: TGStrategy, problemType: String, taskType: String) -> Double {
        let outcomes = (strategy.outcomes?.allObjects as? [TGStrategyOutcome]) ?? []
        let relevantOutcomes = outcomes.filter {
            $0.problemType == problemType && (taskType == "all" || $0.taskType == taskType)
        }

        guard !relevantOutcomes.isEmpty else { return 0 }

        let attempts = Double(relevantOutcomes.count)
        let successes = relevantOutcomes.reduce(0.0) { sum, outcome in
            switch StrategyResult(rawValue: outcome.result ?? "") {
            case .success: return sum + 1.0
            case .partial: return sum + 0.5
            default: return sum
            }
        }

        let successRate = successes / attempts
        let confidence = log(attempts + 1) / log(10)

        // Recency factor
        let recentOutcome = relevantOutcomes.max { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
        let recencyFactor: Double
        if let lastDate = recentOutcome?.date {
            let daysSince = Date().timeIntervalSince(lastDate) / (24 * 3600)
            recencyFactor = exp(-daysSince / 30)
        } else {
            recencyFactor = 1.0
        }

        return successRate * confidence * (0.5 + 0.5 * recencyFactor)
    }
}
```

### SettingsRepository (Singleton)
Create `Core/Repositories/SettingsRepository.swift`:

```swift
protocol SettingsRepositoryProtocol {
    func getSettings() async throws -> TGSettings
    func updateSettings(_ block: (TGSettings) -> Void) async throws
}

final class SettingsRepository: BaseRepository<TGSettings>, SettingsRepositoryProtocol {

    func getSettings() async throws -> TGSettings {
        let existing = try await fetchAll()
        if let settings = existing.first {
            return settings
        }

        // Create default settings
        let settings = TGSettings(context: context)
        settings.id = UUID()
        settings.updatedAt = Date()
        try await save()
        return settings
    }

    func updateSettings(_ block: (TGSettings) -> Void) async throws {
        let settings = try await getSettings()
        block(settings)
        settings.updatedAt = Date()
        try await save()
    }
}
```

### Other Repositories
Create similar repositories for:
- `ProjectRepository` - fetchActive, fetchByGoal
- `GoalRepository` - fetchActive, fetchWithProgress
- `RoutineRepository` - fetchEnabled, fetchByDayOfWeek
- `HabitRepository` - fetchActive, updateStreak
- `FocusModeRepository` - fetchActive, fetchCurrent
- `ModeRepository` - fetchDefault, fetchShared
- `ProblemTypeRepository` - fetchDefaults
- `TagRepository` - fetchAll, fetchByName

## Files to Create
- `Tangentle/Core/Repositories/TaskRepository.swift`
- `Tangentle/Core/Repositories/ProjectRepository.swift`
- `Tangentle/Core/Repositories/GoalRepository.swift`
- `Tangentle/Core/Repositories/StrategyRepository.swift`
- `Tangentle/Core/Repositories/RoutineRepository.swift`
- `Tangentle/Core/Repositories/HabitRepository.swift`
- `Tangentle/Core/Repositories/FocusModeRepository.swift`
- `Tangentle/Core/Repositories/ModeRepository.swift`
- `Tangentle/Core/Repositories/ProblemTypeRepository.swift`
- `Tangentle/Core/Repositories/TagRepository.swift`
- `Tangentle/Core/Repositories/SettingsRepository.swift`

## Files to Modify
- None

## Patterns to Follow
- Define protocol for each repository (enables mocking)
- Use descriptive method names
- Sort results appropriately for UI
- Include convenience create methods

## Acceptance Criteria
- [ ] All 11 repositories created with protocols
- [ ] TaskRepository has all specialized queries
- [ ] StrategyRepository implements scoring algorithm
- [ ] SettingsRepository handles singleton pattern
- [ ] All repositories compile without errors
- [ ] Repositories are ready for unit testing

## Verification Commands
```bash
# Build to verify repositories compile
cd tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Count repository files
ls tangentle-ios/Tangentle/Tangentle/Core/Repositories/*.swift | wc -l
# Should be ~13 (base + 11 entities + protocol)
```

## Documentation Updates
- [ ] Update docs/ARCHITECTURE.md with repository list

## Error Recovery
If queries don't work:
1. Verify Core Data attribute names match predicates
2. Check Transformable types are properly decoded
3. Test predicates in isolation

## Do NOT
- Put business logic in repositories (that's for services)
- Create repositories that don't follow the protocol
- Forget to define protocols for testability
- Use synchronous Core Data operations
