import Testing
import Foundation
import CoreData
@testable import Tangentle

@Suite("StrategyRepository Tests")
struct StrategyRepositoryTests {

    // MARK: - Create Tests

    @Test("Create strategy saves to context")
    func createStrategy() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let strategy = repo.create()
        strategy.id = UUID()
        strategy.name = "New Strategy"
        strategy.strategyDescription = "A helpful strategy"
        strategy.problemTypesArray = ["too_big"]
        strategy.taskTypesArray = ["all"]
        strategy.source = "user"
        strategy.isActive = true
        strategy.createdAt = Date()
        strategy.updatedAt = Date()

        try await repo.save()

        let fetched = try await repo.fetchById(strategy.id!)
        #expect(fetched != nil)
        #expect(fetched?.name == "New Strategy")
    }

    // MARK: - Fetch Active Tests

    @Test("Fetch active returns only active strategies")
    func fetchActive_returnsActive() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let active = stack.createStrategy(name: "Active")
        active.isActive = true
        let inactive = stack.createStrategy(name: "Inactive")
        inactive.isActive = false

        try stack.save()

        let strategies = try await repo.fetchActive()

        #expect(strategies.count == 1)
        #expect(strategies.first?.name == "Active")
    }

    @Test("Fetch active excludes inactive")
    func fetchActive_excludesInactive() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Inactive")
        strategy.isActive = false

        try stack.save()

        let strategies = try await repo.fetchActive()

        #expect(strategies.isEmpty)
    }

    @Test("Fetch active returns multiple strategies sorted by name")
    func fetchActive_sortedByName() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        _ = stack.createStrategy(name: "Zebra Strategy")
        _ = stack.createStrategy(name: "Alpha Strategy")
        _ = stack.createStrategy(name: "Beta Strategy")

        try stack.save()

        let strategies = try await repo.fetchActive()

        #expect(strategies.count == 3)
        #expect(strategies[0].name == "Alpha Strategy")
        #expect(strategies[1].name == "Beta Strategy")
        #expect(strategies[2].name == "Zebra Strategy")
    }

    // MARK: - Fetch by Problem Type Tests

    @Test("Fetch by problem type filters correctly")
    func fetchByProblemType_filtersCorrectly() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        _ = stack.createStrategy(name: "Too Big Strategy", problemTypes: ["too_big"])
        _ = stack.createStrategy(name: "Boring Strategy", problemTypes: ["boring"])
        _ = stack.createStrategy(name: "Multi Strategy", problemTypes: ["too_big", "boring"])

        try stack.save()

        let tooBig = try await repo.fetchByProblemType("too_big")

        #expect(tooBig.count == 2) // "Too Big Strategy" and "Multi Strategy"
        #expect(tooBig.contains { $0.name == "Too Big Strategy" })
        #expect(tooBig.contains { $0.name == "Multi Strategy" })
    }

    @Test("Fetch by problem type returns empty for unknown type")
    func fetchByProblemType_unknownType_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        _ = stack.createStrategy(name: "Some Strategy", problemTypes: ["too_big"])

        try stack.save()

        let strategies = try await repo.fetchByProblemType("unknown_type")

        #expect(strategies.isEmpty)
    }

    @Test("Fetch by problem type excludes inactive strategies")
    func fetchByProblemType_excludesInactive() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let active = stack.createStrategy(name: "Active", problemTypes: ["too_big"])
        active.isActive = true
        let inactive = stack.createStrategy(name: "Inactive", problemTypes: ["too_big"])
        inactive.isActive = false

        try stack.save()

        let strategies = try await repo.fetchByProblemType("too_big")

        #expect(strategies.count == 1)
        #expect(strategies.first?.name == "Active")
    }

    @Test("No strategies for problem type returns empty")
    func fetchByProblemType_noStrategies_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let strategies = try await repo.fetchByProblemType("too_big")

        #expect(strategies.isEmpty)
    }

    // MARK: - Fetch Top Rated Tests

    @Test("Fetch top rated respects limit")
    func fetchTopRated_respectsLimit() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        for i in 0..<10 {
            _ = stack.createStrategy(name: "Strategy \(i)")
        }

        try stack.save()

        let strategies = try await repo.fetchTopRated(limit: 3)

        #expect(strategies.count == 3)
    }

    @Test("Fetch top rated orders by score descending")
    func fetchTopRated_ordersByScore() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        // Create strategies with different outcomes to get different scores
        let lowStrategy = stack.createStrategy(name: "Low Score")
        let highStrategy = stack.createStrategy(name: "High Score")

        // Add success outcomes to high strategy
        _ = stack.createStrategyOutcome(strategy: highStrategy, result: .success)
        _ = stack.createStrategyOutcome(strategy: highStrategy, result: .success)
        _ = stack.createStrategyOutcome(strategy: highStrategy, result: .success)

        // Add failure outcome to low strategy
        _ = stack.createStrategyOutcome(strategy: lowStrategy, result: .failure)

        try stack.save()

        let strategies = try await repo.fetchTopRated(limit: 2)

        #expect(strategies.count == 2)
        #expect(strategies.first?.name == "High Score")
    }

    @Test("Fetch top rated returns fewer than limit when not enough strategies")
    func fetchTopRated_fewerThanLimit() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        _ = stack.createStrategy(name: "Only Strategy")

        try stack.save()

        let strategies = try await repo.fetchTopRated(limit: 10)

        #expect(strategies.count == 1)
    }

    @Test("Strategy with equal scores maintains consistent order")
    func fetchTopRated_equalScores_consistentOrder() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        for i in 0..<5 {
            _ = stack.createStrategy(name: "Strategy \(i)")
        }

        try stack.save()

        let first = try await repo.fetchTopRated(limit: 5)
        let second = try await repo.fetchTopRated(limit: 5)

        // Order should be consistent
        #expect(first.map { $0.name } == second.map { $0.name })
    }

    // MARK: - Fetch by Source Tests

    @Test("Fetch by source filters correctly")
    func fetchBySource_filtersCorrectly() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let defaultStrategy = stack.createStrategy(name: "Default")
        defaultStrategy.source = "default"
        let userStrategy = stack.createStrategy(name: "User")
        userStrategy.source = "user"

        try stack.save()

        let defaults = try await repo.fetchBySource("default")

        #expect(defaults.count == 1)
        #expect(defaults.first?.name == "Default")

        let user = try await repo.fetchBySource("user")

        #expect(user.count == 1)
        #expect(user.first?.name == "User")
    }

    @Test("Fetch by source returns empty for unknown source")
    func fetchBySource_unknownSource_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Default")
        strategy.source = "default"

        try stack.save()

        let strategies = try await repo.fetchBySource("custom")

        #expect(strategies.isEmpty)
    }

    // MARK: - Delete Tests

    @Test("Delete strategy removes from context")
    func deleteStrategy() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "To Delete")
        let strategyId = strategy.id!

        try stack.save()

        try await repo.delete(strategy)

        let fetched = try await repo.fetchById(strategyId)
        #expect(fetched == nil)
    }

    // MARK: - Fetch All Tests

    @Test("Fetch all returns all strategies including inactive")
    func fetchAll_returnsAll() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        _ = stack.createStrategy(name: "Strategy 1")
        _ = stack.createStrategy(name: "Strategy 2")
        let inactive = stack.createStrategy(name: "Strategy 3")
        inactive.isActive = false

        try stack.save()

        let strategies = try await repo.fetchAll()

        #expect(strategies.count == 3) // All, regardless of active status
    }

    // MARK: - Fetch by ID Tests

    @Test("Fetch by ID returns correct strategy")
    func fetchById_returnsStrategy() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let strategy = stack.createStrategy(name: "Find Me")
        let strategyId = strategy.id!

        try stack.save()

        let fetched = try await repo.fetchById(strategyId)

        #expect(fetched != nil)
        #expect(fetched?.name == "Find Me")
    }

    @Test("Fetch by ID returns nil for non-existent ID")
    func fetchById_nonExistent_returnsNil() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let fetched = try await repo.fetchById(UUID())

        #expect(fetched == nil)
    }

    // MARK: - Edge Cases

    @Test("Empty database returns empty array")
    func fetchActive_emptyDatabase_returnsEmpty() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let strategies = try await repo.fetchActive()

        #expect(strategies.isEmpty)
    }

    @Test("Strategy with multiple problem types")
    func strategyWithMultipleProblemTypes() async throws {
        let stack = TestCoreDataStack()
        let repo = StrategyRepository(context: stack.context)

        let strategy = stack.createStrategy(
            name: "Multi-Problem Strategy",
            problemTypes: ["too_big", "boring", "unclear", "scary"]
        )

        try stack.save()

        let fetched = try await repo.fetchById(strategy.id!)
        #expect(fetched?.problemTypesArray.count == 4)

        // Should appear in all problem type queries
        let tooBig = try await repo.fetchByProblemType("too_big")
        let boring = try await repo.fetchByProblemType("boring")
        let unclear = try await repo.fetchByProblemType("unclear")
        let scary = try await repo.fetchByProblemType("scary")

        #expect(tooBig.contains { $0.id == strategy.id })
        #expect(boring.contains { $0.id == strategy.id })
        #expect(unclear.contains { $0.id == strategy.id })
        #expect(scary.contains { $0.id == strategy.id })
    }
}
