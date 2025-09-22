import SwiftUI

struct AboutLeedsLinkView: View {
    @State private var showingShareSheet = false
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // App Header
                VStack(spacing: 20) {
                    // App Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [Color.royalBlue, Color.royalBlue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "link")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        Text("LeedsLink")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                
                // App Description
                VStack(alignment: .leading, spacing: 16) {
                    Text("About LeedsLink")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("LeedsLink connects people in your local community by making it easy to share opportunities and requests. Whether you need help with something or have something to offer, LeedsLink helps you find the right people in your area.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 16) {
                    Text("Key Features")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(
                            icon: "location.circle.fill",
                            title: "Location-Based Matching",
                            description: "Find opportunities and requests in your local area"
                        )
                        
                        FeatureRow(
                            icon: "message.circle.fill",
                            title: "Direct Messaging",
                            description: "Connect directly with people through secure messaging"
                        )
                        
                        FeatureRow(
                            icon: "bell.circle.fill",
                            title: "Smart Notifications",
                            description: "Get notified about relevant opportunities and matches"
                        )
                        
                        FeatureRow(
                            icon: "shield.circle.fill",
                            title: "Safe & Secure",
                            description: "Your privacy and security are our top priorities"
                        )
                    }
                }
                
                // Team & Credits
                VStack(alignment: .leading, spacing: 16) {
                    Text("Team & Credits")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        CreditRow(
                            title: "Development Team",
                            subtitle: "LeedsLink Development Team"
                        )
                        
                        CreditRow(
                            title: "Design",
                            subtitle: "LeedsLink Design Team"
                        )
                        
                        CreditRow(
                            title: "Special Thanks",
                            subtitle: "To all our beta testers and community members"
                        )
                    }
                }
                
                // Legal & Links
                VStack(alignment: .leading, spacing: 16) {
                    Text("Legal & Links")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        ActionRow(
                            icon: "doc.text",
                            title: "Privacy Policy",
                            action: {
                                showingPrivacyPolicy = true
                            }
                        )
                        
                        ActionRow(
                            icon: "doc.plaintext",
                            title: "Terms of Service",
                            action: {
                                showingTermsOfService = true
                            }
                        )
                        
                        ActionRow(
                            icon: "square.and.arrow.up",
                            title: "Share LeedsLink",
                            action: {
                                showingShareSheet = true
                            }
                        )
                        
                        ActionRow(
                            icon: "star",
                            title: "Rate on App Store",
                            action: {
                                if let url = URL(string: "https://apps.apple.com/app/leedslink/id123456789") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                    }
                }
                
                // Copyright
                VStack(spacing: 8) {
                    Text("© 2025 LeedsLink")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("All rights reserved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
            }
            .padding(20)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [
                "Check out LeedsLink - the app that connects your local community!",
                URL(string: "https://leedslink.app")!
            ])
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            LegalDocumentView(
                title: "Privacy Policy",
                content: privacyPolicyContent
            )
        }
        .sheet(isPresented: $showingTermsOfService) {
            LegalDocumentView(
                title: "Terms of Service",
                content: termsOfServiceContent
            )
        }
    }
    
    private let privacyPolicyContent = """
    Privacy Policy for LeedsLink
    
    Last updated: December 2024
    
    1. Information We Collect
    We collect information you provide directly to us, such as when you create an account, create listings, or communicate with other users.
    
    2. How We Use Your Information
    We use the information we collect to provide, maintain, and improve our services, communicate with you, and ensure the safety of our platform.
    
    3. Information Sharing
    We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.
    
    4. Data Security
    We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.
    
    5. Your Rights
    You have the right to access, update, or delete your personal information. You can do this through the app settings or by contacting us.
    
    6. Contact Us
    If you have any questions about this Privacy Policy, please contact us at privacy@leedslink.app
    """
    
    private let termsOfServiceContent = """
    Terms of Service for LeedsLink
    
    Last updated: December 2024
    
    1. Acceptance of Terms
    By using LeedsLink, you agree to be bound by these Terms of Service and all applicable laws and regulations.
    
    2. Use License
    Permission is granted to temporarily use LeedsLink for personal, non-commercial transitory viewing only.
    
    3. User Conduct
    You agree to use LeedsLink in a manner that is lawful, respectful, and in accordance with these terms.
    
    4. Content
    You are responsible for the content you post and must ensure it does not violate any laws or infringe on others' rights.
    
    5. Privacy
    Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the service.
    
    6. Termination
    We may terminate or suspend your account at any time for violations of these terms.
    
    7. Contact Information
    If you have any questions about these Terms of Service, please contact us at legal@leedslink.app
    """
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.royalBlue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
        }
    }
}

struct CreditRow: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ActionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.royalBlue)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct LegalDocumentView: View {
    let title: String
    let content: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
                Text(content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(20)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

#Preview {
    NavigationView {
        AboutLeedsLinkView()
    }
}
