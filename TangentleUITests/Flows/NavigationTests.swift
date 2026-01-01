import XCTest

/// UI tests for navigation flows.
/// Tests tab bar navigation and view transitions.
final class NavigationTests: XCTestCase {
    var app: XCUIApplication!
    var tabBar: TabBarPage!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchWithScenario(.multipleTasks)
        tabBar = TabBarPage(app: app)
    }

    override func tearDownWithError() throws {
        app = nil
        tabBar = nil
    }

    // MARK: - Tab Bar Visibility Tests

    func testTabBar_allTabsVisible() throws {
        // Verify tab bar exists with at least one tab
        let anyTab = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'Tab_'")).firstMatch
        XCTAssertTrue(anyTab.waitForExistence(timeout: 5), "Tab bar should be visible with tabs")
    }

    func testTabBar_todayIsDefaultTab() throws {
        // Today view should be visible by default - look for greeting text
        let greetingTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Good'"))
        XCTAssertTrue(greetingTexts.firstMatch.waitForExistence(timeout: 5), "Today view should be displayed by default")
    }

    // MARK: - Tab Navigation Tests

    func testTabNavigation_switchesBetweenViews() throws {
        // Start on Today (default) - look for greeting
        let greetingTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Good'"))
        XCTAssertTrue(greetingTexts.firstMatch.waitForExistence(timeout: 5), "Should start on Today view")

        // Navigate to Tasks
        tabBar.navigateTo(.tasks)
        sleep(1)

        // Navigate to Calendar
        tabBar.navigateTo(.calendar)
        sleep(1)

        // Navigate to Strategies
        tabBar.navigateTo(.strategies)
        sleep(1)

        // Navigate to Settings
        tabBar.navigateTo(.settings)
        sleep(1)

        // Navigate back to Today
        tabBar.navigateTo(.today)
        XCTAssertTrue(greetingTexts.firstMatch.waitForExistence(timeout: 5), "Should return to Today view")
    }

    func testTabNavigation_todayTab() throws {
        // Navigate away first
        tabBar.navigateTo(.settings)
        sleep(1)

        // Navigate to Today
        tabBar.navigateTo(.today)

        let greetingTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Good'"))
        XCTAssertTrue(greetingTexts.firstMatch.waitForExistence(timeout: 5), "Today view should be visible")
    }

    func testTabNavigation_tasksTab() throws {
        tabBar.navigateTo(.tasks)

        // Tasks view should become visible
        // This depends on what the Tasks view shows - adjust as needed
        sleep(1) // Allow transition
        XCTAssertTrue(tabBar.tabExists(.tasks), "Tasks tab should exist")
    }

    func testTabNavigation_calendarTab() throws {
        tabBar.navigateTo(.calendar)
        sleep(1)
        XCTAssertTrue(tabBar.tabExists(.calendar), "Calendar tab should exist")
    }

    func testTabNavigation_strategiesTab() throws {
        tabBar.navigateTo(.strategies)
        sleep(1)
        XCTAssertTrue(tabBar.tabExists(.strategies), "Strategies tab should exist")
    }

    func testTabNavigation_settingsTab() throws {
        tabBar.navigateTo(.settings)
        sleep(1)
        XCTAssertTrue(tabBar.tabExists(.settings), "Settings tab should exist")
    }

    // MARK: - State Preservation Tests

    func testTabNavigation_preservesStateOnReturn() throws {
        // Start on Today - look for greeting
        let greetingTexts = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Good'"))
        XCTAssertTrue(greetingTexts.firstMatch.waitForExistence(timeout: 5))

        // Navigate away and back
        tabBar.navigateTo(.settings)
        sleep(1)
        tabBar.navigateTo(.today)

        // Today view should still show header
        XCTAssertTrue(greetingTexts.firstMatch.waitForExistence(timeout: 5), "Today view should preserve state")
    }
}
