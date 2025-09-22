import SwiftUI

struct RatingInputSheet: View {
    let targetUser: User
    @EnvironmentObject var ratingManager: RatingManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var rating: Int = 0
    @State private var review: String = ""
    @State private var selectedCategory: RatingCategory = .overall
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        // Target user info
                        HStack(spacing: 16) {
                            // Avatar
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.royalBlue, Color.royalBlue.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(targetUser.name.prefix(1).uppercased())
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(targetUser.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                if let businessName = targetUser.businessName {
                                    Text(businessName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(targetUser.role.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.royalBlue.opacity(0.1))
                                    )
                            }
                            
                            Spacer()
                        }
                        
                        Text("Share your experience to help others make informed decisions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    
                    // Rating input component
                    RatingInputView(
                        rating: $rating,
                        review: $review,
                        onSubmit: submitRating,
                        onCancel: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Rate & Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func submitRating() {
        guard let currentUser = ratingManager.ratings.first?.fromUserId else { return }
        
        isSubmitting = true
        
        let newRating = Rating(
            fromUserId: currentUser,
            toUserId: targetUser.id,
            rating: rating,
            review: review.isEmpty ? nil : review,
            category: selectedCategory
        )
        
        // Submit the rating
        ratingManager.submitRating(newRating)
        
        // Show success feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSubmitting = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Rating List View
struct RatingListView: View {
    let userId: UUID
    @EnvironmentObject var ratingManager: RatingManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Reviews")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let summary = ratingManager.getRatingSummary(for: userId) {
                    Text("\(summary.totalRatings) review\(summary.totalRatings == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // Reviews list
            let userRatings = ratingManager.getRatings(for: userId)
            
            if userRatings.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.slash")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("No reviews yet")
                        .font(.body)
                        .foregroundColor(.secondary)
                    Text("Be the first to leave a review")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(userRatings) { rating in
                        ReviewCard(
                            rating: rating,
                            reviewerName: "Anonymous User" // In a real app, fetch reviewer name
                        )
                    }
                }
            }
        }
        .padding(20)
    }
}

#Preview {
    RatingInputSheet(
        targetUser: User(
            name: "John Smith",
            businessName: "Smith's Services",
            role: .serviceProvider,
            address: "123 Main St",
            phoneNumber: "0113 123 4567",
            postcode: "LS1 1AA",
            description: "Professional service provider"
        )
    )
    .environmentObject(RatingManager.shared)
}
