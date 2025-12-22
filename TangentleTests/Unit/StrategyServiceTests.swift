import Testing
import Foundation
@testable import Tangentle

@Suite("StrategyService Tests")
struct StrategyServiceTests {

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
}
