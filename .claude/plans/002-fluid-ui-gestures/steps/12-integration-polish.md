# Step 12: Integration & Polish

## Context
All individual components are built. This final step integrates everything, adds microinteractions, ensures consistency, and polishes the experience. This is where the app goes from "components work" to "feels premium".

## Goal
Wire up all components, add finishing touches, ensure consistency across the app, and verify everything works together smoothly.

## Prerequisites
- All previous steps (1-11) completed
- All components building successfully

## High-Level Steps
1. App-level theme integration
2. Add missing microinteractions
3. Ensure dark mode works perfectly
4. Accessibility audit and fixes
5. Performance optimization
6. Final testing and polish
7. Update other views to use new components

## Detailed Requirements

### App-Level Theme Integration

```swift
// TangentleApp.swift
@main
struct TangentleApp: App {
    @StateObject private var themeManager = ThemeManager()
    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            TabBarContainer()
                .environment(\.theme, themeManager.currentTheme)
                .environment(\.hapticEngine, container.hapticEngine)
                .environment(\.container, container)
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    setupAppearance()
                }
        }
    }

    private func setupAppearance() {
        // Prepare haptic engine
        container.hapticEngine.prepare()
    }
}
```

### Container Updates

```swift
// Container.swift
protocol DIContainer {
    // ... existing properties ...

    // Add haptic engine
    var hapticEngine: HapticEngineProtocol { get }
}

// AppContainer.swift
final class AppContainer: DIContainer {
    // ... existing properties ...

    lazy var hapticEngine: HapticEngineProtocol = {
        HapticEngine(settingsService: settingsService)
    }()
}
```

### Environment Keys

```swift
// Add to ThemeEnvironment.swift or new file
private struct HapticEngineKey: EnvironmentKey {
    static let defaultValue: HapticEngineProtocol = NoOpHapticEngine()
}

extension EnvironmentValues {
    var hapticEngine: HapticEngineProtocol {
        get { self[HapticEngineKey.self] }
        set { self[HapticEngineKey.self] = newValue }
    }
}

// Fallback for previews
final class NoOpHapticEngine: HapticEngineProtocol {
    func trigger(_ type: HapticType) {}
    func prepare() {}
}
```

### Microinteraction Additions

```swift
// Button press scale
extension View {
    func pressableStyle() -> some View {
        self.buttonStyle(ScaleButtonStyle())
    }
}

// List row highlight
struct HighlightRowModifier: ViewModifier {
    @Environment(\.theme) var theme
    @State private var isHighlighted = false

    func body(content: Content) -> some View {
        content
            .background(isHighlighted ? theme.surfacePressed : .clear)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHighlighted = pressing
                }
            }, perform: {})
    }
}

// Navigation transition
extension View {
    func slideTransition() -> some View {
        self.transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}
```

### Dark Mode Verification Checklist

```swift
// Create a preview helper
struct ThemePreviewWrapper<Content: View>: View {
    let content: Content

    var body: some View {
        HStack(spacing: 0) {
            content
                .environment(\.theme, WarmLightTheme())
                .colorScheme(.light)

            content
                .environment(\.theme, WarmDarkTheme())
                .colorScheme(.dark)
        }
    }
}

// Use in previews
#Preview {
    ThemePreviewWrapper {
        TaskCard(task: previewTask()) {}
    }
}
```

### Accessibility Audit

```swift
// Ensure all interactive elements have:
// 1. accessibilityLabel
// 2. accessibilityHint (where appropriate)
// 3. accessibilityTraits
// 4. Proper focus order

// Example audit checklist view modifier
struct AccessibilityAuditModifier: ViewModifier {
    let label: String
    let hint: String?
    let traits: AccessibilityTraits

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
}
```

### Performance Optimizations

```swift
// 1. LazyVStack for long lists (already done in TodayContent)

// 2. Avoid excessive re-renders
extension TGTask: Equatable {
    static func == (lhs: TGTask, rhs: TGTask) -> Bool {
        lhs.id == rhs.id &&
        lhs.updatedAt == rhs.updatedAt
    }
}

// 3. Reduce animation work on low-power mode
extension View {
    func adaptiveAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        self.animation(
            ProcessInfo.processInfo.isLowPowerModeEnabled ? .none : animation,
            value: value
        )
    }
}

// 4. Pre-render heavy content
struct TaskCardCache {
    static let shared = TaskCardCache()
    private var cache: [UUID: AnyView] = [:]
    // Cache implementation
}
```

### Update Other Views

