import XCTest

/// Page Object for the Today view.
/// Abstracts UI structure from test logic for maintainability.
struct TodayPage {
    let app: XCUIApplication

    // MARK: - Elements

    var header: XCUIElement {
        // The TodayHeader is an HStack with accessibilityElement(children: .combine)
        // Try multiple element types to find it
        let otherElement = app.otherElements["TodayHeader"]
        if otherElement.exists { return otherElement }
        return app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Good'")).firstMatch
    }

    var addButton: XCUIElement {
        app.buttons["AddTaskButton"]
    }

    var scrollView: XCUIElement {
        app.scrollViews.firstMatch
    }

    var emptyStateMessage: XCUIElement {
        // EmptyState uses accessibilityElement(children: .combine) so try multiple queries
        let otherElement = app.otherElements["EmptyStateMessage"]
        if otherElement.exists { return otherElement }
        // Fallback to text containing the message
        return app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'All clear'")).firstMatch
    }

    var overdueSection: XCUIElement {
        app.otherElements["OverdueSection"]
    }

    var todaySection: XCUIElement {
        app.otherElements["TodaySection"]
    }

    /// Find a task card by its title
    func taskCard(titled: String) -> XCUIElement {
        app.staticTexts[titled].firstMatch
    }

    /// Find a task card by its UUID (more reliable)
    func taskCard(id: String) -> XCUIElement {
        app.otherElements["TaskCard_\(id)"]
    }

    /// Get all task cards visible on screen
    var allTaskCards: XCUIElementQuery {
        app.otherElements.matching(NSPredicate(format: "identifier BEGINSWITH 'TaskCard_'"))
    }

    /// Find the checkbox within a task's row
    func checkbox(for taskTitle: String) -> XCUIElement {
        // Find the static text with the task title, then look for checkbox in same area
        let taskText = app.staticTexts[taskTitle].firstMatch
        // The checkbox should be near the task text
        return app.buttons["Checkbox"].firstMatch
    }

    // MARK: - Actions

    /// Complete a task by tapping its checkbox
    func completeTask(titled: String) {
        let taskElement = taskCard(titled: titled)
        if taskElement.waitForExistence(timeout: 3) {
            // Tap the checkbox button
            let checkbox = app.buttons["Checkbox"].firstMatch
            if checkbox.exists {
                checkbox.tap()
            }
        }
    }

    /// Swipe left on a task to reveal delete action
    func swipeToDelete(task title: String) {
        let card = taskCard(titled: title)
        if card.waitForExistence(timeout: 3) {
            card.swipeLeft()
            // Wait for delete button to appear
            let deleteButton = app.buttons["DeleteAction"]
            app.tapWhenAvailable(deleteButton)
        }
    }

    /// Swipe right on a task to reveal complete action
    func swipeToComplete(task title: String) {
        let card = taskCard(titled: title)
        if card.waitForExistence(timeout: 3) {
            card.swipeRight()
            // The swipe-right action is "Done"
            let doneButton = app.buttons["DoneAction"]
            if doneButton.waitForExistence(timeout: 2) {
                doneButton.tap()
            }
        }
    }

    /// Swipe left to defer a task
    func swipeToDefer(task title: String) {
        let card = taskCard(titled: title)
        if card.waitForExistence(timeout: 3) {
            card.swipeLeft()
            let deferButton = app.buttons["DeferAction"]
            app.tapWhenAvailable(deferButton)
        }
    }

    /// Tap on a task to open its detail
    func tapTask(titled: String) {
        let card = taskCard(titled: titled)
        app.tapWhenAvailable(card)
    }

    /// Tap the floating add button
    func tapAddButton() {
        app.tapWhenAvailable(addButton)
    }

    /// Pull to refresh the task list
    func pullToRefresh() {
        scrollView.swipeDown()
    }

    // MARK: - Verifications

    /// Verify a task with given title is visible
    func verifyTaskVisible(_ title: String) -> Bool {
        taskCard(titled: title).waitForExistence(timeout: 5)
    }

    /// Verify a task with given title is not visible
    func verifyTaskNotVisible(_ title: String) -> Bool {
        let card = taskCard(titled: title)
        if !card.exists {
            return true
        }
        return card.waitForDisappearance(timeout: 3)
    }

    /// Verify the empty state is shown
    func verifyEmptyState() -> Bool {
        emptyStateMessage.waitForExistence(timeout: 5)
    }

    /// Verify the overdue section is visible
    func verifyOverdueSectionVisible() -> Bool {
        overdueSection.waitForExistence(timeout: 5)
    }

    /// Get the count of visible task cards
    var taskCount: Int {
        allTaskCards.count
    }

    /// Verify the header is displayed
    func verifyHeaderVisible() -> Bool {
        header.waitForExistence(timeout: 5)
    }

    /// Verify the add button is visible
    func verifyAddButtonVisible() -> Bool {
        addButton.waitForExistence(timeout: 5)
    }
}
