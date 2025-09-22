import SwiftUI

struct ListingDetailView: View {
    let listing: Listing
    @EnvironmentObject var appState: AppState
    @State private var showMessageSheet = false
    @State private var showDeleteAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 24) {
                // Enhanced Header
                VStack(alignment: .leading, spacing: 20) {
                    // Top badges and category
                    VStack(alignment: .leading, spacing: 12) {
                        // Badges row - ensure they stay on same line
                        HStack(spacing: 8) {
                            Text(listing.type == .offer ? "OFFER" : "REQUEST")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(listing.type == .offer ? Color.green : Color.royalBlue)
                                .cornerRadius(8)
                                .fixedSize(horizontal: true, vertical: false)
                            
                            if listing.isUrgent {
                                Label("URGENT", systemImage: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.red)
                                    .cornerRadius(8)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            
                            Spacer()
                        }
                        
                        // Category badge on separate line for better spacing
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: categoryIcon(for: listing.category))
                                    .foregroundColor(.primary)
                                    .font(.subheadline)
                                Text(listing.category.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(12)
                            
                            Spacer()
                        }
                    }
                    
                    // Title with enhanced styling
                    Text(listing.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    
                    // Posted date with better styling
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text("Posted \(listing.createdAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.cardBackground)
                )
                
                // Enhanced Details Card
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                                    .foregroundColor(.primary)
                            .font(.title2)
                        Text("Details")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    VStack(spacing: 16) {
                        // Price/Budget with enhanced styling
                        if let price = listing.price {
                            EnhancedDetailRow(
                                icon: "sterlingsign.circle.fill",
                                title: "Price",
                                value: price,
                                iconColor: .green,
                                valueColor: .green
                            )
                        } else if let budget = listing.budget {
                            EnhancedDetailRow(
                                icon: "sterlingsign.circle.fill",
                                title: "Budget",
                                value: budget,
                                iconColor: .royalBlue,
                                valueColor: .royalBlue
                            )
                        }
                        
                        // Availability with enhanced styling
                        EnhancedDetailRow(
                            icon: "calendar.circle.fill",
                            title: "Availability",
                            value: listing.availability,
                            iconColor: .orange,
                            valueColor: .primaryText
                        )
                        
                        // Location with enhanced styling
                        if let address = listing.address, let postcode = listing.postcode {
                            EnhancedDetailRow(
                                icon: "location.circle.fill",
                                title: "Location",
                                value: "\(address), \(postcode)",
                                iconColor: .purple,
                                valueColor: .purple
                            )
                        }
                        
                        // Posted date with enhanced styling
                        EnhancedDetailRow(
                            icon: "clock.circle.fill",
                            title: "Posted",
                            value: listing.createdAt.formatted(date: .abbreviated, time: .omitted),
                            iconColor: .secondaryText,
                            valueColor: .secondaryText
                        )
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.cardBackground)
                )
                .shadow(color: Color.gray.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Enhanced Description
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.primary)
                                .font(.title3)
                        }
                        
                        Text("Description")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    Text(listing.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 4)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.cardBackground)
                )
                .shadow(color: Color.gray.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Enhanced Tags
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "tag.fill")
                                .foregroundColor(.primary)
                                .font(.title3)
                        }
                        
                        Text("Tags")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    if listing.tags.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tag.slash")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text("No tags added")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        FlowLayout(spacing: 12) {
                            ForEach(listing.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.accentColor.opacity(0.1),
                                                Color.accentColor.opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .foregroundColor(.primary)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.cardBackground)
                )
                .shadow(color: Color.gray.opacity(0.1), radius: 8, x: 0, y: 4)
                
                // Enhanced Owner Rating Section
                if let owner = getOwnerForListing() {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "star.fill")
                                    .foregroundColor(.primary)
                                    .font(.title3)
                            }
                            
                            Text("Owner Rating")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        if let ratingSummary = owner.ratingSummary, ratingSummary.totalRatings > 0 {
                            RatingSummaryCard(ratingSummary: ratingSummary, showDetails: true)
                                .padding(.horizontal, 24)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "star.slash")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("No ratings yet")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Text("Be the first to rate this \(owner.role.rawValue.lowercased())")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.gray.opacity(0.1), radius: 8, x: 0, y: 4)
                }
                
                // Enhanced Similar Listings
                if !similarListings.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.accentColor.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: "rectangle.stack.fill")
                                    .foregroundColor(.primary)
                                    .font(.title3)
                            }
                            
                            Text("Similar Listings")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(similarListings.count) found")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(similarListings) { similar in
                                    NavigationLink(destination: ListingDetailView(listing: similar)) {
                                        EnhancedMiniListingCard(listing: similar)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.gray.opacity(0.1), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.bottom, 20) // Small bottom padding
        }
        .background(Color.screenBackground)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            // Enhanced Action Button - Fixed at bottom
            VStack(spacing: 0) {
                // Clear separator
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                
                VStack(spacing: 12) {
                    if isOwnListing {
                        // Enhanced Delete Button for own listings
                        Button(action: {
                            showDeleteAlert = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "trash.fill")
                                    .font(.title3)
                                Text("Delete Listing")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                                    .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    } else {
                        // Enhanced Message Button for other listings
                        Button(action: {
                            showMessageSheet = true
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "message.fill")
                                    .font(.title3)
                                Text("Send Message")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                                    .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.royalBlue, Color.royalBlue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.royalBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.screenBackground)
            }
        }
        .sheet(isPresented: $showMessageSheet) {
            MessageComposeView(listing: listing)
                .environmentObject(appState)
        }
        .alert("Delete Listing", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteListing()
            }
        } message: {
            Text("Are you sure you want to delete this listing? This action cannot be undone.")
        }
    }
    
    private var similarListings: [Listing] {
        appState.getTopMatches(for: listing)
    }
    
    private var isOwnListing: Bool {
        appState.currentUser?.id == listing.userId
    }
    
    private func deleteListing() {
        appState.deleteListing(listing.id)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func getOwnerForListing() -> User? {
        // In a real app, you would fetch the user by listing.userId
        // For now, we'll return a mock user or the current user if it's their listing
        if isOwnListing {
            return appState.currentUser
        } else {
            // Return a mock user for demonstration
            return User(
                name: "Listing Owner",
                businessName: "Sample Business",
                role: .serviceProvider,
                address: "123 Sample Street",
                phoneNumber: "0113 123 4567",
                postcode: "LS1 1AA",
                description: "Professional service provider",
                ratingSummary: UserRatingSummary(
                    userId: UUID(),
                    ratings: [
                        Rating(fromUserId: UUID(), toUserId: UUID(), rating: 5, review: "Excellent service!", category: .overall),
                        Rating(fromUserId: UUID(), toUserId: UUID(), rating: 4, review: "Very professional", category: .service),
                        Rating(fromUserId: UUID(), toUserId: UUID(), rating: 5, review: "Great communication", category: .communication)
                    ]
                )
            )
        }
    }
    
    private func categoryIcon(for category: ListingCategory) -> String {
        switch category {
        case .food: return "fork.knife"
        case .construction: return "hammer.fill"
        case .professional: return "briefcase.fill"
        case .retail: return "bag.fill"
        case .health: return "heart.fill"
        case .technology: return "laptopcomputer"
        case .hospitality: return "bed.double.fill"
        case .education: return "book.fill"
        case .transport: return "car.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                                    .foregroundColor(.primary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

struct EnhancedDetailRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    let valueColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with background
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
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(valueColor)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct MiniListingCard: View {
    let listing: Listing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(listing.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            Text(listing.category.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let price = listing.price {
                Text(price)
                    .font(.caption)
                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
            } else if let budget = listing.budget {
                Text(budget)
                    .font(.caption)
                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
            }
        }
        .frame(width: 150)
        .padding()
        .cardStyle()
    }
}

struct EnhancedMiniListingCard: View {
    let listing: Listing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with type badge
            HStack {
                Text(listing.type == .offer ? "OFFER" : "REQUEST")
                    .font(.caption2)
                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(listing.type == .offer ? Color.green : Color.royalBlue)
                    .cornerRadius(6)
                
                Spacer()
                
                if listing.isUrgent {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
            
            // Title
            Text(listing.title)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(2)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            // Category
            HStack(spacing: 4) {
                Image(systemName: categoryIcon(for: listing.category))
                    .font(.caption2)
                                    .foregroundColor(.primary)
                Text(listing.category.rawValue)
                    .font(.caption)
                                    .foregroundColor(.primary)
                    .fontWeight(.medium)
            }
            
            // Description preview
            Text(listing.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Price/Budget
            if let price = listing.price {
                HStack(spacing: 4) {
                    Image(systemName: "sterlingsign.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text(price)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            } else if let budget = listing.budget {
                HStack(spacing: 4) {
                    Image(systemName: "sterlingsign.circle.fill")
                        .font(.caption2)
                                    .foregroundColor(.primary)
                    Text(budget)
                        .font(.caption)
                        .fontWeight(.bold)
                                    .foregroundColor(.primary)
                }
            }
            
            // Location information
            if let address = listing.address, let postcode = listing.postcode {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2)
                        .foregroundColor(.purple)
                    Text("\(address), \(postcode)")
                        .font(.caption2)
                        .foregroundColor(.purple)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .frame(width: 180, height: 160)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground)
        )
        .shadow(color: listing.isUrgent ? Color.red.opacity(0.1) : Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func categoryIcon(for category: ListingCategory) -> String {
        switch category {
        case .food: return "fork.knife"
        case .construction: return "hammer.fill"
        case .professional: return "briefcase.fill"
        case .retail: return "bag.fill"
        case .health: return "heart.fill"
        case .technology: return "laptopcomputer"
        case .hospitality: return "bed.double.fill"
        case .education: return "book.fill"
        case .transport: return "car.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

struct MessageComposeView: View {
    let listing: Listing
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    @State private var messageText = ""
    @State private var showMessageSentSplash = false
    @State private var messageSentScale: CGFloat = 0.5
    @State private var messageSentOpacity: Double = 0.0
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("Regarding") {
                        Text(listing.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Section("Your Message") {
                        TextEditor(text: $messageText)
                            .frame(minHeight: 150)
                    }
                }
                
                Button(action: sendMessage) {
                    Text("Send Message")
                        .font(.headline)
                                    .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.royalBlue)
                        .cornerRadius(25)
                        .disabled(messageText.isEmpty)
                }
                .padding()
            }
            .navigationTitle("New Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .overlay(
                // Message Sent Splash Animation
                ZStack {
                    if showMessageSentSplash {
                        // Background blur
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .transition(.opacity)
                        
                        // Message sent card
                        VStack(spacing: 16) {
                            // Success icon with animation
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(messageSentScale)
                                
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 60, height: 60)
                                    .scaleEffect(messageSentScale)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .scaleEffect(messageSentScale)
                            }
                            
                            // Message text
                            VStack(spacing: 8) {
                                Text("Message Sent!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Your message has been delivered")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(32)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.regularMaterial)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .scaleEffect(messageSentScale)
                        .opacity(messageSentOpacity)
                        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showMessageSentSplash)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: messageSentScale)
                .animation(.easeInOut(duration: 0.3), value: messageSentOpacity)
            )
        }
    }
    
    private func sendMessage() {
        // Create a mock conversation
        let otherUserName = "Listing Owner" // In real app, would fetch from user data
        
        let conversationId = appState.createConversation(
            with: listing.userId,
            otherUserName: otherUserName
        )
        
        // Send the message
        appState.sendMessage(in: conversationId, content: messageText)
        
        // Trigger message sent splash animation
        showMessageSentSplash = true
        messageSentScale = 0.5
        messageSentOpacity = 0.0
        
        // Animate the splash
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            messageSentScale = 1.0
            messageSentOpacity = 1.0
        }
        
        // Hide the splash and dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                messageSentOpacity = 0.0
                messageSentScale = 0.8
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showMessageSentSplash = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX,
                                      y: result.positions[index].y + bounds.minY),
                          proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
                self.size.width = max(self.size.width, x - spacing)
            }
            self.size.height = y + rowHeight
        }
    }
}

#Preview {
    NavigationView {
        ListingDetailView(listing: MockDataGenerator.generateMockListings()[0])
            .environmentObject(AppState())
    }
}
