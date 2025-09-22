import SwiftUI

struct AnimatedOnboardingPageView: View {
    let page: AnimatedOnboardingPage
    @State private var image1Offset: CGFloat = 50
    @State private var image2Offset: CGFloat = -50
    @State private var image1Opacity: Double = 0
    @State private var image2Opacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var descriptionOffset: CGFloat = 30
    @State private var descriptionOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 30
    @State private var buttonOpacity: Double = 0
    @State private var backgroundGradientOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Subtle particle effects
                ParticleSystem(particleCount: 15, colors: [.white.opacity(0.3), .goldenYellow.opacity(0.2)])
                    .allowsHitTesting(false)
                    .ignoresSafeArea(.all, edges: .all)
                
                VStack(spacing: 0) {
                    // Images container with sophisticated layout
                    HStack(spacing: 15) {
                        // First image with floating animation
                        Image(page.image1Name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: geometry.size.width * 0.75, maxHeight: geometry.size.height * 0.7)
                            .offset(y: image1Offset)
                            .opacity(image1Opacity)
                            .scaleEffect(1.0)
                            .floatingAnimation(duration: 2.0, offset: 15)
                            .pulseAnimation(scale: 1.05)
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
                            .shimmerEffect(duration: 3.0)
                        
                        Spacer()
                        
                        // Second image with different floating pattern
                        Image(page.image2Name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: geometry.size.width * 0.75, maxHeight: geometry.size.height * 0.7)
                            .offset(y: image2Offset)
                            .opacity(image2Opacity)
                            .scaleEffect(1.0)
                            .floatingAnimation(duration: 2.5, offset: -12)
                            .pulseAnimation(scale: 1.03)
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
                            .shimmerEffect(duration: 2.5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
                    // Content section with elegant typography
                    VStack(spacing: 16) {
                        // Title with sophisticated animation
                        Text(page.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .offset(y: titleOffset)
                            .opacity(titleOpacity)
                            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                            .padding(.horizontal, 20)
                        
                        // Description with refined styling
                        Text(page.description)
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.95))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .lineSpacing(2)
                            .offset(y: descriptionOffset)
                            .opacity(descriptionOpacity)
                            .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                            .padding(.horizontal, 25)
                        
                    }
                    .padding(.bottom, 60)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Staggered entrance animations for a sophisticated feel
        withAnimation(.easeOut(duration: 0.8).delay(0.1)) {
            image1Opacity = 1
            image1Offset = 0
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
            image2Opacity = 1
            image2Offset = 0
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
            titleOpacity = 1
            titleOffset = 0
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.7)) {
            descriptionOpacity = 1
            descriptionOffset = 0
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.9)) {
            buttonOpacity = 1
            buttonOffset = 0
        }
        
        // Background gradient animation
        withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
            backgroundGradientOffset = 20
        }
    }
}

// Onboarding page data structure
struct AnimatedOnboardingPage {
    let image1Name: String
    let image2Name: String
    let title: String
    let description: String
    let buttonText: String
    let accentColor: Color
    let gradientColors: [Color]
    let action: (() -> Void)?
    
    static let pages: [AnimatedOnboardingPage] = [
        AnimatedOnboardingPage(
            image1Name: "Onboarding 1",
            image2Name: "onboarding 11",
            title: "Leeds: A City of Innovation",
            description: "From the Industrial Revolution to today's digital age, Leeds builds the future.",
            buttonText: "Discover More",
            accentColor: .royalBlue,
            gradientColors: [
                Color(red: 0.1, green: 0.2, blue: 0.6), // Deep royal blue
                Color(red: 0.3, green: 0.1, blue: 0.5), // Purple
                Color(red: 0.6, green: 0.2, blue: 0.4), // Deep pink
                Color(red: 0.2, green: 0.4, blue: 0.8)  // Bright blue
            ],
            action: {}
        ),
        AnimatedOnboardingPage(
            image1Name: "Onboarding 2",
            image2Name: "Onboarding 22",
            title: "The People of Leeds",
            description: "Home to 800,000+ people united by community spirit and collaboration.",
            buttonText: "Connect",
            accentColor: .goldenYellow,
            gradientColors: [
                Color(red: 0.2, green: 0.4, blue: 0.8), // Deep blue
                Color(red: 0.8, green: 0.6, blue: 0.2), // Golden orange
                Color(red: 0.4, green: 0.2, blue: 0.6), // Purple
                Color(red: 0.1, green: 0.3, blue: 0.7)  // Royal blue
            ],
            action: {}
        ),
        AnimatedOnboardingPage(
            image1Name: "onboarding 11",
            image2Name: "Onboarding 3",
            title: "Your Journey Begins",
            description: "Join thousands already connected through LeedsLink. Your story starts here.",
            buttonText: "Start Your Story",
            accentColor: .royalBlue,
            gradientColors: [
                Color(red: 0.8, green: 0.4, blue: 0.2), // Warm orange
                Color(red: 0.2, green: 0.6, blue: 0.8), // Sky blue
                Color(red: 0.6, green: 0.2, blue: 0.4), // Deep pink
                Color(red: 0.3, green: 0.5, blue: 0.9)  // Bright blue
            ],
            action: {}
        )
    ]
}

#Preview {
    AnimatedOnboardingPageView(page: AnimatedOnboardingPage.pages[0])
}
