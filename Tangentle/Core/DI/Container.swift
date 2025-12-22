import Foundation
import CoreData

/// Protocol defining all injectable dependencies
protocol DIContainer {
    // MARK: - Core Data
    var persistenceController: PersistenceController { get }
    var viewContext: NSManagedObjectContext { get }

    // MARK: - Repositories
    var taskRepository: TaskRepositoryProtocol { get }
    var projectRepository: ProjectRepositoryProtocol { get }
    var goalRepository: GoalRepositoryProtocol { get }
    var strategyRepository: StrategyRepositoryProtocol { get }
    var strategyOutcomeRepository: StrategyOutcomeRepositoryProtocol { get }
    var routineRepository: RoutineRepositoryProtocol { get }
    var routineStepRepository: RoutineStepRepositoryProtocol { get }
    var habitRepository: HabitRepositoryProtocol { get }
    var habitCompletionRepository: HabitCompletionRepositoryProtocol { get }
    var focusModeRepository: FocusModeRepositoryProtocol { get }
    var modeRepository: ModeRepositoryProtocol { get }
    var problemTypeRepository: ProblemTypeRepositoryProtocol { get }
    var tagRepository: TagRepositoryProtocol { get }
    var settingsRepository: SettingsRepositoryProtocol { get }

    // MARK: - Services (will be implemented in Step 8)
    var taskService: TaskServiceProtocol { get }
    var strategyService: StrategyServiceProtocol { get }
    var scheduleService: ScheduleServiceProtocol { get }
    var settingsService: SettingsServiceProtocol { get }

    // MARK: - AI Services (will be implemented in Step 9)
    var aiService: AIServiceProtocol { get }

    // MARK: - UI Services
    var hapticEngine: HapticEngineProtocol { get }
}
