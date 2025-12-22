import SwiftUI
import UIKit

// MARK: - Swipe Gesture View

/// A SwiftUI wrapper for UIKit swipe gestures with precise velocity tracking.
/// Use this when you need gesture velocity data for physics-based animations.
///
/// Example:
/// ```swift
/// SwipeGestureView(
///     threshold: 80,
///     onSwipeUpdate: { translation, velocity in
///         offset = translation
///     },
///     onSwipeEnd: { translation, velocity in
///         // Animate to final position
///     }
/// ) {
///     TaskRow(task: task)
/// }
/// ```
struct SwipeGestureView<Content: View>: UIViewRepresentable {
    // MARK: - Properties

    /// The SwiftUI content to wrap
    let content: () -> Content

    /// Translation threshold to trigger action
    let threshold: CGFloat

    /// Called continuously during swipe
    let onSwipeUpdate: (CGFloat, CGFloat) -> Void

    /// Called when swipe ends
    let onSwipeEnd: (CGFloat, CGFloat) -> Void

    /// Optional callback when swipe begins
    var onSwipeBegin: (() -> Void)?

    /// Access haptic engine from environment
    @Environment(\.hapticEngine) var hapticEngine

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> SwipeHostView<Content> {
        let hostView = SwipeHostView<Content>()
        hostView.threshold = threshold
        hostView.onSwipeUpdate = onSwipeUpdate
        hostView.onSwipeEnd = onSwipeEnd
        hostView.onSwipeBegin = onSwipeBegin
        hostView.hapticEngine = hapticEngine

        // Embed SwiftUI content
        let hostingController = UIHostingController(rootView: content())
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        hostView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: hostView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: hostView.bottomAnchor)
        ])

        context.coordinator.hostingController = hostingController

        return hostView
    }

    func updateUIView(_ uiView: SwipeHostView<Content>, context: Context) {
        uiView.threshold = threshold
        uiView.hapticEngine = hapticEngine

        // Update SwiftUI content
        context.coordinator.hostingController?.rootView = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var hostingController: UIHostingController<Content>?
    }
}

// MARK: - Swipe Host View

/// UIView subclass that hosts the swipe gesture handler
final class SwipeHostView<Content: View>: UIView {
    var threshold: CGFloat = 80 {
        didSet { swipeHandler.swipeThreshold = threshold }
    }

    var onSwipeUpdate: ((CGFloat, CGFloat) -> Void)?
    var onSwipeEnd: ((CGFloat, CGFloat) -> Void)?
    var onSwipeBegin: (() -> Void)?
    var hapticEngine: HapticEngineProtocol? {
        didSet { swipeHandler.setHapticEngine(hapticEngine) }
    }

    private lazy var swipeHandler: SwipeGestureHandler = {
        let handler = SwipeGestureHandler()
        handler.delegate = self
        return handler
    }()

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && swipeHandler.delegate === self {
            swipeHandler.setup(on: self)
        }
    }
}

extension SwipeHostView: SwipeGestureDelegate {
    func swipeDidBegin() {
        onSwipeBegin?()
    }

    func swipeDidUpdate(translation: CGFloat, velocity: CGFloat) {
        onSwipeUpdate?(translation, velocity)
    }

    func swipeDidEnd(translation: CGFloat, velocity: CGFloat) {
        onSwipeEnd?(translation, velocity)
    }

    func swipeDidCancel() {
        onSwipeEnd?(0, 0)
    }
}

// MARK: - Long Press Charge View

/// A SwiftUI wrapper for UIKit long press charge gestures.
/// Provides smooth progress updates at up to 120fps on ProMotion displays.
///
/// Example:
/// ```swift
/// LongPressChargeView(
///     chargeDuration: 0.5,
///     onChargeUpdate: { progress in
///         chargeProgress = progress
///     },
///     onChargeComplete: {
///         completeTask()
///     }
/// ) {
///     Checkbox(isComplete: task.isComplete)
/// }
/// ```
struct LongPressChargeView<Content: View>: UIViewRepresentable {
    // MARK: - Properties

    /// The SwiftUI content to wrap
    let content: () -> Content

