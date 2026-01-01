import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("Strategy Relationship Integration Tests")
struct StrategyRelationshipTests {

    // MARK: - Strategy-Outcome Relationships

    @Test("Adding outcome updates strategy relationship")
    func strategyOutcome_addingOutcome_updatesStrategy() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "Strategy")
        let outcome = stack.createStrategyOutcome(strategy: strategy, result: .success)
        try stack.save()

        #expect(outcome.strategy == strategy)
        #expect(strategy.outcomes?.contains(outcome) == true)
    }

    @Test("Multiple outcomes maintain relationship")
    func strategyOutcome_multipleOutcomes_maintainRelationship() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "Strategy")
        for _ in 0..<5 {
            _ = stack.createStrategyOutcome(strategy: strategy, result: .success)
        }
        try stack.save()

        #expect(strategy.outcomes?.count == 5)
    }

    @Test("Outcomes from different strategies are separate")
    func strategyOutcome_differentStrategies_separateOutcomes() async throws {
        let stack = TestCoreDataStack()

        let strategy1 = stack.createStrategy(name: "Strategy 1")
        let strategy2 = stack.createStrategy(name: "Strategy 2")

        _ = stack.createStrategyOutcome(strategy: strategy1, result: .success)
        _ = stack.createStrategyOutcome(strategy: strategy1, result: .success)
        _ = stack.createStrategyOutcome(strategy: strategy2, result: .failure)

        try stack.save()

        #expect(strategy1.outcomes?.count == 2)
        #expect(strategy2.outcomes?.count == 1)
    }

    @Test("Outcome results correctly tracked")
    func strategyOutcome_resultsTracked() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "Strategy")
        let success = stack.createStrategyOutcome(strategy: strategy, result: .success)
        let partial = stack.createStrategyOutcome(strategy: strategy, result: .partial)
        let failure = stack.createStrategyOutcome(strategy: strategy, result: .failure)
        try stack.save()

        let outcomes = strategy.outcomes?.allObjects as? [TGStrategyOutcome] ?? []
        #expect(outcomes.count == 3)
        #expect(outcomes.contains { $0.result == OutcomeResult.success.rawValue })
        #expect(outcomes.contains { $0.result == OutcomeResult.partial.rawValue })
        #expect(outcomes.contains { $0.result == OutcomeResult.failure.rawValue })
    }

    // MARK: - Strategy-Task Relationships

    @Test("Strategy linked to task bidirectionally")
    func strategyTask_linkBidirectional() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "Strategy")
        let task = stack.createTask(title: "Task")
        strategy.addToLinkedTasks(task)
        try stack.save()

        #expect(strategy.linkedTasks?.contains(task) == true)
        #expect(task.linkedStrategies?.contains(strategy) == true)
    }

    @Test("Strategy linked to multiple tasks")
    func strategyTask_multipleTasksLinked() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "Strategy")
        let task1 = stack.createTask(title: "Task 1")
        let task2 = stack.createTask(title: "Task 2")
        strategy.addToLinkedTasks(task1)
        strategy.addToLinkedTasks(task2)
        try stack.save()

        #expect(strategy.linkedTasks?.count == 2)
    }

    @Test("Unlinking task clears relationship")
    func strategyTask_unlinkingTask_clearsRelationship() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "Strategy")
        let task = stack.createTask(title: "Task")
        strategy.addToLinkedTasks(task)
        try stack.save()

        strategy.removeFromLinkedTasks(task)
        try stack.save()

        #expect(strategy.linkedTasks?.contains(task) != true)
        #expect(task.linkedStrategies?.contains(strategy) != true)
    }

    // MARK: - Strategy Score Integration

    @Test("Strategy with outcomes can calculate score")
    func strategy_withOutcomes_calculateScore() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "Strategy")
        _ = stack.createStrategyOutcome(strategy: strategy, result: .success)
        _ = stack.createStrategyOutcome(strategy: strategy, result: .success)
        _ = stack.createStrategyOutcome(strategy: strategy, result: .failure)
        try stack.save()

        let service = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let score = service.calculateScore(for: strategy)
        #expect(score > 0)
    }

    @Test("Strategy with no outcomes has zero score")
    func strategy_noOutcomes_zeroScore() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "New Strategy")
        try stack.save()

        let service = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let score = service.calculateScore(for: strategy)
        #expect(score == 0)
    }

    @Test("Strategy with all successes has high score")
    func strategy_allSuccesses_highScore() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "Great Strategy")
        for _ in 0..<10 {
            _ = stack.createStrategyOutcome(strategy: strategy, result: .success)
        }
        try stack.save()

        let service = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let score = service.calculateScore(for: strategy)
        #expect(score > 1) // Should be significantly positive
    }

    @Test("Strategy with all failures has low score")
    func strategy_allFailures_lowScore() async throws {
        let stack = TestCoreDataStack()

        let strategy = stack.createStrategy(name: "Poor Strategy")
        for _ in 0..<5 {
            _ = stack.createStrategyOutcome(strategy: strategy, result: .failure)
        }
        try stack.save()

        let service = StrategyService(
            strategyRepository: StrategyRepository(context: stack.context),
            settingsRepository: SettingsRepository(context: stack.context)
        )

        let score = service.calculateScore(for: strategy)
        // Score should be negative or very low since failure rate is 100%
        #expect(score <= 0)
    }
}
