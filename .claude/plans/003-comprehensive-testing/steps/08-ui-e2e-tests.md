# Step 8: UI/E2E Tests

## Context
UI tests verify the app works correctly from the user's perspective. Using XCUITest, we test critical user flows end-to-end. Priority flows are task completion and strategy coaching as specified in requirements.

## Goal
Create UI tests for the two priority user flows: task completion and strategy coaching, using the Page Object pattern for maintainability.

## Prerequisites
- Steps 1-5 completed (stable app functionality)
- Steps 3-4 especially important (app must work correctly)

## High-Level Steps
1. Create UI test infrastructure and helpers
2. Implement Page Object pattern for key screens
3. Create task completion flow tests
4. Create strategy coaching flow tests
5. Create navigation tests
6. Verify tests are stable across runs

## Detailed Requirements

### UI Test Infrastructure

#### UITestHelpers.swift
```swift
import XCTest

extension XCUIApplication {
    /// Launch app in test mode with clean state
    func launchForTesting() {
        launchArguments = ["-UITesting"]
        launchEnvironment = ["TESTING": "1"]
        launch()
    }

    /// Wait for element to appear
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5) -> Bool {
        element.waitForExistence(timeout: timeout)
    }

    /// Tap element after waiting
    func tapWhenAvailable(_ element: XCUIElement, timeout: TimeInterval = 5) {
        if waitForElement(element, timeout: timeout) {
            element.tap()
        }
    }
}

extension XCUIElement {
    /// Scroll until element is visible
    func scrollToVisible(in container: XCUIElement) {
        while !isHittable {
            container.swipeUp()
        }
    }
}
```

### Page Object Pattern

#### TodayPage.swift
```swift
import XCTest

struct TodayPage {
    let app: XCUIApplication

    // Elements
    var header: XCUIElement { app.staticTexts["Today"] }
    var addButton: XCUIElement { app.buttons["AddTaskButton"] }
    var taskList: XCUIElement { app.collectionViews["TaskList"] }

    func taskCard(titled: String) -> XCUIElement {
        app.staticTexts[titled].firstMatch
    }

    func checkbox(for taskTitle: String) -> XCUIElement {
        // Find checkbox in same container as task title
        taskCard(titled: taskTitle)
            .ancestors(matching: .cell)
            .firstMatch
            .buttons["Checkbox"]
    }

    // Actions
    func completeTask(titled: String) {
        checkbox(for: taskTitle).tap()
    }

    func swipeToDelete(task: String) {
        taskCard(titled: task).swipeLeft()
        app.buttons["Delete"].tap()
    }

    func swipeToDefer(task: String) {
        taskCard(titled: task).swipeRight()
        app.buttons["Defer"].tap()
    }

    func tapTask(titled: String) {
        taskCard(titled: title).tap()
    }

    // Verifications
    func verifyTaskVisible(_ title: String) -> Bool {
        taskCard(titled: title).waitForExistence(timeout: 5)
    }

    func verifyTaskNotVisible(_ title: String) -> Bool {
        !taskCard(titled: title).exists
    }

    func verifyEmptyState() -> Bool {
        app.staticTexts["No tasks for today"].exists
    }
}
```

#### StrategyCoachingPage.swift
```swift
struct StrategyCoachingPage {
    let app: XCUIApplication

    // Elements
    var problemTypePicker: XCUIElement { app.pickers["ProblemType"] }
    var strategyList: XCUIElement { app.collectionViews["StrategyList"] }
    var triedItButton: XCUIElement { app.buttons["TriedIt"] }
    var outcomeSuccessButton: XCUIElement { app.buttons["ItWorked"] }
    var outcomePartialButton: XCUIElement { app.buttons["Kinda"] }
    var outcomeFailureButton: XCUIElement { app.buttons["DidntWork"] }

    // Actions
    func selectProblemType(_ type: String) {
        problemTypePicker.tap()
        app.pickerWheels.element.adjust(toPickerWheelValue: type)
    }

    func selectStrategy(_ name: String) {
        app.staticTexts[name].tap()
    }

    func recordOutcome(_ outcome: String) {
        switch outcome {
        case "success": outcomeSuccessButton.tap()
        case "partial": outcomePartialButton.tap()
        case "failure": outcomeFailureButton.tap()
        default: break
        }
    }

    // Verifications
    func verifyStrategiesVisible() -> Bool {
        strategyList.cells.count > 0
    }
}
```