    /// Duration to fully charge in seconds
    let chargeDuration: TimeInterval

    /// Called continuously with progress (0.0 to 1.0)
    let onChargeUpdate: (CGFloat) -> Void

    /// Called when charge completes
    let onChargeComplete: () -> Void

    /// Called when charge is cancelled
    var onChargeCancel: (() -> Void)?

    /// Called when charge begins
    var onChargeBegin: (() -> Void)?

    /// Access haptic engine from environment
    @Environment(\.hapticEngine) var hapticEngine

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> ChargeHostView<Content> {
        let hostView = ChargeHostView<Content>()
        hostView.chargeDuration = chargeDuration
        hostView.onChargeUpdate = onChargeUpdate
        hostView.onChargeComplete = onChargeComplete
        hostView.onChargeCancel = onChargeCancel
        hostView.onChargeBegin = onChargeBegin
        hostView.hapticEngine = hapticEngine

        // Embed SwiftUI content
        let hostingController = UIHostingController(rootView: content())
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        hostView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: hostView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: hostView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: hostView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: hostView.bottomAnchor)
        ])

        context.coordinator.hostingController = hostingController

        return hostView
    }

    func updateUIView(_ uiView: ChargeHostView<Content>, context: Context) {
        uiView.chargeDuration = chargeDuration
        uiView.hapticEngine = hapticEngine

        // Update SwiftUI content
        context.coordinator.hostingController?.rootView = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var hostingController: UIHostingController<Content>?
    }
}

// MARK: - Charge Host View

/// UIView subclass that hosts the long press charge handler
final class ChargeHostView<Content: View>: UIView {
    var chargeDuration: TimeInterval = 0.5 {
        didSet { chargeHandler.chargeDuration = chargeDuration }
    }

    var onChargeUpdate: ((CGFloat) -> Void)?
    var onChargeComplete: (() -> Void)?
    var onChargeCancel: (() -> Void)?
    var onChargeBegin: (() -> Void)?
    var hapticEngine: HapticEngineProtocol? {
        didSet { chargeHandler.setHapticEngine(hapticEngine) }
    }

    private lazy var chargeHandler: LongPressChargeHandler = {
        let handler = LongPressChargeHandler()
        handler.delegate = self
        return handler
    }()

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && chargeHandler.delegate === self {
            chargeHandler.setup(on: self)
        }
    }
}

extension ChargeHostView: LongPressChargeDelegate {
    func chargeDidBegin() {
        onChargeBegin?()
    }

    func chargeDidUpdate(progress: CGFloat) {
        onChargeUpdate?(progress)
    }

    func chargeDidComplete() {
        onChargeComplete?()
    }

    func chargeDidCancel() {
        onChargeCancel?()
    }
}

// MARK: - View Extensions

extension View {
    /// Add swipe gesture handling with velocity tracking
    /// - Parameters:
    ///   - threshold: Translation threshold to trigger action
    ///   - onUpdate: Called continuously during swipe with translation and velocity
    ///   - onEnd: Called when swipe ends with final translation and velocity
    /// - Returns: View wrapped with swipe gesture handling
    func onSwipeGesture(
        threshold: CGFloat = 80,
        onUpdate: @escaping (CGFloat, CGFloat) -> Void,
        onEnd: @escaping (CGFloat, CGFloat) -> Void
    ) -> some View {
        SwipeGestureView(
            content: { self },
            threshold: threshold,
            onSwipeUpdate: onUpdate,
            onSwipeEnd: onEnd
        )
    }

    /// Add long press charge gesture handling
    /// - Parameters:
    ///   - duration: Duration to fully charge
    ///   - onProgress: Called continuously with charge progress (0.0 to 1.0)
    ///   - onComplete: Called when charge completes
    /// - Returns: View wrapped with charge gesture handling
    func onChargeGesture(
        duration: TimeInterval = 0.5,
        onProgress: @escaping (CGFloat) -> Void,
        onComplete: @escaping () -> Void
    ) -> some View {
        LongPressChargeView(
            content: { self },
            chargeDuration: duration,
            onChargeUpdate: onProgress,
            onChargeComplete: onComplete
        )
    }
}
