import Foundation

enum UserRole: String, Codable, CaseIterable {
    case supplier = "Supplier"
    case serviceProvider = "Service Provider"
    case customer = "Customer"
}

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var businessName: String?
    var role: UserRole
    var address: String
    var phoneNumber: String
    var postcode: String
    var description: String
    var createdAt: Date
    var ratingSummary: UserRatingSummary?
    
    init(id: UUID = UUID(), name: String, businessName: String? = nil, role: UserRole, address: String, phoneNumber: String, postcode: String, description: String, createdAt: Date = Date(), ratingSummary: UserRatingSummary? = nil) {
        self.id = id
        self.name = name
        self.businessName = businessName
        self.role = role
        self.address = address
        self.phoneNumber = phoneNumber
        self.postcode = postcode
        self.description = description
        self.createdAt = createdAt
        self.ratingSummary = ratingSummary
    }
}
