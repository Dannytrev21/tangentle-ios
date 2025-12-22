import Foundation
import CoreData

// MARK: - Task Repository Protocol

protocol TaskRepositoryProtocol: Repository where Entity == TGTask {
    func fetchTodaysTasks() async throws -> [TGTask]
    func fetchOverdueTasks() async throws -> [TGTask]
    func fetchByProject(_ project: TGProject) async throws -> [TGTask]
    func fetchByStatus(_ status: TaskStatus) async throws -> [TGTask]
    func fetchByPriority(_ priority: Priority) async throws -> [TGTask]
    func fetchScheduledBetween(start: Date, end: Date) async throws -> [TGTask]
    func fetchPending() async throws -> [TGTask]
    func fetchInProgress() async throws -> [TGTask]
    func fetchByEnergy(_ energy: EnergyLevel) async throws -> [TGTask]
}

// MARK: - Project Repository Protocol

protocol ProjectRepositoryProtocol: Repository where Entity == TGProject {
    func fetchActive() async throws -> [TGProject]
    func fetchByGoal(_ goal: TGGoal) async throws -> [TGProject]
    func fetchArchived() async throws -> [TGProject]
}

// MARK: - Goal Repository Protocol

protocol GoalRepositoryProtocol: Repository where Entity == TGGoal {
    func fetchActive() async throws -> [TGGoal]
    func fetchWithUpcomingDeadlines(within days: Int) async throws -> [TGGoal]
}

// MARK: - Strategy Repository Protocol

protocol StrategyRepositoryProtocol: Repository where Entity == TGStrategy {
    func fetchActive() async throws -> [TGStrategy]
    func fetchByProblemType(_ type: String) async throws -> [TGStrategy]
    func fetchTopRated(limit: Int) async throws -> [TGStrategy]
    func fetchBySource(_ source: String) async throws -> [TGStrategy]
}

// MARK: - Strategy Outcome Repository Protocol

protocol StrategyOutcomeRepositoryProtocol: Repository where Entity == TGStrategyOutcome {
    func fetchByStrategy(_ strategy: TGStrategy) async throws -> [TGStrategyOutcome]
    func fetchRecent(limit: Int) async throws -> [TGStrategyOutcome]
}

// MARK: - Routine Repository Protocol

protocol RoutineRepositoryProtocol: Repository where Entity == TGRoutine {
    func fetchEnabled() async throws -> [TGRoutine]
    func fetchByType(_ type: RoutineType) async throws -> [TGRoutine]
    func fetchScheduledForToday() async throws -> [TGRoutine]
}

// MARK: - Routine Step Repository Protocol

protocol RoutineStepRepositoryProtocol: Repository where Entity == TGRoutineStep {
    func fetchByRoutine(_ routine: TGRoutine) async throws -> [TGRoutineStep]
}

// MARK: - Habit Repository Protocol

protocol HabitRepositoryProtocol: Repository where Entity == TGHabit {
    func fetchActive() async throws -> [TGHabit]
    func fetchDueToday() async throws -> [TGHabit]
    func fetchByFrequency(_ frequency: HabitFrequency) async throws -> [TGHabit]
}

// MARK: - Habit Completion Repository Protocol

protocol HabitCompletionRepositoryProtocol: Repository where Entity == TGHabitCompletion {
    func fetchByHabit(_ habit: TGHabit) async throws -> [TGHabitCompletion]
    func fetchForDate(_ date: Date, habit: TGHabit) async throws -> [TGHabitCompletion]
}

// MARK: - Focus Mode Repository Protocol

protocol FocusModeRepositoryProtocol: Repository where Entity == TGFocusMode {
    func fetchActive() async throws -> [TGFocusMode]
    func fetchAutomatic() async throws -> [TGFocusMode]
    func fetchCurrentlyActive() async throws -> TGFocusMode?
}

// MARK: - Mode Repository Protocol

protocol ModeRepositoryProtocol: Repository where Entity == TGMode {
    func fetchDefault() async throws -> TGMode?
    func fetchAll() async throws -> [TGMode]
}

// MARK: - Problem Type Repository Protocol

protocol ProblemTypeRepositoryProtocol: Repository where Entity == TGProblemType {
    func fetchAll() async throws -> [TGProblemType]
    func fetchByIdentifier(_ identifier: String) async throws -> TGProblemType?
    func fetchDefaults() async throws -> [TGProblemType]
}

// MARK: - Tag Repository Protocol

protocol TagRepositoryProtocol: Repository where Entity == TGTag {
    func fetchAll() async throws -> [TGTag]
    func fetchOrCreate(name: String) async throws -> TGTag
    func fetchByName(_ name: String) async throws -> TGTag?
}

// MARK: - Settings Repository Protocol

protocol SettingsRepositoryProtocol: Repository where Entity == TGSettings {
    func getSettings() async throws -> TGSettings
    func updateSettings(_ update: (TGSettings) -> Void) async throws
}
