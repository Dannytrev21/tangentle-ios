import Foundation

/// Service for managing ADHD strategies and coaching
final class StrategyService: StrategyServiceProtocol {
    private let strategyRepository: StrategyRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    init(
        strategyRepository: StrategyRepositoryProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.strategyRepository = strategyRepository
        self.settingsRepository = settingsRepository
    }

    // MARK: - Fetch Operations

    func getStrategiesForProblem(_ problemType: String) async throws -> [TGStrategy] {
        let strategies = try await strategyRepository.fetchByProblemType(problemType)
        return strategies.sorted { $0.score > $1.score }
    }

    func getTopStrategies(limit: Int = 5) async throws -> [TGStrategy] {
        try await strategyRepository.fetchTopRated(limit: limit)
    }

    // MARK: - Outcome Recording

    func recordOutcome(
        strategy: TGStrategy,
        result: OutcomeResult,
        problemType: String,
        taskTitle: String,
        notes: String?
    ) async throws {
        strategy.recordOutcome(
            result: result,
            problemType: problemType,
            taskTitle: taskTitle,
            notes: notes
        )
        try await strategyRepository.save()
    }

    // MARK: - Scoring

    func calculateScore(for strategy: TGStrategy) -> Double {
        strategy.score
    }
}
