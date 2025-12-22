import UIKit

// MARK: - Protocol

/// Protocol for haptic feedback service.
/// Use this protocol for dependency injection and testing.
protocol HapticEngineProtocol {
    /// Trigger a haptic feedback pattern
    func trigger(_ type: HapticType)

    /// Prepare the haptic engine for low-latency feedback
    func prepare()

    /// Update the intensity from settings
    func updateIntensity(_ intensity: HapticIntensity)
}

// MARK: - Implementation

/// Centralized haptic feedback engine with user-configurable intensity.
/// Respects user preferences and provides appropriate feedback for different interactions.
final class HapticEngine: HapticEngineProtocol {
    // MARK: - Properties

    /// Current intensity setting (cached for performance)
    private var intensity: HapticIntensity = .selective

    // MARK: Feedback Generators

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    // MARK: - Initialization

    init(intensity: HapticIntensity = .selective) {
        self.intensity = intensity
    }

    // MARK: - Public Methods

    func prepare() {
        // Prepare generators for low-latency response
        impactMedium.prepare()
        impactRigid.prepare()
        notification.prepare()
        selection.prepare()
    }

    func updateIntensity(_ intensity: HapticIntensity) {
        self.intensity = intensity
    }

    func trigger(_ type: HapticType) {
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
            // Satisfying rigid impact for task completion
            impactRigid.impactOccurred(intensity: 0.8)

        case .swipeThreshold:
            // Subtle click when crossing swipe threshold
            impactLight.impactOccurred(intensity: 0.5)

        case .longPressStart:
            // Soft feedback when long press begins
            impactSoft.impactOccurred(intensity: 0.3)

        case .longPressEnd:
            // Success notification when long press completes
            notification.notificationOccurred(.success)

        case .tabSelection:
            // Light impact for tab switching
            impactLight.impactOccurred(intensity: 0.4)

        case .refreshThreshold:
            // Light feedback when pull-to-refresh threshold crossed
            impactLight.impactOccurred(intensity: 0.6)
        }
    }

    // MARK: - Private Methods

    private func shouldTrigger(_ type: HapticType) -> Bool {
        switch intensity {
        case .off:
            return false

        case .selective:
            // Only key moments that confirm important actions
            return isKeyMoment(type)

        case .rich:
            return true
        }
    }

    /// Determine if a haptic type is a "key moment" for selective mode.
    /// Key moments are actions where feedback helps confirm the action was registered.
    private func isKeyMoment(_ type: HapticType) -> Bool {
        switch type {
        case .success, .error, .warning:
            return true
        case .completion:
            return true
        case .swipeThreshold:
            return true
        case .longPressEnd:
            return true
        case .selection, .light, .medium, .heavy:
            return false
        case .longPressStart:
            return false
        case .tabSelection:
            return false
        case .refreshThreshold:
            return true
        }
    }
}

// MARK: - No-Op Implementation

/// No-op haptic engine for previews and testing.
final class NoOpHapticEngine: HapticEngineProtocol {
    func trigger(_ type: HapticType) {
        // No-op
    }

    func prepare() {
        // No-op
    }

    func updateIntensity(_ intensity: HapticIntensity) {
        // No-op
    }
}

// MARK: - Environment Key

import SwiftUI

private struct HapticEngineKey: EnvironmentKey {
    static let defaultValue: HapticEngineProtocol = NoOpHapticEngine()
}

extension EnvironmentValues {
    /// Access the haptic engine for triggering feedback.
    ///
    /// Usage:
    /// ```swift
    /// @Environment(\.hapticEngine) var haptics
    /// Button("Complete") {
    ///     haptics.trigger(.completion)
    /// }
    /// ```
    var hapticEngine: HapticEngineProtocol {
        get { self[HapticEngineKey.self] }
        set { self[HapticEngineKey.self] = newValue }
    }
}

extension View {
    /// Inject a haptic engine into the view hierarchy.
    func hapticEngine(_ engine: HapticEngineProtocol) -> some View {
        environment(\.hapticEngine, engine)
    }
}
