import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("StrategyOutcomeRepository Tests")
struct StrategyOutcomeRepositoryTests {

    // MARK: - Create Tests

    @Test("Create outcome saves to context")
    func createOutcome() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Test Strategy")
        let outcome = stack.createStrategyOutcome(strategy: strategy, result: .success)

        try stack.save()

        let fetched = try await repo.fetchById(outcome.id!)
        #expect(fetched != nil)
    }

    @Test("Create outcome with failure result")
    func createOutcome_failureResult() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Test Strategy")
        let outcome = stack.createStrategyOutcome(strategy: strategy, result: .failure)

        try stack.save()

        let fetched = try await repo.fetchById(outcome.id!)
        #expect(fetched?.outcomeResult == .failure)
    }

    @Test("Create outcome with partial result")
    func createOutcome_partialResult() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Test Strategy")
        let outcome = stack.createStrategyOutcome(strategy: strategy, result: .partial)

        try stack.save()

        let fetched = try await repo.fetchById(outcome.id!)
        #expect(fetched?.outcomeResult == .partial)
    }

    // MARK: - Fetch By Strategy Tests

    @Test("Fetch by strategy returns outcomes for strategy")
    func fetchByStrategy_returnsOutcomes() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy1 = stack.createStrategy(name: "Strategy 1")
        let strategy2 = stack.createStrategy(name: "Strategy 2")

        _ = stack.createStrategyOutcome(strategy: strategy1, result: .success)
        _ = stack.createStrategyOutcome(strategy: strategy1, result: .partial)
        _ = stack.createStrategyOutcome(strategy: strategy2, result: .success)

        try stack.save()

        let outcomes = try await repo.fetchByStrategy(strategy1)

        #expect(outcomes.count == 2)
        #expect(outcomes.allSatisfy { $0.strategy == strategy1 })
    }

    @Test("Fetch by strategy returns empty for strategy with no outcomes")
    func fetchByStrategy_noOutcomes_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "New Strategy")

        try stack.save()

        let outcomes = try await repo.fetchByStrategy(strategy)

        #expect(outcomes.isEmpty)
    }

    @Test("Fetch by strategy returns only outcomes for that strategy")
    func fetchByStrategy_onlyMatchingStrategy() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy1 = stack.createStrategy(name: "Strategy 1")
        let strategy2 = stack.createStrategy(name: "Strategy 2")

        _ = stack.createStrategyOutcome(strategy: strategy1, result: .success)
        _ = stack.createStrategyOutcome(strategy: strategy2, result: .success)
        _ = stack.createStrategyOutcome(strategy: strategy2, result: .success)

        try stack.save()

        let strategy1Outcomes = try await repo.fetchByStrategy(strategy1)
        let strategy2Outcomes = try await repo.fetchByStrategy(strategy2)

        #expect(strategy1Outcomes.count == 1)
        #expect(strategy2Outcomes.count == 2)
    }

    // MARK: - Fetch Recent Tests

    @Test("Fetch recent orders by date descending")
    func fetchRecent_ordersByDateDescending() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Strategy")

        let oldOutcome = stack.createStrategyOutcome(strategy: strategy, result: .success)
        oldOutcome.date = Date.testYesterday

        let recentOutcome = stack.createStrategyOutcome(strategy: strategy, result: .success)
        recentOutcome.date = Date()

        try stack.save()

        let outcomes = try await repo.fetchRecent(limit: 10)

        #expect(outcomes.count == 2)
        // Most recent should be first
        #expect(outcomes.first?.date ?? Date.distantPast > outcomes.last?.date ?? Date.distantFuture)
    }

    @Test("Fetch recent respects limit")
    func fetchRecent_respectsLimit() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Strategy")

        for _ in 0..<10 {
            _ = stack.createStrategyOutcome(strategy: strategy, result: .success)
        }

        try stack.save()

        let outcomes = try await repo.fetchRecent(limit: 5)

        #expect(outcomes.count == 5)
    }

    @Test("Fetch recent returns fewer than limit when not enough outcomes")
    func fetchRecent_fewerThanLimit() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Strategy")
        _ = stack.createStrategyOutcome(strategy: strategy, result: .success)
        _ = stack.createStrategyOutcome(strategy: strategy, result: .success)

        try stack.save()

        let outcomes = try await repo.fetchRecent(limit: 10)

        #expect(outcomes.count == 2)
    }

    @Test("Fetch recent with limit 0 returns empty")
    func fetchRecent_limitZero_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Strategy")
        _ = stack.createStrategyOutcome(strategy: strategy, result: .success)

        try stack.save()

        let outcomes = try await repo.fetchRecent(limit: 0)

        #expect(outcomes.isEmpty)
    }

    @Test("Fetch recent returns outcomes from multiple strategies")
    func fetchRecent_multipleStrategies() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy1 = stack.createStrategy(name: "Strategy 1")
        let strategy2 = stack.createStrategy(name: "Strategy 2")

        _ = stack.createStrategyOutcome(strategy: strategy1, result: .success)
        _ = stack.createStrategyOutcome(strategy: strategy2, result: .success)

        try stack.save()

        let outcomes = try await repo.fetchRecent(limit: 10)

        #expect(outcomes.count == 2)
    }

    // MARK: - Delete Tests

    @Test("Delete outcome removes from context")
    func deleteOutcome() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Test Strategy")
        let outcome = stack.createStrategyOutcome(strategy: strategy, result: .success)
        let outcomeId = outcome.id!

        try stack.save()

        try await repo.delete(outcome)

        let fetched = try await repo.fetchById(outcomeId)
        #expect(fetched == nil)
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct outcome")
    func fetchById_returnsOutcome() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Test Strategy")
        let outcome = stack.createStrategyOutcome(strategy: strategy, result: .success)
        let outcomeId = outcome.id!

        try stack.save()

        let fetched = try await repo.fetchById(outcomeId)

        #expect(fetched != nil)
        #expect(fetched?.id == outcomeId)
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty database returns empty array")
    func fetchRecent_emptyDatabase_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let outcomes = try await repo.fetchRecent(limit: 10)

        #expect(outcomes.isEmpty)
    }

    @Test("Strategy with many outcomes")
    func fetchByStrategy_manyOutcomes() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Popular Strategy")

        for _ in 0..<50 {
            _ = stack.createStrategyOutcome(strategy: strategy, result: .success)
        }

        try stack.save()

        let outcomes = try await repo.fetchByStrategy(strategy)

        #expect(outcomes.count == 50)
    }

    @Test("Outcome with notes")
    func outcomeWithNotes() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Test Strategy")
        let outcome = stack.createStrategyOutcome(strategy: strategy, result: .success)
        outcome.notes = "This strategy worked really well!"

        try stack.save()

        let fetched = try await repo.fetchById(outcome.id!)
        #expect(fetched?.notes == "This strategy worked really well!")
    }

    @Test("Outcome with task info")
    func outcomeWithTaskInfo() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyOutcomeRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Test Strategy")
        let outcome = stack.createStrategyOutcome(strategy: strategy, result: .success)
        outcome.taskTitle = "My Important Task"
        outcome.taskType = "work"

        try stack.save()

        let fetched = try await repo.fetchById(outcome.id!)
        #expect(fetched?.taskTitle == "My Important Task")
        #expect(fetched?.taskType == "work")
    }
}
