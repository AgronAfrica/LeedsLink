import SwiftUI

// MARK: - Star Rating Display Component
struct StarRatingView: View {
    let rating: Double
    let maxRating: Int = 5
    let size: CGFloat
    let showEmptyStars: Bool
    
    init(rating: Double, size: CGFloat = 16, showEmptyStars: Bool = true) {
        self.rating = rating
        self.size = size
        self.showEmptyStars = showEmptyStars
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: starIcon(for: index))
                    .font(.system(size: size, weight: .medium))
                    .foregroundColor(starColor(for: index))
            }
        }
    }
    
    private func starIcon(for index: Int) -> String {
        if Double(index) <= rating {
            return "star.fill"
        } else if Double(index) - 0.5 <= rating {
            return "star.lefthalf.fill"
        } else {
            return showEmptyStars ? "star" : "star.fill"
        }
    }
    
    private func starColor(for index: Int) -> Color {
        if Double(index) <= rating || (Double(index) - 0.5 <= rating) {
            return .goldenYellow
        } else {
            return showEmptyStars ? .gray.opacity(0.3) : .gray.opacity(0.1)
        }
    }
}

// MARK: - Rating Summary Card
struct RatingSummaryCard: View {
    let ratingSummary: UserRatingSummary
    let showDetails: Bool
    
    init(ratingSummary: UserRatingSummary, showDetails: Bool = true) {
        self.ratingSummary = ratingSummary
        self.showDetails = showDetails
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Main rating display
            HStack(spacing: 12) {
                // Large rating number
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f", ratingSummary.averageRating))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    StarRatingView(rating: ratingSummary.averageRating, size: 20)
                    
                    Text("\(ratingSummary.totalRatings) review\(ratingSummary.totalRatings == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Rating breakdown
                if showDetails && !ratingSummary.ratingBreakdown.isEmpty {
                    VStack(alignment: .trailing, spacing: 4) {
                        ForEach([5, 4, 3, 2, 1], id: \.self) { starCount in
                            HStack(spacing: 8) {
                                Text("\(starCount)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: 12)
                                
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(.goldenYellow)
                                
                                ProgressView(value: Double(ratingSummary.ratingBreakdown[starCount] ?? 0), total: Double(ratingSummary.totalRatings))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .goldenYellow))
                                    .frame(width: 60)
                                
                                Text("\(ratingSummary.ratingBreakdown[starCount] ?? 0)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(width: 20, alignment: .trailing)
                            }
                        }
                    }
                }
            }
            
            // Category ratings
            if showDetails && !ratingSummary.categoryRatings.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category Ratings")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    ForEach(Array(ratingSummary.categoryRatings.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { category in
                        if let categoryRating = ratingSummary.categoryRatings[category] {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(.primary)
                                    .font(.caption)
                                    .frame(width: 16)
                                
                                Text(category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                StarRatingView(rating: categoryRating, size: 12)
                                
                                Text(String(format: "%.1f", categoryRating))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 24, alignment: .trailing)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Rating Input Component
struct RatingInputView: View {
    @Binding var rating: Int
    @Binding var review: String
    @State private var selectedCategory: RatingCategory = .overall
    let onSubmit: () -> Void
    let onCancel: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Rate & Review")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Share your experience to help others")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Category selection
            VStack(alignment: .leading, spacing: 12) {
                Text("Category")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(RatingCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category,
                                onTap: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCategory = category
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            
            // Star rating input
            VStack(alignment: .leading, spacing: 12) {
                Text("Rating")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { index in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                rating = index
                                isAnimating = true
                            }
                        }) {
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(index <= rating ? .goldenYellow : .gray.opacity(0.3))
                                .scaleEffect(isAnimating && index <= rating ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: rating)
                        }
                    }
                }
            }
            
            // Review text input
            VStack(alignment: .leading, spacing: 12) {
                Text("Review (Optional)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                TextEditor(text: $review)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(12)
                    .frame(minHeight: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button("Cancel") {
                    onCancel()
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.1))
                )
                
                Spacer()
                
                Button("Submit") {
                    onSubmit()
                }
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(rating > 0 ? Color.royalBlue : Color.gray)
                )
                .disabled(rating == 0)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: Color.gray.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .onAppear {
            isAnimating = false
        }
    }
}

// MARK: - Compact Rating Display
struct CompactRatingView: View {
    let rating: Double
    let reviewCount: Int
    let size: CGFloat
    
    init(rating: Double, reviewCount: Int, size: CGFloat = 14) {
        self.rating = rating
        self.reviewCount = reviewCount
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: 4) {
            StarRatingView(rating: rating, size: size, showEmptyStars: false)
            
            Text(String(format: "%.1f", rating))
                .font(.system(size: size, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("(\(reviewCount))")
                .font(.system(size: size - 2))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Individual Review Card
struct ReviewCard: View {
    let rating: Rating
    let reviewerName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with reviewer info and rating
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reviewerName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(rating.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StarRatingView(rating: Double(rating.rating), size: 14)
                    
                    Text(rating.category.rawValue)
                        .font(.caption2)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.royalBlue.opacity(0.1))
                        )
                }
            }
            
            // Review text
            if let review = rating.review, !review.isEmpty {
                Text(review)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Category Button Component
struct CategoryButton: View {
    let category: RatingCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.caption)
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .royalBlue)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.royalBlue : Color.royalBlue.opacity(0.1))
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Rating Summary Preview
        RatingSummaryCard(
            ratingSummary: UserRatingSummary(
                userId: UUID(),
                ratings: [
                    Rating(fromUserId: UUID(), toUserId: UUID(), rating: 5, review: "Excellent service!", category: .overall),
                    Rating(fromUserId: UUID(), toUserId: UUID(), rating: 4, review: "Very good communication", category: .communication),
                    Rating(fromUserId: UUID(), toUserId: UUID(), rating: 5, review: "Great value for money", category: .value)
                ]
            )
        )
        
        // Compact Rating Preview
        CompactRatingView(rating: 4.5, reviewCount: 23)
        
        // Review Card Preview
        ReviewCard(
            rating: Rating(fromUserId: UUID(), toUserId: UUID(), rating: 5, review: "Amazing service! Highly recommended.", category: .overall),
            reviewerName: "John Smith"
        )
    }
    .padding()
}
