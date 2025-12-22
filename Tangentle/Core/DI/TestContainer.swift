import Foundation
import CoreData

/// Test container with in-memory Core Data
final class TestContainer: DIContainer {
    let persistenceController: PersistenceController

    var viewContext: NSManagedObjectContext {
        persistenceController.viewContext
    }

    // MARK: - Repositories

    lazy var taskRepository: TaskRepositoryProtocol = TaskRepository(context: viewContext)
    lazy var projectRepository: ProjectRepositoryProtocol = ProjectRepository(context: viewContext)
    lazy var goalRepository: GoalRepositoryProtocol = GoalRepository(context: viewContext)
    lazy var strategyRepository: StrategyRepositoryProtocol = StrategyRepository(context: viewContext)
    lazy var strategyOutcomeRepository: StrategyOutcomeRepositoryProtocol = StrategyOutcomeRepository(context: viewContext)
    lazy var routineRepository: RoutineRepositoryProtocol = RoutineRepository(context: viewContext)
    lazy var routineStepRepository: RoutineStepRepositoryProtocol = RoutineStepRepository(context: viewContext)
    lazy var habitRepository: HabitRepositoryProtocol = HabitRepository(context: viewContext)
    lazy var habitCompletionRepository: HabitCompletionRepositoryProtocol = HabitCompletionRepository(context: viewContext)
    lazy var focusModeRepository: FocusModeRepositoryProtocol = FocusModeRepository(context: viewContext)
    lazy var modeRepository: ModeRepositoryProtocol = ModeRepository(context: viewContext)
    lazy var problemTypeRepository: ProblemTypeRepositoryProtocol = ProblemTypeRepository(context: viewContext)
    lazy var tagRepository: TagRepositoryProtocol = TagRepository(context: viewContext)
    lazy var settingsRepository: SettingsRepositoryProtocol = SettingsRepository(context: viewContext)

    // MARK: - Services

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

    // MARK: - AI Service (Mock)

    lazy var aiService: AIServiceProtocol = MockAIService()

    // MARK: - UI Services

    lazy var hapticEngine: HapticEngineProtocol = NoOpHapticEngine()

    // MARK: - Initialization

    init() {
        self.persistenceController = PersistenceController(inMemory: true)
    }
}

// MARK: - Mock AI Service

/// Mock AI service for testing
final class MockAIService: AIServiceProtocol {
    var mockCoachingAdvice: String = "Mock coaching advice"
    var mockCoachingResponse: CoachingResponse?
    var mockPrioritizedTasks: [TGTask]?
    var mockScheduledTasks: [TGTask]?
    var mockScheduleResponse: ScheduleResponse?

    func getCoachingAdvice(for problemType: String, context: AIContext) async throws -> String {
        return "\(mockCoachingAdvice) for \(problemType)"
    }

    func getCoachingResponse(for problemType: String, context: AIContext) async throws -> CoachingResponse {
        if let response = mockCoachingResponse {
            return response
        }
        let advice = try await getCoachingAdvice(for: problemType, context: context)
        return CoachingResponse(
            advice: advice,
            suggestedStrategies: ["Mock Strategy 1", "Mock Strategy 2"],
            followUpQuestions: ["What's blocking you?"]
        )
    }

    func prioritizeTasks(_ tasks: [TGTask]) async throws -> [TGTask] {
        return mockPrioritizedTasks ?? tasks
    }

    func suggestSchedule(for tasks: [TGTask], settings: ScheduleSettings) async throws -> [TGTask] {
        return mockScheduledTasks ?? tasks
    }

    func generateSchedule(request: ScheduleRequest) async throws -> ScheduleResponse {
        if let response = mockScheduleResponse {
            return response
        }
        return ScheduleResponse(scheduledTasks: [])
    }
}
