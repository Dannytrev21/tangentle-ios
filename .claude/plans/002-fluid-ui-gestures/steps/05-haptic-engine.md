# Step 5: Haptic Engine

## Context
Haptic feedback makes gestures feel tangible and real. For ADHD users, haptics provide confirmation that actions were registered, reducing anxiety about "did it work?". The system should be selective by default but user-configurable.

## Goal
Create a centralized haptic feedback service that provides appropriate feedback for different interaction types and respects user preferences.

## Prerequisites
- Step 1 (Design Tokens) completed
- Settings system exists (TGSettings+Extensions.swift)

## High-Level Steps
1. Define haptic feedback types
2. Create HapticEngine service
3. Add user preference to settings
4. Integrate with DI container
5. Create convenience methods for common patterns

## Detailed Requirements

### Haptic Types
```swift
enum HapticType {
    // Feedback types
    case selection        // Light tick, for selections
    case light           // Subtle, for minor interactions
    case medium          // Standard, for confirmations
    case heavy           // Strong, for major actions

    // Notification types
    case success         // Task completed, positive outcome
    case warning         // Caution, attention needed
    case error           // Something went wrong

    // Custom patterns
    case completion      // Satisfying thunk for task completion
    case swipeThreshold  // Crossed swipe action threshold
    case longPressStart  // Beginning long press
    case longPressEnd    // Completing long press
}
```

### Haptic Intensity Settings
```swift
enum HapticIntensity: String, Codable, CaseIterable {
    case off = "off"           // No haptics
    case selective = "selective"  // Key moments only
    case rich = "rich"         // Most interactions

    var displayName: String {
        switch self {
        case .off: return "Off"
        case .selective: return "Selective"
        case .rich: return "Rich"
        }
    }
}
```

### HapticEngine Service
```swift
protocol HapticEngineProtocol {
    func trigger(_ type: HapticType)
    func prepare()  // Warm up haptic engine
}

final class HapticEngine: HapticEngineProtocol {
    private let settingsService: SettingsServiceProtocol
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    init(settingsService: SettingsServiceProtocol) {
        self.settingsService = settingsService
    }

    func trigger(_ type: HapticType) {
        // Check user preference
        guard shouldTrigger(type) else { return }

        switch type {
        case .selection:
            selection.selectionChanged()
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        case .success:
            notification.notificationOccurred(.success)
        case .warning:
            notification.notificationOccurred(.warning)
        case .error:
            notification.notificationOccurred(.error)
        case .completion:
            // Custom pattern: rigid then soft
            impactRigid.impactOccurred(intensity: 0.8)
        case .swipeThreshold:
            impactLight.impactOccurred(intensity: 0.5)
        case .longPressStart:
            impactRigid.impactOccurred(intensity: 0.3)
        case .longPressEnd:
            notification.notificationOccurred(.success)
        }
    }

    func prepare() {
        impactMedium.prepare()
        notification.prepare()
    }

    private func shouldTrigger(_ type: HapticType) -> Bool {
        // Get intensity from settings
        let intensity = getCurrentIntensity()

        switch intensity {
        case .off:
            return false
        case .selective:
            // Only trigger for key moments
            return [.success, .error, .warning, .completion, .swipeThreshold].contains(type)
        case .rich:
            return true
        }
    }

    private func getCurrentIntensity() -> HapticIntensity {
        // Read from settings synchronously (cached)
        // Default to .selective
    }
}
```

### Settings Integration
```swift
// Add to DisplaySettings struct
struct DisplaySettings: Codable, Equatable {
    var themeMode: String = "system"
    var hapticIntensity: String = "selective"  // "off", "selective", "rich"
    // ... existing properties
}
```

## Files to Create

### `Tangentle/UI/Haptics/HapticEngine.swift`
Main haptic engine service.

### `Tangentle/UI/Haptics/HapticType.swift`
Haptic type enum and intensity settings.

## Files to Modify

### `Tangentle/Core/Models/TGSettings+Extensions.swift`
Add `hapticIntensity` to DisplaySettings.

### `Tangentle/Core/DI/Container.swift`
Add `hapticEngine: HapticEngineProtocol` to container.

### `Tangentle/Core/DI/AppContainer.swift`
Implement HapticEngine instantiation.

### `Tangentle/Core/Services/ServiceProtocols.swift`
Add HapticEngineProtocol if organizing there.

## Patterns to Follow
Reference: `Tangentle/Core/Services/SettingsService.swift` for service pattern
Reference: `Tangentle/Core/DI/Container.swift` for DI pattern

## Acceptance Criteria
- [ ] HapticType enum covers all needed patterns
- [ ] HapticIntensity settings work (off, selective, rich)
- [ ] HapticEngine respects user preference
- [ ] Engine properly prepares generators for low-latency response
- [ ] Custom patterns (completion, long-press) feel satisfying
- [ ] Integrated into DI container
- [ ] Project builds without errors

## Verification Commands
```bash
# Build
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Check haptic files
ls -la /Users/dannytrevino/development/tangentle-ios/Tangentle/UI/Haptics/
```

## Documentation Updates
- [ ] None required for this step

## Error Recovery
If verification fails:
1. Import UIKit for feedback generators
2. Check DI container protocol conformance
3. Ensure HapticIntensity rawValue matches expected strings

## Do NOT
- Create haptics that can't be disabled
- Trigger haptics too frequently (battery/annoyance)
- Use deprecated feedback generator APIs