#### TabBar.swift
```swift
struct TabBar {
    let app: XCUIApplication

    var todayTab: XCUIElement { app.buttons["TodayTab"] }
    var tasksTab: XCUIElement { app.buttons["TasksTab"] }
    var calendarTab: XCUIElement { app.buttons["CalendarTab"] }
    var strategiesTab: XCUIElement { app.buttons["StrategiesTab"] }
    var settingsTab: XCUIElement { app.buttons["SettingsTab"] }

    func navigateTo(_ tab: String) {
        switch tab {
        case "Today": todayTab.tap()
        case "Tasks": tasksTab.tap()
        case "Calendar": calendarTab.tap()
        case "Strategies": strategiesTab.tap()
        case "Settings": settingsTab.tap()
        default: break
        }
    }
}
```

### Task Completion Flow Tests

#### TaskFlowTests.swift
```swift
import XCTest

final class TaskFlowTests: XCTestCase {
    var app: XCUIApplication!
    var todayPage: TodayPage!
    var tabBar: TabBar!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchForTesting()
        todayPage = TodayPage(app: app)
        tabBar = TabBar(app: app)
    }

    func testCompleteTask_removesFromList() throws {
        // Arrange - ensure we have a task (may need test data setup)
        XCTAssertTrue(todayPage.verifyTaskVisible("Test Task"))

        // Act
        todayPage.completeTask(titled: "Test Task")

        // Assert
        XCTAssertTrue(todayPage.verifyTaskNotVisible("Test Task"))
    }

    func testSwipeToDelete_removesTask() throws {
        XCTAssertTrue(todayPage.verifyTaskVisible("Test Task"))

        todayPage.swipeToDelete(task: "Test Task")

        XCTAssertTrue(todayPage.verifyTaskNotVisible("Test Task"))
    }

    func testSwipeToDefer_removesFromToday() throws {
        XCTAssertTrue(todayPage.verifyTaskVisible("Test Task"))

        todayPage.swipeToDefer(task: "Test Task")

        XCTAssertTrue(todayPage.verifyTaskNotVisible("Test Task"))
    }

    func testEmptyState_showsWhenNoTasks() throws {
        // Complete or delete all tasks
        // ...

        XCTAssertTrue(todayPage.verifyEmptyState())
    }

    func testCheckboxAnimation_playsOnComplete() throws {
        // Verify checkbox animates (check for accessibility change)
        let checkbox = todayPage.checkbox(for: "Test Task")
        XCTAssertEqual(checkbox.value as? String, "unchecked")

        checkbox.tap()

        // Wait for animation
        Thread.sleep(forTimeInterval: 0.5)
        XCTAssertEqual(checkbox.value as? String, "checked")
    }
}
```

### Strategy Coaching Flow Tests

