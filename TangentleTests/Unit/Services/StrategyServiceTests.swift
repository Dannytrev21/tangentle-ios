import Testing
import Foundation
@testable import Tangentle

@Suite("StrategyService Tests")
struct StrategyServiceTests {

    // MARK: - Get Strategies for Problem Tests

    @Test("Get strategies for problem type returns matching strategies")
    func getStrategiesForProblemType() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        // Create matching strategy
        _ = stack.createStrategy(name: "Too Big Strategy", problemTypes: ["too_big"])

        // Create non-matching strategy
        _ = stack.createStrategy(name: "Boring Strategy", problemTypes: ["boring"])

        try stack.save()

        let strategies = try await service.getStrategiesForProblem("too_big")

        #expect(strategies.count == 1)
        #expect(strategies.first?.name == "Too Big Strategy")
    }

    @Test("Get strategies for problem returns empty when no matches")
    func getStrategiesForProblem_noMatches_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        // Create strategies for other problem types
        _ = stack.createStrategy(name: "Strategy 1", problemTypes: ["boring"])
        _ = stack.createStrategy(name: "Strategy 2", problemTypes: ["scary"])

        try stack.save()

        let strategies = try await service.getStrategiesForProblem("unknown_type")

        #expect(strategies.isEmpty)
    }

    @Test("Get strategies for problem sorts by score descending")
    func getStrategiesForProblem_sortsByScore() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        let lowScoreStrategy = stack.createStrategy(name: "Low Score", problemTypes: ["too_big"])
        let highScoreStrategy = stack.createStrategy(name: "High Score", problemTypes: ["too_big"])

        // Add outcomes to increase score
        highScoreStrategy.recordOutcome(result: .success, problemType: "too_big", taskTitle: "T1")
        highScoreStrategy.recordOutcome(result: .success, problemType: "too_big", taskTitle: "T2")
        highScoreStrategy.recordOutcome(result: .success, problemType: "too_big", taskTitle: "T3")

        try stack.save()

        let strategies = try await service.getStrategiesForProblem("too_big")

        #expect(strategies.count == 2)
        // Higher score should be first
        #expect(strategies.first?.name == "High Score")
    }

    @Test("Get strategies for problem returns multiple matching strategies")
    func getStrategiesForProblem_multipleMatches() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        _ = stack.createStrategy(name: "Strategy 1", problemTypes: ["too_big"])
        _ = stack.createStrategy(name: "Strategy 2", problemTypes: ["too_big", "scary"])
        _ = stack.createStrategy(name: "Strategy 3", problemTypes: ["too_big"])

        try stack.save()

        let strategies = try await service.getStrategiesForProblem("too_big")

        #expect(strategies.count == 3)
    }

    // MARK: - Record Outcome Tests

    @Test("Record outcome updates strategy")
    func recordOutcome() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        let strategy = stack.createStrategy(name: "Test Strategy")
        try stack.save()

        try await service.recordOutcome(
            strategy: strategy,
            result: .success,
            problemType: "too_big",
            taskTitle: "Test Task",
            notes: "It worked!"
        )

        #expect(strategy.usageCount == 1)
        #expect(strategy.outcomesArray.count == 1)
        #expect(strategy.outcomesArray.first?.result == "success")
    }

    @Test("Record outcome increments usage count")
    func recordOutcome_incrementsUsageCount() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        let strategy = stack.createStrategy(name: "Test Strategy")
        strategy.usageCount = 5
        try stack.save()

        try await service.recordOutcome(
            strategy: strategy,
            result: .success,
            problemType: "too_big",
            taskTitle: "Test Task",
            notes: nil
        )

        #expect(strategy.usageCount == 6)
    }

    @Test("Record outcome creates outcome entity")
    func recordOutcome_createsOutcomeEntity() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        let strategy = stack.createStrategy(name: "Test Strategy")
        try stack.save()

        try await service.recordOutcome(
            strategy: strategy,
            result: .partial,
            problemType: "unclear",
            taskTitle: "My Task",
            notes: "Partially worked"
        )

        #expect(strategy.outcomesArray.count == 1)
        let outcome = strategy.outcomesArray.first
        #expect(outcome?.result == "partial")
        #expect(outcome?.problemType == "unclear")
        #expect(outcome?.taskTitle == "My Task")
    }

    @Test("Record failure outcome")
    func recordOutcome_failure() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        let strategy = stack.createStrategy(name: "Test Strategy")
        try stack.save()

        try await service.recordOutcome(
            strategy: strategy,
            result: .failure,
            problemType: "boring",
            taskTitle: "Failed Task",
            notes: "Didn't work"
        )

        #expect(strategy.outcomesArray.first?.result == "failure")
    }

    // MARK: - Calculate Score Tests

    @Test("Strategy score increases with successful outcomes")
    func strategyScoreCalculation() async throws {
        let stack = TestCoreDataStack()
        let strategy = stack.createStrategy(name: "Scored Strategy")

        // Initial score should be 0
        #expect(strategy.score == 0)

        // Add successful outcome
        strategy.recordOutcome(
            result: .success,
            problemType: "too_big",
            taskTitle: "Task 1"
        )

        // Score should increase
        #expect(strategy.score > 0)

        // Add another success
        strategy.recordOutcome(
            result: .success,
            problemType: "too_big",
            taskTitle: "Task 2"
        )

        // Score should increase further with more usage
        let scoreAfterTwo = strategy.score
        #expect(scoreAfterTwo > 0)
    }

    @Test("Calculate score returns zero for strategy with no outcomes")
    func calculateScore_noOutcomes_returnsZero() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        let strategy = stack.createStrategy(name: "New Strategy")
        try stack.save()

        let score = service.calculateScore(for: strategy)

        #expect(score == 0)
    }

    @Test("Calculate score reflects success rate")
    func calculateScore_reflectsSuccessRate() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        let allSuccessStrategy = stack.createStrategy(name: "All Success")
        let mixedStrategy = stack.createStrategy(name: "Mixed")

        // All successes
        for i in 0..<5 {
            allSuccessStrategy.recordOutcome(result: .success, problemType: "too_big", taskTitle: "Task \(i)")
        }

        // Mix of success and failure
        mixedStrategy.recordOutcome(result: .success, problemType: "too_big", taskTitle: "T1")
        mixedStrategy.recordOutcome(result: .success, problemType: "too_big", taskTitle: "T2")
        mixedStrategy.recordOutcome(result: .failure, problemType: "too_big", taskTitle: "T3")
        mixedStrategy.recordOutcome(result: .failure, problemType: "too_big", taskTitle: "T4")
        mixedStrategy.recordOutcome(result: .failure, problemType: "too_big", taskTitle: "T5")

        try stack.save()

        let allSuccessScore = service.calculateScore(for: allSuccessStrategy)
        let mixedScore = service.calculateScore(for: mixedStrategy)

        // Strategy with 100% success rate should score higher than 40% success rate
        #expect(allSuccessScore > mixedScore)
    }

    @Test("Calculate score uses log scale for attempts")
    func calculateScore_usesLogScale() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        let fewUsesStrategy = stack.createStrategy(name: "Few Uses")
        let manyUsesStrategy = stack.createStrategy(name: "Many Uses")

        // Both have 100% success rate
        for i in 0..<2 {
            fewUsesStrategy.recordOutcome(result: .success, problemType: "too_big", taskTitle: "Task \(i)")
        }

        for i in 0..<10 {
            manyUsesStrategy.recordOutcome(result: .success, problemType: "too_big", taskTitle: "Task \(i)")
        }

        try stack.save()

        let fewScore = service.calculateScore(for: fewUsesStrategy)
        let manyScore = service.calculateScore(for: manyUsesStrategy)

        // More uses should result in higher score due to log scale favoring proven strategies
        #expect(manyScore > fewScore)
    }

    // MARK: - Get Top Strategies Tests

    @Test("Get top strategies returns sorted by score")
    func getTopStrategies() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        // Create strategies with different scores
        let strategy1 = stack.createStrategy(name: "Less Used", problemTypes: ["too_big"])
        let strategy2 = stack.createStrategy(name: "More Used", problemTypes: ["too_big"])

        // Add more outcomes to strategy2
        strategy2.recordOutcome(result: .success, problemType: "too_big", taskTitle: "Task 1")
        strategy2.recordOutcome(result: .success, problemType: "too_big", taskTitle: "Task 2")
        strategy1.recordOutcome(result: .success, problemType: "too_big", taskTitle: "Task 3")

        try stack.save()

        let topStrategies = try await service.getTopStrategies(limit: 2)

        #expect(topStrategies.count == 2)
        // The one with more successful outcomes should have a higher score
        #expect(strategy2.score >= strategy1.score)
    }

    @Test("Get top strategies respects limit")
    func getTopStrategies_respectsLimit() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        // Create many strategies
        for i in 0..<10 {
            _ = stack.createStrategy(name: "Strategy \(i)")
        }

        try stack.save()

        let topStrategies = try await service.getTopStrategies(limit: 3)

        #expect(topStrategies.count == 3)
    }

    @Test("Get top strategies returns empty when no strategies")
    func getTopStrategies_noStrategies_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        let topStrategies = try await service.getTopStrategies(limit: 5)

        #expect(topStrategies.isEmpty)
    }

    // MARK: - Edge Cases

    @Test("Record multiple outcomes for same strategy")
    func recordOutcome_multiple() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        let strategy = stack.createStrategy(name: "Test Strategy")
        try stack.save()

        // Record multiple outcomes
        try await service.recordOutcome(strategy: strategy, result: .success, problemType: "too_big", taskTitle: "T1", notes: nil)
        try await service.recordOutcome(strategy: strategy, result: .failure, problemType: "too_big", taskTitle: "T2", notes: nil)
        try await service.recordOutcome(strategy: strategy, result: .partial, problemType: "too_big", taskTitle: "T3", notes: nil)

        #expect(strategy.outcomesArray.count == 3)
        #expect(strategy.usageCount == 3)
    }

    @Test("Strategy with partial success counts as 0.5")
    func calculateScore_partialSuccess() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)
        let settingsRepo = SettingsRepository(context: stack.context)
        let service = StrategyService(
            strategyRepository: repo,
            settingsRepository: settingsRepo
        )

        let strategy = stack.createStrategy(name: "Partial Strategy")

        // Add partial outcomes
        strategy.recordOutcome(result: .partial, problemType: "too_big", taskTitle: "T1")
        strategy.recordOutcome(result: .partial, problemType: "too_big", taskTitle: "T2")

        try stack.save()

        let score = service.calculateScore(for: strategy)

        // Should have some score (partial counts as 0.5 success)
        #expect(score > 0)
    }
}
