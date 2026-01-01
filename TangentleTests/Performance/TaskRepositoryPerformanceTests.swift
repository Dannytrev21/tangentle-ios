import XCTest
@testable import Tangentle

/// Performance benchmarks for TaskRepository operations.
/// Tests critical query operations with large datasets to ensure ADHD users
/// experience responsive interactions even with many tasks.
final class TaskRepositoryPerformanceTests: XCTestCase {

    var stack: TestCoreDataStack!
    var repo: TaskRepository!

    override func setUp() {
        super.setUp()
        stack = TestCoreDataStack()
        repo = TaskRepository(context: stack.context)
    }

    override func tearDown() {
        PerformanceTestData.clearAllData(in: stack.context)
        stack = nil
        repo = nil
        super.tearDown()
    }

    // MARK: - Fetch Today's Tasks Performance

    func testFetchTodaysTasks_100tasks_performance() throws {
        PerformanceTestData.seedTasks(100, in: stack.context)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchTodaysTasks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchTodaysTasks_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchTodaysTasks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchTodaysTasks_1000tasks_performance() throws {
        PerformanceTestData.seedTasks(1000, in: stack.context)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchTodaysTasks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Fetch Overdue Tasks Performance

    func testFetchOverdueTasks_100tasks_performance() throws {
        PerformanceTestData.seedTasks(100, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchOverdueTasks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchOverdueTasks_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchOverdueTasks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchOverdueTasks_1000tasks_performance() throws {
        PerformanceTestData.seedTasks(1000, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchOverdueTasks()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Fetch By Status Performance

    func testFetchByStatus_100tasks_performance() throws {
        PerformanceTestData.seedTasks(100, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchByStatus(.pending)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchByStatus_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchByStatus(.pending)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchByStatus_1000tasks_performance() throws {
        PerformanceTestData.seedTasks(1000, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchByStatus(.pending)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Fetch By Priority Performance

    func testFetchByPriority_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchByPriority(.high)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchByPriority_1000tasks_performance() throws {
        PerformanceTestData.seedTasks(1000, in: stack.context)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchByPriority(.high)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Fetch Scheduled Between Performance

    func testFetchScheduledBetween_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)
        let today = Date.testToday
        let nextWeek = Date.daysFromNow(7)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchScheduledBetween(start: today, end: nextWeek)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchScheduledBetween_1000tasks_performance() throws {
        PerformanceTestData.seedTasks(1000, in: stack.context)
        let today = Date.testToday
        let nextWeek = Date.daysFromNow(7)

        measure(metrics: [XCTClockMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchScheduledBetween(start: today, end: nextWeek)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Fetch All Performance

    func testFetchAll_500tasks_performance() throws {
        PerformanceTestData.seedTasks(500, in: stack.context)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchAll()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testFetchAll_1000tasks_performance() throws {
        PerformanceTestData.seedTasks(1000, in: stack.context)

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            let expectation = expectation(description: "fetch")
            Task {
                _ = try? await repo.fetchAll()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    // MARK: - Save Performance

    func testSave_singleEntity_performance() throws {
        measure(metrics: [XCTClockMetric()]) {
            let task = TGTask(context: stack.context)
            task.id = UUID()
            task.title = "Test Task"
            task.status = "pending"
            task.createdAt = Date()
            task.updatedAt = Date()

            let expectation = expectation(description: "save")
            Task {
                try? await repo.save()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }

    func testSave_batch50_performance() throws {
        measure(metrics: [XCTClockMetric()]) {
            for i in 0..<50 {
                let task = TGTask(context: stack.context)
                task.id = UUID()
                task.title = "Batch Task \(i)"
                task.status = "pending"
                task.createdAt = Date()
                task.updatedAt = Date()
            }

            let expectation = expectation(description: "save")
            Task {
                try? await repo.save()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 30)
        }
    }

    func testSave_batch100_performance() throws {
        measure(metrics: [XCTClockMetric()]) {
            for i in 0..<100 {
                let task = TGTask(context: stack.context)
                task.id = UUID()
                task.title = "Batch Task \(i)"
                task.status = "pending"
                task.createdAt = Date()
                task.updatedAt = Date()
            }

            let expectation = expectation(description: "save")
            Task {
                try? await repo.save()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 30)
        }
    }

    // MARK: - Delete Performance

    func testDelete_singleEntity_performance() throws {
        // Seed data first
        PerformanceTestData.seedTasks(100, in: stack.context)
        let tasks = try? stack.context.fetch(TGTask.fetchRequest())

        measure(metrics: [XCTClockMetric()]) {
            guard let task = tasks?.first else { return }
            let expectation = expectation(description: "delete")
            Task {
                try? await repo.delete(task)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }
}
