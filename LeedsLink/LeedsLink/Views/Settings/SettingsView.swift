import SwiftUI

struct AppSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var expandedSection: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Simple animated background
                AnimatedBackground()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Splash Screen Motion Effects in Empty Space
                        SplashMotionView()
                            .frame(height: 300)
                            .padding()
                        
                        // Settings sections
                    // User Profile Section
                    if let user = appState.currentUser {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                // Profile Avatar
                                ZStack {
                                    Circle()
                                        .fill(Color.royalBlue.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    
                                    Text(String(user.name.prefix(1)).uppercased())
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.royalBlue)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text(user.role.rawValue)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(user.postcode)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                    }
                    
                    // Settings Options
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(spacing: 12) {
                                // Notifications
                                SettingsSection(
                                    icon: "bell.fill",
                                    title: "Notifications",
                                    subtitle: "Manage your notification preferences",
                                    iconColor: .blue,
                                    isExpanded: expandedSection == "notifications"
                                ) {
                                    NotificationSettingsView()
                                } onTap: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        expandedSection = expandedSection == "notifications" ? nil : "notifications"
                                    }
                                }
                                
                                // Privacy
                                SettingsSection(
                                    icon: "shield.fill",
                                    title: "Privacy & Security",
                                    subtitle: "Manage your privacy settings",
                                    iconColor: .green,
                                    isExpanded: expandedSection == "privacy"
                                ) {
                                    PrivacySecurityView()
                                } onTap: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        expandedSection = expandedSection == "privacy" ? nil : "privacy"
                                    }
                                }
                                
                                // Help & Support
                                SettingsSection(
                                    icon: "questionmark.circle.fill",
                                    title: "Help & Support",
                                    subtitle: "Get help and contact support",
                                    iconColor: .orange,
                                    isExpanded: expandedSection == "help"
                                ) {
                                    HelpSupportView()
                                } onTap: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        expandedSection = expandedSection == "help" ? nil : "help"
                                    }
                                }
                                
                                // About
                                SettingsSection(
                                    icon: "info.circle.fill",
                                    title: "About LeedsLink",
                                    subtitle: "App version and information",
                                    iconColor: .purple,
                                    isExpanded: expandedSection == "about"
                                ) {
                                    AboutLeedsLinkView()
                                } onTap: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        expandedSection = expandedSection == "about" ? nil : "about"
                                    }
                                }
                                
                            }
                        }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    
                    
                    // App Statistics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            StatRow(
                                icon: "doc.text.fill",
                                title: "Listings Created",
                                value: "\(appState.listingsCreatedCount)",
                                iconColor: .blue
                            )
                            
                            StatRow(
                                icon: "heart.fill",
                                title: "Matches Found",
                                value: "\(appState.matchesFoundCount)",
                                iconColor: .red
                            )
                            
                            StatRow(
                                icon: "message.fill",
                                title: "Messages Sent",
                                value: "\(appState.messagesSentCount)",
                                iconColor: .green
                            )
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                }
                .padding()
                    }
                }
            }
            .background(Color.screenBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: (() -> Void)?
    
    init(icon: String, title: String, subtitle: String, iconColor: Color, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title3)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            action?()
        }
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title3)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Total count")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Value
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(iconColor)
        }
        .padding(.vertical, 8)
    }
}

struct SettingsSection<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let isExpanded: Bool
    let content: Content
    let onTap: () -> Void
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        iconColor: Color,
        isExpanded: Bool,
        @ViewBuilder content: () -> Content,
        onTap: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.iconColor = iconColor
        self.isExpanded = isExpanded
        self.content = content()
        self.onTap = onTap
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: onTap) {
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(iconColor)
                    }
                    
                    // Text Content
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Chevron
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Content
            if isExpanded {
                VStack {
                    Divider()
                        .padding(.vertical, 8)
                    
                    content
                        .padding(.top, 8)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

struct AnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.royalBlue.opacity(0.1),
                Color.screenBackground,
                Color.royalBlue.opacity(0.05)
            ]),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

struct SplashMotionView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.6
    @State private var rotation: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            Spacer()
            
            // App Icon with same animations as splash screen
            ZStack {
                // Pulse ring effect
                Circle()
                    .stroke(Color.royalBlue.opacity(0.3), lineWidth: 3)
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulseScale)
                    .opacity(isAnimating ? 0.0 : 0.6)
                
                // Rotating ring
                Circle()
                    .stroke(Color.royalBlue.opacity(0.5), lineWidth: 2)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(rotation))
                
                // Main app icon
                Image(systemName: "building.2.crop.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.royalBlue)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            }
            
            // App name with same styling as splash
            VStack(spacing: 4) {
                Text("LeedsLink")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.royalBlue)
                    .opacity(opacity)
                
                Text("Connecting Leeds")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.royalBlue.opacity(0.7))
                    .opacity(opacity)
            }
            
            // Loading indicator dots
            HStack(spacing: 6) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.royalBlue)
                        .frame(width: 6, height: 6)
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
            
            Spacer()
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Initial entrance animation
        withAnimation(.easeOut(duration: 1.0)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Continuous animations (same as splash screen)
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotation = 360.0
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
        }
        
        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
    }
}

#Preview {
    AppSettingsView()
        .environmentObject(AppState())
}
