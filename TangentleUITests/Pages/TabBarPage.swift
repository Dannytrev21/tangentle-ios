import XCTest

/// Page Object for Tab Bar navigation.
/// Provides methods to navigate between tabs and verify selection state.
struct TabBarPage {
    let app: XCUIApplication

    // MARK: - Tab Elements

    var todayTab: XCUIElement {
        app.buttons["Tab_today"]
    }

    var tasksTab: XCUIElement {
        app.buttons["Tab_tasks"]
    }

    var calendarTab: XCUIElement {
        app.buttons["Tab_calendar"]
    }

    var strategiesTab: XCUIElement {
        app.buttons["Tab_strategies"]
    }

    var settingsTab: XCUIElement {
        app.buttons["Tab_settings"]
    }

    // MARK: - Tab Enum

    enum Tab {
        case today
        case tasks
        case calendar
        case strategies
        case settings
    }

    // MARK: - Actions

    /// Navigate to a specific tab
    func navigateTo(_ tab: Tab) {
        let element: XCUIElement
        switch tab {
        case .today: element = todayTab
        case .tasks: element = tasksTab
        case .calendar: element = calendarTab
        case .strategies: element = strategiesTab
        case .settings: element = settingsTab
        }
        app.tapWhenAvailable(element)
    }

    /// Check if a specific tab exists
    func tabExists(_ tab: Tab) -> Bool {
        let element: XCUIElement
        switch tab {
        case .today: element = todayTab
        case .tasks: element = tasksTab
        case .calendar: element = calendarTab
        case .strategies: element = strategiesTab
        case .settings: element = settingsTab
        }
        return element.waitForExistence(timeout: 3)
    }

    // MARK: - Verifications

    /// Verify a tab is selected (has isSelected trait)
    func verifySelected(_ tab: Tab) -> Bool {
        let element: XCUIElement
        switch tab {
        case .today: element = todayTab
        case .tasks: element = tasksTab
        case .calendar: element = calendarTab
        case .strategies: element = strategiesTab
        case .settings: element = settingsTab
        }
        return element.isSelected
    }

    /// Verify all tabs are visible
    func verifyAllTabsVisible() -> Bool {
        todayTab.waitForExistence(timeout: 3) &&
        tasksTab.exists &&
        calendarTab.exists &&
        strategiesTab.exists &&
        settingsTab.exists
    }
}
