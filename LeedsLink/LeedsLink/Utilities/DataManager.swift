import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    private let userKey = "current_user"
    private let listingsKey = "listings"
    private let conversationsKey = "conversations"
    
    private init() {}
    
    // MARK: - User
    func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
        }
    }
    
    func loadUser() -> User? {
        guard let data = userDefaults.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    // MARK: - Listings
    func saveListings(_ listings: [Listing]) {
        let url = documentsDirectory.appendingPathComponent("listings.json")
        if let encoded = try? JSONEncoder().encode(listings) {
            try? encoded.write(to: url)
        }
    }
    
    func loadListings() -> [Listing] {
        let url = documentsDirectory.appendingPathComponent("listings.json")
        guard let data = try? Data(contentsOf: url),
              let listings = try? JSONDecoder().decode([Listing].self, from: data) else {
            return []
        }
        return listings
    }
    
    // MARK: - Conversations
    func saveConversations(_ conversations: [Conversation]) {
        let url = documentsDirectory.appendingPathComponent("conversations.json")
        if let encoded = try? JSONEncoder().encode(conversations) {
            try? encoded.write(to: url)
        }
    }
    
    func loadConversations() -> [Conversation] {
        let url = documentsDirectory.appendingPathComponent("conversations.json")
        guard let data = try? Data(contentsOf: url),
              let conversations = try? JSONDecoder().decode([Conversation].self, from: data) else {
            return []
        }
        return conversations
    }
    
    // MARK: - Clear Data
    func clearAllData() {
        userDefaults.removeObject(forKey: userKey)
        
        let listingsUrl = documentsDirectory.appendingPathComponent("listings.json")
        try? FileManager.default.removeItem(at: listingsUrl)
        
        let conversationsUrl = documentsDirectory.appendingPathComponent("conversations.json")
        try? FileManager.default.removeItem(at: conversationsUrl)
    }
}
