# Step 7: Dependency Injection Container

## Context
We need a way to wire up dependencies (repositories, services) and inject them into views and other services. This enables testability and clean architecture. We'll use a manual DI container that's simple but effective.

## Goal
Create a dependency injection container that provides access to all repositories and services, supporting both production and test configurations.

## Prerequisites
- Step 5-6 completed (Repositories exist)

## High-Level Steps
1. Create DI Container protocol
2. Create production container implementation
3. Create mock/test container
4. Integrate with SwiftUI environment

## Detailed Requirements

### Container Protocol
Create `Core/DI/Container.swift`:

```swift
import Foundation
import CoreData

/// Protocol defining all injectable dependencies
protocol DIContainer {
    // Core Data
    var persistenceController: PersistenceController { get }
    var viewContext: NSManagedObjectContext { get }

    // Repositories
    var taskRepository: TaskRepositoryProtocol { get }
    var projectRepository: ProjectRepositoryProtocol { get }
    var goalRepository: GoalRepositoryProtocol { get }
    var strategyRepository: StrategyRepositoryProtocol { get }
    var routineRepository: RoutineRepositoryProtocol { get }
    var habitRepository: HabitRepositoryProtocol { get }
    var focusModeRepository: FocusModeRepositoryProtocol { get }
    var modeRepository: ModeRepositoryProtocol { get }
    var problemTypeRepository: ProblemTypeRepositoryProtocol { get }
    var tagRepository: TagRepositoryProtocol { get }
    var settingsRepository: SettingsRepositoryProtocol { get }

    // Services (added in later steps)
    var taskService: TaskServiceProtocol { get }
    var strategyService: StrategyServiceProtocol { get }
    var scheduleService: ScheduleServiceProtocol { get }
    var settingsService: SettingsServiceProtocol { get }

    // AI Services
    var aiService: AIServiceProtocol { get }
}
```

### Production Container
Create `Core/DI/AppContainer.swift`:

```swift
import Foundation
import CoreData

/// Production dependency container
final class AppContainer: DIContainer {
    static let shared = AppContainer()

    // MARK: - Core Data

    let persistenceController: PersistenceController

    var viewContext: NSManagedObjectContext {
        persistenceController.viewContext
    }

    // MARK: - Repositories (lazy initialization)

    private lazy var _taskRepository: TaskRepository = {
        TaskRepository(context: viewContext)
    }()
    var taskRepository: TaskRepositoryProtocol { _taskRepository }

    private lazy var _projectRepository: ProjectRepository = {
        ProjectRepository(context: viewContext)
    }()
    var projectRepository: ProjectRepositoryProtocol { _projectRepository }

    private lazy var _goalRepository: GoalRepository = {
        GoalRepository(context: viewContext)
    }()
    var goalRepository: GoalRepositoryProtocol { _goalRepository }

    private lazy var _strategyRepository: StrategyRepository = {
        StrategyRepository(context: viewContext)
    }()
    var strategyRepository: StrategyRepositoryProtocol { _strategyRepository }

    private lazy var _routineRepository: RoutineRepository = {
        RoutineRepository(context: viewContext)
    }()
    var routineRepository: RoutineRepositoryProtocol { _routineRepository }

    private lazy var _habitRepository: HabitRepository = {
        HabitRepository(context: viewContext)
    }()
    var habitRepository: HabitRepositoryProtocol { _habitRepository }

    private lazy var _focusModeRepository: FocusModeRepository = {
        FocusModeRepository(context: viewContext)
    }()
    var focusModeRepository: FocusModeRepositoryProtocol { _focusModeRepository }

    private lazy var _modeRepository: ModeRepository = {
        ModeRepository(context: viewContext)
    }()
    var modeRepository: ModeRepositoryProtocol { _modeRepository }

    private lazy var _problemTypeRepository: ProblemTypeRepository = {
        ProblemTypeRepository(context: viewContext)
    }()
    var problemTypeRepository: ProblemTypeRepositoryProtocol { _problemTypeRepository }

    private lazy var _tagRepository: TagRepository = {
        TagRepository(context: viewContext)
    }()
    var tagRepository: TagRepositoryProtocol { _tagRepository }

    private lazy var _settingsRepository: SettingsRepository = {
        SettingsRepository(context: viewContext)
    }()
    var settingsRepository: SettingsRepositoryProtocol { _settingsRepository }

    // MARK: - Services (lazy, depend on repositories)

    private lazy var _taskService: TaskService = {
        TaskService(
            taskRepository: taskRepository,
            projectRepository: projectRepository,
            strategyRepository: strategyRepository
        )
    }()
    var taskService: TaskServiceProtocol { _taskService }

    private lazy var _strategyService: StrategyService = {
        StrategyService(
            strategyRepository: strategyRepository,
            settingsRepository: settingsRepository
        )
    }()
    var strategyService: StrategyServiceProtocol { _strategyService }

    private lazy var _scheduleService: ScheduleService = {
        ScheduleService(
            taskRepository: taskRepository,
            settingsRepository: settingsRepository
        )
    }()
    var scheduleService: ScheduleServiceProtocol { _scheduleService }

    private lazy var _settingsService: SettingsService = {
        SettingsService(settingsRepository: settingsRepository)
    }()
    var settingsService: SettingsServiceProtocol { _settingsService }

    // MARK: - AI Services

    private lazy var _aiService: AIService = {
        AIService(strategyService: strategyService)
    }()
    var aiService: AIServiceProtocol { _aiService }

    // MARK: - Init

    private init() {
        self.persistenceController = PersistenceController.shared
    }

    /// For testing with custom persistence
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
}
```

