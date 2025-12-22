# Step 2: Theme System

## Context
With design tokens defined, we need a theme system that can apply these tokens consistently across the app. The theme system should support light/dark modes and be extensible for future custom themes.

## Goal
Create a `ThemeProtocol` with `WarmLightTheme` and `WarmDarkTheme` implementations, plus SwiftUI environment integration for easy access throughout the app.

## Prerequisites
- Step 1 (Design Tokens) completed

## High-Level Steps
1. Define `ThemeProtocol` with all semantic color properties
2. Implement `WarmLightTheme` using light mode tokens
3. Implement `WarmDarkTheme` using dark mode tokens
4. Create `ThemeEnvironment` for SwiftUI environment injection
5. Create `ThemeManager` to handle theme switching
6. Add theme preference to settings

## Detailed Requirements

### ThemeProtocol Definition
```swift
protocol ThemeProtocol {
    // Backgrounds
    var backgroundPrimary: Color { get }
    var backgroundSecondary: Color { get }
    var backgroundTertiary: Color { get }

    // Surfaces
    var surfaceElevated: Color { get }
    var surfacePressed: Color { get }

    // Text
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var textTertiary: Color { get }
    var textInverse: Color { get }

    // Accent
    var accentPrimary: Color { get }
    var accentSecondary: Color { get }
    var accentSoft: Color { get }

    // Status
    var statusSuccess: Color { get }
    var statusWarning: Color { get }
    var statusError: Color { get }
    var statusInfo: Color { get }

    // Priority
    var priorityHigh: Color { get }
    var priorityMedium: Color { get }
    var priorityLow: Color { get }
    var priorityNone: Color { get }

    // Energy
    var energyHigh: Color { get }
    var energyMedium: Color { get }
    var energyLow: Color { get }
}
```

### Theme Environment Key
```swift
private struct ThemeKey: EnvironmentKey {
    static let defaultValue: ThemeProtocol = WarmLightTheme()
}

extension EnvironmentValues {
    var theme: ThemeProtocol {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
```

### ThemeManager (Observable)
```swift
@Observable
final class ThemeManager {
    enum ThemeMode: String, Codable {
        case system
        case light
        case dark
    }

    var mode: ThemeMode = .system
    var currentTheme: ThemeProtocol { ... }

    // Observes system appearance changes
    // Persists preference to UserDefaults
}
```

### Usage Pattern
```swift
struct SomeView: View {
    @Environment(\.theme) var theme

    var body: some View {
        Text("Hello")
            .foregroundStyle(theme.textPrimary)
            .background(theme.backgroundPrimary)
    }
}
```

## Files to Create

### `Tangentle/UI/Themes/ThemeProtocol.swift`
Protocol definition with all color properties.

### `Tangentle/UI/Themes/WarmLightTheme.swift`
Light theme implementation.

### `Tangentle/UI/Themes/WarmDarkTheme.swift`
Dark theme implementation.

### `Tangentle/UI/Themes/ThemeEnvironment.swift`
Environment key and extensions.

### `Tangentle/UI/Themes/ThemeManager.swift`
Observable theme manager for mode switching.

## Files to Modify

### `Tangentle/Core/Models/TGSettings+Extensions.swift`
Add theme preference to DisplaySettings:
```swift
struct DisplaySettings: Codable, Equatable {
    var themeMode: String = "system"  // "system", "light", "dark"
    // ... existing properties
}
```

### `Tangentle/App/TangentleApp.swift`
Inject theme into environment at app root.

## Patterns to Follow
Reference: `Tangentle/Core/DI/ContainerEnvironment.swift` for environment key pattern

## Acceptance Criteria
- [ ] `ThemeProtocol` defines all semantic colors
- [ ] `WarmLightTheme` uses warm, cream-based colors
- [ ] `WarmDarkTheme` uses warm charcoal-based colors
- [ ] Theme accessible via `@Environment(\.theme)`
- [ ] `ThemeManager` responds to system appearance changes
- [ ] Theme preference persists across app launches
- [ ] Project builds without errors

## Verification Commands
```bash
# Build
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Check all theme files exist
ls -la /Users/dannytrevino/development/tangentle-ios/Tangentle/UI/Themes/
```

## Documentation Updates
- [ ] None required for this step

## Error Recovery
If verification fails:
1. Ensure all theme files import SwiftUI
2. Check protocol conformance in theme implementations
3. Verify environment key setup

## Do NOT
- Create a singleton ThemeManager (use environment)
- Hard-code colors in theme implementations (use DesignTokens)
- Add UI previews yet (components come later)
