import SwiftUI

// MARK: - Custom Animation Extensions
extension Animation {
    static let onboardingSpring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let onboardingBounce = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let onboardingSmooth = Animation.easeInOut(duration: 0.8)
    static let onboardingQuick = Animation.easeOut(duration: 0.4)
}

// MARK: - Floating Animation Modifier
struct FloatingAnimation: ViewModifier {
    @State private var isFloating = false
    let duration: Double
    let offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -offset : offset)
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                isFloating = true
            }
    }
}

extension View {
    func floatingAnimation(duration: Double = 2.0, offset: CGFloat = 10) -> some View {
        self.modifier(FloatingAnimation(duration: duration, offset: offset))
    }
}

// MARK: - Pulse Animation Modifier
struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    let scale: CGFloat
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? scale : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    func pulseAnimation(scale: CGFloat = 1.1) -> some View {
        self.modifier(PulseAnimation(scale: scale))
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .animation(
                    Animation.linear(duration: duration)
                        .repeatForever(autoreverses: false),
                    value: phase
                )
            )
            .onAppear {
                phase = 200
            }
    }
}

extension View {
    func shimmerEffect(duration: Double = 2.0) -> some View {
        self.modifier(ShimmerEffect(duration: duration))
    }
}

// MARK: - Staggered Animation Container
struct StaggeredAnimation<Content: View>: View {
    let content: Content
    let delay: Double
    let animation: Animation
    
    init(delay: Double = 0.1, animation: Animation = .onboardingSpring, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.animation = animation
        self.content = content()
    }
    
    var body: some View {
        content
            .opacity(0)
            .offset(y: 30)
            .onAppear {
                withAnimation(animation.delay(delay)) {
                    // Animation will be handled by the parent view
                }
            }
    }
}

// MARK: - Gradient Background Animation
struct AnimatedGradientBackground: View {
    let colors: [Color]
    @State private var gradientOffset: CGFloat = 0
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(x: gradientOffset)
        .animation(
            Animation.easeInOut(duration: 8)
                .repeatForever(autoreverses: true),
            value: gradientOffset
        )
        .onAppear {
            gradientOffset = 20
        }
        .ignoresSafeArea(.all, edges: .all)
        .clipped()
    }
}

// MARK: - Particle System for Special Effects
struct ParticleSystem: View {
    @State private var particles: [Particle] = []
    let particleCount: Int
    let colors: [Color]
    
    init(particleCount: Int = 20, colors: [Color] = [.white, .goldenYellow, .royalBlue]) {
        self.particleCount = particleCount
        self.colors = colors
    }
    
    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
        .onAppear {
            generateParticles()
            animateParticles()
        }
    }
    
    private func generateParticles() {
        particles = (0..<particleCount).map { _ in
            Particle(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height),
                size: CGFloat.random(in: 2...6),
                color: colors.randomElement() ?? .white,
                opacity: Double.random(in: 0.3...0.8),
                scale: CGFloat.random(in: 0.5...1.5)
            )
        }
    }
    
    private func animateParticles() {
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
            for i in particles.indices {
                particles[i].x += CGFloat.random(in: -50...50)
                particles[i].y += CGFloat.random(in: -50...50)
                particles[i].opacity = Double.random(in: 0.2...0.9)
                particles[i].scale = CGFloat.random(in: 0.3...1.2)
            }
        }
    }
}

struct Particle {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    var opacity: Double
    var scale: CGFloat
}

// MARK: - Interactive Button with Haptic Feedback
struct InteractiveButton<Label: View>: View {
    let action: () -> Void
    let label: Label
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
            label
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.onboardingQuick, value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Glassmorphism Effect
struct GlassmorphismEffect: ViewModifier {
    let opacity: Double
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(opacity))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .blur(radius: 0.5)
            )
    }
}

extension View {
    func glassmorphismEffect(opacity: Double = 0.15) -> some View {
        self.modifier(GlassmorphismEffect(opacity: opacity))
    }
}

// MARK: - Morphing Shape Animation
struct MorphingShape: View {
    @State private var morphing = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: morphing ? 50 : 10)
            .fill(
                LinearGradient(
                    colors: [.royalBlue.opacity(0.8), .goldenYellow.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 100, height: 100)
            .animation(
                Animation.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true),
                value: morphing
            )
            .onAppear {
                morphing = true
            }
    }
}
