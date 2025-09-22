import SwiftUI

struct OnboardingCompletionView: View {
    let name: String
    let onComplete: () -> Void
    
    @State private var animateContent = false
    @State private var showConfetti = false
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkRotation: Double = 0
    @State private var showFireworks = false
    @State private var showSparkles = false
    @State private var titleBounce = false
    @State private var buttonPulse = false
    @State private var backgroundPulse = false
    
    var body: some View {
        ZStack {
            // Background gradient with pulse animation
            LinearGradient(
                colors: [
                    Color.royalBlue.opacity(backgroundPulse ? 0.9 : 0.7),
                    Color.goldenYellow.opacity(backgroundPulse ? 0.8 : 0.6),
                    Color.royalBlue.opacity(backgroundPulse ? 0.7 : 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(
                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                value: backgroundPulse
            )
            
            // Confetti effect
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
            
            // Fireworks effect
            if showFireworks {
                FireworksView()
                    .allowsHitTesting(false)
            }
            
            // Sparkles effect
            if showSparkles {
                SparklesView()
                    .allowsHitTesting(false)
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // Success icon with enhanced animation
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 180, height: 180)
                        .scaleEffect(animateContent ? 1.0 : 0.3)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(
                            .spring(response: 1.0, dampingFraction: 0.5)
                                .delay(0.1),
                            value: animateContent
                        )
                    
                    // Background circle with pulse
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(animateContent ? 1.0 : 0.5)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.6)
                                .delay(0.2),
                            value: animateContent
                        )
                        .scaleEffect(backgroundPulse ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: backgroundPulse
                        )
                    
                    // Checkmark with enhanced effects
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(checkmarkScale)
                        .rotationEffect(.degrees(checkmarkRotation))
                        .shadow(color: .white.opacity(0.8), radius: 10, x: 0, y: 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.5)
                                .delay(0.5),
                            value: checkmarkScale
                        )
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.6)
                                .delay(0.5),
                            value: checkmarkRotation
                        )
                }
                
                // Welcome message
                VStack(spacing: 16) {
                    Text("Welcome, \(name)!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .offset(y: animateContent ? 0 : 30)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .scaleEffect(titleBounce ? 1.05 : 1.0)
                        .shadow(color: .white.opacity(0.5), radius: 5, x: 0, y: 0)
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.8)
                                .delay(0.7),
                            value: animateContent
                        )
                        .animation(
                            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                            value: titleBounce
                        )
                    
                    Text("You're all set to start connecting with the Leeds community. Let's begin your journey!")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, 30)
                        .offset(y: animateContent ? 0 : 30)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(
                            .spring(response: 0.8, dampingFraction: 0.8)
                                .delay(0.9),
                            value: animateContent
                        )
                }
                
                Spacer()
                
                // Get Started button
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        onComplete()
                    }
                }) {
                    HStack(spacing: 12) {
                        Text("Get Started")
                            .font(.system(size: 20, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.royalBlue)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                    )
                }
                .scaleEffect(animateContent ? 1.0 : 0.8)
                .opacity(animateContent ? 1.0 : 0.0)
                .scaleEffect(buttonPulse ? 1.05 : 1.0)
                .animation(
                    .spring(response: 0.8, dampingFraction: 0.8)
                        .delay(1.1),
                    value: animateContent
                )
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: buttonPulse
                )
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Start background pulse immediately
        withAnimation {
            backgroundPulse = true
        }
        
        // Start main content animation
        withAnimation {
            animateContent = true
        }
        
        // Show confetti after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showConfetti = true
            }
        }
        
        // Show fireworks after confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                showFireworks = true
            }
        }
        
        // Show sparkles
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                showSparkles = true
            }
        }
        
        // Animate checkmark
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                checkmarkScale = 1.0
                checkmarkRotation = 360
            }
        }
        
        // Start title bounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                titleBounce = true
            }
        }
        
        // Start button pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                buttonPulse = true
            }
        }
    }
}

// Confetti Effect View
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces, id: \.id) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .rotationEffect(.degrees(piece.rotation))
                    .position(x: piece.x, y: piece.y)
                    .opacity(piece.opacity)
            }
        }
        .onAppear {
            generateConfetti()
            animateConfetti()
        }
    }
    
    private func generateConfetti() {
        let colors: [Color] = [.white, .goldenYellow, .royalBlue, .red, .green, .orange]
        
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: -20,
                size: CGFloat.random(in: 4...8),
                color: colors.randomElement() ?? .white,
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
            confettiPieces.append(piece)
        }
    }
    
    private func animateConfetti() {
        withAnimation(.easeOut(duration: 3.0)) {
            for i in confettiPieces.indices {
                confettiPieces[i].y = UIScreen.main.bounds.height + 100
                confettiPieces[i].rotation += Double.random(in: 360...720)
                confettiPieces[i].opacity = 0.0
            }
        }
    }
}

