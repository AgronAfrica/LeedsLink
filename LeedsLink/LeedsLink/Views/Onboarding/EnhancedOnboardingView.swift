import SwiftUI

struct EnhancedOnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var selectedRole: UserRole?
    @State private var name = ""
    @State private var businessName = ""
    @State private var address = ""
    @State private var phoneNumber = ""
    @State private var postcode = ""
    @State private var description = ""
    @State private var showRoleSelection = false
    @State private var showProfileForm = false
    @State private var showCompletion = false
    
    var body: some View {
        ZStack {
            // Full-screen gradient background that fills entire device
            AnimatedGradientBackground(colors: AnimatedOnboardingPage.pages[currentPage].gradientColors)
                .ignoresSafeArea(.all, edges: .all)
            
            // Fallback background to prevent white lines
            Color.black
                .ignoresSafeArea(.all, edges: .all)
                .opacity(0.01)
            
            if !showRoleSelection && !showProfileForm && !showCompletion {
                // Main onboarding flow
                VStack(spacing: 0) {
                    // Custom page indicator
                    HStack(spacing: 12) {
                        ForEach(0..<AnimatedOnboardingPage.pages.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
                        }
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 10)
                    
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(0..<AnimatedOnboardingPage.pages.count, id: \.self) { index in
                            AnimatedOnboardingPageView(
                                page: AnimatedOnboardingPage.pages[index]
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.6), value: currentPage)
                    
                    // Navigation controls with glass UI
                    VStack(spacing: 0) {
                        HStack {
                            if currentPage > 0 {
                                Button("Back") {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        currentPage -= 1
                                    }
                                }
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.white.opacity(0.15))
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(.ultraThinMaterial)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            
                            Spacer()
                            
                            if currentPage < AnimatedOnboardingPage.pages.count - 1 {
                                Button("Next") {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        currentPage += 1
                                    }
                                }
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.white.opacity(0.15))
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(.ultraThinMaterial)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            } else {
                                Button("Get Started") {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        showRoleSelection = true
                                    }
                                }
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .bold))
                                .padding(.horizontal, 32)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(.white.opacity(0.2))
                                        .background(
                                            RoundedRectangle(cornerRadius: 25)
                                                .fill(.ultraThinMaterial)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(.white.opacity(0.4), lineWidth: 1.5)
                                        )
                                )
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 50)
                    }
                }
            } else if showRoleSelection {
                // Role selection with enhanced design
                RoleSelectionView(
                    selectedRole: $selectedRole,
                    onContinue: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showRoleSelection = false
                            showProfileForm = true
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else if showProfileForm {
                // Profile form with enhanced design
                EnhancedProfileFormView(
                    selectedRole: selectedRole ?? .customer,
                    name: $name,
                    businessName: $businessName,
                    address: $address,
                    phoneNumber: $phoneNumber,
                    postcode: $postcode,
                    description: $description,
                    onBack: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showProfileForm = false
                            showRoleSelection = true
                        }
                    },
                    onContinue: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showProfileForm = false
                            showCompletion = true
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            } else if showCompletion {
                // Completion view with enhanced design
                OnboardingCompletionView(
                    name: name,
                    onComplete: completeOnboarding
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .ignoresSafeArea()
    }
    
    private func completeOnboarding() {
        guard let selectedRole = selectedRole else { return }
        
        let user = User(
            name: name,
            businessName: businessName.isEmpty ? nil : businessName,
            role: selectedRole,
            address: address,
            phoneNumber: phoneNumber,
            postcode: postcode,
            description: description
        )
        
        appState.createUser(user)
    }
}

// Enhanced Role Selection View
struct RoleSelectionView: View {
    @Binding var selectedRole: UserRole?
    let onContinue: () -> Void
    @State private var animateCards = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.royalBlue.opacity(0.9),
                    Color.royalBlue.opacity(0.7),
                    Color.goldenYellow.opacity(0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Header
                VStack(spacing: 16) {
                    Text("Choose Your Role")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Help us personalize your LeedsLink experience")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)
                
                // Role cards
                VStack(spacing: 20) {
                    ForEach(Array(UserRole.allCases.enumerated()), id: \.element) { index, role in
                        RoleCard(
                            role: role,
                            isSelected: selectedRole == role,
                            onTap: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    selectedRole = role
                                }
                            }
                        )
                        .offset(x: animateCards ? 0 : 100)
                        .opacity(animateCards ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(index) * 0.1),
                            value: animateCards
                        )
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Continue button
                Button(action: onContinue) {
                    HStack(spacing: 12) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.royalBlue)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                }
                .disabled(selectedRole == nil)
                .opacity(selectedRole == nil ? 0.6 : 1.0)
                .scaleEffect(selectedRole == nil ? 0.95 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedRole)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            animateCards = true
        }
    }
}

// Role Card Component
struct RoleCard: View {
    let role: UserRole
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 20) {
                // Icon
                Image(systemName: roleIcon(for: role))
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(isSelected ? .royalBlue : .white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? .white : .white.opacity(0.2))
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(role.rawValue)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(roleDescription(for: role))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            .padding(24)
            .glassmorphismEffect(opacity: isSelected ? 0.25 : 0.15)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .white : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
    }
    
    private func roleIcon(for role: UserRole) -> String {
        switch role {
        case .supplier:
            return "shippingbox.fill"
        case .serviceProvider:
            return "wrench.and.screwdriver.fill"
        case .customer:
            return "person.fill"
        }
    }
    
    private func roleDescription(for role: UserRole) -> String {
        switch role {
        case .supplier:
            return "Provide products and materials"
        case .serviceProvider:
            return "Offer professional services"
        case .customer:
            return "Find and purchase services"
        }
    }
}

#Preview {
    EnhancedOnboardingView()
        .environmentObject(AppState())
}
