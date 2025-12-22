import Foundation

// MARK: - App Tab

/// Defines the main navigation tabs in the app.
/// Used by CustomTabBar for tab bar navigation.
enum AppTab: String, CaseIterable, Identifiable {
    case today
    case tasks
    case calendar
    case strategies
    case settings

    var id: String { rawValue }

    /// Display title for the tab
    var title: String {
        switch self {
        case .today: return "Today"
        case .tasks: return "Tasks"
        case .calendar: return "Calendar"
        case .strategies: return "Strategies"
        case .settings: return "Settings"
        }
    }

    /// SF Symbol name for unselected state
    var icon: String {
        switch self {
        case .today: return "sun.max"
        case .tasks: return "checklist"
        case .calendar: return "calendar"
        case .strategies: return "lightbulb"
        case .settings: return "gear"
        }
    }

    /// SF Symbol name for selected state (filled variant where available)
    var selectedIcon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .tasks: return "checklist"
        case .calendar: return "calendar"
        case .strategies: return "lightbulb.fill"
        case .settings: return "gear"
        }
    }
}
