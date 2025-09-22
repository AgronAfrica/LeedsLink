import Foundation

enum ListingType: String, Codable {
    case offer = "Offer"
    case request = "Request"
}

enum ListingCategory: String, Codable, CaseIterable {
    case food = "Food & Beverage"
    case construction = "Construction"
    case professional = "Professional Services"
    case retail = "Retail"
    case health = "Health & Wellness"
    case technology = "Technology"
    case hospitality = "Hospitality"
    case education = "Education"
    case transport = "Transport"
    case other = "Other"
}

struct Listing: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var title: String
    var category: ListingCategory
    var tags: [String]
    var budget: String?
    var price: String?
    var availability: String
    var description: String
    var type: ListingType
    var isUrgent: Bool
    var createdAt: Date
    var address: String?
    var postcode: String?
    
    init(id: UUID = UUID(), userId: UUID, title: String, category: ListingCategory, tags: [String], budget: String? = nil, price: String? = nil, availability: String, description: String, type: ListingType, isUrgent: Bool = false, createdAt: Date = Date(), address: String? = nil, postcode: String? = nil) {
        self.id = id
        self.userId = userId
        self.title = title
        self.category = category
        self.tags = tags
        self.budget = budget
        self.price = price
        self.availability = availability
        self.description = description
        self.type = type
        self.isUrgent = isUrgent
        self.createdAt = createdAt
        self.address = address
        self.postcode = postcode
    }
    
    // Helper method to check if this listing matches with another based on tags or category
    func matchScore(with other: Listing) -> Int {
        var score = 0
        
        // Category match (most important)
        if self.category == other.category {
            score += 5
        }
        
        // Tag matches (high value)
        let commonTags = Set(self.tags).intersection(Set(other.tags))
        score += commonTags.count * 2
        
        // Title keyword matches (medium value)
        let titleWords = Set(self.title.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let otherTitleWords = Set(other.title.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let commonTitleWords = titleWords.intersection(otherTitleWords)
        score += commonTitleWords.count
        
        // Description keyword matches (low value)
        let descWords = Set(self.description.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let otherDescWords = Set(other.description.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let commonDescWords = descWords.intersection(otherDescWords)
        score += commonDescWords.count / 2
        
        // Urgent listings get priority
        if other.isUrgent {
            score += 1
        }
        
        return score
    }
}
