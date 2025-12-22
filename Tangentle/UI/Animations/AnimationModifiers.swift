import SwiftUI

// MARK: - Accessibility Support

extension Animation {
    /// An instant animation that completes immediately (no visible motion).
    /// Use this as a replacement for "no animation" when Reduce Motion is enabled.
    static let instant = Animation.linear(duration: 0)

    /// Returns an instant animation if Reduce Motion is enabled, otherwise the original animation.
    /// Use this for all user-facing animations to respect accessibility settings.
    ///
    /// Usage:
    /// ```swift
    /// withAnimation(.reduceMotionAware(SpringConfig.snappy)) {
    ///     isExpanded.toggle()
    /// }
    /// ```
    static func reduceMotionAware(_ animation: Animation) -> Animation {
        UIAccessibility.isReduceMotionEnabled ? .instant : animation
    }
}

// MARK: - View Modifiers

extension View {
    /// Apply a spring animation with automatic Reduce Motion support.
    ///
    /// Usage:
    /// ```swift
    /// Circle()
    ///     .springAnimation(value: isExpanded)
    /// ```
    func springAnimation<V: Equatable>(
        value: V,
        config: Animation = SpringConfig.snappy
    ) -> some View {
        self.animation(
            Animation.reduceMotionAware(config),
            value: value
        )
    }

    /// Apply an animation that respects both Reduce Motion and Low Power Mode.
    ///
    /// Usage:
    /// ```swift
    /// Text("Hello")
    ///     .adaptiveAnimation(SpringConfig.gentle, value: isVisible)
    /// ```
    func adaptiveAnimation<V: Equatable>(
        _ animation: Animation,
        value: V
    ) -> some View {
        let shouldAnimate = !UIAccessibility.isReduceMotionEnabled &&
                           !ProcessInfo.processInfo.isLowPowerModeEnabled
        return self.animation(shouldAnimate ? animation : .instant, value: value)
    }

    /// Scale effect on press for interactive feedback.
    /// Automatically respects Reduce Motion.
    ///
    /// Usage:
    /// ```swift
    /// Button("Tap") { }
    ///     .pressScale(isPressed)
    /// ```
    func pressScale(_ isPressed: Bool, scale: CGFloat = 0.95) -> some View {
        let effectiveScale = UIAccessibility.isReduceMotionEnabled ? 1.0 : (isPressed ? scale : 1.0)
        return self
            .scaleEffect(effectiveScale)
            .animation(SpringConfig.snappy, value: isPressed)
    }

    /// Bounce effect for emphasis (e.g., on appear).
    /// Respects Reduce Motion by using opacity only.
    func bounceOnAppear() -> some View {
        modifier(BounceOnAppearModifier())
    }

    /// Staggered appearance for list items.
    /// Respects Reduce Motion by appearing instantly.
    ///
    /// Usage:
    /// ```swift
    /// ForEach(items.indices, id: \.self) { index in
    ///     TaskRow(task: items[index])
    ///         .staggeredAppear(index: index)
    /// }
    /// ```
    func staggeredAppear(
        index: Int,
        baseDelay: Double = AnimationTiming.staggerBase,
        config: Animation = SpringConfig.gentle
    ) -> some View {
        modifier(StaggeredAppearModifier(index: index, baseDelay: baseDelay, config: config))
    }

    /// Shimmer loading effect.
    /// Respects Reduce Motion by showing static opacity.
    func shimmerEffect(_ isLoading: Bool) -> some View {
        modifier(ShimmerModifier(isLoading: isLoading))
    }
}

// MARK: - Bounce On Appear Modifier

private struct BounceOnAppearModifier: ViewModifier {
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(scaleValue)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(animation) {
                    isVisible = true
                }
            }
    }

    private var scaleValue: CGFloat {
        if UIAccessibility.isReduceMotionEnabled {
            return 1.0
        }
        return isVisible ? 1.0 : 0.8
    }

    private var animation: Animation {
        UIAccessibility.isReduceMotionEnabled ? .instant : SpringConfig.bouncy
    }
}

// MARK: - Staggered Appear Modifier

private struct StaggeredAppearModifier: ViewModifier {
    let index: Int
    let baseDelay: Double
    let config: Animation

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: offsetValue)
            .onAppear {
                withAnimation(animation) {
                    isVisible = true
                }
            }
    }

    private var offsetValue: CGFloat {
        if UIAccessibility.isReduceMotionEnabled {
            return 0
        }
        return isVisible ? 0 : 20
    }

    private var animation: Animation {
        if UIAccessibility.isReduceMotionEnabled {
            return .instant
        }
        return config.delay(Double(index) * baseDelay)
    }
}

// MARK: - Shimmer Modifier

private struct ShimmerModifier: ViewModifier {
    let isLoading: Bool

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    shimmerOverlay
                }
            }
    }

    @ViewBuilder
    private var shimmerOverlay: some View {
        if UIAccessibility.isReduceMotionEnabled {
            // Static shimmer for reduced motion
            Rectangle()
                .fill(Color.white.opacity(0.3))
        } else {
            // Animated shimmer
            GeometryReader { geometry in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                .white.opacity(0.3),
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
        }
    }
}

// MARK: - Transition Helpers

extension AnyTransition {
    /// A spring-based slide transition.
    /// Falls back to opacity-only for Reduce Motion.
    static var springSlide: AnyTransition {
        if UIAccessibility.isReduceMotionEnabled {
            return .opacity
        }
        return .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    /// A scale transition for modals/sheets.
    /// Falls back to opacity-only for Reduce Motion.
    static var springScale: AnyTransition {
        if UIAccessibility.isReduceMotionEnabled {
            return .opacity
        }
        return .scale(scale: 0.9).combined(with: .opacity)
    }
}
