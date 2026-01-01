import Foundation
import CoreData
@testable import Tangentle

// MARK: - Mock Task Repository

final class MockTaskRepository: BaseMockRepository, TaskRepositoryProtocol {
    typealias Entity = TGTask

    // Storage for entities (use TestCoreDataStack to create actual entities)
    var tasks: [TGTask] = []

    // Configurable results
    var fetchTodaysTasksResult: Result<[TGTask], Error> = .success([])
    var fetchOverdueTasksResult: Result<[TGTask], Error> = .success([])
    var fetchByProjectResult: Result<[TGTask], Error> = .success([])
    var fetchByStatusResult: Result<[TGTask], Error> = .success([])
    var fetchByPriorityResult: Result<[TGTask], Error> = .success([])
    var fetchScheduledBetweenResult: Result<[TGTask], Error> = .success([])
    var fetchPendingResult: Result<[TGTask], Error> = .success([])
    var fetchInProgressResult: Result<[TGTask], Error> = .success([])
    var fetchByEnergyResult: Result<[TGTask], Error> = .success([])
    var fetchByIdResult: TGTask?
    var fetchAllResult: Result<[TGTask], Error> = .success([])
    var fetchResult: Result<[TGTask], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGTask?

    // Repository protocol - context (not used in mocks)
    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts. Use TestCoreDataStack.")
    }

    // MARK: - Base Repository Protocol

    func create() -> TGTask {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockTaskRepository.create() - configure createResult or use TestCoreDataStack")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGTask] {
        recordCall("fetch", arguments: ["predicate": predicate?.description ?? "nil"])
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGTask? {
        recordCall("fetchOne", arguments: ["predicate": predicate.description])
        return tasks.first
    }

    func fetchById(_ id: UUID) async throws -> TGTask? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? tasks.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count", arguments: ["predicate": predicate?.description ?? "nil"])
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGTask) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        tasks.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll", arguments: ["predicate": predicate?.description ?? "nil"])
        if shouldThrowOnDelete { throw deleteError }
        tasks.removeAll()
    }

    // MARK: - Task-Specific Protocol Methods

    func fetchTodaysTasks() async throws -> [TGTask] {
        recordCall("fetchTodaysTasks")
        return try fetchTodaysTasksResult.get()
    }

    func fetchOverdueTasks() async throws -> [TGTask] {
        recordCall("fetchOverdueTasks")
        return try fetchOverdueTasksResult.get()
    }

    func fetchByProject(_ project: TGProject) async throws -> [TGTask] {
        recordCall("fetchByProject", arguments: ["projectId": project.id as Any])
        return try fetchByProjectResult.get()
    }

    func fetchByStatus(_ status: TaskStatus) async throws -> [TGTask] {
        recordCall("fetchByStatus", arguments: ["status": status.rawValue])
        return try fetchByStatusResult.get()
    }

    func fetchByPriority(_ priority: Priority) async throws -> [TGTask] {
        recordCall("fetchByPriority", arguments: ["priority": Int(priority.rawValue)])
        return try fetchByPriorityResult.get()
    }

    func fetchScheduledBetween(start: Date, end: Date) async throws -> [TGTask] {
        recordCall("fetchScheduledBetween", arguments: ["start": start, "end": end])
        return try fetchScheduledBetweenResult.get()
    }

    func fetchPending() async throws -> [TGTask] {
        recordCall("fetchPending")
        return try fetchPendingResult.get()
    }

    func fetchInProgress() async throws -> [TGTask] {
        recordCall("fetchInProgress")
        return try fetchInProgressResult.get()
    }

    func fetchByEnergy(_ energy: EnergyLevel) async throws -> [TGTask] {
        recordCall("fetchByEnergy", arguments: ["energy": energy.rawValue])
        return try fetchByEnergyResult.get()
    }
}

// MARK: - Mock Project Repository

final class MockProjectRepository: BaseMockRepository, ProjectRepositoryProtocol {
    typealias Entity = TGProject

    var projects: [TGProject] = []
    var fetchActiveResult: Result<[TGProject], Error> = .success([])
    var fetchByGoalResult: Result<[TGProject], Error> = .success([])
    var fetchArchivedResult: Result<[TGProject], Error> = .success([])
    var fetchByIdResult: TGProject?
    var fetchAllResult: Result<[TGProject], Error> = .success([])
    var fetchResult: Result<[TGProject], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGProject?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGProject {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockProjectRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGProject] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGProject? {
        recordCall("fetchOne")
        return projects.first
    }