### SwiftUI Environment Key
Create `Core/DI/ContainerEnvironment.swift`:

```swift
import SwiftUI

/// Environment key for DI container
private struct ContainerKey: EnvironmentKey {
    static let defaultValue: DIContainer = AppContainer.shared
}

extension EnvironmentValues {
    var container: DIContainer {
        get { self[ContainerKey.self] }
        set { self[ContainerKey.self] = newValue }
    }
}

extension View {
    func withContainer(_ container: DIContainer) -> some View {
        environment(\.container, container)
    }
}
```

### Test Container
Create `Core/DI/TestContainer.swift`:

```swift
import Foundation
import CoreData

/// Test container with mock/stub implementations
final class TestContainer: DIContainer {
    let persistenceController: PersistenceController

    var viewContext: NSManagedObjectContext {
        persistenceController.viewContext
    }

    // Repositories - use in-memory Core Data
    lazy var taskRepository: TaskRepositoryProtocol = TaskRepository(context: viewContext)
    lazy var projectRepository: ProjectRepositoryProtocol = ProjectRepository(context: viewContext)
    lazy var goalRepository: GoalRepositoryProtocol = GoalRepository(context: viewContext)
    lazy var strategyRepository: StrategyRepositoryProtocol = StrategyRepository(context: viewContext)
    lazy var routineRepository: RoutineRepositoryProtocol = RoutineRepository(context: viewContext)
    lazy var habitRepository: HabitRepositoryProtocol = HabitRepository(context: viewContext)
    lazy var focusModeRepository: FocusModeRepositoryProtocol = FocusModeRepository(context: viewContext)
    lazy var modeRepository: ModeRepositoryProtocol = ModeRepository(context: viewContext)
    lazy var problemTypeRepository: ProblemTypeRepositoryProtocol = ProblemTypeRepository(context: viewContext)
    lazy var tagRepository: TagRepositoryProtocol = TagRepository(context: viewContext)
    lazy var settingsRepository: SettingsRepositoryProtocol = SettingsRepository(context: viewContext)

    // Services
    lazy var taskService: TaskServiceProtocol = TaskService(
        taskRepository: taskRepository,
        projectRepository: projectRepository,
        strategyRepository: strategyRepository
    )
    lazy var strategyService: StrategyServiceProtocol = StrategyService(
        strategyRepository: strategyRepository,
        settingsRepository: settingsRepository
    )
    lazy var scheduleService: ScheduleServiceProtocol = ScheduleService(
        taskRepository: taskRepository,
        settingsRepository: settingsRepository
    )
    lazy var settingsService: SettingsServiceProtocol = SettingsService(
        settingsRepository: settingsRepository
    )

    // AI - mock implementation
    lazy var aiService: AIServiceProtocol = MockAIService()

    init() {
        self.persistenceController = PersistenceController(inMemory: true)
    }
}

/// Mock AI service for testing
final class MockAIService: AIServiceProtocol {
    func getCoachingAdvice(for problemType: String, context: AIContext) async throws -> String {
        return "Mock coaching advice for \(problemType)"
    }

    func prioritizeTasks(_ tasks: [TGTask]) async throws -> [TGTask] {
        return tasks // Return unchanged for mock
    }
}
```

## Files to Create
- `Tangentle/Core/DI/Container.swift` - Protocol definition
- `Tangentle/Core/DI/AppContainer.swift` - Production container
- `Tangentle/Core/DI/ContainerEnvironment.swift` - SwiftUI integration
- `Tangentle/Core/DI/TestContainer.swift` - Test container

## Files to Modify
- None

## Patterns to Follow
- Use lazy initialization for efficiency
- Define protocols for all dependencies
- Use SwiftUI environment for view injection
- Keep container as single source of truth

## Acceptance Criteria
- [ ] DIContainer protocol defines all dependencies
- [ ] AppContainer provides production implementations
- [ ] TestContainer uses in-memory Core Data
- [ ] Environment key allows SwiftUI injection
- [ ] Lazy initialization works correctly
- [ ] Project builds without warnings

## Verification Commands
```bash
# Build to verify container compiles
cd tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build

# Check files exist
ls -la tangentle-ios/Tangentle/Tangentle/Core/DI/
```

## Documentation Updates
- [ ] Update docs/ARCHITECTURE.md with DI pattern explanation

## Error Recovery
If circular dependencies occur:
1. Break cycles by using lazy initialization
2. Consider introducing a third abstraction
3. Review dependency graph for design issues

## Do NOT
- Create multiple container instances in production
- Expose concrete types from container (use protocols)
- Initialize dependencies eagerly (use lazy)
- Put business logic in container
