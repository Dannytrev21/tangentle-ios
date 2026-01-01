import XCTest

/// UI tests for task-related flows.
/// Tests the complete user journey for managing tasks.
final class TaskFlowTests: XCTestCase {
    var app: XCUIApplication!
    var todayPage: TodayPage!
    var tabBar: TabBarPage!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchWithScenario(.multipleTasks)

        todayPage = TodayPage(app: app)
        tabBar = TabBarPage(app: app)
    }

    override func tearDownWithError() throws {
        app = nil
        todayPage = nil
        tabBar = nil
    }

    // MARK: - Today View Display Tests

    func testTodayView_displaysHeader() throws {
        // Header contains greeting text - look for "Good Morning/Afternoon/Evening"
        let greetingTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Good'"))
        XCTAssertTrue(greetingTexts.firstMatch.waitForExistence(timeout: 5), "Today header greeting should be visible")
    }

    func testTodayView_displaysAddButton() throws {
        XCTAssertTrue(todayPage.verifyAddButtonVisible(), "Add button should be visible")
    }

    func testTodayView_displaysTasksFromScenario() throws {
        // With multipleTasks scenario, we should have tasks
        XCTAssertTrue(todayPage.verifyTaskVisible("Test Task 1"), "First test task should be visible")
    }

    // MARK: - Task Completion Tests

    func testCompleteTask_removesFromList() throws {
        // Arrange
        let taskTitle = "Test Task 1"
        XCTAssertTrue(todayPage.verifyTaskVisible(taskTitle), "Task should be visible initially")

        // Act - swipe right to complete
        todayPage.swipeToComplete(task: taskTitle)

        // Assert - task should disappear after completion
        // Note: In a real implementation, this might need adjustment based on actual behavior
        sleep(1) // Wait for animation
        XCTAssertTrue(todayPage.verifyTaskNotVisible(taskTitle), "Completed task should not be visible")
    }

    // MARK: - Swipe Action Tests

    func testSwipeToDelete_removesTask() throws {
        let taskTitle = "Test Task 2"
        XCTAssertTrue(todayPage.verifyTaskVisible(taskTitle), "Task should be visible initially")

        todayPage.swipeToDelete(task: taskTitle)

        sleep(1) // Wait for animation
        XCTAssertTrue(todayPage.verifyTaskNotVisible(taskTitle), "Deleted task should not be visible")
    }

    func testSwipeToDefer_removesFromToday() throws {
        let taskTitle = "Test Task 3"
        XCTAssertTrue(todayPage.verifyTaskVisible(taskTitle), "Task should be visible initially")

        todayPage.swipeToDefer(task: taskTitle)

        sleep(1) // Wait for animation
        XCTAssertTrue(todayPage.verifyTaskNotVisible(taskTitle), "Deferred task should not be visible in Today")
    }

    // MARK: - Empty State Tests

    func testEmptyState_showsWhenNoTasks() throws {
        // Relaunch with empty scenario
        app.terminate()
        app = XCUIApplication()
        app.launchWithScenario(.empty)
        todayPage = TodayPage(app: app)

        XCTAssertTrue(todayPage.verifyEmptyState(), "Empty state should be shown when no tasks")
    }

    // MARK: - Add Task Tests

    func testAddButton_opensNewTaskSheet() throws {
        todayPage.tapAddButton()

        // Verify the new task sheet appears
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5), "New task sheet should open with Cancel button")
    }

    // MARK: - Refresh Tests

    func testPullToRefresh_reloadsData() throws {
        // Simply verify pull to refresh doesn't crash
        todayPage.pullToRefresh()

        // Should still see tasks after refresh
        XCTAssertTrue(todayPage.verifyHeaderVisible(), "Header should still be visible after refresh")
    }
}
