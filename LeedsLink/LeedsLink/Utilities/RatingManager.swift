import Foundation

class RatingManager: ObservableObject {
    static let shared = RatingManager()
    
    @Published var ratings: [Rating] = []
    @Published var userRatingSummaries: [UUID: UserRatingSummary] = [:]
    
    private init() {
        loadMockRatings()
    }
    
    // MARK: - Rating Operations
    
    func submitRating(_ rating: Rating) {
        // Remove any existing rating from the same user to the same user
        ratings.removeAll { $0.fromUserId == rating.fromUserId && $0.toUserId == rating.toUserId }
        
        // Add the new rating
        ratings.append(rating)
        
        // Update the rating summary for the rated user
        updateRatingSummary(for: rating.toUserId)
        
        // Save to persistent storage (in a real app)
        saveRatings()
    }
    
    func getRatings(for userId: UUID) -> [Rating] {
        return ratings.filter { $0.toUserId == userId }
    }
    
    func getRatingSummary(for userId: UUID) -> UserRatingSummary? {
        return userRatingSummaries[userId]
    }
    
    func canRate(from fromUserId: UUID, to toUserId: UUID) -> Bool {
        // Users can't rate themselves
        guard fromUserId != toUserId else { return false }
        
        // Check if user has already rated (optional - you might want to allow multiple ratings)
        return !ratings.contains { $0.fromUserId == fromUserId && $0.toUserId == toUserId }
    }
    
    // MARK: - Private Methods
    
    private func updateRatingSummary(for userId: UUID) {
        let userRatings = getRatings(for: userId)
        userRatingSummaries[userId] = UserRatingSummary(userId: userId, ratings: userRatings)
    }
    
    private func saveRatings() {
        // In a real app, save to persistent storage
        // For now, we'll just keep them in memory
    }
    
    private func loadMockRatings() {
        // Create some mock ratings for demonstration
        let mockRatings = [
            Rating(
                fromUserId: UUID(),
                toUserId: UUID(),
                rating: 5,
                review: "Excellent service! Very professional and reliable.",
                category: .overall
            ),
            Rating(
                fromUserId: UUID(),
                toUserId: UUID(),
                rating: 4,
                review: "Good communication throughout the project.",
                category: .communication
            ),
            Rating(
                fromUserId: UUID(),
                toUserId: UUID(),
                rating: 5,
                review: "Great value for money. Highly recommended!",
                category: .value
            ),
            Rating(
                fromUserId: UUID(),
                toUserId: UUID(),
                rating: 4,
                review: "Service was delivered on time and as promised.",
                category: .reliability
            ),
            Rating(
                fromUserId: UUID(),
                toUserId: UUID(),
                rating: 5,
                review: "Outstanding quality of work. Will definitely use again.",
                category: .service
            )
        ]
        
        ratings = mockRatings
        
        // Create rating summaries for all users
        let allUserIds = Set(mockRatings.map { $0.toUserId })
        for userId in allUserIds {
            updateRatingSummary(for: userId)
        }
    }
}

// MARK: - Rating Extensions

extension RatingManager {
    func getAverageRating(for userId: UUID) -> Double {
        guard let summary = getRatingSummary(for: userId) else { return 0.0 }
        return summary.averageRating
    }
    
    func getTotalRatings(for userId: UUID) -> Int {
        guard let summary = getRatingSummary(for: userId) else { return 0 }
        return summary.totalRatings
    }
    
    func getCategoryRating(for userId: UUID, category: RatingCategory) -> Double {
        guard let summary = getRatingSummary(for: userId) else { return 0.0 }
        return summary.categoryRatings[category] ?? 0.0
    }
}
