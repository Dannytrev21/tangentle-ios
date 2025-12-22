import UIKit

// MARK: - Delegate Protocol

/// Delegate protocol for receiving swipe gesture updates.
/// Implement this to respond to swipe gestures in your SwiftUI or UIKit views.
protocol SwipeGestureDelegate: AnyObject {
    /// Called when a swipe gesture begins
    func swipeDidBegin()

    /// Called continuously during the swipe
    /// - Parameters:
    ///   - translation: Current horizontal translation in points
    ///   - velocity: Current velocity in points per second
    func swipeDidUpdate(translation: CGFloat, velocity: CGFloat)

    /// Called when the swipe gesture ends
    /// - Parameters:
    ///   - translation: Final horizontal translation in points
    ///   - velocity: Release velocity in points per second
    func swipeDidEnd(translation: CGFloat, velocity: CGFloat)

    /// Called when the swipe gesture is cancelled
    func swipeDidCancel()
}

// MARK: - Handler

/// UIKit-based swipe gesture handler for precise velocity tracking and haptic feedback.
/// Use this with SwipeableRow or wrap in UIViewRepresentable for SwiftUI.
///
/// Features:
/// - Precise translation and velocity tracking
/// - Haptic feedback at threshold crossing
/// - Configurable threshold and direction
/// - Gesture delegate for direction filtering
final class SwipeGestureHandler: NSObject {
    // MARK: - Properties

    /// Delegate for receiving gesture updates
    weak var delegate: SwipeGestureDelegate?

    /// Haptic engine for feedback (weak to avoid retain cycles)
    private weak var hapticEngine: HapticEngineProtocol?

    // MARK: Configuration

    /// Translation required to trigger an action (default 80pt)
    var swipeThreshold: CGFloat = 80

    /// Velocity required to trigger action even below threshold (default 500pt/s)
    var velocityThreshold: CGFloat = 500

    /// Primary swipe direction
    var direction: SwipeDirection = .horizontal

    /// Direction of swipe gesture
    enum SwipeDirection {
        case horizontal
        case vertical
    }

    // MARK: State

    /// Whether a swipe is currently in progress
    private(set) var isActive = false

    /// Starting point of the gesture
    private var startPoint: CGPoint = .zero

    /// Whether we've crossed the threshold (for haptic once)
    private var crossedThreshold = false

    /// Reference to the gesture recognizer
    private weak var panGesture: UIPanGestureRecognizer?

    // MARK: - Initialization

    /// Create a swipe gesture handler
    /// - Parameter hapticEngine: Optional haptic engine for feedback
    init(hapticEngine: HapticEngineProtocol? = nil) {
        self.hapticEngine = hapticEngine
        super.init()
    }

    // MARK: - Setup

    /// Attach the gesture recognizer to a view
    /// - Parameter view: The view to attach the gesture to
    func setup(on view: UIView) {
        // Remove existing gesture if any
        if let existingGesture = panGesture {
            view.removeGestureRecognizer(existingGesture)
        }

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        panGesture = pan
    }

    /// Update the haptic engine reference
    /// - Parameter engine: The haptic engine to use
    func setHapticEngine(_ engine: HapticEngineProtocol?) {
        self.hapticEngine = engine
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }

        // Get translation and velocity based on direction
        let translation = direction == .horizontal
            ? gesture.translation(in: view).x
            : gesture.translation(in: view).y

        let velocity = direction == .horizontal
            ? gesture.velocity(in: view).x
            : gesture.velocity(in: view).y

        switch gesture.state {
        case .began:
            isActive = true
            startPoint = gesture.location(in: view)
            crossedThreshold = false
            delegate?.swipeDidBegin()

        case .changed:
            // Check threshold crossing for haptic feedback
            let wasOverThreshold = crossedThreshold
            let isOverThreshold = abs(translation) >= swipeThreshold

            if !wasOverThreshold && isOverThreshold {
                // Just crossed threshold - trigger haptic
                crossedThreshold = true
                hapticEngine?.trigger(.swipeThreshold)
            } else if wasOverThreshold && !isOverThreshold {
                // Pulled back below threshold - light feedback
                crossedThreshold = false
                hapticEngine?.trigger(.selection)
            }

            delegate?.swipeDidUpdate(translation: translation, velocity: velocity)

        case .ended:
            isActive = false
            let wasCrossed = crossedThreshold
            crossedThreshold = false
            delegate?.swipeDidEnd(translation: translation, velocity: velocity)

        case .cancelled, .failed:
            isActive = false
            crossedThreshold = false
            delegate?.swipeDidCancel()

        default:
            break
        }
    }

    // MARK: - Helpers

    /// Determine if the swipe should trigger an action based on translation and velocity
    /// - Parameters:
    ///   - translation: Final translation
    ///   - velocity: Release velocity
    /// - Returns: True if action should trigger
    func shouldTriggerAction(translation: CGFloat, velocity: CGFloat) -> Bool {
        // Trigger if past threshold OR if velocity is high enough in same direction
        if abs(translation) >= swipeThreshold {
            return true
        }

        // Velocity-based trigger: high velocity in direction of translation
        if abs(velocity) >= velocityThreshold && translation * velocity > 0 {
            return true
        }

        return false
    }

    /// Determine which side the action is on
    /// - Parameter translation: The swipe translation
    /// - Returns: Leading or trailing side
    func actionSide(for translation: CGFloat) -> SwipeState.SwipeActionSide {
        translation > 0 ? .leading : .trailing
    }
}

// MARK: - UIGestureRecognizerDelegate

extension SwipeGestureHandler: UIGestureRecognizerDelegate {
    /// Only begin gesture if movement matches primary direction
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
              let view = pan.view else { return false }

        let velocity = pan.velocity(in: view)

        // Only begin if movement is primarily in the configured direction
        switch direction {
        case .horizontal:
            return abs(velocity.x) > abs(velocity.y)
        case .vertical:
            return abs(velocity.y) > abs(velocity.x)
        }
    }

    /// Allow simultaneous recognition with other gestures
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allow simultaneous recognition with scroll views initially,
        // but our delegate's shouldBegin will filter appropriately
        return false
    }
}
