import UIKit

// MARK: - Delegate Protocol

/// Delegate protocol for receiving long press charge updates.
/// Implement this to create "hold to confirm" interactions.
protocol LongPressChargeDelegate: AnyObject {
    /// Called when the long press begins (after minimum duration)
    func chargeDidBegin()

    /// Called continuously as charge progresses (up to 120fps on ProMotion)
    /// - Parameter progress: Current progress from 0.0 to 1.0
    func chargeDidUpdate(progress: CGFloat)

    /// Called when charge reaches 1.0 and touch is released
    func chargeDidComplete()

    /// Called when touch is released before completion
    func chargeDidCancel()
}

// MARK: - Handler

/// UIKit-based long press handler with charging animation support.
/// Provides 120fps updates on ProMotion displays via CADisplayLink.
///
/// Features:
/// - Smooth 0-1 progress callbacks at display refresh rate
/// - Haptic feedback at start and completion
/// - Configurable charge duration and minimum press
/// - Proper CADisplayLink cleanup
///
/// Usage:
/// ```swift
/// let handler = LongPressChargeHandler(hapticEngine: haptics)
/// handler.delegate = self
/// handler.chargeDuration = 0.5 // Half second to complete
/// handler.setup(on: view)
/// ```
final class LongPressChargeHandler: NSObject {
    // MARK: - Properties

    /// Delegate for receiving charge updates
    weak var delegate: LongPressChargeDelegate?

    /// Haptic engine for feedback (weak to avoid retain cycles)
    private weak var hapticEngine: HapticEngineProtocol?

    // MARK: Configuration

    /// Duration in seconds to reach full charge (default 0.5s)
    var chargeDuration: TimeInterval = 0.5

    /// Minimum press duration before charging begins (default 0.15s)
    var minimumPressDuration: TimeInterval = 0.15

    // MARK: State

    /// Display link for 120fps updates
    private var displayLink: CADisplayLink?

    /// Time when charging started
    private var startTime: CFTimeInterval = 0

    /// Current charge progress (0.0 to 1.0)
    private(set) var progress: CGFloat = 0

    /// Whether charging is currently in progress
    private(set) var isCharging = false

    /// Reference to the gesture recognizer
    private weak var longPressGesture: UILongPressGestureRecognizer?

    // MARK: - Initialization

    /// Create a long press charge handler
    /// - Parameter hapticEngine: Optional haptic engine for feedback
    init(hapticEngine: HapticEngineProtocol? = nil) {
        self.hapticEngine = hapticEngine
        super.init()
    }

    deinit {
        stopCharging()
    }

    // MARK: - Setup

    /// Attach the gesture recognizer to a view
    /// - Parameter view: The view to attach the gesture to
    func setup(on view: UIView) {
        // Remove existing gesture if any
        if let existingGesture = longPressGesture {
            view.removeGestureRecognizer(existingGesture)
        }

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress)
        )
        longPress.minimumPressDuration = minimumPressDuration
        longPress.delegate = self
        view.addGestureRecognizer(longPress)
        longPressGesture = longPress
    }

    /// Update the haptic engine reference
    /// - Parameter engine: The haptic engine to use
    func setHapticEngine(_ engine: HapticEngineProtocol?) {
        self.hapticEngine = engine
    }

    // MARK: - Gesture Handling

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startCharging()

        case .ended:
            if progress >= 1.0 {
                // Completed successfully
                hapticEngine?.trigger(.longPressEnd)
                delegate?.chargeDidComplete()
            } else {
                // Released too early
                delegate?.chargeDidCancel()
            }
            stopCharging()

        case .cancelled, .failed:
            delegate?.chargeDidCancel()
            stopCharging()

        case .changed:
            // Long press is still held - display link handles updates
            break

        default:
            break
        }
    }

    // MARK: - Charging

    private func startCharging() {
        guard !isCharging else { return }

        isCharging = true
        hapticEngine?.trigger(.longPressStart)
        startTime = CACurrentMediaTime()
        progress = 0
        delegate?.chargeDidBegin()

        // Create display link for smooth updates
        displayLink = CADisplayLink(target: self, selector: #selector(updateCharge))

        // Request 120fps on ProMotion displays
        displayLink?.preferredFrameRateRange = CAFrameRateRange(
            minimum: 60,
            maximum: 120,
            preferred: 120
        )

        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateCharge() {
        let elapsed = CACurrentMediaTime() - startTime
        progress = min(1.0, CGFloat(elapsed / chargeDuration))
        delegate?.chargeDidUpdate(progress: progress)

        // Note: We don't stop at 1.0 - we wait for touch release
        // This allows the user to see the "fully charged" visual
    }

    private func stopCharging() {
        displayLink?.invalidate()
        displayLink = nil
        progress = 0
        isCharging = false
    }

    // MARK: - Programmatic Control

    /// Cancel any in-progress charge
    func cancel() {
        if isCharging {
            delegate?.chargeDidCancel()
            stopCharging()
        }
    }

    /// Reset the handler state
    func reset() {
        stopCharging()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension LongPressChargeHandler: UIGestureRecognizerDelegate {
    /// Allow long press to work alongside other gestures
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Don't recognize simultaneously with pan gestures
        // This prevents conflicts with swipe gestures
        if otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return true
    }

    /// Long press should fail if a swipe starts
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // If a pan gesture is recognized, cancel the long press
        return otherGestureRecognizer is UIPanGestureRecognizer
    }
}