    func fetchById(_ id: UUID) async throws -> TGProject? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? projects.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGProject) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        projects.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        projects.removeAll()
    }

    func fetchActive() async throws -> [TGProject] {
        recordCall("fetchActive")
        return try fetchActiveResult.get()
    }

    func fetchByGoal(_ goal: TGGoal) async throws -> [TGProject] {
        recordCall("fetchByGoal", arguments: ["goalId": goal.id as Any])
        return try fetchByGoalResult.get()
    }

    func fetchArchived() async throws -> [TGProject] {
        recordCall("fetchArchived")
        return try fetchArchivedResult.get()
    }
}

// MARK: - Mock Goal Repository

final class MockGoalRepository: BaseMockRepository, GoalRepositoryProtocol {
    typealias Entity = TGGoal

    var goals: [TGGoal] = []
    var fetchActiveResult: Result<[TGGoal], Error> = .success([])
    var fetchWithUpcomingDeadlinesResult: Result<[TGGoal], Error> = .success([])
    var fetchByIdResult: TGGoal?
    var fetchAllResult: Result<[TGGoal], Error> = .success([])
    var fetchResult: Result<[TGGoal], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGGoal?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGGoal {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockGoalRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGGoal] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGGoal? {
        recordCall("fetchOne")
        return goals.first
    }

    func fetchById(_ id: UUID) async throws -> TGGoal? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? goals.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGGoal) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        goals.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        goals.removeAll()
    }

    func fetchActive() async throws -> [TGGoal] {
        recordCall("fetchActive")
        return try fetchActiveResult.get()
    }

    func fetchWithUpcomingDeadlines(within days: Int) async throws -> [TGGoal] {
        recordCall("fetchWithUpcomingDeadlines", arguments: ["days": days])
        return try fetchWithUpcomingDeadlinesResult.get()
    }
}

// MARK: - Mock Strategy Repository

final class MockStrategyRepository: BaseMockRepository, StrategyRepositoryProtocol {
    typealias Entity = TGStrategy

    var strategies: [TGStrategy] = []
    var fetchActiveResult: Result<[TGStrategy], Error> = .success([])
    var fetchByProblemTypeResult: Result<[TGStrategy], Error> = .success([])
    var fetchTopRatedResult: Result<[TGStrategy], Error> = .success([])
    var fetchBySourceResult: Result<[TGStrategy], Error> = .success([])
    var fetchByIdResult: TGStrategy?
    var fetchAllResult: Result<[TGStrategy], Error> = .success([])
    var fetchResult: Result<[TGStrategy], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGStrategy?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGStrategy {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockStrategyRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGStrategy] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGStrategy? {
        recordCall("fetchOne")
        return strategies.first
    }

    func fetchById(_ id: UUID) async throws -> TGStrategy? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? strategies.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGStrategy) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        strategies.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        strategies.removeAll()
    }

    func fetchActive() async throws -> [TGStrategy] {
        recordCall("fetchActive")
        return try fetchActiveResult.get()
    }

    func fetchByProblemType(_ type: String) async throws -> [TGStrategy] {
        recordCall("fetchByProblemType", arguments: ["type": type])
        return try fetchByProblemTypeResult.get()
    }

    func fetchTopRated(limit: Int) async throws -> [TGStrategy] {
        recordCall("fetchTopRated", arguments: ["limit": limit])
        return try fetchTopRatedResult.get()
    }

    func fetchBySource(_ source: String) async throws -> [TGStrategy] {
        recordCall("fetchBySource", arguments: ["source": source])
        return try fetchBySourceResult.get()
    }
}

// MARK: - Mock Strategy Outcome Repository

final class MockStrategyOutcomeRepository: BaseMockRepository, StrategyOutcomeRepositoryProtocol {
    typealias Entity = TGStrategyOutcome

    var outcomes: [TGStrategyOutcome] = []
    var fetchByStrategyResult: Result<[TGStrategyOutcome], Error> = .success([])
    var fetchRecentResult: Result<[TGStrategyOutcome], Error> = .success([])
    var fetchByIdResult: TGStrategyOutcome?
    var fetchAllResult: Result<[TGStrategyOutcome], Error> = .success([])
    var fetchResult: Result<[TGStrategyOutcome], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGStrategyOutcome?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGStrategyOutcome {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockStrategyOutcomeRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGStrategyOutcome] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGStrategyOutcome? {
        recordCall("fetchOne")
        return outcomes.first
    }

