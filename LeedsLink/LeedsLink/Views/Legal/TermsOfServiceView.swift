import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                
                Group {
                    SectionView(
                        title: "1. Acceptance of Terms",
                        content: "By downloading, installing, or using the LeedsLink mobile application, you agree to be bound by these Terms of Service and all applicable laws and regulations."
                    )
                    
                    SectionView(
                        title: "2. Description of Service",
                        content: "LeedsLink is a local business networking platform that connects suppliers, service providers, and customers within the Leeds community. The app facilitates business listings, messaging, and community engagement."
                    )
                    
                    SectionView(
                        title: "3. User Accounts",
                        content: "To use certain features of the app, you must create an account. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account."
                    )
                    
                    SectionView(
                        title: "4. User Conduct",
                        content: "You agree to use the app in compliance with all applicable laws and regulations. You will not post false, misleading, or inappropriate content, and you will respect other users' privacy and rights."
                    )
                    
                    SectionView(
                        title: "5. Content and Intellectual Property",
                        content: "You retain ownership of content you post, but grant LeedsLink a license to use, display, and distribute your content within the app. You may not post copyrighted material without permission."
                    )
                    
                    SectionView(
                        title: "6. Privacy",
                        content: "Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information."
                    )
                    
                    SectionView(
                        title: "7. Prohibited Uses",
                        content: "You may not use the app for illegal activities, spam, harassment, or to violate others' rights. We reserve the right to suspend or terminate accounts that violate these terms."
                    )
                    
                    SectionView(
                        title: "8. Disclaimers",
                        content: "The app is provided 'as is' without warranties. We do not guarantee the accuracy of user-generated content or the availability of the service."
                    )
                    
                    SectionView(
                        title: "9. Limitation of Liability",
                        content: "LeedsLink shall not be liable for any indirect, incidental, or consequential damages arising from your use of the app."
                    )
                    
                    SectionView(
                        title: "10. Changes to Terms",
                        content: "We may update these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms."
                    )
                    
                    SectionView(
                        title: "11. Contact Information",
                        content: "If you have questions about these terms, please contact us at support@leedslink.app"
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.screenBackground)
    }
}

struct SectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.royalBlue)
            
            Text(content)
                .font(.body)
                .foregroundColor(.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        TermsOfServiceView()
    }
}