#### StrategyCoachingFlowTests.swift
```swift
import XCTest

final class StrategyCoachingFlowTests: XCTestCase {
    var app: XCUIApplication!
    var coachingPage: StrategyCoachingPage!
    var tabBar: TabBar!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchForTesting()
        tabBar = TabBar(app: app)
        coachingPage = StrategyCoachingPage(app: app)

        // Navigate to coaching
        tabBar.navigateTo("Strategies")
    }

    func testSelectProblemType_showsStrategies() throws {
        coachingPage.selectProblemType("Too Big")

        XCTAssertTrue(coachingPage.verifyStrategiesVisible())
    }

    func testSelectStrategy_showsDetails() throws {
        coachingPage.selectProblemType("Too Big")
        coachingPage.selectStrategy("2-Minute Version")

        XCTAssertTrue(app.staticTexts["2-Minute Version"].exists)
    }

    func testRecordSuccess_updatesScore() throws {
        coachingPage.selectProblemType("Too Big")
        coachingPage.selectStrategy("2-Minute Version")
        coachingPage.triedItButton.tap()

        coachingPage.recordOutcome("success")

        // Verify confirmation appears
        XCTAssertTrue(app.staticTexts["Great job!"].waitForExistence(timeout: 2))
    }

    func testFullCoachingFlow() throws {
        // End-to-end test of entire coaching flow
        coachingPage.selectProblemType("Too Big")
        XCTAssertTrue(coachingPage.verifyStrategiesVisible())

        coachingPage.selectStrategy("First Step Only")
        XCTAssertTrue(app.staticTexts["First Step Only"].exists)

        coachingPage.triedItButton.tap()
        coachingPage.recordOutcome("success")

        XCTAssertTrue(app.staticTexts["Great job!"].waitForExistence(timeout: 2))
    }
}
```

### Navigation Tests

```swift
func testTabNavigation_switchesBetweenViews() throws {
    // Start on Today
    XCTAssertTrue(todayPage.header.exists)

    // Navigate to Tasks
    tabBar.navigateTo("Tasks")
    XCTAssertTrue(app.navigationBars["Tasks"].exists)

    // Navigate to Calendar
    tabBar.navigateTo("Calendar")
    XCTAssertTrue(app.navigationBars["Calendar"].exists)

    // Navigate to Strategies
    tabBar.navigateTo("Strategies")
    XCTAssertTrue(app.navigationBars["Strategies"].exists)

    // Navigate to Settings
    tabBar.navigateTo("Settings")
    XCTAssertTrue(app.navigationBars["Settings"].exists)

    // Return to Today
    tabBar.navigateTo("Today")
    XCTAssertTrue(todayPage.header.exists)
}
```

### Test Data Setup
For UI tests, need seed data. Options:
1. Launch argument to seed test data
2. Reset and seed in setUp
3. Use XCUITest's test scaffolding

## Files to Create
- `TangentleUITests/Helpers/UITestHelpers.swift`
- `TangentleUITests/Pages/TodayPage.swift`
- `TangentleUITests/Pages/StrategyCoachingPage.swift`
- `TangentleUITests/Pages/TabBar.swift`
- `TangentleUITests/Flows/TaskFlowTests.swift`
- `TangentleUITests/Flows/StrategyCoachingFlowTests.swift`
- `TangentleUITests/Flows/NavigationTests.swift`

## Files to Modify
- `Tangentle/App/TangentleApp.swift` - Add launch argument handling for test mode

## Patterns to Follow
Reference: XCUITest documentation
Reference: Page Object pattern

## Acceptance Criteria
- [ ] UITestHelpers created with common utilities
- [ ] Page objects created for key screens
- [ ] Task completion flow fully tested (5+ tests)
- [ ] Strategy coaching flow fully tested (4+ tests)
- [ ] Navigation between tabs tested
- [ ] Tests run reliably (no flakiness)
- [ ] All tests pass
- [ ] Test run completes in reasonable time (<2 min)

## Testing Requirements

### UI Tests
- Test files: See "Files to Create" above
- Minimum: 15-20 UI tests

### What to Test
- Complete user flows
- UI state changes
- Navigation
- Swipe gestures
- Accessibility identifiers

## Verification Commands
```bash
# Run UI tests only
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:TangentleUITests

# Run all tests
cd /Users/dannytrevino/development/tangentle-ios && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Documentation Updates
- Add accessibility identifiers to components

## Error Recovery
If verification fails:
1. Check accessibility identifiers are set on components
2. Verify test data is seeded correctly
3. Add explicit waits for animations
4. Check element queries match actual UI
5. Run tests in isolation to identify dependencies

## Do NOT
- Add random waits (use waitForExistence)
- Hard-code coordinates (use accessibility)
- Skip cleanup between tests
- Make tests depend on each other
- Test implementation details (test user flows)
