import XCTest

/// Basic launch and smoke tests for Tangentle app.
/// More detailed flow tests are in the Flows directory.
final class TangentleUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    // MARK: - Launch Tests

    func testLaunch_appLaunchesSuccessfully() throws {
        let app = XCUIApplication()
        app.launchForTesting()
        XCTAssertTrue(app.exists, "App should launch successfully")
    }

    func testLaunch_showsTodayViewByDefault() throws {
        let app = XCUIApplication()
        app.launchWithScenario(.empty)

        // Should see Today header greeting text (Good Morning/Afternoon/Evening)
        let greetingTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Good'"))
        XCTAssertTrue(greetingTexts.firstMatch.waitForExistence(timeout: 10), "Today view should be displayed on launch")
    }

    func testLaunch_withMultipleTasks_displaysTaskCards() throws {
        let app = XCUIApplication()
        app.launchWithScenario(.multipleTasks)

        // Should see at least one task
        let todayPage = TodayPage(app: app)
        XCTAssertTrue(todayPage.verifyTaskVisible("Test Task 1"), "First task should be visible")
    }

    // MARK: - Accessibility Tests

    func testAccessibility_tabBarHasLabels() throws {
        let app = XCUIApplication()
        app.launchForTesting()

        let tabBar = TabBarPage(app: app)
        XCTAssertTrue(tabBar.todayTab.waitForExistence(timeout: 5), "Today tab should have accessibility identifier")
        XCTAssertTrue(tabBar.tasksTab.exists, "Tasks tab should have accessibility identifier")
        XCTAssertTrue(tabBar.calendarTab.exists, "Calendar tab should have accessibility identifier")
        XCTAssertTrue(tabBar.strategiesTab.exists, "Strategies tab should have accessibility identifier")
        XCTAssertTrue(tabBar.settingsTab.exists, "Settings tab should have accessibility identifier")
    }

    func testAccessibility_addButtonHasIdentifier() throws {
        let app = XCUIApplication()
        app.launchForTesting()

        let addButton = app.buttons["AddTaskButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add button should have accessibility identifier")
    }
}
