import SwiftUI

struct LeedsStoryOnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to Leeds",
            subtitle: "A City of Innovation",
            description: "From the Industrial Revolution to today's digital age, Leeds has always been a city that builds the future.",
            icon: "building.2.crop.circle.fill",
            color: Color.royalBlue,
            backgroundGradient: [Color.royalBlue.opacity(0.9), Color.royalBlue.opacity(0.7)]
        ),
        OnboardingPage(
            title: "The People of Leeds",
            subtitle: "Diverse & Connected",
            description: "Home to over 800,000 people from all walks of life, united by a spirit of community and collaboration.",
            icon: "person.3.sequence.fill",
            color: Color.royalBlue,
            backgroundGradient: [Color.royalBlue.opacity(0.9), Color.royalBlue.opacity(0.7)]
        ),
        OnboardingPage(
            title: "LeedsLink",
            subtitle: "Connecting Communities",
            description: "Your gateway to Leeds' vibrant business ecosystem. Connect, collaborate, and grow together.",
            icon: "link.circle.fill",
            color: Color.royalBlue,
            backgroundGradient: [Color.royalBlue.opacity(0.8), Color.goldenYellow.opacity(0.6)]
        )
    ]
    
    var body: some View {
        ZStack {
            // Static background that fills the entire screen
            LinearGradient(
                gradient: Gradient(colors: pages[currentPage].backgroundGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // Main content - static
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Static page indicator
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                    }
                }
                .padding(.bottom, 40)
                
                // Static action buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button("Back") {
                            currentPage -= 1
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    Spacer()
                    
                    Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                        if currentPage == pages.count - 1 {
                            // Complete Leeds story, move to main onboarding
                            appState.showLeedsStory = false
                        } else {
                            currentPage += 1
                        }
                    }
                    .foregroundColor(pages[currentPage].color)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let backgroundGradient: [Color]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Static icon with improved clarity
            ZStack {
                // Enhanced glow effect for better visibility
                Circle()
                    .fill(page.color.opacity(0.6))
                    .frame(width: 220, height: 220)
                    .blur(radius: 25)
                
                // Enhanced background ring for better visibility
                Circle()
                    .stroke(page.color.opacity(0.5), lineWidth: 3)
                    .frame(width: 200, height: 200)
                
                // Main icon with improved clarity
                Image(systemName: page.icon)
                    .font(.system(size: 90, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.6), radius: 12, x: 0, y: 6)
            }
            
            VStack(spacing: 20) {
                // Title with improved clarity
                Text(page.title)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 3)
                
                // Subtitle with improved clarity
                Text(page.subtitle)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 2)
                
                // Description with improved clarity
                Text(page.description)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            Spacer()
        }
    }
}

#Preview {
    LeedsStoryOnboardingView()
        .environmentObject(AppState())
}
