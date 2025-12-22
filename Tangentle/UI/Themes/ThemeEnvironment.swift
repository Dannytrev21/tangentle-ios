import SwiftUI

// MARK: - Theme Environment Key

/// Environment key for accessing the current theme throughout the app.
private struct ThemeKey: EnvironmentKey {
    static let defaultValue: ThemeProtocol = WarmLightTheme()
}

// MARK: - Environment Values Extension

extension EnvironmentValues {
    /// The current theme for styling views.
    ///
    /// Usage:
    /// ```swift
    /// @Environment(\.theme) var theme
    /// Text("Hello").foregroundStyle(theme.textPrimary)
    /// ```
    var theme: ThemeProtocol {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    /// Apply a theme to this view and all its descendants.
    ///
    /// Usage:
    /// ```swift
    /// ContentView()
    ///     .themed(WarmDarkTheme())
    /// ```
    func themed(_ theme: ThemeProtocol) -> some View {
        environment(\.theme, theme)
    }
}
