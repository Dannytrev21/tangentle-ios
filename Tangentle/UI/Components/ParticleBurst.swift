import SwiftUI

// MARK: - Particle Burst

/// A celebratory particle burst effect for task completion.
/// Creates small colored particles that burst outward and fade.
/// Subtle enough to feel rewarding without being distracting.
struct ParticleBurst: View {
    let color: Color
    let particleCount: Int

    @State private var particles: [Particle] = []

    init(color: Color, particleCount: Int = 8) {
        self.color = color
        self.particleCount = particleCount
    }

    struct Particle: Identifiable {
        let id = UUID()
        var angle: Double
        var distance: CGFloat = 0
        var opacity: Double = 1
        var scale: CGFloat = 1
    }

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(color)
                    .frame(width: 4, height: 4)
                    .scaleEffect(particle.scale)
                    .opacity(particle.opacity)
                    .offset(
                        x: cos(particle.angle) * particle.distance,
                        y: sin(particle.angle) * particle.distance
                    )
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
    }

    private func createParticles() {
        // Create particles evenly distributed around a circle
        // Small random offset to make it feel more organic
        particles = (0..<particleCount).map { i in
            let baseAngle = Double(i) * (2 * .pi / Double(particleCount))
            let randomOffset = Double.random(in: -0.2...0.2)
            return Particle(angle: baseAngle + randomOffset)
        }
    }

    private func animateParticles() {
        // Burst outward and fade
        withAnimation(.easeOut(duration: 0.4)) {
            for i in particles.indices {
                particles[i].distance = CGFloat.random(in: 20...35)
                particles[i].opacity = 0
                particles[i].scale = CGFloat.random(in: 0.3...0.7)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ParticleBurst_Previews: PreviewProvider {
    static var previews: some View {
        ParticleBurstDemo()
            .previewLayout(.sizeThatFits)
    }
}

private struct ParticleBurstDemo: View {
    @State private var showBurst = false
    @State private var burstKey = UUID()

    var body: some View {
        VStack(spacing: Spacing.xl) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 60, height: 60)

                if showBurst {
                    ParticleBurst(color: .green)
                        .id(burstKey)
                }

                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }

            Button("Trigger Burst") {
                showBurst = false
                burstKey = UUID()
                showBurst = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showBurst = false
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(Spacing.xl)
    }
}
#endif
