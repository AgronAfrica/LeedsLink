import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var appState: AppState
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0
    @State private var rotation: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.royalBlue, Color.royalBlue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App Icon with multiple animation layers
                ZStack {
                    // Pulse ring effect
                    Circle()
                        .stroke(Color.goldenYellow.opacity(0.3), lineWidth: 3)
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseScale)
                        .opacity(isAnimating ? 0.0 : 0.6)
                    
                    // Rotating ring
                    Circle()
                        .stroke(Color.goldenYellow.opacity(0.5), lineWidth: 2)
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(rotation))
                    
                    // Main app icon
                    Image(systemName: "building.2.crop.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.goldenYellow)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                // App name with fade-in animation
                VStack(spacing: 8) {
                    Text("LeedsLink")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(opacity)
                    
                    Text("Connecting Leeds")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(opacity)
                }
                
                Spacer()
                
                // Loading indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.goldenYellow)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .opacity(opacity)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Ensure initial values are valid
        guard scale.isFinite && opacity.isFinite && rotation.isFinite && pulseScale.isFinite else {
            print("⚠️ Invalid animation values detected, resetting...")
            scale = 0.5
            opacity = 0.0
            rotation = 0.0
            pulseScale = 1.0
            return
        }
        
        // Initial entrance animation
        withAnimation(.easeOut(duration: 1.0)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Continuous animations with safety checks
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotation = 360.0
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
        }
        
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
        
        // Transition to Leeds story onboarding after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                appState.showSplashScreen = false
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(AppState())
}
