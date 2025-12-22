import Foundation
import CoreData

/// Production dependency container with lazy initialization
final class AppContainer: DIContainer {
    static let shared = AppContainer()

    // MARK: - Core Data

    let persistenceController: PersistenceController

    var viewContext: NSManagedObjectContext {
        persistenceController.viewContext
    }

    // MARK: - Repositories (Lazy)

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

    private lazy var _strategyOutcomeRepository: StrategyOutcomeRepository = {
        StrategyOutcomeRepository(context: viewContext)
    }()
    var strategyOutcomeRepository: StrategyOutcomeRepositoryProtocol { _strategyOutcomeRepository }

    private lazy var _routineRepository: RoutineRepository = {
        RoutineRepository(context: viewContext)
    }()
    var routineRepository: RoutineRepositoryProtocol { _routineRepository }

    private lazy var _routineStepRepository: RoutineStepRepository = {
        RoutineStepRepository(context: viewContext)
    }()
    var routineStepRepository: RoutineStepRepositoryProtocol { _routineStepRepository }

    private lazy var _habitRepository: HabitRepository = {
        HabitRepository(context: viewContext)
    }()
    var habitRepository: HabitRepositoryProtocol { _habitRepository }

    private lazy var _habitCompletionRepository: HabitCompletionRepository = {
        HabitCompletionRepository(context: viewContext)
    }()
    var habitCompletionRepository: HabitCompletionRepositoryProtocol { _habitCompletionRepository }

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

    // MARK: - Services (Lazy)

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

    // MARK: - UI Services

    private lazy var _hapticEngine: HapticEngine = {
        HapticEngine(intensity: .selective)
    }()
    var hapticEngine: HapticEngineProtocol { _hapticEngine }

    // MARK: - Initialization

    private init() {
        self.persistenceController = PersistenceController.shared
    }

    /// For testing with custom persistence
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
}
