# Step 6: Gesture Foundation

## Context
Complex gestures (swipe with velocity, long-press with charge animation) require UIKit gesture recognizers for precise control. This step creates the foundation for gesture handling that bridges UIKit to SwiftUI.

## Goal
Create reusable gesture handlers for swipe and long-press interactions that integrate with the animation and haptic systems.

## Prerequisites
- Step 4 (Animation Library) completed
- Step 5 (Haptic Engine) completed

## High-Level Steps
1. Create SwipeGestureHandler with velocity tracking
2. Create LongPressChargeGesture with progress callbacks
3. Build UIViewRepresentable wrappers for SwiftUI
4. Integrate haptic feedback at gesture milestones
5. Create gesture state machine for complex interactions

## Detailed Requirements

### Swipe Gesture Handler
```swift
protocol SwipeGestureDelegate: AnyObject {
    func swipeDidBegin()
    func swipeDidUpdate(translation: CGFloat, velocity: CGFloat)
    func swipeDidEnd(translation: CGFloat, velocity: CGFloat)
    func swipeDidCancel()
}

final class SwipeGestureHandler: NSObject {
    weak var delegate: SwipeGestureDelegate?
    private let hapticEngine: HapticEngineProtocol

    // Configuration
    var swipeThreshold: CGFloat = 80  // Points to trigger action
    var velocityThreshold: CGFloat = 500  // Points/sec to auto-complete
    var direction: SwipeDirection = .horizontal

    enum SwipeDirection {
        case horizontal
        case vertical
    }

    // State
    private(set) var isActive = false
    private var startPoint: CGPoint = .zero
    private var lastTranslation: CGFloat = 0
    private var crossedThreshold = false

    func setup(on view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self
        view.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }

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
            delegate?.swipeDidBegin()

        case .changed:
            // Check threshold crossing
            if !crossedThreshold && abs(translation) >= swipeThreshold {
                crossedThreshold = true
                hapticEngine.trigger(.swipeThreshold)
            } else if crossedThreshold && abs(translation) < swipeThreshold {
                crossedThreshold = false
                hapticEngine.trigger(.selection)
            }
            delegate?.swipeDidUpdate(translation: translation, velocity: velocity)
            lastTranslation = translation

        case .ended:
            isActive = false
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
}

extension SwipeGestureHandler: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
              let view = pan.view else { return false }

        let velocity = pan.velocity(in: view)
        // Only begin if primary axis matches direction
        return direction == .horizontal
            ? abs(velocity.x) > abs(velocity.y)
            : abs(velocity.y) > abs(velocity.x)
    }
}
```

### Long Press Charge Gesture
```swift
protocol LongPressChargeDelegate: AnyObject {
    func chargeDidBegin()
    func chargeDidUpdate(progress: CGFloat)  // 0.0 to 1.0
    func chargeDidComplete()
    func chargeDidCancel()
}

final class LongPressChargeHandler: NSObject {
    weak var delegate: LongPressChargeDelegate?
    private let hapticEngine: HapticEngineProtocol

    // Configuration
    var chargeDuration: TimeInterval = 0.5  // Time to full charge
    var minimumPressDuration: TimeInterval = 0.15  // Debounce

    // State
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private(set) var progress: CGFloat = 0

    func setup(on view: UIView) {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = minimumPressDuration
        view.addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startCharging()

        case .ended:
            if progress >= 1.0 {
                hapticEngine.trigger(.longPressEnd)
                delegate?.chargeDidComplete()
            } else {
                delegate?.chargeDidCancel()
            }
            stopCharging()

        case .cancelled, .failed:
            delegate?.chargeDidCancel()
            stopCharging()

        default:
            break
        }
    }

    private func startCharging() {
        hapticEngine.trigger(.longPressStart)
        startTime = CACurrentMediaTime()
        progress = 0
        delegate?.chargeDidBegin()

        displayLink = CADisplayLink(target: self, selector: #selector(updateCharge))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateCharge() {
        let elapsed = CACurrentMediaTime() - startTime
        progress = min(1.0, CGFloat(elapsed / chargeDuration))
        delegate?.chargeDidUpdate(progress: progress)

        if progress >= 1.0 {
            stopCharging()
        }
    }

    private func stopCharging() {
        displayLink?.invalidate()
        displayLink = nil
        progress = 0
    }
}
```

### SwiftUI Bridge
```swift
struct SwipeGestureView<Content: View>: UIViewRepresentable {
    let content: Content
    let onSwipe: (CGFloat, CGFloat) -> Void  // translation, velocity
    let onComplete: () -> Void
    let threshold: CGFloat

    func makeUIView(context: Context) -> SwipeGestureHostView {
        let hostView = SwipeGestureHostView()
        hostView.onSwipe = onSwipe
        hostView.onComplete = onComplete
        hostView.threshold = threshold
        return hostView
    }

    func updateUIView(_ uiView: SwipeGestureHostView, context: Context) {
        // Update content
    }
}

final class SwipeGestureHostView: UIView {
    var onSwipe: ((CGFloat, CGFloat) -> Void)?
    var onComplete: (() -> Void)?
    var threshold: CGFloat = 80

    // Implementation wrapping SwipeGestureHandler
}
```

## Files to Create

### `Tangentle/UI/Gestures/SwipeGestureHandler.swift`
UIKit swipe gesture with velocity and threshold tracking.

### `Tangentle/UI/Gestures/LongPressChargeHandler.swift`
UIKit long-press with charge progress.

### `Tangentle/UI/Gestures/GestureViewRepresentable.swift`
SwiftUI wrappers for UIKit gestures.

### `Tangentle/UI/Gestures/GestureState.swift`
State machine enums and helpers.

## Files to Modify
- None (these are new foundational components)

## Patterns to Follow
Reference: `UIViewRepresentable` pattern in SwiftUI
Reference: `CADisplayLink` for high-framerate updates

## Acceptance Criteria
- [ ] SwipeGestureHandler tracks translation and velocity
- [ ] Swipe triggers haptic at threshold crossing
- [ ] LongPressChargeHandler provides 0-1 progress
- [ ] Long-press triggers haptics at start and complete
- [ ] 120fps updates on ProMotion devices
- [ ] SwiftUI bridge works for embedding gestures
- [ ] Gesture handlers clean up display links properly
- [ ] Project builds without errors

## Verification Commands
```bash
# Build
cd /Users/dannytrevino/development/tangentle-ios/Tangentle && xcodebuild -scheme Tangentle -sdk iphonesimulator build 2>&1 | tail -20

# Check gesture files
ls -la /Users/dannytrevino/development/tangentle-ios/Tangentle/UI/Gestures/
```

## Documentation Updates
- [ ] None required for this step

## Error Recovery
If verification fails:
1. Import UIKit for gesture recognizers
2. Check CADisplayLink target/selector
3. Ensure weak delegate references

## Do NOT
- Create retain cycles with closures
- Forget to invalidate CADisplayLink
- Use synchronous blocking in gesture handlers