    func fetchById(_ id: UUID) async throws -> TGStrategyOutcome? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? outcomes.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGStrategyOutcome) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        outcomes.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        outcomes.removeAll()
    }

    func fetchByStrategy(_ strategy: TGStrategy) async throws -> [TGStrategyOutcome] {
        recordCall("fetchByStrategy", arguments: ["strategyId": strategy.id as Any])
        return try fetchByStrategyResult.get()
    }

    func fetchRecent(limit: Int) async throws -> [TGStrategyOutcome] {
        recordCall("fetchRecent", arguments: ["limit": limit])
        return try fetchRecentResult.get()
    }
}

// MARK: - Mock Routine Repository

final class MockRoutineRepository: BaseMockRepository, RoutineRepositoryProtocol {
    typealias Entity = TGRoutine

    var routines: [TGRoutine] = []
    var fetchEnabledResult: Result<[TGRoutine], Error> = .success([])
    var fetchByTypeResult: Result<[TGRoutine], Error> = .success([])
    var fetchScheduledForTodayResult: Result<[TGRoutine], Error> = .success([])
    var fetchByIdResult: TGRoutine?
    var fetchAllResult: Result<[TGRoutine], Error> = .success([])
    var fetchResult: Result<[TGRoutine], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGRoutine?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGRoutine {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockRoutineRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGRoutine] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGRoutine? {
        recordCall("fetchOne")
        return routines.first
    }

    func fetchById(_ id: UUID) async throws -> TGRoutine? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? routines.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGRoutine) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        routines.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        routines.removeAll()
    }

    func fetchEnabled() async throws -> [TGRoutine] {
        recordCall("fetchEnabled")
        return try fetchEnabledResult.get()
    }

    func fetchByType(_ type: RoutineType) async throws -> [TGRoutine] {
        recordCall("fetchByType", arguments: ["type": type.rawValue])
        return try fetchByTypeResult.get()
    }

    func fetchScheduledForToday() async throws -> [TGRoutine] {
        recordCall("fetchScheduledForToday")
        return try fetchScheduledForTodayResult.get()
    }
}

// MARK: - Mock Routine Step Repository

final class MockRoutineStepRepository: BaseMockRepository, RoutineStepRepositoryProtocol {
    typealias Entity = TGRoutineStep

    var steps: [TGRoutineStep] = []
    var fetchByRoutineResult: Result<[TGRoutineStep], Error> = .success([])
    var fetchByIdResult: TGRoutineStep?
    var fetchAllResult: Result<[TGRoutineStep], Error> = .success([])
    var fetchResult: Result<[TGRoutineStep], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGRoutineStep?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGRoutineStep {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockRoutineStepRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGRoutineStep] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGRoutineStep? {
        recordCall("fetchOne")
        return steps.first
    }

    func fetchById(_ id: UUID) async throws -> TGRoutineStep? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? steps.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGRoutineStep) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        steps.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        steps.removeAll()
    }

    func fetchByRoutine(_ routine: TGRoutine) async throws -> [TGRoutineStep] {
        recordCall("fetchByRoutine", arguments: ["routineId": routine.id as Any])
        return try fetchByRoutineResult.get()
    }
}

// MARK: - Mock Habit Repository

final class MockHabitRepository: BaseMockRepository, HabitRepositoryProtocol {
    typealias Entity = TGHabit

    var habits: [TGHabit] = []
    var fetchActiveResult: Result<[TGHabit], Error> = .success([])
    var fetchDueTodayResult: Result<[TGHabit], Error> = .success([])
    var fetchByFrequencyResult: Result<[TGHabit], Error> = .success([])
    var fetchByIdResult: TGHabit?
    var fetchAllResult: Result<[TGHabit], Error> = .success([])
    var fetchResult: Result<[TGHabit], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGHabit?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGHabit {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockHabitRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGHabit] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGHabit? {
        recordCall("fetchOne")
        return habits.first
    }

    func fetchById(_ id: UUID) async throws -> TGHabit? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? habits.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGHabit) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        habits.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        habits.removeAll()
    }

    func fetchActive() async throws -> [TGHabit] {
        recordCall("fetchActive")
        return try fetchActiveResult.get()
    }

    func fetchDueToday() async throws -> [TGHabit] {
        recordCall("fetchDueToday")
        return try fetchDueTodayResult.get()
    }

    func fetchByFrequency(_ frequency: HabitFrequency) async throws -> [TGHabit] {
        recordCall("fetchByFrequency", arguments: ["frequency": frequency.rawValue])
        return try fetchByFrequencyResult.get()
    }
}

