import XCTest
@testable import Tangentle

/// Performance benchmarks for StrategyRepository operations.
/// Tests strategy lookup and scoring performance which is critical for
/// quick ADHD coaching recommendations.
final class StrategyRepositoryPerformanceTests: XCTestCase {

    var stack: TestCoreDataStack!
    var repo: StrategyRepository!

    override func setUp() {
        super.setUp()
        stack = TestCoreDataStack()
        repo = StrategyRepository(context: stack.context)
    }

    override func tearDown() {
        PerformanceTestData.clearAllData(in: stack.context)
        stack = nil
        repo = nil
        super.tearDown()
    }

    // MARK: - Fetch By Problem Type Performance

    func testFetchByProblemType_50strategies_performance() throws {
        PerformanceTestData.seedStrategies(50, outcomesPerStrategy: 10, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchByProblemType("too_big")
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchByProblemType_100strategies_performance() throws {
        PerformanceTestData.seedStrategies(100, outcomesPerStrategy: 10, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchByProblemType("too_big")
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchByProblemType_200strategies_performance() throws {
        PerformanceTestData.seedStrategies(200, outcomesPerStrategy: 10, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchByProblemType("too_big")
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Fetch Top Rated Performance

    func testFetchTopRated_50strategies_performance() throws {
        PerformanceTestData.seedStrategies(50, outcomesPerStrategy: 20, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchTopRated(limit: 10)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchTopRated_100strategies_performance() throws {
        PerformanceTestData.seedStrategies(100, outcomesPerStrategy: 50, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchTopRated(limit: 10)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchTopRated_200strategies_manyOutcomes_performance() throws {
        PerformanceTestData.seedStrategies(200, outcomesPerStrategy: 100, in: stack.context)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchTopRated(limit: 10)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Fetch All Strategies Performance

    func testFetchAll_100strategies_performance() throws {
        PerformanceTestData.seedStrategies(100, outcomesPerStrategy: 10, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchAll()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchAll_200strategies_performance() throws {
        PerformanceTestData.seedStrategies(200, outcomesPerStrategy: 10, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchAll()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Fetch Active Strategies Performance

    func testFetchActive_100strategies_performance() throws {
        PerformanceTestData.seedStrategies(100, outcomesPerStrategy: 10, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchActive()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Save Strategy with Outcomes Performance

    func testSave_strategyWithManyOutcomes_performance() throws {
        measure(metrics: [XCTClockMetric()]) {
            let strategy = TGStrategy(context: stack.context)
            strategy.id = UUID()
            strategy.name = "Test Strategy"
            strategy.strategyDescription = "Test description"
            strategy.problemTypesArray = ["too_big"]
            strategy.taskTypesArray = ["all"]
            strategy.source = "test"
            strategy.isActive = true
            strategy.createdAt = Date()
            strategy.updatedAt = Date()

            // Add 50 outcomes
            for i in 0..<50 {
                let outcome = TGStrategyOutcome(context: stack.context)
                outcome.id = UUID()
                outcome.result = ["success", "partial", "failure"][i % 3]
                outcome.problemType = "too_big"
                outcome.date = Date().addingTimeInterval(TimeInterval(-i * 86400))
                outcome.strategy = strategy
            }

            let expectation = expectation(description: "save")
            Task {
                try? await repo.save()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 30)
        }
    }
}
