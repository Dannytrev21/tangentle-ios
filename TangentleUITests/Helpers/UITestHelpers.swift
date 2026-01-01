import XCTest

// MARK: - XCUIApplication Extensions

extension XCUIApplication {
    /// Launch app in test mode with clean state
    func launchForTesting() {
        launchArguments = ["-UITesting"]
        launchEnvironment = [
            "TESTING": "1",
            "ANIMATIONS_DISABLED": "1"
        ]
        launch()
    }

    /// Wait for element to appear with timeout
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    /// Tap element after waiting for it to appear
    func tapWhenAvailable(_ element: XCUIElement, timeout: TimeInterval = 5) {
        if waitForElement(element, timeout: timeout) {
            element.tap()
        } else {
            XCTFail("Element not available: \(element)")
        }
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    /// Check if element exists and is hittable
    var isVisible: Bool {
        exists && isHittable
    }

    /// Scroll until element is visible in container
    func scrollToVisible(in container: XCUIElement, maxSwipes: Int = 5) {
        var attempts = 0
        while !isHittable && attempts < maxSwipes {
            container.swipeUp()
            attempts += 1
        }
    }

    /// Wait for element to disappear
    func waitForDisappearance(timeout: TimeInterval = 5) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }

    /// Safe tap with existence check
    func safeTap() {
        if waitForExistence(timeout: 3) {
            tap()
        }
    }
}

// MARK: - Test Scenarios

/// Test data scenarios for UI tests
enum TestScenario: String {
    case empty
    case singleTask
    case multipleTasks
    case withOverdue
    case strategyCoaching
}

extension XCUIApplication {
    /// Seed test data via launch argument
    func seedTestData(_ scenario: TestScenario) {
        launchArguments.append("-SeedData_\(scenario.rawValue)")
    }

    /// Launch with specific test scenario
    func launchWithScenario(_ scenario: TestScenario) {
        launchArguments = ["-UITesting"]
        seedTestData(scenario)
        launch()
    }
}

// MARK: - Test Assertions

/// Helper for common UI test assertions
enum UIAssert {
    /// Assert element becomes visible within timeout
    static func becomesVisible(_ element: XCUIElement, timeout: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Expected element to become visible: \(element)", file: file, line: line)
    }

    /// Assert element disappears within timeout
    static func disappears(_ element: XCUIElement, timeout: TimeInterval = 5, file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(element.waitForDisappearance(timeout: timeout), "Expected element to disappear: \(element)", file: file, line: line)
    }

    /// Assert count of elements
    static func count(_ query: XCUIElementQuery, equals expected: Int, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(query.count, expected, file: file, line: line)
    }
}