// MARK: - Mock Habit Completion Repository

final class MockHabitCompletionRepository: BaseMockRepository, HabitCompletionRepositoryProtocol {
    typealias Entity = TGHabitCompletion

    var completions: [TGHabitCompletion] = []
    var fetchByHabitResult: Result<[TGHabitCompletion], Error> = .success([])
    var fetchForDateResult: Result<[TGHabitCompletion], Error> = .success([])
    var fetchByIdResult: TGHabitCompletion?
    var fetchAllResult: Result<[TGHabitCompletion], Error> = .success([])
    var fetchResult: Result<[TGHabitCompletion], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGHabitCompletion?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGHabitCompletion {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockHabitCompletionRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGHabitCompletion] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGHabitCompletion? {
        recordCall("fetchOne")
        return completions.first
    }

    func fetchById(_ id: UUID) async throws -> TGHabitCompletion? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? completions.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGHabitCompletion) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        completions.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        completions.removeAll()
    }

    func fetchByHabit(_ habit: TGHabit) async throws -> [TGHabitCompletion] {
        recordCall("fetchByHabit", arguments: ["habitId": habit.id as Any])
        return try fetchByHabitResult.get()
    }

    func fetchForDate(_ date: Date, habit: TGHabit) async throws -> [TGHabitCompletion] {
        recordCall("fetchForDate", arguments: ["date": date, "habitId": habit.id as Any])
        return try fetchForDateResult.get()
    }
}

// MARK: - Mock Focus Mode Repository

final class MockFocusModeRepository: BaseMockRepository, FocusModeRepositoryProtocol {
    typealias Entity = TGFocusMode

    var focusModes: [TGFocusMode] = []
    var fetchActiveResult: Result<[TGFocusMode], Error> = .success([])
    var fetchAutomaticResult: Result<[TGFocusMode], Error> = .success([])
    var fetchCurrentlyActiveResult: TGFocusMode?
    var fetchByIdResult: TGFocusMode?
    var fetchAllResult: Result<[TGFocusMode], Error> = .success([])
    var fetchResult: Result<[TGFocusMode], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGFocusMode?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGFocusMode {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockFocusModeRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGFocusMode] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGFocusMode? {
        recordCall("fetchOne")
        return focusModes.first
    }

    func fetchById(_ id: UUID) async throws -> TGFocusMode? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? focusModes.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGFocusMode) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        focusModes.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        focusModes.removeAll()
    }

    func fetchActive() async throws -> [TGFocusMode] {
        recordCall("fetchActive")
        return try fetchActiveResult.get()
    }

    func fetchAutomatic() async throws -> [TGFocusMode] {
        recordCall("fetchAutomatic")
        return try fetchAutomaticResult.get()
    }

    func fetchCurrentlyActive() async throws -> TGFocusMode? {
        recordCall("fetchCurrentlyActive")
        return fetchCurrentlyActiveResult
    }
}

// MARK: - Mock Mode Repository

final class MockModeRepository: BaseMockRepository, ModeRepositoryProtocol {
    typealias Entity = TGMode

    var modes: [TGMode] = []
    var fetchDefaultResult: TGMode?
    var fetchByIdResult: TGMode?
    var fetchAllResult: Result<[TGMode], Error> = .success([])
    var fetchResult: Result<[TGMode], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGMode?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGMode {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockModeRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGMode] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGMode? {
        recordCall("fetchOne")
        return modes.first
    }

    func fetchById(_ id: UUID) async throws -> TGMode? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? modes.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGMode) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        modes.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        modes.removeAll()
    }

    func fetchDefault() async throws -> TGMode? {
        recordCall("fetchDefault")
        return fetchDefaultResult
    }

    func fetchAll() async throws -> [TGMode] {
        recordCall("fetchAll")
        return try fetchAllResult.get()
    }
}

// MARK: - Mock Problem Type Repository

final class MockProblemTypeRepository: BaseMockRepository, ProblemTypeRepositoryProtocol {
    typealias Entity = TGProblemType

    var problemTypes: [TGProblemType] = []
    var fetchByIdentifierResult: TGProblemType?
    var fetchDefaultsResult: Result<[TGProblemType], Error> = .success([])
    var fetchByIdResult: TGProblemType?
    var fetchAllResult: Result<[TGProblemType], Error> = .success([])
    var fetchResult: Result<[TGProblemType], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGProblemType?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGProblemType {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockProblemTypeRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGProblemType] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGProblemType? {
        recordCall("fetchOne")
        return problemTypes.first
    }

