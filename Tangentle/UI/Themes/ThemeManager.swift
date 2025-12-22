import SwiftUI

// MARK: - Theme Mode

/// Available theme modes for the app.
enum ThemeMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

// MARK: - Theme Manager

/// Observable manager for theme state and switching.
/// Uses @Observable for iOS 17+ reactive updates.
@Observable
final class ThemeManager {
    // MARK: - Properties

    /// Current theme mode preference
    var mode: ThemeMode {
        didSet {
            savePreference()
        }
    }

    /// System color scheme for detecting dark mode
    private var systemColorScheme: ColorScheme = .light

    // MARK: - Storage

    private static let preferenceKey = "themeMode"

    // MARK: - Initialization

    init() {
        // Load saved preference or default to system
        if let savedMode = UserDefaults.standard.string(forKey: Self.preferenceKey),
           let mode = ThemeMode(rawValue: savedMode) {
            self.mode = mode
        } else {
            self.mode = .system
        }
    }

    // MARK: - Computed Properties

    /// The current theme based on mode and system settings
    var currentTheme: ThemeProtocol {
        switch mode {
        case .light:
            return WarmLightTheme()
        case .dark:
            return WarmDarkTheme()
        case .system:
            return systemColorScheme == .dark ? WarmDarkTheme() : WarmLightTheme()
        }
    }

    /// The color scheme to apply (for preferredColorScheme modifier)
    var colorScheme: ColorScheme? {
        switch mode {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil // Use system default
        }
    }

    // MARK: - Methods

    /// Update the system color scheme (call from onAppear or onChange)
    func updateSystemColorScheme(_ colorScheme: ColorScheme) {
        self.systemColorScheme = colorScheme
    }

    /// Toggle between light and dark modes
    func toggle() {
        switch mode {
        case .system:
            mode = systemColorScheme == .dark ? .light : .dark
        case .light:
            mode = .dark
        case .dark:
            mode = .light
        }
    }

    // MARK: - Private Methods

    private func savePreference() {
        UserDefaults.standard.set(mode.rawValue, forKey: Self.preferenceKey)
    }
}

// MARK: - Theme Manager Environment Key

private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue: ThemeManager = ThemeManager()
}

extension EnvironmentValues {
    /// Access the theme manager for mode switching.
    ///
    /// Usage:
    /// ```swift
    /// @Environment(\.themeManager) var themeManager
    /// Button("Toggle") { themeManager.toggle() }
    /// ```
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
