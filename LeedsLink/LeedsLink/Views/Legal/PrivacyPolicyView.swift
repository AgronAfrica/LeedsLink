import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                
                Group {
                    SectionView(
                        title: "1. Information We Collect",
                        content: "We collect information you provide directly to us, such as when you create an account, post listings, send messages, or contact us. This includes your name, email, business information, and any content you share on the platform."
                    )
                    
                    SectionView(
                        title: "2. How We Use Your Information",
                        content: "We use your information to provide and improve our services, facilitate connections between users, send you important updates about the app, and ensure the safety and security of our platform."
                    )
                    
                    SectionView(
                        title: "3. Information Sharing",
                        content: "We do not sell your personal information. We may share your information with other users as part of the app's functionality (e.g., displaying your name and business in listings), or with service providers who help us operate the app."
                    )
                    
                    SectionView(
                        title: "4. Data Storage and Security",
                        content: "We implement appropriate security measures to protect your information. Your data is stored securely and we regularly review our security practices to ensure your information is protected."
                    )
                    
                    SectionView(
                        title: "5. Your Rights",
                        content: "You have the right to access, update, or delete your personal information. You can manage your account settings within the app or contact us directly for assistance."
                    )
                    
                    SectionView(
                        title: "6. Cookies and Tracking",
                        content: "We may use cookies and similar technologies to improve your experience, analyze app usage, and provide personalized content. You can manage these preferences in your device settings."
                    )
                    
                    SectionView(
                        title: "7. Third-Party Services",
                        content: "Our app may integrate with third-party services for features like analytics or push notifications. These services have their own privacy policies, and we encourage you to review them."
                    )
                    
                    SectionView(
                        title: "8. Data Retention",
                        content: "We retain your information for as long as your account is active or as needed to provide services. You can request deletion of your account and associated data at any time."
                    )
                    
                    SectionView(
                        title: "9. Children's Privacy",
                        content: "Our app is not intended for children under 13. We do not knowingly collect personal information from children under 13. If we become aware of such collection, we will take steps to delete the information."
                    )
                    
                    SectionView(
                        title: "10. International Users",
                        content: "If you are using our app from outside the United Kingdom, please note that your information may be transferred to and processed in the UK, where our servers are located."
                    )
                    
                    SectionView(
                        title: "11. Changes to This Policy",
                        content: "We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new policy in the app and updating the 'Last updated' date."
                    )
                    
                    SectionView(
                        title: "12. Contact Us",
                        content: "If you have any questions about this Privacy Policy or our data practices, please contact us at privacy@leedslink.app"
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.screenBackground)
    }
}

#Preview {
    NavigationView {
        PrivacyPolicyView()
    }
}