    func fetchById(_ id: UUID) async throws -> TGProblemType? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? problemTypes.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGProblemType) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        problemTypes.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        problemTypes.removeAll()
    }

    func fetchAll() async throws -> [TGProblemType] {
        recordCall("fetchAll")
        return try fetchAllResult.get()
    }

    func fetchByIdentifier(_ identifier: String) async throws -> TGProblemType? {
        recordCall("fetchByIdentifier", arguments: ["identifier": identifier])
        return fetchByIdentifierResult ?? problemTypes.first { $0.identifier == identifier }
    }

    func fetchDefaults() async throws -> [TGProblemType] {
        recordCall("fetchDefaults")
        return try fetchDefaultsResult.get()
    }
}

// MARK: - Mock Tag Repository

final class MockTagRepository: BaseMockRepository, TagRepositoryProtocol {
    typealias Entity = TGTag

    var tags: [TGTag] = []
    var fetchByNameResult: TGTag?
    var fetchOrCreateResult: TGTag?
    var fetchByIdResult: TGTag?
    var fetchAllResult: Result<[TGTag], Error> = .success([])
    var fetchResult: Result<[TGTag], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGTag?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGTag {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockTagRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGTag] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGTag? {
        recordCall("fetchOne")
        return tags.first
    }

    func fetchById(_ id: UUID) async throws -> TGTag? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? tags.first { $0.id == id }
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGTag) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        tags.removeAll { $0.id == entity.id }
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        tags.removeAll()
    }

    func fetchAll() async throws -> [TGTag] {
        recordCall("fetchAll")
        return try fetchAllResult.get()
    }

    func fetchByName(_ name: String) async throws -> TGTag? {
        recordCall("fetchByName", arguments: ["name": name])
        return fetchByNameResult ?? tags.first { $0.name == name }
    }

    func fetchOrCreate(name: String) async throws -> TGTag {
        recordCall("fetchOrCreate", arguments: ["name": name])
        if let result = fetchOrCreateResult {
            return result
        }
        if let existing = tags.first(where: { $0.name == name }) {
            return existing
        }
        fatalError("MockTagRepository.fetchOrCreate() - configure fetchOrCreateResult")
    }
}

// MARK: - Mock Settings Repository

final class MockSettingsRepository: BaseMockRepository, SettingsRepositoryProtocol {
    typealias Entity = TGSettings

    var settings: TGSettings?
    var getSettingsResult: TGSettings?
    var fetchByIdResult: TGSettings?
    var fetchAllResult: Result<[TGSettings], Error> = .success([])
    var fetchResult: Result<[TGSettings], Error> = .success([])
    var countResult: Int = 0
    var createResult: TGSettings?

    var context: NSManagedObjectContext {
        fatalError("Mock repositories don't use real contexts")
    }

    func create() -> TGSettings {
        recordCall("create")
        guard let result = createResult else {
            fatalError("MockSettingsRepository.create() - configure createResult")
        }
        return result
    }

    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [TGSettings] {
        recordCall("fetch")
        return try fetchResult.get()
    }

    func fetchOne(predicate: NSPredicate) async throws -> TGSettings? {
        recordCall("fetchOne")
        return settings
    }

    func fetchById(_ id: UUID) async throws -> TGSettings? {
        recordCall("fetchById", arguments: ["id": id])
        return fetchByIdResult ?? settings
    }

    func count(predicate: NSPredicate?) async throws -> Int {
        recordCall("count")
        return countResult
    }

    func save() async throws {
        recordCall("save")
        if shouldThrowOnSave { throw saveError }
    }

    func delete(_ entity: TGSettings) async throws {
        recordCall("delete", arguments: ["id": entity.id as Any])
        if shouldThrowOnDelete { throw deleteError }
        settings = nil
    }

    func deleteAll(predicate: NSPredicate?) async throws {
        recordCall("deleteAll")
        if shouldThrowOnDelete { throw deleteError }
        settings = nil
    }

    func getSettings() async throws -> TGSettings {
        recordCall("getSettings")
        guard let result = getSettingsResult ?? settings else {
            fatalError("MockSettingsRepository.getSettings() - configure getSettingsResult")
        }
        return result
    }

    func updateSettings(_ update: (TGSettings) -> Void) async throws {
        recordCall("updateSettings")
        if let settings = settings {
            update(settings)
        }
        if shouldThrowOnSave { throw saveError }
    }
}