struct ConfettiPiece {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    var rotation: Double
    var opacity: Double
}

// Fireworks Effect View
struct FireworksView: View {
    @State private var fireworks: [Firework] = []
    
    var body: some View {
        ZStack {
            ForEach(fireworks, id: \.id) { firework in
                ForEach(0..<firework.particles.count, id: \.self) { index in
                    Circle()
                        .fill(firework.particles[index].color)
                        .frame(width: firework.particles[index].size, height: firework.particles[index].size)
                        .position(
                            x: firework.particles[index].x,
                            y: firework.particles[index].y
                        )
                        .opacity(firework.particles[index].opacity)
                }
            }
        }
        .onAppear {
            generateFireworks()
        }
    }
    
    private func generateFireworks() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
        
        for _ in 0..<3 {
            let centerX = CGFloat.random(in: 100...UIScreen.main.bounds.width - 100)
            let centerY = CGFloat.random(in: 200...400)
            
            var particles: [FireworkParticle] = []
            for _ in 0..<12 {
                let angle = Double.random(in: 0...360)
                let distance = CGFloat.random(in: 30...80)
                let x = centerX + cos(angle * .pi / 180) * distance
                let y = centerY + sin(angle * .pi / 180) * distance
                
                particles.append(FireworkParticle(
                    x: x,
                    y: y,
                    size: CGFloat.random(in: 3...6),
                    color: colors.randomElement() ?? .red,
                    opacity: 1.0
                ))
            }
            
            let firework = Firework(
                centerX: centerX,
                centerY: centerY,
                particles: particles
            )
            fireworks.append(firework)
            
            // Animate fireworks
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...0.5)) {
                animateFirework(firework)
            }
        }
    }
    
    private func animateFirework(_ firework: Firework) {
        withAnimation(.easeOut(duration: 2.0)) {
            if let index = fireworks.firstIndex(where: { $0.id == firework.id }) {
                for i in fireworks[index].particles.indices {
                    fireworks[index].particles[i].opacity = 0.0
                }
            }
        }
    }
}

struct Firework {
    let id = UUID()
    let centerX: CGFloat
    let centerY: CGFloat
    var particles: [FireworkParticle]
}

struct FireworkParticle {
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    let color: Color
    var opacity: Double
}

// Sparkles Effect View
struct SparklesView: View {
    @State private var sparkles: [Sparkle] = []
    
    var body: some View {
        ZStack {
            ForEach(sparkles, id: \.id) { sparkle in
                Image(systemName: "sparkle")
                    .font(.system(size: sparkle.size, weight: .bold))
                    .foregroundColor(sparkle.color)
                    .position(x: sparkle.x, y: sparkle.y)
                    .opacity(sparkle.opacity)
                    .rotationEffect(.degrees(sparkle.rotation))
                    .scaleEffect(sparkle.scale)
            }
        }
        .onAppear {
            generateSparkles()
            animateSparkles()
        }
    }
    
    private func generateSparkles() {
        let colors: [Color] = [.white, .goldenYellow, .royalBlue, .pink, .green]
        
        for _ in 0..<20 {
            let sparkle = Sparkle(
                x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 200),
                size: CGFloat.random(in: 12...20),
                color: colors.randomElement() ?? .white,
                opacity: 0.0,
                rotation: 0,
                scale: 0.5
            )
            sparkles.append(sparkle)
        }
    }
    
    private func animateSparkles() {
        for i in sparkles.indices {
            let delay = Double.random(in: 0...2.0)
            let duration = Double.random(in: 1.5...3.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    sparkles[i].opacity = Double.random(in: 0.6...1.0)
                    sparkles[i].rotation = Double.random(in: 0...360)
                    sparkles[i].scale = Double.random(in: 0.8...1.2)
                }
            }
        }
    }
}

struct Sparkle {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let color: Color
    var opacity: Double
    var rotation: Double
    var scale: Double
}

#Preview {
    OnboardingCompletionView(
        name: "John Doe",
        onComplete: {}
    )
}
