import Foundation

struct Rating: Codable, Identifiable {
    let id: UUID
    let fromUserId: UUID
    let toUserId: UUID
    let rating: Int // 1-5 stars
    let review: String?
    let category: RatingCategory
    let createdAt: Date
    
    init(id: UUID = UUID(), fromUserId: UUID, toUserId: UUID, rating: Int, review: String? = nil, category: RatingCategory, createdAt: Date = Date()) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.rating = max(1, min(5, rating)) // Ensure rating is between 1-5
        self.review = review
        self.category = category
        self.createdAt = createdAt
    }
}

enum RatingCategory: String, Codable, CaseIterable {
    case service = "Service Quality"
    case communication = "Communication"
    case reliability = "Reliability"
    case value = "Value for Money"
    case overall = "Overall Experience"
    
    var icon: String {
        switch self {
        case .service:
            return "star.fill"
        case .communication:
            return "message.fill"
        case .reliability:
            return "clock.fill"
        case .value:
            return "sterlingsign.circle.fill"
        case .overall:
            return "heart.fill"
        }
    }
}

struct UserRatingSummary: Codable {
    let userId: UUID
    let averageRating: Double
    let totalRatings: Int
    let ratingBreakdown: [Int: Int] // rating value -> count
    let categoryRatings: [RatingCategory: Double]
    let lastUpdated: Date
    
    init(userId: UUID, ratings: [Rating]) {
        self.userId = userId
        self.totalRatings = ratings.count
        
        if ratings.isEmpty {
            self.averageRating = 0.0
            self.ratingBreakdown = [:]
            self.categoryRatings = [:]
        } else {
            // Calculate average rating
            self.averageRating = Double(ratings.map { $0.rating }.reduce(0, +)) / Double(ratings.count)
            
            // Calculate rating breakdown
            var breakdown: [Int: Int] = [:]
            for rating in ratings {
                breakdown[rating.rating, default: 0] += 1
            }
            self.ratingBreakdown = breakdown
            
            // Calculate category ratings
            var categoryRatings: [RatingCategory: Double] = [:]
            for category in RatingCategory.allCases {
                let categoryRatingValues = ratings.filter { $0.category == category }.map { $0.rating }
                if !categoryRatingValues.isEmpty {
                    categoryRatings[category] = Double(categoryRatingValues.reduce(0, +)) / Double(categoryRatingValues.count)
                }
            }
            self.categoryRatings = categoryRatings
        }
        
        self.lastUpdated = Date()
    }
}
