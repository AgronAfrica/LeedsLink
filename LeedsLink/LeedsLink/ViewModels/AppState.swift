import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var listings: [Listing] = []
    @Published var conversations: [Conversation] = []
    @Published var isOnboarded: Bool = false
    @Published var showSplashScreen: Bool = true
    @Published var showLeedsStory: Bool = true
    
    // Statistics for dashboard
    @Published var listingsCreatedCount: Int = 0
    @Published var matchesFoundCount: Int = 0
    @Published var messagesSentCount: Int = 0
    
    // Track newly created listing for dashboard highlighting
    @Published var newlyCreatedListingId: UUID?
    
    private let dataManager = DataManager.shared
    // private let notificationManager = NotificationManager.shared
    
    init() {
        loadData()
        loadMockData()
    }
    
    // MARK: - User Management
    func createUser(_ user: User) {
        currentUser = user
        isOnboarded = true
        dataManager.saveUser(user)
    }
    
    // MARK: - Listing Management
    func createListing(_ listing: Listing) {
        print("📝 Adding listing to app state: \(listing.title)")
        listings.append(listing)
        listingsCreatedCount += 1
        newlyCreatedListingId = listing.id // Track newly created listing
        dataManager.saveListings(listings)
        print("💾 Saved \(listings.count) listings to storage")
        
        // Update match count when new listing is created
        updateMatchCount()
        
        // Send location-based notifications to users in the same postcode
        // sendLocationBasedNotifications(for: listing)
    }
    
    func deleteListing(_ listingId: UUID) {
        listings.removeAll { $0.id == listingId }
        // Update the count if the deleted listing was created by current user
        if let currentUser = currentUser {
            listingsCreatedCount = listings.filter { $0.userId == currentUser.id }.count
        }
        dataManager.saveListings(listings)
        
        // Update match count when listing is deleted
        updateMatchCount()
    }
    
    func getAllListings() -> [Listing] {
        return listings.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getFilteredListings(role: UserRole? = nil, category: ListingCategory? = nil) -> [Listing] {
        return listings.filter { listing in
            var matches = true
            
            if let role = role {
                // Filter based on role logic - show complementary listings
                switch role {
                case .supplier, .serviceProvider:
                    // Suppliers/Service Providers see requests (what they can fulfill)
                    matches = listing.type == .request
                case .customer:
                    // Customers see offers (what they can buy/use)
                    matches = listing.type == .offer
                }
            }
            
            if let category = category {
                matches = matches && listing.category == category
            }
            
            return matches
        }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getTopMatches(for listing: Listing) -> [Listing] {
        return listings
            .filter { $0.id != listing.id && $0.type != listing.type }
            .map { other in
                (listing: other, score: listing.matchScore(with: other))
            }
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            .prefix(5)
            .map { $0.listing }
    }
    
    func getMatchesForUser() -> [Listing] {
        guard let currentUser = currentUser else { return [] }
        
        let userListings = listings.filter { $0.userId == currentUser.id }
        var allMatches: [Listing] = []
        
        for userListing in userListings {
            let matches = getTopMatches(for: userListing)
            allMatches.append(contentsOf: matches)
        }
        
        // Remove duplicates and return unique matches
        return Array(Set(allMatches.map { $0.id })).compactMap { id in
            allMatches.first { $0.id == id }
        }
    }
    
    func updateMatchCount() {
        let previousCount = matchesFoundCount
        let newMatches = getMatchesForUser()
        matchesFoundCount = newMatches.count
        
        // Notify if new matches were found
        if matchesFoundCount > previousCount {
            print("🎉 New matches found! Total matches: \(matchesFoundCount)")
            
            // Send match notifications for new matches
            // sendMatchNotifications(newMatches: newMatches, previousCount: previousCount)
        }
    }
    
    // MARK: - Message Management
    func sendMessage(in conversationId: UUID, content: String) {
        guard let currentUser = currentUser,
              let index = conversations.firstIndex(where: { $0.id == conversationId }) else { return }
        
        let message = Message(
            senderId: currentUser.id,
            senderName: currentUser.name,
            content: content
        )
        
        conversations[index].messages.append(message)
        messagesSentCount += 1
        dataManager.saveConversations(conversations)
        
        // Send message notification to the recipient
        // sendMessageNotification(message: message, conversationId: conversationId)
    }
    
    func createConversation(with otherUserId: UUID, otherUserName: String) -> UUID {
        guard let currentUser = currentUser else { return UUID() }
        
        let conversation = Conversation(
            participantIds: [currentUser.id, otherUserId],
            participantNames: [currentUser.name, otherUserName]
        )
        
        conversations.append(conversation)
        dataManager.saveConversations(conversations)
        
        return conversation.id
    }
    
    // MARK: - Community Board
    var urgentRequests: [Listing] {
        listings.filter { $0.isUrgent }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    var activeListings: [Listing] {
        listings
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(10)
            .map { $0 }
    }
    
    // MARK: - Dashboard
    var hasLocalPartnerBadge: Bool {
        matchesFoundCount >= 3
    }
    
    // MARK: - User Management
    func signOut() {
        currentUser = nil
        isOnboarded = false
        showSplashScreen = true
        showLeedsStory = true
        listings = []
        conversations = []
        listingsCreatedCount = 0
        matchesFoundCount = 0
        messagesSentCount = 0
        
        // Clear saved data
        dataManager.clearAllData()
    }
    
    func clearAllData() {
        listings = []
        conversations = []
        listingsCreatedCount = 0
        matchesFoundCount = 0
        messagesSentCount = 0
        
        // Clear saved data
        dataManager.clearAllData()
    }
    
    func reloadMockData() {
        // Force reload mock data
        listings = MockDataGenerator.generateMockListings()
        dataManager.saveListings(listings)
        
        if let currentUser = currentUser {
            conversations = MockDataGenerator.generateMockConversations(currentUserId: currentUser.id)
            dataManager.saveConversations(conversations)
        }
        
        // Update statistics
        listingsCreatedCount = listings.filter { $0.userId == currentUser?.id }.count
        updateMatchCount()
    }
    
    // MARK: - Data Loading
    private func loadData() {
        currentUser = dataManager.loadUser()
        isOnboarded = currentUser != nil
        listings = dataManager.loadListings()
        conversations = dataManager.loadConversations()
        
        // Calculate statistics
        listingsCreatedCount = listings.filter { $0.userId == currentUser?.id }.count
        messagesSentCount = conversations.flatMap { $0.messages }.filter { $0.senderId == currentUser?.id }.count
        
        // Calculate matches
        updateMatchCount()
    }
    
    private func loadMockData() {
        // Only load mock data if there are no listings
        if listings.isEmpty {
            let mockListings = MockDataGenerator.generateMockListings()
            listings = mockListings
            dataManager.saveListings(listings)
            
            // Update match count after loading mock data
            updateMatchCount()
        }
        
        if conversations.isEmpty && currentUser != nil {
            let mockConversations = MockDataGenerator.generateMockConversations(currentUserId: currentUser?.id)
            conversations = mockConversations
            dataManager.saveConversations(conversations)
        }
    }
    
    // MARK: - Notification Helpers (commented out to avoid Firebase dependencies)
    
    // Send location-based notifications for new listings
    private func sendLocationBasedNotifications(for listing: Listing) {
        // Commented out to avoid Firebase dependencies
    }
    
    // Send match notifications
    private func sendMatchNotifications(newMatches: [Listing], previousCount: Int) {
        // Commented out to avoid Firebase dependencies
    }
    
    // Send message notifications
    private func sendMessageNotification(message: Message, conversationId: UUID) {
        // Commented out to avoid Firebase dependencies
    }
    
    // Helper method to get users in the same postcode (simulated)
    private func getAllUsersInPostcode(_ postcode: String) -> [User] {
        // In a real app, this would query a database for users in the same postcode
        // For now, we'll return mock users or use existing users from conversations
        var users: [User] = []
        
        // Add current user if they exist
        if let currentUser = currentUser {
            users.append(currentUser)
        }
        
        // Add users from conversations (simulating other users in the area)
        for conversation in conversations {
            for participantId in conversation.participantIds {
                if let participantName = conversation.participantNames.first(where: { _ in true }) {
                    // Create a mock user for notification purposes
                    let mockUser = User(
                        id: participantId,
                        name: participantName,
                        role: .customer,
                        address: "Mock Address",
                        phoneNumber: "000-000-0000",
                        postcode: postcode,
                        description: "Mock user for notifications"
                    )
                    users.append(mockUser)
                }
            }
        }
        
        return users
    }
}