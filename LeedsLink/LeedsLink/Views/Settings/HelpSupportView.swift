import SwiftUI

struct HelpSupportView: View {
    @State private var showingContactForm = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // FAQ Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Frequently Asked Questions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        FAQRow(
                            question: "How do I create a listing?",
                            answer: "Tap the 'Create' tab and fill out the form with your listing details."
                        )
                        
                        FAQRow(
                            question: "How do I find listings near me?",
                            answer: "Use the 'Home' tab to browse listings in your area. You can filter by category and distance."
                        )
                        
                        FAQRow(
                            question: "How do I contact someone about a listing?",
                            answer: "Tap on a listing to view details, then tap 'Message' to start a conversation."
                        )
                        
                        FAQRow(
                            question: "How do I manage my notifications?",
                            answer: "Go to Settings > Notifications to customize your notification preferences."
                        )
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Contact Support Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Contact Support")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Need more help? Contact our support team.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingContactForm = true
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Send Message")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.royalBlue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
        }
        .background(Color.screenBackground)
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingContactForm) {
            ContactSupportView()
        }
    }
}

struct FAQRow: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.royalBlue)
                        .font(.caption)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
    }
}

struct ContactSupportView: View {
    @State private var subject = ""
    @State private var message = ""
    @State private var selectedCategory = "General"
    @Environment(\.dismiss) private var dismiss
    
    let categories = ["General", "Bug Report", "Feature Request", "Account Issue", "Technical Problem"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contact Support")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("We're here to help! Send us a message and we'll get back to you as soon as possible.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Category")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Subject")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter subject", text: $subject)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Message")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Describe your issue or question...", text: $message, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(5...10)
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        sendSupportMessage()
                    }
                    .disabled(subject.isEmpty || message.isEmpty)
                }
            }
        }
    }
    
    private func sendSupportMessage() {
        // Create email URL with support message
        let emailSubject = "[\(selectedCategory)] \(subject)"
        let emailBody = """
        Category: \(selectedCategory)
        Subject: \(subject)
        
        Message:
        \(message)
        
        ---
        Sent from LeedsLink App
        """
        
        // Encode the email components
        let encodedSubject = emailSubject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Create mailto URL
        let mailtoURL = "mailto:leedslinkapp@gmail.com?subject=\(encodedSubject)&body=\(encodedBody)"
        
        // Open the email client
        if let url = URL(string: mailtoURL) {
            UIApplication.shared.open(url)
        }
        
        dismiss()
    }
}

#Preview {
    NavigationView {
        HelpSupportView()
    }
}