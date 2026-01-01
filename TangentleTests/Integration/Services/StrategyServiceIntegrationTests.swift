import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("StrategyService Integration Tests")
struct StrategyServiceIntegrationTests {

    // MARK: - Record Outcome Integration

    @Test("Record outcome creates outcome entity")
    func strategyService_recordOutcome_createsOutcomeEntity() async throws {
        let stack = TestCoreDataStack()
        let strategy = stack.createStrategy(name: "Strategy")
        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        try await strategyService.recordOutcome(
            strategy: strategy,
            result: .success,
            problemType: "too_big",
            taskTitle: "Test Task",
            notes: nil
        )

        #expect(strategy.outcomes?.count == 1)
    }

    @Test("Record outcome updates strategy score")
    func strategyService_recordOutcome_updatesScore() async throws {
        let stack = TestCoreDataStack()
        let strategy = stack.createStrategy(name: "Strategy")
        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let initialScore = strategyService.calculateScore(for: strategy)

        try await strategyService.recordOutcome(
            strategy: strategy,
            result: .success,
            problemType: "too_big",
            taskTitle: "Test Task",
            notes: nil
        )

        let newScore = strategyService.calculateScore(for: strategy)
        #expect(newScore > initialScore)
    }

    @Test("Record multiple outcomes accumulates correctly")
    func strategyService_recordMultipleOutcomes_accumulatesCorrectly() async throws {
        let stack = TestCoreDataStack()
        let strategy = stack.createStrategy(name: "Strategy")
        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        for i in 0..<5 {
            try await strategyService.recordOutcome(
                strategy: strategy,
                result: .success,
                problemType: "too_big",
                taskTitle: "Task \(i)",
                notes: nil
            )
        }

        #expect(strategy.outcomes?.count == 5)
    }

    @Test("Record outcome with notes persists notes")
    func strategyService_recordOutcomeWithNotes_persistsNotes() async throws {
        let stack = TestCoreDataStack()
        let strategy = stack.createStrategy(name: "Strategy")
        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        try await strategyService.recordOutcome(
            strategy: strategy,
            result: .success,
            problemType: "too_big",
            taskTitle: "Test Task",
            notes: "This worked great!"
        )

        let outcomes = strategy.outcomes?.allObjects as? [TGStrategyOutcome] ?? []
        #expect(outcomes.first?.notes == "This worked great!")
    }

    // MARK: - Get Strategies Integration

    @Test("Get strategies for problem returns matching strategies")
    func strategyService_getStrategiesForProblem_returnsMatching() async throws {
        let stack = TestCoreDataStack()
        _ = stack.createStrategy(name: "Too Big Strategy", problemTypes: ["too_big"])
        _ = stack.createStrategy(name: "Boring Strategy", problemTypes: ["boring"])
        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let strategies = try await strategyService.getStrategiesForProblem("too_big")

        #expect(strategies.count == 1)
        #expect(strategies.first?.name == "Too Big Strategy")
    }

    @Test("Get strategies for problem returns empty for no matches")
    func strategyService_getStrategiesForProblem_returnsEmptyForNoMatches() async throws {
        let stack = TestCoreDataStack()
        _ = stack.createStrategy(name: "Too Big Strategy", problemTypes: ["too_big"])
        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let strategies = try await strategyService.getStrategiesForProblem("scary")

        #expect(strategies.isEmpty)
    }

    @Test("Get top strategies ordered by score")
    func strategyService_getTopStrategies_orderedByScore() async throws {
        let stack = TestCoreDataStack()

        // Create strategies with different outcome histories
        let highScore = stack.createStrategy(name: "High Score")
        for _ in 0..<10 {
            _ = stack.createStrategyOutcome(strategy: highScore, result: .success)
        }

        let lowScore = stack.createStrategy(name: "Low Score")
        _ = stack.createStrategyOutcome(strategy: lowScore, result: .failure)

        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let strategies = try await strategyService.getTopStrategies(limit: 10)

        // High score should come first
        #expect(strategies.first?.name == "High Score")
    }

    @Test("Get top strategies respects limit")
    func strategyService_getTopStrategies_respectsLimit() async throws {
        let stack = TestCoreDataStack()

        for i in 0..<10 {
            _ = stack.createStrategy(name: "Strategy \(i)")
        }
        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let strategies = try await strategyService.getTopStrategies(limit: 3)

        #expect(strategies.count == 3)
    }

    // MARK: - Score Calculation Integration

    @Test("Calculate score with mixed outcomes")
    func strategyService_calculateScore_withMixedOutcomes() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "Mixed Strategy")
        _ = stack.createStrategyOutcome(strategy: strategy, result: .success)
        _ = stack.createStrategyOutcome(strategy: strategy, result: .success)
        _ = stack.createStrategyOutcome(strategy: strategy, result: .partial)
        _ = stack.createStrategyOutcome(strategy: strategy, result: .failure)
        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let score = strategyService.calculateScore(for: strategy)
        // With 2 successes (2.0), 1 partial (0.5), 1 failure (0), total = 2.5
        // Score should be positive since success rate > 0
        #expect(score > 0)
    }

    @Test("Calculate score increases with more successes")
    func strategyService_calculateScore_increasesWithMoreSuccesses() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "Growing Strategy")
        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        var previousScore = strategyService.calculateScore(for: strategy)

        for _ in 0..<5 {
            _ = stack.createStrategyOutcome(strategy: strategy, result: .success)
            try stack.save()
            let newScore = strategyService.calculateScore(for: strategy)
            #expect(newScore >= previousScore)
            previousScore = newScore
        }
    }

    // MARK: - Multi-Strategy Integration

    @Test("Different strategies have independent scores")
    func strategyService_differentStrategies_independentScores() async throws {
        let stack = TestCoreDataStack()

        let strategy1 = stack.createStrategy(name: "Strategy 1")
        let strategy2 = stack.createStrategy(name: "Strategy 2")

        // Strategy 1: all successes
        for _ in 0..<5 {
            _ = stack.createStrategyOutcome(strategy: strategy1, result: .success)
        }

        // Strategy 2: all failures
        for _ in 0..<5 {
            _ = stack.createStrategyOutcome(strategy: strategy2, result: .failure)
        }

        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let score1 = strategyService.calculateScore(for: strategy1)
        let score2 = strategyService.calculateScore(for: strategy2)

        #expect(score1 > score2)
    }

    @Test("Strategy with multiple problem types found by any matching")
    func strategyService_strategyWithMultipleProblemTypes_foundByAny() async throws {
        let stack = TestCoreDataStack()
        _ = stack.createStrategy(name: "Multi-Problem Strategy", problemTypes: ["too_big", "boring", "scary"])
        try stack.save()

        let strategyService = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let forTooBig = try await strategyService.getStrategiesForProblem("too_big")
        let forBoring = try await strategyService.getStrategiesForProblem("boring")
        let forScary = try await strategyService.getStrategiesForProblem("scary")

        #expect(forTooBig.count == 1)
        #expect(forBoring.count == 1)
        #expect(forScary.count == 1)
    }
}
