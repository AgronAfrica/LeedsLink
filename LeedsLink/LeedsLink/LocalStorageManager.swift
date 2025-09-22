import Foundation
import SwiftUI

@MainActor
class LocalStorageManager: ObservableObject {
    static let shared = LocalStorageManager()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private let userDefaults = UserDefaults.standard
    private let usersKey = "stored_users"
    private let listingsKey = "stored_listings"
    private let conversationsKey = "stored_conversations"
    private let messagesKey = "stored_messages"
    
    private init() {
        loadCurrentUser()
    }
    
    // MARK: - User Management
    
    private func loadCurrentUser() {
        if let userData = userDefaults.data(forKey: "current_user"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    private func saveCurrentUser() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: "current_user")
        }
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, userData: [String: Any]) async throws {
        // Check if user already exists (using name as identifier since User model doesn't have email)
        let existingUsers = getStoredUsers()
        let userName = userData["name"] as? String ?? ""
        if existingUsers.contains(where: { $0.name == userName }) {
            throw NSError(domain: "LocalStorageManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "User already exists"])
        }
        
        // Create new user with the existing User model structure
        let newUser = User(
            id: UUID(),
            name: userName,
            businessName: userData["businessName"] as? String,
            role: UserRole(rawValue: userData["role"] as? String ?? "Customer") ?? .customer,
            address: userData["address"] as? String ?? "",
            phoneNumber: userData["phoneNumber"] as? String ?? "",
            postcode: userData["postcode"] as? String ?? "",
            description: userData["description"] as? String ?? "",
            createdAt: Date()
        )
        
        // Store user
        var users = existingUsers
        users.append(newUser)
        storeUsers(users)
        
        // Set as current user
        currentUser = newUser
        isAuthenticated = true
        saveCurrentUser()
    }
    
    func signIn(email: String, password: String) async throws {
        // Since User model doesn't have email, we'll use name as identifier
        // In a real app, you'd want to add email to the User model
        let users = getStoredUsers()
        guard let user = users.first(where: { $0.name == email }) else {
            throw NSError(domain: "LocalStorageManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        currentUser = user
        isAuthenticated = true
        saveCurrentUser()
    }
    
    func signOut() throws {
        currentUser = nil
        isAuthenticated = false
        userDefaults.removeObject(forKey: "current_user")
    }
    
    // MARK: - User Data Management
    
    func getUserData(uid: String) async throws -> [String: Any] {
        let users = getStoredUsers()
        guard let userUUID = UUID(uuidString: uid),
              let user = users.first(where: { $0.id == userUUID }) else {
            throw NSError(domain: "LocalStorageManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "User data not found"])
        }
        
        return [
            "id": user.id.uuidString,
            "name": user.name,
            "businessName": user.businessName ?? "",
            "role": user.role.rawValue,
            "address": user.address,
            "phoneNumber": user.phoneNumber,
            "postcode": user.postcode,
            "description": user.description,
            "createdAt": user.createdAt
        ]
    }
    
    func updateUserData(uid: String, data: [String: Any]) async throws {
        var users = getStoredUsers()
        guard let userUUID = UUID(uuidString: uid),
              let index = users.firstIndex(where: { $0.id == userUUID }) else {
            throw NSError(domain: "LocalStorageManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        var user = users[index]
        user.name = data["name"] as? String ?? user.name
        user.businessName = data["businessName"] as? String ?? user.businessName
        user.role = UserRole(rawValue: data["role"] as? String ?? user.role.rawValue) ?? user.role
        user.address = data["address"] as? String ?? user.address
        user.phoneNumber = data["phoneNumber"] as? String ?? user.phoneNumber
        user.postcode = data["postcode"] as? String ?? user.postcode
        user.description = data["description"] as? String ?? user.description
        
        users[index] = user
        storeUsers(users)
        
        // Update current user if it's the same user
        if currentUser?.id == userUUID {
            currentUser = user
            saveCurrentUser()
        }
    }
    
    // MARK: - Listings Management
    
    func createListing(_ listing: [String: Any]) async throws -> String {
        let listingId = UUID().uuidString
        var newListing = listing
        newListing["id"] = listingId
        newListing["createdAt"] = Date()
        newListing["updatedAt"] = Date()
        
        var listings = getStoredListings()
        listings.append(newListing)
        storeListings(listings)
        
        return listingId
    }
    
    func updateListing(_ listingId: String, data: [String: Any]) async throws {
        var listings = getStoredListings()
        guard let index = listings.firstIndex(where: { $0["id"] as? String == listingId }) else {
            throw NSError(domain: "LocalStorageManager", code: 5, userInfo: [NSLocalizedDescriptionKey: "Listing not found"])
        }
        
        var listing = listings[index]
        for (key, value) in data {
            listing[key] = value
        }
        listing["updatedAt"] = Date()
        
        listings[index] = listing
        storeListings(listings)
    }
    
    func deleteListing(_ listingId: String) async throws {
        var listings = getStoredListings()
        listings.removeAll { $0["id"] as? String == listingId }
        storeListings(listings)
    }
    
    func getAllListings() async throws -> [[String: Any]] {
        return getStoredListings().sorted { listing1, listing2 in
            let date1 = listing1["createdAt"] as? Date ?? Date.distantPast
            let date2 = listing2["createdAt"] as? Date ?? Date.distantPast
            return date1 > date2
        }
    }
    
    func getListingsByUser(_ userId: String) async throws -> [[String: Any]] {
        return getStoredListings().filter { $0["userId"] as? String == userId }
            .sorted { listing1, listing2 in
                let date1 = listing1["createdAt"] as? Date ?? Date.distantPast
                let date2 = listing2["createdAt"] as? Date ?? Date.distantPast
                return date1 > date2
            }
    }
    
    // MARK: - Conversations and Messages
    
    func createConversation(participants: [String], listingId: String) async throws -> String {
        let conversationId = UUID().uuidString
        let conversationData: [String: Any] = [
            "id": conversationId,
            "participants": participants,
            "listingId": listingId,
            "createdAt": Date(),
            "lastMessage": "",
            "lastMessageAt": Date(),
            "updatedAt": Date()
        ]
        
        var conversations = getStoredConversations()
        conversations.append(conversationData)
        storeConversations(conversations)
        
        return conversationId
    }
    
    func getConversations(for userId: String) async throws -> [[String: Any]] {
        return getStoredConversations().filter { conversation in
            let participants = conversation["participants"] as? [String] ?? []
            return participants.contains(userId)
        }.sorted { conversation1, conversation2 in
            let date1 = conversation1["lastMessageAt"] as? Date ?? Date.distantPast
            let date2 = conversation2["lastMessageAt"] as? Date ?? Date.distantPast
            return date1 > date2
        }
    }
    
    func sendMessage(conversationId: String, senderId: String, text: String) async throws {
        let messageId = UUID().uuidString
        let messageData: [String: Any] = [
            "id": messageId,
            "conversationId": conversationId,
            "senderId": senderId,
            "text": text,
            "timestamp": Date(),
            "readBy": [senderId]
        ]
        
        // Store message
        var messages = getStoredMessages()
        messages.append(messageData)
        storeMessages(messages)
        
        // Update conversation with last message
        var conversations = getStoredConversations()
        if let index = conversations.firstIndex(where: { $0["id"] as? String == conversationId }) {
            conversations[index]["lastMessage"] = text
            conversations[index]["lastMessageAt"] = Date()
            conversations[index]["updatedAt"] = Date()
            storeConversations(conversations)
        }
    }
    
    func getMessages(for conversationId: String) async throws -> [[String: Any]] {
        return getStoredMessages().filter { $0["conversationId"] as? String == conversationId }
            .sorted { message1, message2 in
                let date1 = message1["timestamp"] as? Date ?? Date.distantPast
                let date2 = message2["timestamp"] as? Date ?? Date.distantPast
                return date1 < date2
            }
    }
    
    // MARK: - Real-time Listeners (Simulated with Timer)
    
    private var listingsTimer: Timer?
    private var conversationsTimer: Timer?
    private var messagesTimer: Timer?
    
    func listenToListings(completion: @escaping ([[String: Any]]) -> Void) {
        // Simulate real-time updates with a timer
        listingsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                let listings = self.getStoredListings().sorted { listing1, listing2 in
                    let date1 = listing1["createdAt"] as? Date ?? Date.distantPast
                    let date2 = listing2["createdAt"] as? Date ?? Date.distantPast
                    return date1 > date2
                }
                completion(listings)
            }
        }
    }
    
    func listenToConversations(for userId: String, completion: @escaping ([[String: Any]]) -> Void) {
        conversationsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                let conversations = self.getStoredConversations().filter { conversation in
                    let participants = conversation["participants"] as? [String] ?? []
                    return participants.contains(userId)
                }.sorted { conversation1, conversation2 in
                    let date1 = conversation1["lastMessageAt"] as? Date ?? Date.distantPast
                    let date2 = conversation2["lastMessageAt"] as? Date ?? Date.distantPast
                    return date1 > date2
                }
                completion(conversations)
            }
        }
    }
    
    func listenToMessages(for conversationId: String, completion: @escaping ([[String: Any]]) -> Void) {
        messagesTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                let messages = self.getStoredMessages().filter { $0["conversationId"] as? String == conversationId }
                    .sorted { message1, message2 in
                        let date1 = message1["timestamp"] as? Date ?? Date.distantPast
                        let date2 = message2["timestamp"] as? Date ?? Date.distantPast
                        return date1 < date2
                    }
                completion(messages)
            }
        }
    }
    
    func stopListening() {
        listingsTimer?.invalidate()
        conversationsTimer?.invalidate()
        messagesTimer?.invalidate()
        listingsTimer = nil
        conversationsTimer = nil
        messagesTimer = nil
    }
    
    // MARK: - Private Storage Methods
    
    private func getStoredUsers() -> [User] {
        guard let data = userDefaults.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    private func storeUsers(_ users: [User]) {
        if let data = try? JSONEncoder().encode(users) {
            userDefaults.set(data, forKey: usersKey)
        }
    }
    
    private func getStoredListings() -> [[String: Any]] {
        guard let data = userDefaults.data(forKey: listingsKey),
              let listings = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return listings
    }
    
    private func storeListings(_ listings: [[String: Any]]) {
        if let data = try? JSONSerialization.data(withJSONObject: listings) {
            userDefaults.set(data, forKey: listingsKey)
        }
    }
    
    private func getStoredConversations() -> [[String: Any]] {
        guard let data = userDefaults.data(forKey: conversationsKey),
              let conversations = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return conversations
    }
    
    private func storeConversations(_ conversations: [[String: Any]]) {
        if let data = try? JSONSerialization.data(withJSONObject: conversations) {
            userDefaults.set(data, forKey: conversationsKey)
        }
    }
    
    private func getStoredMessages() -> [[String: Any]] {
        guard let data = userDefaults.data(forKey: messagesKey),
              let messages = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        return messages
    }
    
    private func storeMessages(_ messages: [[String: Any]]) {
        if let data = try? JSONSerialization.data(withJSONObject: messages) {
            userDefaults.set(data, forKey: messagesKey)
        }
    }
}