```swift
// TasksView - Update to use new components
struct TasksView: View {
    @Environment(\.theme) var theme

    var body: some View {
        NavigationStack {
            // Apply theme background
            // Use TaskCard instead of TaskRow
            // Add SwipeableRow for each task
        }
        .background(theme.backgroundPrimary)
    }
}

// CalendarView - Theme colors
struct CalendarView: View {
    @Environment(\.theme) var theme

    var body: some View {
        // Apply theme colors
    }
}

// StrategiesView - Theme colors
struct StrategiesView: View {
    @Environment(\.theme) var theme

    var body: some View {
        // Apply theme colors
    }
}

// SettingsView - Theme and new sections
struct SettingsView: View {
    @Environment(\.theme) var theme

    var body: some View {
        NavigationStack {
            List {
                AppearanceSettingsSection()
                // ... existing sections
            }
            .background(theme.backgroundPrimary)
            .scrollContentBackground(.hidden)
        }
    }
}
```

### New Appearance Settings

```swift
struct AppearanceSettingsSection: View {
    @Environment(\.theme) var theme
    @AppStorage("themeMode") private var themeMode = "system"
    @AppStorage("hapticIntensity") private var hapticIntensity = "selective"
    @AppStorage("hideTabBar") private var hideTabBar = false

    var body: some View {
        Section("Appearance") {
            Picker("Theme", selection: $themeMode) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }

            Picker("Haptic Feedback", selection: $hapticIntensity) {
                Text("Off").tag("off")
                Text("Selective").tag("selective")
                Text("Rich").tag("rich")
            }

            Toggle("Hide Tab Bar", isOn: $hideTabBar)
        }
    }
}
```

### Final Test Checklist

```markdown
## Manual Testing Checklist

### Visual
- [ ] Light mode looks warm and inviting
- [ ] Dark mode looks warm, not cold
- [ ] All text is readable (contrast)
- [ ] Shadows render correctly in both modes
- [ ] Animations are smooth (60fps minimum)

### Interactions
- [ ] Swipe to complete works
- [ ] Swipe to delete works
- [ ] Long-press does not conflict with swipe
- [ ] Tab switching has haptic feedback
- [ ] Task completion has haptic feedback
- [ ] All buttons have press feedback

### Accessibility
- [ ] VoiceOver can read all content
- [ ] Focus order makes sense
- [ ] All images have labels
- [ ] Color is not only indicator

### Edge Cases
- [ ] Empty state displays correctly
- [ ] Many tasks (20+) scrolls smoothly
- [ ] Overdue section appears/disappears
- [ ] Pull-to-refresh works
- [ ] Rotation handled (if supported)
```

## Files to Create

### `Tangentle/UI/Themes/ThemePreviewWrapper.swift`
Preview helper for theme testing.

### `Tangentle/Features/Settings/AppearanceSettingsSection.swift`
Appearance settings UI.

### `Tangentle/Core/DI/EnvironmentKeys.swift`
All custom environment keys.

## Files to Modify

### `Tangentle/App/TangentleApp.swift`
Full theme and environment integration.

### `Tangentle/Core/DI/Container.swift`
Add HapticEngine.

### `Tangentle/Core/DI/AppContainer.swift`
Implement HapticEngine.

### `Tangentle/Features/Tasks/TasksView.swift`
Apply theme, use new components.

### `Tangentle/Features/Calendar/CalendarView.swift`
Apply theme.

### `Tangentle/Features/Strategies/StrategiesView.swift`
Apply theme.

### `Tangentle/Features/Settings/SettingsView.swift`
Apply theme, add appearance section.

## Patterns to Follow
Reference: All previously created components

## Acceptance Criteria
- [ ] App launches with theme applied
- [ ] Theme changes instantly when toggled
- [ ] Dark mode is fully themed (no default colors leaking)
- [ ] All haptics work and respect user settings
- [ ] Tab bar works with hide/show
- [ ] All views use theme colors
- [ ] Settings UI for appearance works
- [ ] Performance is smooth on target devices
- [ ] VoiceOver audit passes
- [ ] Existing tests still pass
- [ ] Project builds and runs without errors

## Verification Commands
```bash
# Build
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Run all tests
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild test -scheme Tangentle -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' 2>&1 | tail -50

# Run app in simulator
xcrun simctl boot "iPhone 15" 2>/dev/null || true
open -a Simulator
```

## Documentation Updates
- [ ] Update CLAUDE.md with new UI patterns
- [ ] Document theme customization approach
- [ ] Add component usage examples

## Error Recovery
If verification fails:
1. Check all environment keys are set at app root
2. Verify no hardcoded colors remain
3. Check DI container has all required services

## Do NOT
- Ship with any hardcoded colors
- Skip accessibility testing
- Leave preview code that doesn't work
- Forget to test on actual device
