import SwiftUI

// MARK: - Checkmark Shape

/// An animatable checkmark path for use with trim animation.
/// Designed for use inside AnimatedCheckbox to create a satisfying
/// "draw in" effect when a task is completed.
struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Checkmark proportions - designed to look balanced inside a circle
        // Start at left middle, go down to the bottom "valley", then up to end
        let startX = rect.width * 0.22
        let startY = rect.height * 0.50
        let midX = rect.width * 0.42
        let midY = rect.height * 0.70
        let endX = rect.width * 0.78
        let endY = rect.height * 0.32

        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: midX, y: midY))
        path.addLine(to: CGPoint(x: endX, y: endY))

        return path
    }
}

// MARK: - Preview

#if DEBUG
struct CheckmarkShape_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Spacing.lg) {
            // Static checkmark
            CheckmarkShape()
                .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .frame(width: 40, height: 40)
                .background(Circle().fill(Color.green.opacity(0.2)))

            // Animated trim demo
            AnimatedCheckmarkDemo()
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

private struct AnimatedCheckmarkDemo: View {
    @State private var trimEnd: CGFloat = 0

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 60, height: 60)

                CheckmarkShape()
                    .trim(from: 0, to: trimEnd)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: 40, height: 40)
            }

            Button("Animate") {
                trimEnd = 0
                withAnimation(.easeOut(duration: 0.3)) {
                    trimEnd = 1
                }
            }
        }
    }
}
#endif
